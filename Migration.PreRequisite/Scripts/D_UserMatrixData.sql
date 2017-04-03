﻿SELECT 'UPDATE MIGRATION.GAM_PROPERTY SET PROP_PARENT_CODE = '''
+ Prop_Short_Name + ''', PROP_TYPE = '''
+ ORG_TYPE_CODE  + ''', PROP_DEPTH_LEVEL = '
+ CAST(Depth_Level AS NVARCHAR) + ' WHERE PROP_SHORT_NAME = '''+Prop_Short_Name+''';'
as stat 
 FROM ( SELECT ORG.ORG_CODE as Prop_Short_Name,
ORG.[ORG_SHORT_NAME] as Prop_Long_Name,
ORG.[ORG_LONG_NAME] as Prop_Description,
p_org.ORG_CODE as Parent_Code,
case when ORG.ORG_PARENT_ID is null then 'True'
       else 'False' end as IsRoot,
case when ORG.ORG_PARENT_ID is null then 1
       when ORG.ORG_PARENT_ID = 1 then 2
       when ORG.ORG_PARENT_ID > 1 then 3 end as Depth_Level,
ORGTYPE.[ORG_TYPE_CODE]
FROM [UM].[ORGANIZATION] AS ORG
LEFT JOIN [UM].[ORGANIZATION_TYPE] AS ORGTYPE ON ORGTYPE.ORG_TYPE_ID = ORG.ORG_TYPE_ID
left join [UM].[ORGANIZATION] AS p_org on p_org.ORG_ID = ORG.ORG_PARENT_ID
WHERE ORG.ORG_DELETED_TS IS NULL AND ORGTYPE.ORG_TYPE_ID <> 3  ) as AM_Property

UNION ALL

SELECT 'UPDATE MIGRATION.GAM_SITE SET SITE_CODE = '''
+ ORG.ORG_CODE +''' , '
+' SITE_LICENSEE = ''' + CASE WHEN ORG_LICENSEE IS NULL THEN '' ELSE CAST(ORG_LICENSEE AS NVARCHAR) END +''' ,'
+' SITE_LICENSE_NUM = ''' + CASE WHEN ORG_LICENSE_NUM IS NULL THEN '' ELSE CAST(ORG_LICENSE_NUM AS NVARCHAR) END +''''
+ ' WHERE SITE_NUMBER = ' + CAST(ORG_NUMBER AS NVARCHAR)+';'  as Stat

-- select ORG.ORG_CODE, CASE WHEN ORG_LICENSEE IS NULL THEN '' ELSE CAST(ORG_LICENSEE AS NVARCHAR) END  as SITE_LICENSEE,
-- CASE WHEN ORG_LICENSE_NUM IS NULL THEN '' ELSE CAST(ORG_LICENSE_NUM AS NVARCHAR) END as SITE_LICENSE_NUM,
-- CAST(ORG_NUMBER AS NVARCHAR) as ORG_NUMBER
FROM [UM].[ORGANIZATION] AS ORG
LEFT JOIN [UM].[ORGANIZATION_TYPE] AS ORGTYPE ON ORGTYPE.ORG_TYPE_ID = ORG.ORG_TYPE_ID
WHERE ORG.ORG_DELETED_TS IS NULL AND ORGTYPE.ORG_TYPE_ID = 3 