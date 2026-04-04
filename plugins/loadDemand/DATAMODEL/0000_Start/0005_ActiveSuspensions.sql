/***
Setup details for demand
***/

DROP TABLE IF EXISTS demand."ActiveSuspensions" CASCADE;

CREATE TABLE demand."ActiveSuspensions"
(
    gid INT GENERATED ALWAYS AS IDENTITY,
    "SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom geometry(LineString,27700),
    UNIQUE ("SurveyID", "GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE demand."ActiveSuspensions"
    OWNER to postgres;

ALTER TABLE demand."ActiveSuspensions"
ADD UNIQUE ("SurveyID", "GeometryID");

/***

INSERT INTO demand."ActiveSuspensions" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", gid::text AS "GeometryID", r.geom As geom
FROM mhtc_operations."RC_Sections_merged" r, demand."Surveys";
***/

-- OR

INSERT INTO demand."ActiveSuspensions" ("SurveyID", "GeometryID")
SELECT "SurveyID", "GeometryID"
FROM demand."RestrictionsInSurveys" ris
WHERE ris."NrBaysSuspended" > 0;

--

ALTER TABLE demand."ActiveSuspensions"
    ADD COLUMN IF NOT EXISTS "RestrictionTypeID" integer;

ALTER TABLE demand."ActiveSuspensions"
    ADD COLUMN IF NOT EXISTS "GeomShapeID" integer;
    
ALTER TABLE demand."ActiveSuspensions"
    ADD COLUMN IF NOT EXISTS "AzimuthToRoadCentreLine" double precision;
    
UPDATE demand."ActiveSuspensions" AS a
SET "RestrictionTypeID" = s."RestrictionTypeID",
	"GeomShapeID" = s."GeomShapeID",
	"AzimuthToRoadCentreLine" = s."AzimuthToRoadCentreLine"
FROM mhtc_operations."Supply" s
WHERE a."GeometryID" = s."GeometryID";

/***
UPDATE demand."ActiveSuspensions" AS a
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE a."GeometryID" = s."GeometryID";
***/

-- Now deal with geometry ...

DO
$do$
DECLARE

     row1 RECORD;
     row2 RECORD;
          
	 vehicleLength real := 0.0;
	 vehicleWidth real := 0.0;
	 
	 survey_id integer;
	 geometry_id text;
	 capacity integer;
	 restriction_capacity integer;
	 new_capacity integer;
	 demand real;
	 new_demand real;
	 nr_bays_suspended integer;
	 suspension_ratio real;
	 
BEGIN

	-- Get vehicle length
	
    select "Value" into vehicleLength
    from "mhtc_operations"."project_parameters"
    where "Field" = 'VehicleLength';
    
    select "Value" into vehicleWidth
    from "mhtc_operations"."project_parameters"
    where "Field" = 'VehicleWidth';
            
		
    -- Now consider the details in ActiveSuspensions
    
    FOR row1 IN 
    	SELECT "SurveyID", "GeometryID"
    	FROM demand."ActiveSuspensions"
		
	LOOP
	
		-- get capacity for restriction
		
		SELECT "CapacityAtTimeOfSurvey", "Demand", "NrBaysSuspended"
		INTO restriction_capacity, demand, nr_bays_suspended
		FROM demand."RestrictionsInSurveys"
		WHERE "SurveyID" = row1."SurveyID"
		AND "GeometryID" = row1."GeometryID";
		
		/***
		Now deal with geometry
		***/
		
		suspension_ratio = nr_bays_suspended::float / restriction_capacity::float;
		
		RAISE NOTICE '***** SurveyID: %, GeometryID: % suspension_ratio: % % %', row1."SurveyID", row1."GeometryID", suspension_ratio, nr_bays_suspended, restriction_capacity;

		UPDATE demand."ActiveSuspensions" AS a
		SET geom = ST_LineSubstring(RiS.geom, 0.0, suspension_ratio)
		FROM demand."RestrictionsInSurveys" RiS
		WHERE RiS."SurveyID" = row1."SurveyID"
		AND RiS."GeometryID" = row1."GeometryID"
		AND RiS."SurveyID" = a."SurveyID"
		AND RiS."GeometryID" = a."GeometryID";
    		
    END LOOP;    
	
END
$do$;



