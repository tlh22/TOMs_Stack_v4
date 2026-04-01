/***
 * Eshelon bays tend not to be imported correctly. Need to find them and remove the excess points
 ***/

--- This needs to be run multiple times - until all extra points are removed ...
DO
$do$
DECLARE
    eschelon_bay_details RECORD;
BEGIN

    FOR eschelon_bay_details IN
        SELECT "GeometryID", ST_NumPoints (geom) AS "NrPoints"
        FROM toms."Bays"
        WHERE "GeomShapeID" IN ( 5, 25)
        AND  ST_NumPoints (geom) > 2
        AND ST_Distance(ST_StartPoint(geom), ST_EndPoint(geom)) < 3.5
		AND ST_Distance(ST_StartPoint(geom), ST_EndPoint(geom)) > 2.0
    LOOP

        RAISE NOTICE '*****--- Considering %, point: %', eschelon_bay_details."GeometryID", eschelon_bay_details."NrPoints"-2;

        UPDATE toms."Bays"
            SET geom = ST_RemovePoint(geom, eschelon_bay_details."NrPoints"-2)
            WHERE "GeometryID" = eschelon_bay_details."GeometryID";

    END LOOP;

END;
$do$;