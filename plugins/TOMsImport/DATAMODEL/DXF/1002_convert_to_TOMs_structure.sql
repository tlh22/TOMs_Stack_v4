/***

Now start to deal with structure - and then snap vertices ...


***/


-- Bays
UPDATE local_authority."DXF_Merged_single"
SET "GeomShapeID" = 1
WHERE "RestrictionTypeID" < 200
AND "GeomShapeID" IS NULL;

-- Lines
UPDATE local_authority."DXF_Merged_single"
SET "GeomShapeID" = 10
WHERE "RestrictionTypeID" > 200
AND "GeomShapeID" IS NULL;

-- Check for off-carriageway bays
UPDATE local_authority."DXF_Merged_single" AS r
SET "GeomShapeID" = 3
FROM topography."RC_Polygons" p
WHERE NOT ST_Within(r.geom, p.geom)
AND "GeomShapeID" = 1;

-- CPZ
UPDATE local_authority."DXF_Merged_single" AS r
SET "CPZ" = c."CPZ"
FROM mhtc_operations."CPZs_ToBeSurveyed" c
WHERE ST_Intersects(r.geom, c.geom)
AND r."CPZ" IS NULL;

-- Az
UPDATE local_authority."DXF_Merged_single" AS c
SET "AzimuthToRoadCentreLine" = ST_Azimuth(ST_LineInterpolatePoint(c.geom, 0.5), closest.geom)
FROM (SELECT DISTINCT ON (s."id") s."id" AS id, ST_ClosestPoint(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length
      FROM "highways_network"."roadlink" cl, local_authority."DXF_Merged_single" s
      ORDER BY s."id", length) AS closest
WHERE c."id" = closest.id;   --- *** TODO: Check that this is best option for Az

-- Crossovers
UPDATE local_authority."DXF_DroppedKerbs_single2" AS r
SET "GeomShapeID" = 35
WHERE "GeomShapeID" IS NULL;

UPDATE local_authority."DXF_DroppedKerbs_single2" AS c
SET "AzimuthToRoadCentreLine" = ST_Azimuth(ST_LineInterpolatePoint(c.geom, 0.5), closest.geom)
FROM (SELECT DISTINCT ON (s."id") s."id" AS id, ST_ClosestPoint(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(cl.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length
      FROM "highways_network"."roadlink" cl, local_authority."DXF_DroppedKerbs_single2" s
      ORDER BY s."id", length) AS closest
WHERE c."id" = closest.id;   --- *** TODO: Check that this is best option for Az