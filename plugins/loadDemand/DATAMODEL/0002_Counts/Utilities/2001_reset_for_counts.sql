/***
 * Reset details for Counts - for reload
 
 --- Remember that you need to change over details in both RiS and Counts!
 
SELECT *
FROM "Counts" c, "RestrictionsInSurveys" RiS
WHERE c."GeometryID" = RiS."GeometryID"
AND RiS."SurveyID" = c."SurveyID"
AND c."SurveyID" = 101
AND RiS."Done" IS true
AND RiS."GeometryID" IN (
	SELECT "GeometryID" 
	FROM "Supply" s
	WHERE s."SurveyAreaID" = 5
	 )
;


SELECT *
FROM "Counts" c, "RestrictionsInSurveys" RiS
WHERE c."GeometryID" = RiS."GeometryID"
AND RiS."SurveyID" = c."SurveyID"
AND c."SurveyID" = 1010


In this case, details for 104 were entered into 101 for area 5 (id=5). So need to swap details around within Counts. RiS has already been dealt with ...

Step 1: Change SurveyID for all restrictions in target SurveyID
UPDATE "Counts" AS c
SET "SurveyID" = 1010
FROM "RestrictionsInSurveys" RiS
WHERE c."GeometryID" = RiS."GeometryID"
AND c."SurveyID" = RiS."SurveyID"
AND RiS."SurveyID" = 101
AND RiS."Done" IS true
AND RiS."GeometryID" IN (
	SELECT "GeometryID" 
	FROM "Supply" s
	WHERE s."SurveyAreaID" = 5
	 );

UPDATE "RestrictionsInSurveys" AS RiS
SET "SurveyID" = 1010
WHERE RiS."SurveyID" = 101
AND RiS."Done" IS true
AND RiS."GeometryID" IN (
	SELECT "GeometryID" 
	FROM "Supply" s
	WHERE s."SurveyAreaID" = 5
	 )
;

Step 2: Change SurveyID from correct
UPDATE "Counts" AS c1
SET "SurveyID" = 101
FROM "Counts" c2
WHERE c1."GeometryID" = c2."GeometryID"
AND c1."SurveyID" = 104
AND c2."SurveyID" = 1010;

UPDATE "RestrictionsInSurveys" AS RiS1
SET "SurveyID" = 101
FROM "RestrictionsInSurveys" RiS2
WHERE RiS1."GeometryID" = RiS2."GeometryID"
AND RiS1."SurveyID" = 104
AND RiS2."SurveyID" = 1010;


Step 3: Change SurveyID from 1010 to correct
UPDATE "Counts" AS c
SET "SurveyID" = 104
WHERE c."SurveyID" = 1010;

UPDATE "RestrictionsInSurveys" AS RiS
SET "SurveyID" = 104
WHERE RiS."SurveyID" = 1010;
 

 ***/

-- Remove additional columns

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys" DROP COLUMN IF EXISTS "Demand";
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys" DROP COLUMN IF EXISTS "SupplyCapacity";
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys" DROP COLUMN IF EXISTS "CapacityAtTimeOfSurvey";
ALTER TABLE IF EXISTS demand."RestrictionsInSurveys" DROP COLUMN IF EXISTS "Stress";

DROP TRIGGER IF EXISTS update_demand ON demand."RestrictionsInSurveys";

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
        SELECT DISTINCT RiS."SurveyID", RiS."GeometryID", RiS."DemandSurveyDateTime", RiS."Enumerator", RiS."Done", RiS."SuspensionReference", RiS."SuspensionReason", RiS."SuspensionLength", RiS."NrBaysSuspended", RiS."SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
            FROM "demand"."RestrictionsInSurveys" RiS, mhtc_operations."Supply" r, mhtc_operations."SurveyAreas" a
        WHERE RiS."GeometryID" = r."GeometryID"
        AND r."SurveyAreaID" = a."Code"
        --AND a."SurveyAreaName" IN ('3')
        AND RiS."Done" IS true
        AND RiS."SurveyID" = curr_survey_id
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
			"Demand"=NULL, "SupplyCapacity"=NULL, "CapacityAtTimeOfSurvey"=NULL, "Stress"=NULL
            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

            -- Now reset Counts

            UPDATE demand."Counts"
                SET
                "NrCars"=NULL, "NrLGVs"=NULL, "NrMCLs"=NULL, "NrTaxis"=NULL, "NrPCLs"=NULL, "NrEScooters"=NULL,
                "NrDocklessPCLs"=NULL, "NrOGVs"=NULL, "NrMiniBuses"=NULL, "NrBuses"=NULL, "NrSpaces"=NULL, "Notes"=NULL,

                "DoubleParkingDetails"=NULL,

                "NrCars_Suspended"=NULL, "NrLGVs_Suspended"=NULL, "NrMCLs_Suspended"=NULL, "NrTaxis_Suspended"=NULL, "NrPCLs_Suspended"=NULL,
                "NrEScooters_Suspended"=NULL, "NrDocklessPCLs_Suspended"=NULL, "NrOGVs_Suspended"=NULL, "NrMiniBuses_Suspended"=NULL,
                "NrBuses_Suspended"=NULL,

                "NrCarsWaiting"=NULL, "NrLGVsWaiting"=NULL, "NrMCLsWaiting"=NULL, "NrTaxisWaiting"=NULL, "NrOGVsWaiting"=NULL,
                "NrMiniBusesWaiting"=NULL, "NrBusesWaiting"=NULL,

                "NrCarsIdling"=NULL, "NrLGVsIdling"=NULL, "NrMCLsIdling"=NULL, "NrTaxisIdling"=NULL, "NrOGVsIdling"=NULL,
                "NrMiniBusesIdling"=NULL, "NrBusesIdling"=NULL,

                "NrCarsParkedIncorrectly"=NULL, "NrLGVsParkedIncorrectly"=NULL, "NrMCLsParkedIncorrectly"=NULL,
                "NrOGVsParkedIncorrectly"=NULL, "NrMiniBusesParkedIncorrectly"=NULL, "NrBusesParkedIncorrectly"=NULL
                , "NrCarsWithDisabledBadgeParkedInPandD"=NULL

            WHERE "GeometryID" = relevant_restriction_in_survey."GeometryID"
            AND "SurveyID" = relevant_restriction_in_survey."SurveyID";

        END IF;

    END LOOP;

END;
$do$;

