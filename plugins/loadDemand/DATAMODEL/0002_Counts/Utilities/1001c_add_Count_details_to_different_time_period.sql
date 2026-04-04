/***
 * This was used for RBKC 2022 to over write data entered into the wrong time period
 ***/

-- for Counts (need to break into individual loops)
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := 102;
	new_survey_id INTEGER := 102;
BEGIN

    FOR relevant_restriction_in_survey IN

		SELECT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", 
		RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03", 
		RiS."NrCars", RiS."NrLGVs", RiS."NrMCLs", RiS."NrTaxis", RiS."NrPCLs", RiS."NrEScooters", RiS."NrDocklessPCLs", RiS."NrOGVs", 
		RiS."NrMiniBuses", RiS."NrBuses", RiS."NrSpaces", RiS."Notes", RiS."DoubleParkingDetails", 
		RiS."NrCars_Suspended", RiS."NrLGVs_Suspended", RiS."NrMCLs_Suspended", RiS."NrTaxis_Suspended", 
		RiS."NrPCLs_Suspended", RiS."NrEScooters_Suspended", RiS."NrDocklessPCLs_Suspended", 
		RiS."NrOGVs_Suspended", RiS."NrMiniBuses_Suspended", RiS."NrBuses_Suspended", RiS."NrCarsIdling", 
		RiS."NrCarsParkedIncorrectly", RiS."NrLGVsIdling", RiS."NrLGVsParkedIncorrectly", RiS."NrMCLsIdling", 
		RiS."NrMCLsParkedIncorrectly", RiS."NrTaxisIdling", RiS."NrTaxisParkedIncorrectly", RiS."NrOGVsIdling", 
		RiS."NrOGVsParkedIncorrectly", RiS."NrMiniBusesIdling", RiS."NrMiniBusesParkedIncorrectly", RiS."NrBusesIdling", 
		RiS."NrBusesParkedIncorrectly", RiS."NrCarsWithDisabledBadgeParkedInPandD", 
		RiS."MCL_Notes", RiS."Supply_Notes", RiS."Parking_Notes", RiS."NrCarsWaiting", RiS."NrLGVsWaiting", RiS."NrMCLsWaiting", 
		RiS."NrTaxisWaiting", RiS."NrOGVsWaiting", RiS."NrMiniBusesWaiting", RiS."NrBusesWaiting", RiS."Demand", 
		RiS."SupplyCapacity", RiS."CapacityAtTimeOfSurvey", RiS."Stress", RiS."Demand_Suspended", RiS."Demand_Waiting", 
		RiS."Demand_Idling", RiS."PerceivedAvailableSpaces", RiS."PerceivedCapacityAtTimeOfSurvey", RiS."PerceivedStress", RiS."CaptureSource"
        FROM mhtc_operations."RestrictionsInSurveys_Green" RiS, 
        (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
        WHERE RiS."GeometryID" = s."GeometryID"
        AND s."SurveyAreaName" IN ('3-A')
        --AND RiS."Done" IS true
        AND RiS."SurveyID" = curr_survey_id
		--AND RiS."DemandSurveyDateTime" < '2022-06-29'::date
    LOOP

        --IF current_done IS false or current_done IS NULL THEN

            RAISE NOTICE '*****--- Processing % copying from (%) to (%)', relevant_restriction_in_survey."GeometryID", curr_survey_id, new_survey_id;

            UPDATE "demand"."RestrictionsInSurveys"
                SET "DemandSurveyDateTime"=relevant_restriction_in_survey."DemandSurveyDateTime", "Enumerator"=relevant_restriction_in_survey."Enumerator", "Done"=relevant_restriction_in_survey."Done", "SuspensionReference"=relevant_restriction_in_survey."SuspensionReference",
                "SuspensionReason"=relevant_restriction_in_survey."SuspensionReason", "SuspensionLength"=relevant_restriction_in_survey."SuspensionLength", "NrBaysSuspended"=relevant_restriction_in_survey."NrBaysSuspended", "SuspensionNotes"=relevant_restriction_in_survey."SuspensionNotes",
                "Photos_01"=relevant_restriction_in_survey."Photos_01", "Photos_02"=relevant_restriction_in_survey."Photos_02", "Photos_03"=relevant_restriction_in_survey."Photos_03",

                "CaptureSource"=relevant_restriction_in_survey."CaptureSource",
                "Demand"=relevant_restriction_in_survey."Demand",
                "CapacityAtTimeOfSurvey"=relevant_restriction_in_survey."CapacityAtTimeOfSurvey", "Stress"=relevant_restriction_in_survey."Stress",
                "SupplyCapacity"=relevant_restriction_in_survey."SupplyCapacity",

				"Demand_Suspended"=relevant_restriction_in_survey."Demand_Suspended", "Demand_Waiting"=relevant_restriction_in_survey."Demand_Waiting", 
				"Demand_Idling"=relevant_restriction_in_survey."Demand_Idling", "PerceivedAvailableSpaces"=relevant_restriction_in_survey."PerceivedAvailableSpaces", 
				"PerceivedCapacityAtTimeOfSurvey"=relevant_restriction_in_survey."PerceivedCapacityAtTimeOfSurvey", "PerceivedStress"=relevant_restriction_in_survey."PerceivedStress",

			"NrCars"=relevant_restriction_in_survey."NrCars", "NrLGVs"=relevant_restriction_in_survey."NrLGVs", "NrMCLs"=relevant_restriction_in_survey."NrMCLs", "NrTaxis"=relevant_restriction_in_survey."NrTaxis", "NrPCLs"=relevant_restriction_in_survey."NrPCLs", "NrEScooters"=relevant_restriction_in_survey."NrEScooters",
	        "NrDocklessPCLs"=relevant_restriction_in_survey."NrDocklessPCLs", "NrOGVs"=relevant_restriction_in_survey."NrOGVs", "NrMiniBuses"=relevant_restriction_in_survey."NrMiniBuses", "NrBuses"=relevant_restriction_in_survey."NrBuses", "NrSpaces"=relevant_restriction_in_survey."NrSpaces", "Notes"=relevant_restriction_in_survey."Notes", "DoubleParkingDetails"=relevant_restriction_in_survey."DoubleParkingDetails",
	        "NrCars_Suspended"=relevant_restriction_in_survey."NrCars_Suspended", "NrLGVs_Suspended"=relevant_restriction_in_survey."NrLGVs_Suspended", "NrMCLs_Suspended"=relevant_restriction_in_survey."NrMCLs_Suspended",
	        "NrTaxis_Suspended"=relevant_restriction_in_survey."NrTaxis_Suspended", "NrPCLs_Suspended"=relevant_restriction_in_survey."NrPCLs_Suspended", "NrEScooters_Suspended"=relevant_restriction_in_survey."NrEScooters_Suspended",
	        "NrDocklessPCLs_Suspended"=relevant_restriction_in_survey."NrDocklessPCLs_Suspended", "NrOGVs_Suspended"=relevant_restriction_in_survey."NrOGVs_Suspended", "NrMiniBuses_Suspended"=relevant_restriction_in_survey."NrMiniBuses_Suspended", "NrBuses_Suspended"=relevant_restriction_in_survey."NrBuses_Suspended"

            ,"NrCarsWaiting"=relevant_restriction_in_survey."NrCarsWaiting",
            "NrLGVsWaiting"=relevant_restriction_in_survey."NrLGVsWaiting",
            "NrMCLsWaiting"=relevant_restriction_in_survey."NrMCLsWaiting",
            "NrTaxisWaiting"=relevant_restriction_in_survey."NrTaxisWaiting",
            "NrOGVsWaiting"=relevant_restriction_in_survey."NrOGVsWaiting",
            "NrMiniBusesWaiting"=relevant_restriction_in_survey."NrMiniBusesWaiting",
            "NrBusesWaiting"=relevant_restriction_in_survey."NrBusesWaiting",

            "NrCarsIdling"=relevant_restriction_in_survey."NrCarsIdling",
            "NrLGVsIdling"=relevant_restriction_in_survey."NrLGVsIdling",
            "NrMCLsIdling"=relevant_restriction_in_survey."NrMCLsIdling",
            "NrTaxisIdling"=relevant_restriction_in_survey."NrTaxisIdling",
            "NrOGVsIdling"=relevant_restriction_in_survey."NrOGVsIdling",
            "NrMiniBusesIdling"=relevant_restriction_in_survey."NrMiniBusesIdling",
            "NrBusesIdling"=relevant_restriction_in_survey."NrBusesIdling",

            "NrCarsWithDisabledBadgeParkedInPandD"=relevant_restriction_in_survey."NrCarsWithDisabledBadgeParkedInPandD"
            
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = new_survey_id;
            
        --ELSE

            --RAISE NOTICE '*****--- % already has details on survey id (%) ', relevant_restriction_in_survey."GeometryID", new_survey_id;

       -- END IF;

    END LOOP;

END;
$do$;