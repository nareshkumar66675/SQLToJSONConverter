
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Migration')
EXEC sys.sp_executesql N'CREATE SCHEMA [Migration]'

GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Migration].[Report]') AND type in (N'U'))
BEGIN
DROP Table [Migration].[Report]
END

GO

CREATE TABLE [Migration].[Report](
	[Migration_ID] [int] IDENTITY(1,1) NOT NULL,
	[Component_Name] [nvarchar](100) NULL,
	[SiteGroupID] [int] NULL,
	[Tot_Rcrds_InLegacy] [bigint] NULL,
	[Tot_Unique_RcrdsInLegacy] [bigint] NULL,
	[Inserted_Rcrds_InNew] [bigint] NULL,
	[Start_Time] [datetime] NULL,
	[End_Time] [datetime] NULL,
	[Status] [nvarchar](50) NULL,
 CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED 
(
	[Migration_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Migration].[SiteGroup]') AND type in (N'U'))
BEGIN
DROP TABLE [Migration].[SiteGroup]
END

GO

CREATE TABLE [Migration].[SiteGroup](
	[SiteGroupID] [int] NOT NULL,
	[SiteID] [int] NULL,
	[SiteName] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO