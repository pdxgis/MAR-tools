USE [AddressPDX_Edit]
GO
/****** Object:  StoredProcedure [BDSAdmin].[MAR_CLEANUP_LOG_INSERT]    Script Date: 12/12/2014 10:27:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [BDSAdmin].[MAR_CLEANUP_LOG_INSERT]
AS
BEGIN
	INSERT INTO [BDSAdmin].[MAR_CLEANUP_BURNDOWN_LOG]
			   (Date
			   ,[Total_Addresses]
			   ,[Bulk_Edited_Addresses]
			   ,[Bulk_Edit_Rule_1]
			   ,[Bulk_Edit_Rule_2]
			   ,[Bulk_Edit_Rule_3]
			   ,[Bulk_Edit_Rule_4]
			   ,[Address_Accuracy_Score_0]
			   ,[Address_Accuracy_Score_1]
			   ,[Address_Accuracy_Score_2]
			   ,[Address_Accuracy_Score_3]
			   ,[Address_Accuracy_Score_4]
			   ,[Address_Accuracy_Score_5]
			   ,[Address_Accuracy_Score_6]
			   ,[Address_Accuracy_Score_7]
			   ,[Address_Accuracy_Score_8]
			   ,[Address_Accuracy_Score_9]
			   ,[Address_Accuracy_Score_10]
			   ,[Address_Score_Failing]
			   ,[Address_Score_Passing]
			   ,[Address_Point_Not_On_Lot]
			   ,[AP_Not_On_Associated_TL]
			   ,[AP_Not_On_Associated_Building]
			   ,[AP_StreetViolation_PDX]
			   ,[AP_StreetViolation_Google]
			   ,[AP_StreetViolation_SS]
			   ,[Address_Not_Valid_Mailing_SS])
		 VALUES
				(GETDATE(),
				(select count(*) 'Total Addresses' from [BDSAdmin].[MAR_METRIC_SUMMARY]),
				(select count(*)  'BDS EDIT MULT' from [BDSAdmin].[MAR_METRIC_SUMMARY] where DATA_SOURCE LIKE 'Bulk Edit'),
				(select count(*) 'MULT 1' from [BDSAdmin].[MAR_METRIC_SUMMARY] where BULK_EDIT_1 = 'BULK 1'),
				(select count(*) 'MULT 2' from [BDSAdmin].[MAR_METRIC_SUMMARY] where BULK_EDIT_2 = 'BULK 2'),
				(select count(*) 'MULT 3' from [BDSAdmin].[MAR_METRIC_SUMMARY] where BULK_EDIT_3 = 'BULK 3'),
				(select count(*) 'MULT 4' from [BDSAdmin].[MAR_METRIC_SUMMARY] where BULK_EDIT_4 = 'BULK 4'),

				(select count(*) 'Score 0 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 0),
				(select count(*) 'Score 1 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 1),
				(select count(*) 'Score 2 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 2),
				(select count(*) 'Score 3 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 3),
				(select count(*) 'Score 4 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 4),
				(select count(*) 'Score 5 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 5),
				(select count(*) 'Score 6 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 6),
				(select count(*) 'Score 7 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 7),
				(select count(*) 'Score 8 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 8),
				(select count(*) 'Score 9 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 9),
				(select count(*) 'Score 10 ' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] = 10),
				(select count(*) 'Failing' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] < 6),
				(select count(*) 'Passing' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [ADDRESS_ACCURACY_SCORE] > 5),
				(select count(*) 'Not On Tax Lot' from [BDSAdmin].[MAR_METRIC_SUMMARY] where ADDRESS_ON_LOT = 'NO'),
				(select count(*) 'No Tax Lot' from [BDSAdmin].[MAR_METRIC_SUMMARY] where ADDRESS_ON_LOT = 'NTL'),
				(select count(*) 'No Building' from [BDSAdmin].[MAR_METRIC_SUMMARY] where ADDRESS_ON_BLDG <> 'YES') ,
				(select count(*) 'Violate Centerline' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [CENTERLINE_STREET_CROSSED_COUNT] <> 0),
				(select count(*) 'Violate Google' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [GOOGLE_LOC_LOT_COUNT] <> 1),
				(select count(*) 'Violate SS Centerline' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [SMARTY_STREETS_STREET_COUNT] <> 0),
				(select count(*) 'Violate SS Mail' from [BDSAdmin].[MAR_METRIC_SUMMARY] where [SMARTY_STREETS_VALID_MAIL] <> 'Y'))

END

