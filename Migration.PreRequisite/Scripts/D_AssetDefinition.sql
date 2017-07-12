/*
	
	***************************************************
	*												  *
	*   PreRequisite Name - AssetDefinition           *
	*												  *
	***************************************************
   
   Purpose : Insert Asset Definition to Legacy Database

 */


SELECT ROW_NUMBER() OVER(ORDER BY ID ASC) AS ID,
       ID as ASST_ID,
	   ASSET_NAME,
	   ASSET_CODE,
	   ASSET_DISPLAY_NAME,
	   OPTION_ID,
	   OPTION_NAME,
	   OPTION_CODE,
	   NULL as ASST_OPTN_ORDER from  [ASSET_DEF].[ASSETS] ast CROSS APPLY OPENJSON([value])
       with (ID int '$.AssetType.Id',
	         ASSET_NAME varchar(128) '$.AssetType.Name',
			 ASSET_CODE VARCHAR(128)  '$.AssetType.Code',
			 ASSET_DISPLAY_NAME varchar(128) '$.AssetType.DisplayName')
       cross apply OPENJSON(JSON_QUERY(ast.value,'$.Options')) 
	   with (OPTION_ID int '$.Id',
	         OPTION_NAME varchar(128) '$.Name',
			 OPTION_CODE varchar(128) '$.Code')