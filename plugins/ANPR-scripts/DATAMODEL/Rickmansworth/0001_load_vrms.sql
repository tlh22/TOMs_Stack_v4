/*
Load from csv
*/

-- Now copy additional details into the VRMs table

COPY anpr."VRMs"("SiteID", "VRM", "InternationalCodeID", "CaptureTime", "Direction", "VehicleTypeID")
FROM 'C:\Users\Public\Documents\ADL2501_VRMs_CP04b_116.csv'
DELIMITER ','
CSV HEADER;


-- Now copy details into the VRMs table

COPY anpr."VRMs"("SiteID", "VRM", "InternationalCodeID", "CaptureTime", "Direction", "VehicleTypeID", "PermitTypeID")
FROM 'C:\Users\Public\Documents\ADL2501_VRMs_CP04b_116.csv'
DELIMITER ','
CSV HEADER;


/***

Need to check that:
 - opening/closing records are present
 - no records exist on day before opening records (as this creates duplicates)
 - 
 
 
 ***/