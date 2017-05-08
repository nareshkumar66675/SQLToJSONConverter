/*
	
	***************************************************
	*												  *
	*    PreRequisite Name - AuthNumberMasterInsert	  *
	*												  *
	***************************************************
   
    Purpose : Retrieve Max Id For Auth Number Master Insert

 */

WITH NumMaster_CTE (StartRange, NumberCode,Seed,[Version])
AS
(
    SELECT ISNULL(MAX(SITE_NUMBER),0) + 1 as StartRange, 'SITE' as NumberCode,10 as Seed, 1 as [Version] from Gam.SITE
	UNION ALL
	SELECT ISNULL(MAX(FUNCGRP_NEW_ID),0) + 1 as StartRange, 'TASKGROUP' as NumberCode,50 as Seed,1 as [Version] FROM MIGRATION.COMMON_USER_FUNCTION_GROUP
	UNION ALL
	SELECT ISNULL(MAX(ROLE_NEW_ID),0) + 1 as StartRange, 'ROLE' as NumberCode,50 as Seed,1 as [Version] FROM MIGRATION.COMMON_USER_ROLE
    UNION ALL
	SELECT ISNULL(MAX(PROP_NEW_ID),0) + 1 as StartRange, 'HIERARCHALORGANIZATION' as NumberCode,10 as Seed,1 as [Version] FROM MIGRATION.GAM_PROPERTY
)
SELECT 'IF EXISTS (Select 1 from Config.NumberMaster where NumberCode='''+cast(NumberCode as VARCHAR(50))+''')
		UPDATE [Config].[NumberMaster] SET StartRange='+cast(StartRange as VARCHAR(50))+' WHERE NumberCode='''+NumberCode+'''
		ELSE
		INSERT INTO Config.NumberMaster (NumberCode,StartRange,Seed,Version) Values('''+
			cast(NumberCode as VARCHAR(50))+''','+cast(StartRange as VARCHAR(50))+','+cast(Seed as VARCHAR(50))+','+cast([Version] as VARCHAR(50))+');  '
FROM NumMaster_CTE

GO

