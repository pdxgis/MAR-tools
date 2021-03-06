USE [AddressPDX_Edit]
GO
/****** Object:  StoredProcedure [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_ORIGINAL_LOCATION]    Script Date: 12/12/2014 10:38:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_ORIGINAL_LOCATION]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- update the summary with current location XY 
	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET MAR_X = AP.SHAPE.STX, MAR_Y = AP.SHAPE.STY
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	INNER JOIN [AddressPDX_Edit].[ArcMap_Admin].[ADDRESSPDX] AP
	ON AP.ADDRESS_ID = MAR_SUMMARY.ADDRESS_ID 



	DELETE FROM [BDSAdmin].[MAR_METRIC_ADDRESSPOINT_LOCATION_ORIGINAL_LOCATION]
	
	INSERT [BDSAdmin].[MAR_METRIC_ADDRESSPOINT_LOCATION_ORIGINAL_LOCATION]
		([OBJECTID],[ADDRESS_ID],POINT_X,POINT_Y,BULK_EDIT_1,BULK_EDIT_2,BULK_EDIT_3,BULK_EDIT_4,MANUAL_EDIT,SHAPE)
	SELECT 
	OBJECTID,
	ADDRESS_ID,
	MAR_X,
	MAR_Y,
	BULK_EDIT_1,
	BULK_EDIT_2,
	BULK_EDIT_3,
	BULK_EDIT_4,
	MANUAL_EDIT,
	geometry::Point(ORIGINAL_X,ORIGINAL_Y, 2913) SHAPE
	FROM  [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	WHERE MAR_X <> ORIGINAL_X and MAR_Y <> ORIGINAL_Y
	and (geometry::STLineFromText('LINESTRING(' +  convert(VARCHAR(16), MAR_X, 2)  + ' ' +convert(VARCHAR(16), MAR_Y, 2) + ', ' + convert(VARCHAR(16), ORIGINAL_X, 2)  + ' ' + convert(VARCHAR(16), ORIGINAL_Y, 2) + ')', 2913)).STLength() > .05
	and MAR_X is not null and  ORIGINAL_X is not null and   MAR_Y is not null and   ORIGINAL_Y is not null 
	order by (geometry::STLineFromText('LINESTRING(' +  convert(VARCHAR(16), MAR_X, 2)  + ' ' +convert(VARCHAR(16), MAR_Y, 2) + ', ' + convert(VARCHAR(16), ORIGINAL_X, 2)  + ' ' + convert(VARCHAR(16), ORIGINAL_Y, 2) + ')', 2913)).STLength() desc


	-------------------------------------------------------------------------------------------------------------
	-- process original location
	DELETE FROM [BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_ORIGINAL_LOCATION]
	
	INSERT [BDSAdmin].[MAR_METRIC_LOCATION_DISCREPANCY_ORIGINAL_LOCATION]
		([OBJECTID],[ADDRESS_ID],BULK_EDIT_1,BULK_EDIT_2,BULK_EDIT_3,BULK_EDIT_4,MANUAL_EDIT,MAR_ADDRESS,FEET_BETWEEN_POINTS,SHAPE)
	SELECT 
	OBJECTID,
	ADDRESS_ID,
	BULK_EDIT_1,
	BULK_EDIT_2,
	BULK_EDIT_3,
	BULK_EDIT_4,
	MANUAL_EDIT,
	ADDRESS_DESCRIPTION,
	--convert(VARCHAR(16), MAR_X, 2),
	--convert(VARCHAR(16), ORIGINAL_X, 2) ,
	--convert(VARCHAR(16), MAR_Y, 2),
	--convert(VARCHAR(16), ORIGINAL_Y, 2)
	(geometry::STLineFromText('LINESTRING(' +  convert(VARCHAR(16), MAR_X, 2)  + ' ' +convert(VARCHAR(16), MAR_Y, 2) + ', ' + convert(VARCHAR(16), ORIGINAL_X, 2)  + ' ' + convert(VARCHAR(16), ORIGINAL_Y, 2) + ')', 2913)).STLength() FEET_BETWEEN_POINTS,
	geometry::STLineFromText('LINESTRING(' +  convert(VARCHAR(16), MAR_X, 2)  + ' ' +convert(VARCHAR(16), MAR_Y, 2) + ', ' + convert(VARCHAR(16), ORIGINAL_X, 2)  + ' ' + convert(VARCHAR(16), ORIGINAL_Y, 2) + ')', 2913) SHAPE
	FROM  [BDSAdmin].[MAR_METRIC_SUMMARY] SUMMARY
	WHERE MAR_X <> ORIGINAL_X and MAR_Y <> ORIGINAL_Y
	and (geometry::STLineFromText('LINESTRING(' +  convert(VARCHAR(16), MAR_X, 2)  + ' ' +convert(VARCHAR(16), MAR_Y, 2) + ', ' + convert(VARCHAR(16), ORIGINAL_X, 2)  + ' ' + convert(VARCHAR(16), ORIGINAL_Y, 2) + ')', 2913)).STLength() > .05
	and MAR_X is not null and  ORIGINAL_X is not null and   MAR_Y is not null and   ORIGINAL_Y is not null 
	order by (geometry::STLineFromText('LINESTRING(' +  convert(VARCHAR(16), MAR_X, 2)  + ' ' +convert(VARCHAR(16), MAR_Y, 2) + ', ' + convert(VARCHAR(16), ORIGINAL_X, 2)  + ' ' + convert(VARCHAR(16), ORIGINAL_Y, 2) + ')', 2913)).STLength() desc

	UPDATE  [BDSAdmin].[MAR_METRIC_SUMMARY]
	SET 
	[FEET_MOVED] = ORIG_LOC.[FEET_BETWEEN_POINTS]
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] SUMMARY
	INNER JOIN 
	MAR_METRIC_LOCATION_DISCREPANCY_ORIGINAL_LOCATION ORIG_LOC
	ON SUMMARY.ADDRESS_ID = ORIG_LOC.ADDRESS_ID



END

