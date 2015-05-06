USE [AddressPDX_Edit]
GO

/****** Object:  Table [BDSAdmin].[MAR_CLEANUP_BURNDOWN_LOG]    Script Date: 11/12/2014 12:54:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP TABLE [BDSAdmin].[MAR_Cleanup_Burndown_Log]
CREATE TABLE [BDSAdmin].[MAR_Cleanup_Burndown_Log](
	[Date] [datetime] NULL,
	[Total_Addresses] [int] NULL,
	[Bulk_Edited_Addresses] [int] NULL,
	[Bulk_Edit_Rule_1] [int] NULL,
	[Bulk_Edit_Rule_2] [int] NULL,
	[Bulk_Edit_Rule_3] [int] NULL,
	[Bulk_Edit_Rule_4] [int] NULL,
	[Address_Accuracy_Score_0] [int] NULL,
	[Address_Accuracy_Score_1] [int] NULL,
	[Address_Accuracy_Score_2] [int] NULL,
	[Address_Accuracy_Score_3] [int] NULL,
	[Address_Accuracy_Score_4] [int] NULL,
	[Address_Accuracy_Score_5] [int] NULL,
	[Address_Accuracy_Score_6] [int] NULL,
	[Address_Accuracy_Score_7] [int] NULL,
	[Address_Accuracy_Score_8] [int] NULL,
	[Address_Accuracy_Score_9] [int] NULL,
	[Address_Accuracy_Score_10] [int] NULL,
	[Address_Score_Failing] [int] NULL,
	[Address_Score_Passing] [int] NULL,
	[Address_Point_Not_On_Lot] [int] NULL,
	[AP_Not_On_Associated_TL] [int] NULL,
	[AP_Not_On_Associated_Building] [int] NULL,
	[AP_StreetViolation_PDX] [int] NULL,
	[AP_StreetViolation_Google] [int] NULL,
	[AP_StreetViolation_SS] [int] NULL,
	[Address_Not_Valid_Mailing_SS] [int] NULL
) ON [PRIMARY]

GO


