/*
    ** Ensure that SurveyAreas table is created (even if not populated) 
*/

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" AS RiS
SET "Photos_03" = RiS."Photos_03"
FROM mhtc_operations."Supply" a
	LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE RiS."GeometryID" = a."GeometryID"
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('M');

---

-- Unsure beat title is correct

/***
UPDATE demand."Surveys"
--SET "BeatTitle" = LPAD("SurveyID"::text, 3, '0') || '_' || "SurveyDay" || '_' || "BeatStartTime" || '_' || "BeatEndTime"
SET "BeatTitle" = LPAD("SurveyID"::text, 3, '0') || '_' || to_char("SurveyDate", 'Dy_DD_Mon') || '_' || "BeatStartTime" || '_' || "BeatEndTime"
--WHERE "BeatTitle" IS NULL
;
***/

---

SELECT d."SurveyID"
, LPAD("SurveyID"::text, 3, '0') || '_' || REPLACE("SurveyDay", ' ', '') || '_' || "BeatStartTime" || '_' || "BeatEndTime"
 AS "BeatTitle"
, d."GeometryID"
, d."RestrictionTypeID"
, d."RestrictionType Description"
, d."RoadName",
d."DemandSurveyDateTime"
, d."Enumerator"
, d."Done"
, CONCAT('"', d."Notes", '"') AS "Notes",
d."SuspensionReference"
, d."SuspensionReason"
, d."SuspensionLength"
, d."NrBaysSuspended", CONCAT('"',d."SuspensionNotes",'"') AS "SuspensionNotes"
, d."Photos_01", d."Photos_02", d."Photos_03"
, d."SupplyCapacity"
, d."CapacityAtTimeOfSurvey"
, ROUND(d."Demand"::numeric, 2) AS "Demand", ROUND(d."Stress"::numeric, 2) AS "Stress"
, d."CPZ"
, d."PerceivedAvailableSpaces"
, d."PerceivedCapacityAtTimeOfSurvey"
, ROUND(d."PerceivedStress"::numeric, 2) AS "PerceivedStress"
--    d."NrCars", d."NrLGVs", d."NrMCLs", d."NrTaxis", d."NrPCLs", d."NrEScooters", d."NrDocklessPCLs", 
--    d."NrOGVs", d."NrMiniBuses", d."NrBuses", d."NrSpaces", d."Notes"
, COALESCE("SouthwarkProposedDeliveryZoneName", '') AS "SouthwarkProposedDeliveryZoneName"
, d."TheoreticalCapacityAtTimeOfSurvey"
FROM
(SELECT ris."SurveyID", su."BeatTitle", su."SurveyDay", su."BeatStartTime", su."BeatEndTime"
, ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description",
 s."RoadName", s."CPZ", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength",
 "NrBaysSuspended", "SuspensionNotes",
 ris."Photos_01", ris."Photos_02", ris."Photos_03", s."Capacity" AS "SupplyCapacity", ris."CapacityAtTimeOfSurvey", ris."TheoreticalCapacityAtTimeOfSurvey", ris."Demand",
 ris."Stress", "SurveyAreaName", c."Notes",
 ris."PerceivedAvailableSpaces", ris."PerceivedCapacityAtTimeOfSurvey", ris."PerceivedStress" 
--     ris."NrCars", ris."NrLGVs", ris."NrMCLs", ris."NrTaxis", ris."NrPCLs", ris."NrEScooters", ris."NrDocklessPCLs", 
--     ris."NrOGVs", ris."NrMiniBuses", ris."NrBuses", ris."NrSpaces", ris."Notes",
, COALESCE(s."zonename", '')  AS "SouthwarkProposedDeliveryZoneName"

FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, demand."Counts" c,
(((
  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") AS s

 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND ris."SurveyID" = c."SurveyID"
 AND ris."GeometryID" = c."GeometryID"
 AND su."SurveyID" > 0
 AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
 -- AND s."RestrictionTypeID" IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc  ** Use when selecting MCL/PCL bays
 --AND s."CPZ" = '7S'

 ) as d
WHERE d."SouthwarkProposedDeliveryZoneName" IN ('J')
ORDER BY d."RestrictionTypeID", d."GeometryID", d."SurveyID";