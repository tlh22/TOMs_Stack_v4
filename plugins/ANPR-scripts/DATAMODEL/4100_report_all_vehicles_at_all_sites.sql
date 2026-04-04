-- Output table

DROP TABLE IF EXISTS "anpr"."ANPRSummaryResults";
CREATE TABLE "anpr"."ANPRSummaryResults" (
    "gid" SERIAL,
    "CarParkID" integer,
	"SiteID" integer,
	"TimePeriodID" integer,
	--"Direction" text,
	"VehicleTypeID" integer,
	"Total" integer
);

ALTER TABLE "anpr"."ANPRSummaryResults" OWNER TO "postgres";

ALTER TABLE "anpr"."ANPRSummaryResults"
    ADD PRIMARY KEY ("gid");


-- Tidy Vehicle Types

UPDATE anpr."VRMs"
SET "VehicleTypeID" = 1
WHERE "VehicleTypeID" = 0;

-- Set up Summary table

DO
$do$
DECLARE
   car_park RECORD;
   time_period RECORD;
   from_site RECORD;
   site RECORD;
   obs RECORD;
   total_at_start INTEGER;
   total_in INTEGER;
   total_out INTEGER;
   total_at_end INTEGER;
   
   total_cars_in INTEGER;
   total_cars_out INTEGER;
   
   car_park_id INTEGER = x;
   
   site_id TEXT;
BEGIN

	-- Going into the car park will be matchedTo
	-- Going out of the car park will be matchedFrom
				   
	FOR site IN SELECT "CarParkID", "SiteID", "Description"
					FROM anpr."Sites"
					WHERE "CarParkId" = car_park_id
					ORDER BY "SiteID"
	LOOP
	
		RAISE NOTICE '--- Considering site %...', site."Description";
		
		FOR time_period IN SELECT "TimePeriodID", "StartTime", "EndTime"
						   FROM anpr."TimePeriods"
						   ORDER BY "StartTime"
		LOOP

			RAISE NOTICE '--- Considering time period %-%...', time_period."StartTime", time_period."EndTime";

			-- IN Total
			
			INSERT INTO "anpr"."ANPRSummaryResults" ("CarParkID", "SiteID", "TimePeriodID", "VehicleTypeID", "Total")

			SELECT site."CarParkID" AS "CarParkID"
			, site."SiteID"
			, time_period."TimePeriodID"
			--, 'IN' As "Direction"
			, COALESCE(v."VehicleTypeID", 1) AS "VehicleTypeID"
			, COUNT(v."VRM")
			FROM anpr."VRMs" v
			WHERE v."CaptureTime" >= time_period."StartTime" and v."CaptureTime" < time_period."EndTime"
			AND v."SiteID" = site."SiteID"
			GROUP BY site."CarParkID", site."SiteID", time_period."TimePeriodID", COALESCE(v."VehicleTypeID", 1)
			--ORDER BY time_period."TimePeriodID", COALESCE(v."VehicleTypeID", 0)
			;
			
			-- OUT total
			/***
			INSERT INTO "anpr"."ANPRSummaryResults" ("CarParkID", "SiteID", "TimePeriodID", "Direction", "VehicleTypeID", "Total")

			SELECT site."CarParkID" AS "CarParkID"
			, site."SiteID"
			, time_period."TimePeriodID"
			, 'OUT' As "Direction"
			, COALESCE(v."VehicleTypeID", 1) AS "VehicleTypeID"
			, COUNT(v."VRM")
			FROM anpr."VRMs" v
			WHERE v."CaptureTime" >= time_period."StartTime" and v."CaptureTime" < time_period."EndTime"
			AND v."SiteID" = site."SiteID"
			GROUP BY site."CarParkID", site."SiteID", time_period."TimePeriodID", COALESCE(v."VehicleTypeID", 1)
			--ORDER BY time_period."TimePeriodID", COALESCE(v."VehicleTypeID", 0)
			;
			***/

		END LOOP;
		
	END LOOP;

END
$do$;


-- Generate pivot style table - NB: need to change day/site

/***
 - change Site and Day
 ***/

SELECT * FROM CROSSTAB(
  '
  
	SELECT 
		y."TimePeriodDescription"
		, y."VehicleTypeDescription"
		, r."Total"
	FROM
	
	(SELECT t."TimePeriodID"
			, CONCAT(TO_CHAR(t."StartTime", ''HH24:MI''), ''-'', TO_CHAR(t."EndTime", ''HH24:MI'')) AS "TimePeriodDescription"
			, TO_CHAR(t."StartTime", ''Day (dd/mm)'') AS "SurveyDay"
			, v."Code" AS "VehicleTypeID"
			, v."Description" AS "VehicleTypeDescription"
	FROM (anpr."TimePeriods" t CROSS JOIN demand_lookups."VehicleTypes" v) 
	WHERE v."Code" IN (1,2,3,4,5,6,14)
	ORDER BY t."TimePeriodID", v."Code") y

	LEFT OUTER JOIN 
	
	(SELECT "SiteID", "TimePeriodID", "VehicleTypeID", "Total"
	FROM "anpr"."ANPRSummaryResults"
	WHERE "SiteID" IN (11)  -- *** Change Site(s) to match direction
	) r
	
	ON ( y."TimePeriodID" =  r."TimePeriodID"
	AND y."VehicleTypeID" = r."VehicleTypeID")
	WHERE y."SurveyDay" LIKE ''Tuesday%''  -- *** Change day

	--GROUP BY y."TimePeriodDescription", y."VehicleTypeDescription"
	ORDER BY y."TimePeriodDescription", y."VehicleTypeDescription"
	
  ',
  'SELECT "Description" 
   FROM demand_lookups."VehicleTypes" v
   WHERE "Code" IN (1,2,3,4,5,6,14)'
) AS (
  "Vehicle Type" TEXT,
	"Car" INTEGER,
	"LGV" INTEGER,
	"OGV" INTEGER,
	"OGV2" INTEGER,
	"Bus" INTEGER,
	"MCL" INTEGER,
	"PCL" INTEGER
);



/***
Tests

	SELECT 
		y."TimePeriodDescription"
		, y."VehicleTypeDescription"
		, r."Total"
	FROM
	
	(SELECT t."TimePeriodID"
			, CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriodDescription"
			, TO_CHAR(t."StartTime", 'Day (dd/mm)') AS "SurveyDay"
			, v."Code" AS "VehicleTypeID"
			, v."Description" AS "VehicleTypeDescription"
	FROM (anpr."TimePeriods" t CROSS JOIN demand_lookups."VehicleTypes" v) 
	WHERE v."Code" IN (1,2,3,4,5,6)
	ORDER BY t."TimePeriodID", v."Code") y
	
	LEFT OUTER JOIN 

	ON ( 
	y."TimePeriodID" =  r."TimePeriodID"
	AND y."VehicleTypeID" = r."VehicleTypeID")
	WHERE y."SurveyDay" LIKE ''Tuesday%''
	--AND r."SiteID" = 11
	
	ORDER BY y."TimePeriodDescription", y."VehicleTypeDescription"


***/