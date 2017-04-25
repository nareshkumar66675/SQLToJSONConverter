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