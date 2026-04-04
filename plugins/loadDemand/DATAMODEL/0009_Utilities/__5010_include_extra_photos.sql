/***

Process to import photos captured outside tablet into RiS 

Steps:
1. Import photos using Processing -> Import geotagged photos
2. Modify CRS using Processing -> Reproject layer with Target CRS as EPSG:27700 (OSGB36) & Save layer into database as <connection> demand."DemandPhotosImport"
3. Check that photos are in (approximately) the correct place

then use this script to add photos to RiS

***/

/***
Add SurveyID
***/

ALTER TABLE IF EXISTS demand."DemandPhotosImport"
  ADD COLUMN IF NOT EXISTS "SurveyID" INTEGER;

-- Add SurveyID as required

*** for some reason, this does not UPDATE - not sure why

DO $$
DECLARE
	photo_details RECORD;
	geometry_id VARCHAR;
	last_geometry_id VARCHAR;
	survey_id INTEGER;
BEGIN

	survey_id = 101;
	
	-- TODO: There is still a possible over write if the order is not sequential, e.g., if go back to start or reverse direction ...

    -- now update
    FOR photo_details IN
        SELECT id, CONCAT(p."filename", '.jpg') AS "PHOTO", "SurveyID", geom
        FROM demand."DemandPhotosImport" p
		ORDER BY id
    LOOP

		-- Find closest
		
		SELECT "GeometryID"
		INTO geometry_id
		FROM mhtc_operations."Supply" s
		WHERE ST_DWithin(s.geom, photo_details.geom, 10) 
		ORDER BY ST_Distance(s.geom, photo_details.geom)
		LIMIT 1;
		
		RAISE NOTICE '1: %; %; % ... last: %', photo_details.id, geometry_id, survey_id, last_geometry_id;
		
		IF geometry_id <> last_geometry_id OR last_geometry_id IS NULL THEN
		
			last_geometry_id = geometry_id;
			
			UPDATE demand."RestrictionsInSurveys" RiS
			SET "Photos_01" = photo_details."PHOTO"
			WHERE RiS."GeometryID" = geometry_id
			AND "SurveyID" = photo_details."SurveyID";
			
			RAISE NOTICE 'Added to Photos_01 ...';
			
		ELSE
		
			UPDATE demand."RestrictionsInSurveys" RiS
			SET "Photos_02" = photo_details."PHOTO"
			WHERE RiS."GeometryID" = geometry_id
			AND "SurveyID" = photo_details."SurveyID";
			
			RAISE NOTICE 'Added to Photos_02 ...';
						
        END IF;
		
    END LOOP;

END; $$;	