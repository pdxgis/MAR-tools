USE [AddressPDX_Edit]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [BDSAdmin].[MAR_BULK_UPDATE_1]

AS
BEGIN

	--Conditions to be met for edit action:
		--Address point is from data source  is like '%MULT%' or '%USPS%'
		--Address is not located on a building footprint
		--There is only one building shape within the tax lot

	--Edit action: Modify the address point shape to be the building centroid


	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET MAR_X = AP.SHAPE.STX, MAR_Y = AP.SHAPE.STY
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MS
	INNER JOIN [AddressPDX_Edit].[ArcMap_Admin].[ADDRESSPDX] AP
	ON AP.ADDRESS_ID = MS.ADDRESS_ID 

	EXEC [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_BUILDING]

	IF (EXISTS (SELECT * 
						FROM INFORMATION_SCHEMA.TABLES 
						WHERE TABLE_SCHEMA = 'BDSAdmin' 
						AND  TABLE_NAME = 'TEMPTABLE'))
	BEGIN
		DROP TABLE TEMPTABLE
	END

	CREATE TABLE TEMPTABLE
	(
		ADDRESS_ID int,
		ADDRESS_SHAPE geometry
	)

	INSERT INTO TEMPTABLE
	select MS.ADDRESS_ID,geometry::Point(min(BLDG.SHAPE.STX),min(BLDG.SHAPE.STY),2913) FROM  
		[BDSAdmin].[MAR_METRIC_SUMMARY] MS  
		INNER JOIN 
		[BDSAdmin].[MAR_REFERENCE_TAXLOTS] TL
		ON  geometry::Point(MS.MAR_X,MS.MAR_Y,2913).STIntersects(TL.SHAPE) = 1
		INNER JOIN  [AddressPDX_Edit].[BDSAdmin].[MAR_REFERENCE_BUILDINGS_LOOKUP] BLDG  
		ON TL.[PROPERTYID] = BLDG.PROPERTYID
		WHERE 
		(MS.DATA_SOURCE IN ('Bulk Edit','USPS Addr','MULT')) and MS.BULK_EDIT_1 is null
		and (MS.[ADDRESS_ON_BLDG] = 'NO' or MS.[ADDRESS_ON_BLDG] = 'NA' ) 
		GROUP BY MS.ADDRESS_ID 
		HAVING  count(BLDG.OBJECTID) = 1


	update [ArcMap_Admin].[ADDRESSPDX]
		   SET SHAPE =  TT.ADDRESS_SHAPE,
		   DATA_SOURCE =  AP.DATA_SOURCE + '1'
		   FROM [ArcMap_Admin].[ADDRESSPDX] AP
		   INNER JOIN 
			TEMPTABLE TT 
			ON  AP.ADDRESS_ID = TT.ADDRESS_ID


	-- update the summary table
	update MAR_METRIC_SUMMARY 
		   SET DATA_SOURCE = 'Bulk Edit', BULK_EDIT_1 = 'BULK 1'
		   FROM MAR_METRIC_SUMMARY MS
		   INNER JOIN 
			TEMPTABLE TT 
			ON  MS.ADDRESS_ID = TT.ADDRESS_ID


	DROP TABLE TEMPTABLE
END

