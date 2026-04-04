/***

Check bay numbers

***/

SELECT "GeometryID"
, "BayLineTypes"."Description"
, "RoadName"
, "NrBays"
, FLOOR(s."RestrictionLength"/5.0)
-- , s.geom
FROM mhtc_operations."Supply" s
		LEFT JOIN toms_lookups."BayLineTypes"  AS "BayLineTypes" ON s."RestrictionTypeID" IS NOT DISTINCT FROM "BayLineTypes" ."Code"
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE "RestrictionTypeID" < 200
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND "NrBays" > 0
AND "NrBays" < FLOOR(s."RestrictionLength"/5.0)
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('J')