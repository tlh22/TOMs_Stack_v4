-- Active suspensions ...

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
		
		suspension_ratio = nr_bays_suspended / restriction_capacity;
		
		IF suspension_ratio > 1.0 THEN
			suspension_ratio = 1.0;
		END IF;
		
		INSERT INTO demand."ActiveSuspensions" (geom)
		SELECT ST_LineSubstring(geom, 1.0-suspension_ratio, 1.0)
		FROM demand."RestrictionsInSurveys"
		WHERE "SurveyID" = row1."SurveyID"
		AND "GeometryID" = row1."GeometryID";
    		
    END LOOP;    
	
END
$do$;

