/***

Get opening/closing details from manual survey

***/


SELECT NULL AS "SiteID", REPLACE("VRM", '-', '') AS "VRM", "InternationalCodeID", "DemandSurveyDateTime" AS "CaptureTime", NULL AS "Direction", "VehicleTypeID", "PermitTypeID"
FROM demand."VRMs" v, demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE v."GeometryID" = s."GeometryID"
AND v."SurveyID" = su."SurveyID"
AND v."SurveyID" = RiS."SurveyID"
AND v."GeometryID" = RiS."GeometryID"
AND v."SurveyID" IN (101, 201, 301)
AND s."RoadName" LIKE '%Upper%'


SELECT NULL AS "SiteID", REPLACE("VRM", '-', '') AS "VRM", "InternationalCodeID", "DemandSurveyDateTime" AS "CaptureTime", NULL AS "Direction", "VehicleTypeID", "PermitTypeID"
FROM demand."VRMs" v, demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE v."GeometryID" = s."GeometryID"
AND v."SurveyID" = su."SurveyID"
AND v."SurveyID" = RiS."SurveyID"
AND v."GeometryID" = RiS."GeometryID"
AND v."SurveyID" IN (116, 216, 316)
AND s."RoadName" LIKE '%Upper%'
