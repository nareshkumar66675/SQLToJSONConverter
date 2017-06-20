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

GO


/* SP to Update Site GeoData */


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'p_GetDashboardSiteInfo')
DROP PROCEDURE [Common].[p_GetDashboardSiteInfo]
GO

CREATE PROCEDURE [Common].[p_GetDashboardSiteInfo] (@siteList VARCHAR(max),
@TotalSlots BIGINT = 0,
@Online BIGINT = 0,
@Enrolled BIGINT = 0,
@Connected BIGINT = 0,
@Manufacturer VARCHAR(500) = NULL,
@Denom VARCHAR(500) = NULL,
@Progressive VARCHAR(500) =NULL)
AS

BEGIN

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE NAME = '#temp')
	drop table #temp
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE NAME = '#temp2')
	drop table #temp2

	CREATE TABLE #temp (
		[STATE_NAME] [varchar](50) NULL
		,[STATE_CODE] [varchar](50) NULL
		,JSONDATA VARCHAR(max)
		) ON [PRIMARY]

DECLARE @json VARCHAR(max)
DECLARE @String VARCHAR(max)
DECLARE @DisplayName varchar(max)
DECLARE @Offline BIGINT
DECLARE @UnEnrolled BIGINT
DECLARE @ProgressiveSlots BIGINT
DECLARE @NotConnected BIGINT
		
	set @siteList = CONCAT(@siteList,',' +(select STUFF((select ','+ cdsi.Value  AS [text()]   from [Common].[DASHBOARDDATA] cd 
	cross apply openjson(json_query(cd.value,'$.SiteData.CountryList')) cds 
	outer apply openJSon(JSON_QUERY(cds.value,'$.StateList')) cdsa 
	cross apply openjson(json_query(cdsa.value,'$.CityNameList')) cdc 
	cross apply openjson(json_query(cdc.value,'$.SiteNumber')) cdsi 
	FOR XML PATH('')),1,1,'')))

	INSERT INTO #temp
	SELECT STATE_NAME AS "StateList.StateName"
		,STATE_CODE AS "StateList.StateCode"
		,(
			SELECT REPLACE((
						SELECT REPLACE((
									SELECT replace(replace(replace(a.CITY_NAME, ' ', '<>'), '><', ''), '<>', ' ') AS "CityName"
										,LATITUDE AS "Latitude"
										,LONGITUDE AS "Longitude"
										,count(a.CITY_NAME) AS "SiteCount"
										,replace(replace(replace(CITY_CODE, ' ', '<>'), '><', ''), '<>', ' ') AS "CityCode"
										,abc.SiteNumber as "siteNumbers"
									FROM COMMON.COUNTRY_INFO AS a
									JOIN (
										SELECT CITY_NAME
											,'[' + LEFT(CONVERT(VARCHAR(max), SiteNumber), LEN(CONVERT(VARCHAR(max), SiteNumber)) - 1) + ']' AS SiteNumber
										FROM (
											SELECT replace(replace(replace(CITY_NAME, ' ', '<>'), '><', ''), '<>', ' ') AS CITY_NAME
												,(
													SELECT SITE_NUMBER + ',' AS [text()]
													FROM Common.COUNTRY_INFO
													WHERE (replace(replace(replace(CITY_NAME, ' ', '<>'), '><', ''), '<>', ' ') = replace(replace(replace(SE.CITY_NAME, ' ', '<>'), '><', ''), '<>', ' '))
													FOR XML PATH('')
														,TYPE
													) AS SiteNumber
											FROM Common.COUNTRY_INFO SE
											GROUP BY replace(replace(replace(SE.CITY_NAME, ' ', '<>'), '><', ''), '<>', ' ')
											) AS xx
										) AS abc ON a.CITY_NAME = abc.CITY_NAME
									WHERE SITE_NUMBER IN (
											SELECT Value
											FROM STRING_SPLIT(@siteList, ',')
											)
										AND a.STATE_NAME = b.STATE_NAME
									GROUP BY replace(replace(replace(a.CITY_NAME, ' ', '<>'), '><', ''), '<>', ' ')
										,LATITUDE
										,LONGITUDE
										,COUNTRY
										,COUNTRY_CODE
										,STATE_NAME
										,STATE_CODE
										,replace(replace(replace(CITY_CODE, ' ', '<>'), '><', ''), '<>', ' ')
										,abc.SiteNumber
									FOR JSON PATH
										,WITHOUT_ARRAY_WRAPPER
									), '"siteNumbers":"', '"siteNumbers":')
						), ']"}', ']}')
			)
	FROM COMMON.COUNTRY_INFO AS b
	WHERE SITE_NUMBER IN (
			SELECT Value
			FROM STRING_SPLIT(@siteList, ',')
			)
	GROUP BY STATE_NAME
		,STATE_CODE

	SET @json = (
			SELECT *
			FROM (
				SELECT STATE_NAME AS "StateName"
					,STATE_CODE AS "StateCode"
					,JSON_QUERY('[' + JSONDATA + ']') AS "CityNameList"
				FROM #temp
				) AS a
			FOR JSON path
				,WITHOUT_ARRAY_WRAPPER
			)
	SET @String = (
			SELECT COUNTRY AS CountryName
				,COUNTRY_CODE AS CountryCode
			FROM COMMON.COUNTRY_INFO AS b
			WHERE SITE_NUMBER IN (
					SELECT Value
					FROM STRING_SPLIT(@siteList, ',')
					)
			GROUP BY COUNTRY
				,COUNTRY_CODE
			FOR JSON PATH
				,WITHOUT_ARRAY_WRAPPER
			)



	UPDATE Common.DASHBOARDDATA
	SET [value] = JSON_MODIFY([Value], '$.SiteData.CountryList', JSON_QUERY('['+LEFT(@String, LEN(@String) - 1) + ',"StateList":[' + @json + ']}]'))


    IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE NAME = '#temp')
	drop table #temp


set @UnEnrolled = @TotalSlots - @Enrolled

set @NotConnected = @TotalSlots - @Connected

set @JSON = (select [value] from Common.DASHBOARDDATA)

set @JSON =JSON_MODIFY(@JSON, '$.SlotDataEntity.TotalSlots',@TotalSlots)

set @JSON =JSON_MODIFY(@JSON, '$.SlotDataEntity.Online',@Online)

set @JSON =JSON_MODIFY(@JSON, '$.SlotDataEntity.Offline',@Offline)

set @JSON =JSON_MODIFY(@JSON, '$.SlotDataEntity.Enrolled',@Enrolled)

set @JSON =JSON_MODIFY(@JSON, '$.SlotDataEntity.UnEnrolled',@UnEnrolled)

set @JSON =JSON_MODIFY(@JSON, '$.SlotDataEntity.Connected',@Connected)

set @JSON =JSON_MODIFY(@JSON, '$.SlotDataEntity.NotConnected',@NotConnected)

set @JSON = JSON_MODIFY(@JSON, '$.Manufacturers', ISNULL(JSON_QUERY(@Manufacturer),'null'))

set @JSON = JSON_MODIFY(@JSON, '$.Denoms', ISNULL(JSON_QUERY(@Denom),'null'))

set @JSON = JSON_MODIFY(@JSON, '$.ProgressivePools', ISNULL(JSON_QUERY(@Progressive),'null'))

UPDATE Common.DASHBOARDDATA set [Value] = @JSON

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE NAME = '#temp2')
	drop table #temp2

END
