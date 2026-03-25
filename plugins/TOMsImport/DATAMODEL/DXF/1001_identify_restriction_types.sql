-- dealing with DXF import for Haringey ...
/***

DXF imported directly into QGIS (opened from browser and not using import tool). Used polyline layer ... (although some details in polygon ...)

Data includes all OS mapping across the area - and data is tiled. Need to get details within the area of interest - remove details not intersecting polygon including setting CRS ...

Imported as multiline using ExportToPostgresql from Processing

Details are held against "Layer" field


***/

DROP TABLE IF EXISTS local_authority."DXF_Merged_single" CASCADE;

CREATE TABLE local_authority."DXF_Merged_single"
(
    id SERIAL,
    "Layer" character varying COLLATE pg_catalog."default",
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry(LineString,27700),
    CONSTRAINT dxf_merged_single_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

-- DROP INDEX local_authority.fp_geom_geom_idx;

CREATE INDEX dxf_merged_single_geom_idx
    ON local_authority."DXF_Merged_single" USING gist
    (geom)
    TABLESPACE pg_default;

INSERT INTO local_authority."DXF_Merged_single" ("Layer", geom)
SELECT layer AS "Layer", (ST_Dump(geom)).geom As geom
FROM local_authority."import_all";

-- Remove any duplicates

DELETE FROM local_authority."DXF_Merged_single" a
WHERE id NOT IN (
SELECT MAX(id)
FROM local_authority."DXF_Merged_single" r1
GROUP BY ST_AsBinary(geom), "Layer"
	);

-- Add GeometryID

ALTER TABLE local_authority."DXF_Merged_single"
    ADD COLUMN "GeometryID" integer;

UPDATE local_authority."DXF_Merged_single"
SET "GeometryID" = id;

-- start by identifying relevant items

ALTER TABLE local_authority."DXF_Merged_single"
    ADD COLUMN "RestrictionTypeID" integer;


-- Set up a mapping table


DROP TABLE IF EXISTS "local_authority"."DXF_Mapping";
CREATE TABLE "local_authority"."DXF_Mapping" (
    "id" SERIAL,
	"Layer" character varying COLLATE pg_catalog."default",
	"RestrictionTypeID" integer
);

ALTER TABLE "local_authority"."DXF_Mapping"
    ADD PRIMARY KEY ("id");
	
ALTER TABLE "local_authority"."DXF_Mapping" OWNER TO "postgres";

INSERT INTO "local_authority"."DXF_Mapping" ("Layer")
SELECT DISTINCT "Layer"
FROM local_authority."DXF_Merged_single";

-- *** Add mappings - and any other new layer types

-- Now tidy

INSERT INTO "local_authority"."DXF_Mapping" ("Layer")
SELECT DISTINCT "Layer"
FROM local_authority."DXF_Merged_single"
WHERE "Layer" NOT IN (SELECT "Layer" FROM "local_authority"."DXF_Mapping");

DELETE FROM "local_authority"."DXF_Mapping"
WHERE "Layer" NOT IN (SELECT "Layer" FROM local_authority."DXF_Merged_single");

-- Apply mapping

UPDATE local_authority."DXF_Merged_single" AS d
SET "RestrictionTypeID" = m."RestrictionTypeID"
FROM "local_authority"."DXF_Mapping" m
WHERE m."Layer" = d."Layer";


-- Now check for parallel lines (need to adjust as required)

-- DYLs
UPDATE local_authority."DXF_Merged_single" a
SET "RestrictionTypeID" = 202
WHERE id IN (
SELECT r2.id AS id
FROM local_authority."DXF_Merged_single" r1, local_authority."DXF_Merged_single" r2
WHERE r1.id != r2.id
AND st_within(r1.geom, ST_Buffer(r2.geom, 0.5)) -- 'endcap=flat' seems to miss some DYLs
AND (r1."RestrictionTypeID" = 224)
AND r1."Layer" = r2."Layer"
AND ST_Length(r1.geom) <= ST_Length(r2.geom)
ORDER BY r1.id );

DELETE FROM local_authority."DXF_Merged_single" a
WHERE id IN (
SELECT r1.id AS id
FROM local_authority."DXF_Merged_single" r1, local_authority."DXF_Merged_single" r2
WHERE r1.id != r2.id
AND st_within(r1.geom, ST_Buffer(r2.geom, 0.5))
AND (r1."RestrictionTypeID" = 202)
AND r1."Layer" = r2."Layer"
AND ABS(ST_Length(r1.geom) - ST_Length(r2.geom)) < 0.5
ORDER BY r1.id );


-- DRLs
UPDATE local_authority."DXF_Merged_single" a
SET "RestrictionTypeID" = 218
WHERE id IN (
SELECT r2.id AS id
FROM local_authority."DXF_Merged_single" r1, local_authority."DXF_Merged_single" r2
WHERE r1.id != r2.id
AND st_within(r1.geom, ST_Buffer(r2.geom, 0.5))
AND (r1."RestrictionTypeID" = 226)
AND r1."Layer" = r2."Layer"
AND ST_Length(r1.geom) <= ST_Length(r2.geom)
ORDER BY r1.id );

DELETE FROM local_authority."DXF_Merged_single" a
WHERE id IN (
SELECT r1.id AS id
FROM local_authority."DXF_Merged_single" r1, local_authority."DXF_Merged_single" r2
WHERE r1.id != r2.id
AND st_within(r1.geom, ST_Buffer(r2.geom, 0.5))
AND (r1."RestrictionTypeID" = 226)
AND r1."Layer" = r2."Layer"
AND ABS(ST_Length(r1.geom) - ST_Length(r2.geom)) < 0.5
ORDER BY r1.id );

