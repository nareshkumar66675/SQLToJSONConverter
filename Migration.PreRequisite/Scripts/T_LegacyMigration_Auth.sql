
/*
	
	***************************************************
	*												  *
	*    PreRequisite Name - LegacyAuthDataTables     *
	*												  *
	***************************************************
   
   Purpose : To Populating New Ids for Active Auth records

*/

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Migration')
EXEC ('CREATE SCHEMA MIGRATION;');
GO


 ------Drop Tables ----

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.COMMON_USER_FUNCTION_GROUP') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.COMMON_USER_FUNCTION_GROUP
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.COMMON_USER_ROLE') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.COMMON_USER_ROLE
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_PROPERTY') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_PROPERTY 
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MIGRATION.GAM_SITE') AND type in (N'U'))
BEGIN
DROP Table MIGRATION.GAM_SITE 
END
GO


------------ DDL Create & Insert Data ---------------------

CREATE TABLE MIGRATION.COMMON_USER_FUNCTION_GROUP 
(
FUNCGRP_ID BIGINT,
FUNCGRP_NEW_ID BIGINT
)

-- insert record for migration

INSERT INTO MIGRATION.COMMON_USER_FUNCTION_GROUP (FUNCGRP_ID, FUNCGRP_NEW_ID)
SELECT FUNCGRP_ID, ROW_NUMBER()OVER(ORDER BY FUNCGRP_CREATED_TS) AS RW_NUM 
FROM [COMMON].[USER_FUNCTION_GROUP] WHERE FUNCGRP_IS_DELETED = 0 ORDER BY FUNCGRP_CREATED_TS 

GO


CREATE TABLE MIGRATION.COMMON_USER_ROLE
(
ROLE_ID BIGINT,
ROLE_NEW_ID BIGINT
)
GO

-- insert record for migration

INSERT INTO MIGRATION.COMMON_USER_ROLE (ROLE_ID, ROLE_NEW_ID)
SELECT ROLE_ID, ROW_NUMBER()OVER(ORDER BY ROLE_CREATED_TS) AS RW_NUM FROM [COMMON].[USER_ROLE] 
WHERE ROLE_IS_DELETED = 0 ORDER BY ROLE_CREATED_TS 
GO

CREATE TABLE MIGRATION.GAM_PROPERTY (
PROP_LEGCY_ID BIGINT,
PROP_NEW_ID BIGINT,
PROP_SHORT_NAME VARCHAR(128),
PROP_PARENT_CODE VARCHAR(5),
PROP_TYPE VARCHAR(32),
PROP_DEPTH_LEVEL INT
)
GO

--CREATE INDEX IDX_GAM_PRTY ON [MIGRATION].[GAM_PROPERTY] ([PROP_LEGCY_ID]);
--GO

--POPULATING PROPERTY TABLE

INSERT INTO MIGRATION.GAM_PROPERTY (PROP_LEGCY_ID, PROP_SHORT_NAME, PROP_NEW_ID)
SELECT PROP_ID, PROP_SHORT_NAME, ROW_NUMBER() OVER (ORDER BY CREATED_TS)  AS NEW_SEQ FROM GAM.PROPERTY WHERE IS_DELETED = 0 AND  PROP_ID NOT IN (1)

GO

CREATE TABLE MIGRATION.GAM_SITE (
SITE_LEGCY_ID BIGINT,
SITE_NEW_ID BIGINT,
SITE_NUMBER BIGINT,
SITE_CODE VARCHAR(5),
SITE_LICENSEE VARCHAR(128),
SITE_LICENSE_NUM VARCHAR(16)
)

GO

INSERT INTO MIGRATION.GAM_SITE (SITE_LEGCY_ID, SITE_NUMBER, SITE_NEW_ID)
SELECT SITE_ID, SITE_NUMBER, SITE_NUMBER FROM GAM.[SITE] WHERE IS_DELETED = 0 

GO