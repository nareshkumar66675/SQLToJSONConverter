/*
	
	***************************************************
	*												  *
	*   PreRequisite Name - AssetNumberMasterInsert	  *
	*												  *
	***************************************************
   
    Purpose : Retrieve Max Id For Asset Number Master Insert

 */

WITH NumMaster_CTE (StartRange, NumberCode,Seed,[Version])
AS
(
	SELECT ISNULL(MAX(asd_am_uid),0) + 1 as StartRange, 'ASSETDATA' as NumberCode,500 as Seed, 1 as [Version] from gam.asset_standard_details
	UNION ALL
	SELECT ISNULL(MAX(TYCOD_Number),0) + 1 as StartRange, 'TYPECODE' as NumberCode,1 as Seed,1 as [Version] FROM GAM.TYPE_CODE_MASTER AS MS where ms.[TYCOD_TYPE] = 2 
	UNION ALL
	SELECT ISNULL(MAX(RN),0) + 1 as StartRange, 'AssetHistoryId' as NumberCode,1 as Seed,1 as [Version]  FROM  [MIGRATION].[GAM_CHANGELIST_ASSET_DETAIL]
	UNION ALL
	SELECT ((SELECT ISNULL(MAX(INLINEASSETS_ID),0) AS GAME_MAX_INLINEASSETS_ID FROM MIGRATION.GAM_GAMES_DETAILS) +  (SELECT COUNT(1) FROM [PROGRESSIVE].[METER] WHERE IS_DELETED = 0  ) ) AS StartRange, 'INLINEASSETDATA' as NumberCode, 1 as Seed, 1 as [Version] 
)
SELECT 'IF EXISTS (Select 1 from Config.NumberMaster where NumberCode='''+cast(NumberCode as VARCHAR(50))+''')
		UPDATE [Config].[NumberMaster] SET StartRange='+cast(StartRange as VARCHAR(50))+' WHERE NumberCode='''+NumberCode+'''
		ELSE
		INSERT INTO Config.NumberMaster (NumberCode,StartRange,Seed,Version) Values('''+
			cast(NumberCode as VARCHAR(50))+''','+cast(StartRange as VARCHAR(50))+','+cast(Seed as VARCHAR(50))+','+cast([Version] as VARCHAR(50))+');  '
FROM NumMaster_CTE

GO
