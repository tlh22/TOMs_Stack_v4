-- dealing with DXF import for Haringey ...
/***

DXF imported directly into QGIS (opened from browser and not using import tool). Used polyline layer ... (although some details in polygon ...)

Data includes all OS mapping across the area - and data is tiled. Need to get details within the area of interest - remove details not intersecting polygon including setting CRS ...

Imported as multiline using ExportToPostgresql from Processing

Details are held against "Layer" field


***/

DROP TABLE IF EXISTS local_authority."DXF_Polygons_single" CASCADE;

CREATE TABLE local_authority."DXF_Polygons_single"
(
    id SERIAL,
    "Layer" character varying COLLATE pg_catalog."default",
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry(LineString,27700),
    CONSTRAINT dxf_polygons_single_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

-- DROP INDEX local_authority.fp_geom_geom_idx;

CREATE INDEX dxf_polygons_single_geom_idx
    ON local_authority."DXF_Polygons_single" USING gist
    (geom)
    TABLESPACE pg_default;

INSERT INTO local_authority."DXF_Polygons_single" ("Layer", geom)
SELECT "Layer" AS "Layer", (ST_Dump(ST_Force2D(geom))).geom As geom
FROM local_authority."DXF_Polygons_import_as_lines";

-- Remove any duplicates

DELETE FROM local_authority."DXF_Polygons_single" a
WHERE id NOT IN (
SELECT MAX(id)
FROM local_authority."DXF_Polygons_single" r1
GROUP BY ST_AsBinary(geom), "Layer"
	);

-- Add GeometryID

ALTER TABLE local_authority."DXF_Polygons_single"
    ADD COLUMN "GeometryID" integer;

UPDATE local_authority."DXF_Polygons_single"
SET "GeometryID" = id;

-- start by identifying relevant items

ALTER TABLE local_authority."DXF_Polygons_single"
    ADD COLUMN "RestrictionTypeID" integer;

/***
 *
 * Next steps are:
 *  1. Snap and trace polygon to kerb
 *  2. Create buffer of 0.1m around polygon lines
 *  3. Intersect kerbline with Polygon line buffer
 *
 ***/

DROP TABLE IF EXISTS local_authority."DXF_DroppedKerbs_single" CASCADE;

CREATE TABLE local_authority."DXF_DroppedKerbs_single"
(
    id SERIAL,
    "Layer" character varying COLLATE pg_catalog."default",
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry(LineString,27700),
    CONSTRAINT dxf_dropped_kerbs_single_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

-- DROP INDEX local_authority.fp_geom_geom_idx;

CREATE INDEX dxf_dropped_kerbs_single_geom_idx
    ON local_authority."DXF_DroppedKerbs_single" USING gist
    (geom)
    TABLESPACE pg_default;

INSERT INTO local_authority."DXF_DroppedKerbs_single" ("Layer", geom)
SELECT "Layer" AS "Layer", (ST_Dump(geom)).geom As geom
FROM local_authority."DXF_Dropped_kerbs";

-- Now snap to kerb



--- *** TIDY UP
DELETE FROM local_authority."DXF_Merged_single"
WHERE "RestrictionTypeID" IS NULL;


----

DROP TABLE IF EXISTS local_authority."DXF_DroppedKerbs_single2" CASCADE;

CREATE TABLE local_authority."DXF_DroppedKerbs_single2"
(
    id SERIAL,
    "Layer" character varying COLLATE pg_catalog."default",
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry(LineString,27700),
    CONSTRAINT dxf_dropped_kerbs_single2_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

-- DROP INDEX local_authority.fp_geom_geom_idx;

CREATE INDEX dxf_dropped_kerbs_single2_geom_idx
    ON local_authority."DXF_DroppedKerbs_single2" USING gist
    (geom)
    TABLESPACE pg_default;

INSERT INTO local_authority."DXF_DroppedKerbs_single2" ("Layer", geom)
SELECT "Layer" AS "Layer", (ST_Dump(geom)).geom As geom
FROM local_authority."DXF_DroppedKerbs_single";
