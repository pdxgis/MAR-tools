USE [AddressPDX_Edit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [BDSAdmin].[MAR_BULK_UPDATE_4]

AS
BEGIN
	-- Conditions that must be met in order for the edit action to run
		--Address point is from data source 'MULT%' or 'USPS%'
		--Address point has a centerline/smarty street crossed count of zero
		--Address is located within a building footprint
		--Address is not assocated with building in XREF table


	--create temporary table - using a temporary table has performed much faster for this update
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
		BLDG_ID nvarchar(20),
		MAR_X numeric(38,8),
		MAR_Y numeric(38,8)
	)
	INSERT INTO TEMPTABLE
	select MS.ADDRESS_ID,
			MIN(BLDG.BLDG_ID),
			MIN(MS.MAR_X),
			MIN(MS.MAR_Y)
			from MAR_METRIC_SUMMARY MS
			INNER JOIN
			[BDSAdmin].[MAR_REFERENCE_BUILDINGS] BLDG
			ON geometry::Point(MS.MAR_X, MS.MAR_Y, 2913).STIntersects(BLDG.SHAPE) = 1
			INNER JOIN [ArcMap_Admin].[ADDRESS_PROPERTY_XREF] XREF_TL
			ON MS.ADDRESS_ID = XREF_TL.ADDRESS_ID  
			INNER JOIN [BDSAdmin].[MAR_REFERENCE_TAXLOTS] TL
			ON XREF_TL.PROPERTY_ID =  TL.PROPERTYID
			LEFT OUTER JOIN  [ArcMap_Admin].[ADDRESS_BUILDING_XREF] XREF
			ON MS.ADDRESS_ID = XREF.ADDRESS_ID
			where  (MS.DATA_SOURCE IN ('Bulk Edit','USPS Addr','MULT'))  and MS.BULK_EDIT_4 is null
			and (SMARTY_STREETS_STREET_COUNT = 0 or CENTERLINE_STREET_CROSSED_COUNT = 0) 
			and XREF.ADDRESS_ID is null
			GROUP BY MS.ADDRESS_ID

	--------------------------------------------------------------------------------------------------------------------------------------
	-- insert a value in the XREF table associating the address with the building
	INSERT INTO [ArcMap_Admin].[ADDRESS_BUILDING_XREF]
			   ([ADDRESS_ID]
			   ,[BLDG_ID]
			   ,[VERSION]
			   ,[ADD_DATE]
			   ,[ADD_USER])
				select ADDRESS_ID
				,BLDG_ID         
				,1
			   ,GETDATE()
			   ,8
				from TEMPTABLE TT





	update MAR_METRIC_SUMMARY
		   SET DATA_SOURCE = 'Bulk Edit', BULK_EDIT_4 = 'BULK 4'
		   FROM MAR_METRIC_SUMMARY SUMMARY
		   INNER JOIN
		   TEMPTABLE TT
		   ON TT.ADDRESS_ID = SUMMARY.ADDRESS_ID


	-- update the data source for the addresspdx - this just flags that the address points are no longer "stock"
	update [ArcMap_Admin].[ADDRESSPDX]
		   SET DATA_SOURCE =  AP.DATA_SOURCE + '4'
		   FROM [ArcMap_Admin].[ADDRESSPDX] AP
		   INNER JOIN
		   TEMPTABLE TT
		   ON TT.ADDRESS_ID = AP.ADDRESS_ID




	DROP TABLE TEMPTABLE
	--update complete we can drop the temporary table.

END


