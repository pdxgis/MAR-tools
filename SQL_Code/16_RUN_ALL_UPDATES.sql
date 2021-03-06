USE [AddressPDX_Edit]
GO
/****** Object:  StoredProcedure [BDSAdmin].[MAR_RUN_ALL_UPDATES]    Script Date: 12/12/2014 8:18:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [BDSAdmin].[MAR_RUN_ALL_UPDATES]

AS
BEGIN

-- run ONCE
--EXEC MAR_METRIC_DELETE_RECREATE_METRICS_SUMMARY -- 2 minutes  

EXEC [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_ALL] -- 23 minutes
EXEC [BDSAdmin].[MAR_CLEANUP_LOG_INSERT] -- 5 seconds

EXEC [BDSAdmin].[MAR_BULK_UPDATE_1] -- 8 minutes (85k)     
EXEC [BDSAdmin].[MAR_BULK_UPDATE_2] -- 7 minutes (15k)

EXEC [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_ALL] -- 30 minutes
EXEC [BDSAdmin].[MAR_CLEANUP_LOG_INSERT] -- 5 seconds   -- running
 
EXEC [BDSAdmin].[MAR_BULK_UPDATE_3] -- 3 minutes (104k)
EXEC [BDSAdmin].[MAR_BULK_UPDATE_4] -- 6 minutes (66k)

EXEC [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_ALL] -- 30 minutes
EXEC [BDSAdmin].[MAR_CLEANUP_LOG_INSERT] -- 5 seconds


END


