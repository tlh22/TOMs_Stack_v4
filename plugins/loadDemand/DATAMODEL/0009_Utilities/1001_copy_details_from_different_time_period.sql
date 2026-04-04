/***
 * When data is entered into a different time period, needs to be to moved across to correct time period
 ***/

 -- for Haringey

 -- data is entered into incorrect project

 -- Copy across VRMs

SELECT  v."SurveyID", v."SectionID", v."GeometryID", v."PositionID", v."VRM", v."VehicleTypeID", v."RestrictionTypeID", v."PermitTypeID", v."Notes"
	FROM "demand_WGR"."VRMs" v, "demand_WGR"."Surveys" s, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = r."GeometryID"
AND r."SurveyArea" = a.name
AND r."SurveyArea" IN ('7S-7', '7S-6');

INSERT INTO "demand_WGR"."VRMs"(
	"ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes")
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?); -- Need to check that RiS is not done ...


SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
	FROM "demand_WGR"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = r."GeometryID"
AND r."SurveyArea" = a.name
AND r."SurveyArea" IN ('7S-7', '7S-6')
AND RiS."Done" IS true;


UPDATE "demand"."RestrictionsInSurveys" AS RiS1
	SET "DemandSurveyDateTime"=RiS."DemandSurveyDateTime", "Enumerator"=RiS."Enumerator", "Done"=RiS."Done", "SuspensionReference"=RiS."SuspensionReference", "SuspensionReason"=RiS."SuspensionReason", "SuspensionLength"=RiS."SuspensionLength", "NrBaysSuspended"=RiS."NrBaysSuspended", "SuspensionNotes"=RiS."SuspensionNotes",
	"Photos_01"=RiS."Photos_01", "Photos_02"=RiS."Photos_02", "Photos_03"=RiS."Photos_03"
	FROM "demand_WGR"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
    WHERE RiS."GeometryID" = r."GeometryID"
    AND r."SurveyArea" = a.name
    AND r."SurveyArea" IN ('7S-7', '7S-6')
    AND RiS."Done" IS true
    AND (RiS1."Done" IS false OR RiS1."Done" IS NULL);



-- for Counts (need to break into individual loops)
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."SurveyID" IN (107, 108)
        AND "GeometryID" IN (SELECT DISTINCT RiS2."GeometryID"
                            FROM "demand"."RestrictionsInSurveys" RiS2, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a, demand."Surveys" s
                            WHERE RiS2."GeometryID" = r."GeometryID"
                            AND RiS2."SurveyID" = s."SurveyID"
                            AND r."SurveyArea" = a.name
                            AND r."SurveyArea" IN ('1', '2')
                            AND "Enumerator" = 'peter a'
                            AND s."SurveyID" IN (107, 108))
    LOOP

        RAISE NOTICE '*****--- Changing survey ID for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = relevant_restriction_in_survey."SurveyID" + 1000
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = relevant_restriction_in_survey."SurveyID" + 1000
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."SurveyID" = 1107
    LOOP

        RAISE NOTICE '*****--- Changing survey ID for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = 108
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = 108
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."SurveyID" = 1108
    LOOP

        RAISE NOTICE '*****--- Changing survey ID for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = 107
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = 107
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

END;
$do$;

DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := 0;
	new_survey_id INTEGER := 101;
	survey_area TEXT := '203';
BEGIN

	-- Moving details from "curr" to "new"
	
    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r,  mhtc_operations."SurveyAreas" a
        WHERE RiS."SurveyID" = curr_survey_id
		AND RiS."GeometryID" = r."GeometryID"
		AND RiS."Done" IS true
		AND r."SurveyAreaID" = a."Code"
		AND a."SurveyAreaName" IN (survey_area)
    LOOP

        RAISE NOTICE '*****--- Changing survey ID for % (%) to %', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID", new_survey_id;
		
		-- Firstly make space for the change
		
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = new_survey_id + 1000
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = new_survey_id;
		
		UPDATE demand."Counts" AS c
            SET "SurveyID" = new_survey_id + 1000
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = new_survey_id;
		
		-- Now make the change
		
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = new_survey_id
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = new_survey_id
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

		-- tidy ...
		
		UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = curr_survey_id
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = new_survey_id + 1000;
		
		UPDATE demand."Counts" AS c
            SET "SurveyID" = curr_survey_id
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = new_survey_id + 1000;
		
    END LOOP;

END;
$do$;

-- for VRMs
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := 209;
	new_survey_id INTEGER := 109;
BEGIN


    FOR relevant_restriction_in_survey IN
        SELECT DISTINCT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand_WGR"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
        WHERE RiS."GeometryID" = r."GeometryID"
        AND r."SurveyArea" = a.name
        AND r."SurveyArea" IN ('7S-WGR')
        AND RiS."Done" IS true
        AND RiS."SurveyID" = curr_survey_id
		--AND RiS."DemandSurveyDateTime" < '2022-06-29'::date
    LOOP

        RAISE NOTICE '*****--- Processing % moving from (%) to (%)', relevant_restriction_in_survey."GeometryID", curr_survey_id, new_survey_id;

        -- check to see if the restriction already has a value
        SELECT "Done"
        INTO current_done
        FROM "demand_WGR"."RestrictionsInSurveys"
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = new_survey_id;

        IF current_done IS false or current_done IS NULL THEN

            UPDATE "demand_WGR"."RestrictionsInSurveys"
                SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
                "SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes",
                "Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03"
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = new_survey_id;

            -- Now add VRMs

            INSERT INTO "demand_WGR"."VRMs"(
            "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes")
            SELECT new_survey_id, "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes"
                FROM "demand_WGR"."VRMs"
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = curr_survey_id;

            -- Now tidy up ...

            UPDATE "demand_WGR"."RestrictionsInSurveys"
            SET "Done" = false, "Enumerator" = NULL, "DemandSurveyDateTime" = NULL, "SuspensionReference" = NULL,
            "SuspensionReason" = NULL, "SuspensionLength" = NULL, "NrBaysSuspended"=NULL, "SuspensionNotes"=NULL,
            "Photos_01"=NULL, "Photos_02"=NULL, "Photos_03"=NULL
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = curr_survey_id;

            DELETE FROM "demand_WGR"."VRMs"
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = curr_survey_id;

        ELSE

            RAISE NOTICE '*****--- % already has details on survey id (%) ', relevant_restriction_in_survey."GeometryID", new_survey_id;

        END IF;

    END LOOP;

END;
$do$;



-- update details for count


DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	nrCars INTEGER;
	nrCarsSuspended INTEGER;
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."SurveyID" IN (108)
        AND "GeometryID" IN (SELECT DISTINCT RiS2."GeometryID"
                            FROM "demand"."RestrictionsInSurveys" RiS2, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a, demand."Surveys" s
                            WHERE RiS2."GeometryID" = r."GeometryID"
                            AND RiS2."SurveyID" = s."SurveyID"
                            AND r."SurveyArea" = a.name
                            AND r."SurveyArea" IN ('1', '2')
                            AND "Enumerator" = 'peter a'
                            AND s."SurveyID" IN (108))
    LOOP

		RAISE NOTICE '*****--- Considering for % (%)', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";

        UPDATE demand."Counts" AS c1
            SET "NrCars"=c2."NrCars", "NrLGVs"=c2."NrLGVs", "NrMCLs"=c2."NrMCLs", "NrTaxis"=c2."NrTaxis", "NrPCLs"=c2."NrPCLs", "NrEScooters"=c2."NrEScooters", "NrDocklessPCLs"=c2."NrDocklessPCLs", "NrOGVs"=c2."NrOGVs", "NrMiniBuses"=c2."NrMiniBuses", "NrBuses"=c2."NrBuses", 
            "NrSpaces"=c2."NrSpaces", "DoubleParkingDetails"=c2."DoubleParkingDetails", 
            "NrCars_Suspended"=c2."NrCars_Suspended", "NrLGVs_Suspended"=c2."NrLGVs_Suspended", "NrMCLs_Suspended"=c2."NrMCLs_Suspended", "NrTaxis_Suspended"=c2."NrTaxis_Suspended", "NrPCLs_Suspended"=c2."NrPCLs_Suspended", "NrEScooters_Suspended"=c2."NrEScooters_Suspended", "NrDocklessPCLs_Suspended"=c2."NrDocklessPCLs_Suspended", "NrOGVs_Suspended"=c2."NrOGVs_Suspended", "NrMiniBuses_Suspended"=c2."NrMiniBuses_Suspended", "NrBuses_Suspended"=c2."NrBuses_Suspended"
            FROM demand."Counts_PA" c2
            WHERE c2."GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND c1."GeometryID" = c2."GeometryID"
            AND c2."SurveyID" = 107
            AND c1."SurveyID" = relevant_restriction_in_survey."SurveyID";
       
    END LOOP;

END;
$do$;

/*** Copy forward details ***/

-- for Counts (need to break into individual loops)
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	NrCars INTEGER;
	NrLGVs INTEGER;
	NrMCLs INTEGER;
	NrTaxis INTEGER;
	NrPCLs INTEGER;
	NrEScooters INTEGER;
	NrDocklessPCLs INTEGER;
	NrOGVs INTEGER;
	NrMiniBuses INTEGER;
	NrBuses INTEGER;
    NrSpaces INTEGER;
	DoubleParkingDetails VARCHAR(250);
    NrCars_Suspended INTEGER;
	NrLGVs_Suspended INTEGER;
	NrMCLs_Suspended INTEGER;
	NrTaxis_Suspended INTEGER;
	NrPCLs_Suspended INTEGER;
	NrEScooters_Suspended INTEGER;
	NrDocklessPCLs_Suspended INTEGER;
	NrOGVs_Suspended INTEGER;
	NrMiniBuses_Suspended INTEGER;
	NrBuses_Suspended INTEGER;
	loop_cnt INTEGER;
	GeometryID VARCHAR(10);
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
        FROM "demand"."RestrictionsInSurveys" RiS, "mhtc_operations"."Supply" s
        WHERE RiS."SurveyID" IN (101)
		AND RiS."GeometryID" = s."GeometryID"
		AND s."SurveyArea" = '2'
		AND RiS."Done" is true

    LOOP

		-- Get count details
		

            SELECT "NrCars", "NrLGVs", "NrMCLs", "NrTaxis", "NrPCLs", "NrEScooters", "NrDocklessPCLs", "NrOGVs", "NrMiniBuses", "NrBuses", 
            "NrSpaces", "DoubleParkingDetails", 
            "NrCars_Suspended", "NrLGVs_Suspended", "NrMCLs_Suspended", "NrTaxis_Suspended", "NrPCLs_Suspended", "NrEScooters_Suspended", 
			"NrDocklessPCLs_Suspended", "NrOGVs_Suspended", "NrMiniBuses_Suspended", "NrBuses_Suspended"
			INTO NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, 
            NrSpaces, DoubleParkingDetails, 
            NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended, 
			NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended
            FROM demand."Counts" c
            WHERE c."GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND c."SurveyID" = relevant_restriction_in_survey."SurveyID";
		
			GeometryID = relevant_restriction_in_survey."GeometryID";

			FOR loop_cnt IN 102..113 LOOP
						
				RAISE NOTICE '*****--- Copying details from survey ID % for % (into %)', relevant_restriction_in_survey."SurveyID", GeometryID, loop_cnt;

			    UPDATE demand."Counts"
				SET "NrCars"=NrCars, "NrLGVs"=NrLGVs, "NrMCLs"=NrMCLs, "NrTaxis"=NrTaxis, "NrPCLs"=NrPCLs, "NrEScooters"=NrEScooters, "NrDocklessPCLs"=NrDocklessPCLs, "NrOGVs"=NrOGVs, "NrMiniBuses"=NrMiniBuses, "NrBuses"=NrBuses, 
				"NrSpaces"=NrSpaces, "DoubleParkingDetails"=DoubleParkingDetails,
				"NrCars_Suspended"=NrCars_Suspended, "NrLGVs_Suspended"=NrLGVs_Suspended, "NrMCLs_Suspended"=NrMCLs_Suspended, "NrTaxis_Suspended"=NrTaxis_Suspended, "NrPCLs_Suspended"=NrPCLs_Suspended, "NrEScooters_Suspended"=NrEScooters_Suspended, 
				"NrDocklessPCLs_Suspended"=NrDocklessPCLs_Suspended, "NrOGVs_Suspended"=NrOGVs_Suspended, "NrMiniBuses_Suspended"=NrMiniBuses_Suspended, "NrBuses_Suspended"=NrBuses_Suspended
				WHERE "GeometryID" = GeometryID
				AND "SurveyID" = loop_cnt;

				UPDATE "demand"."RestrictionsInSurveys"
					SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
					"SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes",
					"Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03"
				WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
				AND "SurveyID" = loop_cnt;
				
			END LOOP;
	
    END LOOP;

END;
$do$;

-- COUNTS - Moving whole survey

-- for Counts (need to break into individual loops)
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	incorrect_survey_id INTEGER := 309;
	correct_survey_id INTEGER := 209;
BEGIN

	-- ** Assume that there is no data in correct survey id
	
	-- Move data from incorrect survey to interim survey id

        RAISE NOTICE '*****--- 1. Changing survey ID for (%) to %', incorrect_survey_id, incorrect_survey_id + 1000;
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = incorrect_survey_id + 1000
        WHERE "SurveyID" = incorrect_survey_id;

        UPDATE demand."Counts" AS c
            SET "SurveyID" = incorrect_survey_id + 1000
        WHERE "SurveyID" = incorrect_survey_id;

	-- move "blank" correct survey details to incorrect

        RAISE NOTICE '*****--- 2. Changing survey ID for (%) to % ', correct_survey_id, incorrect_survey_id;
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = incorrect_survey_id
        WHERE "SurveyID" = correct_survey_id;

        UPDATE demand."Counts" AS c
            SET "SurveyID" = incorrect_survey_id
        WHERE "SurveyID" = correct_survey_id;

	-- Move from interim to correct survey id

        RAISE NOTICE '*****--- 3. Changing survey ID for (%) to % ', incorrect_survey_id + 1000, correct_survey_id;
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = correct_survey_id
        WHERE "SurveyID" = incorrect_survey_id + 1000;

        UPDATE demand."Counts" AS c
            SET "SurveyID" = correct_survey_id
        WHERE "SurveyID" = incorrect_survey_id + 1000;

END;
$do$;
