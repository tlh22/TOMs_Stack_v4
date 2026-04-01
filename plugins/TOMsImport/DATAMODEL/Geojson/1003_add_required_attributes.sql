/***
 * Now add GeometryID, etc

 ***/

ALTER TABLE import_geojson."Merged_Lines"
    ADD COLUMN "GeometryID" integer;

UPDATE import_geojson."Merged_Lines"
SET "GeometryID" = gid;

ALTER TABLE import_geojson."Merged_Lines"
    ADD COLUMN "RestrictionTypeID" integer;

ALTER TABLE import_geojson."Merged_Lines"
    ADD COLUMN "GeomShapeID" integer;

ALTER TABLE import_geojson."Merged_Lines"
    ADD COLUMN "AzimuthToRoadCentreLine" double precision;

ALTER TABLE import_geojson."Merged_Lines"
    ADD COLUMN "NoWaitingTimeID" integer;

ALTER TABLE import_geojson."Merged_Lines"
    ADD COLUMN "CPZ" character varying(40) COLLATE pg_catalog."default";

--

ALTER TABLE import_geojson."Merged_Bays"
    ADD COLUMN "GeometryID" integer;

UPDATE import_geojson."Merged_Bays"
SET "GeometryID" = gid;

ALTER TABLE import_geojson."Merged_Bays"
    ADD COLUMN "RestrictionTypeID" integer;

ALTER TABLE import_geojson."Merged_Bays"
    ADD COLUMN "GeomShapeID" integer;

ALTER TABLE import_geojson."Merged_Bays"
    ADD COLUMN "AzimuthToRoadCentreLine" double precision;

ALTER TABLE import_geojson."Merged_Bays"
    ADD COLUMN "TimePeriodID" integer;

ALTER TABLE import_geojson."Merged_Bays"
    ADD COLUMN "CPZ" character varying(40) COLLATE pg_catalog."default";