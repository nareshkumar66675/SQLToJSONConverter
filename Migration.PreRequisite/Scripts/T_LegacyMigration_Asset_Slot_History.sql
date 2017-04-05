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
	[CLST_DET_ID] bigint
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
	[CLST_OLD_DATA_ID] [bigint] NULL,
	[CLST_UNIQUE_ID] [nvarchar](32) NULL,
	[CLST_INSMAP_ID] [bigint] NULL
) ON [PRIMARY]

GO