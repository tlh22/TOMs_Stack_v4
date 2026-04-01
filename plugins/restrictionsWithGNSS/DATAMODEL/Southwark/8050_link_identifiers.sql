/***
Script to transfer AppyWay ids to TOMs data

Original import used ogc_fid field as identifier. This has been transferred? to TOMs data.

New id from AppyWay is ospId. Need create table to link this IDs


***/

CREATE TABLE import_geojson."Identifier_Transfer"
(
    id SERIAL,
    ogc_fid integer NOT NULL,
    "ospId" character varying COLLATE pg_catalog."default" NOT NULL
)

TABLESPACE pg_default;

ALTER TABLE import_geojson."Identifier_Transfer"
    OWNER to postgres;

ALTER TABLE import_geojson."Identifier_Transfer"
    ADD PRIMARY KEY (id);

INSERT INTO import_geojson."Identifier_Transfer"(ogc_fid, "ospId")
SELECT a.ogc_fid, b."ospId"
FROM import_geojson."Parking_Restrictions_Polygon" a, import_geojson."Parking_Restrictions_Polygon_20250601_22700" b, toms."ControlledParkingZones" c
WHERE ST_Equals(a.geom, b.geom)
AND c."CPZ" = 'C1'
AND ST_Within(a.geom, c.geom)
;
