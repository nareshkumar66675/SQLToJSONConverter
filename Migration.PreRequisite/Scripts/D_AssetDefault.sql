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

-- Manufacture
-- Model
-- Model Type
DELETE FROM  [COMPONENTS].[COMPONENTDATA]
WHERE [KEY] IN ('57_22002', '57_22003', '57_22006', '57_22011', '57_22061', '57_22069')
GO
