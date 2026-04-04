-- set road details

UPDATE mhtc_operations."Supply" AS c
SET "SectionID" = closest."SectionID", "RoadName" = closest."RoadName", "SideOfStreet" = closest."SideOfStreet", "StartStreet" =  closest."StartStreet", "EndStreet" = closest."EndStreet"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."gid" AS "SectionID",
        ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length, c1."RoadName", c1."SideOfStreet", c1."StartStreet", c1."EndStreet"
      FROM mhtc_operations."Supply" s 
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
	  , mhtc_operations."RC_Sections_merged" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
	  AND LENGTH(c1."RoadName") > 0
	  AND "SouthwarkProposedDeliveryZones"."zonename" IN ('N')
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
;


/**
Deal with unmarked areas within PPZ
**/

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 227
FROM toms."RestrictionPolygons" p, import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones"
WHERE s."RestrictionTypeID" = 216  -- Unmarked (Acceptable)
AND p."RestrictionTypeID" IN ( 2)
AND ST_Within(s.geom, p.geom)
AND s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
AND "SouthwarkProposedDeliveryZones"."zonename" IN ('O')
;

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 228
FROM toms."RestrictionPolygons" p, import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones"
WHERE s."RestrictionTypeID" = 220   -- Unmarked (Unacceptable)
AND p."RestrictionTypeID" IN ( 2 )
AND ST_Within(s.geom, p.geom)
AND s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
AND "SouthwarkProposedDeliveryZones"."zonename" IN ('O')
;

UPDATE mhtc_operations."Supply" AS s
SET "RestrictionTypeID" = 229
FROM toms."RestrictionPolygons" p, import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones"
WHERE s."RestrictionTypeID" = 225   -- Unmarked
AND p."RestrictionTypeID" IN ( 2 )
AND ST_Within(s.geom, p.geom)
AND s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
AND "SouthwarkProposedDeliveryZones"."zonename" IN ('O')
;

/**
Deal with CPZs
**/

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = NULL
FROM import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones"
WHERE s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
AND "SouthwarkProposedDeliveryZones"."zonename" IN ('O')
;

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a, import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones"
WHERE ST_WITHIN (s.geom, a.geom)
AND s."CPZ" IS NULL
AND s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
AND "SouthwarkProposedDeliveryZones"."zonename" IN ('O')
;

UPDATE "mhtc_operations"."Supply" AS s
SET "CPZ" = a."CPZ"
FROM toms."ControlledParkingZones" a, import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones"
WHERE ST_Intersects (s.geom, a.geom)
AND s."CPZ" IS NULL
AND s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
AND "SouthwarkProposedDeliveryZones"."zonename" IN ('O')
;

/***
Dual restrictions
***/

INSERT INTO mhtc_operations."DualRestrictions" ("GeometryID", "LinkedTo")
SELECT s1."GeometryID", s2."GeometryID"
FROM mhtc_operations."Supply" s1 LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones1" ON s1."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones1"."ogc_fid"
, mhtc_operations."Supply" s2 LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones2" ON s2."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones2"."ogc_fid"
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."GeometryID" != s2."GeometryID"
AND s1."RestrictionTypeID" > 200
AND s1."GeomShapeID" < 100
AND s2."GeomShapeID" < 100
AND s2."RestrictionTypeID" NOT IN (121, 147, 151, 164)
AND s2."GeomShapeID" NOT IN (3, 6, 9, 23, 26, 29)
AND "SouthwarkProposedDeliveryZones1"."zonename" = "SouthwarkProposedDeliveryZones2"."zonename"
AND "SouthwarkProposedDeliveryZones1"."zonename" IN ('P')
AND NOT EXISTS (SELECT 1
				FROM mhtc_operations."DualRestrictions"
				WHERE "GeometryID" = s1."GeometryID" 
				AND "LinkedTo" = s2."GeometryID");

--
	
INSERT INTO mhtc_operations."DualRestrictions" ("GeometryID", "LinkedTo")
SELECT s1."GeometryID", s2."GeometryID"
FROM mhtc_operations."Supply" s1 LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones1" ON s1."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones1"."ogc_fid"
, mhtc_operations."Supply" s2 LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones2" ON s2."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones2"."ogc_fid"
WHERE ST_INTERSECTS(ST_LineSubstring (s1.geom, 0.1, 0.9), ST_Buffer(s2.geom, 0.1, 'endcap=flat'))
AND s1."GeometryID" != s2."GeometryID"
AND s1."GeomShapeID" < 100
AND s2."GeomShapeID" < 100
AND s1."RestrictionTypeID" IN (203, 204, 205, 206, 207, 208)
AND s2."RestrictionTypeID" IN (201, 221, 224, 202)
AND "SouthwarkProposedDeliveryZones1"."zonename" = "SouthwarkProposedDeliveryZones2"."zonename"
AND "SouthwarkProposedDeliveryZones1"."zonename" IN ('P')
AND NOT EXISTS (SELECT 1
				FROM mhtc_operations."DualRestrictions"
				WHERE "GeometryID" = s1."GeometryID" 
				AND "LinkedTo" = s2."GeometryID");

--

-- Remove duplicates

DELETE
FROM mhtc_operations."DualRestrictions" d1
USING mhtc_operations."DualRestrictions" d2
WHERE d1."GeometryID" = d2."GeometryID"
AND d1."LinkedTo" = d2."LinkedTo"
AND d1.id < d2.id;

-- Add geometry column

ALTER TABLE mhtc_operations."DualRestrictions"
    ADD COLUMN IF NOT EXISTS "geom" geometry(LineString,27700);

UPDATE mhtc_operations."DualRestrictions" AS d
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID";

-- Remove any short restrictions from this list

DELETE
FROM mhtc_operations."DualRestrictions" d
WHERE ST_Length(d.geom) < 1.0;

DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND ST_Length(s.geom) < 1.0;

-- Remove any restrictions that no longer exist

DELETE
FROM mhtc_operations."DualRestrictions" d
WHERE "GeometryID" NOT IN
    (SELECT "GeometryID" FROM mhtc_operations."Supply");

DELETE
FROM mhtc_operations."DualRestrictions" d
WHERE "LinkedTo" NOT IN
    (SELECT "GeometryID" FROM mhtc_operations."Supply");

-- Remove any DYLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = 202;

-- Remove and SYLs/DYLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE d."GeometryID" = s1."GeometryID"
AND s1."RestrictionTypeID" IN (201, 221, 224)
AND d."LinkedTo" = s2."GeometryID"
AND s2."RestrictionTypeID" = 202;

-- Remove and SYLs/SYLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE d."GeometryID" = s1."GeometryID"
AND s1."RestrictionTypeID" IN (201, 221, 224)
AND d."LinkedTo" = s2."GeometryID"
AND s2."RestrictionTypeID" IN (201, 221, 224);

-- Remove any situations where the ZigZag is linked to
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND s."RestrictionTypeID" IN (203, 204, 205, 206, 207, 208);

-- Remove DRLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = 218;

-- Remove and SYLs/SYLs
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s1, mhtc_operations."Supply" s2
WHERE d."GeometryID" = s1."GeometryID"
AND s1."RestrictionTypeID" IN (217, 222, 226)
AND d."LinkedTo" = s2."GeometryID"
AND s2."RestrictionTypeID" IN (217, 222, 226);

-- Remove crossings
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (209, 210, 211, 212, 213, 214, 215);

DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND s."RestrictionTypeID" IN (209, 210, 211, 212, 213, 214, 215);

-- Remove any Cycle Hire bays
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (116);

DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND s."RestrictionTypeID" IN (116);

-- TO DO Remove on-pavement bays / SYLs

-- Remove Unmarked
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (216, 220, 225, 227, 228, 229);

DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND s."RestrictionTypeID" IN (216, 220, 225, 227, 228, 229);

-- Remove item linked to Unaaceptable SYL/SRL
DELETE
FROM mhtc_operations."DualRestrictions" d
USING mhtc_operations."Supply" s
WHERE d."LinkedTo" = s."GeometryID"
AND s."RestrictionTypeID" IN (221, 222);
