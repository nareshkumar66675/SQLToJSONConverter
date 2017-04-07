/*
	
	***************************************************
	*												  *
	*    PreRequisite Name - OptionOrderUpdate        *
	*												  *
	***************************************************
   
   Purpose : Update Legacy Database for Option Order

 */



UPDATE fastDefn
SET fastDefn.ASST_OPTN_ORDER = a.OPTN_ORDER
FROM (SELECT fastDefn.[OPTION_CODE], optn.OPTN_CODE,
ASTDFN_OPTN_ORDER,
[ASSET_NAME],
ROW_NUMBER() OVER (PARTITION BY AST.ASST_ID ORDER BY AST.ASST_ID, astDfn.ASTDFN_OPTN_ORDER ) AS OPTN_ORDER
from GAM.ASSET AS AST
join gam.ASSET_DEFINITION as astDfn on astdfn.ASTDFN_ASST_ID = AST.ASST_ID
join gam.[OPTION] as optn on optn.[OPTN_ID] = astdfn.ASTDFN_OPTN_ID
join [MIGRATION].[ASSET_TYPE_DEFN] as fastDefn on fastDefn.[ASSET_CODE] = upper(AST.asst_name)
and fastDefn.[OPTION_CODE] = optn.OPTN_CODE ) AS a
JOIN [MIGRATION].[ASSET_TYPE_DEFN] as fastDefn on fastDefn.[ASSET_NAME] = A.assEt_name
and fastDefn.[OPTION_CODE] = a.OPTN_CODE