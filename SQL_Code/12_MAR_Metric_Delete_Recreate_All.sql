USE [AddressPDX_Edit]
GO
/****** Object:  StoredProcedure [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_ALL]    Script Date: 9/25/2014 3:08:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_ALL]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	UPDATE [BDSAdmin].[MAR_METRIC_SUMMARY]  
	SET MAR_X = AP.SHAPE.STX, MAR_Y = AP.SHAPE.STY
	FROM [BDSAdmin].[MAR_METRIC_SUMMARY] MAR_SUMMARY
	INNER JOIN [AddressPDX_Edit].[ArcMap_Admin].[ADDRESSPDX] AP
	ON AP.ADDRESS_ID = MAR_SUMMARY.ADDRESS_ID   -- 15 seconds

  

    -------------------------------------------------------------------------------------------------center line info

	EXEC MAR_METRIC_DELETE_RECREATE_METRICS_CENTERLINE  -- takes 2 min 55 sesonds
   -------------------------------------------------------------------------------------------------building analysis

	EXEC MAR_METRIC_DELETE_RECREATE_METRICS_BUILDING   -- takes 1 minute 50 seconds

    ------------------------------------------------------------------------------------------------update tax lot info

	EXEC MAR_METRIC_DELETE_RECREATE_METRICS_TAXLOT  -- takes 2 minutes 20 seconds

	-------------------------------------------------------------------------------------------------update google info

	EXEC MAR_METRIC_DELETE_RECREATE_METRICS_GOOGLE   -- takes 20 seconds

	-------------------------------------------------------------------------------------------------update smarty streets info

	EXEC MAR_METRIC_DELETE_RECREATE_METRICS_SMARTY_STREETS  -- 1 minute

    -------------------------------------------------------------------------------------------------ranking address
	
	EXEC MAR_METRIC_DELETE_RECREATE_METRICS_ORIGINAL_LOCATION  -- 24 seconds

	-- rank addresses

	EXEC MAR_METRIC_RANK_ADDRESSES   -- 10 seconds


END
