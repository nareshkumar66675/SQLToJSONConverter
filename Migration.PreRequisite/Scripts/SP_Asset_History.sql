/*
	
	******************************************************************
	*																 *
	*           PreRequisite Name - AssetHistoryInsertSP		     *
	*																 *
	******************************************************************
   
   Purpose : Insert Asset History Data tables - Options, Games, Progressive

 */


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_ASSET_SLOT_HISTORY_GAMES_MAPPING')
DROP PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_GAMES_MAPPING
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_GAMES_MAPPING (@P_SITE_NUMBER BIGINT)
AS

--DECLARE @P_SITE_NUMBER BIGINT;
--SET @P_SITE_NUMBER = 201
INSERT INTO [MIGRATION].[GAM_HISTORY_SLOT_GAMES_MAPPING]
SELECT ROW_NUMBER() over (partition by gdm_aststd_or_tycd_id order by gdm_aststd_or_tycd_id, GM.Game_id, Id)  as Idx,
GDM_ASTSTD_OR_TYCD_ID as GM_ASD_STD_ID,
gm.Game_Id, ASD_AM_UID, gmOptionName, Code, Id, GmOptionValue, Comp_Id, H_Id as Game_AssetId
FROM GAM.GAME_DETAILS_MAPPING (nolock) AS GMAP
JOIN MIGRATION.GAM_GAME_COMBO_HISTORY (nolock) as h_g on h_g.GAME_ID = GMAP.GDM_GAME_ID
JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD ON ASD.ASD_STD_ID = GDM_ASTSTD_OR_TYCD_ID
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS ISM ON ISM.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] (nolock) AS SRC_ST ON SRC_ST.SITE_ID = ISM.INSM_SITE_ID
JOIN MIGRATION.GAM_HISTORY_GAMES (nolock) AS GM ON  GM.GAME_ID = GMAP.GDM_GAME_ID
WHERE 1=1 AND SITE_NUMBER = @P_SITE_NUMBER

GO


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_TRUNCATE_ASSET_HISTORY_TBLES')
DROP PROCEDURE MIGRATION.P_TRUNCATE_ASSET_HISTORY_TBLES
GO

CREATE PROCEDURE MIGRATION.P_TRUNCATE_ASSET_HISTORY_TBLES
AS
TRUNCATE TABLE MIGRATION.GAM_ASSET_SLOT_HISTORY_SUMMARY
TRUNCATE TABLE MIGRATION.GAM_ASSET_SLOT_HISTORY_OPTIONS
--TRUNCATE TABLE MIGRATION.GAM_ASSET_SLOT_HISTORY_GAMES
TRUNCATE TABLE MIGRATION.GAM_ASSET_SLOT_HISTORY_PROGRESSIVE
TRUNCATE TABLE MIGRATION.GAM_HISTORY_SLOT_GAMES_MAPPING
DELETE FROM MIGRATION.GAM_ASSET_SLOT_OPTIONS_VALUE WHERE P_SITE_TYPE IN (1)

GO


--MAIN SP

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_ASSET_SLOT_HISTORY')
DROP PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY (@P_SITE_NUMBER BIGINT)
AS
--DECLARE @P_SITE_NUMBER BIGINT;
DECLARE @P_AM_UID BIGINT;
DECLARE @P_ID_COUNT BIGINT;
--SET @P_SITE_NUMBER = 233
IF OBJECT_ID('tempdb..#TMP_ASSET_UID') IS NOT NULL
DROP TABLE #TMP_ASSET_UID;

SELECT DISTINCT SITE_NUMBER, ASD_AM_UID, st.SITE_TYPE_ID
INTO #TMP_ASSET_UID
FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD
JOIN GAM.ASSET (nolock) AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS IMAP ON IMAP.INSM_ID = ASD_INSMAP_ID
JOIN GAM.[SITE] (nolock) AS ST ON ST.SITE_ID = INSM_SITE_ID
JOIN GAM.MANUFACTURER (nolock) AS M ON MANF_ID = ASD_MANF_ID
WHERE ISNULL(ASST_ANCESTOR_ID, ASST_ID) = 1
AND SITE_NUMBER = @P_SITE_NUMBER and ASD_AM_UID is not null 
AND (CASE WHEN ST.SITE_TYPE_ID = 3 THEN 0 ELSE ASD.IS_DELETED END) = 0
AND M.MANF_SHORT_NAME NOT IN ('POS')


--select * from #TMP_ASSET_UID
--clearing old records
EXEC MIGRATION.P_TRUNCATE_ASSET_HISTORY_TBLES
--EXEC MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_SITE @P_SITE_NUMBER
EXEC MIGRATION.P_ASSET_SLOT_HISTORY_GAMES_MAPPING @P_SITE_NUMBER

SELECT TOP 1 @P_AM_UID = ASD_AM_UID FROM #TMP_ASSET_UID
--set @P_AM_UID = null
BEGIN TRAN
SELECT @P_ID_COUNT = COUNT(*) FROM #TMP_ASSET_UID
WHILE @P_ID_COUNT > 0
BEGIN
	DELETE FROM #TMP_ASSET_UID where ASD_AM_UID = @P_AM_UID
	--PRINT @P_AM_UID
	-- Population Slot Action Summary
	EXEC MIGRATION.P_ASSET_SLOT_HISTORY_SUMMARY @P_AM_UID
	-- Population Slot Option and Values in Dictionary Form
	EXEC MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_AM_UID @P_AM_UID
	-- Population Slot Updated Option
	EXEC MIGRATION.P_ASSET_SLOT_HISTORY_OPTIONS @P_AM_UID 
	-- Population Slot Updated Progressive
	EXEC MIGRATION.P_ASSET_SLOT_HISTORY_PROGRESSIVE @P_AM_UID 

	SELECT @P_ID_COUNT = count(*) from #TMP_ASSET_UID
	SELECT top 1 @P_AM_UID = ASD_AM_UID from #TMP_ASSET_UID
END
COMMIT

GO


--- SUMMARY

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_ASSET_SLOT_HISTORY_SUMMARY')
DROP PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_SUMMARY
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_SUMMARY (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT
--SET @P_AM_UID = 34
INSERT INTO MIGRATION.GAM_ASSET_SLOT_HISTORY_SUMMARY
SELECT 
CAST(CAST(@P_AM_UID as nvarchar) + 
format(ROW_NUMBER()OVER(order by cl.clst_id ), '0000000000') as bigint) AS Id,
CL.CLST_NAME AS CLST_NAME,
CL.CLST_ID AS CLST_ID,
CAD.ASD_STD_ID as Current_Id,
ASDOLD.ASD_STD_ID as Pre_Id,
MCD.RN as Asst_Histry_Id,
ASD.ASD_NUMBER,
ASD.ASD_AM_UID,
ASD.IS_DELETED AS ASD_DELETED,
STS.CLST_STAT_DESCRIPTION,

CASE WHEN ACT.CLSA_CODE = 'ADD' THEN 'Add'
     WHEN ACT.CLSA_CODE = 'EDIT' THEN 'Edit'
     WHEN ACT.CLSA_CODE = 'MOVE' THEN 'Move'
     WHEN ACT.CLSA_CODE = 'MOVE & EDIT' THEN 'MoveEdit'
ELSE 'None' END AS [ACTION],
CASE ACT.CLSA_ID WHEN 1001 THEN src_ST.site_short_name ELSE dest_ST.site_short_name END AS SOURCE_SITE,
CASE ACT.CLSA_ID WHEN 1001 THEN NULL ELSE src_ST.site_short_name END AS DEST_SITE,
CL.CLST_SCHEDULED_DATE,
CL.CLST_EXECTUED_DATE,
ACT.CLSA_CODE,
ASSET.ASST_NAME AS ASSET_TYPE,
ASTL_DATA_SOURCE,
CL.CREATED_USER,
CL.CLST_AUTH_USER,
cl.CLST_AUTH_USER_SECOND,
CAD.CLST_DET_ID,
GPT.[PROP_NEW_ID] as Site_OrganizationId,
PT.PROP_LONG_NAME as Site_OrganizationName,
ST.SITE_NUMBER as SiteId,
ST.SITE_NUMBER as SiteNumber,
case when CL.CREATED_USER = 'Auto Sync' then 'Sync' else cUsr.actr_user_id end as CreatedBy_UserId,
case when CL.CREATED_USER = 'Auto Sync' then 'Sync' else cUsr.actr_login end as CreatedBy_LoginName,
case when CL.CREATED_USER = 'Auto Sync' then 'Sync' else cUsr.actr_First_name end as CreatedBy_FirstName,
case when CL.CREATED_USER = 'Auto Sync' then 'Sync' else cUsr.actr_middle_name end as CreatedBy_MiddleName,
case when CL.CREATED_USER = 'Auto Sync' then 'Sync' else cUsr.actr_last_name end as CreatedBy_LastName,

case when CL.CLST_AUTH_USER = 'Auto Sync' then 'Sync' else aUsr.actr_user_id end as ApprovedBy_UserId,
case when CL.CLST_AUTH_USER = 'Auto Sync' then 'Sync' else aUsr.actr_login end as ApprovedBy_LoginName,
case when CL.CLST_AUTH_USER = 'Auto Sync' then 'Sync' else aUsr.actr_First_name end as ApprovedBy_FirstName,
case when CL.CLST_AUTH_USER = 'Auto Sync' then 'Sync' else aUsr.actr_middle_name end as ApprovedBy_MiddleName,
case when CL.CLST_AUTH_USER = 'Auto Sync' then 'Sync' else aUsr.actr_last_name end as ApprovedBy_LastName,
ASD.Is_Deleted as Asset_Is_Latest
FROM GAM.CHANGE_LIST (nolock) AS CL
JOIN GAM.CHANGE_LIST_STATUS (nolock) AS STS ON CL.CLST_STAT_ID = STS.CLST_STAT_ID
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS CISM ON CL.CLST_INSMAP_ID = CISM.INSM_ID
JOIN GAM.[SITE] (nolock) AS ST ON ST.SITE_ID = CISM.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE (nolock) AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY (nolock) AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] (nolock) as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.ASSET (nolock) AS ASSET ON CL.CLST_ASSET_TYPE = ASSET.ASST_ID
JOIN GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD ON CL.CLST_ID = CAD.CLST_ID
JOIN MIGRATION.GAM_CHANGELIST_ASSET_DETAIL (nolock) AS MCD ON MCD.CLST_DET_ID = CAD.CLST_DET_ID
LEFT JOIN GAM.ASSET_TRANSFER_LIST (nolock) AS AT ON AT.ASTL_CLST_ID = CL.CLST_ID
JOIN GAM.[ACTION] (nolock) AS ACT ON ACT.CLSA_ID = CAD.CLSA_ID
JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD ON ASD.ASD_STD_ID = CAD.ASD_STD_ID
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS ISM ON ISM.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] (nolock) AS src_ST ON src_ST.SITE_ID = ISM.INSM_SITE_ID
LEFT JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASDOLD ON ASDOLD.ASD_STD_ID = CAD.CLST_OLD_DATA_ID
LEFT JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS ISMOLD ON ISMOLD.INSM_ID = ASDOLD.ASD_INSMAP_ID
LEFT JOIN GAM.[SITE] (nolock) AS dest_ST ON dest_ST.SITE_ID = ISMOLD.INSM_SITE_ID
LEFT JOIN MIGRATION.GAM_SITE (nolock) AS dest_GST ON dest_GST.[SITE_LEGCY_ID] = dest_ST.SITE_ID
LEFT JOIN GAM.PROPERTY (nolock) AS dest_pt ON dest_pt.PROP_ID = dest_ST.SITE_PROP_ID
LEFT JOIN [MIGRATION].[GAM_PROPERTY] (nolock) as dest_gpt on dest_gpt.[PROP_LEGCY_ID] = dest_pt.PROP_ID
LEFT JOIN PROGRESSIVE.SLOT (nolock) as prgSlot on prgSlot.asd_std_id = CAD.ASD_STD_ID 
left join COMMON.USER_ACTOR (nolock) as aUsr on isnull(aUsr.ACTR_ACTIVE_DIR_USER, aUsr.actr_login) = CLST_AUTH_USER
left join COMMON.USER_ACTOR (nolock) as bUsr on isnull(bUsr.ACTR_ACTIVE_DIR_USER, bUsr.actr_login) = CLST_AUTH_USER_SECOND
left join COMMON.USER_ACTOR (nolock) as cUsr on isnull(cUsr.ACTR_ACTIVE_DIR_USER, cUsr.actr_login) = CL.CREATED_USER
WHERE ASD.ASD_CLST_STAT_ID = 5 AND ASSET.ASST_ID = 1
AND ASD.ASD_AM_UID = @P_AM_UID
--ORDER BY CL.CLST_EXECTUED_DATE 
GO


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_ASSET_SLOT_HISTORY_OPTIONS')
DROP PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_OPTIONS
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_OPTIONS (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT;
--SET @P_AM_UID = 11134;
INSERT INTO MIGRATION.GAM_ASSET_SLOT_HISTORY_OPTIONS
SELECT 
CAST(CAST(@P_AM_UID as nvarchar) + 
format(ROW_NUMBER()OVER(order by CHANGELIST_ID ), '0000000000') as bigint) AS Id,
CHANGELIST_NAME, CHANGELIST_ID, CLST_ASD_ID, 
 ASD_AM_UID, ASD_NUMBER, ASD_LOCATION, OLD_ASD_NUMBER, OLD_ASD_LOCATION,
 [ACTION], OPTN_CODE,OPTN_NAME, CURRENT_VALUE, OLD_VALUE, OPTION_ORDER, 
CASE WHEN CURRENT_VALUE <> ISNULL(OLD_VALUE, CURRENT_VALUE) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IS_UPDATED,
--FINAL_DISPLAY,
CUR_ASD_STD_ID, PRE_ASD_STD_ID,
ASTL_DATA_SOURCE, EXECUTED_DATETIME
--REC_COUNT, COMPARED_FLAG
--CASE WHEN [ACTION_ID] = 1001 THEN DEST_SITE ELSE SOURCE_SITE END AS SOURCE_SITE, DEST_SITE
-- ASD_SERIAL_NUM, MANF_LONG_NAME, AST_IS_DELETED, OLD_OPTN_ID, OLD_OPTN_VALUE, CL_CREATED_TS, 
-- CREATED_TS, IS_TYPE_CODE_VALUE, OPTN_CUSTOM, FINAL_DISPLAY, 

FROM  (SELECT ASD_NUMBER,  ASD_LOCATION,  ASD_SERIAL_NUM, OLD_ASD_NUMBER, 
OLD_ASD_LOCATION,  MANF_LONG_NAME, ASD_AM_UID, CREATED_TS, CL_CREATED_TS, SOURCE_SITE, DEST_SITE,
OPTN_CODE,OPTN_NAME, OPTN_DESCRIPTION, ASSET_TYPE, OPTION_ORDER,  ACTION_CODE AS [ACTION], AST_IS_DELETED,

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

--CURRENT_VALUE, OLD_VALUE,

CASE WHEN CURRENT_VALUE <> ISNULL(OLD_VALUE, CURRENT_VALUE) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END COMPARED_FLAG,


CASE WHEN OPTN_CODE in ('ASSET.GMU.CRC.AUTH', 'ASSET.CASLESS.DISAB', 'OPTION.CODE.ENROLMENT.STATUS') THEN 
	(CASE	WHEN CURRENT_VALUE = 'FLAG.NO' then 'N'
		WHEN CURRENT_VALUE = 'FLAG.F' then 'F'
		WHEN CURRENT_VALUE = 'FLAG.YES' then 'Y'
		WHEN CURRENT_VALUE = '' then 'N' END)
     WHEN OPTN_CODE = ('BILL.VALIDATOR.CAPACITY') THEN 
		(CASE	WHEN CURRENT_VALUE = '' then '100'
			WHEN CURRENT_VALUE IS NULL then '100'
			ELSE CURRENT_VALUE END)
 ELSE 
  (CASE WHEN CURRENT_VALUE = 'FLAG.NO' then 'No'
      WHEN CURRENT_VALUE = 'FLAG.BAL' then 'Balance'
      WHEN CURRENT_VALUE = 'FLAG.YES' then 'Yes'
      WHEN CURRENT_VALUE = 'ASSET.CASH.CLUB.ENAB.ENUM.NORMAL' then 'Normal'
      WHEN CURRENT_VALUE = 'VALIDATION.SYSTEM' then 'System'
      WHEN CURRENT_VALUE = 'ETHERNET' then 'Ethernet'
      WHEN CURRENT_VALUE = 'PROTOCOL.TYPE.SAS' then 'SAS'
      WHEN CURRENT_VALUE = 'ASSET.CONFIG.STATUS.OFFLINE' then 'Offline'
      WHEN CURRENT_VALUE = 'ASSET.CONFIG.STATUS.ONLINE' then 'Online'
      WHEN CURRENT_VALUE = 'CONTROLLER.TYPE.THIRDPARTY' then 'Third Party'
      WHEN CURRENT_VALUE = 'ASSET.TYPE.EGM' THEN 'EGM'
      WHEN CURRENT_VALUE = 'PROTOCOL.TYPE.QCOMM' THEN 'QCOMM'
      WHEN CURRENT_VALUE = 'ASSET.CASH.CLUB.ENAB.ENUM.WITH.CCCE' THEN 'With CCCE'
      WHEN CURRENT_VALUE = 'KIOSK.TYPE.K' THEN 'K'
      WHEN CURRENT_VALUE = 'VALIDATION.ENHANCED' THEN 'Enhanced'
      WHEN CURRENT_VALUE = '-------------Select-------------' THEN ''
      WHEN CURRENT_VALUE = 'SM.SERVER.DOWN' THEN 'Server Down'
      WHEN CURRENT_VALUE = 'METER.TYPE.BCD' THEN 'BCD'
      ELSE CURRENT_VALUE end) END as CURRENT_VALUE,

CASE WHEN OPTN_CODE in ('ASSET.GMU.CRC.AUTH', 'ASSET.CASLESS.DISAB', 'OPTION.CODE.ENROLMENT.STATUS') THEN 
	(CASE	WHEN OLD_VALUE = 'FLAG.NO' then 'N'
		WHEN OLD_VALUE = 'FLAG.F' then 'F'
		WHEN OLD_VALUE = 'FLAG.YES' then 'Y' 
		WHEN OLD_VALUE = '' then 'N' END )
    WHEN OPTN_CODE = ('BILL.VALIDATOR.CAPACITY') THEN 
		(CASE	WHEN OLD_VALUE = '' then '100'
			WHEN OLD_VALUE IS NULL then '100'
			ELSE OLD_VALUE END)
 ELSE 
  (CASE WHEN OLD_VALUE = 'FLAG.NO' then 'No'
      WHEN OLD_VALUE = 'FLAG.BAL' then 'Balance'
      WHEN OLD_VALUE = 'FLAG.YES' then 'Yes'
      WHEN OLD_VALUE = 'ASSET.CASH.CLUB.ENAB.ENUM.NORMAL' then 'Normal'
      WHEN OLD_VALUE = 'VALIDATION.SYSTEM' then 'System'
      WHEN OLD_VALUE = 'ETHERNET' then 'Ethernet'
      WHEN OLD_VALUE = 'PROTOCOL.TYPE.SAS' then 'SAS'
      WHEN OLD_VALUE = 'ASSET.CONFIG.STATUS.OFFLINE' then 'Offline'
      WHEN OLD_VALUE = 'ASSET.CONFIG.STATUS.ONLINE' then 'Online'
      WHEN OLD_VALUE = 'CONTROLLER.TYPE.THIRDPARTY' then 'Third Party'
      WHEN OLD_VALUE = 'ASSET.TYPE.EGM' THEN 'EGM'
      WHEN OLD_VALUE = 'PROTOCOL.TYPE.QCOMM' THEN 'QCOMM'
      WHEN OLD_VALUE = 'ASSET.CASH.CLUB.ENAB.ENUM.WITH.CCCE' THEN 'With CCCE'
      WHEN OLD_VALUE = 'KIOSK.TYPE.K' THEN 'K'
      WHEN OLD_VALUE = 'VALIDATION.ENHANCED' THEN 'Enhanced'
      WHEN OLD_VALUE = '-------------Select-------------' THEN ''
      WHEN OLD_VALUE = 'SM.SERVER.DOWN' THEN 'Server Down'
      WHEN OLD_VALUE = 'METER.TYPE.BCD' THEN 'BCD'
      ELSE OLD_VALUE end) END as OLD_VALUE,


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
INDCURRENT.INSM_NAME AS DEST_SITE, OTPN.OPTN_CODE,OPTN_NAME, OTPN.OPTN_DESCRIPTION,
AD.AST_OPTION_ID, AD.AST_OPTN_VALUE AS CURRENT_VALUE,
ASSET.ASST_NAME AS ASSET_TYPE,   ASDCURRENT.ASD_ASST_ID AS ASSET_TYPE_ID,
ADEF.ASTDFN_OPTN_ORDER AS OPTION_ORDER,  CAD.CLSA_ID AS ACTION_ID,
ACTION.CLSA_CODE AS ACTION_CODE, ASDCURRENT.IS_DELETED AS AST_IS_DELETED,
AD.AST_DET_ID, ASDCURRENT.ASD_STD_ID, CAD.CLST_OLD_DATA_ID AS OLD_ASD_STD_ID,
CLST_DET_ID AS CLST_ASD_ID,  CL.CLST_NAME AS CHANGELIST_NAME, CL.CLST_ID AS CHANGELIST_ID,
CL.CLST_EXECTUED_DATE AS EXECUTED_DATETIME,
0 AS IS_TYPE_CODE_VALUE, OPTN_CUSTOM, ASTL_DATA_SOURCE
FROM GAM.CHANGE_LIST (nolock) AS CL
JOIN GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD ON CL.CLST_ID = CAD.CLST_ID
LEFT JOIN GAM.ASSET_TRANSFER_LIST (nolock) AS AT ON AT.ASTL_CLST_ID = CL.CLST_ID
JOIN GAM.[ACTION] (nolock) AS ACTION ON ACTION.CLSA_ID = CAD.CLSA_ID
JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASDCURRENT ON ASDCURRENT.ASD_STD_ID = CAD.ASD_STD_ID
AND ASDCURRENT.ASD_CLST_STAT_ID = 5
JOIN GAM.ASSET (nolock) AS ASSET ON ASSET.ASST_ID = ASDCURRENT.ASD_ASST_ID
JOIN GAM.MANUFACTURER (nolock) AS MANF ON MANF.MANF_ID = ASDCURRENT.ASD_MANF_ID
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS INDCURRENT ON INDCURRENT.INSM_ID = ASDCURRENT.ASD_INSMAP_ID
JOIN GAM.ASSET_DETAIL (nolock) AS AD ON AD.ASD_STD_ID = ASDCURRENT.ASD_STD_ID
JOIN GAM.[OPTION] (nolock) AS OTPN ON OTPN.OPTN_ID = AD.AST_OPTION_ID
JOIN GAM.ASSET_DEFINITION (nolock) AS ADEF ON ADEF.ASTDFN_OPTN_ID = OTPN.OPTN_ID
AND ASDCURRENT.ASD_ASST_ID=ASTDFN_ASST_ID
WHERE ASDCURRENT.ASD_CLST_STAT_ID = 5 
AND AD.AST_OPTION_ID NOT IN ( 277 )
 AND ASDCURRENT.ASD_AM_UID = @P_AM_UID
            UNION 
SELECT ASDCURRENT.ASD_NUMBER, ASDCURRENT.ASD_LOCATION, 
ASDCURRENT.ASD_SERIAL_NUM, MANF.MANF_LONG_NAME,
ASDCURRENT.ASD_AM_UID,  CL.CLST_EXECTUED_DATE AS CREATED_TS,
CAD.CREATED_TS AS CL_CREATED_TS, INDCURRENT.INSM_NAME AS DEST_SITE,
OTPN.OPTN_CODE,OPTN_NAME, OTPN.OPTN_DESCRIPTION, TCV.TYCV_OPTN_ID,
TCV.TYCV_OPTN_VALUE AS CURRENT_VALUE, ASSET.ASST_NAME AS ASSET_TYPE,
ASDCURRENT.ASD_ASST_ID AS ASSET_TYPE_ID,  ADEF.ASTDFN_OPTN_ORDER AS OPTION_ORDER,
CAD.CLSA_ID AS ACTION_ID,  ACTION.CLSA_CODE AS ACTION_CODE,
ASDCURRENT.IS_DELETED AS AST_IS_DELETED, TCV.TYCV_ID, ASDCURRENT.ASD_STD_ID,
CAD.CLST_OLD_DATA_ID AS OLD_ASD_STD_ID, CLST_DET_ID AS CLST_ASD_ID,
CL.CLST_NAME AS CHANGELIST_NAME,  CL.CLST_ID AS CHANGELIST_ID, 
CL.CLST_EXECTUED_DATE AS EXECUTED_DATETIME,
1 AS IS_TYPE_CODE_VALUE,OPTN_CUSTOM,  ASTL_DATA_SOURCE
FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASDCURRENT
JOIN GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD ON ASDCURRENT.ASD_STD_ID = CAD.ASD_STD_ID
JOIN GAM.CHANGE_LIST (nolock) AS CL ON CL.CLST_ID = CAD.CLST_ID
LEFT JOIN GAM.ASSET_TRANSFER_LIST (nolock) AS AT ON AT.ASTL_CLST_ID = CL.CLST_ID
JOIN GAM.ACTION (nolock) AS ACTION ON ACTION.CLSA_ID = CAD.CLSA_ID
JOIN GAM.ASSET (nolock) AS ASSET ON ASSET.ASST_ID = ASDCURRENT.ASD_ASST_ID
JOIN GAM.MANUFACTURER (nolock) AS MANF ON MANF.MANF_ID = ASDCURRENT.ASD_MANF_ID
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS INDCURRENT ON INDCURRENT.INSM_ID = ASDCURRENT.ASD_INSMAP_ID
JOIN GAM.TYPE_CODE_VALUES (nolock) AS TCV ON TCV.TYCV_TYCOD_ID = ASDCURRENT.ASD_TCOD_ID
JOIN GAM.[OPTION] (nolock) AS OTPN ON OTPN.OPTN_ID = TCV.TYCV_OPTN_ID
JOIN GAM.ASSET_DEFINITION (nolock) AS ADEF ON ADEF.ASTDFN_OPTN_ID = OTPN.OPTN_ID
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
FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASDOLD
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS OLDCURRENT ON OLDCURRENT.INSM_ID = ASDOLD.ASD_INSMAP_ID
JOIN GAM.ASSET_DETAIL (nolock) AS ADOLD ON ADOLD.ASD_STD_ID = ASDOLD.ASD_STD_ID
JOIN GAM.MANUFACTURER (nolock) AS MNF ON MANF_ID = ASDOLD.ASD_MANF_ID
JOIN GAM.ASSET (nolock) AS ASSET ON ASSET.ASST_ID = ASDOLD.ASD_ASST_ID
WHERE ASDOLD.ASD_CLST_STAT_ID = 5 
 AND ASDOLD.ASD_AM_UID = @P_AM_UID
UNION 
SELECT ASDOLD.ASD_AM_UID AS OLD_ASD_AM_UID, ASDOLD.ASD_STD_ID AS OLD_ASD_STD_ID, 
TCV.TYCV_ID AS OLD_AST_DET_ID, OLDCURRENT.INSM_NAME AS SOURCE_SITE,
TCV.TYCV_OPTN_ID AS AST_OPTION_ID,ASDOLD.ASD_NUMBER AS OLD_ASD_NUMBER,
ASDOLD.ASD_LOCATION AS OLD_ASD_LOCATION, ASDOLD.ASD_SERIAL_NUM AS OLD_SERIAL_NUM,
TCV.TYCV_OPTN_VALUE AS OLD_VALUE
FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASDOLD
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS OLDCURRENT ON OLDCURRENT.INSM_ID = ASDOLD.ASD_INSMAP_ID
JOIN GAM.TYPE_CODE_VALUES (nolock) AS TCV ON TCV.TYCV_TYCOD_ID = ASDOLD.ASD_TCOD_ID
JOIN GAM.MANUFACTURER (nolock) AS MNF ON MANF_ID = ASDOLD.ASD_MANF_ID
JOIN GAM.ASSET (nolock) AS ASSET ON ASSET.ASST_ID = ASDOLD.ASD_ASST_ID
WHERE ASDOLD.ASD_CLST_STAT_ID = 5
 and ASDOLD.ASD_AM_UID = @P_AM_UID
) AS OLD_DATA ON CUR_DATA.OLD_ASD_STD_ID = OLD_DATA.OLD_ASD_STD_ID
     AND CUR_DATA.AST_OPTION_ID = OLD_DATA.AST_OPTION_ID))AS COMBINE
LEFT JOIN (SELECT
  CL.CLST_NAME,
  ASD.ASD_AM_UID AS AST_UNQU_ID,
  ASD.ASD_NUMBER AS ASSET_NUMBER,
  COUNT(*) AS REC_COUNT
FROM GAM.CHANGE_LIST (nolock) AS CL
JOIN GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD ON CAD.CLST_ID = CL.CLST_ID
JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD ON ASD.ASD_STD_ID = CAD.ASD_STD_ID
JOIN GAM.ASSET_DETAIL (nolock) AS AD ON AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD_OLD ON ASD_OLD.ASD_STD_ID = CAD.CLST_OLD_DATA_ID
LEFT JOIN GAM.ASSET_DETAIL (nolock) AS AD_OLD ON AD_OLD.ASD_STD_ID = ASD_OLD.ASD_STD_ID
  AND AD.AST_OPTION_ID = AD_OLD.AST_OPTION_ID
WHERE 1 = 1 AND AD.AST_OPTION_ID NOT IN ( 277 )
GROUP BY cl.CLST_NAME, asd.ASD_AM_UID, asd.ASD_NUMBER) AS ch_Summary
  ON ch_Summary.CLST_NAME = changelist_name
  AND ch_Summary.ast_unqu_id = ASD_AM_UID
WHERE FINAL_DISPLAY = 1
AND COMPARED_FLAG = 1 
--AND (CASE WHEN REC_COUNT >= 1 AND COMPARED_FLAG = 1 THEN 1  WHEN ISNULL(REC_COUNT, 0) = 0 AND COMPARED_FLAG = 0 THEN 1 ELSE 0 END ) = 1  
ORDER BY ASD_AM_UID, EXECUTED_DATETIME, OPTION_ORDER

--GAMES
GO


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_ASSET_SLOT_HISTORY_GAMES')
DROP PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_GAMES
GO


CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_GAMES (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT;
--SET @P_AM_UID = 34;
INSERT INTO MIGRATION.GAM_ASSET_SLOT_HISTORY_GAMES
SELECT 
CAST(CAST(@P_AM_UID as nvarchar) + 
format(ROW_NUMBER()OVER(order by CL.CLST_ID ), '0000000000') as bigint) AS Id,
CL.CLST_ID, CL.CLST_NAME AS Changelist_Name,
cad.CLST_DET_ID, sltGamMap.ASD_AM_UID, 
ACT.CLSA_CODE AS [ACTION],
sltGamMap.GAME_COMBO_NAME as Current_GameComboName,
sltGamMap.GAME_ID as Current_Game_Id,
oldSltGamMap.GAME_COMBO_NAME as Old_GameComboName,
oldSltGamMap.GAME_ID as Old_Game_Id,
cad.ASD_STD_ID, CLST_OLD_DATA_ID,
CL.CLST_UNIQUE_ID, CL.CLST_INSMAP_ID,
Game_Unq_Id,
Game_Unq_Id_Old
--, *
 FROM GAM.CHANGE_LIST (nolock) AS CL 
JOIN GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD ON CL.CLST_ID = CAD.CLST_ID AND CL.CLST_ASSET_TYPE = 1
LEFT JOIN GAM.[ACTION] (nolock) AS ACT ON ACT.CLSA_ID = CAD.CLSA_ID
-- CURRENT
FULL OUTER JOIN (SELECT ASD.ASD_STD_ID, ASD_AM_UID, GME.GAME_ID, 
GME.GAME_COMBO_NAME, h_ID as Game_Unq_Id FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD
JOIN [GAM].[GAME_DETAILS_MAPPING] (nolock) AS GMAP ON GMAP.GDM_ASTSTD_OR_TYCD_ID = ASD.ASD_STD_ID
JOIN [GAM].[GAME_DETAILS] (nolock) AS GME ON GME.GAME_ID = GMAP.GDM_GAME_ID
JOIN MIGRATION.GAM_GAME_COMBO_HISTORY (nolock) as h_g on h_g.GAME_ID = GME.GAME_ID
WHERE 1 = 1 and ASD_AM_UID = @P_AM_UID) as sltGamMap ON sltGamMap.ASD_STD_ID = CAD.ASD_STD_ID
-- OLD
FULL OUTER JOIN (SELECT ASD.ASD_STD_ID, ASD_AM_UID, GME.GAME_ID, 
GME.GAME_COMBO_NAME, h_ID as Game_Unq_Id_Old FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD
JOIN [GAM].[GAME_DETAILS_MAPPING] (nolock) AS GMAP ON GMAP.GDM_ASTSTD_OR_TYCD_ID = ASD.ASD_STD_ID
JOIN [GAM].[GAME_DETAILS] (nolock) AS GME ON GME.GAME_ID = GMAP.GDM_GAME_ID
JOIN MIGRATION.GAM_GAME_COMBO_HISTORY (nolock) as h_g on h_g.GAME_ID = GME.GAME_ID
WHERE 1 = 1 and ASD_AM_UID = @P_AM_UID ) as oldSltGamMap ON oldSltGamMap.ASD_STD_ID = CLST_OLD_DATA_ID
AND sltGamMap.GAME_ID = oldSltGamMap.GAME_ID

WHERE 1 = 1 AND sltGamMap.ASD_AM_UID = @P_AM_UID
--ORDER BY CL.CLST_EXECTUED_DATE
GO

--PROGRESSIVE

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_ASSET_SLOT_HISTORY_PROGRESSIVE')
DROP PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_PROGRESSIVE
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_HISTORY_PROGRESSIVE (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT;
--SET @P_AM_UID = 3151;
INSERT INTO MIGRATION.GAM_ASSET_SLOT_HISTORY_PROGRESSIVE
SELECT 
CAST(CAST(@P_AM_UID as nvarchar) + 
format(ROW_NUMBER()OVER(order by CL.CLST_ID ), '0000000000') as bigint) AS Id,
CL.CLST_ID, CL.CLST_NAME AS Changelist_Name,
cad.CLST_DET_ID, ASD.ASD_AM_UID, 
ACT.CLSA_CODE AS [ACTION],

p_old.PRGP_ID as PoolId_Old,
p_curr.PRGP_ID as PoolId_Current,

p_old.PRGP_NAME as PoolName_Old,
p_curr.PRGP_NAME as PoolName_Current,
CL.CLST_UNIQUE_ID, CL.CLST_INSMAP_ID,
CLST_EXECTUED_DATE

FROM GAM.CHANGE_LIST (nolock) AS CL 
JOIN GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD ON CL.CLST_ID = CAD.CLST_ID AND CL.CLST_ASSET_TYPE = 1
LEFT JOIN GAM.[ACTION] (nolock) AS ACT ON ACT.CLSA_ID = CAD.CLSA_ID
JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD ON ASD.ASD_STD_ID = CAD.ASD_STD_ID
-- CURRENT
LEFT JOIN (SELECT ASD_STD_ID, p.PRGP_ID, p.PRGP_NAME FROM PROGRESSIVE.SLOT (nolock) AS PRGSLT
JOIN [PROGRESSIVE].[SLOT_POOL_MAPPING] (nolock) AS PMAP ON PMAP.[SLOT_ID] = PRGSLT.SLOT_ID
JOIN [PROGRESSIVE].[POOL] (nolock) as p on p.PRGP_ID = PMAP.PRGP_ID ) as p_curr on p_curr.ASD_STD_ID = CAD.ASD_STD_ID
-- OLD
LEFT JOIN (SELECT ASD_STD_ID, p.PRGP_ID, p.PRGP_NAME FROM PROGRESSIVE.SLOT (nolock) AS PRGSLT
JOIN [PROGRESSIVE].[SLOT_POOL_MAPPING] (nolock) AS PMAP ON PMAP.[SLOT_ID] = PRGSLT.SLOT_ID
JOIN [PROGRESSIVE].[POOL] (nolock) as p on p.PRGP_ID = PMAP.PRGP_ID ) as p_old on p_old.ASD_STD_ID = CLST_OLD_DATA_ID
WHERE 1 = 1 
AND ASD.ASD_CLST_STAT_ID = 5
AND ASD.ASD_AM_UID = @P_AM_UID 
AND (p_curr.PRGP_NAME IS NOT NULL OR p_old.PRGP_NAME IS NOT NULL )
--ORDER BY CL.CLST_EXECTUED_DATE
GO




IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_ASSET_SLOT_OPTIONS_VALUE')
DROP PROCEDURE MIGRATION.P_ASSET_SLOT_OPTIONS_VALUE
GO

CREATE PROCEDURE MIGRATION.P_ASSET_SLOT_OPTIONS_VALUE (
@P_ASD_ID BIGINT, 
@P_SITE_NUM INT, 
@P_SITE_TYPE INT
)
AS 
 --209911629000004161, 1, 2
--declare @P_ASD_ID bigint;
--declare @P_SITE_NUM bigint;
--declare @P_SITE_TYPE int;

--set @P_ASD_ID = 209900001000002486
--set @P_SITE_NUM = 1
--set @P_SITE_TYPE = 2

DECLARE @TMP NVARCHAR(MAX)
SET @TMP = '{ "'

SELECT @TMP = @TMP + OPTN_CODE +'":"'+Option_Value+ '", "'
FROM ( SELECT OPTN.OPTN_ID, CASE WHEN OPTN.OPTN_CODE = 'ASSET.MASTER.MANUFACTURER' THEN 'MANUFACTURER' ELSE OPTN.OPTN_CODE END as OPTN_CODE,
CASE WHEN OPTN.OPTN_CODE in ('ASSET.GMU.CRC.AUTH', 'ASSET.CASLESS.DISAB', 'OPTION.CODE.ENROLMENT.STATUS')
 THEN 
	(CASE	WHEN AST_OPTN_VALUE = 'FLAG.NO' then 'N'
		WHEN AST_OPTN_VALUE = 'FLAG.F' then 'F'
		WHEN AST_OPTN_VALUE = 'FLAG.YES' then 'Y'
		WHEN AST_OPTN_VALUE = '' then 'N' END)
    WHEN OPTN.OPTN_CODE = ('BILL.VALIDATOR.CAPACITY') THEN 
		(CASE	WHEN AST_OPTN_VALUE = '' then '100'
			WHEN AST_OPTN_VALUE IS NULL then '100'
			ELSE AST_OPTN_VALUE END)
 ELSE
	(CASE WHEN AST_OPTN_VALUE = 'FLAG.NO' then 'No'
      WHEN AST_OPTN_VALUE = 'FLAG.BAL' then 'Balance'
      WHEN AST_OPTN_VALUE = 'FLAG.YES' then 'Yes'
      WHEN AST_OPTN_VALUE = 'ASSET.CASH.CLUB.ENAB.ENUM.NORMAL' then 'Normal'
      WHEN AST_OPTN_VALUE = 'VALIDATION.SYSTEM' then 'System'
      WHEN AST_OPTN_VALUE = 'ETHERNET' then 'Ethernet'
      WHEN AST_OPTN_VALUE = 'PROTOCOL.TYPE.SAS' then 'SAS'
      WHEN AST_OPTN_VALUE = 'ASSET.CONFIG.STATUS.OFFLINE' then 'Offline'
      WHEN AST_OPTN_VALUE = 'ASSET.CONFIG.STATUS.ONLINE' then 'Online'
      WHEN AST_OPTN_VALUE = 'CONTROLLER.TYPE.THIRDPARTY' then 'Third Party'
      WHEN AST_OPTN_VALUE = 'ASSET.TYPE.EGM' THEN 'EGM'
      WHEN AST_OPTN_VALUE = 'PROTOCOL.TYPE.QCOMM' THEN 'QCOMM'
      WHEN AST_OPTN_VALUE = 'ASSET.CASH.CLUB.ENAB.ENUM.WITH.CCCE' THEN 'With CCCE'
      WHEN AST_OPTN_VALUE = 'KIOSK.TYPE.K' THEN 'K'
      WHEN AST_OPTN_VALUE = 'VALIDATION.ENHANCED' THEN 'Enhanced'
      WHEN AST_OPTN_VALUE = 'SM.SERVER.DOWN' THEN 'Server Down'
      WHEN AST_OPTN_VALUE = 'METER.TYPE.BCD' THEN 'BCD'
      WHEN AST_OPTN_VALUE = '-------------Select-------------' THEN ''
      ELSE ISNULL(cast(AST_OPTN_VALUE as nvarchar), '') END)  END as Option_Value
 FROM GAM.ASSET_DETAIL (nolock) AS AD
JOIN GAM.[OPTION] (nolock) AS OPTN ON OPTN. [OPTN_ID] = AD.AST_OPTION_ID
WHERE ASD_STD_ID = @P_ASD_ID -- 209900182000000001 -- @P_ASD_ID

UNION ALL

SELECT OPTN.OPTN_ID, CASE WHEN OPTN.OPTN_CODE = 'ASSET.MASTER.MANUFACTURER' THEN 'MANUFACTURER' ELSE OPTN.OPTN_CODE END as OPTN_CODE,
CASE WHEN OPTN.OPTN_CODE in ('ASSET.GMU.CRC.AUTH', 'ASSET.CASLESS.DISAB', 'OPTION.CODE.ENROLMENT.STATUS') 
THEN 
	(CASE	WHEN TCV.TYCV_OPTN_VALUE = 'FLAG.NO' then 'N'
		WHEN TCV.TYCV_OPTN_VALUE = 'FLAG.F' then 'F'
		WHEN TCV.TYCV_OPTN_VALUE = 'FLAG.YES' then 'Y'
		WHEN TCV.TYCV_OPTN_VALUE = '' then 'N' END)
    WHEN OPTN.OPTN_CODE = ('BILL.VALIDATOR.CAPACITY') THEN 
		(CASE	WHEN TCV.TYCV_OPTN_VALUE = '' then '100'
			WHEN TCV.TYCV_OPTN_VALUE IS NULL then '100'
			ELSE TCV.TYCV_OPTN_VALUE END)
 ELSE
	(CASE WHEN TCV.TYCV_OPTN_VALUE = 'FLAG.NO' then 'No'
      WHEN TCV.TYCV_OPTN_VALUE = 'FLAG.BAL' then 'Balance'
      WHEN TCV.TYCV_OPTN_VALUE = 'FLAG.YES' then 'Yes'
      WHEN TCV.TYCV_OPTN_VALUE = 'ASSET.CASH.CLUB.ENAB.ENUM.NORMAL' then 'Normal'
      WHEN TCV.TYCV_OPTN_VALUE = 'VALIDATION.SYSTEM' then 'System'
      WHEN TCV.TYCV_OPTN_VALUE = 'ETHERNET' then 'Ethernet'
      WHEN TCV.TYCV_OPTN_VALUE = 'PROTOCOL.TYPE.SAS' then 'SAS'
      WHEN TCV.TYCV_OPTN_VALUE = 'ASSET.CONFIG.STATUS.OFFLINE' then 'Offline'
      WHEN TCV.TYCV_OPTN_VALUE = 'ASSET.CONFIG.STATUS.ONLINE' then 'Online'
      WHEN TCV.TYCV_OPTN_VALUE = 'CONTROLLER.TYPE.THIRDPARTY' then 'Third Party'
      WHEN TCV.TYCV_OPTN_VALUE = 'ASSET.TYPE.EGM' THEN 'EGM'
      WHEN TCV.TYCV_OPTN_VALUE = 'PROTOCOL.TYPE.QCOMM' THEN 'QCOMM'
      WHEN TCV.TYCV_OPTN_VALUE = 'ASSET.CASH.CLUB.ENAB.ENUM.WITH.CCCE' THEN 'With CCCE'
      WHEN TCV.TYCV_OPTN_VALUE = 'KIOSK.TYPE.K' THEN 'K'
      WHEN TCV.TYCV_OPTN_VALUE = 'VALIDATION.ENHANCED' THEN 'Enhanced'
      WHEN TCV.TYCV_OPTN_VALUE = 'SM.SERVER.DOWN' THEN 'Server Down'
      WHEN TCV.TYCV_OPTN_VALUE = 'METER.TYPE.BCD' THEN 'BCD'
      WHEN TCV.TYCV_OPTN_VALUE = '-------------Select-------------' THEN ''
      ELSE ISNULL(cast(TCV.TYCV_OPTN_VALUE as nvarchar), '') END)  END as Option_Value
FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD
join [GAM].[TYPE_CODE_MASTER] (nolock) as tcm on tcm.tycod_id = [ASD_TCOD_ID]
JOIN GAM.TYPE_CODE_VALUES  AS TCV ON TCV.TYCV_TYCOD_ID = TYCOD_ID
join gam.[OPTION] (nolock) as optn on optn.[OPTN_ID] = TYCV_OPTN_ID
WHERE ASD_STD_ID = @P_ASD_ID ) as ovrAll
order by OPTN_ID

SET @tmp = SUBSTRING(@tmp, 0, LEN(@tmp)-2) + '}'
--print @tmp
IF NOT EXISTS (SELECT 1 FROM MIGRATION.GAM_ASSET_SLOT_OPTIONS_VALUE WHERE P_ASD_ID = @P_ASD_ID)
BEGIN
	INSERT INTO MIGRATION.GAM_ASSET_SLOT_OPTIONS_VALUE VALUES (@P_ASD_ID, @P_SITE_NUM, @P_SITE_TYPE , @TMP)
END
GO




IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_GAM_ASSET_SLOT_OPTIONS_SITE')
DROP PROCEDURE MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_SITE
GO


CREATE PROCEDURE MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_SITE (@P_SITE_NUMBER BIGINT)
AS
--DECLARE @P_SITE_NUMBER BIGINT;
DECLARE @P_ASD_STD_ID BIGINT;
DECLARE @V_COUNT BIGINT;
DECLARE @P_SITE_NUM INT;
DECLARE @P_SITE_TYPE INT;
--SET @P_SITE_NUMBER = 201

IF OBJECT_ID('tempdb..#TMP_SLOT_ASD_ID_LIST') IS NOT NULL
DROP TABLE #TMP_SLOT_ASD_ID_LIST;

CREATE TABLE #TMP_SLOT_ASD_ID_LIST (ASD_STD_ID BIGINT, SITE_NUMBER INT, SITE_TYPE INT)

INSERT INTO #TMP_SLOT_ASD_ID_LIST
SELECT ASD.ASD_STD_ID, SITE_NUMBER, SITE_TYPE_ID FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS ISM ON ISM.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.SITE (nolock) AS ST ON ST.SITE_ID = ISM.INSM_SITE_ID
where ST.SITE_NUMBER = @P_SITE_NUMBER
AND ASD_ASST_ID = 1 AND ASD_CLST_STAT_ID = 5

SELECT @V_COUNT = COUNT(*) FROM #TMP_SLOT_ASD_ID_LIST
--PRINT @V_COUNT
--SELECT @P_ASD_STD_ID = MIN(ASD_STD_ID) FROM #TMP_SLOT_ASD_ID_LIST
SELECT TOP 1 @P_ASD_STD_ID = (ASD_STD_ID),
@P_SITE_NUM = SITE_NUMBER,
@P_SITE_TYPE = SITE_TYPE
FROM #TMP_SLOT_ASD_ID_LIST
WHILE @V_COUNT > 0
BEGIN
	DELETE FROM #TMP_SLOT_ASD_ID_LIST WHERE ASD_STD_ID = @P_ASD_STD_ID;
	EXEC MIGRATION.P_ASSET_SLOT_OPTIONS_VALUE @P_ASD_STD_ID, @P_SITE_NUM, @P_SITE_TYPE
	--PRINT  @P_ASD_STD_ID
	SELECT @P_ASD_STD_ID = MIN(ASD_STD_ID) FROM #TMP_SLOT_ASD_ID_LIST
	SELECT @V_COUNT = COUNT(*) FROM #TMP_SLOT_ASD_ID_LIST
END

GO


--Unique ID wise
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_GAM_ASSET_SLOT_OPTIONS_AM_UID')
DROP PROCEDURE MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_AM_UID
GO


CREATE PROCEDURE MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_AM_UID (@P_AM_UID BIGINT)
AS
--DECLARE @P_AM_UID BIGINT;
DECLARE @P_ASD_STD_ID BIGINT;
DECLARE @P_OLD_ASD_STD_ID BIGINT;
DECLARE @V_COUNT BIGINT;
DECLARE @P_SITE_NUM INT;
DECLARE @P_SITE_TYPE INT;
--SET @P_AM_UID = 201

IF OBJECT_ID('tempdb..#TMP_UID_SLOT_ASD_ID_LIST') IS NOT NULL
DROP TABLE #TMP_UID_SLOT_ASD_ID_LIST;

CREATE TABLE #TMP_UID_SLOT_ASD_ID_LIST (ASD_STD_ID BIGINT, OLD_ASD_STD_ID BIGINT, SITE_NUMBER INT, SITE_TYPE INT)

INSERT INTO #TMP_UID_SLOT_ASD_ID_LIST
SELECT DISTINCT CURRENT_ID, CASE WHEN SOURCE_SITE <> DEST_SITE THEN PRE_ID ELSE NULL END AS PRE_ID,
SITENUMBER, SITE_TYPE_ID FROM MIGRATION.GAM_ASSET_SLOT_HISTORY_SUMMARY 
JOIN GAM.[SITE] AS ST ON ST.SITE_NUMBER = SITENUMBER
WHERE ASD_AM_UID = @P_AM_UID

/*SELECT ASD.ASD_STD_ID, SITE_NUMBER, SITE_TYPE_ID FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN GAM.INSTALLED_SYSTEM_MAP AS ISM ON ISM.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.SITE AS ST ON ST.SITE_ID = ISM.INSM_SITE_ID
where ST.SITE_NUMBER = @P_SITE_NUMBER
AND ASD_ASST_ID = 1 AND ASD_CLST_STAT_ID = 5 */


SELECT @V_COUNT = COUNT(*) FROM #TMP_UID_SLOT_ASD_ID_LIST
--PRINT @V_COUNT
--SELECT @P_ASD_STD_ID = MIN(ASD_STD_ID) FROM #TMP_SLOT_ASD_ID_LIST
SELECT TOP 1 @P_ASD_STD_ID = (ASD_STD_ID),
@P_OLD_ASD_STD_ID = OLD_ASD_STD_ID,
@P_SITE_NUM = SITE_NUMBER,
@P_SITE_TYPE = SITE_TYPE
FROM #TMP_UID_SLOT_ASD_ID_LIST
WHILE @V_COUNT > 0
BEGIN
	DELETE FROM #TMP_UID_SLOT_ASD_ID_LIST WHERE ASD_STD_ID = @P_ASD_STD_ID;
	EXEC MIGRATION.P_ASSET_SLOT_OPTIONS_VALUE @P_ASD_STD_ID, @P_SITE_NUM, @P_SITE_TYPE
	--PRINT  @P_ASD_STD_ID
	IF (@P_OLD_ASD_STD_ID IS NOT NULL)
	BEGIN
		--PRINT  @P_OLD_ASD_STD_ID
		EXEC MIGRATION.P_ASSET_SLOT_OPTIONS_VALUE @P_OLD_ASD_STD_ID, @P_SITE_NUM, @P_SITE_TYPE
	END
	--PRINT  @P_ASD_STD_ID
	SELECT TOP 1 @P_ASD_STD_ID = (ASD_STD_ID),
	@P_OLD_ASD_STD_ID = OLD_ASD_STD_ID,
	@P_SITE_NUM = SITE_NUMBER,
	@P_SITE_TYPE = SITE_TYPE
	FROM #TMP_UID_SLOT_ASD_ID_LIST

	SELECT @V_COUNT = COUNT(*) FROM #TMP_UID_SLOT_ASD_ID_LIST
END

GO

DELETE FROM MIGRATION.GAM_ASSET_SLOT_OPTIONS_VALUE
GO

--POPULATE THE DATA FOR WAREHOUSE AND DISPOSAL
EXEC MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_SITE 1
GO
EXEC MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_SITE 2
GO
EXEC MIGRATION.P_GAM_ASSET_SLOT_OPTIONS_SITE 3
GO



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_HISTORY_TRANS') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_HISTORY_TRANS
END
GO

--- populating trans table
SELECT pt.PROP_LONG_NAME, ST.SITE_SHORT_NAME, ST.SITE_NUMBER, count(*) as Trs 
INTO MIGRATION.GAM_ASSET_HISTORY_TRANS
FROM GAM.CHANGE_LIST (nolock) AS CL
LEFT JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS CISM ON CL.CLST_INSMAP_ID = CISM.INSM_ID
LEFT JOIN GAM.[SITE] (nolock) AS ST ON ST.SITE_ID = CISM.INSM_SITE_ID
LEFT JOIN GAM.PROPERTY (nolock) AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
LEFT JOIN GAM.ASSET (nolock) AS ASSET ON CL.CLST_ASSET_TYPE = ASSET.ASST_ID
LEFT JOIN GAM.CHANGELIST_ASSET_DETAIL (nolock) AS CAD ON CL.CLST_ID = CAD.CLST_ID
JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD ON ASD.ASD_STD_ID = CAD.ASD_STD_ID
JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS ISM ON ISM.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] (nolock) AS src_ST ON src_ST.SITE_ID = ISM.INSM_SITE_ID
WHERE ASD.ASD_CLST_STAT_ID = 5 AND ASSET.ASST_ID = 1
GROUP BY pt.PROP_LONG_NAME,ST.SITE_SHORT_NAME, ST.SITE_NUMBER
GO

