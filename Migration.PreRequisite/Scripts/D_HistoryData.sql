/*
	
	***************************************************
	*												  *
	*		PreRequisite Name - HistoryData			  *
	*												  *
	***************************************************
   
   Purpose : Insert/Update Data for History Migration

 */



-----------------------------------------
--- BEFORE RUNNING THE HISTORY FROM TOOL

--------------------------------------------------------------
-----Start--** Updating Inital transaction master tables**--
--------------------------------------------------------------
--1.AM UID Population
--2.GAM_CH_ASSET_HISTORY_CHANGELIST
--3.GAM_CHANGELIST_ASSET_DETAIL
--4.GAM_GAME_COMBO_HISTORY
--5.Slot
--------------------------------------------------

--1. AM UID Population
---------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.TMP_CURRENT_ASSET_UID') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.TMP_CURRENT_ASSET_UID 
END
GO


SELECT * INTO MIGRATION.TMP_CURRENT_ASSET_UID
 FROM ( SELECT ASD_STD_ID, ROW_NUMBER() OVER (ORDER BY CREATED_TS) + cpig_counter  AS UID, cpig_counter
FROM GAM.ASSET_STANDARD_DETAILS (nolock) cross join (select cpig_counter from COMMON.CUSTOM_PRIMARY_ID_GENERATOR (nolock)
 WHERE CPIG_SLOT_NUMBER = '9999_AMUID') as mxId
WHERE ASD_CLST_STAT_ID = 5 AND ASD_AM_UID IS NULL ) AS T
GO

--SELECT * FROM MIGRATION.TMP_CURRENT_ASSET_UID
DECLARE @C_UID_UPDATE CURSOR;
DECLARE @P_CURR_ASSET BIGINT;
DECLARE @P_CURR_ASSET_VERSION BIGINT;


SET @C_UID_UPDATE = CURSOR FAST_FORWARD READ_ONLY FOR
SELECT ASD_STD_ID, UID FROM MIGRATION.TMP_CURRENT_ASSET_UID

SET NOCOUNT OFF;
OPEN @C_UID_UPDATE
FETCH NEXT FROM @C_UID_UPDATE INTO @P_CURR_ASSET, @P_CURR_ASSET_VERSION

WHILE @@FETCH_STATUS = 0
BEGIN

;WITH CTE_ASSET_UPDATE 
AS ( 
SELECT DISTINCT @P_CURR_ASSET as CURR_ASSET, CAD.ASD_STD_ID AS ASSET_ID, 
CASE WHEN CAD.ASD_STD_ID = CAD.CLST_OLD_DATA_ID THEN NULL ELSE CAD.CLST_OLD_DATA_ID  END AS ASSET_ID_OLD ,
CAD.CLST_DET_ID,
 1 AS VER
FROM GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD
WHERE CAD.ASD_STD_ID = (@P_CURR_ASSET)  
UNION ALL
SELECT @P_CURR_ASSET CURR_ASSET, CAD.ASD_STD_ID AS ASSET_ID, 
CASE WHEN CAD.ASD_STD_ID = CAD.CLST_OLD_DATA_ID THEN NULL ELSE CAD.CLST_OLD_DATA_ID  END AS ASSET_ID_OLD , 
CAD.CLST_DET_ID,
 VER+1
FROM GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD
JOIN CTE_ASSET_UPDATE T2 ON CAD.ASD_STD_ID = T2.ASSET_ID_OLD
)

UPDATE ASD SET ASD.ASD_AM_UID = @P_CURR_ASSET_VERSION
--SELECT *
 FROM CTE_ASSET_UPDATE 
JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD  ON ASD.ASD_STD_ID = ASSET_ID
WHERE ASD_AM_UID IS NULL --AND ASD_CLST_STAT_ID <> 2
option (maxrecursion  1000)

print '------------------'
print @P_CURR_ASSET
print @P_CURR_ASSET_VERSION
print '------------------'

FETCH NEXT FROM @C_UID_UPDATE INTO @P_CURR_ASSET, @P_CURR_ASSET_VERSION

 END
 CLOSE @C_UID_UPDATE
 DEALLOCATE @C_UID_UPDATE;

 DECLARE @MAX_ID BIGINT;
 SELECT @MAX_ID = MAX(ASD_AM_UID) FROM GAM.ASSET_STANDARD_DETAILS (nolock)
 
 UPDATE COMMON.CUSTOM_PRIMARY_ID_GENERATOR 
 SET CPIG_COUNTER = @max_id
 WHERE CPIG_SLOT_NUMBER = '9999_AMUID'
 GO

DROP TABLE MIGRATION.TMP_CURRENT_ASSET_UID
GO
---------------------------

--2.Changelist
DECLARE @CL_MAX_ID BIGINT;
SELECT @CL_MAX_ID = MAX(CL_RW_ID) FROM MIGRATION.GAM_CH_ASSET_HISTORY_CHANGELIST 
PRINT @CL_MAX_ID + 1

INSERT INTO MIGRATION.GAM_CH_ASSET_HISTORY_CHANGELIST
SELECT @CL_MAX_ID + ROW_NUMBER()over(order by cl.CLST_EXECTUED_DATE asc, cl.CREATED_TS) AS CL_RW_ID,
CL.CLST_ID,  
CAST(0 as bit) as Is_History_Completed, NULL, NULL
FROM GAM.CHANGE_LIST AS CL  
LEFT JOIN MIGRATION.GAM_CH_ASSET_HISTORY_CHANGELIST AS MCL ON CL.CLST_ID = MCL.CLST_ID
WHERE CL.CLST_ASSET_TYPE = 1 AND CL.IS_DELETED = 0 
AND MCL.CLST_ID IS NULL
ORDER BY cl.CLST_EXECTUED_DATE asc, cl.CREATED_TS 

GO

--3.Changelist asset detail
DECLARE @CL_AST_MAX_ID BIGINT;
SELECT @CL_AST_MAX_ID = MAX(RN) FROM MIGRATION.GAM_CHANGELIST_ASSET_DETAIL
PRINT @CL_AST_MAX_ID + 1

INSERT INTO MIGRATION.GAM_CHANGELIST_ASSET_DETAIL
SELECT  @CL_AST_MAX_ID + ROW_NUMBER() OVER (ORDER BY CLST_EXECTUED_DATE, [ASD_AM_UID]) AS RN,  *  
FROM (SELECT C.CLST_ID, CAD.[CLST_DET_ID], ASD.ASD_STD_ID, C.CLST_EXECTUED_DATE, asd.[ASD_AM_UID] 
FROM [GAM].[CHANGELIST_ASSET_DETAIL](nolock) as cad
LEFT JOIN MIGRATION.GAM_CHANGELIST_ASSET_DETAIL AS MCAD ON CAD.CLST_DET_ID = MCAD.CLST_DET_ID
join [GAM].[CHANGE_LIST](nolock) as c on c.clst_id = cad.clst_id
join [GAM].[ASSET_STANDARD_DETAILS](nolock) as asd on asd.asd_std_id = cad.asd_std_id
WHERE C.[CLST_ASSET_TYPE] = 1 AND ASD.[ASD_CLST_STAT_ID] = 5 
AND MCAD.CLST_DET_ID IS NULL ) AS TT

GO

--4.Game
DECLARE @GM_MAX_ID BIGINT;
SELECT @GM_MAX_ID = MAX(h_ID) FROM MIGRATION.GAM_GAME_COMBO_HISTORY
PRINT @GM_MAX_ID + 1

INSERT INTO MIGRATION.GAM_GAME_COMBO_HISTORY
SELECT @GM_MAX_ID + ROW_NUMBER()OVER(ORDER BY g.GAME_ID) AS h_ID, g.GAME_ID 
FROM GAM.GAME_DETAILS (NOLOCK) AS G
LEFT JOIN MIGRATION.GAM_GAME_COMBO_HISTORY AS MG ON G.GAME_ID = MG.GAME_ID
WHERE MG.GAME_ID IS NULL

GO

--5.Slot
--Step 1: --> retriving max asset std count

DECLARE @P_AST_ID BIGINT;
SELECT @P_AST_ID = MAX(ASD_STD_NEW_ID) FROM MIGRATION.GAM_ASSET_STANDARD_DETAILS
PRINT @P_AST_ID
--Step 2: --> adding max asset std count + slot running number
INSERT INTO MIGRATION.GAM_ASSET_STANDARD_DETAILS
SELECT ASD_STD_ID, @P_AST_ID + ROW_NUMBER() OVER(ORDER BY ASD_AM_UID) AS RW_NUM  FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD 
LEFT JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS (nolock) AS msd ON msd.ASD_STD_LEGACY_ID = ASD.ASD_STD_ID
WHERE IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5 and ASD_AM_UID IS NOT NULL 
AND msd.ASD_STD_LEGACY_ID is null ORDER BY ASD.ASD_AM_UID 

GO

--------------------------------------------------------------
-----End--** Updating Inital transaction master tables**--
--------------------------------------------------------------

-----------------------------------------



ALTER PROCEDURE MIGRATION.P_ASSET_CHANGELIST_HISTORY_POPULATION
AS
DECLARE @p_ch_index BIGINT;
DECLARE @p_ch_clst_id BIGINT;
DECLARE @p_ch_trck_count BIGINT;

IF OBJECT_ID('tempdb..#tmp_GAM_CH_ASSET_HISTORY_CHANGELIST') IS NOT NULL
DROP TABLE #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST;

SELECT * INTO #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST
FROM MIGRATION.GAM_CH_ASSET_HISTORY_CHANGELIST WHERE Is_History_Completed = 0 

SELECT @p_ch_trck_count = count(1) from #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST --where Is_History_Completed = 0
SELECT @p_ch_index = min(CL_RW_ID) from #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST --where Is_History_Completed = 0
SELECT @p_ch_clst_id = CLST_ID from #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST where CL_RW_ID = @p_ch_index

PRINT @p_ch_trck_count
PRINT @p_ch_index
PRINT @p_ch_clst_id

WHILE ( @p_ch_trck_count > 0 )
BEGIN
	UPDATE #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST
	SET [CL_HISTORY_START_DATE] = GETDATE()
	WHERE CL_RW_ID = @p_ch_index
	
	print @p_ch_trck_count
	print @p_ch_index
	print @p_ch_clst_id
	----------
	EXEC MIGRATION.P_CHL_ASSET_SLOT_HISTORY_SUMMARY @p_ch_clst_id, @p_ch_index
	EXEC MIGRATION.P_CHK_ASSET_SLOT_HISTORY_OPTIONS @p_ch_clst_id, @p_ch_index
	EXEC MIGRATION.P_CHK_ASSET_SLOT_HISTORY_PROGRESSIVE @p_ch_clst_id, @p_ch_index
	EXEC MIGRATION.P_CHK_GAM_ASSET_SLOT_OPTIONS_AM_UID @p_ch_clst_id
	EXEC MIGRATION.P_CHK_ASSET_SLOT_HISTORY_GAMES_MAPPING @p_ch_clst_id, @p_ch_index
	----------
	UPDATE #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST
	SET [CL_HISTORY_END_DATE] = GETDATE(), Is_History_Completed = 1
	WHERE CL_RW_ID = @p_ch_index

	SELECT @p_ch_trck_count = count(1) FROM #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST WHERE Is_History_Completed = 0
	SELECT @p_ch_index = min(CL_RW_ID) FROM #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST WHERE Is_History_Completed = 0
	SELECT @p_ch_clst_id = CLST_ID FROM #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST WHERE CL_RW_ID = @p_ch_index
END

UPDATE M
SET M.CL_HISTORY_START_DATE = tm.CL_HISTORY_START_DATE,
m.CL_HISTORY_END_DATE = tm.CL_HISTORY_END_DATE,
m.Is_History_Completed = tm.Is_History_Completed
FROM MIGRATION.GAM_CH_ASSET_HISTORY_CHANGELIST as m
JOIN #tmp_GAM_CH_ASSET_HISTORY_CHANGELIST as tm  on m.CLST_ID = tm.CLST_ID
AND m.CL_RW_ID = tm.CL_RW_ID

GO

----