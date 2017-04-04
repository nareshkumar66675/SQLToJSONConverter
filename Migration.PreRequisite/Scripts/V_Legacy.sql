/*
	
	***************************************************
	*												  *
	*        PreRequisite Name - LegacyViews          *
	*												  *
	***************************************************
   
   Purpose : DDL To Create New Views which is necessary for Migration

 */


----------------------------------
--			SITES				--
----------------------------------


DROP VIEW IF EXISTS [MIGRATION].[VIEW_SITE_INFO]
GO

CREATE VIEW [MIGRATION].[VIEW_SITE_INFO]
as
SELECT INSSYSMAP.INSM_GROUP_ID, st.SITE_LONG_NAME, st.SITE_NUMBER,
INSYS.INS_CONNECTION_URL
FROM GAM.SITE AS ST
JOIN GAM.INSTALLED_SYSTEM_MAP AS INSSYSMAP ON INSSYSMAP.INSM_SITE_ID = ST.SITE_ID
JOIN GAM.INSTALLED_SYSTEM AS INSYS ON INSYS.INS_SYS_ID = INSSYSMAP.INSM_SYS_ID
WHERE INSYS.SYS_ID = 3
GO





--------------------------
--		MANUFACTURE     --
--------------------------

DROP VIEW IF EXISTS [Migration].[VIEW_MANUFACTURE]
GO

CREATE VIEW [Migration].[VIEW_MANUFACTURE]
AS
SELECT MF_ID, '22002' AS COMP_TYPE_ID, MANF_ID,
DISPLAY_NAME,
CASE  WHEN VALUE_DESC = 'MANF_SHORT_NAME' then 'Manufacture Short Name'
	  WHEN VALUE_DESC = 'MANF_LONG_NAME' then 'Manufacture Long Name'
	  WHEN VALUE_DESC = 'MANF_VEND_CODE' then 'Code'
END AS MNF_NAME,
CASE  WHEN VALUE_DESC = 'MANF_SHORT_NAME' then 'MANF.SHORT.NAME'
	  WHEN VALUE_DESC = 'MANF_LONG_NAME' then 'MANF.LONG.NAME'
	  WHEN VALUE_DESC = 'MANF_VEND_CODE' then 'MANUF.CODE'
END AS MNF_CODE,
CASE  WHEN VALUE_DESC = 'MANF_SHORT_NAME' then 1
	  WHEN VALUE_DESC = 'MANF_LONG_NAME' then 2
	  WHEN VALUE_DESC = 'MANF_VEND_CODE' then 2
END AS MNF_SEQ,

CASE  WHEN VALUE_DESC = 'MANF_SHORT_NAME' then 1
	  WHEN VALUE_DESC = 'MANF_LONG_NAME' then 2
	  WHEN VALUE_DESC = 'MANF_VEND_CODE' then 3
END AS MNF_CODE_SEQ,
 VALUE 
 FROM
(SELECT MANF_ID, 
MF_NEW_ID as MF_ID,
MANF_LONG_NAME AS DISPLAY_NAME,
CAST(MANF_SHORT_NAME AS NVARCHAR) AS MANF_SHORT_NAME, 
CAST(MANF_LONG_NAME AS NVARCHAR) AS MANF_LONG_NAME,
CAST(MANF_VEND_CODE AS NVARCHAR) AS MANF_VEND_CODE
FROM GAM.MANUFACTURER 
JOIN MIGRATION.GAM_MANUFACTURER ON MNF_LEGCY_ID = MANF_ID 
WHERE IS_DELETED = 0 AND MANF_IS_VENDOR = 0 and MANF_ID > 0 ) MFN
UNPIVOT 
 ( VALUE FOR VALUE_DESC IN (MANF_SHORT_NAME, MANF_LONG_NAME, MANF_VEND_CODE)  ) AS T
 GO



--------------------------
--		Model Type      --
--------------------------

DROP VIEW IF EXISTS [Migration].[VIEW_MODEL_TYPE]
GO

CREATE VIEW [Migration].[VIEW_MODEL_TYPE]
AS
SELECT MDLTYP_ID,
MDLTYPE_NEW_ID,
DISPLAY_NAME,
'22003' AS COMP_TYPE_ID, 
CASE  WHEN VALUE_DESC = 'MDLTYP_SHORT_NAME' then 'Model Type Short Name'
	  WHEN VALUE_DESC = 'MDLTYP_LONG_NAME' then 'Model Type Long Name'
END AS MDL_TYP_NAME,
CASE  WHEN VALUE_DESC = 'MDLTYP_SHORT_NAME' then 'MODEL.TYPE.SHORT.NAME'
	  WHEN VALUE_DESC = 'MDLTYP_LONG_NAME' then 'MODEL.TYPE.LONG.NAME'
END AS MDL_TYP_CODE,
CASE  WHEN VALUE_DESC = 'MDLTYP_SHORT_NAME' then 1
	  WHEN VALUE_DESC = 'MDLTYP_LONG_NAME' then 2
END AS MDL_TYP_SEQ,
 VALUE 
 FROM
(SELECT MDLTYP_ID, MDLTYPE_NEW_ID,
MDLTYP_LONG_NAME AS DISPLAY_NAME,
CAST(MDLTYP_SHORT_NAME AS NVARCHAR) AS MDLTYP_SHORT_NAME, 
CAST(MDLTYP_LONG_NAME AS NVARCHAR) AS MDLTYP_LONG_NAME
FROM GAM.MODEL_TYPE 
JOIN MIGRATION.GAM_MODEL_TYPE AS MG_MT ON MDLTYP_ID = MDLTYPE_LEGCY_ID
WHERE IS_DELETED = 0 ) MDL_TYPE
UNPIVOT
 ( VALUE FOR VALUE_DESC IN (MDLTYP_SHORT_NAME, MDLTYP_LONG_NAME)
 ) AS T

 GO

--------------------------
--		View Model      --
--------------------------
DROP VIEW IF EXISTS [Migration].[VIEW_MODEL]
GO

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[Migration].[VIEW_MODEL]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [Migration].[VIEW_MODEL]
AS
SELECT ''22005'' as COMP_TYPE_ID,
MDL_ID, MDL_MANF_ID,
''MODEL.RELATION'' as Component_Code,
Components_Id ,
Name,
DISPLAY_NAME,
CASE  
WHEN VALUE_DESC = ''MODL_SHORT_NAME'' then ''Model Short Name''
WHEN VALUE_DESC = ''MODL_LONG_NAME'' then ''Model Long Name''
END AS MDL_NAME,
CASE  
WHEN VALUE_DESC = ''MODL_SHORT_NAME'' then ''MODEL.SHORT.NAME''
WHEN VALUE_DESC = ''MODL_LONG_NAME'' then ''MODEL.LONG.NAME''
END AS MDL_CODE,
CASE  
WHEN VALUE_DESC = ''MODL_SHORT_NAME'' then 1
WHEN VALUE_DESC = ''MODL_LONG_NAME'' then 2
END AS MDL_SEQ,
VALUE
FROM ( SELECT MDL.MDL_ID, MDL_MANF_ID, 
MDL_NEW_ID,
MDL_SHORT_NAME as Name,
MDL_LONG_NAME as DISPLAY_NAME,
MDL_NEW_ID AS Components_Id,
CAST(MDL.MDL_SHORT_NAME AS NVARCHAR) AS MODL_SHORT_NAME,
CAST(MDL.MDL_LONG_NAME AS NVARCHAR)  AS MODL_LONG_NAME
FROM  GAM.MODEL AS MDL 
JOIN MIGRATION.GAM_MODEL AS GD ON GD.MDL_LEGCY_ID = MDL.MDL_ID
WHERE MDL.IS_DELETED = 0 ) MDL_TYPE
UNPIVOT
( VALUE FOR VALUE_DESC IN (MODL_SHORT_NAME, MODL_LONG_NAME)  ) AS T


'
GO

--------------------------
--		Theme Type      --
--------------------------

DROP VIEW IF EXISTS [Migration].[VIEW_THEME_TYPE]
GO

CREATE VIEW [Migration].[VIEW_THEME_TYPE]
AS
SELECT TT_ID, '22057' AS COMP_TYPE_ID, TTYP_ID,
DISPLAY_NAME,
CASE  WHEN VALUE_DESC = 'TTYP_SHORT_NAME' then 'Theme Type Short Name'
	  WHEN VALUE_DESC = 'TTYP_LONG_NAME' then 'Theme Type Long Name'
END AS THEM_TYPE_NAME,
CASE  WHEN VALUE_DESC = 'TTYP_SHORT_NAME' then 'THEME.TYPE.SHORT.NAME'
	  WHEN VALUE_DESC = 'TTYP_LONG_NAME' then 'THEME.TYPE.LONG.NAME'
END AS THEM_TYPE_CODE,
CASE  WHEN VALUE_DESC = 'TTYP_SHORT_NAME' then 1
	  WHEN VALUE_DESC = 'TTYP_LONG_NAME' then 2
END AS THEM_TYPE_SEQ,
 VALUE 
 FROM
(SELECT TTYP_ID, 
ROW_NUMBER() OVER (ORDER BY TTYP_ID) AS TT_ID,
TTYP_LONG_NAME AS DISPLAY_NAME,
CAST(TTYP_SHORT_NAME AS NVARCHAR) AS TTYP_SHORT_NAME, 
CAST(TTYP_LONG_NAME AS NVARCHAR) AS TTYP_LONG_NAME
FROM GAM.THEME_TYPE  WHERE IS_DELETED = 0 ) MDL_TYPE
UNPIVOT
 ( VALUE FOR VALUE_DESC IN (TTYP_SHORT_NAME, TTYP_LONG_NAME)  ) AS T
GO

--------------------------
--		Theme Group     --
--------------------------

DROP VIEW IF EXISTS [Migration].[VIEW_THEME_GROUP]
GO

CREATE VIEW [Migration].[VIEW_THEME_GROUP]
AS
SELECT TG_ID, '22058' AS COMP_TYPE_ID, TGRP_ID, TGRP_TTYP_ID,
DISPLAY_NAME,
CASE  WHEN VALUE_DESC = 'TGRP_SHORT_NAME' then 'Theme Group Short Name'
	  WHEN VALUE_DESC = 'TGRP_LONG_NAME' then 'Theme Group Long Name'
END AS THM_GRP_NAME,
CASE  WHEN VALUE_DESC = 'TGRP_SHORT_NAME' then 'THEME.GROUP.SHORT.NAME'
	  WHEN VALUE_DESC = 'TGRP_LONG_NAME' then 'THEME.GROUP.LONG.NAME'
END AS THM_GRP_CODE,
CASE  WHEN VALUE_DESC = 'TGRP_SHORT_NAME' then 1
	  WHEN VALUE_DESC = 'TGRP_LONG_NAME' then 2
END AS THM_GRP_SEQ,
 VALUE 
FROM ( SELECT TGRP_ID, ROW_NUMBER() OVER (ORDER BY TGRP_ID ) AS TG_ID,
TGRP_TTYP_ID,
TGRP_LONG_NAME AS DISPLAY_NAME,
CAST(TGRP_SHORT_NAME AS NVARCHAR) AS TGRP_SHORT_NAME, 
CAST(TGRP_LONG_NAME AS NVARCHAR) AS TGRP_LONG_NAME 
FROM GAM.THEME_GROUP AS GRP WHERE GRP.IS_DELETED = 0 ) TMGRP_TYPE
UNPIVOT
 ( VALUE FOR VALUE_DESC IN (TGRP_SHORT_NAME, TGRP_LONG_NAME)  ) AS T
GO

--------------------------
--   Theme Category     --
--------------------------
DROP VIEW IF EXISTS [Migration].[VIEW_THEME_CATEGORY]
GO

CREATE VIEW [Migration].[VIEW_THEME_CATEGORY]
AS
SELECT TC_ID, '22059' AS COMP_TYPE_ID, TCAT_ID, TCAT_TGRP_ID,
DISPLAY_NAME,
CASE 
	  WHEN VALUE_DESC = 'TCAT_SHORT_NAME' then 'Theme Category Short Name'
	  WHEN VALUE_DESC = 'TCAT_LONG_NAME' then 'Theme Category Long Name'
END AS TCAT_NAME,
CASE 
	  WHEN VALUE_DESC = 'TCAT_SHORT_NAME' then 'THEME.CATEGORY.SHORT.NAME'
	  WHEN VALUE_DESC = 'TCAT_LONG_NAME' then 'THEME.CATEGORY.LONG.NAME'
END AS TCAT_CODE,
CASE 
	  WHEN VALUE_DESC = 'TCAT_SHORT_NAME' then 1
	  WHEN VALUE_DESC = 'TCAT_LONG_NAME' then 2
END AS TCAT_SEQ,
 VALUE 
 FROM ( SELECT TCAT_ID, TCAT_TGRP_ID, ROW_NUMBER() OVER (ORDER BY TCAT_ID ) AS TC_ID,
 TCAT_LONG_NAME AS DISPLAY_NAME,
CAST(TCAT_SHORT_NAME AS NVARCHAR) AS TCAT_SHORT_NAME, 
CAST(TCAT_LONG_NAME AS NVARCHAR) AS TCAT_LONG_NAME
FROM GAM.THEME_CATEGORY AS THEM_CAT WHERE THEM_CAT.IS_DELETED = 0 ) TMGRP_TYPE
UNPIVOT
 ( VALUE FOR VALUE_DESC IN (TCAT_SHORT_NAME, TCAT_LONG_NAME)  ) AS T
 GO
 
--------------------------
--		Theme           --
--------------------------
DROP VIEW IF EXISTS [Migration].[VIEW_THEME]
GO

CREATE VIEW [Migration].[VIEW_THEME]
AS
SELECT TM_ID, '22060' AS COMP_TYPE_ID, THEM_ID,THEME_CAT_ID, 
TTYP_ID, MANF_ID,
DISPLAY_NAME,
CASE 
	  WHEN VALUE_DESC = 'THEM_SHORT_NAME' then 'Theme Name'
	  WHEN VALUE_DESC = 'THEM_LONG_NAME' then 'Theme Name'
END AS THEM_NAME,
CASE 
	  WHEN VALUE_DESC = 'THEM_SHORT_NAME' then 'THEME.NAME'
	  WHEN VALUE_DESC = 'THEM_LONG_NAME' then 'THEME.NAME'
END AS THEM_CODE,
CASE 
	  WHEN VALUE_DESC = 'THEM_SHORT_NAME' then 1
	  WHEN VALUE_DESC = 'THEM_LONG_NAME' then 2
END AS THEM_SEQ,
CASE 
	  WHEN VALUE_DESC = 'THEM_SHORT_NAME' then 1
	  WHEN VALUE_DESC = 'THEM_LONG_NAME' then 1
END AS THEM_CODE_SEQ,
 VALUE 
FROM ( SELECT THEM_ID, TTYP_ID, MANF_ID, THEME_CAT_ID, ROW_NUMBER() OVER (ORDER BY THEM_ID ) AS TM_ID,
CAST(THEM_NAME AS NVARCHAR) AS DISPLAY_NAME, 
CAST(THEM_NAME AS NVARCHAR) AS THEM_SHORT_NAME, 
CAST(THEM_NAME AS NVARCHAR) AS THEM_LONG_NAME, 
CAST(THEM_NAME AS NVARCHAR) AS THEM_NAME
-- SELECT *
FROM GAM.THEME AS THEM WHERE THEM.IS_DELETED = 0 ) TM
UNPIVOT
 ( VALUE FOR VALUE_DESC IN (THEM_SHORT_NAME, THEM_LONG_NAME )  ) AS T
GO

--------------------------
--  Asset Definition    --
--------------------------


DROP VIEW IF EXISTS MIGRATION.VIEW_ASSET_DEFN_LIST
GO

CREATE VIEW MIGRATION.VIEW_ASSET_DEFN_LIST
AS
SELECT AST.ASST_NAME as AM_LGCY_ASST_NAME,
flrAst.ASSET_NAME AS AM_NEW_ASSET_NAME,
flrAst.ASSET_CODE AS AM_NEW_ASSET_CODE,
OPTN.OPTN_NAME as AM_LGCY_OPTN_NAME,
OPTN.OPTN_CODE as AM_LGCY_OPTN_CODE,
OPTN.OPTN_ID as AM_LGCY_OPTN_ID,
 flrAst.* FROM GAM.ASSET_DEFINITION AS ASTDFN
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASTDFN.ASTDFN_ASST_ID
JOIN GAM.[OPTION] AS OPTN ON OPTN.OPTN_ID = ASTDFN.ASTDFN_OPTN_ID
JOIN MIGRATION.ASSET_TYPE_DEFN as flrAst ON OPTION_CODE = OPTN.OPTN_CODE 
and AST.ASST_NAME = flrAst.ASSET_Code
GO



--------------------------
--	Progressive Meter   --
--------------------------

DROP VIEW IF EXISTS [MIGRATION].[VIEW_PROGRESSIVE_METERS]
GO


CREATE VIEW [MIGRATION].[VIEW_PROGRESSIVE_METERS]
AS
SELECT MTR_ID , INSMAP_ID , PRGP_ID , JKPT_ID ,
POOL_NEW_ID,
--MTR_VALUE, MTR_VALUE_DESC ,
----Site------
SiteId as Site_SiteId, 
SiteNumber as Site_SiteNumber,
SiteName as Site_SiteName,
OrganizationId as Site_OrganizationId, 
OrganizationName as Site_OrganizationName,
'false' as Site_IsDeleted,

CASE
       when mtr_value_desc = 'METER_ID' then 1
       when mtr_value_desc = 'MTR_DESCRIPTION' then 2
       when mtr_value_desc = 'MTR_FLOOR_DESCRIPTION' then 3
       when mtr_value_desc = 'MTR_CURRENT_AMOUNT' then 4   
       when mtr_value_desc = 'MTR_RESET_AMOUNT' then 5
       when mtr_value_desc = 'MTR_HAS_HIDDEN_METER' then 6
       when mtr_value_desc = 'MTR_MACHINE_PAY_AMOUNT' then 7   
       when mtr_value_desc = 'MTR_CURRENT_MAXIMUM' then 8
       when mtr_value_desc = 'MTR_CURRENT_FACTOR' then 9
       when mtr_value_desc = 'MTR_HIT_TO_HIT_CONTRIBUTN' then 10
       when mtr_value_desc = 'MTR_HIDDEN_AMOUNT' then 11
       when mtr_value_desc = 'MTR_HIDDEN_MAXIMUM' then 12
       when mtr_value_desc = 'MTR_HIDDEN_FACTOR' then 13
       when mtr_value_desc = 'MTR_BREAK_RATE_FACTOR' then 14
       when mtr_value_desc = 'MTR_BREAK_RATE_THRESHOLD' then 15
       when mtr_value_desc = 'MTR_START_OUT_FACTOR' then 16
       when mtr_value_desc = 'MTR_CURRENT_FRACT_AMT' then 17
       when mtr_value_desc = 'MTR_OVERFLOW_AMOUNT' then 18
       when mtr_value_desc = 'JKPT_JACKPOT_ID' then 19
       when mtr_value_desc = 'PRPM_DESC' then 20
       when mtr_value_desc = 'MTR_LAST_JACKPOT_AMOUNT' then 21
       when mtr_value_desc = 'MTR_LAST_JACKPOT_TS' then 22
       END AS InlineAssets_Id,

CASE
       when mtr_value_desc = 'METER_ID' then 'Meter Id'
       when mtr_value_desc = 'MTR_DESCRIPTION' then 'Meter Description' 
       when mtr_value_desc = 'MTR_FLOOR_DESCRIPTION' then 'Floor Description'
       when mtr_value_desc = 'MTR_CURRENT_AMOUNT' then 'Current Meter Amount'     
       when mtr_value_desc = 'MTR_RESET_AMOUNT' then 'Meter Reset Amount'
       when mtr_value_desc = 'MTR_HAS_HIDDEN_METER' then 'Has Hidden Meter'
       when mtr_value_desc = 'MTR_MACHINE_PAY_AMOUNT' then 'Machine Pay Amount'   
       when mtr_value_desc = 'MTR_CURRENT_MAXIMUM' then 'Current Meter Max Amount'
       when mtr_value_desc = 'MTR_CURRENT_FACTOR' then 'Current Meter Factor'
       when mtr_value_desc = 'MTR_HIT_TO_HIT_CONTRIBUTN' then 'Meter Hit To Hit Contribution'
       when mtr_value_desc = 'MTR_HIDDEN_AMOUNT' then 'Hidden Meter Amount'
       when mtr_value_desc = 'MTR_HIDDEN_MAXIMUM' then 'Hidden Meter Max Amount'
       when mtr_value_desc = 'MTR_HIDDEN_FACTOR' then 'Hidden Meter Factor'
       when mtr_value_desc = 'MTR_BREAK_RATE_FACTOR' then 'Break Rate'
       when mtr_value_desc = 'MTR_BREAK_RATE_THRESHOLD' then 'Break Threshold'
       when mtr_value_desc = 'MTR_START_OUT_FACTOR' then 'Start Out Factor'
       when mtr_value_desc = 'MTR_CURRENT_FRACT_AMT' then 'Meter Current Fraction Amount'
       when mtr_value_desc = 'MTR_OVERFLOW_AMOUNT' then 'Meter Over Flow Amount'
       when mtr_value_desc = 'JKPT_JACKPOT_ID' then 'Level No'
       when mtr_value_desc = 'PRPM_DESC' then 'Payment Method'
       when mtr_value_desc = 'MTR_LAST_JACKPOT_AMOUNT' then 'Last Jackpot Amount'
       when mtr_value_desc = 'MTR_LAST_JACKPOT_TS' then 'Last Jackpot Timestamp'
       END AS InlineAssets_Name,

    CASE
       when mtr_value_desc = 'METER_ID' then 'Meter.Id'
       when mtr_value_desc = 'MTR_DESCRIPTION' then 'Meter.Description' 
       when mtr_value_desc = 'MTR_FLOOR_DESCRIPTION' then 'Floor.Description'
       when mtr_value_desc = 'MTR_CURRENT_AMOUNT' then 'Current.Meter.Amount'     
       when mtr_value_desc = 'MTR_RESET_AMOUNT' then 'Meter.Reset.Amount'
       when mtr_value_desc = 'MTR_HAS_HIDDEN_METER' then 'Has.Hidden.Meter'
       when mtr_value_desc = 'MTR_MACHINE_PAY_AMOUNT' then 'Machine.Pay.Amount'   
       when mtr_value_desc = 'MTR_CURRENT_MAXIMUM' then 'Current.Meter.Max.Amount'
       when mtr_value_desc = 'MTR_CURRENT_FACTOR' then 'Current.Meter.Factor'
       when mtr_value_desc = 'MTR_HIT_TO_HIT_CONTRIBUTN' then 'Meter.Hit.To.Hit.Contribution'
       when mtr_value_desc = 'MTR_HIDDEN_AMOUNT' then 'Hidden.Meter.Amount'
       when mtr_value_desc = 'MTR_HIDDEN_MAXIMUM' then 'Hidden.Meter.Max.Amount'
       when mtr_value_desc = 'MTR_HIDDEN_FACTOR' then 'Hidden.Meter.Factor'
       when mtr_value_desc = 'MTR_BREAK_RATE_FACTOR' then 'Break.Rate'
       when mtr_value_desc = 'MTR_BREAK_RATE_THRESHOLD' then 'Break.Threshold'
       when mtr_value_desc = 'MTR_START_OUT_FACTOR' then 'Start.Out.Factor'
       when mtr_value_desc = 'MTR_CURRENT_FRACT_AMT' then 'Meter.Current.Fraction.Amount'
       when mtr_value_desc = 'MTR_OVERFLOW_AMOUNT' then 'Meter.Over.Flow.Amount'
       when mtr_value_desc = 'JKPT_JACKPOT_ID' then 'Level.No'
       when mtr_value_desc = 'PRPM_DESC' then 'Payment.Method'
       when mtr_value_desc = 'MTR_LAST_JACKPOT_AMOUNT' then 'Last.Jackpot.Amount'
       when mtr_value_desc = 'MTR_LAST_JACKPOT_TS' then 'Last.Jackpot.Timestamp'
       END AS InlineAssets_Code,
      MTR_VALUE AS InlineAssets
FROM (SELECT MTR_ID , m.INSMAP_ID , MTR_NAME , 
m.PRGP_ID , m.JKPT_ID , MP.POOL_NEW_ID,
cast(MTR_NAME as nvarchar) as METER_ID,
cast(MTR_CURRENT_AMOUNT as nvarchar) as MTR_CURRENT_AMOUNT,
cast(ISNULL(MTR_LAST_JACKPOT_AMOUNT, 0) as nvarchar) as MTR_LAST_JACKPOT_AMOUNT,
cast(ISNULL(MTR_LAST_JACKPOT_TS, '1970-01-01 00:00:00') as nvarchar) as MTR_LAST_JACKPOT_TS, 
cast(ISNULL(MTR_HIT_TO_HIT_CONTRIBUTN , 0) as nvarchar) as MTR_HIT_TO_HIT_CONTRIBUTN,
cast(ISNULL(MTR_DESCRIPTION, '') as nvarchar) as MTR_DESCRIPTION, 
cast(ISNULL(MTR_FLOOR_DESCRIPTION, '') as nvarchar) as MTR_FLOOR_DESCRIPTION, 
cast(ISNULL(MTR_HAS_HIDDEN_METER, 'N') as nvarchar) as MTR_HAS_HIDDEN_METER, 
cast(ISNULL(MTR_MACHINE_PAY_AMOUNT, 0) as nvarchar) as MTR_MACHINE_PAY_AMOUNT, 
cast(ISNULL(MTR_CURRENT_MAXIMUM, 0) as nvarchar) as MTR_CURRENT_MAXIMUM, 
cast(ISNULL(MTR_CURRENT_FACTOR, 0.00) as nvarchar) as MTR_CURRENT_FACTOR, 
cast(ISNULL(MTR_HIDDEN_AMOUNT, 0) as nvarchar) as MTR_HIDDEN_AMOUNT, 
cast(ISNULL(MTR_HIDDEN_MAXIMUM, 0) as nvarchar) as MTR_HIDDEN_MAXIMUM, 
cast(ISNULL(MTR_HIDDEN_FACTOR, 0.00) as nvarchar) as MTR_HIDDEN_FACTOR, 
cast(ISNULL(MTR_RESET_AMOUNT, 0) as nvarchar) as MTR_RESET_AMOUNT, 
cast(ISNULL(MTR_BREAK_RATE_FACTOR, 0.00) as nvarchar) as MTR_BREAK_RATE_FACTOR, 
cast(ISNULL(MTR_BREAK_RATE_THRESHOLD, 0) as nvarchar) as MTR_BREAK_RATE_THRESHOLD, 
cast(ISNULL(MTR_START_OUT_FACTOR, 0.00) as nvarchar) as MTR_START_OUT_FACTOR, 
cast(ISNULL(MTR_CURRENT_FRACT_AMT, 0.00) as nvarchar) as MTR_CURRENT_FRACT_AMT, 
cast(ISNULL(MTR_OVERFLOW_AMOUNT, 0) as nvarchar) as MTR_OVERFLOW_AMOUNT,
cast(JKPT_JACKPOT_ID as nvarchar) as JKPT_JACKPOT_ID,
cast(PRPM_DESC as nvarchar) as PRPM_DESC,
ST.SITE_NUMBER as SiteId,
ST.SITE_NUMBER as SiteNumber,
ST.SITE_LONG_NAME as SiteName,
LPROP.PROP_NEW_ID as OrganizationId,
PTY.PROP_LONG_NAME as OrganizationName
FROM PROGRESSIVE.METER as m
join [PROGRESSIVE].[JACKPOT] as j on j.[JKPT_ID] = m.[JKPT_ID]
join [PROGRESSIVE].[PAYMENT_METHOD] as pm on pm.[PRPM_ID] = m.[PRPM_ID]
join progressive.[pool] as p on m.PRGP_ID = p.PRGP_ID
JOIN MIGRATION.PROGRESSIVE_POOL AS MP ON MP.POOL_LEGCY_ID = P.PRGP_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS IMAP ON IMAP.INSM_ID = P.INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = IMAP.INSM_SITE_ID
JOIN GAM.PROPERTY AS PTY ON PTY.PROP_ID = ST.SITE_PROP_ID
join MIGRATION.GAM_PROPERTY as Lprop on Lprop.prop_legcy_id = PTY.PROP_ID

where m.IS_DELETED = 0 ) as st
UNPIVOT
( MTR_VALUE FOR MTR_VALUE_DESC IN ( METER_ID, MTR_CURRENT_AMOUNT, MTR_LAST_JACKPOT_AMOUNT,
MTR_LAST_JACKPOT_TS, MTR_HIT_TO_HIT_CONTRIBUTN, MTR_DESCRIPTION, MTR_FLOOR_DESCRIPTION, 
MTR_HAS_HIDDEN_METER, MTR_MACHINE_PAY_AMOUNT, MTR_CURRENT_MAXIMUM, MTR_CURRENT_FACTOR, 
MTR_HIDDEN_AMOUNT, MTR_HIDDEN_MAXIMUM, MTR_HIDDEN_FACTOR, MTR_RESET_AMOUNT, 
MTR_BREAK_RATE_FACTOR, MTR_BREAK_RATE_THRESHOLD,  MTR_START_OUT_FACTOR, MTR_CURRENT_FRACT_AMT, 
MTR_OVERFLOW_AMOUNT, JKPT_JACKPOT_ID, PRPM_DESC) ) AS UU

GO


--------------------------
--        Pool          --
--------------------------

DROP VIEW IF EXISTS [MIGRATION].[VIEW_POOL]
GO


CREATE VIEW [MIGRATION].[VIEW_POOL]
as
SELECT PRGP_ID, PCON_ID,
11 as Id,
POOL_NEW_ID,
---AssetId----
'11' as AssetId_Id,
'11' as AssetId_AssetTypeDefinitionId,

---Options----
Case when value_desc_prog = 'Pool_Id' then 1
	 when value_desc_prog = 'Pool_Name' then 2
	 when value_desc_prog = 'IsMultipleLevel' then 3
	 when value_desc_prog = 'IsMysteryPool' then 4
	 when value_desc_prog = 'IsWAPPool' then 5 
	 when value_desc_prog = 'MeterCount' then 6 end as Options_Id,

Case when value_desc_prog = 'Pool_Id' then 'Pool_Id'
	 when value_desc_prog = 'Pool_Name' then 'Pool_Name'
	 when value_desc_prog = 'IsMultipleLevel' then 'IsMultipleLevel'
	 when value_desc_prog = 'IsMysteryPool' then 'IsMysteryPool'
	 when value_desc_prog = 'IsWAPPool' then 'IsWAPPool' 
	 when value_desc_prog = 'MeterCount' then 'MeterCount' end as Options_Name,

Case when value_desc_prog = 'Pool_Id' then 'Pool.Id'
	 when value_desc_prog = 'Pool_Name' then 'Pool.Name'
	 when value_desc_prog = 'IsMultipleLevel' then 'Is.Multiple.Level'
	 when value_desc_prog = 'IsMysteryPool' then 'Is.Mystery.Pool'
	 when value_desc_prog = 'IsWAPPool' then 'Is.WAP.Pool' 
	 when value_desc_prog = 'MeterCount' then 'Meter.Count.Code' end as Options_Code,

	 value_prog as Options_Value

--, *
from ( SELECT cast(PRGP_POOL_ID as nvarchar) as Pool_Id,
cast(PRGP_NAME as nvarchar) as Pool_Name,
case when PRGP_IS_MULTIPLE_LVL_ON = 1 then cast('Yes' as nvarchar) else cast('No' as nvarchar) end as IsMultipleLevel,
case when PRGP_IS_MYSTERY_POOL = 1 then cast('Yes' as nvarchar) else cast('No' as nvarchar) end as IsMysteryPool,
case when PRGP_IS_WAP_POOL = 1 then cast('Yes' as nvarchar) else cast('No' as nvarchar) end as IsWAPPool,

cast(METER_COUNT as nvarchar) AS MeterCount,
MP.POOL_NEW_ID,
P.PRGP_ID, P.PCON_ID

FROM PROGRESSIVE.[POOL] AS P 
JOIN MIGRATION.PROGRESSIVE_POOL AS MP ON MP.POOL_LEGCY_ID = P.PRGP_ID
LEFT JOIN (SELECT M.PRGP_ID, COUNT(*) AS METER_COUNT FROM PROGRESSIVE.METER AS M
WHERE IS_DELETED = 0 GROUP BY M.PRGP_ID ) mtr_sum
ON MTR_SUM.PRGP_ID = P.PRGP_ID

WHERE P.IS_DELETED = 0 ) prog_view
unpivot 
(value_prog for value_desc_prog in (Pool_Id, Pool_Name, 
IsMultipleLevel, IsMysteryPool, IsWAPPool, MeterCount) ) as t


GO

--------------------------
--	Game Combo Options  --
--------------------------


DROP VIEW IF EXISTS [MIGRATION].[VIEW_GAME_COMBO_OPTIONS]
GO
CREATE VIEW [MIGRATION].[VIEW_GAME_COMBO_OPTIONS]
AS
SELECT 
GAME_ID as GO_GAME_ID,
case when value_desc = 'GAME_HOLD_PER' then 'Hold Percent' 
	 when value_desc = 'GAME_WAGER' then 'Max Credit Bet' 
	 when value_desc = 'GAME_PAYLINE' then 'Pay Lines' 
	 when value_desc = 'GAME_REELS' then 'Reels' 
	 when value_desc = 'GAME_PAYTABLE_ID' then 'Paytable' end as Options_Code,

case when value_desc = 'GAME_HOLD_PER' then 1
	 when value_desc = 'GAME_WAGER' then 2
	 when value_desc = 'GAME_PAYLINE' then 3
	 when value_desc = 'GAME_REELS' then 4 
	 when value_desc = 'GAME_PAYTABLE_ID' then 5 end as IdIndex,
	Value as Options_Value,
	Value_desc as Options_Code
--* 
from (SELECT GAME_ID, GAME_THEM_ID,
cast(isnull(GAME_WAGER, 0 ) as nvarchar) as GAME_WAGER,
cast(isnull(GAME_PAYLINE, 0) as nvarchar) as GAME_PAYLINE,
cast(isnull(GAME_REELS, 0) as nvarchar) as GAME_REELS,
cast(GAME_HOLD_PER as nvarchar) as GAME_HOLD_PER,
cast(GAME_PAYTABLE_ID as nvarchar) as GAME_PAYTABLE_ID,
cast(GAME_PAY_ID as nvarchar) as GAME_PAY_ID,
cast(isnull(GAME_POSITION, 0 ) as nvarchar) as GAME_POSITION
FROM GAM.GAME_DETAILS AS GM where is_deleted = 0) as a
unpivot
(value for value_desc in (GAME_HOLD_PER, GAME_WAGER, GAME_PAYLINE, GAME_REELS, GAME_PAYTABLE_ID) )as tt

GO
