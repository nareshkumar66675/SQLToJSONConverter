﻿/*
	
	***************************************************
	*												  *
	*    PreRequisite Name - OptionOrderUpdate        *
	*												  *
	***************************************************
   
   Purpose : Update Legacy Database for Option Order

 */



UPDATE fastDefn
SET fastDefn.ASST_OPTN_ORDER = a.OPTN_ORDER
FROM (SELECT fastDefn.[OPTION_CODE], optn.OPTN_CODE,
ASTDFN_OPTN_ORDER,
[ASSET_NAME],
ROW_NUMBER() OVER (PARTITION BY AST.ASST_ID ORDER BY AST.ASST_ID, astDfn.ASTDFN_OPTN_ORDER ) AS OPTN_ORDER
from GAM.ASSET (nolock) AS AST
join GAM.ASSET_DEFINITION (nolock) as astDfn on astdfn.ASTDFN_ASST_ID = AST.ASST_ID
join GAM.[OPTION] (nolock) as optn on optn.[OPTN_ID] = astdfn.ASTDFN_OPTN_ID
join [MIGRATION].[ASSET_TYPE_DEFN] (nolock) as fastDefn on fastDefn.[ASSET_CODE] = upper(AST.asst_name)
and fastDefn.[OPTION_CODE] = optn.OPTN_CODE ) AS a
JOIN [MIGRATION].[ASSET_TYPE_DEFN] (nolock) as fastDefn on fastDefn.[ASSET_NAME] = A.assEt_name
and fastDefn.[OPTION_CODE] = a.OPTN_CODE

GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.DATAMANAGEMENT_ASSET_DATA') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.DATAMANAGEMENT_ASSET_DATA
END
GO

-------------------------------
--- populating historical   ---
-------------------------------
      SELECT
      Id,
	  0 as DataRowVersion,
      ---ASSET ID -----
      AssetId_Id,
      AssetId_AssetTypeDefinitionId,
      ---------SITE----------
      Site_SiteId,
      Site_SiteName,
      Site_SiteNumber,
      Site_OrganizationId,
      Site_OrganizationName,
      --------- OPTIONS ----------
      Options_Id,
      Options_Code,
      Options_Value,
      --------Components --------
      Components_ComponentId,
      Components_ComponentInstanceId,
      Components_ComponentName,
      Components_ComponentKey,
      Components_ComponentValue,
      Components_ComponentCode,
      ------------InlineAssets------------
      InlineAssets_Id,
      InlineAssets_AssetId_AssetTypeDefinitionId,
      InlineAssets_AssetId_Id,
      InlineAssets_Components_ComponentId,
      InlineAssets_Components_ComponentName,
      InlineAssets_Components_ComponentValue,
      InlineAssets_Components_ComponentKey,
      InlineAssets_Components_ComponentInstanceId,
      InlineAssets_Components_ComponentCode,
      InlineAssets_Options_Id,
      InlineAssets_Options_Value,
      InlineAssets_Options_Code,
      --------TypeCode--------
      TypeCode_TypeCodeId,
      TypeCode_TypeCodeName,
      Ast_std_Id, game_id, 
	  Asset_Options_SeqId,
	  Asset_Comp_SeqId, 
	  Inline_Asset_SeqId,
	  Asset_optn_val_seqId,
	  ASD_AM_UID
	  INTO MIGRATION.DATAMANAGEMENT_ASSET_DATA
      FROM (SELECT isnull(gSltMap.ASD_STD_NEW_ID, Ast_Optn.ASD_STD_NEW_ID)  as  Id,
      ---ASSET ID -----
      isnull(gSltMap.ASD_STD_NEW_ID, Ast_Optn.ASD_STD_NEW_ID)  as AssetId_Id,
      10 as AssetId_AssetTypeDefinitionId,
      ---------SITE----------
      isnull(Site_SiteId, SITE_NEW_ID) as Site_SiteId,
      isnull(Site_SiteName, SITE_SHORT_NAME) as Site_SiteName,
      isnull(Site_SiteNumber, SITE_NUMBER) as Site_SiteNumber,
      --st.IS_DELETED as Site_IsDeleted,
      isnull(OrganizationId, Ast_Optn.PROP_NEW_ID) as Site_OrganizationId,
      isnull(OrganizationName, Ast_Optn.PROP_LONG_NAME) as Site_OrganizationName,
      --------- OPTIONS ----------
      Ast_Optn.[OPTION_ID] as Options_Id,
      Ast_Optn.OPTION_CODE as Options_Code,
	  case when Ast_Optn.[OPTION_ID] is null then null else Ast_Optn.AST_OPTN_VALUE end as Options_Value,
      --------Components --------
      ComponentId as Components_ComponentId,
      ComponentInstanceId as Components_ComponentInstanceId,
      ComponentName as Components_ComponentName,
      ComponentKey as Components_ComponentKey,
      ComponentValue as Components_ComponentValue,
      ComponentCode as Components_ComponentCode,
      --ASST_OPTN_ORDER,
      --Seq_Id ,
      ------------InlineAssets------------
      --gSltMap.game_id,
      InlineAssets_Id,
      AssetId_AssetTypeDefinitionId as InlineAssets_AssetId_AssetTypeDefinitionId,
      AssetId_Id as InlineAssets_AssetId_Id,
      InlineAssets_Components_ComponentId,
      InlineAssets_Components_ComponentName,
      InlineAssets_Components_ComponentValue,
      InlineAssets_Components_ComponentKey,
      InlineAssets_Components_ComponentInstanceId,
      InlineAssets_Components_ComponentCode,
      gSltMap.IdIndex as InlineAssets_Options_Id,
      gSltMap.Options_Value as InlineAssets_Options_Value,
      gSltMap.Options_Code as InlineAssets_Options_Code,
      --------TypeCode--------
      isnull(TypeCodeNumber, TypeCode_Id) as TypeCode_TypeCodeId,
      isnull(TypeCodeName, TypeCode_Name) as TypeCode_TypeCodeName,
      isnull(GDM_ASTSTD_OR_TYCD_ID, Ast_Optn.ASD_STD_ID)  as Ast_std_Id,
      gSltMap.game_id,
	  ASST_OPTN_ORDER as Asset_Options_SeqId,
	  AST_COMP.Seq_id as Asset_Comp_SeqId,
	  gSltMap.Ast_Gme_Seq as Inline_Asset_SeqId,
	  Asset_optn_val_seqId, ASD_AM_UID
	   FROM   ( select  ASD_STD_ID, ASD_STD_NEW_ID, [AST_OPTION_ID], [OPTION_ID],[OPTN_NAME],
      [OPTION_NAME], [OPTION_CODE], [ASTDFN_OPTN_ORDER],
   
      CASE WHEN OPTION_CODE in ('ASSET.GMU.CRC.AUTH', 'ASSET.CASLESS.DISAB', 'OPTION.CODE.ENROLMENT.STATUS') THEN 
		(CASE WHEN AST_OPTN_VALUE = 'FLAG.NO' then 'N'
			WHEN AST_OPTN_VALUE = 'FLAG.F' then 'F'
			WHEN AST_OPTN_VALUE = 'FLAG.YES' then 'Y'
			WHEN AST_OPTN_VALUE is null or AST_OPTN_VALUE = '' then 'N' END)
	   WHEN OPTION_CODE = ('BILL.VALIDATOR.CAPACITY') THEN 
		(CASE	WHEN AST_OPTN_VALUE = '' then '100'
			WHEN AST_OPTN_VALUE IS NULL then '100'	
			ELSE AST_OPTN_VALUE END)
	   WHEN OPTION_CODE = 'ASSET.USER.CUSTOM.10' THEN 
		(CASE WHEN PROP_LONG_NAME = ('South Australia') THEN FORMAT(cast(isnull(ASD_NUMBER, '0') as int), 'X') 
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
	      ELSE AST_OPTN_VALUE end) end as AST_OPTN_VALUE,
      SITE_NEW_ID, SITE_NUMBER, SITE_SHORT_NAME,
      PROP_NEW_ID, PROP_LONG_NAME, ASST_OPTN_ORDER,
      TypeCode_Id, TypeCode_Name,
      ROW_NUMBER() over (partition by asd_std_id order by asd_std_id, ASST_OPTN_ORDER) as Asset_optn_val_seqId,
      ASD_AM_UID 
      from (  SELECT ASD.ASD_STD_ID, ASD.ASD_NUMBER, ASD_STD_NEW_ID, [AST_OPTION_ID], [OPTION_ID],[OPTN_NAME],
      fastDefn.[OPTION_NAME], [OPTION_CODE], [ASTDFN_OPTN_ORDER],
	  AST_OPTN_VALUE,
      GST.SITE_NEW_ID, st.SITE_NUMBER, st.SITE_SHORT_NAME,
      gpt.PROP_NEW_ID, pt.PROP_LONG_NAME, ASST_OPTN_ORDER,
      tycod_number as TypeCode_Id, tycod_name as TypeCode_Name, ASD.ASD_AM_UID
      FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD
      JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS (nolock) AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
      JOIN GAM.ASSET (nolock) AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
      JOIN GAM.MANUFACTURER (nolock) AS MNF ON MNF.MANF_ID = ASD_MANF_ID
      JOIN GAM.MODEL (nolock) AS MDL ON MDL.MDL_ID = ASD_MODL_ID
      JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
      JOIN GAM.[SITE] (nolock) AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
      JOIN MIGRATION.GAM_SITE (nolock) AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
      JOIN GAM.PROPERTY (nolock) AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
      JOIN [MIGRATION].[GAM_PROPERTY] (nolock) as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
      left JOIN GAM.ASSET_DETAIL (nolock) AS AD ON  AD.IS_DELETED = 0 and AD.ASD_STD_ID = ASD.ASD_STD_ID
      left join gam.[OPTION] (nolock) as optn on optn.[OPTN_ID] = AST_OPTION_ID
      left join gam.ASSET_DEFINITION (nolock) as astDfn on astdfn.ASTDFN_ASST_ID = AST.ASST_ID
      and optn.[OPTN_ID] = astDfn.[ASTDFN_OPTN_ID]
      left join [MIGRATION].[ASSET_TYPE_DEFN] (nolock) as fastDefn on
      fastDefn.[ASSET_NAME] = AST.asst_name and fastDefn.[OPTION_CODE] = optn.OPTN_CODE
      left join [GAM].[TYPE_CODE_MASTER] (nolock) as tcm on tcm.tycod_id = [ASD_TCOD_ID]
      WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5 AND ASD.ASD_ASST_ID = 1
	  AND MNF.MANF_LONG_NAME NOT IN ('POS') AND MDL.MDL_SHORT_NAME NOT IN ('POS') 
	  union all

	  SELECT ASD.ASD_STD_ID, ASD.ASD_NUMBER, ASD_STD_NEW_ID, [TYCV_OPTN_ID], [OPTION_ID],[OPTN_NAME],
      fastDefn.[OPTION_NAME], [OPTION_CODE], [ASTDFN_OPTN_ORDER],
	  TYCV_OPTN_VALUE,
      GST.SITE_NEW_ID, st.SITE_NUMBER, st.SITE_SHORT_NAME,
      gpt.PROP_NEW_ID, pt.PROP_LONG_NAME, ASST_OPTN_ORDER,
      tycod_number as TypeCode_Id, tycod_name as TypeCode_Name, ASD.ASD_AM_UID

	  FROM GAM.ASSET_STANDARD_DETAILS (nolock) AS ASD
      JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS (nolock) AS GSD ON ASD.ASD_STD_ID = GSD.ASD_STD_LEGACY_ID
      JOIN GAM.ASSET (nolock) AS AST ON AST.ASST_ID = ASD.ASD_ASST_ID
      JOIN GAM.MANUFACTURER (nolock) AS MNF ON MNF.MANF_ID = ASD_MANF_ID
      JOIN GAM.MODEL (nolock) AS MDL ON MDL.MDL_ID = ASD_MODL_ID
      JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS MAP ON MAP.INSM_ID = ASD.ASD_INSMAP_ID
      JOIN GAM.[SITE] (nolock) AS ST ON ST.SITE_ID = MAP.INSM_SITE_ID
      JOIN MIGRATION.GAM_SITE (nolock) AS GST ON GST.[SITE_LEGCY_ID] = ST.SITE_ID
      JOIN GAM.PROPERTY (nolock) AS pt ON pt.PROP_ID = ST.SITE_PROP_ID
      JOIN [MIGRATION].[GAM_PROPERTY] (nolock) as gpt on gpt.[PROP_LEGCY_ID] = pt.PROP_ID
      LEFT JOIN [GAM].[TYPE_CODE_MASTER] (nolock) as tcm on tcm.tycod_id = [ASD_TCOD_ID]
      LEFT JOIN GAM.TYPE_CODE_VALUES  AS TCV ON TCV.TYCV_TYCOD_ID = TYCOD_ID
      left join gam.[OPTION] (nolock) as optn on optn.[OPTN_ID] = TYCV_OPTN_ID
      left join gam.ASSET_DEFINITION (nolock) as astDfn on astdfn.ASTDFN_ASST_ID = AST.ASST_ID
      and optn.[OPTN_ID] = astDfn.[ASTDFN_OPTN_ID]
      left join [MIGRATION].[ASSET_TYPE_DEFN] (nolock) as fastDefn on
      fastDefn.[ASSET_NAME] = AST.asst_name and fastDefn.[OPTION_CODE] = optn.OPTN_CODE

      WHERE ASD.IS_DELETED = 0 AND ASD_CLST_STAT_ID = 5 AND ASD.ASD_ASST_ID = 1
	  AND MNF.MANF_LONG_NAME NOT IN ('POS') AND MDL.MDL_SHORT_NAME NOT IN ('POS') 
	  and OPTION_ID is not null
	    ) as all_tc ) as Ast_Optn

      FULL JOIN MIGRATION.GAM_ASSET_COMP_VALUES (nolock) AS AST_COMP ON AST_OPTN.ASD_STD_ID = AM_LEGACYID and Ast_Optn.Asset_optn_val_seqId = AST_COMP.Seq_id
      FULL JOIN (SELECT * FROM MIGRATION.GAM_GAMES_DETAILS (nolock) WHERE ASD_STD_NEW_ID IS NOT NULL) as gSltMap  on [GDM_ASTSTD_OR_TYCD_ID] = Ast_Optn.ASD_STD_ID
      and Ast_Optn.Asset_optn_val_seqId = gSltMap.Ast_Gme_Seq       ) as overAll
      where 1=1 AND Site_SiteNumber IS NOT NULL AND AssetId_Id IS NOT NULL
      AND Site_SiteNumber in (select * from [Migration].[GetSitesForMigration]())
      order by Ast_std_Id, game_id
GO




IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[MIGRATION].[DATAMANAGEMENT_ASSET_DATA]') AND name = N'INDX_AST_DATA')
DROP INDEX [INDX_AST_DATA] ON [MIGRATION].[DATAMANAGEMENT_ASSET_DATA]
GO
CREATE NONCLUSTERED INDEX [INDX_AST_DATA] ON [MIGRATION].[DATAMANAGEMENT_ASSET_DATA]
(
	[Site_SiteNumber] ASC
)
INCLUDE ( 	[Id],
	[AssetId_Id],
	[AssetId_AssetTypeDefinitionId],
	[Site_SiteId],
	[Site_SiteName],
	[Site_OrganizationId],
	[Site_OrganizationName],
	[Options_Id],
	[Options_Code],
	[Options_Value],
	[Components_ComponentId],
	[Components_ComponentInstanceId],
	[Components_ComponentName],
	[Components_ComponentKey],
	[Components_ComponentValue],
	[Components_ComponentCode],
	[InlineAssets_Id],
	[InlineAssets_AssetId_AssetTypeDefinitionId],
	[InlineAssets_AssetId_Id],
	[InlineAssets_Components_ComponentId],
	[InlineAssets_Components_ComponentName],
	[InlineAssets_Components_ComponentValue],
	[InlineAssets_Components_ComponentKey],
	[InlineAssets_Components_ComponentInstanceId],
	[InlineAssets_Components_ComponentCode],
	[InlineAssets_Options_Id],
	[InlineAssets_Options_Value],
	[InlineAssets_Options_Code],
	[TypeCode_TypeCodeId],
	[TypeCode_TypeCodeName],
	[Asset_Comp_SeqId],
	[Inline_Asset_SeqId],
	[Asset_optn_val_seqId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


GO


CREATE NONCLUSTERED INDEX IDX_DATAMANAGEMENT_ASSET_DATA_Site_SiteNumber_Id_ASD_AM_UID
ON [MIGRATION].[DATAMANAGEMENT_ASSET_DATA] ([Site_SiteNumber],[Id],[ASD_AM_UID])
INCLUDE ([AssetId_AssetTypeDefinitionId],[Site_OrganizationId],[Site_OrganizationName],[Options_Id],[Options_Code],[Options_Value],[Components_ComponentId],[Components_ComponentInstanceId],[Components_ComponentName],[Components_ComponentKey],[Components_ComponentValue],[Components_ComponentCode],[InlineAssets_Id],[InlineAssets_AssetId_AssetTypeDefinitionId],[InlineAssets_AssetId_Id],[InlineAssets_Components_ComponentId],[InlineAssets_Components_ComponentName],[InlineAssets_Components_ComponentValue],[InlineAssets_Components_ComponentKey],[InlineAssets_Components_ComponentInstanceId],[InlineAssets_Components_ComponentCode],[InlineAssets_Options_Id],[InlineAssets_Options_Value],[InlineAssets_Options_Code],[TypeCode_TypeCodeId],[TypeCode_TypeCodeName],[Asset_Comp_SeqId],[Inline_Asset_SeqId],[Asset_optn_val_seqId])
GO


UPDATE GAM.ASSET_DETAIL
SET AST_OPTN_VALUE = 'Bright Lights'
WHERE AST_OPTN_VALUE = '\Bright Lights'

GO



IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'P_Get_Dashboard_Count')
DROP PROCEDURE Migration.P_Get_Dashboard_Count
GO
-- EXEC Migration.P_Get_Dashboard_Count
CREATE PROCEDURE Migration.P_Get_Dashboard_Count
AS
DECLARE @TotalSlots BIGINT
DECLARE @Online BIGINT
DECLARE @Enrolled BIGINT
DECLARE @ProgressiveSlots BIGINT
DECLARE @Connected BIGINT

DECLARE @Manufacturer VARCHAR(500)
DECLARE @Denom VARCHAR(500)
DECLARE @Progressive VARCHAR(500)

	  /*        Total Asset Count           */
	  SELECT
      @TotalSlots = count(distinct Id)
      FROM migration.Datamanagement_asset_data (nolock)

	  /*        Total Online Asset Count           */
	  SELECT
      @Online = count(distinct Id)
      FROM migration.Datamanagement_asset_data (nolock)
	  WHERE Options_Code ='ASSET.MASTER.CONFIGURATION.STATUS' and Options_Value='Online'

	  /*        Total Enrolled Asset Count           */
	  SELECT
      @Enrolled = count(distinct Id)
      FROM migration.Datamanagement_asset_data (nolock)
	  WHERE Options_Code ='OPTION.CODE.ENROLMENT.STATUS' and Options_Value='Y'

	  /*        Total Connected Asset Count           */
	  SELECT
      @Connected = count(distinct MSLOT.[ASD_STD_NEW_ID])
      FROM [PROGRESSIVE].[SLOT_POOL_MAPPING] (nolock) AS PM
      JOIN [PROGRESSIVE].[SLOT] (nolock) AS SLT ON SLT.SLOT_ID = PM.SLOT_ID
      JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS (nolock) AS MSLOT ON MSLOT.ASD_STD_LEGACY_ID = SLT.ASD_STD_ID
      JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ONLNE ON ONLNE.ASD_STD_ID = MSLOT.ASD_STD_LEGACY_ID
      JOIN GAM.ASSET (nolock) AS AST ON AST.ASST_ID = ONLNE.ASD_ASST_ID
      JOIN MIGRATION.PROGRESSIVE_POOL (nolock) AS MPOOL ON MPOOL.[POOL_LEGCY_ID] = PRGP_ID
      JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS ISM ON ISM.INSM_ID = ONLNE.ASD_INSMAP_ID
      JOIN GAM.SITE (nolock) AS ST ON ST.SITE_ID = ISM.INSM_SITE_ID
      WHERE PM.[IS_DELETED] = 0 AND ISNULL(ASST_ANCESTOR_ID, ASST_ID)=1

	  /*        Total 3 Manufacturer Count           */
	  SELECT @Manufacturer =  '[{' +  CASE dat WHEN null THEN null ELSE (CASE LEN(dat) WHEN 0 THEN dat ELSE LEFT(dat, LEN(dat) - 1) END 
      ) END +']' FROM (
	  SELECT STUFF((
      SELECT '{"Key":"' + cast([key] as VARCHAR(MAX))+'","Value":'+cast(Value as VARCHAR(MAX))+'},' 
      FROM (
	  SELECT
      top 3 Components_ComponentValue as [Key],count(distinct Id) as [Value]
      FROM migration.Datamanagement_asset_data (nolock) 
	  WHERE Components_ComponentCode ='MANUFACTURER' 
	  group by Components_ComponentValue
	  order by count(distinct Id) desc )as t
	  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') dat) as gds

	  /*        Total 3 Denom Count           */
	  SELECT @Denom =  '[{' +  CASE dat WHEN null THEN null ELSE (CASE LEN(dat) WHEN 0 THEN dat ELSE LEFT(dat, LEN(dat) - 1) END 
      ) END +']'  FROM (
	  SELECT STUFF((
      SELECT '{"Key":"' + cast([key] as VARCHAR(MAX))+'","Value":'+cast(Value as VARCHAR(MAX))+'},' 
      FROM (
	  SELECT
      top 3 Components_ComponentValue as [key],count(distinct Id) as Value
      FROM migration.Datamanagement_asset_data (nolock)
	  WHERE Components_ComponentCode ='ASSET.DENOMINATION' 
	  group by Components_ComponentValue
	  order by count(distinct Id) desc) as t
	  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') dat) as gds

	  /*        Total 3 Progressive Count           */
	  SELECT @Progressive = '[{' +  CASE dat WHEN null THEN null ELSE (CASE LEN(dat) WHEN 0 THEN dat ELSE LEFT(dat, LEN(dat) - 1) END 
      ) END +']' FROM (
	  SELECT STUFF((
      SELECT '{"Key":"' + cast(PRGP_POOL_ID as VARCHAR(MAX))+'","Value":'+cast(cnt as VARCHAR(MAX))+'},' 
      FROM (
	  SELECT top 3 POOL_NEW_ID, pl.PRGP_POOL_ID ,count(distinct MSLOT.[ASD_STD_NEW_ID]) as cnt
      FROM [PROGRESSIVE].[SLOT_POOL_MAPPING] (nolock) AS PM
      JOIN [PROGRESSIVE].[SLOT] (nolock) AS SLT ON SLT.SLOT_ID = PM.SLOT_ID
      JOIN MIGRATION.GAM_ASSET_STANDARD_DETAILS (nolock) AS MSLOT ON MSLOT.ASD_STD_LEGACY_ID = SLT.ASD_STD_ID
      JOIN GAM.ASSET_STANDARD_DETAILS (nolock) AS ONLNE ON ONLNE.ASD_STD_ID = MSLOT.ASD_STD_LEGACY_ID
      JOIN GAM.ASSET (nolock) AS AST ON AST.ASST_ID = ONLNE.ASD_ASST_ID
      JOIN MIGRATION.PROGRESSIVE_POOL (nolock) AS MPOOL ON MPOOL.[POOL_LEGCY_ID] = PRGP_ID
      JOIN GAM.INSTALLED_SYSTEM_MAP (nolock) AS ISM ON ISM.INSM_ID = ONLNE.ASD_INSMAP_ID
      JOIN GAM.SITE (nolock) AS ST ON ST.SITE_ID = ISM.INSM_SITE_ID
	  JOIN PROGRESSIVE.POOL (nolock) AS pl ON pl.PRGP_ID = PM.PRGP_ID
      WHERE PM.[IS_DELETED] = 0 AND ISNULL(ASST_ANCESTOR_ID, ASST_ID)=1
	  group by POOL_NEW_ID, PRGP_POOL_ID	  
      ORDER BY count(distinct MSLOT.[ASD_STD_NEW_ID]) desc
	  ) as t
	  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') dat) as gds


	  select  @TotalSlots as TotalSlot,
	          @Online as [Online], 
			  @Enrolled as [Enrolled],
			  @Connected  as Connected,
			  @Manufacturer as Manufacturer,
			  @Denom as Denom,
			  @Progressive as Progressive

GO