import arcpy, datetime, time,urllib2,json
from time import sleep

def Run():
    print "Initiating..."
    ScratchFGDB = "//cgisproc1/MAR/SmartyStreets/SmartyStreets.gdb"
    SmartyStreets_Address_Points_WGS = ScratchFGDB + "/SmartyStreets_All_Metro_AP_WGS"

    insertCursor = arcpy.da.InsertCursor(SmartyStreets_Address_Points_WGS,("SHAPE@XY","ADDRESS_ID","input_id","input_index","candidate_index","addressee","delivery_line_1",
                                                                           "delivery_line_2","last_line","delivery_point_barcode","urbanization","primary_number","street_name",
                                                                           "street_predirection","street_postdirection","street_suffix","secondary_number","secondary_designator",
                                                                           "extra_secondary_number","extra_secondary_designator","pmb_designator","pmb_number","city_name",
                                                                           "default_city_name","state_abbreviation","zipcode","plus4_code","delivery_point","delivery_point_check_digit",
                                                                           "record_type","zip_type","county_fips","county_name","carrier_route","congressional_district",
                                                                           "building_default_indicator","rdi","elot_sequence","elot_sort","latitude","longitude","smarty_precision","time_zone",
                                                                           "utc_offset","dst","dpv_match_code","dpv_footnotes","dpv_cmra",
                                                                           "dpv_vacant","active","ews_match","footnotes","lacslink_code","lacslink_indicator","suitelink_match","JSON_RESPONSE"))

    

    SQL = "SELECT REPLACE(REPLACE(REPLACE([ADDRESS_FULL],'  ','%20'),' ','%20' ),'#','UNIT%20') + '&street2=&city=' + REPLACE(REPLACE(J.CITY,'  ','%20'),' ','%20' ) + '&state=OR&zipcode=&candidates=1', AP.ADDRESS_ID FROM [ArcMap_Admin].[ADDRESSPDX] AP INNER JOIN [ArcMap_Admin].[JURISDICTIONS] J ON J.JURISDICTION_ID = AP.JURISDICTION_ID where  ADDRESS_FULL not like '%/%' and ADDRESS_FULL not like '%-%'"
    sde_conn = arcpy.ArcSDESQLExecute(r"your_connection_file")
    sde_return = sde_conn.execute(SQL)
    count = 0
    print "Processing Results"
    for i in sde_return:
        
        ADDRESS_ID =  i[1]
        AddressString =  str(i[0])
        
        input_id = None
        input_index = None
        candidate_index = None
        addressee = None
        delivery_line_1 = None
        delivery_line_2 = None
        last_line = None
        delivery_point_barcode = None
        
        urbanization = None
        primary_number = None
        street_name = None
        street_predirection = None
        street_postdirection = None
        street_suffix = None
        secondary_number = None
        secondary_designator = None
        extra_secondary_number = None
        extra_secondary_designator = None
        pmb_designator = None
        pmb_number = None
        city_name = None
        default_city_name = None
        state_abbreviation = None
        zipcode = None
        plus4_code = None
        delivery_point = None
        delivery_point_check_digit = None
        
        record_type = None
        zip_type = None
        county_fips = None
        county_name = None
        carrier_route = None
        congressional_district = None
        building_default_indicator = None
        rdi = None
        elot_sequence = None
        elot_sort = None
        latitude = None
        longitude = None
        smarty_precision = None
        time_zone = None
        utc_offset = None
        dst = None

        dpv_match_code = None
        dpv_footnotes = None
        dpv_cmra = None
        dpv_vacant = None
        active = None
        ews_match = None
        footnotes = None
        lacslink_code = None
        lacslink_indicator = None
        suitelink_match = None
        
        try:
            url= "your_smarty_streets_url=" + AddressString
            print url
            count = count + 1
            Response = False



            
            try:
                response = urllib2.urlopen(url)
                jsongeocode = response.read()
                json_data = json.loads(jsongeocode)
            except Exception:
                print "Error: " + str(e.reason)

            if json_data:
                
                for item in json_data[0]:
                    if item == "input_id":
                        input_id = json_data[0]["input_id"]
                    if item == "input_index":
                        input_index = json_data[0]["input_index"]
                    if item == "candidate_index":
                        candidate_index = json_data[0]["candidate_index"]
                    if item == "addressee":
                        addressee = json_data[0]["addressee"]
                    if item == "delivery_line_1":
                        delivery_line_1 = json_data[0]["delivery_line_1"]
                    if item == "delivery_line_2":
                        delivery_line_2 = json_data[0]["delivery_line_2"]
                    if item == "last_line":
                        last_line = json_data[0]["last_line"]
                    if item == "delivery_point_barcode":
                        delivery_point_barcode = json_data[0]["delivery_point_barcode"]
                    if item == "components":
                        for component in json_data[0]["components"]:
                            if component == "urbanization":
                                urbanization = json_data[0]["components"]["urbanization"]
                            if component == "primary_number":
                                primary_number = json_data[0]["components"]["primary_number"]
                            if component == "street_name":
                                street_name = json_data[0]["components"]["street_name"]
                            if component == "street_predirection":
                                street_predirection = json_data[0]["components"]["street_predirection"]
                            if component == "street_postdirection":
                                street_postdirection = json_data[0]["components"]["street_postdirection"]
                            if component == "street_suffix":
                                street_suffix = json_data[0]["components"]["street_suffix"]
                            if component == "secondary_number":
                                secondary_number = json_data[0]["components"]["secondary_number"]
                            if component == "secondary_designator":
                                secondary_designator = json_data[0]["components"]["secondary_designator"]
                            if component == "extra_secondary_number":
                                extra_secondary_number = json_data[0]["components"]["extra_secondary_number"]
                            if component == "extra_secondary_designator":
                                extra_secondary_designator = json_data[0]["components"]["extra_secondary_designator"]                                 
                            if component == "pmb_designator":
                                pmb_designator = json_data[0]["components"]["pmb_designator"]
                            if component == "pmb_number":
                                pmb_number = json_data[0]["components"]["pmb_number"]
                            if component == "city_name":
                                city_name = json_data[0]["components"]["city_name"]
                            if component == "default_city_name":
                                default_city_name = json_data[0]["components"]["default_city_name"]
                            if component == "state_abbreviation":
                                state_abbreviation = json_data[0]["components"]["state_abbreviation"]
                            if component == "zipcode":
                                zipcode = json_data[0]["components"]["zipcode"]
                            if component == "plus4_code":
                                plus4_code = json_data[0]["components"]["plus4_code"]
                            if component == "delivery_point":
                                 delivery_point = json_data[0]["components"]["delivery_point"]
                            if component == "delivery_point_check_digit":
                                 delivery_point_check_digit = json_data[0]["components"]["delivery_point_check_digit"]

                    if item == "metadata":
                        for component in json_data[0]["metadata"]:
                            if component == "record_type":
                                record_type = json_data[0]["metadata"]["record_type"]            
                            if component == "zip_type":
                                zip_type = json_data[0]["metadata"]["zip_type"]
                            if component == "county_fips":
                                county_fips = json_data[0]["metadata"]["county_fips"]   
                            if component == "county_name":
                                county_name = json_data[0]["metadata"]["county_name"]   
                            if component == "carrier_route":
                                carrier_route = json_data[0]["metadata"]["carrier_route"]
                            if component == "congressional_district":
                                congressional_district = json_data[0]["metadata"]["congressional_district"]   
                            if component == "building_default_indicator":
                                building_default_indicator = json_data[0]["metadata"]["building_default_indicator"]   
                            if component == "rdi":
                                rdi = json_data[0]["metadata"]["rdi"]   
                            if component == "elot_sequence":
                                elot_sequence = json_data[0]["metadata"]["elot_sequence"]   
                            if component == "elot_sort":
                                elot_sort = json_data[0]["metadata"]["elot_sort"]   
                            if component == "latitude":
                                latitude = json_data[0]["metadata"]["latitude"]   
                            if component == "longitude":
                                longitude = json_data[0]["metadata"]["longitude"]   
                            if component == "precision":
                                smarty_precision = json_data[0]["metadata"]["precision"]
                            if component == "time_zone":
                                time_zone = json_data[0]["metadata"]["time_zone"]   
                            if component == "utc_offset":
                                utc_offset = json_data[0]["metadata"]["utc_offset"]
                            if component == "dst":
                                dst = json_data[0]["metadata"]["dst"]
                                
                    if item == "analysis":
                        for component in json_data[0]["analysis"]: 
                            if component == "dpv_match_code":
                                dpv_match_code = json_data[0]["analysis"]["dpv_match_code"]
                            if component == "dpv_footnotes":
                                dpv_footnotes = json_data[0]["analysis"]["dpv_footnotes"]
                            if component == "dpv_cmra":
                                dpv_cmra = json_data[0]["analysis"]["dpv_cmra"]
                            if component == "dpv_vacant":
                                dpv_vacant = json_data[0]["analysis"]["dpv_vacant"]
                            if component == "active":
                                active = json_data[0]["analysis"]["active"]
                            if component == "ews_match":
                                ews_match = json_data[0]["analysis"]["ews_match"]
                            if component == "footnotes":
                                footnotes = json_data[0]["analysis"]["footnotes"]
                            if component == "lacslink_code":
                                lacslink_code = json_data[0]["analysis"]["lacslink_code"]
                            if component == "lacslink_indicator":
                                lacslink_indicator = json_data[0]["analysis"]["lacslink_indicator"]                                
                            if component == "suitelink_match":
                                suitelink_match = json_data[0]["analysis"]["suitelink_match"]                                

    


                

                insertCursor.insertRow(((longitude,latitude),ADDRESS_ID,input_id,input_index,candidate_index,addressee,delivery_line_1,
                                       delivery_line_2,last_line,delivery_point_barcode,urbanization,primary_number,street_name,
                                       street_predirection,street_postdirection,street_suffix,secondary_number,secondary_designator,
                                       extra_secondary_number,extra_secondary_designator,pmb_designator,pmb_number,city_name,
                                       default_city_name,state_abbreviation,zipcode,plus4_code,delivery_point,delivery_point_check_digit,
                                       record_type,zip_type,county_fips,county_name,carrier_route,congressional_district,
                                       building_default_indicator,rdi,elot_sequence,elot_sort,latitude,longitude,smarty_precision,time_zone,
                                       utc_offset,dst,dpv_match_code,dpv_footnotes,dpv_cmra,
                                       dpv_vacant,active,ews_match,footnotes,lacslink_code,lacslink_indicator,suitelink_match,'YES'))
                
                print "Inserted Record " + str(count)

            else:
                insertCursor.insertRow(((longitude,latitude),ADDRESS_ID,input_id,input_index,candidate_index,addressee,delivery_line_1,
                                       delivery_line_2,last_line,delivery_point_barcode,urbanization,primary_number,street_name,
                                       street_predirection,street_postdirection,street_suffix,secondary_number,secondary_designator,
                                       extra_secondary_number,extra_secondary_designator,pmb_designator,pmb_number,city_name,
                                       default_city_name,state_abbreviation,zipcode,plus4_code,delivery_point,delivery_point_check_digit,
                                       record_type,zip_type,county_fips,county_name,carrier_route,congressional_district,
                                       building_default_indicator,rdi,elot_sequence,elot_sort,latitude,longitude,smarty_precision,time_zone,
                                       utc_offset,dst,dpv_match_code,dpv_footnotes,dpv_cmra,
                                       dpv_vacant,active,ews_match,footnotes,lacslink_code,lacslink_indicator,suitelink_match,'NO'))
        except Exception as e:
            print "   Error occurred in address processing"
            print e.message
    del insertCursor

    del sde_conn


    




Run()
