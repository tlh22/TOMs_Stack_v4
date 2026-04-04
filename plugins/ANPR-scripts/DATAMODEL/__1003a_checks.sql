-- With time periods and specific routes
 
-- Number unmatched by car park

SELECT c."Description", COUNT(v.*) --, v.*
FROM anpr."VRMs" v, anpr."CarParks" c, anpr."Sites" s
WHERE v."SiteID" = s."SiteID"
AND s."CarParkID" = c."CarParkID"
AND (v."MatchedTo" IS NULL AND v."MatchedFrom" IS NULL)
GROUP BY c."Description"
--ORDER BY "VRM", "CaptureTime"




-- ???

DO
$do$
DECLARE
   car_park RECORD;
   time_period RECORD;
   from_site RECORD;
   obs RECORD;
   total_at_start INTEGER;
   total_in INTEGER;
   total_out INTEGER;
   total_at_end INTEGER;
BEGIN

	-- Going into the car park will be matchedTo
	-- Going out of the car park will be matchedFrom
				   
	FOR car_park IN SELECT "CarParkID", "Description"
					FROM anpr."CarParks"
					ORDER BY "CarParkID"
	LOOP
	
		RAISE NOTICE '--- Considering car park %...', car_park."Description";
		
		FOR time_period IN SELECT "TimePeriodID", "StartTime", "EndTime"
						   FROM anpr."TimePeriods"
						   ORDER BY "StartTime"
		LOOP

			RAISE NOTICE '--- Considering time period %-%...', time_period."StartTime", time_period."EndTime";
			
			SELECT 
				SUM (CASE WHEN v1."CaptureTime" < time_period."StartTime"
						   AND v2."CaptureTime" >= time_period."StartTime" THEN 1 ELSE 0 END) AS "Total_At_Start",
				SUM (CASE WHEN v1."CaptureTime" >= time_period."StartTime" and v1."CaptureTime" < time_period."EndTime" THEN 1 ELSE 0 END) AS "Total_IN",
				SUM (CASE WHEN v2."CaptureTime" >= time_period."StartTime" and v2."CaptureTime" < time_period."EndTime" THEN 1 ELSE 0 END) AS "Total_OUT",
				SUM (CASE WHEN v1."CaptureTime" < time_period."EndTime"
						   AND v2."CaptureTime" >= time_period."EndTime" THEN 1 ELSE 0 END) AS "Total_AtEnd"
			INTO total_at_start, total_in, total_out, total_at_end
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedTo"
			 FROM anpr."VRMs" v, anpr."Sites" s
			 WHERE v."SiteID" = s."SiteID") v1,
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedFrom"
			 FROM anpr."VRMs" v, anpr."Sites" s
			 WHERE v."SiteID" = s."SiteID") v2
			WHERE v1."CarParkID" = v2."CarParkID"
			AND v1."CarParkID" = car_park."CarParkID"
			AND v1."MatchedTo" = v2."ID"
			AND v2."MatchedFrom" = v1."ID";

			INSERT INTO "anpr"."ANPRSummaryResults" ("CarParkID", "TimePeriodID", "TotalStartTimePeriod", "TotalIn", "TotalOut", "TotalEndTimePeriod")
			VALUES (car_park."CarParkID", time_period."TimePeriodID", total_at_start, total_in, total_out, total_at_end);
			
			RAISE NOTICE '--- Car Park: %. Time period % (%-%) START:%; IN:%; OUT:%; END:%', car_park."Description", time_period."TimePeriodID", time_period."StartTime", time_period."EndTime", total_at_start, total_in, total_out, total_at_end;

		END LOOP;
		
	END LOOP;

END
$do$;				   

-- Output from results table

SELECT c."Description" AS "CarPark", TO_CHAR(t."StartTime", 'Day') AS "Survey Day", CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriod",
"TotalStartTimePeriod", "TotalIn", "TotalOut", "TotalEndTimePeriod"
FROM "anpr"."ANPRSummaryResults" r, anpr."TimePeriods" t, anpr."CarParks" c
WHERE r."CarParkID" = c."CarParkID"
AND r."TimePeriodID" = t."TimePeriodID";
