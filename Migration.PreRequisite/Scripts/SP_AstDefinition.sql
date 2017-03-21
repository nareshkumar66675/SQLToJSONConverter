
DROP PROCEDURE IF EXISTS [MIGRATION].[P_ASSET_DEFINITION]
GO


CREATE PROCEDURE MIGRATION.P_ASSET_DEFINITION
 @pValue nvarchar(max) 
 AS 

--option index 0
IF JSON_VALUE(@pValue, '$.Options[1].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[0].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[0].Id') as Option_Id, json_value(@pValue, '$.Options[0].Name') as Option_Name, json_value(@pValue, '$.Options[0].Code') as Option_Code 
END 


--option index 1 
IF JSON_VALUE(@pValue, '$.Options[1].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[1].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[1].Id') as Option_Id, json_value(@pValue, '$.Options[1].Name') as Option_Name, json_value(@pValue, '$.Options[1].Code') as Option_Code 
END 


--option index 2 
IF JSON_VALUE(@pValue, '$.Options[2].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[2].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[2].Id') as Option_Id, json_value(@pValue, '$.Options[2].Name') as Option_Name, json_value(@pValue, '$.Options[2].Code') as Option_Code 
END 


--option index 3 
IF JSON_VALUE(@pValue, '$.Options[3].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[3].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[3].Id') as Option_Id, json_value(@pValue, '$.Options[3].Name') as Option_Name, json_value(@pValue, '$.Options[3].Code') as Option_Code 
END 


--option index 4 
IF JSON_VALUE(@pValue, '$.Options[4].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[4].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[4].Id') as Option_Id, json_value(@pValue, '$.Options[4].Name') as Option_Name, json_value(@pValue, '$.Options[4].Code') as Option_Code 
END 


--option index 5 
IF JSON_VALUE(@pValue, '$.Options[5].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[5].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[5].Id') as Option_Id, json_value(@pValue, '$.Options[5].Name') as Option_Name, json_value(@pValue, '$.Options[5].Code') as Option_Code 
END 


--option index 6 
IF JSON_VALUE(@pValue, '$.Options[6].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[6].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[6].Id') as Option_Id, json_value(@pValue, '$.Options[6].Name') as Option_Name, json_value(@pValue, '$.Options[6].Code') as Option_Code 
END 


--option index 7 
IF JSON_VALUE(@pValue, '$.Options[7].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[7].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[7].Id') as Option_Id, json_value(@pValue, '$.Options[7].Name') as Option_Name, json_value(@pValue, '$.Options[7].Code') as Option_Code 
END 


--option index 8 
IF JSON_VALUE(@pValue, '$.Options[8].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[8].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[8].Id') as Option_Id, json_value(@pValue, '$.Options[8].Name') as Option_Name, json_value(@pValue, '$.Options[8].Code') as Option_Code 
END 


--option index 9 
IF JSON_VALUE(@pValue, '$.Options[9].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[9].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[9].Id') as Option_Id, json_value(@pValue, '$.Options[9].Name') as Option_Name, json_value(@pValue, '$.Options[9].Code') as Option_Code 
END 


--option index 10 
IF JSON_VALUE(@pValue, '$.Options[10].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[10].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[10].Id') as Option_Id, json_value(@pValue, '$.Options[10].Name') as Option_Name, json_value(@pValue, '$.Options[10].Code') as Option_Code 
END 


--option index 11 
IF JSON_VALUE(@pValue, '$.Options[11].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[11].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[11].Id') as Option_Id, json_value(@pValue, '$.Options[11].Name') as Option_Name, json_value(@pValue, '$.Options[11].Code') as Option_Code 
END 


--option index 12 
IF JSON_VALUE(@pValue, '$.Options[12].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[12].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[12].Id') as Option_Id, json_value(@pValue, '$.Options[12].Name') as Option_Name, json_value(@pValue, '$.Options[12].Code') as Option_Code 
END 


--option index 13 
IF JSON_VALUE(@pValue, '$.Options[13].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[13].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[13].Id') as Option_Id, json_value(@pValue, '$.Options[13].Name') as Option_Name, json_value(@pValue, '$.Options[13].Code') as Option_Code 
END 


--option index 14 
IF JSON_VALUE(@pValue, '$.Options[14].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[14].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[14].Id') as Option_Id, json_value(@pValue, '$.Options[14].Name') as Option_Name, json_value(@pValue, '$.Options[14].Code') as Option_Code 
END 


--option index 15 
IF JSON_VALUE(@pValue, '$.Options[15].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[15].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[15].Id') as Option_Id, json_value(@pValue, '$.Options[15].Name') as Option_Name, json_value(@pValue, '$.Options[15].Code') as Option_Code 
END 


--option index 16 
IF JSON_VALUE(@pValue, '$.Options[16].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[16].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[16].Id') as Option_Id, json_value(@pValue, '$.Options[16].Name') as Option_Name, json_value(@pValue, '$.Options[16].Code') as Option_Code 
END 


--option index 17 
IF JSON_VALUE(@pValue, '$.Options[17].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[17].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[17].Id') as Option_Id, json_value(@pValue, '$.Options[17].Name') as Option_Name, json_value(@pValue, '$.Options[17].Code') as Option_Code 
END 


--option index 18 
IF JSON_VALUE(@pValue, '$.Options[18].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[18].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[18].Id') as Option_Id, json_value(@pValue, '$.Options[18].Name') as Option_Name, json_value(@pValue, '$.Options[18].Code') as Option_Code 
END 


--option index 19 
IF JSON_VALUE(@pValue, '$.Options[19].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[19].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[19].Id') as Option_Id, json_value(@pValue, '$.Options[19].Name') as Option_Name, json_value(@pValue, '$.Options[19].Code') as Option_Code 
END 


--option index 20 
IF JSON_VALUE(@pValue, '$.Options[20].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[20].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[20].Id') as Option_Id, json_value(@pValue, '$.Options[20].Name') as Option_Name, json_value(@pValue, '$.Options[20].Code') as Option_Code 
END 


--option index 21 
IF JSON_VALUE(@pValue, '$.Options[21].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[21].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[21].Id') as Option_Id, json_value(@pValue, '$.Options[21].Name') as Option_Name, json_value(@pValue, '$.Options[21].Code') as Option_Code 
END 


--option index 22 
IF JSON_VALUE(@pValue, '$.Options[22].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[22].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[22].Id') as Option_Id, json_value(@pValue, '$.Options[22].Name') as Option_Name, json_value(@pValue, '$.Options[22].Code') as Option_Code 
END 


--option index 23 
IF JSON_VALUE(@pValue, '$.Options[23].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[23].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[23].Id') as Option_Id, json_value(@pValue, '$.Options[23].Name') as Option_Name, json_value(@pValue, '$.Options[23].Code') as Option_Code 
END 


--option index 24 
IF JSON_VALUE(@pValue, '$.Options[24].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[24].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[24].Id') as Option_Id, json_value(@pValue, '$.Options[24].Name') as Option_Name, json_value(@pValue, '$.Options[24].Code') as Option_Code 
END 


--option index 25 
IF JSON_VALUE(@pValue, '$.Options[25].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[25].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[25].Id') as Option_Id, json_value(@pValue, '$.Options[25].Name') as Option_Name, json_value(@pValue, '$.Options[25].Code') as Option_Code 
END 


--option index 26 
IF JSON_VALUE(@pValue, '$.Options[26].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[26].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[26].Id') as Option_Id, json_value(@pValue, '$.Options[26].Name') as Option_Name, json_value(@pValue, '$.Options[26].Code') as Option_Code 
END 


--option index 27 
IF JSON_VALUE(@pValue, '$.Options[27].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[27].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[27].Id') as Option_Id, json_value(@pValue, '$.Options[27].Name') as Option_Name, json_value(@pValue, '$.Options[27].Code') as Option_Code 
END 


--option index 28 
IF JSON_VALUE(@pValue, '$.Options[28].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[28].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[28].Id') as Option_Id, json_value(@pValue, '$.Options[28].Name') as Option_Name, json_value(@pValue, '$.Options[28].Code') as Option_Code 
END 


--option index 29 
IF JSON_VALUE(@pValue, '$.Options[29].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[29].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[29].Id') as Option_Id, json_value(@pValue, '$.Options[29].Name') as Option_Name, json_value(@pValue, '$.Options[29].Code') as Option_Code 
END 


--option index 30 
IF JSON_VALUE(@pValue, '$.Options[30].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[30].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[30].Id') as Option_Id, json_value(@pValue, '$.Options[30].Name') as Option_Name, json_value(@pValue, '$.Options[30].Code') as Option_Code 
END 


--option index 31 
IF JSON_VALUE(@pValue, '$.Options[31].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[31].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[31].Id') as Option_Id, json_value(@pValue, '$.Options[31].Name') as Option_Name, json_value(@pValue, '$.Options[31].Code') as Option_Code 
END 


--option index 32 
IF JSON_VALUE(@pValue, '$.Options[32].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[32].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[32].Id') as Option_Id, json_value(@pValue, '$.Options[32].Name') as Option_Name, json_value(@pValue, '$.Options[32].Code') as Option_Code 
END 


--option index 33 
IF JSON_VALUE(@pValue, '$.Options[33].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[33].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[33].Id') as Option_Id, json_value(@pValue, '$.Options[33].Name') as Option_Name, json_value(@pValue, '$.Options[33].Code') as Option_Code 
END 


--option index 34 
IF JSON_VALUE(@pValue, '$.Options[34].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[34].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[34].Id') as Option_Id, json_value(@pValue, '$.Options[34].Name') as Option_Name, json_value(@pValue, '$.Options[34].Code') as Option_Code 
END 


--option index 35 
IF JSON_VALUE(@pValue, '$.Options[35].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[35].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[35].Id') as Option_Id, json_value(@pValue, '$.Options[35].Name') as Option_Name, json_value(@pValue, '$.Options[35].Code') as Option_Code 
END 


--option index 36 
IF JSON_VALUE(@pValue, '$.Options[36].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[36].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[36].Id') as Option_Id, json_value(@pValue, '$.Options[36].Name') as Option_Name, json_value(@pValue, '$.Options[36].Code') as Option_Code 
END 


--option index 37 
IF JSON_VALUE(@pValue, '$.Options[37].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[37].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[37].Id') as Option_Id, json_value(@pValue, '$.Options[37].Name') as Option_Name, json_value(@pValue, '$.Options[37].Code') as Option_Code 
END 


--option index 38 
IF JSON_VALUE(@pValue, '$.Options[38].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[38].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[38].Id') as Option_Id, json_value(@pValue, '$.Options[38].Name') as Option_Name, json_value(@pValue, '$.Options[38].Code') as Option_Code 
END 


--option index 39 
IF JSON_VALUE(@pValue, '$.Options[39].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[39].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[39].Id') as Option_Id, json_value(@pValue, '$.Options[39].Name') as Option_Name, json_value(@pValue, '$.Options[39].Code') as Option_Code 
END 


--option index 40 
IF JSON_VALUE(@pValue, '$.Options[40].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[40].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[40].Id') as Option_Id, json_value(@pValue, '$.Options[40].Name') as Option_Name, json_value(@pValue, '$.Options[40].Code') as Option_Code 
END 


--option index 41 
IF JSON_VALUE(@pValue, '$.Options[41].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[41].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[41].Id') as Option_Id, json_value(@pValue, '$.Options[41].Name') as Option_Name, json_value(@pValue, '$.Options[41].Code') as Option_Code 
END 


--option index 42 
IF JSON_VALUE(@pValue, '$.Options[42].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[42].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[42].Id') as Option_Id, json_value(@pValue, '$.Options[42].Name') as Option_Name, json_value(@pValue, '$.Options[42].Code') as Option_Code 
END 


--option index 43 
IF JSON_VALUE(@pValue, '$.Options[43].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[43].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[43].Id') as Option_Id, json_value(@pValue, '$.Options[43].Name') as Option_Name, json_value(@pValue, '$.Options[43].Code') as Option_Code 
END 


--option index 44 
IF JSON_VALUE(@pValue, '$.Options[44].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[44].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[44].Id') as Option_Id, json_value(@pValue, '$.Options[44].Name') as Option_Name, json_value(@pValue, '$.Options[44].Code') as Option_Code 
END 


--option index 45 
IF JSON_VALUE(@pValue, '$.Options[45].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[45].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[45].Id') as Option_Id, json_value(@pValue, '$.Options[45].Name') as Option_Name, json_value(@pValue, '$.Options[45].Code') as Option_Code 
END 


--option index 46 
IF JSON_VALUE(@pValue, '$.Options[46].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[46].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[46].Id') as Option_Id, json_value(@pValue, '$.Options[46].Name') as Option_Name, json_value(@pValue, '$.Options[46].Code') as Option_Code 
END 


--option index 47 
IF JSON_VALUE(@pValue, '$.Options[47].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[47].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[47].Id') as Option_Id, json_value(@pValue, '$.Options[47].Name') as Option_Name, json_value(@pValue, '$.Options[47].Code') as Option_Code 
END 


--option index 48 
IF JSON_VALUE(@pValue, '$.Options[48].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[48].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[48].Id') as Option_Id, json_value(@pValue, '$.Options[48].Name') as Option_Name, json_value(@pValue, '$.Options[48].Code') as Option_Code 
END 


--option index 49 
IF JSON_VALUE(@pValue, '$.Options[49].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[49].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[49].Id') as Option_Id, json_value(@pValue, '$.Options[49].Name') as Option_Name, json_value(@pValue, '$.Options[49].Code') as Option_Code 
END 


--option index 50 
IF JSON_VALUE(@pValue, '$.Options[50].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[50].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[50].Id') as Option_Id, json_value(@pValue, '$.Options[50].Name') as Option_Name, json_value(@pValue, '$.Options[50].Code') as Option_Code 
END 


--option index 51 
IF JSON_VALUE(@pValue, '$.Options[51].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[51].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[51].Id') as Option_Id, json_value(@pValue, '$.Options[51].Name') as Option_Name, json_value(@pValue, '$.Options[51].Code') as Option_Code 
END 


--option index 52 
IF JSON_VALUE(@pValue, '$.Options[52].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[52].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[52].Id') as Option_Id, json_value(@pValue, '$.Options[52].Name') as Option_Name, json_value(@pValue, '$.Options[52].Code') as Option_Code 
END 


--option index 53 
IF JSON_VALUE(@pValue, '$.Options[53].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[53].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[53].Id') as Option_Id, json_value(@pValue, '$.Options[53].Name') as Option_Name, json_value(@pValue, '$.Options[53].Code') as Option_Code 
END 


--option index 54 
IF JSON_VALUE(@pValue, '$.Options[54].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[54].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[54].Id') as Option_Id, json_value(@pValue, '$.Options[54].Name') as Option_Name, json_value(@pValue, '$.Options[54].Code') as Option_Code 
END 


--option index 55 
IF JSON_VALUE(@pValue, '$.Options[55].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[55].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[55].Id') as Option_Id, json_value(@pValue, '$.Options[55].Name') as Option_Name, json_value(@pValue, '$.Options[55].Code') as Option_Code 
END 


--option index 56 
IF JSON_VALUE(@pValue, '$.Options[56].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[56].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[56].Id') as Option_Id, json_value(@pValue, '$.Options[56].Name') as Option_Name, json_value(@pValue, '$.Options[56].Code') as Option_Code 
END 


--option index 57 
IF JSON_VALUE(@pValue, '$.Options[57].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[57].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[57].Id') as Option_Id, json_value(@pValue, '$.Options[57].Name') as Option_Name, json_value(@pValue, '$.Options[57].Code') as Option_Code 
END 


--option index 58 
IF JSON_VALUE(@pValue, '$.Options[58].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[58].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[58].Id') as Option_Id, json_value(@pValue, '$.Options[58].Name') as Option_Name, json_value(@pValue, '$.Options[58].Code') as Option_Code 
END 


--option index 59 
IF JSON_VALUE(@pValue, '$.Options[59].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[59].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[59].Id') as Option_Id, json_value(@pValue, '$.Options[59].Name') as Option_Name, json_value(@pValue, '$.Options[59].Code') as Option_Code 
END 


--option index 60 
IF JSON_VALUE(@pValue, '$.Options[60].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[60].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[60].Id') as Option_Id, json_value(@pValue, '$.Options[60].Name') as Option_Name, json_value(@pValue, '$.Options[60].Code') as Option_Code 
END 


--option index 61 
IF JSON_VALUE(@pValue, '$.Options[61].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[61].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[61].Id') as Option_Id, json_value(@pValue, '$.Options[61].Name') as Option_Name, json_value(@pValue, '$.Options[61].Code') as Option_Code 
END 


--option index 62 
IF JSON_VALUE(@pValue, '$.Options[62].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[62].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[62].Id') as Option_Id, json_value(@pValue, '$.Options[62].Name') as Option_Name, json_value(@pValue, '$.Options[62].Code') as Option_Code 
END 


--option index 63 
IF JSON_VALUE(@pValue, '$.Options[63].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[63].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[63].Id') as Option_Id, json_value(@pValue, '$.Options[63].Name') as Option_Name, json_value(@pValue, '$.Options[63].Code') as Option_Code 
END 


--option index 64 
IF JSON_VALUE(@pValue, '$.Options[64].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[64].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[64].Id') as Option_Id, json_value(@pValue, '$.Options[64].Name') as Option_Name, json_value(@pValue, '$.Options[64].Code') as Option_Code 
END 


--option index 65 
IF JSON_VALUE(@pValue, '$.Options[65].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[65].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[65].Id') as Option_Id, json_value(@pValue, '$.Options[65].Name') as Option_Name, json_value(@pValue, '$.Options[65].Code') as Option_Code 
END 


--option index 66 
IF JSON_VALUE(@pValue, '$.Options[66].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[66].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[66].Id') as Option_Id, json_value(@pValue, '$.Options[66].Name') as Option_Name, json_value(@pValue, '$.Options[66].Code') as Option_Code 
END 


--option index 67 
IF JSON_VALUE(@pValue, '$.Options[67].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[67].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[67].Id') as Option_Id, json_value(@pValue, '$.Options[67].Name') as Option_Name, json_value(@pValue, '$.Options[67].Code') as Option_Code 
END 


--option index 68 
IF JSON_VALUE(@pValue, '$.Options[68].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[68].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[68].Id') as Option_Id, json_value(@pValue, '$.Options[68].Name') as Option_Name, json_value(@pValue, '$.Options[68].Code') as Option_Code 
END 


--option index 69 
IF JSON_VALUE(@pValue, '$.Options[69].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[69].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[69].Id') as Option_Id, json_value(@pValue, '$.Options[69].Name') as Option_Name, json_value(@pValue, '$.Options[69].Code') as Option_Code 
END 


--option index 70 
IF JSON_VALUE(@pValue, '$.Options[70].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[70].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[70].Id') as Option_Id, json_value(@pValue, '$.Options[70].Name') as Option_Name, json_value(@pValue, '$.Options[70].Code') as Option_Code 
END 


--option index 71 
IF JSON_VALUE(@pValue, '$.Options[71].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[71].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[71].Id') as Option_Id, json_value(@pValue, '$.Options[71].Name') as Option_Name, json_value(@pValue, '$.Options[71].Code') as Option_Code 
END 


--option index 72 
IF JSON_VALUE(@pValue, '$.Options[72].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[72].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[72].Id') as Option_Id, json_value(@pValue, '$.Options[72].Name') as Option_Name, json_value(@pValue, '$.Options[72].Code') as Option_Code 
END 


--option index 73 
IF JSON_VALUE(@pValue, '$.Options[73].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[73].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[73].Id') as Option_Id, json_value(@pValue, '$.Options[73].Name') as Option_Name, json_value(@pValue, '$.Options[73].Code') as Option_Code 
END 


--option index 74 
IF JSON_VALUE(@pValue, '$.Options[74].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[74].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[74].Id') as Option_Id, json_value(@pValue, '$.Options[74].Name') as Option_Name, json_value(@pValue, '$.Options[74].Code') as Option_Code 
END 


--option index 75 
IF JSON_VALUE(@pValue, '$.Options[75].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[75].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[75].Id') as Option_Id, json_value(@pValue, '$.Options[75].Name') as Option_Name, json_value(@pValue, '$.Options[75].Code') as Option_Code 
END 


--option index 76 
IF JSON_VALUE(@pValue, '$.Options[76].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[76].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[76].Id') as Option_Id, json_value(@pValue, '$.Options[76].Name') as Option_Name, json_value(@pValue, '$.Options[76].Code') as Option_Code 
END 


--option index 77 
IF JSON_VALUE(@pValue, '$.Options[77].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[77].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[77].Id') as Option_Id, json_value(@pValue, '$.Options[77].Name') as Option_Name, json_value(@pValue, '$.Options[77].Code') as Option_Code 
END 


--option index 78 
IF JSON_VALUE(@pValue, '$.Options[78].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[78].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[78].Id') as Option_Id, json_value(@pValue, '$.Options[78].Name') as Option_Name, json_value(@pValue, '$.Options[78].Code') as Option_Code 
END 


--option index 79 
IF JSON_VALUE(@pValue, '$.Options[79].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[79].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[79].Id') as Option_Id, json_value(@pValue, '$.Options[79].Name') as Option_Name, json_value(@pValue, '$.Options[79].Code') as Option_Code 
END 


--option index 80 
IF JSON_VALUE(@pValue, '$.Options[80].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[80].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[80].Id') as Option_Id, json_value(@pValue, '$.Options[80].Name') as Option_Name, json_value(@pValue, '$.Options[80].Code') as Option_Code 
END 


--option index 81 
IF JSON_VALUE(@pValue, '$.Options[81].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[81].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[81].Id') as Option_Id, json_value(@pValue, '$.Options[81].Name') as Option_Name, json_value(@pValue, '$.Options[81].Code') as Option_Code 
END 


--option index 82 
IF JSON_VALUE(@pValue, '$.Options[82].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[82].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[82].Id') as Option_Id, json_value(@pValue, '$.Options[82].Name') as Option_Name, json_value(@pValue, '$.Options[82].Code') as Option_Code 
END 


--option index 83 
IF JSON_VALUE(@pValue, '$.Options[83].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[83].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[83].Id') as Option_Id, json_value(@pValue, '$.Options[83].Name') as Option_Name, json_value(@pValue, '$.Options[83].Code') as Option_Code 
END 


--option index 84 
IF JSON_VALUE(@pValue, '$.Options[84].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[84].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[84].Id') as Option_Id, json_value(@pValue, '$.Options[84].Name') as Option_Name, json_value(@pValue, '$.Options[84].Code') as Option_Code 
END 


--option index 85 
IF JSON_VALUE(@pValue, '$.Options[85].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[85].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[85].Id') as Option_Id, json_value(@pValue, '$.Options[85].Name') as Option_Name, json_value(@pValue, '$.Options[85].Code') as Option_Code 
END 


--option index 86 
IF JSON_VALUE(@pValue, '$.Options[86].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[86].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[86].Id') as Option_Id, json_value(@pValue, '$.Options[86].Name') as Option_Name, json_value(@pValue, '$.Options[86].Code') as Option_Code 
END 


--option index 87 
IF JSON_VALUE(@pValue, '$.Options[87].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[87].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[87].Id') as Option_Id, json_value(@pValue, '$.Options[87].Name') as Option_Name, json_value(@pValue, '$.Options[87].Code') as Option_Code 
END 


--option index 88 
IF JSON_VALUE(@pValue, '$.Options[88].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[88].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[88].Id') as Option_Id, json_value(@pValue, '$.Options[88].Name') as Option_Name, json_value(@pValue, '$.Options[88].Code') as Option_Code 
END 


--option index 89 
IF JSON_VALUE(@pValue, '$.Options[89].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[89].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[89].Id') as Option_Id, json_value(@pValue, '$.Options[89].Name') as Option_Name, json_value(@pValue, '$.Options[89].Code') as Option_Code 
END 


--option index 90 
IF JSON_VALUE(@pValue, '$.Options[90].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[90].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[90].Id') as Option_Id, json_value(@pValue, '$.Options[90].Name') as Option_Name, json_value(@pValue, '$.Options[90].Code') as Option_Code 
END 


--option index 91 
IF JSON_VALUE(@pValue, '$.Options[91].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[91].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[91].Id') as Option_Id, json_value(@pValue, '$.Options[91].Name') as Option_Name, json_value(@pValue, '$.Options[91].Code') as Option_Code 
END 


--option index 92 
IF JSON_VALUE(@pValue, '$.Options[92].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[92].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[92].Id') as Option_Id, json_value(@pValue, '$.Options[92].Name') as Option_Name, json_value(@pValue, '$.Options[92].Code') as Option_Code 
END 


--option index 93 
IF JSON_VALUE(@pValue, '$.Options[93].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[93].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[93].Id') as Option_Id, json_value(@pValue, '$.Options[93].Name') as Option_Name, json_value(@pValue, '$.Options[93].Code') as Option_Code 
END 


--option index 94 
IF JSON_VALUE(@pValue, '$.Options[94].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[94].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[94].Id') as Option_Id, json_value(@pValue, '$.Options[94].Name') as Option_Name, json_value(@pValue, '$.Options[94].Code') as Option_Code 
END 


--option index 95 
IF JSON_VALUE(@pValue, '$.Options[95].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[95].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[95].Id') as Option_Id, json_value(@pValue, '$.Options[95].Name') as Option_Name, json_value(@pValue, '$.Options[95].Code') as Option_Code 
END 


--option index 96 
IF JSON_VALUE(@pValue, '$.Options[96].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[96].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[96].Id') as Option_Id, json_value(@pValue, '$.Options[96].Name') as Option_Name, json_value(@pValue, '$.Options[96].Code') as Option_Code 
END 


--option index 97 
IF JSON_VALUE(@pValue, '$.Options[97].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[97].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[97].Id') as Option_Id, json_value(@pValue, '$.Options[97].Name') as Option_Name, json_value(@pValue, '$.Options[97].Code') as Option_Code 
END 


--option index 98 
IF JSON_VALUE(@pValue, '$.Options[98].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[98].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[98].Id') as Option_Id, json_value(@pValue, '$.Options[98].Name') as Option_Name, json_value(@pValue, '$.Options[98].Code') as Option_Code 
END 


--option index 99 
IF JSON_VALUE(@pValue, '$.Options[99].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[99].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[99].Id') as Option_Id, json_value(@pValue, '$.Options[99].Name') as Option_Name, json_value(@pValue, '$.Options[99].Code') as Option_Code 
END 


--option index 100 
IF JSON_VALUE(@pValue, '$.Options[100].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[100].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[100].Id') as Option_Id, json_value(@pValue, '$.Options[100].Name') as Option_Name, json_value(@pValue, '$.Options[100].Code') as Option_Code 
END 


--option index 101 
IF JSON_VALUE(@pValue, '$.Options[101].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[101].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[101].Id') as Option_Id, json_value(@pValue, '$.Options[101].Name') as Option_Name, json_value(@pValue, '$.Options[101].Code') as Option_Code 
END 


--option index 102 
IF JSON_VALUE(@pValue, '$.Options[102].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[102].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[102].Id') as Option_Id, json_value(@pValue, '$.Options[102].Name') as Option_Name, json_value(@pValue, '$.Options[102].Code') as Option_Code 
END 


--option index 103 
IF JSON_VALUE(@pValue, '$.Options[103].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[103].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[103].Id') as Option_Id, json_value(@pValue, '$.Options[103].Name') as Option_Name, json_value(@pValue, '$.Options[103].Code') as Option_Code 
END 


--option index 104 
IF JSON_VALUE(@pValue, '$.Options[104].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[104].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[104].Id') as Option_Id, json_value(@pValue, '$.Options[104].Name') as Option_Name, json_value(@pValue, '$.Options[104].Code') as Option_Code 
END 


--option index 105 
IF JSON_VALUE(@pValue, '$.Options[105].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[105].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[105].Id') as Option_Id, json_value(@pValue, '$.Options[105].Name') as Option_Name, json_value(@pValue, '$.Options[105].Code') as Option_Code 
END 


--option index 106 
IF JSON_VALUE(@pValue, '$.Options[106].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[106].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[106].Id') as Option_Id, json_value(@pValue, '$.Options[106].Name') as Option_Name, json_value(@pValue, '$.Options[106].Code') as Option_Code 
END 


--option index 107 
IF JSON_VALUE(@pValue, '$.Options[107].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[107].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[107].Id') as Option_Id, json_value(@pValue, '$.Options[107].Name') as Option_Name, json_value(@pValue, '$.Options[107].Code') as Option_Code 
END 


--option index 108 
IF JSON_VALUE(@pValue, '$.Options[108].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[108].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[108].Id') as Option_Id, json_value(@pValue, '$.Options[108].Name') as Option_Name, json_value(@pValue, '$.Options[108].Code') as Option_Code 
END 


--option index 109 
IF JSON_VALUE(@pValue, '$.Options[109].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[109].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[109].Id') as Option_Id, json_value(@pValue, '$.Options[109].Name') as Option_Name, json_value(@pValue, '$.Options[109].Code') as Option_Code 
END 


--option index 110 
IF JSON_VALUE(@pValue, '$.Options[110].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[110].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[110].Id') as Option_Id, json_value(@pValue, '$.Options[110].Name') as Option_Name, json_value(@pValue, '$.Options[110].Code') as Option_Code 
END 


--option index 111 
IF JSON_VALUE(@pValue, '$.Options[111].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[111].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[111].Id') as Option_Id, json_value(@pValue, '$.Options[111].Name') as Option_Name, json_value(@pValue, '$.Options[111].Code') as Option_Code 
END 


--option index 112 
IF JSON_VALUE(@pValue, '$.Options[112].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[112].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[112].Id') as Option_Id, json_value(@pValue, '$.Options[112].Name') as Option_Name, json_value(@pValue, '$.Options[112].Code') as Option_Code 
END 


--option index 113 
IF JSON_VALUE(@pValue, '$.Options[113].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[113].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[113].Id') as Option_Id, json_value(@pValue, '$.Options[113].Name') as Option_Name, json_value(@pValue, '$.Options[113].Code') as Option_Code 
END 


--option index 114 
IF JSON_VALUE(@pValue, '$.Options[114].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[114].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[114].Id') as Option_Id, json_value(@pValue, '$.Options[114].Name') as Option_Name, json_value(@pValue, '$.Options[114].Code') as Option_Code 
END 


--option index 115 
IF JSON_VALUE(@pValue, '$.Options[115].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[115].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[115].Id') as Option_Id, json_value(@pValue, '$.Options[115].Name') as Option_Name, json_value(@pValue, '$.Options[115].Code') as Option_Code 
END 


--option index 116 
IF JSON_VALUE(@pValue, '$.Options[116].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[116].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[116].Id') as Option_Id, json_value(@pValue, '$.Options[116].Name') as Option_Name, json_value(@pValue, '$.Options[116].Code') as Option_Code 
END 


--option index 117 
IF JSON_VALUE(@pValue, '$.Options[117].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[117].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[117].Id') as Option_Id, json_value(@pValue, '$.Options[117].Name') as Option_Name, json_value(@pValue, '$.Options[117].Code') as Option_Code 
END 


--option index 118 
IF JSON_VALUE(@pValue, '$.Options[118].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[118].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[118].Id') as Option_Id, json_value(@pValue, '$.Options[118].Name') as Option_Name, json_value(@pValue, '$.Options[118].Code') as Option_Code 
END 


--option index 119 
IF JSON_VALUE(@pValue, '$.Options[119].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[119].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[119].Id') as Option_Id, json_value(@pValue, '$.Options[119].Name') as Option_Name, json_value(@pValue, '$.Options[119].Code') as Option_Code 
END 


--option index 120 
IF JSON_VALUE(@pValue, '$.Options[120].Name') IS NOT NULL 
BEGIN 
INSERT INTO MIGRATION.ASSET_TYPE_DEFN (ID, ASST_ID, ASSET_NAME, ASSET_CODE, ASSET_DISPLAY_NAME, OPTION_ID, OPTION_NAME, OPTION_CODE) 
SELECT CAST( (json_value(@pValue, '$.AssetType.Id') + '0' + json_value(@pValue, '$.Options[120].Id')) AS INT), json_value(@pValue, '$.AssetType.Id') as Id, json_value(@pValue, '$.AssetType.Name') as Name, json_value(@pValue, '$.AssetType.Code') as Code, json_value(@pValue, '$.AssetType.DisplayName') as DisplayName, 
json_value(@pValue, '$.Options[120].Id') as Option_Id, json_value(@pValue, '$.Options[120].Name') as Option_Name, json_value(@pValue, '$.Options[120].Code') as Option_Code 
END 


--SELECT * INTO PROD0121_AssetMatrix14.MIGRATION.[FLORET_ASSET_DEF] from [ASSET_DEF].[ASSETS]  
--SELECT * INTO MIGRATION.DENOMINATION from GAM.DENOMINATION
--(EXEC PROD0121_AssetMatrix14.MIGRATION.P_ASSET_DEFINITION [value])
