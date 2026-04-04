/***

Create table for output of duration for ALL vehicles with vehicle type and permit type

Used for creation of pivot like table for spreadsheet
All VRMs for spreadsheet

***/


CREATE OR REPLACE FUNCTION anpr."All_VRMs"(default_permit_type integer,
									car_park_nr integer) RETURNS integer AS $$


        BEGIN

DROP TABLE IF EXISTS anpr."DurationDetails" CASCADE;

CREATE TABLE anpr."DurationDetails" AS

SELECT "CarParkID"
        , "CarParkDescription"
        , "VRM"
		, "AnonomisedVRM"
		, "VehicleTypeID"
		, "VehicleTypeDescription"
		, "PermitTypeID"
		, "PermitTypeDescription"
		, "Site_IN"
		, "Site_OUT"
		, "Time_IN"
		, "Time_OUT"
		, "TimePeriodID_IN"
		, "TimePeriodID_OUT"
		, "SurveyDay"
		, "TimePeriodDescription_IN"
		, "TimePeriodDescription_OUT"
		, "Duration"
		, COALESCE("DurationCategoryID", 14) AS "DurationCategoryID"
		, "DurationCategoryDescription"
		
FROM (

		SELECT v1."CarParkID"
		       , c."Description" AS "CarParkDescription"
			   , v1."VRM"
			   , v1."AnonomisedVRM"
			   , v1."SiteID" AS "Site_IN"
			   , v2."SiteID" AS "Site_OUT"
			   , v1."VehicleTypeID"
			   , v1."VehicleTypeDescription"
			   , v1."PermitTypeID"
			   , v1."PermitTypeDescription"
			   , TO_CHAR(v1."CaptureTime", 'Day (dd/mm)') AS "SurveyDay"
			   
			   , v1."CaptureTime" AS "Time_IN"

 			   , CASE WHEN v1."CaptureTime"::TIME <= '06:00:00'::TIME THEN NULL -- 'Start of Day'
				    WHEN v1."CaptureTime"::TIME >= '22:00:00'::TIME THEN NULL -- 'End of Day'
					ELSE (SELECT t."TimePeriodID"
					     FROM anpr."TimePeriods" t
						 WHERE v1."CaptureTime" >= t."StartTime" AND v1."CaptureTime" < t."EndTime")
					END AS "TimePeriodID_IN"
					
			   , CASE WHEN v1."CaptureTime"::TIME <= '06:00:00'::TIME THEN NULL -- 'Start of Day'
				    WHEN v1."CaptureTime"::TIME >= '22:00:00'::TIME THEN NULL -- 'End of Day'
					ELSE (SELECT CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI'))
					     FROM anpr."TimePeriods" t
						 WHERE v1."CaptureTime" >= t."StartTime" AND v1."CaptureTime" < t."EndTime")
					END AS "TimePeriodDescription_IN"

			   , v2."CaptureTime" AS "Time_OUT"
			   
			   , CASE WHEN v2."CaptureTime"::TIME <= '06:00:00'::TIME THEN NULL -- 'Start of Day'
				    WHEN v2."CaptureTime"::TIME >= '22:00:00'::TIME THEN NULL -- 'End of Day'
					ELSE (SELECT t."TimePeriodID"
					     FROM anpr."TimePeriods" t
						 WHERE v2."CaptureTime" >= t."StartTime" AND v2."CaptureTime" < t."EndTime")
					END AS "TimePeriodID_OUT"

			   , CASE WHEN v2."CaptureTime"::TIME <= '06:00:00'::TIME THEN NULL -- 'Start of Day'
				    WHEN v2."CaptureTime"::TIME >= '22:00:00'::TIME THEN NULL -- 'End of Day'
					ELSE (SELECT CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI'))
					     FROM anpr."TimePeriods" t
						 WHERE v2."CaptureTime" >= t."StartTime" AND v2."CaptureTime" < t."EndTime")
					END AS "TimePeriodDescription_OUT"

			   , CASE WHEN v1."CaptureTime"::TIME <= '06:00:00'::TIME THEN NULL -- 'Start of Day'
				    WHEN v2."CaptureTime"::TIME >= '22:00:00'::TIME THEN NULL -- 'End of Day'
					WHEN v2."CaptureTime"::TIME IS NULL THEN NULL  -- Genuinely not known
					ELSE v2."CaptureTime" - v1."CaptureTime"
					END AS "Duration"	
					
			   , CASE WHEN v1."CaptureTime"::TIME <= '06:00:00'::TIME AND v2."CaptureTime"::TIME >= '22:00:00'::TIME THEN NULL
			   		WHEN v1."CaptureTime"::TIME <= '06:00:00'::TIME THEN NULL
				    WHEN v2."CaptureTime"::TIME >= '22:00:00'::TIME THEN NULL				    
					WHEN v2."CaptureTime"::TIME IS NULL THEN NULL  -- Genuinely not known
					ELSE (SELECT "DurationCategoryID" FROM anpr."DurationCategories" d
					     WHERE (v2."CaptureTime" - v1."CaptureTime") >= d."StartTime"
						 AND (v2."CaptureTime" - v1."CaptureTime") < d."EndTime")
					END AS "DurationCategoryID"	

			   , CASE WHEN v1."CaptureTime"::TIME <= '06:00:00'::TIME AND v2."CaptureTime"::TIME >= '22:00:00'::TIME THEN 'All Day'
			   		WHEN v1."CaptureTime"::TIME <= '06:00:00'::TIME THEN 'Start of Day'
				    WHEN v2."CaptureTime"::TIME >= '22:00:00'::TIME THEN 'End of Day'				    
					WHEN v2."CaptureTime"::TIME IS NULL THEN 'Unknown'  -- Genuinely not known
					ELSE (SELECT "Description" FROM anpr."DurationCategories" d
					     WHERE (v2."CaptureTime" - v1."CaptureTime") >= d."StartTime"
						 AND (v2."CaptureTime" - v1."CaptureTime") < d."EndTime")
					END AS "DurationCategoryDescription"	
					
		FROM
		
		(SELECT v."ID", s."CarParkID", v."SiteID", v."VRM"
		       , v."AnonomisedVRM"
			   , COALESCE(v."VehicleTypeID", 1) AS "VehicleTypeID"
			   , vt."Description" AS "VehicleTypeDescription"
			   , "PermitTypeID"	  
			   , pt."Description" AS "PermitTypeDescription"
			   , v."CaptureTime", v."MatchedTo"
		 FROM (SELECT "ID", "SiteID", "VRM", "AnonomisedVRM", "CaptureTime", "VehicleTypeID", "MatchedTo"
					  , CASE WHEN "PermitTypeID" = 0 OR "PermitTypeID" IS NULL THEN default_permit_type  -- default permit type *** need to change !!!
							 ELSE "PermitTypeID"
						END AS "PermitTypeID"	
			   FROM anpr."VRMs" 
			   WHERE UPPER("VRM") NOT LIKE '%UNKN%'
			   ) v
			 , anpr."Sites" s, demand_lookups."VehicleTypes" vt, demand_lookups."PermitTypes" pt
		 WHERE v."SiteID" = s."SiteID"
		 AND s."CarParkID" = car_park_nr
		 AND COALESCE(v."VehicleTypeID", 1) = vt."Code"
		 AND v."PermitTypeID" = pt."Code" 
		) v1 LEFT JOIN
		 (SELECT v."ID", s."CarParkID", v."SiteID", v."VRM",  v."VehicleTypeID", v."PermitTypeID", v."CaptureTime", v."MatchedFrom"
		 FROM anpr."VRMs" v, anpr."Sites" s
		 WHERE v."SiteID" = s."SiteID"
		 AND s."CarParkID" = car_park_nr
		 ) v2 ON v1."MatchedTo" = v2."ID"
		  , anpr."CarParks" c
			WHERE c."CarParkID" = v1."CarParkID"
			AND v1."SiteID" IN (SELECT "FromSiteID" FROM anpr."Routes")

ORDER BY "CarParkDescription", "VRM", "Time_IN"

) y;

RETURN 1;

        END;
$$ LANGUAGE plpgsql;

SELECT * FROM anpr."All_VRMs"(21, 1)

