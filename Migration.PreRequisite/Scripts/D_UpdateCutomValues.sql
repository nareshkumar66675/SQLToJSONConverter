/*
	
	***************************************************
	*												  *
	*      PreRequisite Name - UpdateCustomID         *
	*												  *
	***************************************************
   
   Purpose : To Update the Min Cutom ID 

 */


DECLARE @offset int 

SELECT @offset=ISNULL(min([ADDRESS]),0) from [IDGEN].[CustomID_VALUES] 

UPDATE [IDGEN].[CustomID_MAP] set OFFSET=@offset where id=1