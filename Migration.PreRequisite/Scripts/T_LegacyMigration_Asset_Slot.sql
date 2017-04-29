/*
	
	***************************************************
	*												  *
	*    PreRequisite Name - LegacyAssetSlotTables    *
	*												  *
	***************************************************
   
   Purpose : To Populating New Ids for Active Slot records

 */


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Migration')
EXEC ('CREATE SCHEMA MIGRATION;');
GO


 ------Drop Tables ----

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.PROGRESSIVE_POOL') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.PROGRESSIVE_POOL
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.PROGRESSIVE_METER') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.PROGRESSIVE_METER
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_STANDARD_DETAILS') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_STANDARD_DETAILS
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.ASSET_TYPE_DEFN') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.ASSET_TYPE_DEFN
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_COMP_VALUES') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_COMP_VALUES
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAME_DETAIL_COMPONENTS') AND type in (N'U'))
BEGIN
DROP TABLE MIGRATION.GAME_DETAIL_COMPONENTS
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_GAMES_DETAILS') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_GAMES_DETAILS
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.DATAMANAGEMENT_ASSET_DATA') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.DATAMANAGEMENT_ASSET_DATA
END
GO



-------------- DDL Index ----------------





------------ DDL Create & Insert Data ---------------------


-- MIGRATION.PROGRESSIVE_POOL
-- MIGRATION.PROGRESSIVE_METER
--- PROGRESSIVE POOL
CREATE TABLE MIGRATION.PROGRESSIVE_POOL
(
POOL_LEGCY_ID BIGINT,
POOL_NEW_ID BIGINT
)

INSERT INTO MIGRATION.PROGRESSIVE_POOL
SELECT PRGP_ID, ROW_NUMBER() OVER(ORDER BY PRGP_ID) AS RW_NUM
-- select *
FROM PROGRESSIVE.[POOL] AS P
WHERE IS_DELETED = 0 ORDER BY PRGP_ID

--- PROGRESSIVE METER
CREATE TABLE MIGRATION.PROGRESSIVE_METER
(
MTR_LEGCY_ID BIGINT,
MTR_NEW_ID BIGINT
)

INSERT INTO MIGRATION.PROGRESSIVE_METER
SELECT MTR_ID, ROW_NUMBER() OVER(ORDER BY MTR_ID) AS RW_NUM
-- SELECT *
FROM PROGRESSIVE.METER AS MTR
WHERE IS_DELETED = 0 ORDER BY MTR_ID



CREATE TABLE MIGRATION.GAM_ASSET_STANDARD_DETAILS (
ASD_STD_LEGACY_ID BIGINT, 
ASD_STD_NEW_ID INT
)
GO

--Step 1: --> retriving max pool count

DECLARE @P_AST_ID BIGINT;
SELECT @P_AST_ID = MAX(POOL_NEW_ID) FROM MIGRATION.PROGRESSIVE_POOL

--Step 2: --> adding max pool count + slot running number
INSERT INTO MIGRATION.GAM_ASSET_STANDARD_DETAILS
SELECT ASD_STD_ID, @P_AST_ID + ROW_NUMBER() OVER(ORDER BY ASD_AM_UID) AS RW_NUM  FROM GAM.ASSET_STANDARD_DETAILS AS ASD 
WHERE IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5 and ASD_AM_UID is not null  ORDER BY ASD.ASD_AM_UID 

GO


--select * from MIGRATION.GAM_TYPE_DESCRIPTION

-- Asset to Type Description
UPDATE ASTMAP
SET ASTMAP.TYPEDESCP_ID = TYP.Id
--SELECT *
FROM MIGRATION.GAM_TYPE_DESCRIPTION AS TYP
JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS ASTMAP ON ASTMAP.TYPEDESCRIPTION = TYP.TYPEDESCRIPTION
AND ASTMAP.Manufacturer = typ.Manufacturer
and ASTMAP.Model = typ.Model
and astmap.modelType = typ.modelType
and astmap.GameHoldPC = typ.GameHoldPC
and astmap.HoldPC = typ.HoldPC
and astmap.MaxBet = typ.MaxBet
and astmap.LineConfiguration = typ.LineConfiguration
and astmap.GameCategory = typ.GameCategory
left join [MIGRATION].[GAM_ASSET_STANDARD_DETAILS] on [ASD_STD_LEGACY_ID] = ASD_STD_ID
GO

CREATE TABLE MIGRATION.ASSET_TYPE_DEFN
(
ID INT,
ASST_ID INT,
ASSET_NAME NVARCHAR(128),
ASSET_CODE NVARCHAR(128),
ASSET_DISPLAY_NAME NVARCHAR(128),
OPTION_ID INT,
OPTION_NAME NVARCHAR(128),
OPTION_CODE NVARCHAR(128),
ASST_OPTN_ORDER INT
)
GO

--- Asset Comp Values
CREATE TABLE MIGRATION.GAM_ASSET_COMP_VALUES
(
AM_LegacyId bigint,
Id int,
AM_Asset_UID bigint,
AssetNumber nvarchar(32),
Location nvarchar(64),
SerialNumber nvarchar(64),
SiteId int,
SiteNumber bigint,
SiteName nvarchar(128),
OrgId int,
OrgName nvarchar(128),
ModelName nvarchar(128),
Seq_Id int,
ComponentId nvarchar(128),
ComponentName nvarchar(128),
ComponentValue nvarchar(256),
ComponentKey nvarchar(128),
ComponentInstanceId nvarchar(128),
ComponentCode nvarchar(128)
)
GO


DROP INDEX IF EXISTS [GAM_ASSET_COMP_VALUES_INDX] ON [MIGRATION].[GAM_ASSET_COMP_VALUES]
GO

CREATE NONCLUSTERED INDEX [GAM_ASSET_COMP_VALUES_INDX]
ON [MIGRATION].[GAM_ASSET_COMP_VALUES] ([AM_LegacyId],[Seq_Id])
INCLUDE ([ComponentId],[ComponentName],[ComponentValue],[ComponentKey],[ComponentInstanceId],[ComponentCode])
GO

--
DELETE FROM MIGRATION.GAM_ASSET_COMP_VALUES 
GO

SELECT GETDATE() AS START_dAT_TIME
-------------------
-- Area
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---sequenceId----
1 as Seq_Id,
-- Area --
cast('22007'as nvarchar)  as ComponentId,
cast('Area' as nvarchar) as ComponentName,
cast(ar.AR_LONG_NAME as nvarchar)  as ComponentValue,
cast(ST.site_number as nvarchar) +'_'+ cast(ar_new_id as nvarchar)+'_22007' as ComponentKey,
--cast('110_2_22007' as nvarchar)  as ComponentKey, 
cast('AREA' as nvarchar) as ComponentInstanceId,
cast('AREA'as nvarchar)  as ComponentCode
FROM GAM.ASSET_STANDARD_DETAILS AS ASD
join MIGRATION.GAM_ASSET_STANDARD_DETAILS as gsd on asd.ASD_STD_ID = gsd.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
JOIN [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
LEFT JOIN GAM.AREA AS AR ON AR.IS_DELETED = 0 AND AR.AREA_ID = ASD.ASD_AREA_ID
left join migration.gam_area as gar on gar.[AREA_LEGCY_ID] = ASD.ASD_AREA_ID

WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
Order by gsd.ASD_STD_NEW_ID
GO
-------------------
--Zone
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
2 as Seq_Id,
-- Zone --
cast('22008' as nvarchar) as ComponentId,
cast('Zone' as nvarchar) as ComponentName,
cast(zn.zn_LONG_NAME as nvarchar) as ComponentValue,
--cast('110_2_22008' as nvarchar) as ComponentKey,
cast(ST.site_number as nvarchar) +'_'+ cast(zn_new_id as nvarchar)+'_22008' as ComponentKey,
cast('ZONE' as nvarchar)  as ComponentInstanceId,
cast('ZONE' as nvarchar)  as ComponentCode
FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
LEFT JOIN GAM.ZONE AS ZN ON ZN.IS_DELETED = 0 AND ZN.ZONE_ID = ASD.ASD_ZONE_ID
left join migration.gam_zone as gzn on gzn.[ZONE_LEGCY_ID] = ASD.ASD_ZONE_ID
left join migration.GAM_AREA as gar on gar.[AREA_LEGCY_ID] = ASD.ASD_AREA_ID
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO
-------------------
-- Bank
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
3 as Seq_Id,
-- Bank --
cast('22009' as nvarchar) as ComponentId,
cast('Bank' as nvarchar) as ComponentName,
cast(bk.bk_LONG_NAME as nvarchar) as ComponentValue,
--cast('110_2_22009' as nvarchar) as ComponentKey,
cast(ST.site_number as nvarchar) +'_'+ cast(BK_new_id as nvarchar)+'_22009' as ComponentKey,
cast('BANK' as nvarchar) as ComponentInstanceId,
cast('BANK' as nvarchar)  as ComponentCode
FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
LEFT JOIN GAM.BANK AS BK ON bk.IS_DELETED = 0 AND BK.BANK_ID = ASD.ASD_BANK_ID
left join migration.gam_bank as gbk on gbk.[BANK_LEGCY_ID] = ASD.ASD_BANK_ID
left join migration.GAM_AREA as gar on gar.[AREA_LEGCY_ID] = ASD.ASD_AREA_ID
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS')
GO
-------------------
--Manufacturer
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
4 as Seq_Id,
-- Manufacturer --
cast('22002'as nvarchar)  as ComponentId,
cast('Manufacturer' as nvarchar) as ComponentName,
cast(MNF.MANF_LONG_NAME as nvarchar)  as ComponentValue,
--'0_'+ cast(mf_new_id as nvarchar)+'_22002' as ComponentKey,
'0_'+ cast(Manufacturer_Id as nvarchar)+'_22002' as ComponentKey,
cast('MANUFACTURER' as nvarchar) as ComponentInstanceId,
cast('MANUFACTURER' as nvarchar)  as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
JOIN [MIGRATION].[GAM_PROPERTY] AS GPT ON GPT.[PROP_LEGCY_ID] = PT.PROP_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
LEFT JOIN GAM.MANUFACTURER AS MNF ON MNF.MANF_ID = ASD.ASD_MANF_ID
LEFT JOIN [MIGRATION].[GAM_MANUFACTURER] AS GMNF ON MNF.MANF_ID = GMNF.MNF_LEGCY_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS GTC ON GTC.ASD_STD_ID = ASD.ASD_STD_ID 
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS tc on tc.Id = gtc.typedescp_id 
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MNF.IS_DELETED = 0
AND MANF_LONG_NAME NOT IN ('POS')
GO


-------------------
--Model Type
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
5 as Seq_Id,
--Model Type--
'22003' as ComponentId,
cast('Model Type' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
--cast('0_2_22003' as nvarchar) as ComponentKey,
'0_'+ cast(ModelType_Id as nvarchar)+'_22003' as ComponentKey,
'MODELTYPE' as ComponentInstanceId,
'MODEL.TYPE' as ComponentCode
FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 126 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN [GAM].MODEL_TYPE AS MTYP ON  MTYP.IS_DELETED = 0 AND  MDLTYP_LONG_NAME = AST_OPTN_VALUE
left join [MIGRATION].[GAM_MODEL_TYPE] as gmty on gmty.MDLTYPE_LEGCY_ID = [MDLTYP_ID]
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS GTC ON GTC.ASD_STD_ID = ASD.ASD_STD_ID 
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS tc on tc.Id = gtc.typedescp_id 
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS')
GO

-------------------
--Model
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
6 as Seq_Id,
--Model--
'22005' as ComponentId,
cast('Model' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
'0_'+CAST(Model_Id AS NVARCHAR)+'_22005' as ComponentKey,
--cast('0_2_22005' as nvarchar) as ComponentKey,
'MODEL' as ComponentInstanceId,
'MODEL' as ComponentCode 

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
JOIN GAM.ASSET_DETAIL AS AD ON AD.IS_DELETED = 0 AND  ad.[AST_OPTION_ID] = 108 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN [GAM].MODEL AS MDL ON MDL.IS_DELETED = 0 AND [MDL_LONG_NAME] = AST_OPTN_VALUE
LEFT JOIN MIGRATION.GAM_MODEL AS GDML ON MDL.MDL_ID = GDML.MDL_LEGCY_ID --MDL_NEW_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS GTC ON GTC.ASD_STD_ID = ASD.ASD_STD_ID 
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS tc on tc.Id = gtc.typedescp_id 
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO

-------------------
-- Denomination
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
7 as Seq_Id,

--Denomination--
'22011' as ComponentId,
cast('Denomination' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
'0_'+cast(Components_Id as nvarchar)+'_1' as ComponentKey,
'ASSETDENOMINATION' as ComponentInstanceId,
'ASSET.DENOMINATION' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 202 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_DENOMINATION AS GD ON GD.DENM_AMOUNT = AST_OPTN_VALUE
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO

-------------------
--GMU Denomination
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
8 as Seq_Id,

--GMU Denom--
'22011' as ComponentId,
cast('GMU Denom' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
--cast('0_1_1' as nvarchar) as ComponentKey,
'0_'+cast(Components_Id as nvarchar)+'_1' as ComponentKey,
'ASSETGMUDENOM' as ComponentInstanceId,
'ASSET.GMU.DENOM' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 203 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_DENOMINATION AS GD ON GD.DENM_AMOUNT = AST_OPTN_VALUE
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO

-------------------
--Fill Denomination
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
9 as Seq_Id,

--Fill Denom--
'22011' as ComponentId,
cast('Fill Denom' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
--cast('0_1_1' as nvarchar) as ComponentKey,
'0_'+cast(components_id as nvarchar)+'_1' as ComponentKey,
'ASSETFILLDENOM' as ComponentInstanceId,
'ASSET.FILL.DENOM' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 204 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_DENOMINATION AS GDM ON GDM.DENM_AMOUNT = AD.AST_OPTN_VALUE
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO

-------------------
--Type Description
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
10 as Seq_Id,

-- Type Description ---
'22068' as ComponentId,
cast('Type Description' as nvarchar) as ComponentName,
cast(upper(ad.AST_OPTN_VALUE) as nvarchar)  as ComponentValue,
--cast('0_5_22069' as nvarchar) as ComponentKey,
'0_'+ cast(TypeDescription_Id as nvarchar)+'_22068' as ComponentKey,
'ASSETTYPEDESCRIPTION' as ComponentInstanceId,
'ASSET.TYPE.DESCRIPTION' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 210 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS TYAST ON TYAST.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS TDSC ON TDSC.ID = TYAST.TYPEDESCP_ID
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO

-------------------
----Hold Percentage
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
11 as Seq_Id,

--Hold Percentage--
'22063' as ComponentId,
cast('Hold Percentage' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
'0_'+cast(HoldPC_Id as nvarchar) +'_22063' as ComponentKey,
'ASSETHOLDPERCENTAGE' as ComponentInstanceId,
'ASSET.HOLD.PERCENTAGE' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 206 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS GTC ON GTC.ASD_STD_ID = ASD.ASD_STD_ID 
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS tc on tc.Id = gtc.typedescp_id 
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO

----------------------
--Game Hold Percentage
----------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
12 as Seq_Id,

--Game Hold Percentage--
'22064' as ComponentId,
cast('Game Hold Percentage' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
'0_'+cast(GameHoldPC_Id as nvarchar) +'_22064' as ComponentKey,
'ASSETGAMEHOLDPERCENT' as ComponentInstanceId,
'ASSET.GAME.HOLD.PERCENT' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 207 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS GTC ON GTC.ASD_STD_ID = ASD.ASD_STD_ID 
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS tc on tc.Id = gtc.typedescp_id 
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO

-------------------
--Max Bet
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
13 as Seq_Id,

--Max Bet--
'22065' as ComponentId,
cast('Max Bet' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
'0_'+cast(MaxBet_Id as nvarchar) +'_22065' as ComponentKey,
'ASSETUSERCUSTOM1' as ComponentInstanceId,
'ASSET.USER.CUSTOM.1' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 244 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS GTC ON GTC.ASD_STD_ID = ASD.ASD_STD_ID 
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS tc on tc.Id = gtc.typedescp_id 
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS') 
GO

---------------------
--Line Configuration
---------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
14 as Seq_Id,

--Line Configuration--
'22066' as ComponentId,
cast('Line Configuration' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
'0_'+cast(LineConfiguration_Id as nvarchar) +'_22066' as ComponentKey,
'ASSETUSERCUSTOM3' as ComponentInstanceId,
'ASSET.USER.CUSTOM.3' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 246 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS GTC ON GTC.ASD_STD_ID = ASD.ASD_STD_ID 
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS tc on tc.Id = gtc.typedescp_id 
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS')
GO

-------------------
--Game Category
-------------------
INSERT INTO MIGRATION.GAM_ASSET_COMP_VALUES 
SELECT asd.ASD_STD_ID as AM_LegacyId, gsd.ASD_STD_NEW_ID as Id, asd.asd_am_uid,
asd.asd_number as AssetNumber, asd.asd_location as Location, asd.ASD_SERIAL_NUM as SerialNumber, 
gst.SITE_NEW_ID as SiteId, gst.site_number as SiteNumber, st.SITE_LONG_NAME as SiteName,
gpt.PROP_NEW_ID as OrgId, pt.PROP_LONG_NAME as OrgName, mdl.Mdl_long_name as ModelName,
---SequenceId----
15 as Seq_Id,

--Game Category--
'22067' as ComponentId,
cast('Game Category' as nvarchar) as ComponentName,
cast(ad.AST_OPTN_VALUE as nvarchar)  as ComponentValue,
'0_'+cast(GameCategory_Id as nvarchar) +'_22067' as ComponentKey,
'ASSETUSERCUSTOM4' as ComponentInstanceId,
'ASSET.USER.CUSTOM.4' as ComponentCode

FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
JOIN GAM.MODEL AS MDL ON MDL.MDL_ID = ASD_MODL_ID
JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
LEFT JOIN GAM.ASSET_DETAIL AS AD ON  AD.IS_DELETED = 0 AND ad.[AST_OPTION_ID] = 247 and AD.ASD_STD_ID = ASD.ASD_STD_ID
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET AS GTC ON GTC.ASD_STD_ID = ASD.ASD_STD_ID 
LEFT JOIN MIGRATION.GAM_TYPE_DESCRIPTION AS tc on tc.Id = gtc.typedescp_id 
WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5
AND AST.ASST_ID in ( 1 ) AND MANF_LONG_NAME NOT IN ('POS')
GO

SELECT GETDATE() AS END_DATE_TIME
GO


------------------------------
--	Game Combo Options  --
------------------------------


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
	Value_desc 
--* 
from (SELECT GAME_ID, GAME_THEM_ID,
cast(isnull(GAME_WAGER, 0 ) as nvarchar) as GAME_WAGER,
cast(isnull(GAME_PAYLINE, 0) as nvarchar) as GAME_PAYLINE,
cast(isnull(GAME_REELS, 0) as nvarchar) as GAME_REELS,
cast(GAME_HOLD_PER as nvarchar) as GAME_HOLD_PER,
cast(GAME_PAYTABLE_ID as nvarchar) as GAME_PAYTABLE_ID,
cast(GAME_PAY_ID as nvarchar) as GAME_PAY_ID,
cast(isnull(GAME_POSITION, 0 ) as nvarchar) as GAME_POSITION
FROM GAM.GAME_DETAILS AS GM ) as a
unpivot
(value for value_desc in (GAME_HOLD_PER, GAME_WAGER, GAME_PAYLINE, GAME_REELS, GAME_PAYTABLE_ID) )as tt

GO

SELECT GETDATE() AS END_dAT_TIME

------------------------------------
--game combo details population
------------------------------------


--DROP TABLE MIGRATION.GAM_GAMES_DETAILS
GO

-- GAME DETAILS - COMPONENT DATA

SELECT * 
INTO MIGRATION.GAME_DETAIL_COMPONENTS
FROM ( SELECT GM.GAME_ID, 1 as Seq,
22011 as InlineAssets_Components_ComponentId,
'Denom' as InlineAssets_Components_ComponentName,
gdm.DENM_AMOUNT as InlineAssets_Components_ComponentValue,
'0_'+cast(gdm.Components_Id as nvarchar)+'_1' as InlineAssets_Components_ComponentKey,
'Inline260DENOMINATION' as InlineAssets_Components_ComponentInstanceId,
'DENOMINATION' as InlineAssets_Components_ComponentCode,
 row_number() over (order by GAME_ID) Row_Num,
 6 as Htry_Indx,
 GM.IS_DELETED as Game_Deleted
--, *
FROM GAM.GAME_DETAILS AS GM
JOIN GAM.DENOMINATION AS D ON D.DENM_ID = GAME_DENOM
JOIN MIGRATION.GAM_DENOMINATION as gdm on gdm.DENM_ID = D.DENM_ID

Union All

-- theme type
SELECT GM.GAME_ID, 2 as Seq,
22057 as ComponentId,
'Theme Type' as ComponentName,
tt.TTYP_LONG_NAME as ComponentValue,
'0_'+ CAST(GTD.ThemeType_Id as nvarchar) +'_22057' as ComponentKey,
'Inline260THEMETYPE' as ComponentInstanceId,
'THEME.TYPE' as ComponentCode,
 row_number() over (order by GAME_ID) Row_Num,
 7 as Htry_Indx,
 GM.IS_DELETED as Game_Deleted
FROM GAM.GAME_DETAILS AS GM
JOIN GAM.THEME AS TH ON TH.THEM_ID = GM.GAME_THEM_ID
LEFT JOIN MIGRATION.GAM_THEME AS GTH ON GTH.TME_LEGCY_ID = TH.THEM_ID
JOIN GAM.THEME_TYPE AS TT ON TT.TTYP_ID = TH.TTYP_ID
JOIN GAM.THEME_CATEGORY AS TC ON TC.TCAT_ID = TH.THEME_CAT_ID
JOIN GAM.THEME_GROUP AS TG ON TG.TGRP_ID = TC.TCAT_TGRP_ID
JOIN GAM.MANUFACTURER AS MNF ON MNF.MANF_ID = TH.MANF_ID
LEFT JOIN MIGRATION.GAM_MANUFACTURER AS GMF ON GMF.MNF_LEGCY_ID = MNF.MANF_ID 
LEFT JOIN MIGRATION.GAM_THEME_DETAILS AS GTD ON gtd.TTYP_ID = TT.TTYP_ID AND GTD.THEM_ID = TH.THEM_ID
--WHERE GM.IS_DELETED = 0

union all
-- theme group
SELECT GM.GAME_ID, 3 as Seq,
22058 as ComponentId,
'Theme Group' as ComponentName,
TG.TGRP_LONG_NAME as ComponentValue,
'0_'+ CAST(GTD.ThemeGroup_Id as nvarchar) +'_22058' as ComponentKey,
'Inline260THEMEGROUP' as ComponentInstanceId,
'THEME.GROUP' as ComponentCode,
 row_number() over (order by GAME_ID) Row_Num,
 8 as Htry_Indx,
 GM.IS_DELETED as Game_Deleted
FROM GAM.GAME_DETAILS AS GM
JOIN GAM.THEME AS TH ON TH.THEM_ID = GM.GAME_THEM_ID
LEFT JOIN MIGRATION.GAM_THEME AS GTH ON GTH.TME_LEGCY_ID = TH.THEM_ID
JOIN GAM.THEME_CATEGORY AS TC ON TC.TCAT_ID = TH.THEME_CAT_ID
JOIN GAM.THEME_GROUP AS TG ON TG.TGRP_ID = TC.TCAT_TGRP_ID
JOIN GAM.MANUFACTURER AS MNF ON MNF.MANF_ID = TH.MANF_ID
LEFT JOIN MIGRATION.GAM_MANUFACTURER AS GMF ON GMF.MNF_LEGCY_ID = MNF.MANF_ID 
LEFT JOIN MIGRATION.GAM_THEME_DETAILS AS GTD ON gtd.TGRP_ID = TG.TGRP_ID AND GTD.THEM_ID = TH.THEM_ID
--where GM.IS_DELETED = 0

union all
-- theme category
SELECT GM.GAME_ID, 4 as Seq,
22059 as ComponentId,
'Theme Category' as ComponentName,
TC.TCAT_LONG_NAME as ComponentValue,
'0_'+ CAST(GTD.ThemeCategory_Id as nvarchar) +'_22059' as ComponentKey,
'Inline260THEMECATEGORY' as ComponentInstanceId,
'THEME.CATEGORY' as ComponentCode,
 row_number() over (order by GAME_ID) Row_Num,
 9 as Htry_Indx,
 GM.IS_DELETED as Game_Deleted
FROM GAM.GAME_DETAILS AS GM
JOIN GAM.THEME AS TH ON TH.THEM_ID = GM.GAME_THEM_ID
LEFT JOIN MIGRATION.GAM_THEME AS GTH ON GTH.TME_LEGCY_ID = TH.THEM_ID
JOIN GAM.THEME_CATEGORY AS TC ON TC.TCAT_ID = TH.THEME_CAT_ID
JOIN GAM.MANUFACTURER AS MNF ON MNF.MANF_ID = TH.MANF_ID
LEFT JOIN MIGRATION.GAM_MANUFACTURER AS GMF ON GMF.MNF_LEGCY_ID = MNF.MANF_ID 
LEFT JOIN MIGRATION.GAM_THEME_DETAILS AS GTD ON gtd.TCAT_ID = TC.TCAT_ID AND GTD.THEM_ID = TH.THEM_ID
--where GM.IS_DELETED = 0

union all
--Manufacturer
SELECT GM.GAME_ID, 5 as Seq,
22002 as ComponentId,
'Manufacturer' as ComponentName,
MNF.MANF_LONG_NAME as ComponentValue,
'0_'+ CAST(GTD.Manfacture_Id as nvarchar) +'_22002' as ComponentKey,
'Inline260MANUFACTURER' as ComponentInstanceId,
'MANUFACTURER' as ComponentCode,
 row_number() over (order by GAME_ID) Row_Num,
 10 as Htry_Indx,
 GM.IS_DELETED as Game_Deleted
FROM GAM.GAME_DETAILS AS GM
JOIN GAM.THEME AS TH ON TH.THEM_ID = GM.GAME_THEM_ID
LEFT JOIN MIGRATION.GAM_THEME AS GTH ON GTH.TME_LEGCY_ID = TH.THEM_ID
JOIN GAM.MANUFACTURER AS MNF ON MNF.MANF_ID = TH.MANF_ID
LEFT JOIN MIGRATION.GAM_MANUFACTURER AS GMF ON GMF.MNF_LEGCY_ID = MNF.MANF_ID 
LEFT JOIN MIGRATION.GAM_THEME_DETAILS AS GTD ON gtd.MANF_ID = MNF.MANF_ID AND GTD.THEM_ID = TH.THEM_ID

--WHERE GM.IS_DELETED = 0

UNION ALL
--Theme
SELECT GM.GAME_ID, 6 as Seq,
22060 as ComponentId,
'Theme Attributes' as ComponentName,
TH.THEM_NAME as ComponentValue,
'0_'+ CAST(Theme_Id as nvarchar) +'_22060' as ComponentKey,
'Inline260THEME' as ComponentInstanceId,
'THEME' as ComponentCode,
 row_number() over (order by GAME_ID) Row_Num,
 11 as Htry_Indx,
 GM.IS_DELETED as Game_Deleted
FROM GAM.GAME_DETAILS AS GM
JOIN GAM.THEME AS TH ON TH.THEM_ID = GM.GAME_THEM_ID
LEFT JOIN MIGRATION.GAM_THEME AS GTH ON GTH.TME_LEGCY_ID = TH.THEM_ID
JOIN GAM.MANUFACTURER AS MNF ON MNF.MANF_ID = TH.MANF_ID
LEFT JOIN MIGRATION.GAM_MANUFACTURER AS GMF ON GMF.MNF_LEGCY_ID = MNF.MANF_ID 
LEFT JOIN MIGRATION.GAM_THEME_DETAILS AS GTD ON gtd.THEM_ID = TH.THEM_ID AND GTD.THEM_ID = TH.THEM_ID
--where GM.IS_DELETED = 0
) as gam_Comp 


--DROP TABLE MIGRATION.GAM_GAMES_DETAILS
GO


SELECT ROW_NUMBER()OVER (partition by [GDM_ASTSTD_OR_TYCD_ID] Order by [GDM_ASTSTD_OR_TYCD_ID], mainT.game_id, mainT.seq) as Ast_Gme_Seq,
* 
INTO MIGRATION.GAM_GAMES_DETAILS
FROM (SELECT AST_GAME_IDX as InlineAssets_Id,
260 as AssetId_AssetTypeDefinitionId,
AST_GAME_IDX as AssetId_Id,
ROW_NUMBER() OVER (partition by GMP.[GDM_ASTSTD_OR_TYCD_ID], gam_Comp.game_id Order by GMP.[GDM_ASTSTD_OR_TYCD_ID], gam_Comp.game_id, gam_Comp.seq) as Rw_Nm,
SITE_NEW_ID as Site_SiteId,
SITE_LONG_NAME as Site_SiteName,
st.SITE_NUMBER as Site_SiteNumber,
PROP_NEW_ID as OrganizationId,
PROP_LONG_NAME as OrganizationName,
TYCOD_NAME as TypeCodeName,
TYCOD_NUMBER as TypeCodeNumber,
GDM_ASTSTD_OR_TYCD_ID,
gam_Comp.*,
GOPTN.*,
GSD.* FROM MIGRATION.GAME_DETAIL_COMPONENTS as gam_Comp 
LEFT JOIN (SELECT ROW_NUMBER()OVER ( ORDER BY [GDM_ASTSTD_OR_TYCD_ID],GDM_GAME_ID) AS AST_GAME_IDX, *
 FROM GAM.GAME_DETAILS_MAPPING WHERE IS_DELETED = 0) AS GMP ON GMP.[GDM_GAME_ID]= GAM_COMP.GAME_ID 
LEFT JOIN GAM.ASSET_STANDARD_DETAILS as asd on asd.asd_std_id = [GDM_ASTSTD_OR_TYCD_ID]
LEFT JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON GSD.ASD_STD_LEGACY_ID = [GDM_ASTSTD_OR_TYCD_ID] 
LEFT JOIN GAM.MANUFACTURER AS MF ON MF.MANF_ID = ASD_MANF_ID
LEFT JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
LEFT JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
LEFT JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
LEFT JOIN GAM.PROPERTY AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
LEFT join [MIGRATION].[GAM_PROPERTY] as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
LEFT JOIN GAM.TYPE_CODE_MASTER AS TCM ON TCM.TYCOD_ID = ASD_TCOD_ID
LEFT JOIN MIGRATION.VIEW_GAME_COMBO_OPTIONS AS GOPTN 
ON GOPTN.GO_GAME_ID = GAM_COMP.GAME_ID AND GOPTN.IDINDEX = GAM_COMP.SEQ 
--order by GMP.[GDM_ASTSTD_OR_TYCD_ID], gam_Comp.game_id, gam_Comp.seq
WHERE asd.is_deleted = 0 and GMP.IS_DELETED = 0 AND ASD.ASD_CLST_STAT_ID = 5
AND gam_Comp.Game_Deleted = 0
AND MANF_LONG_NAME NOT IN ('POS') ) as mainT
--where ASD_STD_NEW_ID = 14507
ORDER BY mainT.[GDM_ASTSTD_OR_TYCD_ID], mainT.game_id, mainT.Rw_Nm
GO


--------------------------
--	Asset Count Summary  --
--------------------------

DROP VIEW IF EXISTS MIGRATION.VIEW_ASST_SUMMARY
GO

CREATE VIEW MIGRATION.VIEW_ASST_SUMMARY
AS
SELECT PT.PROP_LONG_NAME, ST.SITE_NUMBER, ST.SITE_LONG_NAME, AST.ASST_NAME,
COUNT(ASD.ASD_STD_ID) AS ASSET_COUNT FROM GAM.ASSET_STANDARD_DETAILS AS ASD
JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
JOIN GAM.ASSET AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
JOIN GAM.INSTALLED_SYSTEM_MAP AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
JOIN GAM.[SITE] AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
JOIN MIGRATION.GAM_SITE AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
JOIN GAM.PROPERTY AS PT ON PT.PROP_ID = ST.SITE_PROP_ID
JOIN [MIGRATION].[GAM_PROPERTY] AS GPT ON GPT.[PROP_LEGCY_ID] = PT.PROP_ID
WHERE ASD.IS_DELETED = 0 AND ASD.ASD_CLST_STAT_ID = 5
GROUP BY PT.PROP_LONG_NAME, ST.SITE_NUMBER, ST.SITE_LONG_NAME, AST.ASST_NAME

GO

DROP INDEX IF EXISTS [GAM_GAMES_DETAILS_INDX] ON [MIGRATION].[GAM_GAMES_DETAILS]
GO

CREATE NONCLUSTERED INDEX [GAM_GAMES_DETAILS_INDX]
ON [MIGRATION].[GAM_GAMES_DETAILS] ([GAME_ID],[Seq])
INCLUDE ([InlineAssets_Id],[AssetId_AssetTypeDefinitionId],[AssetId_Id],[InlineAssets_Components_ComponentId],[InlineAssets_Components_ComponentName],[InlineAssets_Components_ComponentValue],[InlineAssets_Components_ComponentKey],[InlineAssets_Components_ComponentInstanceId],[InlineAssets_Components_ComponentCode],[Options_Code],[IdIndex],[Options_Value])

GO