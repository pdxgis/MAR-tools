USE [AddressPDX_Edit]
GO
/****** Object:  StoredProcedure [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_SUMMARY]    Script Date: 12/5/2014 10:52:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_SUMMARY]

AS
BEGIN	

	--------------------------------------------------------------------------------------------------update summary info
	DELETE FROM [BDSAdmin].[MAR_METRIC_SUMMARY]

	-- get address points in table
	INSERT INTO [BDSAdmin].[MAR_METRIC_SUMMARY]
		(OBJECTID,ADDRESS_ID,[ADDRESS_DESCRIPTION],[MAR_X],[MAR_Y], ORIGINAL_X,ORIGINAL_Y,DATA_SOURCE)
	SELECT AP.OBJECTID
		  ,AP.ADDRESS_ID
		  ,AP.ADDRESS_FULL
		  ,AP.SHAPE.STX
		  ,AP.SHAPE.STY
		  ,AP.SHAPE.STX
		  ,AP.SHAPE.STY
		  ,AP.DATA_SOURCE
	  FROM [AddressPDX_Edit].[ArcMap_Admin].[ADDRESSPDX] AP
	  INNER JOIN [AddressPDX_Edit].[BDSAdmin].[MAR_ADDRESSING_JURISDICTION] BOUND ON AP.SHAPE.STIntersects(BOUND.SHAPE) = 1 where ADDRESS_ID is not null


END
