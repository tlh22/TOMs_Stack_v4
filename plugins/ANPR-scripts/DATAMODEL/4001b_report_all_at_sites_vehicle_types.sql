-- Output table

DROP TABLE IF EXISTS "anpr"."ANPRSummaryResults";
CREATE TABLE "anpr"."ANPRSummaryResults" (
    "gid" SERIAL,
    "CarParkID" integer,
	"SiteID" character varying(12),
	"TimePeriodID" integer,
	"TotalStartTimePeriod" integer,
	"TotalIn" integer,
	"TotalOut" integer,
	"TotalCarsIn" integer,
	"TotalCarsOut" integer,
	"TotalEndTimePeriod" integer
);

ALTER TABLE "anpr"."ANPRSummaryResults" OWNER TO "postgres";

ALTER TABLE "anpr"."ANPRSummaryResults"
    ADD PRIMARY KEY ("gid");

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
   
   site_id TEXT;
BEGIN

	-- Going into the car park will be matchedTo
	-- Going out of the car park will be matchedFrom
				   
	FOR site IN SELECT "CarParkID", "SiteID", "Description"
					FROM anpr."Sites"
					ORDER BY "SiteID"
	LOOP
	
		RAISE NOTICE '--- Considering site %...', site."Description";
		
		FOR time_period IN SELECT "TimePeriodID", "StartTime", "EndTime"
						   FROM anpr."TimePeriods"
						   ORDER BY "StartTime"
		LOOP

			RAISE NOTICE '--- Considering time period %-%...', time_period."StartTime", time_period."EndTime";
			
			SELECT 

				SUM (CASE WHEN v."CaptureTime" >= time_period."StartTime" and v."CaptureTime" < time_period."EndTime"
						       AND v."Direction" = (SELECT "IN" FROM anpr."Sites" WHERE "SiteID" = v."SiteID") THEN 1 ELSE 0 END) 
							   AS "Total_IN",
				SUM (CASE WHEN v."CaptureTime" >= time_period."StartTime" and v."CaptureTime" < time_period."EndTime" 
							   AND v."Direction" = (SELECT "OUT" FROM anpr."Sites" WHERE "SiteID" = v."SiteID") THEN 1 ELSE 0 END) 
							   AS "Total_OUT",
							   
				SUM (CASE WHEN v."CaptureTime" >= time_period."StartTime" and v."CaptureTime" < time_period."EndTime"
						       AND v."Direction" = (SELECT "IN" FROM anpr."Sites" WHERE "SiteID" = v."SiteID"
							   AND l."Description" = 'Car') THEN 1 ELSE 0 END) 
							   AS "Total_Cars_IN",
				SUM (CASE WHEN v."CaptureTime" >= time_period."StartTime" and v."CaptureTime" < time_period."EndTime" 
							   AND v."Direction" = (SELECT "OUT" FROM anpr."Sites" WHERE "SiteID" = v."SiteID" 
							   AND l."Description" = 'Car') THEN 1 ELSE 0 END) 
							   AS "Total_Cars_OUT"
							   
			INTO total_in, total_out, total_cars_in, total_cars_out
			FROM anpr."VRMs" v, demand_lookups."VehicleTypes" l
			WHERE v."VehicleTypeID" = l."Code"
			AND v."SiteID" = site."SiteID"
			;

			INSERT INTO "anpr"."ANPRSummaryResults" ("CarParkID", "SiteID", "TimePeriodID", "TotalIn", "TotalOut", "TotalCarsIn", "TotalCarsOut")
			VALUES (site."CarParkID", site."SiteID", time_period."TimePeriodID", total_in, total_out, total_cars_in, total_cars_out);
			
			RAISE NOTICE '--- Site: %. Time period % (%-%) IN:%; OUT:%', site."SiteID", time_period."TimePeriodID", time_period."StartTime", time_period."EndTime", total_in, total_out;

		END LOOP;
		
	END LOOP;

END
$do$;


-- Output from results table

SELECT c."Description" AS "CarPark", r."SiteID", TO_CHAR(t."StartTime", 'Day (dd/mm)') AS "Survey Day", CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriod",
"TotalIn", "TotalOut", "TotalCarsIn", "TotalCarsOut"
FROM "anpr"."ANPRSummaryResults" r, anpr."TimePeriods" t, anpr."CarParks" c
WHERE r."CarParkID" = c."CarParkID"
AND r."TimePeriodID" = t."TimePeriodID";