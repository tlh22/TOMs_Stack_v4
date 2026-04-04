/***
 * When data is entered into wrong restriction, need to move to correct one
 ***/

-- for VRMs
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	--curr_survey_id INTEGER := 1001;
	curr_GeometryID VARCHAR := 'S_001099';
	new_GeometryID VARCHAR := 'S_001100';
BEGIN


    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", 
		RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", 
		RiS."Photos_01", RiS."Photos_02", RiS."Photos_03", RiS."CaptureSource"
		
		,RiS."Demand", RiS."SupplyCapacity", RiS."CapacityAtTimeOfSurvey", RiS."Stress", 
		RiS."Demand_Residents", RiS."Demand_Commuters", RiS."Demand_Visitors"
            FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."GeometryID" = curr_GeometryID
        AND RiS."Done" IS true
        --AND RiS."SurveyID" = curr_survey_id

    LOOP

        RAISE NOTICE '*****--- Processing % moving to (%) for [%]', curr_GeometryID, new_GeometryID, relevant_restriction_in_survey."SurveyID";


            UPDATE "demand"."RestrictionsInSurveys"
                SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
                "SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes",
                "Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03", "CaptureSource"=relevant_restriction_in_survey."CaptureSource"

				,"Demand"=relevant_restriction_in_survey."Demand", "SupplyCapacity"=relevant_restriction_in_survey."SupplyCapacity", "CapacityAtTimeOfSurvey"=relevant_restriction_in_survey."CapacityAtTimeOfSurvey", 
				"Stress"=relevant_restriction_in_survey."Stress", 
				"Demand_Residents"=relevant_restriction_in_survey."Demand_Residents", "Demand_Commuters"=relevant_restriction_in_survey."Demand_Commuters", "Demand_Visitors"=relevant_restriction_in_survey."Demand_Visitors"

            WHERE "GeometryID" = new_GeometryID
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

            -- Now add VRMs

            UPDATE "demand"."VRMs"
            SET "GeometryID" = new_GeometryID
            WHERE "GeometryID" = curr_GeometryID
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

            -- Now tidy up ...

            UPDATE "demand"."RestrictionsInSurveys"
            SET "Done" = false, "Enumerator" = NULL, "DemandSurveyDateTime" = NULL, "SuspensionReference" = NULL,
            "SuspensionReason" = NULL, "SuspensionLength" = NULL, "NrBaysSuspended"=NULL, "SuspensionNotes"=NULL,
            "Photos_01"=NULL, "Photos_02"=NULL, "Photos_03"=NULL, "CaptureSource"=NULL
			
			,"Demand"=NULL, "SupplyCapacity"=NULL, "CapacityAtTimeOfSurvey"=NULL, "Stress"=NULL, 
			"Demand_Residents"=NULL, "Demand_Commuters"=NULL, "Demand_Visitors"=NULL

            WHERE "GeometryID" = curr_GeometryID
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";


    END LOOP;

END;
$do$;

-- for Counts
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	--curr_survey_id INTEGER := 1001;
	curr_GeometryID VARCHAR := 'S_001099';
	new_GeometryID VARCHAR := 'S_001100';
BEGIN


    FOR relevant_restriction_in_survey IN
        SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", 
		RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", 
		RiS."Photos_01", RiS."Photos_02", RiS."Photos_03", RiS."CaptureSource"
		
		,RiS."Demand", RiS."SupplyCapacity", RiS."CapacityAtTimeOfSurvey", RiS."Stress", 
		--RiS."Demand_Residents", RiS."Demand_Commuters", RiS."Demand_Visitors", 
		
		"NrCars", "NrLGVs", "NrMCLs", "NrTaxis", "NrPCLs", "NrEScooters", "NrDocklessPCLs", "NrOGVs", "NrMiniBuses", "NrBuses", "NrSpaces", "Notes", 
		
		"DoubleParkingDetails", 
		
		"NrCars_Suspended", "NrLGVs_Suspended", "NrMCLs_Suspended", "NrTaxis_Suspended", "NrPCLs_Suspended", "NrEScooters_Suspended", 
		"NrDocklessPCLs_Suspended", "NrOGVs_Suspended", "NrMiniBuses_Suspended", "NrBuses_Suspended", 
		
		"NrCarsIdling", "NrLGVsIdling", "NrMCLsIdling", "NrTaxisIdling", "NrOGVsIdling", "NrMiniBusesIdling", "NrBusesIdling", 

		"NrCarsParkedIncorrectly", "NrLGVsParkedIncorrectly", "NrMCLsParkedIncorrectly",  
		"NrTaxisParkedIncorrectly", "NrOGVsParkedIncorrectly", "NrMiniBusesParkedIncorrectly", 
		"NrBusesParkedIncorrectly", 
		
		"NrCarsWithDisabledBadgeParkedInPandD", "MCL_Notes", "Supply_Notes", "Parking_Notes", 
		
		"PerceivedAvailableSpaces", "PerceivedCapacityAtTimeOfSurvey", "PerceivedStress", 
		
		"Demand_Suspended", "Demand_Waiting", "Demand_Idling", 
		"Demand_ParkedIncorrectly", 
		
		"NrCarsWaiting", "NrLGVsWaiting", "NrMCLsWaiting", "NrTaxisWaiting", "NrOGVsWaiting", "NrMiniBusesWaiting", "NrBusesWaiting"

        FROM "demand"."RestrictionsInSurveys" RiS
        WHERE RiS."GeometryID" = curr_GeometryID
        AND RiS."Done" IS true
        --AND RiS."SurveyID" = curr_survey_id

    LOOP

        RAISE NOTICE '*****--- Processing % moving to (%) for [%]', curr_GeometryID, new_GeometryID, relevant_restriction_in_survey."SurveyID";


            UPDATE "demand"."RestrictionsInSurveys"
                SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
                "SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes",
                "Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03", "CaptureSource"=relevant_restriction_in_survey."CaptureSource"

				,"Demand"=relevant_restriction_in_survey."Demand", "SupplyCapacity"=relevant_restriction_in_survey."SupplyCapacity", "CapacityAtTimeOfSurvey"=relevant_restriction_in_survey."CapacityAtTimeOfSurvey", 
				"Stress"=relevant_restriction_in_survey."Stress", 
				--"Demand_Residents"=relevant_restriction_in_survey."Demand_Residents", "Demand_Commuters"=relevant_restriction_in_survey."Demand_Commuters", "Demand_Visitors"=relevant_restriction_in_survey."Demand_Visitors",
				
				"NrCars"=relevant_restriction_in_survey."NrCars", "NrLGVs"=relevant_restriction_in_survey."NrLGVs", "NrMCLs"=relevant_restriction_in_survey."NrMCLs", 
				"NrTaxis"=relevant_restriction_in_survey."NrTaxis", "NrPCLs"=relevant_restriction_in_survey."NrPCLs", "NrEScooters"=relevant_restriction_in_survey."NrEScooters", 
				"NrDocklessPCLs"=relevant_restriction_in_survey."NrDocklessPCLs", "NrOGVs"=relevant_restriction_in_survey."NrOGVs", "NrMiniBuses"=relevant_restriction_in_survey."NrMiniBuses", 
				"NrBuses"=relevant_restriction_in_survey."NrBuses", "NrSpaces"=relevant_restriction_in_survey."NrSpaces", "Notes"=relevant_restriction_in_survey."Notes", 
		
				"DoubleParkingDetails"=relevant_restriction_in_survey."DoubleParkingDetails", 
		
				"NrCars_Suspended"=relevant_restriction_in_survey."NrCars_Suspended", "NrLGVs_Suspended"=relevant_restriction_in_survey."NrLGVs_Suspended", "NrMCLs_Suspended"=relevant_restriction_in_survey."NrMCLs_Suspended", 
				"NrTaxis_Suspended"=relevant_restriction_in_survey."NrTaxis_Suspended", "NrPCLs_Suspended"=relevant_restriction_in_survey."NrPCLs_Suspended", "NrEScooters_Suspended"=relevant_restriction_in_survey."NrEScooters_Suspended", 
				"NrDocklessPCLs_Suspended"=relevant_restriction_in_survey."NrDocklessPCLs_Suspended", "NrOGVs_Suspended"=relevant_restriction_in_survey."NrOGVs_Suspended", 
				"NrMiniBuses_Suspended"=relevant_restriction_in_survey."NrMiniBuses_Suspended", "NrBuses_Suspended"=relevant_restriction_in_survey."NrBuses_Suspended", 
		
				"NrCarsIdling"=relevant_restriction_in_survey."NrCarsIdling", "NrLGVsIdling"=relevant_restriction_in_survey."NrLGVsIdling", "NrMCLsIdling"=relevant_restriction_in_survey."NrMCLsIdling", 
				"NrTaxisIdling"=relevant_restriction_in_survey."NrTaxisIdling", "NrOGVsIdling"=relevant_restriction_in_survey."NrOGVsIdling", "NrMiniBusesIdling"=relevant_restriction_in_survey."NrMiniBusesIdling", 
				"NrBusesIdling"=relevant_restriction_in_survey."NrBusesIdling", 

				"NrCarsParkedIncorrectly"=relevant_restriction_in_survey."NrCarsParkedIncorrectly", "NrLGVsParkedIncorrectly"=relevant_restriction_in_survey."NrLGVsParkedIncorrectly", 
				"NrMCLsParkedIncorrectly"=relevant_restriction_in_survey."NrMCLsParkedIncorrectly", "NrTaxisParkedIncorrectly"=relevant_restriction_in_survey."NrTaxisParkedIncorrectly", 
				"NrOGVsParkedIncorrectly"=relevant_restriction_in_survey."NrOGVsParkedIncorrectly", "NrMiniBusesParkedIncorrectly"=relevant_restriction_in_survey."NrMiniBusesParkedIncorrectly", 
				"NrBusesParkedIncorrectly"=relevant_restriction_in_survey."NrBusesParkedIncorrectly", 
		
				"NrCarsWithDisabledBadgeParkedInPandD"=relevant_restriction_in_survey."NrCarsWithDisabledBadgeParkedInPandD", 
				"MCL_Notes"=relevant_restriction_in_survey."MCL_Notes", "Supply_Notes"=relevant_restriction_in_survey."Supply_Notes", "Parking_Notes"=relevant_restriction_in_survey."Parking_Notes", 
		
				"PerceivedAvailableSpaces"=relevant_restriction_in_survey."PerceivedAvailableSpaces", "PerceivedCapacityAtTimeOfSurvey"=relevant_restriction_in_survey."PerceivedCapacityAtTimeOfSurvey", 
				"PerceivedStress"=relevant_restriction_in_survey."PerceivedStress", 
		
				"Demand_Suspended"=relevant_restriction_in_survey."Demand_Suspended", "Demand_Waiting"=relevant_restriction_in_survey."Demand_Waiting", "Demand_Idling"=relevant_restriction_in_survey."Demand_Idling", 
				"Demand_ParkedIncorrectly"=relevant_restriction_in_survey."Demand_ParkedIncorrectly", 
		
				"NrCarsWaiting"=relevant_restriction_in_survey."NrCarsWaiting", "NrLGVsWaiting"=relevant_restriction_in_survey."NrLGVsWaiting", "NrMCLsWaiting"=relevant_restriction_in_survey."NrMCLsWaiting", 
				"NrTaxisWaiting"=relevant_restriction_in_survey."NrTaxisWaiting", "NrOGVsWaiting"=relevant_restriction_in_survey."NrOGVsWaiting", "NrMiniBusesWaiting"=relevant_restriction_in_survey."NrMiniBusesWaiting", 
				"NrBusesWaiting"=relevant_restriction_in_survey."NrBusesWaiting"


            WHERE "GeometryID" = new_GeometryID
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

            -- Now add VRMs

            UPDATE "demand"."Counts"
            SET
				"NrCars"=relevant_restriction_in_survey."NrCars", "NrLGVs"=relevant_restriction_in_survey."NrLGVs", "NrMCLs"=relevant_restriction_in_survey."NrMCLs", 
				"NrTaxis"=relevant_restriction_in_survey."NrTaxis", "NrPCLs"=relevant_restriction_in_survey."NrPCLs", "NrEScooters"=relevant_restriction_in_survey."NrEScooters", 
				"NrDocklessPCLs"=relevant_restriction_in_survey."NrDocklessPCLs", "NrOGVs"=relevant_restriction_in_survey."NrOGVs", "NrMiniBuses"=relevant_restriction_in_survey."NrMiniBuses", 
				"NrBuses"=relevant_restriction_in_survey."NrBuses", "NrSpaces"=relevant_restriction_in_survey."NrSpaces", "Notes"=relevant_restriction_in_survey."Notes", 
		
				"DoubleParkingDetails"=relevant_restriction_in_survey."DoubleParkingDetails", 
		
				"NrCars_Suspended"=relevant_restriction_in_survey."NrCars_Suspended", "NrLGVs_Suspended"=relevant_restriction_in_survey."NrLGVs_Suspended", "NrMCLs_Suspended"=relevant_restriction_in_survey."NrMCLs_Suspended", 
				"NrTaxis_Suspended"=relevant_restriction_in_survey."NrTaxis_Suspended", "NrPCLs_Suspended"=relevant_restriction_in_survey."NrPCLs_Suspended", "NrEScooters_Suspended"=relevant_restriction_in_survey."NrEScooters_Suspended", 
				"NrDocklessPCLs_Suspended"=relevant_restriction_in_survey."NrDocklessPCLs_Suspended", "NrOGVs_Suspended"=relevant_restriction_in_survey."NrOGVs_Suspended", 
				"NrMiniBuses_Suspended"=relevant_restriction_in_survey."NrMiniBuses_Suspended", "NrBuses_Suspended"=relevant_restriction_in_survey."NrBuses_Suspended", 
		
				"NrCarsIdling"=relevant_restriction_in_survey."NrCarsIdling", "NrLGVsIdling"=relevant_restriction_in_survey."NrLGVsIdling", "NrMCLsIdling"=relevant_restriction_in_survey."NrMCLsIdling", 
				"NrTaxisIdling"=relevant_restriction_in_survey."NrTaxisIdling", "NrOGVsIdling"=relevant_restriction_in_survey."NrOGVsIdling", "NrMiniBusesIdling"=relevant_restriction_in_survey."NrMiniBusesIdling", 
				"NrBusesIdling"=relevant_restriction_in_survey."NrBusesIdling", 

				"NrCarsParkedIncorrectly"=relevant_restriction_in_survey."NrCarsParkedIncorrectly", "NrLGVsParkedIncorrectly"=relevant_restriction_in_survey."NrLGVsParkedIncorrectly", 
				"NrMCLsParkedIncorrectly"=relevant_restriction_in_survey."NrMCLsParkedIncorrectly", "NrTaxisParkedIncorrectly"=relevant_restriction_in_survey."NrTaxisParkedIncorrectly", 
				"NrOGVsParkedIncorrectly"=relevant_restriction_in_survey."NrOGVsParkedIncorrectly", "NrMiniBusesParkedIncorrectly"=relevant_restriction_in_survey."NrMiniBusesParkedIncorrectly", 
				"NrBusesParkedIncorrectly"=relevant_restriction_in_survey."NrBusesParkedIncorrectly", 
		
				"NrCarsWithDisabledBadgeParkedInPandD"=relevant_restriction_in_survey."NrCarsWithDisabledBadgeParkedInPandD", 
				"MCL_Notes"=relevant_restriction_in_survey."MCL_Notes", "Supply_Notes"=relevant_restriction_in_survey."Supply_Notes", "Parking_Notes"=relevant_restriction_in_survey."Parking_Notes"
					
            WHERE "GeometryID" = new_GeometryID
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

            -- Now tidy up ...

            UPDATE "demand"."RestrictionsInSurveys"
            SET "Done" = false, "Enumerator" = NULL, "DemandSurveyDateTime" = NULL, "SuspensionReference" = NULL,
            "SuspensionReason" = NULL, "SuspensionLength" = NULL, "NrBaysSuspended"=NULL, "SuspensionNotes"=NULL,
            "Photos_01"=NULL, "Photos_02"=NULL, "Photos_03"=NULL, "CaptureSource"=NULL
			
			,"Demand"=NULL, "SupplyCapacity"=NULL, "CapacityAtTimeOfSurvey"=NULL, "Stress"=NULL, 
			--"Demand_Residents"=NULL, "Demand_Commuters"=NULL, "Demand_Visitors"=NULL,
			
			"NrCars"=NULL, "NrLGVs"=NULL, "NrMCLs"=NULL, "NrTaxis"=NULL, "NrPCLs"=NULL, "NrEScooters"=NULL, "NrDocklessPCLs"=NULL, "NrOGVs"=NULL, "NrMiniBuses"=NULL, "NrBuses"=NULL, "NrSpaces"=NULL, "Notes"=NULL, 
			
			"DoubleParkingDetails"=NULL, 
			
			"NrCars_Suspended"=NULL, "NrLGVs_Suspended"=NULL, "NrMCLs_Suspended"=NULL, "NrTaxis_Suspended"=NULL, "NrPCLs_Suspended"=NULL, "NrEScooters_Suspended"=NULL, 
			"NrDocklessPCLs_Suspended"=NULL, "NrOGVs_Suspended"=NULL, "NrMiniBuses_Suspended"=NULL, "NrBuses_Suspended"=NULL, 
			
			"NrCarsIdling"=NULL, "NrLGVsIdling"=NULL, "NrMCLsIdling"=NULL, "NrTaxisIdling"=NULL, "NrOGVsIdling"=NULL, "NrMiniBusesIdling"=NULL, "NrBusesIdling"=NULL, 
			
			"NrCarsParkedIncorrectly"=NULL, "NrLGVsParkedIncorrectly"=NULL, "NrMCLsParkedIncorrectly"=NULL, "NrTaxisParkedIncorrectly"=NULL, "NrOGVsParkedIncorrectly"=NULL, "NrMiniBusesParkedIncorrectly"=NULL, 
			"NrBusesParkedIncorrectly"=NULL, 
			
			"NrCarsWithDisabledBadgeParkedInPandD"=NULL, 
			
			"MCL_Notes"=NULL, "Supply_Notes"=NULL, "Parking_Notes"=NULL, 
			
			"PerceivedAvailableSpaces"=NULL, "PerceivedCapacityAtTimeOfSurvey"=NULL, "PerceivedStress"=NULL, 
			
			"Demand_Suspended"=NULL, "Demand_Waiting"=NULL, "Demand_Idling"=NULL, "Demand_ParkedIncorrectly"=NULL, "NrCarsWaiting"=NULL, "NrLGVsWaiting"=NULL, 
			"NrMCLsWaiting"=NULL, "NrTaxisWaiting"=NULL, "NrOGVsWaiting"=NULL, "NrMiniBusesWaiting"=NULL, "NrBusesWaiting"=NULL

            WHERE "GeometryID" = curr_GeometryID
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

            UPDATE "demand"."Counts"
            SET
				"NrCars"=NULL, "NrLGVs"=NULL, "NrMCLs"=NULL, "NrTaxis"=NULL, "NrPCLs"=NULL, "NrEScooters"=NULL, "NrDocklessPCLs"=NULL, "NrOGVs"=NULL, "NrMiniBuses"=NULL, "NrBuses"=NULL, "NrSpaces"=NULL, "Notes"=NULL, 
				
				"DoubleParkingDetails"=NULL, 
				
				"NrCars_Suspended"=NULL, "NrLGVs_Suspended"=NULL, "NrMCLs_Suspended"=NULL, "NrTaxis_Suspended"=NULL, "NrPCLs_Suspended"=NULL, "NrEScooters_Suspended"=NULL, 
				"NrDocklessPCLs_Suspended"=NULL, "NrOGVs_Suspended"=NULL, "NrMiniBuses_Suspended"=NULL, "NrBuses_Suspended"=NULL, 
				
				"NrCarsIdling"=NULL, "NrLGVsIdling"=NULL, "NrMCLsIdling"=NULL, "NrTaxisIdling"=NULL, "NrOGVsIdling"=NULL, "NrMiniBusesIdling"=NULL, "NrBusesIdling"=NULL, 
				
				"NrCarsParkedIncorrectly"=NULL, "NrLGVsParkedIncorrectly"=NULL, "NrMCLsParkedIncorrectly"=NULL, "NrTaxisParkedIncorrectly"=NULL, "NrOGVsParkedIncorrectly"=NULL, "NrMiniBusesParkedIncorrectly"=NULL, 
				"NrBusesParkedIncorrectly"=NULL, 
				
				"NrCarsWithDisabledBadgeParkedInPandD"=NULL
					
            WHERE "GeometryID" = curr_GeometryID
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

    END LOOP;

END;
$do$;
