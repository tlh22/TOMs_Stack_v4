
-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" AS RiS
SET "Photos_03" = RiS."Photos_03"
FROM mhtc_operations."Supply" a
	LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE RiS."GeometryID" = a."GeometryID"
--AND s."SurveyAreaID" = x
--AND a."SurveyAreaName" = 'y'
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I');

/***
SELECT su."SurveyID", "SurveyAreaName", SUM("Demand")
FROM demand."Surveys" su, demand."RestrictionsInSurveys" RiS,
(SELECT s."GeometryID", "SurveyAreas"."SurveyAreaName"
 FROM mhtc_operations."Supply" s LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code") AS d
WHERE su."SurveyID" = RiS."SurveyID"
AND d."GeometryID" = RiS."GeometryID"
AND su."SurveyID" > 0
GROUP BY su."SurveyID", "SurveyAreaName"
ORDER BY "SurveyAreaName", su."SurveyID"
***/
/***
SELECT RiS."SurveyID", SUM("Demand")
FROM demand."RestrictionsInSurveys" RiS
WHERE RiS."SurveyID" > 0
GROUP BY RiS."SurveyID"
ORDER BY RiS."SurveyID"


SELECT RiS."SurveyID", RiS."GeometryID", RiS."CapacityAtTimeOfSurvey", "TimePeriods"."Description"
FROM demand."RestrictionsInSurveys" RiS
, mhtc_operations."Supply" s
LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON s."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods" ON s."NoWaitingTimeID" is not distinct from "TimePeriods"."Code"

WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."GeometryID" = 'S_025161'
***/

/***

SELECT su."SurveyID", "SurveyAreaName", SUM("Demand")
FROM demand."Surveys" su, demand."RestrictionsInSurveys" RiS,
(SELECT s."GeometryID", "SurveyAreas"."SurveyAreaName"
 FROM mhtc_operations."Supply" s LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code") AS d
WHERE su."SurveyID" = RiS."SurveyID"
AND d."GeometryID" = RiS."GeometryID"
AND su."SurveyID" > 0
AND su."SurveyID" = 101
AND "SurveyAreaName" = 'N-03'
GROUP BY su."SurveyID", "SurveyAreaName"
ORDER BY "SurveyAreaName", su."SurveyID"

***/

/***

SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Demand_ALL", RiS."Demand", RiS."CapacityAtTimeOfSurvey", RiS."Stress"
	FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" a
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
		LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code"
	WHERE RiS."GeometryID" = a."GeometryID"
	AND RiS."SurveyID" = 102
	AND "SurveyAreaName" = 'O-07'
	
***/