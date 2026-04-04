/***
 Perceived supply is:
  - Demand + NrSpaces

when a bay is longer than 20m (4 spaces), if it has occupancy of less than 75%, the theoretical available spaces is used, otherwise 0
when a bay is shorter than 20m (4 spaces), if it has an occupancy of less than 50%, the theoretical available spaces is used, otherwise 0.


***/

-- Add relevant fields

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedAvailableSpaces" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedCapacityAtTimeOfSurvey" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedStress" double precision;

-- Now calculate

CREATE OR REPLACE FUNCTION "demand"."update_demand_counts"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
	 restrictionLength real := 0.0;
	 carPCU real := 0.0;
	 lgvPCU real := 0.0;
	 mclPCU real := 0.0;
	 ogvPCU real := 0.0;
	 busPCU real := 0.0;
	 pclPCU real := 0.0;
	 taxiPCU real := 0.0;
	 otherPCU real := 0.0;
	 minibusPCU real := 0.0;
	 docklesspclPCU real := 0.0;
	 escooterPCU real := 0.0;

	 NrCars INTEGER := 0;
	 NrLGVs INTEGER := 0;
	 NrMCLs INTEGER := 0;
	 NrTaxis INTEGER := 0;
	 NrPCLs INTEGER := 0;
	 NrEScooters INTEGER := 0;
	 NrDocklessPCLs INTEGER := 0;
	 NrOGVs INTEGER := 0;
	 NrMiniBuses INTEGER := 0;
	 NrBuses INTEGER := 0;
	 NrSpaces INTEGER := 0;
     Notes VARCHAR (10000);
     SuspensionReference VARCHAR (250);
     ReasonForSuspension VARCHAR (250);
     DoubleParkingDetails VARCHAR (250);
     NrCars_Suspended INTEGER := 0;
     NrLGVs_Suspended INTEGER := 0;
     NrMCLs_Suspended INTEGER := 0;
     NrTaxis_Suspended INTEGER := 0;
     NrPCLs_Suspended INTEGER := 0;
     NrEScooters_Suspended INTEGER := 0;
     NrDocklessPCLs_Suspended INTEGER := 0;
     NrOGVs_Suspended INTEGER := 0;
     NrMiniBuses_Suspended INTEGER := 0;
     NrBuses_Suspended INTEGER := 0;

     NrCarsWaiting INTEGER := 0;
     NrLGVsWaiting INTEGER := 0;
     NrMCLsWaiting INTEGER := 0;
     NrTaxisWaiting INTEGER := 0;
     NrOGVsWaiting INTEGER := 0;
     NrMiniBusesWaiting INTEGER := 0;
     NrBusesWaiting INTEGER := 0;

     NrCarsIdling INTEGER := 0;
     NrLGVsIdling INTEGER := 0;
     NrMCLsIdling INTEGER := 0;
     NrTaxisIdling INTEGER := 0;
     NrOGVsIdling INTEGER := 0;
     NrMiniBusesIdling INTEGER := 0;
     NrBusesIdling INTEGER := 0;

     NrCarsParkedIncorrectly INTEGER := 0;
     NrLGVsParkedIncorrectly INTEGER := 0;
     NrMCLsParkedIncorrectly INTEGER := 0;
     NrTaxisParkedIncorrectly INTEGER := 0;
     NrOGVsParkedIncorrectly INTEGER := 0;
     NrMiniBusesParkedIncorrectly INTEGER := 0;
     NrBusesParkedIncorrectly INTEGER := 0;

     NrCarsWithDisabledBadgeParkedInPandD INTEGER := 0;

     Supply_Capacity INTEGER := 0;
     Capacity INTEGER := 0;
     NrBays INTEGER := 0;
	 NrBaysSuspended INTEGER := 0;
	 RestrictionTypeID INTEGER;

	 controlled BOOLEAN;
	 check_exists BOOLEAN;
	 check_dual_restrictions_exists BOOLEAN;

     primary_geometry_id VARCHAR (12);
     secondary_geometry_id VARCHAR (12);
     time_period_id INTEGER;
     vehicleLength real := 0.0;
     demand_ratio real = 0.0;
     perceived_capacity_difference_ratio real := 0.0;

BEGIN

    RAISE NOTICE '--- considering capacity for (%); survey (%) ', NEW."GeometryID", NEW."SurveyID";

    ---
    select "PCU" into carPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Car';

    select "PCU" into lgvPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'LGV';

    select "PCU" into mclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'MCL';

    select "PCU" into ogvPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'OGV';

    select "PCU" into busPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Bus';

    select "PCU" into pclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'PCL';

    select "PCU" into taxiPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Taxi';

    select "PCU" into otherPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Other';

    select "PCU" into minibusPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Minibus';

    select "PCU" into docklesspclPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'Dockless PCL';

    select "PCU" into escooterPCU
        from "demand_lookups"."VehicleTypes"
        where "Description" = 'E-Scooter';


    IF carPCU IS NULL OR lgvPCU IS NULL OR mclPCU IS NULL OR ogvPCU IS NULL OR busPCU IS NULL OR
       pclPCU IS NULL OR taxiPCU IS NULL OR otherPCU IS NULL OR minibusPCU IS NULL OR docklesspclPCU IS NULL OR escooterPCU IS NULL THEN
        RAISE NOTICE '--- (%); (%); (%); (%); (%); (%); (%); (%); (%); (%); (%) ', carPCU, lgvPCU, mclPCU, ogvPCU, busPCU, pclPCU, taxiPCU, otherPCU, minibusPCU, docklesspclPCU, escooterPCU;
        RAISE EXCEPTION 'PCU parameters not available ...';
        RETURN OLD;
    END IF;

    SELECT RiS."NrCars", RiS."NrLGVs", RiS."NrMCLs", RiS."NrTaxis", RiS."NrPCLs", RiS."NrEScooters", RiS."NrDocklessPCLs", RiS."NrOGVs", RiS."NrMiniBuses", RiS."NrBuses", RiS."NrSpaces",
        RiS."Notes", RiS."DoubleParkingDetails",
        RiS."NrCars_Suspended", RiS."NrLGVs_Suspended", RiS."NrMCLs_Suspended", RiS."NrTaxis_Suspended", RiS."NrPCLs_Suspended", RiS."NrEScooters_Suspended",
        RiS."NrDocklessPCLs_Suspended", RiS."NrOGVs_Suspended", RiS."NrMiniBuses_Suspended", RiS."NrBuses_Suspended",

        RiS."NrCarsWaiting", RiS."NrLGVsWaiting", RiS."NrMCLsWaiting", RiS."NrTaxisWaiting", RiS."NrOGVsWaiting", RiS."NrMiniBusesWaiting", RiS."NrBusesWaiting",

        RiS."NrCarsIdling", RiS."NrLGVsIdling", RiS."NrMCLsIdling",
        RiS."NrTaxisIdling", RiS."NrOGVsIdling", RiS."NrMiniBusesIdling",
        RiS."NrBusesIdling"

        , RiS."NrCarsParkedIncorrectly", RiS."NrLGVsParkedIncorrectly", RiS."NrMCLsParkedIncorrectly",
        RiS."NrTaxisParkedIncorrectly", RiS."NrOGVsParkedIncorrectly", RiS."NrMiniBusesParkedIncorrectly",
        RiS."NrBusesParkedIncorrectly",

        RiS."NrCarsWithDisabledBadgeParkedInPandD",

        "NrBaysSuspended"

    INTO
        NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces,
        Notes, DoubleParkingDetails,
        NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended,
        NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended,

        NrCarsWaiting, NrLGVsWaiting, NrMCLsWaiting, NrTaxisWaiting, NrOGVsWaiting, NrMiniBusesWaiting, NrBusesWaiting,

        NrCarsIdling, NrLGVsIdling, NrMCLsIdling, NrTaxisIdling, NrOGVsIdling, NrMiniBusesIdling, NrBusesIdling

        ,NrCarsParkedIncorrectly, NrLGVsParkedIncorrectly, NrMCLsParkedIncorrectly,
        NrTaxisParkedIncorrectly, NrOGVsParkedIncorrectly, NrMiniBusesParkedIncorrectly,
        NrBusesParkedIncorrectly,

        NrCarsWithDisabledBadgeParkedInPandD

        ,NrBaysSuspended

	FROM demand."RestrictionsInSurveys" RiS
	WHERE RiS."GeometryID" = NEW."GeometryID"
	AND RiS."SurveyID" = NEW."SurveyID"
    ;

    -- From Camden where determining capacity from sections
	SELECT "Capacity", "RestrictionTypeID", "NrBays"   -- what happens if field does not exist?
    INTO Supply_Capacity, RestrictionTypeID, NrBays
	FROM mhtc_operations."Supply"
	WHERE "GeometryID" = NEW."GeometryID";

    NEW."Demand" = COALESCE(NrCars::float, 0.0) * carPCU +
        COALESCE(NrLGVs::float, 0.0) * lgvPCU +
        COALESCE(NrMCLs::float, 0.0) * mclPCU +
        COALESCE(NrOGVs::float, 0.0) * ogvPCU + COALESCE(NrMiniBuses::float, 0.0) * minibusPCU +
        COALESCE(NrBuses::float, 0.0) * busPCU +
        COALESCE(NrTaxis::float, 0.0) * taxiPCU +
        COALESCE(NrPCLs::float, 0.0) * pclPCU +
        COALESCE(NrEScooters::float, 0.0) * escooterPCU +
        COALESCE(NrDocklessPCLs::float, 0.0) * docklesspclPCU +

        -- vehicles parked incorrectly
        COALESCE(NrCarsParkedIncorrectly::float, 0.0) * carPCU +
        COALESCE(NrLGVsParkedIncorrectly::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsParkedIncorrectly::float, 0.0) * mclPCU +
        COALESCE(NrOGVsParkedIncorrectly::float, 0) * ogvPCU +
        COALESCE(NrMiniBusesParkedIncorrectly::float, 0) * minibusPCU +
        COALESCE(NrBusesParkedIncorrectly::float, 0) * busPCU +
        COALESCE(NrTaxisParkedIncorrectly::float, 0) * carPCU +

        -- vehicles in P&D bay displaying disabled badge
  		COALESCE(NrCarsWithDisabledBadgeParkedInPandD::float, 0.0) * carPCU
        ;

    IF (RestrictionTypeID = 117 OR RestrictionTypeID = 118 OR   -- MCLs
		RestrictionTypeID = 119 OR RestrictionTypeID = 168 OR RestrictionTypeID = 169   -- PCL, e-Scooter, Dockless PCLs
		) THEN

            select "Value" into vehicleLength
                from "mhtc_operations"."project_parameters"
                where "Field" = 'VehicleLength';

		    NEW."Demand" = COALESCE(NrCars::float, 0.0) * vehicleLength +
                COALESCE(NrLGVs::float, 0.0) * vehicleLength +
                COALESCE(NrOGVs::float, 0.0) * vehicleLength + COALESCE(NrMiniBuses::float, 0.0) * vehicleLength + COALESCE(NrBuses::float, 0.0) * vehicleLength +
                COALESCE(NrTaxis::float, 0.0) * vehicleLength +

                -- vehicles parked incorrectly
                COALESCE(NrCarsParkedIncorrectly::float, 0.0) * vehicleLength +
                COALESCE(NrLGVsParkedIncorrectly::float, 0.0) * vehicleLength +
                COALESCE(NrMCLsParkedIncorrectly::float, 0.0) * vehicleLength +
                COALESCE(NrOGVsParkedIncorrectly::float, 0) * vehicleLength + COALESCE(NrMiniBusesParkedIncorrectly::float, 0) * vehicleLength + COALESCE(NrBusesParkedIncorrectly::float, 0) * vehicleLength +
                COALESCE(NrTaxisParkedIncorrectly::float, 0) * vehicleLength +

                -- Now consider MCLs, PCLs, e-scooters - as 1.0
                COALESCE(NrMCLs::float, 0.0) +
                COALESCE(NrPCLs::float, 0.0) +
                COALESCE(NrEScooters::float, 0.0) +
                COALESCE(NrDocklessPCLs::float, 0.0);

    END IF;

    NEW."Demand_Suspended" =
        -- include suspended vehicles
        COALESCE(NrCars_Suspended::float, 0.0) * carPCU +
        COALESCE(NrLGVs_Suspended::float, 0.0) * lgvPCU +
        COALESCE(NrMCLs_Suspended::float, 0.0) * mclPCU +
        COALESCE(NrOGVs_Suspended::float, 0) * ogvPCU +
        COALESCE(NrMiniBuses_Suspended::float, 0) * minibusPCU +
        COALESCE(NrBuses_Suspended::float, 0) * busPCU +
        COALESCE(NrTaxis_Suspended::float, 0) +
        COALESCE(NrPCLs_Suspended::float, 0.0) * pclPCU +
        COALESCE(NrEScooters_Suspended::float, 0.0) * escooterPCU +
        COALESCE(NrDocklessPCLs_Suspended::float, 0.0) * docklesspclPCU;

    NEW."Demand_Waiting" =
        -- vehicles waiting
        COALESCE(NrCarsWaiting::float, 0.0) * carPCU +
        COALESCE(NrLGVsWaiting::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsWaiting::float, 0.0) * mclPCU +
        COALESCE(NrOGVsWaiting::float, 0) * ogvPCU +
        COALESCE(NrMiniBusesWaiting::float, 0) * minibusPCU +
        COALESCE(NrBusesWaiting::float, 0) * busPCU +
        COALESCE(NrTaxisWaiting::float, 0) * carPCU;

    NEW."Demand_Idling" =
        -- vehicles idling
        COALESCE(NrCarsIdling::float, 0.0) * carPCU +
        COALESCE(NrLGVsIdling::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsIdling::float, 0.0) * mclPCU +
        COALESCE(NrOGVsIdling::float, 0) * ogvPCU +
        COALESCE(NrMiniBusesIdling::float, 0) * minibusPCU +
        COALESCE(NrBusesIdling::float, 0) * busPCU +
        COALESCE(NrTaxisIdling::float, 0) * carPCU;

    NEW."Demand_ParkedIncorrectly" =
        -- vehicles parked incorrectly
        COALESCE(NrCarsParkedIncorrectly::float, 0.0) * carPCU +
        COALESCE(NrLGVsParkedIncorrectly::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsParkedIncorrectly::float, 0.0) * mclPCU +
        COALESCE(NrOGVsParkedIncorrectly::float, 0) * ogvPCU +
        COALESCE(NrMiniBusesParkedIncorrectly::float, 0) * minibusPCU +
        COALESCE(NrBusesParkedIncorrectly::float, 0) * busPCU +
        COALESCE(NrTaxisParkedIncorrectly::float, 0) * carPCU;
        
    /* What to do about suspensions */

	IF (RestrictionTypeID = 201 OR RestrictionTypeID = 221 OR RestrictionTypeID = 224 OR   -- SYLs
	    RestrictionTypeID = 203 OR
		RestrictionTypeID = 217 OR RestrictionTypeID = 222 OR RestrictionTypeID = 226 OR   -- SRLs
		RestrictionTypeID = 227 OR RestrictionTypeID = 228 OR RestrictionTypeID = 220      -- Unmarked within PPZ
		) THEN

        -- Need to check whether or not effected by control hours

        RAISE NOTICE '--- checking SYL capacity for (%); survey (%) ', NEW."GeometryID", NEW."SurveyID";

        SELECT EXISTS INTO check_exists (
            SELECT FROM
                pg_tables
            WHERE
                schemaname = 'demand' AND
                tablename  = 'TimePeriodsControlledDuringSurveyHours'
            ) ;

        IF check_exists THEN

            SELECT "Controlled"
            INTO controlled
            FROM mhtc_operations."Supply" s, demand."TimePeriodsControlledDuringSurveyHours" t
            WHERE s."GeometryID" = NEW."GeometryID"
            AND s."NoWaitingTimeID" = t."TimePeriodID"
            AND t."SurveyID" = NEW."SurveyID";

            IF controlled THEN
                RAISE NOTICE '*****--- capacity set to 0 ...';
                Supply_Capacity = 0.0;
            END IF;

        END IF;

	END IF;

	-- Now consider dual restrictions

    SELECT EXISTS INTO check_dual_restrictions_exists (
    SELECT FROM
        pg_tables
    WHERE
        schemaname = 'mhtc_operations' AND
        tablename  = 'DualRestrictions'
    ) ;


    IF check_dual_restrictions_exists THEN
        -- check for secondary
        
		secondary_geometry_id = NULL;
		
        SELECT d."GeometryID", COALESCE(s."TimePeriodID", s."NoWaitingTimeID") AS "ControlledTimePeriodID", t."Controlled"
        INTO secondary_geometry_id, time_period_id, controlled
        FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d, demand."TimePeriodsControlledDuringSurveyHours" t
        WHERE d."GeometryID" = NEW."GeometryID"
        AND s."GeometryID" = d."GeometryID"
        AND COALESCE(s."TimePeriodID", s."NoWaitingTimeID") = t."TimePeriodID"
        AND t."SurveyID" = NEW."SurveyID";

        IF secondary_geometry_id IS NOT NULL THEN

            -- restriction is "secondary". Need to check whether or not the linked restriction is active
            RAISE NOTICE '*****--- % Secondary restriction. Checking time period % ...', NEW."GeometryID", time_period_id;

            IF controlled THEN
                IF RestrictionTypeID > 200 THEN
                    RAISE NOTICE '*****--- Secondary restriction controlled and is line. Setting capacity set to 0 ...';
                    Supply_Capacity = 0.0;
                END IF;
            ELSE
                RAISE NOTICE '*****--- Secondary restriction is not active. Setting capacity set to 0 ...';
                Supply_Capacity = 0.0;
            END IF;

        END IF;

        -- Now check for Primary

        SELECT d."GeometryID", COALESCE(s."TimePeriodID", s."NoWaitingTimeID") AS "ControlledTimePeriodID", t."Controlled"
        INTO secondary_geometry_id, time_period_id, controlled
        FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d, demand."TimePeriodsControlledDuringSurveyHours" t
        WHERE d."LinkedTo" = NEW."GeometryID"
        AND s."GeometryID" = d."GeometryID"
        AND COALESCE(s."TimePeriodID", s."NoWaitingTimeID") = t."TimePeriodID"
        AND t."SurveyID" = NEW."SurveyID";

        IF secondary_geometry_id IS NOT NULL THEN

            -- restriction is "primary". Need to check whether or not the secondary is active
            RAISE NOTICE '*****--- % Primary restriction. Checking details for secondary restriction time period % ...', secondary_geometry_id, time_period_id;

            IF controlled THEN
                RAISE NOTICE '*****--- Secondary restriction is active. Setting capacity set to 0 ...';
                Supply_Capacity = 0.0;
            END IF;

        END IF;

    END IF;

    Capacity = COALESCE(Supply_Capacity::float, 0.0) - COALESCE(NrBaysSuspended::float, 0.0);
    IF Capacity < 0.0 THEN
        Capacity = 0.0;
    END IF;
    NEW."SupplyCapacity" = Supply_Capacity;
    NEW."CapacityAtTimeOfSurvey" = Capacity;

    -- Perceived supply / stress

    NEW."PerceivedCapacityAtTimeOfSurvey" = NEW."CapacityAtTimeOfSurvey";
    NEW."PerceivedAvailableSpaces" = NEW."CapacityAtTimeOfSurvey" - NEW."Demand";

    IF NEW."CapacityAtTimeOfSurvey" > 0 AND NrBays < 0 AND RestrictionTypeID < 200
    AND NOT (RestrictionTypeID = 117 OR RestrictionTypeID = 118 OR   -- MCLs
		RestrictionTypeID = 119 OR RestrictionTypeID = 168 OR RestrictionTypeID = 169)   -- PCL, e-Scooter, Dockless PCLs
    THEN  -- Only consider unmarked bays

        demand_ratio = NEW."Demand" / NEW."CapacityAtTimeOfSurvey";

        IF NrSpaces IS NOT NULL THEN

            IF (NEW."CapacityAtTimeOfSurvey" <= 4 AND demand_ratio > 0.5) OR
               (NEW."CapacityAtTimeOfSurvey" > 4 AND demand_ratio > 0.75) THEN

                NEW."PerceivedCapacityAtTimeOfSurvey" = NEW."Demand" + NrSpaces;
                NEW."PerceivedAvailableSpaces" = NrSpaces;
                IF NEW."PerceivedCapacityAtTimeOfSurvey" > NEW."CapacityAtTimeOfSurvey" THEN
                    NEW."PerceivedCapacityAtTimeOfSurvey" = NEW."CapacityAtTimeOfSurvey";
                    NEW."PerceivedAvailableSpaces" = NEW."CapacityAtTimeOfSurvey" - NEW."Demand";
                END IF;

            END IF;

        ELSE   -- No NrSpaces provided ...

            IF (NEW."CapacityAtTimeOfSurvey" <= 4 AND demand_ratio > 0.5) OR
               (NEW."CapacityAtTimeOfSurvey" > 4 AND demand_ratio > 0.75) THEN

                    NEW."PerceivedCapacityAtTimeOfSurvey" = NEW."Demand";
                    NEW."PerceivedAvailableSpaces" = 0;

            END IF;

        END IF;

    ELSE

        NEW."PerceivedCapacityAtTimeOfSurvey" = NEW."CapacityAtTimeOfSurvey";
        NEW."PerceivedAvailableSpaces" = NEW."CapacityAtTimeOfSurvey" - NEW."Demand";

    END IF;

    -- final check
    IF NEW."PerceivedCapacityAtTimeOfSurvey" < 0 THEN
        NEW."PerceivedCapacityAtTimeOfSurvey" = 0;
    END IF;

    IF NEW."PerceivedAvailableSpaces" < 0 THEN
        NEW."PerceivedAvailableSpaces" = 0;
    END IF;

    IF NEW."CapacityAtTimeOfSurvey" <= 0.0 THEN
        IF NEW."Demand" > 0.0 THEN
            NEW."Stress" = 1.0;
        ELSE
            NEW."Stress" = 0.0;
        END IF;
    ELSE
        NEW."Stress" = NEW."Demand"::float / NEW."CapacityAtTimeOfSurvey"::float;
    END IF;

    -- perceived stress
    IF NEW."PerceivedCapacityAtTimeOfSurvey" <= 0.0 THEN
        IF NEW."Demand" > 0.0 THEN
            NEW."PerceivedStress" = 1.0;
        ELSE
            NEW."PerceivedStress" = 0.0;
        END IF;
    ELSE
        NEW."PerceivedStress" = NEW."Demand"::float / NEW."PerceivedCapacityAtTimeOfSurvey"::float;
    END IF;

	RETURN NEW;

END;
$$;

-- create trigger

DROP TRIGGER IF EXISTS update_demand ON demand."RestrictionsInSurveys";
CREATE TRIGGER "update_demand" BEFORE INSERT OR UPDATE ON "demand"."RestrictionsInSurveys" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand_counts"();

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

