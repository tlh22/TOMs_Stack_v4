/**
Check the count collected within each pass
**/

/*** 
 *   If dealing with two types of survey
 ***/

-- Check required fields exist

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_ALL" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand" double precision; -- This is the count of all vehicles in the main count tab

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "DemandInSuspendedAreas" double precision;  -- This is the count of all vehicles in the suspensions tab

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Waiting" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Idling" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_ParkedIncorrectly" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "CapacityAtTimeOfSurvey" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Stress" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedAvailableSpaces" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedCapacityAtTimeOfSurvey" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "PerceivedStress" double precision;
	
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "TheoreticalCapacityAtTimeOfSurvey" double precision;

-- Step 2: calculate demand values using trigger

-- set up trigger for demand and stress

CREATE OR REPLACE FUNCTION "demand"."update_demand_counts"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
	 --vehicleLength real := 0.0;
	 --vehicleWidth real := 0.0;
	 --motorcycleWidth real := 0.0;
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
	secondary_controlled BOOLEAN;
	primary_controlled BOOLEAN;
	check_exists BOOLEAN;
	count_survey BOOLEAN;
	check_dual_restrictions_exists BOOLEAN;

    primary_geometry_id VARCHAR (12);
    secondary_geometry_id VARCHAR (12);
    time_period_id INTEGER;
    vehicleLength real := 0.0;
	busLength real := 0.0;
    demand_ratio real = 0.0;
    perceived_capacity_difference_ratio real := 0.0;

BEGIN

	-- Check that we are dealing with VRMs
	SELECT EXISTS INTO check_exists (
	SELECT FROM
		pg_tables
	WHERE
		schemaname = 'demand' AND
		tablename  = 'Surveys_Counts'
	) ;

	IF check_exists THEN

		SELECT EXISTS
		(SELECT 1
		FROM demand."Counts" sv
		WHERE sv."SurveyID" = NEW."SurveyID")
		INTO count_survey;
		
		IF count_survey IS FALSE OR count_survey IS NULL THEN
			RETURN NEW;
		END IF;

	END IF;

    RAISE NOTICE '--- considering (%) in survey (%) ', NEW."GeometryID", NEW."SurveyID";

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


	RAISE NOTICE '*****--- Getting demand details ...';
	
    SELECT COALESCE(c."NrCars", 0), COALESCE(c."NrLGVs", 0), COALESCE(c."NrMCLs", 0), COALESCE(c."NrTaxis", 0), 
	    COALESCE(c."NrPCLs", 0), COALESCE(c."NrEScooters", 0), COALESCE(c."NrDocklessPCLs", 0), 
	    COALESCE(c."NrOGVs", 0), COALESCE(c."NrMiniBuses", 0), COALESCE(c."NrBuses", 0), 
	    COALESCE(c."NrSpaces", 0),
	    
        -- c."Notes", c."DoubleParkingDetails",
        
        COALESCE(c."NrCars_Suspended", 0), COALESCE(c."NrLGVs_Suspended", 0), COALESCE(c."NrMCLs_Suspended", 0),
        COALESCE(c."NrTaxis_Suspended", 0), COALESCE(c."NrPCLs_Suspended", 0), COALESCE(c."NrEScooters_Suspended", 0),
        COALESCE(c."NrDocklessPCLs_Suspended", 0), COALESCE(c."NrOGVs_Suspended", 0), 
        COALESCE(c."NrMiniBuses_Suspended", 0), COALESCE(c."NrBuses_Suspended", 0),

        COALESCE(c."NrCarsWaiting", 0), COALESCE(c."NrLGVsWaiting", 0), COALESCE(c."NrMCLsWaiting", 0), 
        COALESCE(c."NrTaxisWaiting", 0), COALESCE(c."NrOGVsWaiting"), COALESCE(c."NrMiniBusesWaiting", 0), 
        COALESCE(c."NrBusesWaiting", 0),

        COALESCE(c."NrCarsIdling", 0), COALESCE(c."NrLGVsIdling", 0), COALESCE(c."NrMCLsIdling", 0),
        COALESCE(c."NrTaxisIdling", 0), COALESCE(c."NrOGVsIdling", 0), COALESCE(c."NrMiniBusesIdling", 0),
        COALESCE(c."NrBusesIdling", 0),

        COALESCE(c."NrCarsParkedIncorrectly", 0), COALESCE(c."NrLGVsParkedIncorrectly", 0), COALESCE(c."NrMCLsParkedIncorrectly", 0),
        COALESCE(c."NrTaxisParkedIncorrectly", 0), COALESCE(c."NrOGVsParkedIncorrectly", 0), COALESCE(c."NrMiniBusesParkedIncorrectly", 0),
        COALESCE(c."NrBusesParkedIncorrectly", 0),

        COALESCE(c."NrCarsWithDisabledBadgeParkedInPandD", 0),

        COALESCE(RiS."NrBaysSuspended", 0)

    INTO
        NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces,
        --Notes, DoubleParkingDetails,
        NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended,
        NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended,

        NrCarsWaiting, NrLGVsWaiting, NrMCLsWaiting, NrTaxisWaiting, NrOGVsWaiting, NrMiniBusesWaiting, NrBusesWaiting,

        NrCarsIdling, NrLGVsIdling, NrMCLsIdling, NrTaxisIdling, NrOGVsIdling, NrMiniBusesIdling, NrBusesIdling,

        NrCarsParkedIncorrectly, NrLGVsParkedIncorrectly, NrMCLsParkedIncorrectly,
        NrTaxisParkedIncorrectly, NrOGVsParkedIncorrectly, NrMiniBusesParkedIncorrectly,
        NrBusesParkedIncorrectly,

        NrCarsWithDisabledBadgeParkedInPandD,

        NrBaysSuspended

	FROM demand."Counts" c, demand."RestrictionsInSurveys" RiS
	WHERE c."GeometryID" = NEW."GeometryID"
	AND c."SurveyID" = NEW."SurveyID"
	AND c."GeometryID" = RiS."GeometryID"
	AND c."SurveyID" = RiS."SurveyID";

    -- Check restriction type ...
	SELECT "Capacity", "RestrictionTypeID", "NrBays"   -- what happens if field does not exist?
    INTO Supply_Capacity, RestrictionTypeID, NrBays
	FROM mhtc_operations."Supply"
	WHERE "GeometryID" = NEW."GeometryID";

    IF (RestrictionTypeID = 117 OR RestrictionTypeID = 118 OR   -- MCLs
		RestrictionTypeID = 119 OR RestrictionTypeID = 168 OR RestrictionTypeID = 169   -- PCL, e-Scooter, Dockless PCLs
		) THEN

        select "Value" into vehicleLength
            from "mhtc_operations"."project_parameters"
            where "Field" = 'VehicleLength';

        select "Value" into busLength
            from "mhtc_operations"."project_parameters"
            where "Field" = 'BusLength';

        carPCU = vehicleLength;
        lgvPCU = vehicleLength;
        mclPCU = 1.0;
        ogvPCU = vehicleLength * 2.0;
        minibusPCU = vehicleLength * 2.0;
        busPCU = busLength;
        pclPCU = 1.0;
        escooterPCU = 1.0;
        docklesspclPCU = 1.0;

		RAISE NOTICE '--- MCL/PCL bay - changing PCU values TO %; %; %; % ', mclPCU, pclPCU, docklesspclPCU, escooterPCU;

    END IF;

    NEW."Demand_ParkedIncorrectly" =
        COALESCE(NrCarsParkedIncorrectly::float, 0.0) * carPCU +
        COALESCE(NrLGVsParkedIncorrectly::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsParkedIncorrectly::float, 0.0) * mclPCU +
        COALESCE(NrOGVsParkedIncorrectly::float, 0) * ogvPCU +
        COALESCE(NrMiniBusesParkedIncorrectly::float, 0) * minibusPCU +
        COALESCE(NrBusesParkedIncorrectly::float, 0) * busPCU +
        COALESCE(NrTaxisParkedIncorrectly::float, 0) * carPCU;

    NEW."Demand" = COALESCE(NrCars::float, 0.0) * carPCU +
        COALESCE(NrLGVs::float, 0.0) * lgvPCU +
        COALESCE(NrMCLs::float, 0.0) * mclPCU +
        COALESCE(NrOGVs::float, 0.0) * ogvPCU +
        COALESCE(NrMiniBuses::float, 0.0) * minibusPCU +
        COALESCE(NrBuses::float, 0.0) * busPCU +
        COALESCE(NrTaxis::float, 0.0) * taxiPCU +
        COALESCE(NrPCLs::float, 0.0) * pclPCU +
        COALESCE(NrEScooters::float, 0.0) * escooterPCU +
        COALESCE(NrDocklessPCLs::float, 0.0) * docklesspclPCU +

        -- vehicles parked incorrectly
        NEW."Demand_ParkedIncorrectly" +

        -- vehicles in P&D bay displaying disabled badge
  		COALESCE(NrCarsWithDisabledBadgeParkedInPandD::float, 0.0) * carPCU
        ;

    NEW."DemandInSuspendedAreas" =
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
        COALESCE(NrCarsWaiting::float, 0.0) * carPCU +
        COALESCE(NrLGVsWaiting::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsWaiting::float, 0.0) * mclPCU +
        COALESCE(NrOGVsWaiting::float, 0) * ogvPCU +
        COALESCE(NrMiniBusesWaiting::float, 0) * minibusPCU +
        COALESCE(NrBusesWaiting::float, 0) * busPCU +
        COALESCE(NrTaxisWaiting::float, 0) * carPCU;

    NEW."Demand_Idling" =
        COALESCE(NrCarsIdling::float, 0.0) * carPCU +
        COALESCE(NrLGVsIdling::float, 0.0) * lgvPCU +
        COALESCE(NrMCLsIdling::float, 0.0) * mclPCU +
        COALESCE(NrOGVsIdling::float, 0) * ogvPCU +
        COALESCE(NrMiniBusesIdling::float, 0) * minibusPCU +
        COALESCE(NrBusesIdling::float, 0) * busPCU +
        COALESCE(NrTaxisIdling::float, 0) * carPCU;


    NEW."Demand_ALL" =
        NEW."Demand" +
        NEW."Demand_Waiting" +
        NEW."Demand_Idling" +
        NEW."DemandInSuspendedAreas";

	RAISE NOTICE '*****--- demand is %. (ALL = %) ...', NEW."Demand", NEW."Demand_ALL";

    /* What to do about suspensions */

	RAISE NOTICE '*****--- Checking SYLs ...';
	
	IF (RestrictionTypeID = 201 OR RestrictionTypeID = 221 OR RestrictionTypeID = 224 OR   -- SYLs
		RestrictionTypeID = 217 OR RestrictionTypeID = 222 OR RestrictionTypeID = 226 OR   -- SRLs
		-- RestrictionTypeID = 227 OR RestrictionTypeID = 228 OR RestrictionTypeID = 229 OR   -- Unmarked within PPZ
		RestrictionTypeID = 203 OR RestrictionTypeID = 207 OR RestrictionTypeID = 208      -- ZigZags
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

            SELECT "Controlled", t."TimePeriodID"
            INTO controlled, time_period_id
            FROM mhtc_operations."Supply" s, demand."TimePeriodsControlledDuringSurveyHours" t
            WHERE s."GeometryID" = NEW."GeometryID"
            AND s."NoWaitingTimeID" = t."TimePeriodID"
            AND t."SurveyID" = NEW."SurveyID";

			RAISE NOTICE '*****--- SYL ... time period id: %; controlled = %', time_period_id, controlled;
			
            IF controlled THEN
                RAISE NOTICE '*****--- capacity set to 0 ...';
                Supply_Capacity = 0.0;
            END IF;

        ELSE
            RAISE EXCEPTION 'TimePeriodsControlledDuringSurveyHours does not exist ...';
            RETURN OLD;
        END IF;

	END IF;

	-- Now consider dual restrictions

	RAISE NOTICE '*****--- Checking dual restrictions ... Capacity = %', Supply_Capacity;
	
    SELECT EXISTS INTO check_dual_restrictions_exists (
    SELECT FROM
        pg_tables
    WHERE
        schemaname = 'mhtc_operations' AND
        tablename  = 'DualRestrictions'
    ) ;

    IF check_dual_restrictions_exists THEN
        -- check for primary

        SELECT d."GeometryID", "LinkedTo", COALESCE("TimePeriodID", "NoWaitingTimeID") AS "ControlledTimePeriodID"
        INTO secondary_geometry_id, primary_geometry_id, time_period_id
        FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d
        WHERE s."GeometryID" = d."LinkedTo"
        AND d."LinkedTo" = NEW."GeometryID";

        IF primary_geometry_id IS NOT NULL THEN

            -- restriction is "primary". Need to check whether or not the linked restriction is active
            RAISE NOTICE '*****--- % is a primary restriction. Checking if secondary is active in time period % ...', NEW."GeometryID", time_period_id;

			-- check whether or not secondary restriction is controlled
			SELECT "Controlled"
			INTO secondary_controlled
			FROM demand."TimePeriodsControlledDuringSurveyHours" t
			WHERE t."TimePeriodID" IN
				(SELECT COALESCE("TimePeriodID", "NoWaitingTimeID") AS "ControlledTimePeriodID"
				 FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d
				 WHERE s."GeometryID" = d."GeometryID"
				 AND d."LinkedTo" = NEW."GeometryID")
			AND t."SurveyID" = NEW."SurveyID";
			
			IF secondary_controlled THEN
		
				RAISE NOTICE '*****--- Secondary restriction is controlled ...';
				Supply_Capacity = 0.0;
				
			END IF;

        END IF;

        -- Now check for secondary

        SELECT d."GeometryID", "LinkedTo", COALESCE("TimePeriodID", "NoWaitingTimeID") AS "ControlledTimePeriodID"
        INTO secondary_geometry_id, primary_geometry_id, time_period_id
        FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d
        WHERE s."GeometryID" = d."GeometryID"
        AND d."GeometryID" = NEW."GeometryID";

        IF secondary_geometry_id IS NOT NULL THEN

            -- restriction is "secondary". Need to check whether or not it is active
            RAISE NOTICE '*****--- % is secondary restriction to (%). Checking if secondary is active during time period % ...', NEW."GeometryID", primary_geometry_id, time_period_id;

            SELECT "Controlled"
            INTO secondary_controlled
            FROM demand."TimePeriodsControlledDuringSurveyHours" t
            WHERE t."TimePeriodID" = time_period_id
            AND t."SurveyID" = NEW."SurveyID";

            IF NOT secondary_controlled OR secondary_controlled IS NULL THEN
			
                RAISE NOTICE '*****--- Secondary restriction is not controlled. Setting capacity set to 0 ...';
                Supply_Capacity = 0.0;
				
			/***
			ELSE
			
			    RAISE NOTICE '*****--- Secondary restriction is controlled. Checking primary ...';
				
				-- Secondary restriction is controlled. Need to check whether or not primary is also active. If primary is active, it overrides.
				SELECT "Controlled"
				INTO primary_controlled
				FROM demand."TimePeriodsControlledDuringSurveyHours" t
				WHERE t."TimePeriodID" IN
					(SELECT COALESCE("TimePeriodID", "NoWaitingTimeID") AS "ControlledTimePeriodID"
					 FROM mhtc_operations."Supply" s, mhtc_operations."DualRestrictions" d
					 WHERE s."GeometryID" = d."LinkedTo"
					 AND d."GeometryID" = NEW."GeometryID")
				AND t."SurveyID" = NEW."SurveyID";
				
				IF primary_controlled THEN
					RAISE NOTICE '*****--- Primary restriction is controlled. Setting capacity to 0 ...';
					Supply_Capacity = 0.0;
				ELSE
					RAISE NOTICE '*****--- Primary restriction is not controlled ...';
				END IF;
				***/
            END IF;

        END IF;

    ELSE
        RAISE EXCEPTION 'DualRestrictions does not exist ...';
        RETURN OLD;
    END IF;

	NEW."TheoreticalCapacityAtTimeOfSurvey" = Supply_Capacity;

	RAISE NOTICE '*****--- After dual restrictions ... Capacity = %', Supply_Capacity;
	
	-- take account of suspensions
	
    Capacity = COALESCE(Supply_Capacity::float, 0.0) - COALESCE(NrBaysSuspended::float, 0.0);
    IF Capacity < 0.0 THEN
        Capacity = 0.0;
    END IF;

    NEW."CapacityAtTimeOfSurvey" = Capacity;
	
	-- To provide realistic amounts of suspended spaces, remove extras.
	IF NrBaysSuspended::float > Supply_Capacity::float THEN
		NEW."NrBaysSuspended" = Supply_Capacity;
	END IF;

	RAISE NOTICE '*****--- After suspensions ... Capacity = %', Capacity;
    -- Perceived supply / stress

    /***
     Perceived supply is Demand + NrSpaces

    when a bay is longer than 20m (4 spaces), if it has occupancy of less than 75%, the theoretical available spaces is used, otherwise 0
    when a bay is shorter than 20m (4 spaces), if it has an occupancy of less than 50%, the theoretical available spaces is used, otherwise 0.

    ***/

    NEW."PerceivedCapacityAtTimeOfSurvey" = NEW."CapacityAtTimeOfSurvey";
    NEW."PerceivedAvailableSpaces" = NEW."CapacityAtTimeOfSurvey" - NEW."Demand";

    IF NEW."CapacityAtTimeOfSurvey" > 0 AND NrBays < 0 --AND RestrictionTypeID < 200
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
CREATE TRIGGER "update_demand" BEFORE UPDATE ON "demand"."RestrictionsInSurveys" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand_counts"();

-- DROP TRIGGER IF EXISTS update_demand_counts ON demand."Counts";
-- CREATE TRIGGER "update_demand_counts" AFTER UPDATE ON "demand"."Counts" FOR EACH ROW EXECUTE FUNCTION "demand"."update_demand_counts"();

-- trigger trigger

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";


-- Check details


SELECT su."SurveyID", "SurveyAreaName", SUM("Demand")
FROM demand."Surveys" su, demand."RestrictionsInSurveys" RiS,
(SELECT s."GeometryID", "SurveyAreas"."SurveyAreaName"
 FROM mhtc_operations."Supply" s LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code") AS d
WHERE su."SurveyID" = RiS."SurveyID"
AND d."GeometryID" = RiS."GeometryID"
AND su."SurveyID" > 0
GROUP BY su."SurveyID", "SurveyAreaName"
ORDER BY "SurveyAreaName", su."SurveyID"

/***
SELECT RiS."SurveyID", SUM("Demand")
FROM demand."RestrictionsInSurveys" RiS
WHERE RiS."SurveyID" > 0
GROUP BY RiS."SurveyID"
ORDER BY RiS."SurveyID"
***/


/***
Southwark

UPDATE "demand"."RestrictionsInSurveys" AS RiS
SET "Photos_03" = "Photos_03"
FROM mhtc_operations."Supply" a
	LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE RiS."GeometryID" = a."GeometryID"
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I');

***/