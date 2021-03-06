/*
	
	***************************************************
	*												  *
	*      PreRequisite Name - AuthStaticData		  *
	*												  *
	***************************************************
   
   Purpose : Default Data For Site and Organization

 */

DELETE FROM [Organization].[Organization] WHERE [key]='100_1'

GO

INSERT INTO [Organization].[Organization] ([Key] ,[Value])
VALUES ('100_1','{"Id":1,"ParentCode":null,"Code":"Rot","Name":"Root","Description":"Root","CreatedAt":"0001-01-01T00:00:00","IsRoot":true,"UpdatedAt":"2017-02-06T07:32:10.407Z","DepthLevel":1,"UMDataRowVersion":0,"DataRowVersion":0,"IsDeleted":false}')
GO

DELETE FROM [SITE].[SITE] WHERE [key]='151_99'
GO

INSERT INTO [SITE].[SITE] ([Key] ,[Value])
VALUES ('151_99', '{"Id":99,"Number":99,"Name":"System Site","Description":"System Site","Code":"System","ContactInformation":null,"ApprovedMachineCount":0,"Licensee":"0","LicensedMonitoringOperator":null,"VenueCode":"SystemSite","Timezone":"UTC","DataRowVersion":1,"IsActive":true,"IsDeleted":false}')
GO
