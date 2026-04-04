--

--  Join with Supply to ensure only current supply used ...

SELECT v."ID", v."SurveyID",
        v."GeometryID", 
        v."CPZ",
		v."VRM", 
		v."InternationalCodeID", 
		v."VehicleTypeID", 
        v."PermitTypeID", 
		v."ParkingActivityTypeID", 
		v."ParkingMannerTypeID", 
        v."Notes", 
        v."UserTypeID", 
		v."isLast", v."isFirst", v."orphan"

FROM demand."VRMs" v, mhtc_operations."Supply" s
WHERE v."GeometryID" = s."GeometryID"
AND v."SurveyID" > 0
AND s."RoadName"  IN ('Art School Car Park', 'Loreburn Street Car Park', 'White Sands Car Park', 'Brewery Street Car Park', 'Dock Park Car Park', 'Dockhead Car Park' )
  
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
--AND "CPZ" IN ('P', 'F', 'Y')
--AND (v."SurveyAreaName" LIKE 'L%' OR
--     v."SurveyAreaName" LIKE 'E-0%' OR
--     v."SurveyAreaName" LIKE 'P%' OR
--     v."SurveyAreaName" LIKE 'T%' OR
--     v."SurveyAreaName" LIKE 'V%'
--     )
ORDER BY "GeometryID", "VRM", "SurveyID"
