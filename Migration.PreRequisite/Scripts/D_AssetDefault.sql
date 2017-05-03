/*
	
	***************************************************
	*												  *
	*       PreRequisite Name - AssetDefault		  *
	*												  *
	***************************************************
   
   Purpose : To Execute Common Queries in Asset Database

 */

 /*  Remove Default Asset Custom IDs - 
     New Id's will be inserted based on Legacy  */

DELETE FROM [IDGEN].[CustomID_VALUES] WHERE ID=1
GO
-- Manufacture
-- Model
-- Model Type
DELETE FROM  [COMPONENTS].[COMPONENTDATA]
WHERE [KEY] IN ('57_22002', '57_22003', '57_22006', '57_22011', '57_22061', '57_22069')
GO
--Insert Default POS.Relation
INSERT INTO Components.ComponentData
VALUES ('57_22079','{"Component":{"Id":22079,"ScopeLevel":0,"Code":"POS.RELATION","Components":[{"SiteId":0,"ComponentValues":[{"Id":"1_root","Name":"POS Model","Code":"POS.RELATION","DisplayName":"POS Model","IsSystemDefined":false,"Options":null,"ChildComponents":[{"Id":"1_22051","Name":"POS","Code":"POS.VENDOR","DisplayName":"POS","IsSystemDefined":false,"Options":[{"Id":1,"Value":"POS","Code":"VEND.SHORT.NAME"},{"Id":2,"Value":"POS","Code":"VEND.LONG.NAME"},{"Id":3,"Value":"9","Code":"VEND.CODE"}],"ChildComponents":[{"Id":"1_22052","Name":"POS","Code":"POS.MODEL","DisplayName":"POS","IsSystemDefined":false,"Options":[{"Id":1,"Value":"POS","Code":"POS.MODEL.NAME"}],"ChildComponents":[]}]}]}]}]},"ScopeLevel":0,"IsDeleted":false,"DataRowVersion":1}')
