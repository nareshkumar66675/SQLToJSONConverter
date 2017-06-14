/*
	
	***************************************************
	*												  *
	*		PreRequisite Name - DataCorrection		  *
	*												  *
	***************************************************
   
   Purpose : Data Modications

 */


--updating model
--need to change
UPDATE MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET
SET Model = 'MVPXCEED' WHERE MODEL = 'MVP XCEED' 
GO

--updating model
--need to change
UPDATE MIGRATION.GAM_TYPE_DESCRIPTION 
SET Model = 'MVPXCEED' WHERE MODEL = 'MVP XCEED' 
GO


--inserting type decription for Type Code
INSERT INTO [MIGRATION].[GAM_TYPE_DESCRIPTION]
SELECT 
max(Id)+1 as Id, 
'KONAMI' as Typedescription,
'KONAMI' AS manufacture, --7
'CASINO' as modelType,
'PODIUM' as Model,
'1.00' as gameHoldPc,
'1.00' as HoldPC,
'1' as MaxBet,
'1' as LineConfiguration,
'Core' as GameCategory,
max(TypeDescription_Id)+1 as TypeDescription_Id,
max(Manufacturer_Id)+1 as Manufacturer_Id,
max(ModelType_Id)+1 as ModelType_Id,
max(Model_Id)+1 as Model_Id,
max(GameHoldPC_Id)+1 as GameHoldPC_Id,
max(HoldPC_Id)+1 as HoldPC_Id,
max(MaxBet_Id)+1 as MaxBet_Id,
max(LineConfiguration_Id)+1 as LineConfiguration_Id,
max(GameCategory_Id)+1 as GameCategory_Id
from [MIGRATION].[GAM_TYPE_DESCRIPTION] (nolock)


UPDATE MIGRATION.GAM_TYPE_DESCRIPTION SET MAXBET = '1' WHERE MAXBET = ''
GO
UPDATE MIGRATION.GAM_TYPE_DESCRIPTION SET LINECONFIGURATION = '1' WHERE LINECONFIGURATION = ''
GO
UPDATE MIGRATION.GAM_TYPE_DESCRIPTION SET GameCategory = 'Core' WHERE GameCategory = ''
GO

UPDATE MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET SET MAXBET = '1' WHERE MAXBET = ''
GO
UPDATE MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET SET LINECONFIGURATION = '1' WHERE LINECONFIGURATION = ''
GO
UPDATE MIGRATION.GAM_TYPE_DESCRIPTION_WITH_ASSET SET GameCategory = 'Core' WHERE GameCategory = ''
GO


