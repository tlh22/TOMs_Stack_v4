-- For Enfield
-- Bay types

-- Ensure key field does not have spaces

UPDATE import_geojson."Merged_Bays"
SET "boundary_type" = TRIM ("boundary_type");

--

UPDATE import_geojson."Merged_Bays"
SET "RestrictionTypeID" =
    CASE  WHEN "boundary_type" = 'BUSINESS PARKING PLACE'
                THEN 102

          WHEN "boundary_type" = 'DISABLED PARKING PLACE' OR "boundary_type" = 'DISABLED BAY' OR "boundary_type" = 'DISABLED PARKING' OR "boundary_type" = 'DISABLED PARKING PLACE' OR "boundary_type" = 'disabled bay'
                THEN 110

          WHEN "boundary_type" = 'FREE PARKING' OR "boundary_type" = 'FREE PARKING PLACE'
                THEN 127

          WHEN "boundary_type" = 'LOADING BAY' OR "boundary_type" = 'LOADING AND SHORT TERM FREE BAY'
                THEN 114

          WHEN "boundary_type" = 'PARKING PLACE' OR "boundary_type" = 'RESIDENT BAY'
                OR "boundary_type" = 'RESIDENT PARKIG PLACE' OR "boundary_type" = 'RESIDENT PARKING' OR "boundary_type" = 'RESIDENT PARKING PLACE'
                OR "boundary_type" = 'RESIDENTS PARKING' OR "boundary_type" = 'RESIDENTS PARKING PLACE'
                THEN 101

          WHEN "boundary_type" = 'TAXI RANK'
                THEN 121

          ELSE 101

     END
WHERE "RestrictionTypeID" IS NULL;

UPDATE import_geojson."Merged_Bays"
SET "GeomShapeID" = 21;

--

UPDATE import_geojson."Merged_Lines"
SET "RestrictionTypeID" =
    CASE  WHEN "layer" = 'tpc no waiting double yellow line'
                THEN 202

          WHEN "layer" = 'tpc no waiting single yellow line' OR "layer" = 'tpc no waiting inter yellow line'
                THEN 224

     END
WHERE "RestrictionTypeID" IS NULL;

UPDATE import_geojson."Merged_Lines"
SET "GeomShapeID" = 10;