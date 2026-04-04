-- Find obvious errors


SELECT "Enumerator", "SurveyID", RiS."GeometryID", s."RestrictionTypeID", l."Description", "Capacity", "CapacityAtTimeOfSurvey", "Demand", s."RestrictionLength", FLOOR(s."RestrictionLength"/5.5) AS "CapacityFromLength"
-- , s.geom
FROM demand."RestrictionsInSurveys" RiS, toms_lookups."BayLineTypes" l, 
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND s."RestrictionTypeID" = l."Code"
AND "Stress" >= 1
AND (
	("CapacityAtTimeOfSurvey" > 0 AND "Demand" > "CapacityAtTimeOfSurvey" + 2)
	OR ("CapacityAtTimeOfSurvey" = 0 AND "Demand" > (FLOOR(s."RestrictionLength"/5.5)) AND "Demand" > 1)
	)
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('J')
Order By s."RestrictionTypeID",  RiS."GeometryID", "SurveyID";


