/*
    ** Ensure that SurveyAreas table is created (even if not populated)
*/

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" AS RiS
SET "Photos_03" = RiS."Photos_03"
FROM mhtc_operations."Supply" a
	LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE RiS."GeometryID" = a."GeometryID"
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('E');

--



SELECT d."SurveyID"
, LPAD("SurveyID"::text, 3, '0') || '_' || REPLACE("SurveyDay", ' ', '') || '_' || "BeatStartTime" || '_' || "BeatEndTime" AS "BeatTitle"
, d."SurveyDay"
--to_char(d."SurveyDate", 'Day (DD Mon)') AS "SurveyDay",
--to_char(d."SurveyDate", 'Day') AS "SurveyDay",
, d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime"
, d."GeometryID"
, d."RestrictionTypeID", d."RestrictionType Description"
, d."UnacceptableType Description"
, d."RestrictionLength"
, d."RoadName"
, d."CPZ"
, d."SupplyCapacity", d."CapacityAtTimeOfSurvey", ROUND(d."Demand"::numeric, 2) AS "Demand", 
CASE WHEN "SurveyID" IN (101, 201, 301, 401) THEN to_char(d."DemandSurveyDateTime" + interval '1' hour, 'Dy DD Mon HH24:MI')
     ELSE to_char(d."DemandSurveyDateTime" + interval '0' hour, 'Dy DD Mon HH24:MI') 
	 END As "SurveyDateTime"

FROM
(SELECT ris."SurveyID", ris."GeometryID", ris."CapacityAtTimeOfSurvey", ris."Demand", ris."DemandSurveyDateTime",
 su."BeatTitle", su."SurveyDay", su."SurveyDate", su."BeatStartTime", su."BeatEndTime", s."RestrictionTypeID", s."RestrictionLength", s."SupplyCapacity",
 s."RestrictionType Description",
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
, "SouthwarkProposedDeliveryZones"."zonename" AS "SouthwarkProposedDeliveryZoneName"
 FROM
(
(((  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
 LEFT JOIN "import_geojson"."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid")
 ) AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND su."SurveyID" > 0
 --AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
 AND s."SouthwarkProposedDeliveryZoneName" = 'I'
 ) as d
ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";

