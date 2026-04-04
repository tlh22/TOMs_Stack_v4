*** Copy details ***/

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
	
	source_survey_id INTEGER = 104;
	destination_survey_id INTEGER = 102;
	survey_area TEXT = z;
	--time_stamp_end TIMESTAMP = p; -- '2025-11-26 06:00:00'
	
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
        FROM "demand"."RestrictionsInSurveys" RiS, "mhtc_operations"."Supply" s, mhtc_operations."SurveyAreas" a
        WHERE RiS."SurveyID" = source_survey_id
		AND RiS."GeometryID" = s."GeometryID"
		AND s."SurveyAreaID" = a."Code"
		AND a."SurveyAreaName" = survey_area
		AND RiS."Done" is true
		--AND RiS."DemandSurveyDateTime" < timestamp time_stamp_end

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

						
			RAISE NOTICE '*****--- Copying details from survey ID % for % (into %)', relevant_restriction_in_survey."SurveyID", GeometryID, destination_survey_id;

			UPDATE demand."Counts"
			SET "NrCars"=NrCars, "NrLGVs"=NrLGVs, "NrMCLs"=NrMCLs, "NrTaxis"=NrTaxis, "NrPCLs"=NrPCLs, "NrEScooters"=NrEScooters, "NrDocklessPCLs"=NrDocklessPCLs, "NrOGVs"=NrOGVs, "NrMiniBuses"=NrMiniBuses, "NrBuses"=NrBuses, 
			"NrSpaces"=NrSpaces, "DoubleParkingDetails"=DoubleParkingDetails,
			"NrCars_Suspended"=NrCars_Suspended, "NrLGVs_Suspended"=NrLGVs_Suspended, "NrMCLs_Suspended"=NrMCLs_Suspended, "NrTaxis_Suspended"=NrTaxis_Suspended, "NrPCLs_Suspended"=NrPCLs_Suspended, "NrEScooters_Suspended"=NrEScooters_Suspended, 
			"NrDocklessPCLs_Suspended"=NrDocklessPCLs_Suspended, "NrOGVs_Suspended"=NrOGVs_Suspended, "NrMiniBuses_Suspended"=NrMiniBuses_Suspended, "NrBuses_Suspended"=NrBuses_Suspended
			WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
			AND "SurveyID" = destination_survey_id;

			UPDATE "demand"."RestrictionsInSurveys"
				SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
				"SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes"
				--, "Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03"
			WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
			AND "SurveyID" = destination_survey_id;
	
    END LOOP;

END;
$do$;
