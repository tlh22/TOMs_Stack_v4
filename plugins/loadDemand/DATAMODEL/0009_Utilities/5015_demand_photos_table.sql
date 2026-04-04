/***

Process to import photos captured outside tablet into RiS 

Steps:
1. Import photos using Processing -> Import geotagged photos
2. Modify CRS using Processing -> Reproject layer with Target CRS as EPSG:27700 (OSGB36) & Save layer into database as <connection> demand."DemandPhotosImport"
3. Check that photos are in (approximately) the correct place

then use this script to name photos

***/

DROP SEQUENCE IF EXISTS "demand"."DemandPhotos_id_seq" CASCADE;

CREATE SEQUENCE "demand"."DemandPhotos_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP TABLE IF EXISTS "demand"."DemandPhotos" CASCADE;

CREATE TABLE "demand"."DemandPhotos" (
    "GeometryID" character varying(12) DEFAULT ('DP_'::"text" || "to_char"("nextval"('"demand"."DemandPhotos_id_seq"'::"regclass"), 'FM0000000'::"text")) NOT NULL,
    "geom" "public"."geometry"(Point,27700) NOT NULL,
    "Photos_01" character varying(255),
    "Photos_02" character varying(255),
    "Photos_03" character varying(255),
    "RoadName" character varying(254),
	"DemandPhotoRef" integer
);

ALTER TABLE "demand"."DemandPhotos" OWNER TO "postgres";

ALTER TABLE ONLY "demand"."DemandPhotos"
    ADD CONSTRAINT "DemandPhotos_pkey" PRIMARY KEY ("GeometryID");

--- Insert

INSERT INTO demand."DemandPhotos"(
	geom, "Photos_01")
SELECT ST_Force2D(geom), CONCAT(p."filename", '.jpg') AS "PHOTO"
        FROM demand."DemandPhotosImport" p;

--- set the road name

UPDATE demand."DemandPhotos" AS c
SET "RoadName" = closest."RoadName"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id,
        ST_ClosestPoint(c1.geom, s.geom) AS geom,
        ST_Distance(c1.geom, s.geom) AS length, c1."name1" AS "RoadName"
      FROM demand."DemandPhotos" s, highways_network."roadlink" c1
      WHERE ST_DWithin(c1.geom, s.geom, 15.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id;

--- give each one number

UPDATE demand."DemandPhotos" AS c
SET "DemandPhotoRef" = sid
FROM
(
SELECT row_number() OVER (PARTITION BY true::boolean) AS sid,
	b."GeometryID", b."RoadName", b."Photo"
FROM
(
SELECT su."GeometryID", su."RoadName", su."Photos_01" AS "Photo"
FROM demand."DemandPhotos" su
WHERE su."Photos_01" IS NOT NULL

ORDER BY "Photo"
) b
	) g
WHERE c."GeometryID" = g."GeometryID";

-- Set up copy script
-- https://stackoverflow.com/questions/10768924/match-sequence-using-regex-after-a-specified-character

SELECT CONCAT('copy ', g."Photo", ' "', '../Extra_Demand_Photos/', 'Photo_', to_char(g."sid", 'fm000'), '_', "RoadName",  '.', ext, '"')
FROM
(
SELECT row_number() OVER (PARTITION BY true::boolean) AS sid,
	b."RoadName", b."Photo", substring(b."Photo", '(?<=\.)[^\]]+') AS ext
FROM
(
SELECT su."RoadName", su."Photos_01" AS "Photo"
FROM demand."DemandPhotos" su
WHERE su."Photos_01" IS NOT NULL
ORDER BY "Photo"

) b
) g;
