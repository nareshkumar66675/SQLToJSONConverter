/*
	
	***************************************************
	*												  *
	*      PreRequisite Name - InsertCustomAssetID    *
	*												  *
	***************************************************
   
   Purpose : To Retrieve unused Custom Asset ID From Legacy

 */


IF OBJECT_ID('tempdb..#TMP_SLOT_NUM_LIST') IS NOT NULL
DROP TABLE #TMP_SLOT_NUM_LIST;

IF OBJECT_ID('tempdb..#TMP_ALL_SLOT_NUM_LIST') IS NOT NULL
DROP TABLE #TMP_ALL_SLOT_NUM_LIST;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.AVAILABLE_ASSET_NUM_LIST') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.AVAILABLE_ASSET_NUM_LIST
END

-------  Fetch Asset ID ----------

SELECT DISTINCT ASD_NUMBER INTO #TMP_SLOT_NUM_LIST
FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN GAM.PROPERTY AS PT ON PT.PROP_ID = ST.SITE_PROP_ID
WHERE ASD.IS_DELETED = 0 AND ASD.ASD_CLST_STAT_ID = 5 AND AST.ASST_ID = 1
AND ST.SITE_TYPE_ID = 1 ORDER BY ASD_NUMBER

-------- Generate Running Sequence ---------
CREATE TABLE #TMP_ALL_SLOT_NUM_LIST(slt_num int);

declare @v_min int;
declare @v_max int;
declare @v_pointer int;

set @v_min = 1
set @v_max = 99999
set @v_pointer = @v_min
WHILE @v_pointer <= @v_max
BEGIN
       INSERT INTO #TMP_ALL_SLOT_NUM_LIST VALUES (@v_pointer)
SET @v_pointer = @v_pointer + 1
END

---------- Retrieve Unused AssetId -------------
SELECT 1 as ID,
	ROW_NUMBER() OVER(ORDER BY SLT_NUM) as [ADDRESS],
    SLT_NUM as [VALUE],
	NULL as CONSUMED_AT
--INTO MIGRATION.AVAILABLE_ASSET_NUM_LIST
FROM #TMP_ALL_SLOT_NUM_LIST AS M
LEFT JOIN #TMP_SLOT_NUM_LIST AS L ON M.SLT_NUM = L.ASD_NUMBER
WHERE L.ASD_NUMBER IS NULL


--SELECT 1 as ID,Id as [ADDRESS],SLT_NUM as VALUE,NULL as CONSUMED_AT from MIGRATION.AVAILABLE_ASSET_NUM_LIST