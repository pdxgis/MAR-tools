USE [AddressPDX_Edit]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [BDSAdmin].[MAR_BULK_UPDATE_3]

AS
BEGIN

	-- Conditions that must be met in order for the edit action to run
		--Address point is from data source 'MULT%' or 'USPS%'
		--Address point has a centerline/smarty street crossed count of zero
		--Address is located within tax lot
		--Address is not assocated with tax lot in XREF table

	--Edit action: Associate address point with tax lot  in XREF table

	--create temporary table - using a temporary table has performed much faster for this update

	EXEC [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_TAXLOT]

	IF (EXISTS (SELECT * 
					 FROM INFORMATION_SCHEMA.TABLES 
					 WHERE TABLE_SCHEMA = 'BDSAdmin' 
					 AND  TABLE_NAME = 'TEMPTABLE'))
	BEGIN
		DROP TABLE TEMPTABLE
	END

	--create temporary table - using a temporary table has performed much faster for this update
	CREATE TABLE TEMPTABLE
	(
		ADDRESS_ID int,
		PROPERTY_ID varchar(10),
		MAR_X numeric(38,8),
		MAR_Y numeric(38,8)
	)
	INSERT INTO TEMPTABLE
	select MS.ADDRESS_ID,TL.PROPERTYID,MS.MAR_X,MS.MAR_Y
	from MAR_METRIC_SUMMARY MS
	INNER JOIN [BDSAdmin].[MAR_REFERENCE_TAXLOTS] TL
	ON geometry::Point(MS.MAR_X, MS.MAR_Y, 2913).STIntersects(TL.SHAPE) = 1 
	where (MS.DATA_SOURCE IN ('Bulk Edit','USPS Addr','MULT')) and 
	  MS.BULK_EDIT_3 is null and (SMARTY_STREETS_STREET_COUNT = 0 or CENTERLINE_STREET_CROSSED_COUNT = 0)
	and TL.PROPERTYID is not null and 
	(MS.ADDRESS_ON_LOT = 'NTL' or MS.ADDRESS_ON_LOT = 'NA' )
	--gets you all the USPS addresses that are located on lots, don't violate centerline and are not in the cross reference table for tax lots 


	---------------------------------------------------------------------------------------------------------------------------------------------------
	-- insert a value in the XREF table associating the address with the tax lot.  
	INSERT INTO [ArcMap_Admin].[ADDRESS_PROPERTY_XREF]
			   ([ADDRESS_ID],[PROPERTY_ID],[ACCOUNT_STATUS_CODE],[VERSION],[ADD_DATE],[ADD_USER])
				select ADDRESS_ID,PROPERTY_ID,'A',1,GETDATE(),8
				FROM TEMPTABLE TT WHERE NOT EXISTS (SELECT ADDRESS_ID,PROPERTY_ID 
				 FROM [ArcMap_Admin].[ADDRESS_PROPERTY_XREF] XREF WHERE 
				 TT.ADDRESS_ID = XREF.ADDRESS_ID and TT.PROPERTY_ID = XREF.PROPERTY_ID )

	------------------------------------------------------------------------------------------------------------

	update MAR_METRIC_SUMMARY
		   SET DATA_SOURCE = 'Bulk Edit', BULK_EDIT_3 = 'BULK 3'
		   FROM MAR_METRIC_SUMMARY SUMMARY
		   INNER JOIN 
	(select ADDRESS_ID
	from TEMPTABLE) USPS_Associate
	ON SUMMARY.ADDRESS_ID = USPS_Associate.ADDRESS_ID

	-- update the data source for the addresspdx - this just flags that the address points are no longer "stock"
	update [ArcMap_Admin].[ADDRESSPDX]
		   SET DATA_SOURCE =  AP.DATA_SOURCE + '3'
		   FROM [ArcMap_Admin].[ADDRESSPDX] AP
		   INNER JOIN 
	(select ADDRESS_ID
	from TEMPTABLE) USPS_Associate
	ON AP.ADDRESS_ID = USPS_Associate.ADDRESS_ID

	------------------------------------------------------------------------------------------------------------

	DROP TABLE TEMPTABLE
	--update complete we can drop the temporary table.

END


