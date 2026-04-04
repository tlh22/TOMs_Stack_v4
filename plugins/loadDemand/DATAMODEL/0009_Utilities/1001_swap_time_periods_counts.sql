/***

Swap time periods for survey area 

***/


DO
$do$
DECLARE
    relevant_restriction_in_first_survey RECORD;
	relevant_restriction_in_second_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	first_survey_id INTEGER := 202;
	second_survey_id INTEGER := 203;
	survey_area TEXT := 'M-01';
BEGIN

	-- Swapping details in "first" with "second"
	
	RAISE NOTICE '*****--- Swapping survey ID % with %', first_survey_id, second_survey_id;
		

	-- Firstly make space for the change
			
    FOR relevant_restriction_in_first_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r,  mhtc_operations."SurveyAreas" a
        WHERE RiS."SurveyID" = first_survey_id
		AND RiS."GeometryID" = r."GeometryID"
		--AND RiS."Done" IS true
		AND r."SurveyAreaID" = a."Code"
		AND a."SurveyAreaName" IN (survey_area)
    LOOP

        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = relevant_restriction_in_first_survey."SurveyID" + 1000
        WHERE "GeometryID" = relevant_restriction_in_first_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_first_survey."SurveyID";
		
		UPDATE demand."Counts" AS c
            SET "SurveyID" = relevant_restriction_in_first_survey."SurveyID" + 1000
        WHERE "GeometryID" = relevant_restriction_in_first_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_first_survey."SurveyID";
				
    END LOOP;

	-- Now move second to first	
	
    FOR relevant_restriction_in_second_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r,  mhtc_operations."SurveyAreas" a
        WHERE RiS."SurveyID" = second_survey_id
		AND RiS."GeometryID" = r."GeometryID"
		--AND RiS."Done" IS true
		AND r."SurveyAreaID" = a."Code"
		AND a."SurveyAreaName" IN (survey_area)
    LOOP
	
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = first_survey_id
        WHERE "GeometryID" = relevant_restriction_in_second_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_second_survey."SurveyID";

        UPDATE demand."Counts" AS c
            SET "SurveyID" = first_survey_id
        WHERE "GeometryID" = relevant_restriction_in_second_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_second_survey."SurveyID";

    END LOOP;

	-- Now move first to second
	
    FOR relevant_restriction_in_first_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r,  mhtc_operations."SurveyAreas" a
        WHERE RiS."SurveyID" = first_survey_id + 1000
		AND RiS."GeometryID" = r."GeometryID"
		--AND RiS."Done" IS true
		AND r."SurveyAreaID" = a."Code"
		AND a."SurveyAreaName" IN (survey_area)
    LOOP
		
        UPDATE "demand"."RestrictionsInSurveys"
            SET "SurveyID" = second_survey_id
        WHERE "GeometryID" = relevant_restriction_in_first_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_first_survey."SurveyID";
		
		UPDATE demand."Counts" AS c
            SET "SurveyID" = second_survey_id
        WHERE "GeometryID" = relevant_restriction_in_first_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_first_survey."SurveyID";
				
    END LOOP;

END;
$do$;
