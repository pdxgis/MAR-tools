USE [AddressPDX_Edit]
GO
/****** Object:  StoredProcedure [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_BUILDING]    Script Date: 9/9/2014 9:10:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_BUILDING]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		
	-- refresh building analysis
	DELETE FROM [BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_BUILDINGCENTER_ADDRESSPOINT]
	
	INSERT [BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_BUILDINGCENTER_ADDRESSPOINT]
		([OBJECTID],[ADDRESS_ID],[BLDG_ID],FEET_BETWEEN_POINTS,SHAPE,ADDRESS_POINT_WITHIN_BUILDING,BLDG_TYPE)
	SELECT 
	BLDG.OBJECTID,
	MAX(XREF.ADDRESS_ID),
	MAX(XREF.BLDG_ID),

	(geometry::STLineFromText('LINESTRING(' + str(MAX(SUMMARY.MAR_X),15,5)  + ' ' + str(MAX(SUMMARY.MAR_Y),15,5) + ', ' + str(MAX(BLDG.SHAPE.STCentroid().STX),15,5)  + ' ' +  str(MAX(BLDG.SHAPE.STCentroid().STY) ,15,5) + ')', 2913)).STLength() FEET_BETWEEN_POINTS,
	geometry::STLineFromText('LINESTRING(' + str(MAX(SUMMARY.MAR_X),15,5)  + ' ' + str(MAX(SUMMARY.MAR_Y),15,5) + ', ' + str(MAX(BLDG.SHAPE.STCentroid().STX),15,5)  + ' ' +  str(MAX(BLDG.SHAPE.STCentroid().STY) ,15,5) + ')', 2913) SHAPE,
	(CASE WHEN 
		geometry::Point(MAX(SUMMARY.MAR_X), MAX(SUMMARY.MAR_Y), 2913).STIntersects(geometry::STPolyFromText(MAX(SHAPE.ToString()), 2913)) = 1 
		THEN
			'YES'  
		ELSE
			'NO'
	END)  ADDRESS_POINT_WITHIN_BLDG,
	MAX(BLDG.BLDG_TYPE)
	FROM [ArcMap_Admin].[ADDRESS_BUILDING_XREF] XREF
	INNER JOIN [BDSAdmin].[MAR_METRIC_SUMMARY] SUMMARY 
	ON XREF.ADDRESS_ID = SUMMARY.ADDRESS_ID
	INNER JOIN [BDSAdmin].[MAR_REFERENCE_BUILDINGS] BLDG
	ON XREF.BLDG_ID = BLDG.BLDG_ID
	WHERE geometry::Point(SUMMARY.MAR_X, SUMMARY.MAR_Y, 2913).STDistance(BLDG.SHAPE.STCentroid()) > .001 and BLDG.BLDG_ID not like '' and BLDG.BLDG_TYPE <> 'Garage'
	GROUP BY BLDG.OBJECTID

	-- check to see if address point is on building, what building

	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET SPATIAL_BLDG_ID = BLDG.BLDG_ID, 
		ADDRESS_ON_BLDG = (CASE WHEN BLDG.BLDG_ID is not Null THEN  'YES'  ELSE 'NO' END)
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	LEFT OUTER JOIN 
	   [BDSAdmin].[MAR_REFERENCE_BUILDINGS] BLDG
	ON
	   geometry::Point(MAR_SUMMARY.MAR_X, MAR_SUMMARY.MAR_Y, 2913).STIntersects(BLDG.SHAPE) = 1 

	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET ADDRESS_ON_BLDG = 'NA'
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	LEFT OUTER JOIN
	[ArcMap_Admin].[ADDRESS_BUILDING_XREF] XREF
	ON MAR_SUMMARY.ADDRESS_ID = XREF.ADDRESS_ID
	WHERE XREF.ADDRESS_ID is null


END
