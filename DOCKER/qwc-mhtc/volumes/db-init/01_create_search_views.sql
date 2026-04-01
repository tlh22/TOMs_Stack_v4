SET search_path = local_authority, public;

DROP VIEW IF EXISTS local_authority."StreetGazetteerRecords_with_postcode";
CREATE OR REPLACE VIEW local_authority."StreetGazetteerRecords_with_postcode" AS
SELECT
    s.gid,
    s."SITE_NAME",
    s."LOCALITY",
    s."TOWN",
    s."AREA_NAME",
    s.geom,
    c.postcode
FROM local_authority."StreetGazetteerRecords" s
LEFT JOIN LATERAL (
    SELECT postcode
    FROM local_authority."CodePoint_Open_TRDC"
    ORDER BY geom <-> ST_Centroid(s.geom)
    LIMIT 1
) c ON true;

DROP VIEW IF EXISTS local_authority."CodePoint_Open_TRDC_with_street";
CREATE OR REPLACE VIEW local_authority."CodePoint_Open_TRDC_with_street" AS
SELECT
    c.id,
    c.geom,
    c.postcode,
    s."SITE_NAME",
    s."TOWN"
FROM local_authority."CodePoint_Open_TRDC" c
LEFT JOIN LATERAL (
    SELECT "SITE_NAME", "TOWN"
    FROM local_authority."StreetGazetteerRecords"
    ORDER BY geom <-> c.geom
    LIMIT 1
) s ON true;
