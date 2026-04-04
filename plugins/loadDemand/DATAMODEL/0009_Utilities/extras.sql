-- Create table

DROP TABLE IF EXISTS "demand"."MissingVRMs";
CREATE TABLE "demand"."MissingVRMs" (
    "gid" SERIAL,
    "VRM" character varying,
	"RoadName" character varying,
	"SurveyID" integer
);

ALTER TABLE "demand"."MissingVRMs" OWNER TO "postgres";

ALTER TABLE "demand"."MissingVRMs"
    ADD PRIMARY KEY ("gid");

-- LOAD!!!

COPY demand."MissingVRMs"("VRM", "RoadName", "SurveyID")
FROM 'C:\Users\Public\Documents\Dumfries_Extras3.csv'
DELIMITER ','
CSV HEADER;

-- Set up unique index on VRMs

CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_vrm ON demand."VRMs" ("SurveyID", "GeometryID", "PositionID", "VRM");

-- for VRMs
DO
$do$
DECLARE
    missing_VRM_in_survey RECORD;
	surveyid integer;
	geometryid text;
	positionid integer;
	internationalcodeid integer;
	vehicletypeid integer;
	permittypeid integer;
	parkingactivitytypeid integer;
	parkingmannertypeid integer;
	notes text;

BEGIN


    FOR missing_VRM_in_survey IN
        SELECT "SurveyID", "RoadName", "VRM"
        FROM "demand"."MissingVRMs"

    LOOP

        RAISE NOTICE '*****--- Processing % in (%)', missing_VRM_in_survey."VRM", missing_VRM_in_survey."SurveyID";

        -- check to see if the VRM exists here
        SELECT "SurveyID", "GeometryID", "PositionID", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", "Notes"
		INTO surveyid, geometryid, positionid, internationalcodeid, vehicletypeid, permittypeid,parkingactivitytypeid, parkingmannertypeid, notes
		FROM demand."VRMs"
		WHERE "VRM" = missing_VRM_in_survey."VRM"
		AND "SurveyID" = missing_VRM_in_survey."SurveyID" + 1;

		RAISE NOTICE 'Found: %', FOUND;
		
		IF NOT FOUND THEN

			RAISE NOTICE '*****--- % details NOT FOUND on survey id (%). Checking on % ... ', missing_VRM_in_survey."VRM", missing_VRM_in_survey."SurveyID"+1, missing_VRM_in_survey."SurveyID"-1;
			
			SELECT "SurveyID", "GeometryID", "PositionID", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", "Notes"
			INTO surveyid, geometryid, positionid, internationalcodeid, vehicletypeid, permittypeid,parkingactivitytypeid, parkingmannertypeid, notes
			FROM demand."VRMs"
			WHERE "VRM" = missing_VRM_in_survey."VRM"
			AND "SurveyID" = missing_VRM_in_survey."SurveyID" - 1;
		
			IF NOT FOUND THEN
			
				RAISE NOTICE '*****--- % details NOT FOUND on survey id (%). Checking elsewhere ... ', missing_VRM_in_survey."VRM", missing_VRM_in_survey."SurveyID"-1;

				SELECT "SurveyID", "GeometryID", "PositionID", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", "Notes"
				INTO surveyid, geometryid, positionid, internationalcodeid, vehicletypeid, permittypeid,parkingactivitytypeid, parkingmannertypeid, notes
				FROM demand."VRMs"
				WHERE "VRM" = missing_VRM_in_survey."VRM";
			
				IF NOT FOUND THEN
					RAISE NOTICE '*****--- % details NOT FOUND !!! ', missing_VRM_in_survey."VRM";
					CONTINUE;
				END IF;
				
			END IF;
			
        END IF;

		BEGIN
		
			INSERT INTO demand."VRMs"(
				"SurveyID", "GeometryID", "PositionID", "VRM", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", "Notes")
				VALUES (missing_VRM_in_survey."SurveyID", geometryid, positionid, missing_VRM_in_survey."VRM", internationalcodeid, vehicletypeid, permittypeid,parkingactivitytypeid, parkingmannertypeid, notes);
		
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Error occurred: %', sqlstate;
		END;
		
    END LOOP;

END;
$do$;

-- Update vehicle type / pcu

UPDATE demand."VRMs"
SET "VehicleTypeID" = 1
WHERE "VehicleTypeID" IS NULL;