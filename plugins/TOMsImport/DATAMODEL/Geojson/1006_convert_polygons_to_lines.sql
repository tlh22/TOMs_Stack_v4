-- create copy of table but change geometry type to linestring

CREATE TABLE import_geojson."Merged_Bays_LineString" AS
    TABLE import_geojson."Merged_Bays"
    WITH NO DATA;

ALTER TABLE IF EXISTS import_geojson."Merged_Bays_LineString"
    ADD PRIMARY KEY (gid);

ALTER TABLE import_geojson."Merged_Bays_LineString" ALTER COLUMN geom type geometry(LineString, 27700);

INSERT INTO import_geojson."Merged_Bays_LineString"(
	gid, geom, ogc_fid, ambulance_bay, id, traffic_engineers, parking_control, permitted_parking, type, boundary_type, lengthm, location, reference_number, lbe_code, hours_of_operation, enforcement_level, layer, path, "GeometryID", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "TimePeriodID")
SELECT gid, ST_ExteriorRing(geom), ogc_fid, ambulance_bay, id, traffic_engineers, parking_control, permitted_parking, type, boundary_type, lengthm, location, reference_number, lbe_code, hours_of_operation, enforcement_level, layer, path, "GeometryID", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "TimePeriodID"
	FROM import_geojson."Merged_Bays";


/***
 * Was able to use TOMs_Import to create LineStrings for bays from Polygons. Saved into db as Merged_Bays_LineString. There were some duplicates to be removed.
 ***/

DELETE FROM import_geojson."Merged_Bays_LineString" a
WHERE gid NOT IN (
SELECT MAX(gid)
FROM import_geojson."Merged_Bays_LineString" r1
GROUP BY ST_AsBinary(geom), "RestrictionTypeID"
	);

