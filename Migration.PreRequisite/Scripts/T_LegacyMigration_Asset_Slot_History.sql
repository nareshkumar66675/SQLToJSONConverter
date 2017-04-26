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


------------ DDL Create & Insert Data ---------------------



CREATE TABLE [MIGRATION].[GAM_ASSET_SLOT_HISTORY_SUMMARY](
	[CLST_NAME] [nvarchar](128) NOT NULL,
	[CLST_ID] BIGINT,
	[Current_Id] [bigint] NULL,
	[Pre_Id] [bigint] NULL,
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
	[ApprovedBy_LastName] [nvarchar](30) NULL
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
SELECT * 
INTO MIGRATION.GAM_HISTORY_GAMES
FROM (
select distinct Game_id, InlineAssets_Components_ComponentName as GmOptionName, ''as Code, Seq, InlineAssets_Components_ComponentValue as GmOptionValue  
from [MIGRATION].[GAM_GAMES_DETAILS]
--where game_id = 1099000005473
union all
select distinct go_game_id, options_code, '' as Code, IdIndex+6, Options_Value from [MIGRATION].[GAM_GAMES_DETAILS]
--where go_game_id = 1099000005473
) as tgm
where game_id is not null
-- and game_id = 1099000005473
order by game_id, seq



