/*

Need to change for each CPZ - and ensure correct Supply details

*/

-- Ensure that details are updated
UPDATE "mhtc_operations"."Supply"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";


SELECT d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description", d."RoadName", --d."SideOfStreet",

--d."CPZ", d."SupplyCapacity", d."CapacityAtTimeOfSurvey", ROUND(d."Demand"::numeric, 2) AS "Demand", --d."SupplyCapacity_55m", d."CapacityAtTimeOfSurvey_55m", 
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."Notes", 
d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."SupplyCapacity", d."CapacityAtTimeOfSurvey", 
ROUND(d."Demand"::numeric, 2) AS "Demand", ROUND(d."Stress"::numeric, 2) AS "Stress",
COALESCE("SurveyAreaName", '') AS "SurveyAreaName", 
d."CPZ"
, d."PerceivedAvailableSpaces", d."PerceivedCapacityAtTimeOfSurvey", ROUND(d."PerceivedStress"::numeric, 2) AS "PerceivedStress"
FROM
(SELECT ris."SurveyID", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description", 
 s."RoadName", s."SideOfStreet", 
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", ris."SupplyCapacity", ris."CapacityAtTimeOfSurvey", ris."Demand",
ris."Stress", s."SurveyAreaName", ris."Notes",
 ris."PerceivedAvailableSpaces", ris."PerceivedCapacityAtTimeOfSurvey", ris."PerceivedStress"
 --, s."SurveyAreaName"
 , s."CPZ"
-- , ris."SupplyCapacity_55m", ris."CapacityAtTimeOfSurvey_55m"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su,
((mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

WHERE d."SurveyID" > 0
--AND d."Done" IS true
ORDER BY d."SurveyID", d."GeometryID";

-- check total count for each pass

/***
SELECT d."SurveyID", d."BeatTitle", SUM(d."NrBaysSuspended") AS "NrBaysSuspended", SUM(d."Capacity") AS "Capacity", SUM(v."Demand") As "Demand"
FROM
(SELECT ris."SurveyID", su."BeatTitle", s."GeometryID", ris."NrBaysSuspended", s."Capacity"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, mhtc_operations."Supply" s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID",
   SUM(CASE WHEN "VehicleTypeID" = 1 or "VehicleTypeID" = 2 or "VehicleTypeID" = 7 THEN 1.0  -- Car, LGV or Taxi
            WHEN "VehicleTypeID" = 3 THEN 0.4  -- MCL
            WHEN "VehicleTypeID" = 4 THEN 1.5  -- OGV
            WHEN "VehicleTypeID" = 5 THEN 2.0  -- Bus
            ELSE 1.0  -- Other or Null
      END) AS "Demand"
   FROM demand."VRMs"
   GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"
WHERE d."SurveyID" > 0
GROUP BY d."SurveyID", d."BeatTitle"
ORDER BY d."SurveyID";
***/

