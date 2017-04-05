/*
	
	******************************************************************
	*																 *
	*           PreRequisite Name - AssetHistoryInsertSP		     *
	*																 *
	******************************************************************
   
   Purpose : Insert Asset History Data tables - Options, Games, Progressive

 */


DROP PROCEDURE IF EXISTS MIGRATION.P_TRUNCATE_ASSET_HISTORY_TBLES
GO

CREATE PROCEDURE MIGRATION.P_TRUNCATE_ASSET_HISTORY_TBLES
AS
TRUNCATE TABLE MIGRATION.GAM_ASSET_SLOT_HISTORY_SUMMARY
TRUNCATE TABLE MIGRATION.GAM_ASSET_SLOT_HISTORY_OPTIONS
TRUNCATE TABLE MIGRATION.GAM_ASSET_SLOT_HISTORY_GAMES
TRUNCATE TABLE MIGRATION.GAM_ASSET_SLOT_HISTORY_PROGRESSIVE

GO

--MAIN SP

DROP PROCEDURE IF EXISTS MIGRATION.P_ASSET_SLOT_HISTORY 
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY (@P_SITE_NUMBER BIGINT)
AS
--DECLARE @P_SITE_NUMBER BIGINT;
DECLARE @P_AM_UID BIGINT;
DECLARE @P_ID_COUNT BIGINT;
--SET @P_SITE_NUMBER = 233
IF OBJECT_ID('tempdb..#TMP_ASSET_UID') IS NOT NULL
DROP TABLE #TMP_ASSET_UID;

SELECT DISTINCT SITE_NUMBER, ASD_AM_UID 
INTO #TMP_ASSET_UID
FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS IMAP ON IMAP.INSM_ID = ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = INSM_SITE_ID
WHERE ISNULL(ASST_ANCESTOR_ID, ASST_ID) = 1
AND SITE_NUMBER = @P_SITE_NUMBER and ASD_AM_UID is not null --AND ASD.IS_DELETED = 0
--select * from #TMP_ASSET_UID
--clearing old records
EXEC MIGRATION.P_TRUNCATE_ASSET_HISTORY_TBLES

SELECT TOP 1 @P_AM_UID = ASD_AM_UID FROM #TMP_ASSET_UID
--set @P_AM_UID = null
BEGIN TRAN
SELECT @P_ID_COUNT = COUNT(*) FROM #TMP_ASSET_UID
WHILE @P_ID_COUNT > 0
BEGIN
	DELETE FROM #TMP_ASSET_UID where ASD_AM_UID = @P_AM_UID
	PRINT @P_AM_UID
	EXEC MIGRATION.P_ASSET_SLOT_HISTORY_SUMMARY @P_AM_UID
	EXEC MIGRATION.P_ASSET_SLOT_HISTORY_OPTIONS @P_AM_UID 
	EXEC MIGRATION.P_ASSET_SLOT_HISTORY_PROGRESSIVE @P_AM_UID 
	EXEC MIGRATION.P_ASSET_SLOT_HISTORY_GAMES @P_AM_UID 

	SELECT @P_ID_COUNT = count(*) from #TMP_ASSET_UID
	SELECT top 1 @P_AM_UID = ASD_AM_UID from #TMP_ASSET_UID
END
COMMIT

GO


--- SUMMARY

DROP PROCEDURE IF EXISTS MIGRATION.P_ASSET_SLOT_HISTORY_SUMMARY
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_SUMMARY (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT;
--SET @P_AM_UID = 34;
INSERT INTO MIGRATION.GAM_ASSET_SLOT_HISTORY_SUMMARY
SELECT CL.CLST_NAME AS CLST_NAME,
CL.CLST_ID AS CLST_ID,
CAD.ASD_STD_ID as Current_Id,
ASDOLD.ASD_STD_ID as Pre_Id,
ASD.ASD_NUMBER,
ASD.ASD_AM_UID,
ASD.IS_DELETED AS ASD_DELETED,
STS.CLST_STAT_DESCRIPTION,
ACT.CLSA_CODE AS [ACTION],
CASE ACT.CLSA_ID WHEN 1001 THEN src_ST.site_long_name ELSE dest_ST.site_long_name END AS SOURCE_SITE,
CASE ACT.CLSA_ID WHEN 1001 THEN NULL ELSE src_ST.site_long_name END AS DEST_SITE,
CL.CLST_SCHEDULED_DATE,
CL.CLST_EXECTUED_DATE,
ACT.CLSA_CODE,
ASSET.ASST_NAME AS ASSET_TYPE,
ASTL_DATA_SOURCE,
CL.CREATED_USER,
CL.CLST_AUTH_USER,
cl.CLST_AUTH_USER_SECOND,
CAD.CLST_DET_ID
FROM GAM.CHANGE_LIST AS CL
LEFT JOIN GAM.CHANGE_LIST_STATUS AS STS ON CL.CLST_STAT_ID = STS.CLST_STAT_ID
LEFT JOIN GAM.INSTALLED_SYSTEM_MAP AS CISM ON CL.CLST_INSMAP_ID = CISM.INSM_ID
LEFT JOIN GAM.[SITE] AS ST ON ST.SITE_ID = CISM.INSM_SITE_ID
LEFT JOIN GAM.ASSET AS ASSET ON CL.CLST_ASSET_TYPE = ASSET.ASST_ID
LEFT JOIN GAM.CHANGELIST_ASSET_DETAIL AS CAD ON CL.CLST_ID = CAD.CLST_ID
LEFT JOIN GAM.ASSET_TRANSFER_LIST AS AT ON AT.ASTL_CLST_ID = CL.CLST_ID
LEFT JOIN GAM.[ACTION] AS ACT ON ACT.CLSA_ID = CAD.CLSA_ID
JOIN GAM.ASSET_STANDARD_DETAILS AS ASD ON ASD.ASD_STD_ID = CAD.ASD_STD_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS ISM ON ISM.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS src_ST ON src_ST.SITE_ID = ISM.INSM_SITE_ID
LEFT JOIN GAM.ASSET_STANDARD_DETAILS AS ASDOLD ON ASDOLD.ASD_STD_ID = CAD.CLST_OLD_DATA_ID
LEFT JOIN GAM.INSTALLED_SYSTEM_MAP AS ISMOLD ON ISMOLD.INSM_ID = ASDOLD.ASD_INSMAP_ID
LEFT JOIN GAM.[SITE] AS dest_ST ON dest_ST.SITE_ID = ISMOLD.INSM_SITE_ID
left join PROGRESSIVE.SLOT as prgSlot on prgSlot.asd_std_id = CAD.ASD_STD_ID 
WHERE ASD.ASD_CLST_STAT_ID = 5 AND ASSET.ASST_ID = 1
AND ASD.ASD_AM_UID = @P_AM_UID
ORDER BY CL.CLST_EXECTUED_DATE 
GO


DROP PROCEDURE IF EXISTS MIGRATION.P_ASSET_SLOT_HISTORY_OPTIONS
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_OPTIONS (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT;
--SET @P_AM_UID = 34;
INSERT INTO MIGRATION.GAM_ASSET_SLOT_HISTORY_OPTIONS
SELECT CHANGELIST_NAME, CHANGELIST_ID, CLST_ASD_ID, 
 ASD_AM_UID, ASD_NUMBER, ASD_LOCATION, OLD_ASD_NUMBER, OLD_ASD_LOCATION,
 [ACTION], OPTN_CODE, CURRENT_VALUE, OLD_VALUE, OPTION_ORDER, 
CASE WHEN CURRENT_VALUE <> ISNULL(OLD_VALUE, CURRENT_VALUE) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IS_UPDATED,
CUR_ASD_STD_ID, PRE_ASD_STD_ID,
ASTL_DATA_SOURCE, EXECUTED_DATETIME
--CASE WHEN [ACTION_ID] = 1001 THEN DEST_SITE ELSE SOURCE_SITE END AS SOURCE_SITE, DEST_SITE
-- ASD_SERIAL_NUM, MANF_LONG_NAME, AST_IS_DELETED, OLD_OPTN_ID, OLD_OPTN_VALUE, CL_CREATED_TS, 
-- CREATED_TS, IS_TYPE_CODE_VALUE, OPTN_CUSTOM, FINAL_DISPLAY, 

FROM  (SELECT ASD_NUMBER,  ASD_LOCATION,  ASD_SERIAL_NUM, OLD_ASD_NUMBER, 
OLD_ASD_LOCATION,  MANF_LONG_NAME, ASD_AM_UID, CREATED_TS, CL_CREATED_TS, SOURCE_SITE, DEST_SITE,
OPTN_CODE, OPTN_DESCRIPTION, ASSET_TYPE, OPTION_ORDER,  ACTION_CODE AS [ACTION], AST_IS_DELETED,

CASE CUR_DATA.ACTION_ID WHEN 1001 THEN CUR_DATA.AST_OPTION_ID
 ELSE OLD_DATA.AST_OPTION_ID END AS OLD_OPTN_ID,

CASE CUR_DATA.ACTION_ID WHEN 1001 THEN CUR_DATA.CURRENT_VALUE
ELSE OLD_DATA.OLD_VALUE  END AS OLD_OPTN_VALUE,

CUR_DATA.ACTION_ID AS [ACTION_ID], CUR_DATA.ASD_STD_ID,  0 AS ACTION_COUNT,
CUR_DATA.AST_OPTION_ID AS CUR_DATA_AST_OPTION_ID,

CASE CUR_DATA.ACTION_ID   WHEN 1001 THEN CUR_DATA.AST_OPTION_ID   ELSE OLD_DATA.AST_OPTION_ID
END AS OLD_DATA_AST_OPTION_ID,

(CASE CUR_DATA.ACTION_ID   WHEN 1001 THEN CASE 
WHEN LTRIM(RTRIM(ISNULL(CUR_DATA.CURRENT_VALUE,''))) = '' THEN CUR_DATA.CURRENT_VALUE
ELSE '-'+CUR_DATA.CURRENT_VALUE END ELSE OLD_DATA.OLD_VALUE END) AS OLD_VALUE_CPRE,

CURRENT_VALUE, OLD_VALUE,

CASE (CASE CUR_DATA.ACTION_ID   WHEN 1001 THEN 1
ELSE CASE WHEN ISNULL(CUR_DATA.CURRENT_VALUE,'') <> ISNULL(OLD_DATA.OLD_VALUE,'') THEN 1 ELSE 0
END  END)
WHEN 1 THEN 1 ELSE ROW_NUMBER() OVER(PARTITION BY ASD_AM_UID, CREATED_TS, CUR_DATA.ASD_STD_ID,CUR_DATA.ACTION_ID, 
(CASE CUR_DATA.ACTION_ID WHEN 1001 THEN 1  ELSE CASE WHEN ISNULL(CUR_DATA.CURRENT_VALUE,'') <> ISNULL(OLD_DATA.OLD_VALUE,'')THEN 1
 ELSE 0  END END)
ORDER BY ASD_AM_UID, CREATED_TS, CUR_DATA.ASD_STD_ID, CUR_DATA.ACTION_ID, 
(CASE CUR_DATA.ACTION_ID  WHEN 1001 THEN 1  ELSE CASE
 WHEN ISNULL(CUR_DATA.CURRENT_VALUE,'') <> ISNULL(OLD_DATA.OLD_VALUE,'')THEN 1
ELSE 0  END  END)) END AS FINAL_DISPLAY,

CUR_DATA.ASD_STD_ID AS CUR_ASD_STD_ID,
CUR_DATA.OLD_ASD_STD_ID AS PRE_ASD_STD_ID,

CHANGELIST_NAME, CHANGELIST_ID, CLST_ASD_ID, EXECUTED_DATETIME, 
IS_TYPE_CODE_VALUE, OPTN_CUSTOM, ASTL_DATA_SOURCE 
FROM ( (SELECT ASDCURRENT.ASD_NUMBER, ASDCURRENT.ASD_LOCATION,
ASDCURRENT.ASD_SERIAL_NUM,  MANF.MANF_LONG_NAME,   ASDCURRENT.ASD_AM_UID,
CL.CLST_EXECTUED_DATE AS CREATED_TS,   CAD.CREATED_TS AS CL_CREATED_TS,
INDCURRENT.INSM_NAME AS DEST_SITE,   OTPN.OPTN_CODE, OTPN.OPTN_DESCRIPTION,
AD.AST_OPTION_ID, AD.AST_OPTN_VALUE AS CURRENT_VALUE,
ASSET.ASST_NAME AS ASSET_TYPE,   ASDCURRENT.ASD_ASST_ID AS ASSET_TYPE_ID,
ADEF.ASTDFN_OPTN_ORDER AS OPTION_ORDER,  CAD.CLSA_ID AS ACTION_ID,
ACTION.CLSA_CODE AS ACTION_CODE, ASDCURRENT.IS_DELETED AS AST_IS_DELETED,
AD.AST_DET_ID, ASDCURRENT.ASD_STD_ID, CAD.CLST_OLD_DATA_ID AS OLD_ASD_STD_ID,
CLST_DET_ID AS CLST_ASD_ID,  CL.CLST_NAME AS CHANGELIST_NAME, CL.CLST_ID AS CHANGELIST_ID,
CL.CLST_EXECTUED_DATE AS EXECUTED_DATETIME,
0 AS IS_TYPE_CODE_VALUE, OPTN_CUSTOM, ASTL_DATA_SOURCE
FROM GAM.CHANGELIST_ASSET_DETAIL AS CAD
JOIN GAM.CHANGE_LIST AS CL ON CL.CLST_ID = CAD.CLST_ID
LEFT JOIN GAM.ASSET_TRANSFER_LIST AS AT ON AT.ASTL_CLST_ID = CL.CLST_ID
JOIN GAM.[ACTION] AS ACTION ON ACTION.CLSA_ID = CAD.CLSA_ID
JOIN GAM.ASSET_STANDARD_DETAILS AS ASDCURRENT ON ASDCURRENT.ASD_STD_ID = CAD.ASD_STD_ID
AND ASDCURRENT.ASD_CLST_STAT_ID = 5
JOIN GAM.ASSET AS ASSET ON ASSET.ASST_ID = ASDCURRENT.ASD_ASST_ID
JOIN GAM.MANUFACTURER AS MANF ON MANF.MANF_ID = ASDCURRENT.ASD_MANF_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS INDCURRENT ON INDCURRENT.INSM_ID = ASDCURRENT.ASD_INSMAP_ID
JOIN GAM.ASSET_DETAIL AS AD ON AD.ASD_STD_ID = ASDCURRENT.ASD_STD_ID
JOIN GAM.[OPTION] AS OTPN ON OTPN.OPTN_ID = AD.AST_OPTION_ID
JOIN GAM.ASSET_DEFINITION AS ADEF ON ADEF.ASTDFN_OPTN_ID = OTPN.OPTN_ID
AND ASDCURRENT.ASD_ASST_ID=ASTDFN_ASST_ID
WHERE ASDCURRENT.ASD_CLST_STAT_ID = 5 
 AND ASDCURRENT.ASD_AM_UID = @P_AM_UID
            UNION 
SELECT ASDCURRENT.ASD_NUMBER, ASDCURRENT.ASD_LOCATION, 
ASDCURRENT.ASD_SERIAL_NUM, MANF.MANF_LONG_NAME,
ASDCURRENT.ASD_AM_UID,  CL.CLST_EXECTUED_DATE AS CREATED_TS,
CAD.CREATED_TS AS CL_CREATED_TS, INDCURRENT.INSM_NAME AS DEST_SITE,
OTPN.OPTN_CODE, OTPN.OPTN_DESCRIPTION, TCV.TYCV_OPTN_ID,
TCV.TYCV_OPTN_VALUE AS CURRENT_VALUE, ASSET.ASST_NAME AS ASSET_TYPE,
ASDCURRENT.ASD_ASST_ID AS ASSET_TYPE_ID,  ADEF.ASTDFN_OPTN_ORDER AS OPTION_ORDER,
CAD.CLSA_ID AS ACTION_ID,  ACTION.CLSA_CODE AS ACTION_CODE,
ASDCURRENT.IS_DELETED AS AST_IS_DELETED, TCV.TYCV_ID, ASDCURRENT.ASD_STD_ID,
CAD.CLST_OLD_DATA_ID AS OLD_ASD_STD_ID, CLST_DET_ID AS CLST_ASD_ID,
CL.CLST_NAME AS CHANGELIST_NAME,  CL.CLST_ID AS CHANGELIST_ID, 
CL.CLST_EXECTUED_DATE AS EXECUTED_DATETIME,
1 AS IS_TYPE_CODE_VALUE,OPTN_CUSTOM,  ASTL_DATA_SOURCE
FROM GAM.ASSET_STANDARD_DETAILS AS ASDCURRENT
JOIN GAM.CHANGELIST_ASSET_DETAIL AS CAD ON ASDCURRENT.ASD_STD_ID = CAD.ASD_STD_ID
JOIN GAM.CHANGE_LIST AS CL ON CL.CLST_ID = CAD.CLST_ID
LEFT JOIN GAM.ASSET_TRANSFER_LIST AS AT ON AT.ASTL_CLST_ID = CL.CLST_ID
JOIN GAM.ACTION AS ACTION ON ACTION.CLSA_ID = CAD.CLSA_ID
JOIN GAM.ASSET AS ASSET ON ASSET.ASST_ID = ASDCURRENT.ASD_ASST_ID
JOIN GAM.MANUFACTURER AS MANF ON MANF.MANF_ID = ASDCURRENT.ASD_MANF_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS INDCURRENT ON INDCURRENT.INSM_ID = ASDCURRENT.ASD_INSMAP_ID
JOIN GAM.TYPE_CODE_VALUES AS TCV ON TCV.TYCV_TYCOD_ID = ASDCURRENT.ASD_TCOD_ID
JOIN GAM.[OPTION] AS OTPN ON OTPN.OPTN_ID = TCV.TYCV_OPTN_ID
JOIN GAM.ASSET_DEFINITION AS ADEF ON ADEF.ASTDFN_OPTN_ID = OTPN.OPTN_ID
AND ASDCURRENT.ASD_ASST_ID = ASTDFN_ASST_ID
WHERE 1 = 1 AND ASDCURRENT.ASD_CLST_STAT_ID = 5
 AND ASDCURRENT.ASD_AM_UID = @P_AM_UID
) AS CUR_DATA

LEFT JOIN (SELECT ASDOLD.ASD_AM_UID AS OLD_ASD_AM_UID,
 ASDOLD.ASD_STD_ID AS OLD_ASD_STD_ID,
 ADOLD.AST_DET_ID AS OLD_AST_DET_ID,
 OLDCURRENT.INSM_NAME AS SOURCE_SITE, ADOLD.AST_OPTION_ID AS AST_OPTION_ID,
ASDOLD.ASD_NUMBER AS OLD_ASD_NUMBER,
ASDOLD.ASD_LOCATION AS OLD_ASD_LOCATION,
ASDOLD.ASD_SERIAL_NUM AS OLD_SERIAL_NUM,
ADOLD.AST_OPTN_VALUE AS OLD_VALUE
FROM GAM.ASSET_STANDARD_DETAILS AS ASDOLD
JOIN GAM.INSTALLED_SYSTEM_MAP AS OLDCURRENT ON OLDCURRENT.INSM_ID = ASDOLD.ASD_INSMAP_ID
JOIN GAM.ASSET_DETAIL AS ADOLD ON ADOLD.ASD_STD_ID = ASDOLD.ASD_STD_ID
JOIN GAM.MANUFACTURER AS MNF ON MANF_ID = ASDOLD.ASD_MANF_ID
JOIN GAM.ASSET AS ASSET ON ASSET.ASST_ID = ASDOLD.ASD_ASST_ID
WHERE ASDOLD.ASD_CLST_STAT_ID = 5 
 AND ASDOLD.ASD_AM_UID = @P_AM_UID
UNION 
SELECT ASDOLD.ASD_AM_UID AS OLD_ASD_AM_UID, ASDOLD.ASD_STD_ID AS OLD_ASD_STD_ID, 
TCV.TYCV_ID AS OLD_AST_DET_ID, OLDCURRENT.INSM_NAME AS SOURCE_SITE,
TCV.TYCV_OPTN_ID AS AST_OPTION_ID,ASDOLD.ASD_NUMBER AS OLD_ASD_NUMBER,
ASDOLD.ASD_LOCATION AS OLD_ASD_LOCATION, ASDOLD.ASD_SERIAL_NUM AS OLD_SERIAL_NUM,
TCV.TYCV_OPTN_VALUE AS OLD_VALUE
FROM GAM.ASSET_STANDARD_DETAILS AS ASDOLD
JOIN GAM.INSTALLED_SYSTEM_MAP AS OLDCURRENT ON OLDCURRENT.INSM_ID = ASDOLD.ASD_INSMAP_ID
JOIN GAM.TYPE_CODE_VALUES AS TCV ON TCV.TYCV_TYCOD_ID = ASDOLD.ASD_TCOD_ID
JOIN GAM.MANUFACTURER AS MNF ON MANF_ID = ASDOLD.ASD_MANF_ID
JOIN GAM.ASSET AS ASSET ON ASSET.ASST_ID = ASDOLD.ASD_ASST_ID
WHERE ASDOLD.ASD_CLST_STAT_ID = 5
 and ASDOLD.ASD_AM_UID = @P_AM_UID
) AS OLD_DATA ON CUR_DATA.OLD_ASD_STD_ID = OLD_DATA.OLD_ASD_STD_ID
     AND CUR_DATA.AST_OPTION_ID = OLD_DATA.AST_OPTION_ID))AS COMBINE
--WHERE FINAL_DISPLAY = 1
ORDER BY ASD_AM_UID, EXECUTED_DATETIME, OPTION_ORDER
GO

--GAMES

DROP PROCEDURE IF EXISTS MIGRATION.P_ASSET_SLOT_HISTORY_GAMES
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_GAMES (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT;
--SET @P_AM_UID = 34;
INSERT INTO MIGRATION.GAM_ASSET_SLOT_HISTORY_GAMES
SELECT CL.CLST_ID, CL.CLST_NAME AS Changelist_Name,
cad.CLST_DET_ID, sltGamMap.ASD_AM_UID, 
ACT.CLSA_CODE AS [ACTION],
sltGamMap.GAME_COMBO_NAME as Current_GameComboName,
sltGamMap.GAME_ID as Current_Game_Id,
oldSltGamMap.GAME_COMBO_NAME as Old_GameComboName,
oldSltGamMap.GAME_ID as Old_Game_Id,
cad.ASD_STD_ID, CLST_OLD_DATA_ID,
CL.CLST_UNIQUE_ID, CL.CLST_INSMAP_ID
--, *
 FROM GAM.CHANGE_LIST AS CL 
JOIN GAM.CHANGELIST_ASSET_DETAIL AS CAD ON CL.CLST_ID = CAD.CLST_ID AND CL.CLST_ASSET_TYPE = 1
LEFT JOIN GAM.[ACTION] AS ACT ON ACT.CLSA_ID = CAD.CLSA_ID
-- CURRENT
FULL OUTER JOIN (SELECT ASD.ASD_STD_ID, ASD_AM_UID, GME.GAME_ID, 
GME.GAME_COMBO_NAME FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN [GAM].[GAME_DETAILS_MAPPING] AS GMAP ON GMAP.GDM_ASTSTD_OR_TYCD_ID = ASD.ASD_STD_ID
JOIN [GAM].[GAME_DETAILS] AS GME ON GME.GAME_ID = GMAP.GDM_GAME_ID
WHERE 1 = 1 and ASD_AM_UID = @P_AM_UID) as sltGamMap ON sltGamMap.ASD_STD_ID = CAD.ASD_STD_ID
-- OLD
FULL OUTER JOIN (SELECT ASD.ASD_STD_ID, ASD_AM_UID, GME.GAME_ID, 
GME.GAME_COMBO_NAME FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN [GAM].[GAME_DETAILS_MAPPING] AS GMAP ON GMAP.GDM_ASTSTD_OR_TYCD_ID = ASD.ASD_STD_ID
JOIN [GAM].[GAME_DETAILS] AS GME ON GME.GAME_ID = GMAP.GDM_GAME_ID
WHERE 1 = 1 and ASD_AM_UID = @P_AM_UID ) as oldSltGamMap ON oldSltGamMap.ASD_STD_ID = CLST_OLD_DATA_ID
AND sltGamMap.GAME_ID = oldSltGamMap.GAME_ID

WHERE 1 = 1 AND sltGamMap.ASD_AM_UID = @P_AM_UID
ORDER BY CL.CLST_EXECTUED_DATE
GO

--PROGRESSIVE

DROP PROCEDURE IF EXISTS MIGRATION.P_ASSET_SLOT_HISTORY_PROGRESSIVE
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_PROGRESSIVE (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT;
--SET @P_AM_UID = 3151;
INSERT INTO MIGRATION.GAM_ASSET_SLOT_HISTORY_PROGRESSIVE
SELECT CL.CLST_ID, CL.CLST_NAME AS Changelist_Name,
cad.CLST_DET_ID, ASD.ASD_AM_UID, 
ACT.CLSA_CODE AS [ACTION],
p_old.PRGP_NAME as PoolName_Old,
p_curr.PRGP_NAME as PoolName_Current,
CL.CLST_UNIQUE_ID, CL.CLST_INSMAP_ID,
CLST_EXECTUED_DATE

FROM GAM.CHANGE_LIST AS CL 
JOIN GAM.CHANGELIST_ASSET_DETAIL AS CAD ON CL.CLST_ID = CAD.CLST_ID AND CL.CLST_ASSET_TYPE = 1
LEFT JOIN GAM.[ACTION] AS ACT ON ACT.CLSA_ID = CAD.CLSA_ID
JOIN GAM.ASSET_STANDARD_DETAILS AS ASD ON ASD.ASD_STD_ID = CAD.ASD_STD_ID
-- CURRENT
LEFT JOIN (SELECT ASD_STD_ID, p.PRGP_ID, p.PRGP_NAME FROM PROGRESSIVE.SLOT AS PRGSLT
JOIN [PROGRESSIVE].[SLOT_POOL_MAPPING] AS PMAP ON PMAP.[SLOT_ID] = PRGSLT.SLOT_ID
JOIN [PROGRESSIVE].[POOL] as p on p.PRGP_ID = PMAP.PRGP_ID ) as p_curr on p_curr.ASD_STD_ID = CAD.ASD_STD_ID
-- OLD
LEFT JOIN (SELECT ASD_STD_ID, p.PRGP_ID, p.PRGP_NAME FROM PROGRESSIVE.SLOT AS PRGSLT
JOIN [PROGRESSIVE].[SLOT_POOL_MAPPING] AS PMAP ON PMAP.[SLOT_ID] = PRGSLT.SLOT_ID
JOIN [PROGRESSIVE].[POOL] as p on p.PRGP_ID = PMAP.PRGP_ID ) as p_old on p_old.ASD_STD_ID = CLST_OLD_DATA_ID
WHERE 1 = 1 
AND ASD.ASD_CLST_STAT_ID = 5
AND ASD.ASD_AM_UID = @P_AM_UID 
AND (p_curr.PRGP_NAME IS NOT NULL OR p_old.PRGP_NAME IS NOT NULL )
ORDER BY CL.CLST_EXECTUED_DATE
GO

