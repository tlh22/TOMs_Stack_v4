/***
 * When data is entered into wrong time period, need to move to correct time period
 ***/

-- for VRMs


DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := 108;
	car_park TEXT := 'Well Street Car Park';
	--new_survey_id INTEGER := 109;
BEGIN


    FOR relevant_restriction_in_survey IN
        SELECT DISTINCT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03", RiS."CaptureSource"
            FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r --, mhtc_operations."SurveyAreas" a
        WHERE RiS."GeometryID" = r."GeometryID"
        --AND r."SurveyAreaID" = a."Code"
        --AND a."SurveyAreaName" IN ('7S-WGR')
        AND RiS."Done" IS true
        AND RiS."SurveyID" = curr_survey_id
		AND r."RoadName" = car_park
		--AND RiS."DemandSurveyDateTime" < '2022-06-29'::date
    LOOP

       RAISE NOTICE '*****--- Processing % removing from (%)', relevant_restriction_in_survey."GeometryID", curr_survey_id;

			-- Clear RiS

            UPDATE "demand"."RestrictionsInSurveys"
            SET "Done" = false, "Enumerator" = NULL, "DemandSurveyDateTime" = NULL, "SuspensionReference" = NULL,
            "SuspensionReason" = NULL, "SuspensionLength" = NULL, "NrBaysSuspended"=NULL, "SuspensionNotes"=NULL,
            "Photos_01"=NULL, "Photos_02"=NULL, "Photos_03"=NULL, "CaptureSource" = NULL
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = curr_survey_id;
		
			IF NOT FOUND THEN
				RAISE EXCEPTION 'RiS records not found';
			END IF;
			
            -- Now remove VRMs

            DELETE FROM "demand"."VRMs"
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = curr_survey_id;
	
			IF NOT FOUND THEN
				RAISE EXCEPTION 'VRM records not found';
			END IF;

    END LOOP;

END;
$do$;