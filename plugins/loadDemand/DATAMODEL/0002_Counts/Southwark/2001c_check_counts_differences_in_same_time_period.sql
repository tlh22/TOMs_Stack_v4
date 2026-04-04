-- Find obvious errors

-- Find differences within the same time periods for the same GeometryID - good check - possibly typo, possible miss

Southwark

SELECT RiS1."GeometryID", s."RestrictionTypeID", l."Description"
, s."RoadName"
, s."Capacity", RiS1."SurveyID", RiS1."Demand", RiS1."Enumerator", RiS2."SurveyID", RiS2."Demand", RiS2."Enumerator"
, s.geom
FROM demand."RestrictionsInSurveys" RiS1, demand."RestrictionsInSurveys" RiS2, toms_lookups."BayLineTypes" l,
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE  RiS1."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND RiS1."GeometryID" = RiS2."GeometryID"
AND RiS1."SurveyID" < RiS2."SurveyID"
AND ABS(RiS1."SurveyID" - RiS2."SurveyID") = 100
AND ABS(RiS1."Demand" - RiS2."Demand") >= 5
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I')
ORDER BY s."RestrictionTypeID", RiS1."GeometryID", RiS1."SurveyID";




