import Process_Google_Geocode_Results,arcpy,PDX_Email

# this serves as a heartbeat for you google query, the Process_Google_Geocode_Results only should process 100 features at a time...

Records_To_Process = True

while Records_To_Process:

    Google_SQL = "SELECT TOP 1 REPLACE(REPLACE([ADDRESS_FULL],'  ','+'),' ','+' ), AP.ADDRESS_ID FROM [ArcMap_Admin].[ADDRESSPDX] AP INNER JOIN [AddressPDX_Edit].[BDSAdmin].[MAR_METRIC_SUMMARY] AddSumm ON AP.ADDRESS_ID = AddSumm.ADDRESS_ID  where [GOOGLE_LOC_MATCH_TYPE] = 'Not Processed' and ADDRESS_FULL not like '%/%' ORDER BY ADDRESS_ACCURACY_SCORE DESC"
    sde_conn = arcpy.ArcSDESQLExecute(r"\\CGISPROC1\MAR\ConnectionFiles\BDS_Admin_GISDB1-AddressPDX_Edit.sde")
    sde_return = sde_conn.execute(Google_SQL)
    if isinstance(sde_return, list):
        Process_Google_Geocode_Results.Run()
        PDX_Email.SendEmail('your email','your email','Google Geocode Batch Processed','Google Geocode Batch Processed')
    else:
        Records_To_Process = False
