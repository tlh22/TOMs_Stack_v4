/***
 * DXF was provided without a coord system.
 * Process to move was:
 * 1. import layers (lines and polygons) into QGIS/postgis - and select items of interest
 * 2. find common point (on mapping) - and save into table ("TranslatePoints")
 * 3. calculate deltas
 * 4. apply translate
 * 5. follow DXF import processes ...

 ***/

-- lines

UPDATE local_authority.entities_lines e
SET geom = ST_Translate(e.geom, d.DeltaX, d.DeltaY)
FROM (
SELECT ST_X(t2.geom) - ST_X(t1.geom) AS DeltaX, ST_Y(t2.geom) - ST_Y(t1.geom) AS DeltaY
	FROM mhtc_operations."TransformPoints" t1, mhtc_operations."TransformPoints" t2
	WHERE t1.id = 1
	AND t2.id = 2 ) AS d;

-- polygons
UPDATE local_authority.entities_polygons e
SET geom = ST_Translate(e.geom, d.DeltaX, d.DeltaY)
FROM (
SELECT ST_X(t2.geom) - ST_X(t1.geom) AS DeltaX, ST_Y(t2.geom) - ST_Y(t1.geom) AS DeltaY
	FROM mhtc_operations."TransformPoints" t1, mhtc_operations."TransformPoints" t2
	WHERE t1.id = 1
	AND t2.id = 2 ) AS d;