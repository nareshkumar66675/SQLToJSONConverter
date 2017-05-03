/*
	
	*********************************************************
	*														*
	*  PreRequisite Name - LegacyAssetHistoryDataPopulation *
	*														*
	*********************************************************
   
   Purpose : To Populating data for historical data migration

 */


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Migration')
EXEC ('CREATE SCHEMA MIGRATION;');
GO


 ------Drop Tables ----

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_SLOT_HISTORY_SUMMARY') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_SLOT_HISTORY_SUMMARY
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_SLOT_HISTORY_OPTIONS') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_SLOT_HISTORY_OPTIONS
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_SLOT_HISTORY_PROGRESSIVE') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_SLOT_HISTORY_PROGRESSIVE
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_SLOT_HISTORY_GAMES') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_SLOT_HISTORY_GAMES
END
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_HISTORY_GAMES') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_HISTORY_GAMES
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_CHANGELIST_ASSET_DETAIL') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_CHANGELIST_ASSET_DETAIL
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_SLOT_OPTIONS_VALUE') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_SLOT_OPTIONS_VALUE
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_ASSET_GAMES_OPTIONS_VALUE') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_ASSET_GAMES_OPTIONS_VALUE
END
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_HISTORY_SLOT_GAMES_MAPPING') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_HISTORY_SLOT_GAMES_MAPPING
END
GO

 



------------ DDL Create & Insert Data ---------------------



CREATE TABLE [MIGRATION].[GAM_ASSET_SLOT_HISTORY_SUMMARY](
	[CLST_NAME] [nvarchar](128) NOT NULL,
	[CLST_ID] BIGINT,
	[Current_Id] [bigint] NULL,
	[Pre_Id] [bigint] NULL,
	[Asst_Histry_Id] bigint null,
	[ASD_NUMBER] [varchar](16) NULL,
	[ASD_AM_UID] [bigint] NULL,
	[ASD_DELETED] bit,
	[CLST_STAT_DESCRIPTION] [nvarchar](64) NULL,
	[ACTION] [nvarchar](64) NULL,
	[SOURCE_SITE] [nvarchar](64) NULL,
	[DEST_SITE] [nvarchar](64) NULL,
	[CLST_SCHEDULED_DATE] [datetime] NULL,
	[CLST_EXECTUED_DATE] [datetime] NULL,
	[CLSA_CODE] [nvarchar](64) NULL,
	[ASSET_TYPE] [nvarchar](64) NULL,
	[ASTL_DATA_SOURCE] [nvarchar](64) NULL,
	[CREATED_USER] [nvarchar](32) NOT NULL,
	[CLST_AUTH_USER] [nvarchar](32) NULL,
	[CLST_AUTH_USER_SECOND] [nvarchar](32) NULL,
	[CLST_DET_ID] bigint,
	[Site_OrganizationId] bigint,
	[Site_OrganizationName] [nvarchar](64) NULL,
	[SiteId] bigint,
	[SiteNumber] bigint,	
	[CreatedBy_UserId] [nvarchar](32) NULL,
	[CreatedBy_LoginName] [nvarchar](30) NULL,
	[CreatedBy_FirstName] [nvarchar](30) NULL,
	[CreatedBy_MiddleName] [nvarchar](30) NULL,
	[CreatedBy_LastName] [nvarchar](30) NULL,
	[ApprovedBy_UserId] [nvarchar](32) NULL,
	[ApprovedBy_LoginName] [nvarchar](30) NULL,
	[ApprovedBy_FirstName] [nvarchar](30) NULL,
	[ApprovedBy_MiddleName] [nvarchar](30) NULL,
	[ApprovedBy_LastName] [nvarchar](30) NULL,
	[Asset_Is_Latest] bit
) ON [PRIMARY]

GO

CREATE TABLE [MIGRATION].[GAM_ASSET_SLOT_HISTORY_OPTIONS](
	[CHANGELIST_NAME] [nvarchar](128) NOT NULL,
	[CHANGELIST_ID] [bigint] NOT NULL,
	[CLST_ASD_ID] [bigint] NOT NULL,
	[ASD_AM_UID] [bigint] NULL,
	[ASD_NUMBER] [varchar](16) NULL,
	[ASD_LOCATION] [varchar](32) NULL,
	[OLD_ASD_NUMBER] [varchar](16) NULL,
	[OLD_ASD_LOCATION] [varchar](32) NULL,
	[ACTION] [nvarchar](64) NOT NULL,
	[OPTN_CODE] [nvarchar](64) NOT NULL,
	[OPTN_NAME] [nvarchar](64) NOT NULL,
	[CURRENT_VALUE] [nvarchar](256) NULL,
	[OLD_VALUE] [nvarchar](256) NULL,
	[OPTION_ORDER] [int] NOT NULL,
	[IS_UPDATED] [bit] NULL,
	[CUR_ASD_STD_ID] [bigint] NOT NULL,
	[PRE_ASD_STD_ID] [bigint] NULL,
	[ASTL_DATA_SOURCE] [nvarchar](64) NULL,
	[EXECUTED_DATETIME] [datetime] NULL
) ON [PRIMARY]

GO


CREATE TABLE [MIGRATION].[GAM_ASSET_SLOT_HISTORY_PROGRESSIVE](
	[CLST_ID] [bigint] NOT NULL,
	[Changelist_Name] [nvarchar](128) NOT NULL,
	[CLST_DET_ID] [bigint] NOT NULL,
	[ASD_AM_UID] [bigint] NULL,
	[ACTION] [nvarchar](64) NULL,
	[PoolId_Old] bigint null,
	[PoolId_Current] bigint null,
	[PoolName_Old] [nvarchar](256) NULL,
	[PoolName_Current] [nvarchar](256) NULL,
	[CLST_UNIQUE_ID] [nvarchar](32) NULL,
	[CLST_INSMAP_ID] [bigint] NOT NULL,
	[CLST_EXECTUED_DATE] [datetime] NULL
) ON [PRIMARY]

GO



CREATE TABLE [MIGRATION].[GAM_ASSET_SLOT_HISTORY_GAMES](
	[CLST_ID] [bigint] NULL,
	[Changelist_Name] [nvarchar](128) NULL,
	[CLST_DET_ID] [bigint] NULL,
	[ASD_AM_UID] [bigint] NULL,
	[ACTION] [nvarchar](64) NULL,
	[Current_GameComboName] [nvarchar](256) NULL,
	[Current_Game_Id] [bigint] NULL,
	[Old_GameComboName] [nvarchar](256) NULL,
	[Old_Game_Id] [bigint] NULL,
	[ASD_STD_ID] [bigint] NULL,
	[CLST_OLD_DATA_ID] [bigint] NULL,
	[CLST_UNIQUE_ID] [nvarchar](32) NULL,
	[CLST_INSMAP_ID] [bigint] NULL,
	Game_Unq_Id bigint null,
	Game_Unq_Id_Old bigint null
) ON [PRIMARY]

GO


CREATE TABLE [MIGRATION].[GAM_HISTORY_SLOT_GAMES_MAPPING](
	[Idx] [bigint] NULL,
	[GM_ASD_STD_ID] [bigint] NOT NULL,
	[Game_Id] [bigint] NULL,
	[ASD_AM_UID] [bigint] NULL,
	[gmOptionName] [varchar](16) NULL,
	[Code] [varchar](32) NOT NULL,
	[Seq] [int] NULL,
	[GmOptionValue] [nvarchar](128) NULL,
	[Comp_Id] [varchar](16) NULL,
	Game_AssetId bigint
) ON [PRIMARY]

GO

CREATE TABLE MIGRATION.GAM_ASSET_SLOT_OPTIONS_VALUE (
P_ASD_ID bigint,
P_ASD_OPTN_VALUE nvarchar(max) 
)
GO


CREATE TABLE MIGRATION.GAM_ASSET_GAMES_OPTIONS_VALUE (
P_GM_ID bigint,
P_GM_VALUE nvarchar(max) 
)
GO

 

--DROP INDEX IDX_RN ON MIGRATION.GAM_CHANGELIST_ASSET_DETAIL;
GO



SELECT * INTO MIGRATION.GAM_CHANGELIST_ASSET_DETAIL
from ( SELECT  ROW_NUMBER() OVER (ORDER BY CLST_EXECTUED_DATE, [ASD_AM_UID]) AS RN,  *  
FROM (SELECT C.CLST_ID, CAD.[CLST_DET_ID], ASD.ASD_STD_ID, C.CLST_EXECTUED_DATE, [ASD_AM_UID] 
FROM [GAM].[CHANGELIST_ASSET_DETAIL] as cad
join [GAM].[CHANGE_LIST] as c on c.clst_id = cad.clst_id
join [GAM].[ASSET_STANDARD_DETAILS] as asd on asd.asd_std_id = cad.asd_std_id
WHERE C.[CLST_ASSET_TYPE] = 1 AND ASD.[ASD_CLST_STAT_ID] = 5 ) AS TT ) asmst
ORDER BY RN
GO


-- IDX_RN
--CREATE INDEX IDX_RN ON MIGRATION.GAM_CHANGELIST_ASSET_DETAIL  (RN);
GO


--------------------------
-- Games
--------------------------
SELECT Game_id, GmOptionName,
CASE WHEN GmOptionName ='Denom' THEN 'DENOMINATION' 
     WHEN GmOptionName ='Theme Type' THEN 'THEME.TYPE' 
     WHEN GmOptionName ='Theme Group' THEN 'THEME.GROUP' 
     WHEN GmOptionName ='Theme Category' THEN 'THEME.CATEGORY' 
     WHEN GmOptionName ='Manufacturer' THEN 'MANUFACTURER'
     WHEN GmOptionName ='Theme Attributes' THEN 'THEME' 
     ELSE GmOptionName end as Code,
     
     Seq as Id, GmOptionValue,

     CASE WHEN GmOptionName ='Denom' THEN '22011' 
     WHEN GmOptionName ='Theme Type' THEN '22057' 
     WHEN GmOptionName ='Theme Group' THEN '22058' 
     WHEN GmOptionName ='Theme Category' THEN '22059' 
     WHEN GmOptionName ='Manufacturer' THEN '22002'
     WHEN GmOptionName ='Theme Attributes' THEN '22060' 
     WHEN GmOptionName ='Hold Percent' THEN '0'
     WHEN GmOptionName ='Max Credit Bet' THEN '0'
     WHEN GmOptionName ='Pay Lines' THEN '0'
     WHEN GmOptionName ='Reels' THEN '0'
     WHEN GmOptionName ='Paytable' THEN '0' end as Comp_Id
INTO MIGRATION.GAM_HISTORY_GAMES
FROM (
SELECT DISTINCT Game_id, InlineAssets_Components_ComponentName as GmOptionName,  Seq, InlineAssets_Components_ComponentValue as GmOptionValue  
FROM [MIGRATION].[GAM_GAMES_DETAILS]
--where game_id = 1099000005473
UNION ALL
SELECT DISTINCT go_game_id, options_code, IdIndex+6, Options_Value from [MIGRATION].[GAM_GAMES_DETAILS]
--where go_game_id = 1099000005473
) AS TGM
WHERE GAME_ID IS NOT NULL
-- and game_id = 1099000005473
ORDER BY GAME_ID, SEQ


----GAME VALUES JSON FORMAT
INSERT INTO MIGRATION.GAM_ASSET_GAMES_OPTIONS_VALUE
SELECT GAME_ID AS P_GM_ID, '{ "Hold Percent" :"' + game_hold_per + '", ' +
'"Max Credit Bet" : "'+ isnull(cast(game_wager as nvarchar), '')  + '", ' +
'"Pay Lines": "'+ isnull(cast(game_payline as nvarchar), '') + '", ' +
'"Reels": "'+ isnull(cast(game_reels as nvarchar), '') + '", ' +
'"Paytable": "'+ isnull(game_paytable_id, '') + '", ' +
'"DENOMINATION": "'+ cast(gdm.denm_amount as nvarchar) +'", ' +
'"THEME.GROUP": "'+ TGRP_LONG_NAME + '", '+
'"THEME CATEGORY": "'+ tcat_long_name + '", ' +
'"MANUFACTURER": "'+ manf_long_name + '", ' +
'"THEME": "' + them_name + '", '+
'"THEME.TYPE": "' + ttyp_long_name+'" }' as P_GM_VALUE
FROM GAM.GAME_DETAILS AS GM
JOIN GAM.THEME AS TH ON TH.THEM_ID = GM.GAME_THEM_ID
JOIN GAM.THEME_TYPE AS TT ON TT.TTYP_ID = TH.TTYP_ID
JOIN GAM.THEME_CATEGORY AS TC ON TC.TCAT_ID = TH.THEME_CAT_ID
JOIN GAM.THEME_GROUP AS TG ON TG.TGRP_ID = TC.TCAT_TGRP_ID
JOIN GAM.MANUFACTURER AS MNF ON MNF.MANF_ID = TH.MANF_ID
JOIN GAM.DENOMINATION AS D ON D.DENM_ID = GAME_DENOM
JOIN MIGRATION.GAM_DENOMINATION as gdm on gdm.DENM_ID = D.DENM_ID
GO


