/*
    ** Ensure that SurveyAreas table is created (even if not populated)
*/

-- rename beats - will need to be specific to a report

UPDATE demand."Surveys"
SET "BeatTitle" = LPAD("SurveyID"::text, 3, '0') || ' - ' || LEFT("SurveyDay", 3) || ' - ' || 'Overnight'
WHERE MOD("SurveyID"-1, 100) = 0
AND "SurveyID" > 0;

UPDATE demand."Surveys"
SET "BeatTitle" = LPAD("SurveyID"::text, 3, '0') || ' - ' || LEFT("SurveyDay", 3) || ' - ' || "BeatStartTime" || '-' || "BeatEndTime"
WHERE MOD("SurveyID"-1, 100) > 0
AND "SurveyID" > 0;

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

--

SELECT d."SurveyID", d."BeatTitle", d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID",
d."RestrictionTypeID", 
d."RestrictionType Description",
d."UnacceptableType Description", 
d."RestrictionLength", d."RoadName", d."CPZ",
d."SupplyCapacity", d."CapacityAtTimeOfSurvey", ROUND(d."Demand"::numeric, 2) AS "Demand", 
CASE WHEN "SurveyID" IN (101, 201, 301) THEN to_char(d."DemandSurveyDateTime" + interval '0' hour, 'Dy DD Mon HH24:MI')
     ELSE to_char(d."DemandSurveyDateTime" + interval '0' hour, 'Dy DD Mon HH24:MI') 
	 END As "SurveyDateTime"

FROM
(SELECT ris."SurveyID", ris."GeometryID", ris."CapacityAtTimeOfSurvey", ris."Demand", ris."DemandSurveyDateTime",
 su."BeatTitle", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", s."RestrictionTypeID", s."RestrictionLength", s."SupplyCapacity",
 --s."RestrictionType Description",
 CASE WHEN LENGTH("UnacceptableType Description")>0 THEN CONCAT(s."RestrictionType Description", ' (', "UnacceptableType Description", ')')
     ELSE s."RestrictionType Description"
	 END AS "RestrictionType Description",
 s."UnacceptableType Description", s."RoadName", s."CPZ",
 "SurveyAreaName", 
 s."SupplyGeom"

FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, 
(
SELECT a."GeometryID", a."RestrictionTypeID", a."RestrictionLength", a."Capacity" AS "SupplyCapacity",
"UnacceptableTypes"."Description" AS "UnacceptableType Description", 
"BayLineTypes"."Description" AS "RestrictionType Description",
a."RoadName", a."SideOfStreet", a."CPZ", "SurveyAreas"."SurveyAreaName", 
 a.geom AS "SupplyGeom"
 FROM
(((  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
 ) AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND su."SurveyID" > 0
 --AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc

 ) as d
ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";
