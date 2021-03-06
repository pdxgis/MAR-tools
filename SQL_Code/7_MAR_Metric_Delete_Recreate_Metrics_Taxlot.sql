USE [AddressPDX_Edit]
GO
/****** Object:  StoredProcedure [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_TAXLOT]    Script Date: 9/9/2014 9:12:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_TAXLOT]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- get spatially coincident taxlot
	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET SPATIAL_PROPERTY_ID = TL.PROPERTYID
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	INNER JOIN 
	   [BDSAdmin].[MAR_REFERENCE_TAXLOTS] TL
	ON
	   geometry::Point(MAR_SUMMARY.MAR_X, MAR_SUMMARY.MAR_Y, 2913).STIntersects(TL.SHAPE) = 1 
	

	-- refresh tax lot analysis  - this only processes metrics for addresses that have associated tax lots in the XREF tables. 
	DELETE FROM [BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_TAXLOTCENTER_ADDRESSPOINT]
	
	INSERT [BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_TAXLOTCENTER_ADDRESSPOINT]
		([OBJECTID],[ADDRESS_ID],[PROPERTY_ID],[FEET_BETWEEN_POINTS],[SHAPE])
	SELECT 
	TL.OBJECTID,
	MAX(XREF.ADDRESS_ID),
	MAX(XREF.PROPERTY_ID),
	(geometry::STLineFromText('LINESTRING(' + str(MAX(SUMMARY.MAR_X),15,5)  + ' ' + str(MAX(SUMMARY.MAR_Y),15,5) + ', ' + str(MAX(TL.SHAPE.STCentroid().STX),15,5)  + ' ' +  str(MAX(TL.SHAPE.STCentroid().STY) ,15,5) + ')', 2913)).STLength() FEET_BETWEEN_POINTS,
	geometry::STLineFromText('LINESTRING(' + str(MAX(SUMMARY.MAR_X),15,5)  + ' ' + str(MAX(SUMMARY.MAR_Y),15,5) + ', ' + str(MAX(TL.SHAPE.STCentroid().STX),15,5)  + ' ' +  str(MAX(TL.SHAPE.STCentroid().STY) ,15,5) + ')', 2913) SHAPE
	FROM [ArcMap_Admin].[ADDRESS_PROPERTY_XREF] XREF
	INNER JOIN [BDSAdmin].[MAR_METRIC_SUMMARY] SUMMARY 
	ON XREF.ADDRESS_ID = SUMMARY.ADDRESS_ID
	INNER JOIN [BDSAdmin].[MAR_REFERENCE_TAXLOTS] TL
	ON XREF.PROPERTY_ID = TL.PROPERTYID
	WHERE geometry::Point(SUMMARY.MAR_X, SUMMARY.MAR_Y, 2913).STDistance(TL.SHAPE.STCentroid()) > .001 and TL.PROPERTYID is not null
	GROUP BY TL.OBJECTID

	----------------------------------------------------------------------------------------------------------------------------------------------
	-- set all address_on_lot to no
	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET ADDRESS_ON_LOT = 'NO'
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY


	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET ADDRESS_ON_LOT = 'NA'
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	LEFT OUTER JOIN
	[ArcMap_Admin].[ADDRESS_PROPERTY_XREF] XREF
	ON MAR_SUMMARY.ADDRESS_ID = XREF.ADDRESS_ID
	WHERE XREF.ADDRESS_ID is null
	

	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET ADDRESS_ON_LOT = 'NTL'
	from [BDSAdmin].[MAR_METRIC_SUMMARY] NEED_VALID_XREF
	LEFT OUTER JOIN
		-- if there is at least one match for an address point this subquery will find it.
		(select MAR_SUMMARY.ADDRESS_ID
		FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
		INNER JOIN
			[ArcMap_Admin].[ADDRESS_PROPERTY_XREF] XREF
			ON MAR_SUMMARY.ADDRESS_ID = XREF.ADDRESS_ID
			WHERE EXISTS 
				(SELECT PROPERTY_ID 
				FROM [BDSAdmin].[MAR_REFERENCE_TAXLOTS] 
				WHERE XREF.PROPERTY_ID = PROPERTYID)) AT_LEAST_ONE_MATCH
	ON NEED_VALID_XREF.ADDRESS_ID = AT_LEAST_ONE_MATCH.ADDRESS_ID
	WHERE AT_LEAST_ONE_MATCH.ADDRESS_ID is null



	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET ADDRESS_ON_LOT = 'H20'
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	WHERE DATA_SOURCE = 'CGIS Marine addr'


	--------------- need to create a temp table to process H20 address points

	CREATE TABLE #TempTable (ADDRESS_ID INT)
	INSERT INTO #TempTable
	select ADDRESS_ID from 
	[ArcMap_Admin].[ADDRESSPDX] AP
	INNER JOIN
	[BDSAdmin].[MAR_REFERENCE_WATERBODY] H20
	ON AP.SHAPE.STIntersects(H20.SHAPE) = 1

	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET ADDRESS_ON_LOT = 'H20'
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	INNER JOIN
	#TempTable TT
	ON TT.ADDRESS_ID = MAR_SUMMARY.ADDRESS_ID

	DROP TABLE #TempTable


	-- set all address_on_lot to yes if they are located within one of the same tax lots they are associated with in the MAR
	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET ADDRESS_ON_LOT = 'YES'
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	INNER JOIN
	[ArcMap_Admin].[ADDRESS_PROPERTY_XREF] XREF
	ON MAR_SUMMARY.ADDRESS_ID = XREF.ADDRESS_ID
	INNER JOIN
	[BDSAdmin].[MAR_REFERENCE_TAXLOTS] TL
	ON XREF.PROPERTY_ID = TL.PROPERTYID
	WHERE geometry::Point(MAR_SUMMARY.MAR_X, MAR_SUMMARY.MAR_Y, 2913).STIntersects(TL.SHAPE) = 1

	--------------------------------------------------------------------------------------------------------------------------------------------
	-- carry over the address on lot onto discrepency table
	UPDATE [BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_TAXLOTCENTER_ADDRESSPOINT]
	SET ADDRESS_POINT_WITHIN_TAXLOT = SUMMARY.ADDRESS_ON_LOT
	FROM [BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_TAXLOTCENTER_ADDRESSPOINT] DIS_AP
	INNER JOIN 
	[BDSAdmin].[MAR_METRIC_SUMMARY] SUMMARY
	ON DIS_AP.ADDRESS_ID = SUMMARY.ADDRESS_ID


	---------------------------------------------------------------------------------------------------------------------------------------
	
	-- set the value to zero if it's null - this really only needs to be ran once, but it doesn't hurt anything.
	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  SET 
	[FEET_FROM_TAXLOT_CENTRIOD] = 0
	FROM  [BDSAdmin].[MAR_METRIC_SUMMARY] SUMMARY
	WHERE [FEET_FROM_TAXLOT_CENTRIOD] is null

	-- get distance from address point to MAR associated tax lot centroid
	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  SET 
	[FEET_FROM_TAXLOT_CENTRIOD] = AP_TL.[FEET_BETWEEN_POINTS]
	FROM  [BDSAdmin].[MAR_METRIC_SUMMARY] SUMMARY
	INNER JOIN 
	[BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_TAXLOTCENTER_ADDRESSPOINT] AP_TL
	ON AP_TL.ADDRESS_ID = SUMMARY.ADDRESS_ID
	

END
