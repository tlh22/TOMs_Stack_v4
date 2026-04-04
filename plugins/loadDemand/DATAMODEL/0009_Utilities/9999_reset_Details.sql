-- Remove "Done" flag and clear any details

UPDATE demand."RestrictionsInSurveys_FPB" AS ris
SET "DemandSurveyDateTime" = NULL, "Enumerator" = NULL, "Done" = NULL, "SuspensionReference" = NULL, "SuspensionReason" = NULL,
"SuspensionLength" = NULL, "NrBaysSuspended" = NULL, "SuspensionNotes" = NULL, "Photos_01" = NULL, "Photos_02" = NULL, "Photos_03" = NULL

-- actually this is not needed ...

FROM demand."Surveys" su, mhtc_operations."Supply_MASTER_210318" s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 AND s."CPZ" = 'FPC'
 AND substring(su."BeatTitle" from '\((.+)\)') LIKE 'FPC'


-- reset VRMs


SELECT v.*
FROM demand."VRMs" v, mhtc_operations."Supply_MASTER_210318" su
	 	, demand."Surveys" s
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = su."GeometryID"
AND su."CPZ" = 'FPB'
ORDER BY "GeometryID", "VRM", "SurveyID"



SELECT v."ID", v."SurveyID", s."BeatTitle", v."GeometryID", su."RoadName",
		v."PositionID", v."VRM", v."VehicleTypeID", v."VehicleType Description",
        v."RestrictionTypeID", v."RestrictionType Description",
        v."PermitTypeID", v."PermitType Description",
        v."Notes"

FROM
(SELECT "ID", "SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description",
        "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        "Notes"

FROM
     (((demand."VRMs" AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")

ORDER BY "GeometryID", "VRM") As v,
	 	mhtc_operations."Supply_MASTER_210318" su
	 	, demand."Surveys" s
WHERE v."SurveyID" = s."SurveyID"
AND v."GeometryID" = su."GeometryID"
AND su."CPZ" = 'FP'
ORDER BY "GeometryID", "VRM", "SurveyID"

--- Clear counts

-- Remove "Done" flag and clear any details

UPDATE demand."RestrictionsInSurveys" AS ris
SET "DemandSurveyDateTime" = NULL, "Enumerator" = NULL, "Done" = NULL, "SuspensionReference" = NULL, "SuspensionReason" = NULL,
"SuspensionLength" = NULL, "NrBaysSuspended" = NULL, "SuspensionNotes" = NULL, "Photos_01" = NULL, "Photos_02" = NULL, "Photos_03" = NULL
WHERE "SurveyID" >=201
AND "SurveyID" <= 212
AND "GeometryID" IN (SELECT DISTINCT r."GeometryID"
                            FROM mhtc_operations."Supply" r
                            WHERE r."SurveyArea" IN ('2')
                            )


-- remove VRMs and clear RiS
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := 101;
	--new_survey_id INTEGER := 109;
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT DISTINCT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
        WHERE RiS."GeometryID" = r."GeometryID"
        AND r."SurveyAreaID" = a."Code"
        --AND a."SurveyAreaName" IN ('7S-6')
        AND RiS."Done" IS true
        AND RiS."SurveyID" = curr_survey_id
		--AND RiS."DemandSurveyDateTime" < '2022-06-29'::date
    LOOP

        -- check to see if the restriction already has a value
        SELECT "Done"
        INTO current_done
        FROM "demand"."RestrictionsInSurveys"
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = curr_survey_id;

        IF current_done IS true THEN

            RAISE NOTICE '*****--- Clearing % from (%) ', relevant_restriction_in_survey."GeometryID", curr_survey_id;

            UPDATE "demand"."RestrictionsInSurveys"
            SET "DemandSurveyDateTime" = NULL, "Enumerator" = NULL, "Done" = NULL, "SuspensionReference" = NULL, "SuspensionReason" = NULL,
            "SuspensionLength" = NULL, "NrBaysSuspended" = NULL, "SuspensionNotes" = NULL, "Photos_01" = NULL, "Photos_02" = NULL, "Photos_03" = NULL
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = curr_survey_id;

            -- Now remove VRMs

            DELETE FROM "demand"."VRMs"
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = curr_survey_id;

        END IF;

    END LOOP;

END;
$do$;

-- verify clearance
SELECT RiS."SurveyID", "SurveyAreaName", RiS."GeometryID"
FROM "demand_WGR"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
WHERE RiS."Done" is 'true'
AND RiS."GeometryID" = r."GeometryID"
AND r."SurveyAreaID" = a."Code"
AND a."SurveyAreaName" = '7S-7'

-- clear Count and RiS
DO
$do$
DECLARE
    relevant_restriction_in_survey RECORD;
    clone_restriction_id uuid;
    current_done BOOLEAN := false;
	curr_survey_id INTEGER := 101;
BEGIN

    FOR relevant_restriction_in_survey IN
        SELECT DISTINCT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", 
			RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", 
			RiS."Photos_01", RiS."Photos_02", RiS."Photos_03",		
			RiS."CaptureSource", 
			RiS."NrCars", RiS."NrLGVs", RiS."NrMCLs", RiS."NrTaxis", RiS."NrPCLs", RiS."NrEScooters", RiS."NrDocklessPCLs", RiS."NrOGVs", RiS."NrMiniBuses", RiS."NrBuses", RiS."NrSpaces", RiS."Notes", 
			RiS."DoubleParkingDetails", 
			RiS."NrCars_Suspended", RiS."NrLGVs_Suspended", RiS."NrMCLs_Suspended", RiS."NrTaxis_Suspended", RiS."NrPCLs_Suspended", RiS."NrEScooters_Suspended", RiS."NrDocklessPCLs_Suspended", 
			RiS."NrOGVs_Suspended", RiS."NrMiniBuses_Suspended", RiS."NrBuses_Suspended", 
			RiS."NrCarsIdling", RiS."NrCarsParkedIncorrectly", RiS."NrLGVsIdling", RiS."NrLGVsParkedIncorrectly", RiS."NrMCLsIdling", RiS."NrMCLsParkedIncorrectly", RiS."NrTaxisIdling", 
			RiS."NrTaxisParkedIncorrectly", RiS."NrOGVsIdling", RiS."NrOGVsParkedIncorrectly", RiS."NrMiniBusesIdling", RiS."NrMiniBusesParkedIncorrectly", RiS."NrBusesIdling", 
			RiS."NrBusesParkedIncorrectly", 
			RiS."NrCarsWithDisabledBadgeParkedInPandD", 
			RiS."MCL_Notes", RiS."Supply_Notes", RiS."Parking_Notes", 
			RiS."PerceivedAvailableSpaces", RiS."PerceivedCapacityAtTimeOfSurvey", RiS."PerceivedStress", 
			RiS."Demand", RiS."SupplyCapacity", RiS."CapacityAtTimeOfSurvey", RiS."Stress", RiS."Demand_Suspended", RiS."Demand_Waiting", RiS."Demand_Idling", 
			RiS."NrCarsWaiting", RiS."NrLGVsWaiting", RiS."NrMCLsWaiting", RiS."NrTaxisWaiting", RiS."NrOGVsWaiting", RiS."NrMiniBusesWaiting", RiS."NrBusesWaiting"

        FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
        WHERE RiS."GeometryID" = r."GeometryID"
        AND r."SurveyAreaID" = a."Code"
        --AND a."SurveyAreaName" IN ('C-2')
        AND RiS."Done" IS true
        --AND RiS."SurveyID" = curr_survey_id
		--AND RiS."DemandSurveyDateTime" > '2022-09-26'::date
    LOOP

        -- check to see if the restriction already has a value
        SELECT "Done"
        INTO current_done
        FROM "demand"."RestrictionsInSurveys"
        WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
        AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        IF current_done IS true THEN

            RAISE NOTICE '*****--- Clearing % from (%) ', relevant_restriction_in_survey."GeometryID", relevant_restriction_in_survey."SurveyID";

            UPDATE "demand"."RestrictionsInSurveys"
            SET "DemandSurveyDateTime" = NULL, "Enumerator" = NULL, "Done" = NULL, "SuspensionReference" = NULL, "SuspensionReason" = NULL,
            "SuspensionLength" = NULL, "NrBaysSuspended" = NULL, "SuspensionNotes" = NULL, "Photos_01" = NULL, "Photos_02" = NULL, "Photos_03" = NULL,
			"CaptureSource" = NULL, 
			"NrCars" = NULL, "NrLGVs" = NULL, "NrMCLs" = NULL, "NrTaxis" = NULL, "NrPCLs" = NULL, "NrEScooters" = NULL, "NrDocklessPCLs" = NULL, "NrOGVs" = NULL, "NrMiniBuses" = NULL, "NrBuses" = NULL, "NrSpaces" = NULL, "Notes" = NULL, 
			"DoubleParkingDetails" = NULL, 
			"NrCars_Suspended" = NULL, "NrLGVs_Suspended" = NULL, "NrMCLs_Suspended" = NULL, "NrTaxis_Suspended" = NULL, "NrPCLs_Suspended" = NULL, "NrEScooters_Suspended" = NULL, "NrDocklessPCLs_Suspended" = NULL, 
			"NrOGVs_Suspended" = NULL, "NrMiniBuses_Suspended" = NULL, "NrBuses_Suspended" = NULL, 
			"NrCarsIdling" = NULL, "NrCarsParkedIncorrectly" = NULL, "NrLGVsIdling" = NULL, "NrLGVsParkedIncorrectly" = NULL, "NrMCLsIdling" = NULL, "NrMCLsParkedIncorrectly" = NULL, 
			"NrTaxisIdling" = NULL, "NrTaxisParkedIncorrectly" = NULL, "NrOGVsIdling" = NULL, "NrOGVsParkedIncorrectly" = NULL, "NrMiniBusesIdling" = NULL, "NrMiniBusesParkedIncorrectly" = NULL, 
			"NrBusesIdling" = NULL, "NrBusesParkedIncorrectly" = NULL, 
			"NrCarsWithDisabledBadgeParkedInPandD" = NULL, 
			"MCL_Notes" = NULL, "Supply_Notes" = NULL, "Parking_Notes" = NULL, 
			"PerceivedAvailableSpaces" = NULL, "PerceivedCapacityAtTimeOfSurvey" = NULL, "PerceivedStress" = NULL, 
			"Demand" = NULL, "SupplyCapacity" = NULL, "CapacityAtTimeOfSurvey" = NULL, "Stress" = NULL, 
			"Demand_Suspended" = NULL, "Demand_Waiting" = NULL, "Demand_Idling" = NULL, 
			"NrCarsWaiting" = NULL, "NrLGVsWaiting" = NULL, "NrMCLsWaiting" = NULL, "NrTaxisWaiting" = NULL, "NrOGVsWaiting" = NULL, "NrMiniBusesWaiting" = NULL, "NrBusesWaiting" = NULL

            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

            -- Now reset Counts

            UPDATE demand."Counts"
            SET "NrCars"=NULL, "NrLGVs"=NULL, "NrMCLs"=NULL, "NrTaxis"=NULL, "NrPCLs"=NULL, "NrEScooters"=NULL,
                "NrDocklessPCLs"=NULL, "NrOGVs"=NULL, "NrMiniBuses"=NULL, "NrBuses"=NULL, "NrSpaces"=NULL, "Notes"=NULL,
                "DoubleParkingDetails"=NULL,
                "NrCars_Suspended"=NULL, "NrLGVs_Suspended"=NULL, "NrMCLs_Suspended"=NULL, "NrTaxis_Suspended"=NULL, "NrPCLs_Suspended"=NULL,
                "NrEScooters_Suspended"=NULL, "NrDocklessPCLs_Suspended"=NULL, "NrOGVs_Suspended"=NULL, "NrMiniBuses_Suspended"=NULL,
                "NrBuses_Suspended"=NULL,
				"NrCarsWaiting"=NULL, "NrLGVsWaiting"=NULL, "NrMCLsWaiting"=NULL, "NrTaxisWaiting"=NULL, "NrOGVsWaiting"=NULL, "NrMiniBusesWaiting"=NULL, "NrBusesWaiting"=NULL,
				"NrCarsIdling"=NULL, "NrLGVsIdling"=NULL, "NrMCLsIdling"=NULL,
				"NrTaxisIdling"=NULL, "NrOGVsIdling"=NULL, "NrMiniBusesIdling"=NULL,
				"NrBusesIdling"=NULL

                /***
                ,"NrCarsParkedIncorrectly"=NULL, "NrLGVsParkedIncorrectly"=NULL,
                "NrMCLsParkedIncorrectly"=NULL, "NrTaxisParkedIncorrectly"=NULL,
                "NrOGVsParkedIncorrectly"=NULL, "NrMiniBusesParkedIncorrectly"=NULL,
                "NrBusesParkedIncorrectly"=NULL,
                "NrCarsWithDisabledBadgeParkedInPandD"=NULL
                ***/

            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        END IF;

    END LOOP;

END;
$do$;

