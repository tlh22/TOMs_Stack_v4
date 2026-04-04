-- Find obvious errors

-- Check for possible typos
SELECT "Enumerator", "SurveyID", RiS."GeometryID", s."RestrictionTypeID", l."Description", "Capacity", "CapacityAtTimeOfSurvey", "Demand", s."RestrictionLength", FLOOR(s."RestrictionLength"/5.5) AS "CapacityFromLength"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, toms_lookups."BayLineTypes" l
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND "Stress" >= 1
AND (
	("CapacityAtTimeOfSurvey" > 0 AND "Demand" > "CapacityAtTimeOfSurvey" + 2)
	OR ("CapacityAtTimeOfSurvey" = 0 AND "Demand" > (FLOOR(s."RestrictionLength"/5.5)) AND "Demand" > 1)
	)
Order By s."RestrictionTypeID",  RiS."GeometryID", "SurveyID";


/***
Southwark


SELECT "Enumerator", "SurveyID", RiS."GeometryID", s."RestrictionTypeID", l."Description", "Capacity", "CapacityAtTimeOfSurvey", "Demand", s."RestrictionLength", FLOOR(s."RestrictionLength"/5.5) AS "CapacityFromLength"
FROM demand."RestrictionsInSurveys" RiS, toms_lookups."BayLineTypes" l, 
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND "Stress" >= 1
AND (
	("CapacityAtTimeOfSurvey" > 0 AND "Demand" > "CapacityAtTimeOfSurvey" + 2)
	OR ("CapacityAtTimeOfSurvey" = 0 AND "Demand" > (FLOOR(s."RestrictionLength"/5.5)) AND "Demand" > 1)
	)
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I')
Order By s."RestrictionTypeID",  RiS."GeometryID", "SurveyID";

***/
