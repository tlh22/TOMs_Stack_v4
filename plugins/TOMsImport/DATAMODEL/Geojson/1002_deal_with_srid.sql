/***
 * For some reason the SRID is not coming through correctly. Re-project to 27700

 ***/

-- Loop through all the tables and change

DO
$do$
DECLARE
   row RECORD;
   import_schema TEXT;
BEGIN

    import_schema = 'import_geojson';

    FOR row IN
        SELECT f_table_name, f_geometry_column, type
        FROM  geometry_columns
        WHERE f_table_schema = import_schema
    LOOP
        EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE Geometry(%I, 27700) USING ST_SetSRID(%I, 27700);',
            import_schema, row.f_table_name, row.f_geometry_column, row.type, row.f_geometry_column);
    END LOOP;

END
$do$;
