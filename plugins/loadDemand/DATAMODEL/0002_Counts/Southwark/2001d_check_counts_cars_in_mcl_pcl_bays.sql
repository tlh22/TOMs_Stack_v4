-- Find obvious errors

-- Check for cars in MCL/PCL bays
SELECT RiS."GeometryID"
, s."RestrictionTypeID"
, l."Description"
, RiS."SurveyID"
, s."RoadName"
, c."NrCars"
FROM demand."RestrictionsInSurveys" RiS, demand."Counts" c
, toms_lookups."BayLineTypes" l
, mhtc_operations."Supply" s
	LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE s."GeometryID" = RiS."GeometryID"
AND RiS."GeometryID" = c."GeometryID"
AND RiS."SurveyID" = c."SurveyID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" IN (117, 118, 119, 168, 169)
AND COALESCE(c."NrCars", 0) > 0
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I')
ORDER BY "GeometryID", "SurveyID";
