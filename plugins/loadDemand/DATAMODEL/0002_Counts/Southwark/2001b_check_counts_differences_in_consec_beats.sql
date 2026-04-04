-- Find obvious errors

-- check for signficant differences between beats - tends to pick misses

SELECT curr."Enumerator", curr."SurveyID"
, curr."GeometryID"
, s."RoadName"
, s."RestrictionTypeID"
, l."Description"
, s."Capacity"
, curr."CapacityAtTimeOfSurvey"
, before."Demand" As "Demand - Before"
, curr."Demand" As "Demand - Current"
, after."Demand" As "Demand - After"
, s.geom
FROM demand."RestrictionsInSurveys" curr, demand."RestrictionsInSurveys" before, demand."RestrictionsInSurveys" after, toms_lookups."BayLineTypes" l,
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE curr."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND curr."GeometryID" = before."GeometryID"
AND before."GeometryID" = after."GeometryID"
AND before."SurveyID" = curr."SurveyID" - 1
AND after."SurveyID" = curr."SurveyID" + 1
AND ABS(curr."Demand"::real - (before."Demand"::real + after."Demand"::real) / 2.0) > 5.0
--AND curr."SurveyID" = 113
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I')
--Order By s."RestrictionTypeID", before."GeometryID"

-- For first survey of day
UNION

SELECT curr."Enumerator"
, curr."SurveyID"
, curr."GeometryID"
, s."RoadName"
, s."RestrictionTypeID"
, l."Description"
, s."Capacity"
, curr."CapacityAtTimeOfSurvey"
, NULL As "Demand - Before"
, curr."Demand" As "Demand - Current"
, after."Demand" As "Demand - After"
, s.geom
FROM demand."RestrictionsInSurveys" curr, demand."RestrictionsInSurveys" after, toms_lookups."BayLineTypes" l,
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE curr."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND MOD(curr."SurveyID", 100) = 1
AND curr."GeometryID" = after."GeometryID"
AND after."SurveyID" = curr."SurveyID" + 1
AND ABS(curr."Demand"::real - after."Demand"::real) > 5.0
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I')
--Order By s."RestrictionTypeID", curr."GeometryID";

-- last survey of day
UNION

SELECT curr."Enumerator", curr."SurveyID", curr."GeometryID"
, s."RoadName"
, s."RestrictionTypeID"
, l."Description"
, s."Capacity"
, curr."CapacityAtTimeOfSurvey"
, before."Demand" As "Demand - Before"
, curr."Demand" As "Demand - Current"
, NULL As "Demand - After"
, s.geom
FROM demand."RestrictionsInSurveys" curr, demand."RestrictionsInSurveys" before, toms_lookups."BayLineTypes" l,
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE curr."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND MOD(curr."SurveyID", 100) = 3
AND curr."GeometryID" = before."GeometryID"
AND before."SurveyID" = curr."SurveyID" - 1
AND ABS(curr."Demand"::real - before."Demand"::real) > 5.0
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I')
-- Order By s."RestrictionTypeID", curr."GeometryID";

Order By "RestrictionTypeID", "GeometryID";

