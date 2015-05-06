import arcpy, datetime, time,urllib2,json
from time import sleep

def Run():

    ScratchFGDB = "D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb"
    Google_Address_Points = ScratchFGDB + "/Google_Address"
    Projected_Google_Address_Points = ScratchFGDB +  "/Projected_Google_Address"
    Project_Google_In_Jurisdiction = ScratchFGDB +  "/Projected_Google_In_Jurisdiction"

    Address_Jurisdiction = r"your_connection_file\AddressPDX_EDIT.BDSADMIN.MAR_Addressing_Jurisdiction"
    MAR_Metric_AddressPoint_Location_Google = r"your_connection_file\AddressPDX_EDIT.BDSADMIN.MAR_Metric_AddressPoint_Location_Google"
    MAR_Metric_Address_Not_Found = r"your_connection_file\AddressPDX_EDIT.BDSADMIN.MAR_Metric_Address_Not_Found"

    arcpy.DeleteFeatures_management(Google_Address_Points)
    if arcpy.Exists(Projected_Google_Address_Points):
        arcpy.Delete_management(Projected_Google_Address_Points)
    if arcpy.Exists(Project_Google_In_Jurisdiction):
        arcpy.Delete_management(Project_Google_In_Jurisdiction)


    insertCursor = arcpy.da.InsertCursor(Google_Address_Points,("SHAPE@XY","ADDRESS_ID", "lat", "lng", "northeast_lat", "northeast_lng","southwest_lat","southwest_lng","types","formatted_address","street_number_long","street_number_short"
                                                                ,"route_long","route_short","neighborhood_long","neighborhood_short","locality_long","locality_short","county_long","county_short","post_code","location_type"))


    Google_SQL = "SELECT  TOP 100 REPLACE(REPLACE(CASE WHEN  CHARINDEX('APT',SUMMARY.ADDRESS_DESCRIPTION) <> 0 THEN LEFT(SUMMARY.ADDRESS_DESCRIPTION, CHARINDEX('APT',ADDRESS_DESCRIPTION)-2)  WHEN  CHARINDEX('#',SUMMARY.ADDRESS_DESCRIPTION) <> 0 THEN LEFT(SUMMARY.ADDRESS_DESCRIPTION, CHARINDEX('#',ADDRESS_DESCRIPTION)-2) WHEN  CHARINDEX('UNIT',SUMMARY.ADDRESS_DESCRIPTION) <> 0 THEN LEFT(SUMMARY.ADDRESS_DESCRIPTION, CHARINDEX('UNIT',ADDRESS_DESCRIPTION)-2)  WHEN  CHARINDEX(' STE ',SUMMARY.ADDRESS_DESCRIPTION) <> 0 THEN LEFT(SUMMARY.ADDRESS_DESCRIPTION, CHARINDEX(' STE ',ADDRESS_DESCRIPTION)-1) WHEN  CHARINDEX('SLIP',SUMMARY.ADDRESS_DESCRIPTION) <> 0 THEN LEFT(SUMMARY.ADDRESS_DESCRIPTION, CHARINDEX('SLIP',ADDRESS_DESCRIPTION)-2) WHEN  CHARINDEX(' UN ',SUMMARY.ADDRESS_DESCRIPTION) <> 0 THEN LEFT(SUMMARY.ADDRESS_DESCRIPTION, CHARINDEX(' UN ',ADDRESS_DESCRIPTION)-1) WHEN  CHARINDEX(' UN ',SUMMARY.ADDRESS_DESCRIPTION) <> 0 THEN LEFT(SUMMARY.ADDRESS_DESCRIPTION, CHARINDEX(' UN ',ADDRESS_DESCRIPTION)-1) WHEN  CHARINDEX('-',SUMMARY.ADDRESS_DESCRIPTION) <> 0 THEN LEFT(SUMMARY.ADDRESS_DESCRIPTION, CHARINDEX('-',ADDRESS_DESCRIPTION)-1) +  ' ' +RIGHT(RIGHT(SUMMARY.ADDRESS_DESCRIPTION, (LEN(SUMMARY.ADDRESS_DESCRIPTION)-CHARINDEX('-',ADDRESS_DESCRIPTION))), LEN(SUMMARY.ADDRESS_DESCRIPTION)-CHARINDEX(' ',ADDRESS_DESCRIPTION))  ELSE  ADDRESS_DESCRIPTION END ,'  ','+'),' ','+' ) + '+' + REPLACE(MAIL.MAIL_CITY, ' ', '+') + '+OR'  Street_String, SUMMARY.ADDRESS_ID FROM [BDSAdmin].[MAR_METRIC_SUMMARY] SUMMARY INNER JOIN [ArcMap_Admin].[ADDRESSPDX] AP ON SUMMARY.ADDRESS_ID = AP.ADDRESS_ID INNER JOIN [ArcMap_Admin].[ADDRESS_MAILCITY] MAIL ON MAIL.[ZIP_CODE] = AP.[ZIP_CODE] where [GOOGLE_LOC_MATCH_TYPE] = 'Not Processed' and ADDRESS_FULL not like '%/%' and ADDRESS_FULL not like '%&%' and ADDRESS_FULL not like '%-%'  ORDER BY ADDRESS_ACCURACY_SCORE ASC"
    sde_conn = arcpy.ArcSDESQLExecute(r"your_connection_file")
    sde_return = sde_conn.execute(Google_SQL)
    count = 0
    for i in sde_return:
        AddressString =  i[0] 
        ADDRESS_ID =  i[1]
        
        try:
            url= "https://maps.googleapis.com/maps/api/geocode/json?address=" + AddressString
            print url
            count = count + 1
            Google_Response = False
            #Example:   http://maps.googleapis.com/maps/api/geocode/json?address=1+SW+RICHARDSON+ST,+PORTLAND,+OR
            try:
                response = urllib2.urlopen(url)
                jsongeocode = response.read()
                json_data = json.loads(jsongeocode)
                Google_Response = json_data["status"]
            except Exception as e:
                print "Error: Other " + str(e.reason)


            if Google_Response == "OK":
                lat =  json_data["results"][0]["geometry"]["location"]["lat"]
                lng =  json_data["results"][0]["geometry"]["location"]["lng"]
                location_type =  json_data["results"][0]["geometry"]["location_type"]
                northeast_lat =  json_data["results"][0]["geometry"]["viewport"]["northeast"]["lat"]
                northeast_lng =  json_data["results"][0]["geometry"]["viewport"]["northeast"]["lng"]
                southwest_lat =  json_data["results"][0]["geometry"]["viewport"]["southwest"]["lat"]
                southwest_lng =  json_data["results"][0]["geometry"]["viewport"]["southwest"]["lng"]
                types = None
                try:
                    types = json_data["results"][0]["types"][0]
                except:
                    types = None
                try:
                    if json_data["partial_match"][0]["types"][0]:
                        partial_match = 'True'
                        #print "Partial Response"
                except:
                    pass
                    #print "Full response"
                try:
                    formatted_address =  json_data["results"][0]["formatted_address"]
                except:
                    formatted_address = None

                # null our varaibles
                street_number_long = None
                street_number_short = None
                route_long = None
                route_short = None
                neighborhood_long = None
                neighborhood_short = None
                locality_long = None
                locality_short = None
                county_long = None
                county_short = None
                post_code = None
                for dictionary in json_data["results"][0]["address_components"]:
                    try:
                        #print dictionary["types"][0]
                        if dictionary["types"][0] == "street_number":
                            street_number_long = dictionary["long_name"]
                            street_number_short = dictionary["short_name"]
                        elif dictionary["types"][0] == "route":
                            route_long = dictionary["long_name"]
                            route_short = dictionary["short_name"]
                        elif dictionary["types"][0] == "neighborhood":
                            neighborhood_long = dictionary["long_name"]
                            neighborhood_short = dictionary["short_name"]
                        elif dictionary["types"][0] == "locality":
                            locality_long = dictionary["long_name"]
                            locality_short = dictionary["short_name"]
                        elif dictionary["types"][0] == "administrative_area_level_2":
                            county_long = dictionary["long_name"]
                            county_short = dictionary["short_name"]
                        elif dictionary["types"][0] == "postal_code":
                            post_code = dictionary["long_name"]
                    except Exception as e:
                        print "Error: dictionary errror " + str(e.message)
 
                
                try:
                    insertCursor.insertRow(((lng,lat),ADDRESS_ID,lat,lng,northeast_lat,northeast_lng,southwest_lat,southwest_lng,types,formatted_address,street_number_long,street_number_short,route_long,route_short,neighborhood_long,
                                            neighborhood_short,locality_long,locality_short,county_long,county_short,post_code,location_type))
                    print "Inserted Record " + str(count)
                except Exception as e:
                    print "   Error inserting results"
                    print e.message
            elif json_data["status"] == "OVER_QUERY_LIMIT":
                print "Over query limit need to time out for 60 minutes and try again.  Note this should not happen"
                sleep(3600)
            else:
                print "   Address did not return valid results"
                print address
        except Exception as e:
            print "   Error occurred in address processing"
            print e.message
        sleep(35)  # sleep for 35 seconds because google only allows 2500 queries a day
    del insertCursor

    #project feature class

    arcpy.Project_management(Google_Address_Points,Projected_Google_Address_Points,"PROJCS['NAD_1983_HARN_StatePlane_Oregon_North_FIPS_3601_Feet_Intl',GEOGCS['GCS_North_American_1983_HARN',DATUM['D_North_American_1983_HARN',SPHEROID['GRS_1980',6378137.0,298.257222101]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Lambert_Conformal_Conic'],PARAMETER['false_easting',8202099.737532808],PARAMETER['false_northing',0.0],PARAMETER['central_meridian',-120.5],PARAMETER['standard_parallel_1',44.33333333333334],PARAMETER['standard_parallel_2',46.0],PARAMETER['latitude_of_origin',43.66666666666666],UNIT['Foot',0.3048]]","NAD_1983_HARN_To_WGS_1984_2","GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]]")

    arcpy.SpatialJoin_analysis(Projected_Google_Address_Points,
                               Address_Jurisdiction,
                               Project_Google_In_Jurisdiction,"JOIN_ONE_TO_ONE","KEEP_ALL",
                               """ADDRESS_ID "ADDRESS_ID" true true false 4 Long 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,ADDRESS_ID,-1,-1;
                                lat "lat" true true false 8 Double 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,lat,-1,-1;
                                lng "lng" true true false 8 Double 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,lng,-1,-1;
                                northeast_lat "northeast_lat" true true false 8 Double 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,northeast_lat,-1,-1;
                                northeast_lng "northeast_lng" true true false 8 Double 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,northeast_lng,-1,-1;
                                southwest_lat "southwest_lat" true true false 8 Double 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,southwest_lat,-1,-1;
                                southwest_lng "southwest_lng" true true false 8 Double 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,southwest_lng,-1,-1;
                                types "types" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,types,-1,-1;
                                formatted_address "formatted_address" true true false 100 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,formatted_address,-1,-1;
                                street_number_long "street_number_long" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,street_number_long,-1,-1;
                                street_number_short "street_number_short" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,street_number_short,-1,-1;
                                route_long "route_long" true true false 100 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,route_long,-1,-1;
                                route_short "route_short" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,route_short,-1,-1;
                                neighborhood_long "neighborhood_long" true true false 100 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,neighborhood_long,-1,-1;
                                neighborhood_short "neighborhood_short" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,neighborhood_short,-1,-1;
                                locality_long "locality_long" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,locality_long,-1,-1;
                                locality_short "locality_short" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,locality_short,-1,-1;
                                county_long "county_long" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,county_long,-1,-1;
                                county_short "county_short" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,county_short,-1,-1;
                                post_code "post_code" true true false 255 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,post_code,-1,-1;
                                location_type "location_type" true true false 50 Text 0 0 ,First,#,D:/MAR/GoogleMaps/GoogleAddressProcessing.gdb/Projected_Google_Address,location_type,-1,-1""","INTERSECT","#","#")

    Google_Insert_Fields = ["ADDRESS_ID","lat","lng","northeast_lat","northeast_lng","southwest_lat","southwest_lng","types","formatted_address","street_number_long","street_number_short"
                            ,"route_long","route_short","neighborhood_long","neighborhood_short","locality_long","locality_short","county_long","county_short","post_code","location_type","SHAPE@"]

    Google_Search_Fields = ["ADDRESS_ID","lat","lng","northeast_lat","northeast_lng","southwest_lat","southwest_lng","types","formatted_address","street_number_long","street_number_short"
                            ,"route_long","route_short","neighborhood_long","neighborhood_short","locality_long","locality_short","county_long","county_short","post_code","location_type","SHAPE@","Join_Count",]

    Google_SDE_IC = arcpy.da.InsertCursor(MAR_Metric_AddressPoint_Location_Google, Google_Insert_Fields)

    Not_Found_I_Cursor = arcpy.da.InsertCursor(MAR_Metric_Address_Not_Found,("ADDRESS_ID","ADDRESS_DESCRIPTION","NOTES","SOURCE_IN_WHICH_NOT_FOUND"))


    # Delete cursor object

    with arcpy.da.SearchCursor(Project_Google_In_Jurisdiction, Google_Search_Fields, "types = 'street_address' OR types = 'subpremise' OR types = 'premise' OR types = 'park'") as cursor:
        for row in cursor:
            if row[22] > 0:  # if join count is > 0 or if the point is in the jurisdiction
                Google_SDE_IC.insertRow((row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[9],row[10],row[11],row[12],row[13],row[14],row[15],row[16],row[17],row[18],row[19],row[20],row[21]))
                print "Added row"
    del Google_SDE_IC


    with arcpy.da.SearchCursor(Project_Google_In_Jurisdiction, ["ADDRESS_ID","Join_Count","types"],"Join_Count = 0 or types <>'street_address' AND types <> 'subpremise' AND types <> 'premise' AND types <> 'park'") as cursor:
        for row in cursor:
            print "not a valid record adding details"
            if row[1] == 0:
                Not_Found_I_Cursor.insertRow((row[0],None,"Outside Jurisdiction","Google Maps"))
            else:
                Notes = "Match Type- " + str(row[2])
                Not_Found_I_Cursor.insertRow((row[0],None,Notes,"Google Maps"))
     
    sde_return = sde_conn.execute("EXEC [BDSAdmin].[MAR_METRIC_DELETE_RECREATE_METRICS_GOOGLE] ")

    del sde_conn


