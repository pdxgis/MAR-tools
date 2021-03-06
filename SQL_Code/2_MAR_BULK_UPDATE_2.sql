USE [AddressPDX_Edit]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [BDSAdmin].[MAR_BULK_UPDATE_2]
 
AS
BEGIN


--Conditions to be met for edit action:
	--Address point is from data source 'MULT%' or 'USPS%' 
	--Address is not located on a building footprint
	--There is a house on the tax lot associated that the address point is located on

--Edit Action: Modify the address point shape to be the house (building) centroid

	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET MAR_X = AP.SHAPE.STX, MAR_Y = AP.SHAPE.STY
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MS
	INNER JOIN [AddressPDX_Edit].[ArcMap_Admin].[ADDRESSPDX] AP
	ON AP.ADDRESS_ID = MS.ADDRESS_ID 
	
	EXEC [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_BUILDING]

	CREATE TABLE #Addresses
	( 
		Address_ID INT, 
		BLDG_ID nvarchar(30),
		NEW_AP_SHAPE geometry 
	)

	CREATE TABLE #Houses
	( 
		PROPERTYID nvarchar(7),
		BLDG_ID nvarchar(30),
		BLDG_SHAPE geometry 
	)

	INSERT INTO #Houses 
	select PROPERTYID,BLDG_ID,SHAPE from [AddressPDX_Edit].[BDSAdmin].[MAR_REFERENCE_BUILDINGS_LOOKUP] BLDG  
	  WHERE BLDG.BLDG_TYPE = 'House'

	INSERT INTO #Addresses 
	select MS.ADDRESS_ID,BLDG.BLDG_ID,BLDG.BLDG_SHAPE FROM  [BDSAdmin].[MAR_METRIC_SUMMARY] MS  
	  INNER JOIN 
	  [BDSAdmin].[MAR_REFERENCE_TAXLOTS] TL
	  ON  geometry::Point(MS.MAR_X,MS.MAR_Y,2913).STIntersects(TL.SHAPE) = 1
	  INNER JOIN  #Houses  BLDG  
	  ON TL.[PROPERTYID] = BLDG.PROPERTYID
	  WHERE 
	  (MS.DATA_SOURCE IN ('Bulk Edit','USPS Addr','MULT'))  and 
	  MS.BULK_EDIT_2 is null and 
	  (MS.[ADDRESS_ON_BLDG] = 'NO' or MS.[ADDRESS_ON_BLDG] = 'NA' ) and 
	  (SMARTY_STREETS_STREET_COUNT = 0 or CENTERLINE_STREET_CROSSED_COUNT = 0)


	update [ArcMap_Admin].[ADDRESSPDX] 
	SET DATA_SOURCE =  AP.DATA_SOURCE + '2',
	SHAPE = TEMP.NEW_AP_SHAPE 
	FROM [ArcMap_Admin].[ADDRESSPDX] AP 
	INNER JOIN #Addresses TEMP
	ON TEMP.Address_ID = AP.ADDRESS_ID
	
	update MAR_METRIC_SUMMARY 
	SET DATA_SOURCE = 'Bulk Edit', BULK_EDIT_2 = 'BULK 2' 
	FROM MAR_METRIC_SUMMARY SUMMARY 
	INNER JOIN #Addresses TEMP
	ON TEMP.Address_ID = SUMMARY.ADDRESS_ID

	DROP TABLE #Addresses
	DROP TABLE #Houses

END


