/*
	
	***************************************************
	*												  *
	*		PreRequisite Name - HistoryPrePopulate	  *
	*												  *
	***************************************************
   
   Purpose : Populate temporary data for history

 */

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_HISTORY_ASSET_DATA') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_HISTORY_ASSET_DATA
END
GO

SELECT  
      ------ Id -------
      Asst_Histry_Id as Id,
      tt.[Action] as [Action],
      clst_name as MasterListName,
      clst_name as ChangeListName,
      case 
          when clst_scheduled_date is not null then 'SCHEDULED' 
          when tt.astl_data_source in ('IMPORT_DATA', 'CHANGELIST_DATA', 'CHANGELIST_VC_DATA'  ) then 'IMMEDIATE'
          when tt.astl_data_source in ('RECOVERY_AM', 'RECOVERY_INSITE'  ) then 'RECOVERY'
          when clst_name like 'Data Sync%' then 'SYNCH'
          when clst_name like 'Batch%' then 'IMMEDIATE'
      else 'IMMEDIATE' end as DataTriggerSource,
      ------- CreatedBy-------
      0 as CreatedBy_UserId,
      tt.created_user as CreatedBy_LoginName,
      tt.created_user as CreatedBy_FirstName,
      tt.created_user as CreatedBy_MiddleName,
      tt.created_user as CreatedBy_LastName,
      --------ApprovedBy--------
      0 as ApprovedBy_UserId,
      tt.CLST_AUTH_USER as ApprovedBy_LoginName,
      tt.CLST_AUTH_USER as ApprovedBy_FirstName,
      tt.CLST_AUTH_USER as ApprovedBy_MiddleName,
      tt.CLST_AUTH_USER as ApprovedBy_LastName,

      cast(tt.clst_exectued_date as Varchar(50)) as ExecutedAt,
      -----Asset----
      10 as Asset_AssetTypeDefinitionId,
      asset_type as Asset_AssetType,
      tt.ASD_AM_UID as Asset_Id,

      ----Site---
      tt.SiteId as Site_SiteId,
      SITE_SHORT_NAME as Site_SiteName,
      tt.SiteNumber as Site_SiteNumber,
      tt.Site_OrganizationId as Site_OrganizationId,
      tt.Site_OrganizationName as Site_OrganizationName,
      ----- OPTIONS --------
      isnull(P_ASD_OPTN_VALUE, '{{}}') as Options,
      --OPTN.IS_UPDATED,

      -----ChangedOptions----
      CASE WHEN tt.IS_UPDATED = 1 THEN OPTION_ORDER ELSE NULL END AS ChangedOptions_Id,
      CASE WHEN tt.IS_UPDATED = 1 THEN tt.OPTN_NAME ELSE NULL END AS ChangedOptions_Name,
      CASE WHEN tt.IS_UPDATED = 1 THEN tt.OLD_VALUE ELSE NULL END AS ChangedOptions_Value_OldValue,
      CASE WHEN tt.IS_UPDATED = 1 THEN tt.CURRENT_VALUE ELSE NULL END AS ChangedOptions_Value_NewValue,
      CASE WHEN tt.IS_UPDATED = 1 THEN tt.OPTN_CODE ELSE NULL END AS ChangedOptions_Code,

      -----------InlineAssets-------
      CASE WHEN C_G.Seq is null and O_G.Seq is null THEN NULL  ELSE C_G.Game_AssetId  END as InlineAssets_Id,
      ------ Asset ------
      CASE WHEN C_G.Seq is null and O_G.Seq is null THEN NULL  ELSE 260 END AS  InlineAssets_Assets_AssetTypeDefinitionId,
      CASE WHEN C_G.Seq is null and O_G.Seq is null THEN NULL  ELSE 'Game' END as InlineAssets_Assets_AssetType,
      CASE WHEN C_G.Seq is null and O_G.Seq is null THEN NULL  ELSE C_G.Game_AssetId  END as InlineAssets_Assets_Id,
      -------Options------
      P_GM_VALUE AS InlineAssets_Options,

      -----Games Changed Options---
      C_G.game_id as cg,
      o_G.game_id as og,
      isnull(C_G.GmOptionValue,'no_data') as GmOptionValue_Current ,
      isnull(O_G.GmOptionValue,'no_data') as GmOptionValue_old,

      CASE WHEN isnull(C_G.GmOptionValue,'no_data') = isnull(O_G.GmOptionValue,'no_data')
      THEN NULL ELSE isnull(C_G.Seq, O_G.Seq) END AS InlineAssets_ChangedOptions_Id,

      CASE WHEN isnull(C_G.GmOptionValue,'no_data') = isnull(O_G.GmOptionValue,'no_data')
      THEN NULL ELSE isnull(C_G.GmOptionName, O_G.GmOptionName) END AS InlineAssets_ChangedOptions_Name,

      CASE WHEN isnull(C_G.GmOptionValue,'no_data') = isnull(O_G.GmOptionValue,'no_data')
      THEN NULL ELSE isnull(O_G.GmOptionValue, '') END AS InlineAssets_ChangedOptions_Value_OldValue,

      CASE WHEN isnull(C_G.GmOptionValue,'no_data') = isnull(O_G.GmOptionValue,'no_data')
      THEN NULL ELSE isnull(C_G.GmOptionValue, '') END AS InlineAssets_ChangedOptions_Value_NewValue,

      CASE WHEN isnull(C_G.Code,'no_data') = isnull(O_G.Code,'no_data')
      THEN NULL ELSE isnull(C_G.Code, O_G.Code)  END AS InlineAssets_ChangedOptions_Code,

      ----LinkedAssets--Progressive---
      ---- i.ActiveLinks
      case when [PoolName_Current] is null then null else 11 end as LinkedAssets_ActiveLinks_AssetTypeDefinitionId,
      case when [PoolName_Current] is null then null else 'Progressive Pool' end as LinkedAssets_ActiveLinks_AssetType,
      case when [PoolName_Current] is null then null else 0 end as LinkedAssets_ActiveLinks_Id,
      case when [PoolName_Current] is null then null else 'Pool Id' end as LinkedAssets_ActiveLinks_DisplayName,
      case when [PoolName_Current] is null then null else [PoolName_Current] end as LinkedAssets_ActiveLinks_DisplayValue,
      --- ii.ChangedLinkes
      -----Linked
      case when [PoolName_Current] is null then null else 11 end as LinkedAssets_ChangedLinkes_Linked_AssetTypeDefinitionId,
      case when [PoolName_Current] is null then null else 'Progressive Pool' end as LinkedAssets_ChangedLinkes_Linked_AssetType,
      case when [PoolName_Current] is null then null else 0 end as LinkedAssets_ChangedLinkes_Linked_Id,
      case when [PoolName_Current] is null then null else 'Pool Id' end as LinkedAssets_ChangedLinkes_Linked_DisplayName,
      case when [PoolName_Current] is null then null else [PoolName_Current] end as LinkedAssets_ChangedLinkes_Linked_DisplayValue,
      -----DeLinked
      case when [PoolName_Old] is null then null else 11 end as LinkedAssets_ChangedLinkes_DeLinked_AssetTypeDefinitionId,
      case when [PoolName_Old] is null then null else 'Progressive Pool' end as LinkedAssets_ChangedLinkes_DeLinked_AssetType,
      case when [PoolName_Old] is null then null else 0 end as LinkedAssets_ChangedLinkes_DeLinked_Id,
      case when [PoolName_Old] is null then null else 'Pool Id' end as LinkedAssets_ChangedLinkes_DeLinked_DisplayName,
      case when [PoolName_Old] is null then null else PoolName_Old  end as LinkedAssets_ChangedLinkes_DeLinked_DisplayValue,

      case when ASD_DELETED = 0 then 1 else 0 end as IsLastest,
      tt.CLST_EXECTUED_DATE, tt.CURRENT_ID, C_G.Game_AssetId, OPTION_ORDER,
      case 
          when tt.[Action] = 'ADD' then 1
          when tt.IS_UPDATED = 1 then 1
          when isnull(C_G.GmOptionValue,'no_data') <> isnull(O_G.GmOptionValue,'no_data') then 1
          when isnull([PoolName_Current],'no_data') <> isnull([PoolName_Old],'no_data') then 1
      else 0 end as all_Updated

      INTO MIGRATION.GAM_HISTORY_ASSET_DATA
      FROM (  select  * from MIGRATION.GAM_CHK_ASSET_SLOT_HISTORY_SUMMARY (nolock)  AS SMY --WHERE SMY.ASD_NUMBER = '180'
      Left JOIN (select row_number() over(partition by changelist_id, clst_asd_id, asd_am_uid 
                                                order by changelist_id, clst_asd_id, asd_am_uid, OPTION_ORDER) as optn_seq,
                --1 as optn_seq,
                GH_OPTN_ID , CHANGELIST_NAME , CHANGELIST_ID , CLST_ASD_ID , ASD_AM_UID as ASSET_UNQ_ID , ASD_NUMBER as Asset_Number, 
                ASD_LOCATION , OLD_ASD_NUMBER , OLD_ASD_LOCATION , OPTN_CODE , OPTN_NAME , CURRENT_VALUE , 
                OLD_VALUE , OPTION_ORDER , IS_UPDATED , CUR_ASD_STD_ID , PRE_ASD_STD_ID , EXECUTED_DATETIME 
                from  MIGRATION.GAM_CHK_ASSET_SLOT_HISTORY_OPTIONS (nolock) ) AS OPTN ON OPTN.CLST_ASD_ID = SMY.CLST_DET_ID
      Left JOIN MIGRATION.GAM_CHK_ASSET_SLOT_OPTIONS_VALUE (nolock) AS OTP_VAL ON P_ASD_ID = smy.CURRENT_ID ) as tt
                  LEFT JOIN [MIGRATION].[UM_SITE_INFO] AS UM ON UM.SITE_NUMBER = tt.SiteNumber
      full outer JOIN MIGRATION.GAM_CHK_HISTORY_SLOT_GAMES_MAPPING (nolock) AS C_G ON cur_asd_std_id = C_G.gm_asd_std_id and c_g.seq = tt.optn_seq 
      FULL OUTER JOIN MIGRATION.GAM_CHK_HISTORY_SLOT_GAMES_MAPPING (nolock) AS O_G ON tt.Pre_Id = O_G.gm_asd_std_id 
                     and C_G.GmOptionName = O_G.GmOptionName and O_G.game_id = C_G.game_id and C_G.seq = O_G.seq
      LEFT JOIN MIGRATION.GAM_ASSET_GAMES_OPTIONS_VALUE (nolock) AS GM ON GM.P_GM_ID = C_G.Game_Id
      LEFT JOIN MIGRATION.GAM_CHK_ASSET_SLOT_HISTORY_PROGRESSIVE (nolock) AS PROG ON PROG.CLST_DET_ID = tt.CLST_DET_ID
      WHERE 1=1  and Asst_Histry_Id is not null
      ORDER BY tt.CLST_EXECTUED_DATE, tt.CURRENT_ID, C_G.Game_AssetId, OPTION_ORDER
GO


CREATE NONCLUSTERED INDEX IDX_GAM_HISTORY_ASSET_DATA_SITE_SITENUMBER
ON [MIGRATION].[GAM_HISTORY_ASSET_DATA] ([Site_SiteNumber])
INCLUDE ([Id],[Action],[MasterListName],[ChangeListName],[DataTriggerSource],[CreatedBy_UserId],[CreatedBy_LoginName],[CreatedBy_FirstName],[CreatedBy_MiddleName],[CreatedBy_LastName],[ApprovedBy_UserId],[ApprovedBy_LoginName],[ApprovedBy_FirstName],[ApprovedBy_MiddleName],[ApprovedBy_LastName],[ExecutedAt],[Asset_AssetTypeDefinitionId],[Asset_AssetType],[Asset_Id],[Site_SiteId],[Site_SiteName],[Site_OrganizationId],[Site_OrganizationName],[Options],[ChangedOptions_Id],[ChangedOptions_Name],[ChangedOptions_Value_OldValue],[ChangedOptions_Value_NewValue],[ChangedOptions_Code],[InlineAssets_Id],[InlineAssets_Assets_AssetTypeDefinitionId],[InlineAssets_Assets_AssetType],[InlineAssets_Assets_Id],[InlineAssets_Options],[cg],[og],[GmOptionValue_Current],[GmOptionValue_old],[InlineAssets_ChangedOptions_Id],[InlineAssets_ChangedOptions_Name],[InlineAssets_ChangedOptions_Value_OldValue],[InlineAssets_ChangedOptions_Value_NewValue],[InlineAssets_ChangedOptions_Code],[LinkedAssets_ActiveLinks_AssetTypeDefinitionId],[LinkedAssets_ActiveLinks_AssetType],[LinkedAssets_ActiveLinks_Id],[LinkedAssets_ActiveLinks_DisplayName],[LinkedAssets_ActiveLinks_DisplayValue],[LinkedAssets_ChangedLinkes_Linked_AssetTypeDefinitionId],[LinkedAssets_ChangedLinkes_Linked_AssetType],[LinkedAssets_ChangedLinkes_Linked_Id],[LinkedAssets_ChangedLinkes_Linked_DisplayName],[LinkedAssets_ChangedLinkes_Linked_DisplayValue],[LinkedAssets_ChangedLinkes_DeLinked_AssetTypeDefinitionId],[LinkedAssets_ChangedLinkes_DeLinked_AssetType],[LinkedAssets_ChangedLinkes_DeLinked_Id],[LinkedAssets_ChangedLinkes_DeLinked_DisplayName],[LinkedAssets_ChangedLinkes_DeLinked_DisplayValue],[IsLastest],[CLST_EXECTUED_DATE],[CURRENT_ID],[Game_AssetId],[OPTION_ORDER])
GO

