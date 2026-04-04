-- With time periods and specific routes

/***
WITH intervals as (
    SELECT "StartTime", "EndTime"
    FROM anpr."TimePeriods"
)
SELECT i."StartTime", i."EndTime", COUNT(x."VRM_1") AS "Total", 
 SUM (CASE WHEN LENGTH(x."VRM_2") > 0 THEN 1 ELSE 0 END) AS "Match"
 FROM intervals i LEFT JOIN
 (
 SELECT v1."VRM" AS "VRM_1", v2."VRM" AS "VRM_2", v1."CaptureTime"
 FROM anpr."VRMs" v1 LEFT JOIN anpr."VRMs" v2 ON
 levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
 --AND v1."VRM" != v2."VRM"
 AND v1."Site" = 1 
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."Site" = 2
 AND (v2."Direction" = 'Forward' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:05:00'
 AND v2."CaptureTime" - v1."CaptureTime" > '00:01:00' ) x
 on x."CaptureTime" >= i."StartTime" and x."CaptureTime" < i."EndTime"
 GROUP BY "StartTime", "EndTime"
 ORDER BY i."StartTime"
 
 
 
WITH intervals as (
    SELECT "StartTime", "EndTime"
    FROM anpr."TimePeriods"
)
SELECT TO_CHAR(i."StartTime", 'dd/mm/yyyy') AS "Date",
	   CONCAT(TO_CHAR(i."StartTime", 'HH24:MI'), '-', TO_CHAR(i."EndTime", 'HH24:MI')) AS "TimePeriod", 
--SELECT i."StartTime", i."EndTime", 
 SUM (CASE WHEN v."Site" = 1 AND v."Direction" = 'Reverse' THEN 1 ELSE 0 END) AS "Total IN at 1", 
 SUM (CASE WHEN v."Site" = 1 AND v."Direction" = 'Forward' THEN 1 ELSE 0 END) AS "Total OUT at 1", 
 SUM (CASE WHEN v."Site" = 1 AND v."MatchedAt" = 2 THEN 1 ELSE 0 END) AS "Matched 1->2", 
 SUM (CASE WHEN v."Site" = 1 AND v."MatchedAt" = 3 THEN 1 ELSE 0 END) AS "Matched 1->3", 
 SUM (CASE WHEN v."Site" = 1 AND v."MatchedAt" IS NOT NULL THEN 1 ELSE 0 END) AS "Matched", 
 SUM (CASE WHEN v."Site" = 2 AND v."Direction" = 'Reverse' THEN 1 ELSE 0 END) AS "Total IN at 2",
 SUM (CASE WHEN v."Site" = 2 AND v."Direction" = 'Forward' THEN 1 ELSE 0 END) AS "Total OUT at 2",
 SUM (CASE WHEN v."Site" = 2 AND v."MatchedAt" = 1 THEN 1 ELSE 0 END) AS "Matched 2->1", 
 SUM (CASE WHEN v."Site" = 3 AND v."Direction" = 'Forward' THEN 1 ELSE 0 END) AS "Total IN at 3",  
 SUM (CASE WHEN v."Site" = 3 AND v."Direction" = 'Reverse' THEN 1 ELSE 0 END) AS "Total OUT at 3",  
 SUM (CASE WHEN v."Site" = 3 AND v."MatchedAt" = 1 THEN 1 ELSE 0 END) AS "Matched 3->1"
 FROM intervals i LEFT JOIN anpr."VRMs" v
 on v."CaptureTime" >= i."StartTime" and v."CaptureTime" < i."EndTime"
 GROUP BY "StartTime", "EndTime"
 ORDER BY i."StartTime"
 
--
 
WITH intervals as (
    SELECT "StartTime", "EndTime"
    FROM anpr."TimePeriods"
)

	WITH sites AS (SELECT "SiteID"
				   FROM anpr."Sites"
				   )
		WITH routes AS (SELECT "ToSiteID"
						FROM anpr."Routes"
						WHERE "FromSiteID" = sites."SiteID"
						)
		 SELECT TO_CHAR(period."StartTime", 'dd/mm/yyyy' AS "Date",
		 CONCAT(TO_CHAR(i."StartTime", 'HH24:MI'), '-'TO_CHAR(i."EndTime", 'HH24:MI')) AS "TimePeriod", sites."SiteID" AS "Site"
		 SUM (CASE WHEN v."Site" = 1 AND v."Direction" = 'Reverse' THEN 1 ELSE 0 END) AS "Total IN at 1", 
		 SUM (CASE WHEN v."Site" = 1 AND v."Direction" = 'Forward' THEN 1 ELSE 0 END) AS "Total OUT at 1", 
		 SUM (CASE WHEN v."Site" = 1 AND v."MatchedAt" = 2 THEN 1 ELSE 0 END) AS "Matched 1->2", 
		 SUM (CASE WHEN v."Site" = 1 AND v."MatchedAt" = 3 THEN 1 ELSE 0 END) AS "Matched 1->3", 
		 SUM (CASE WHEN v."Site" = 1 AND v."MatchedAt" IS NOT NULL THEN 1 ELSE 0 END) AS "Matched", 
		 SUM (CASE WHEN v."Site" = 2 AND v."Direction" = 'Reverse' THEN 1 ELSE 0 END) AS "Total IN at 2",
		 SUM (CASE WHEN v."Site" = 2 AND v."Direction" = 'Forward' THEN 1 ELSE 0 END) AS "Total OUT at 2",
		 SUM (CASE WHEN v."Site" = 2 AND v."MatchedAt" = 1 THEN 1 ELSE 0 END) AS "Matched 2->1", 
		 SUM (CASE WHEN v."Site" = 3 AND v."Direction" = 'Forward' THEN 1 ELSE 0 END) AS "Total IN at 3",  
		 SUM (CASE WHEN v."Site" = 3 AND v."Direction" = 'Reverse' THEN 1 ELSE 0 END) AS "Total OUT at 3", 
		 SUM (CASE WHEN v."Site" = 3 AND v."MatchedAt" = 1 THEN 1 ELSE 0 END) AS "Matched 3->1"
		 FROM intervals i LEFT JOIN anpr."VRMs" v
		 on v."CaptureTime" >= i."StartTime" and v."CaptureTime" < i."EndTime"
		 GROUP BY "Date", "TimePeriod", "StartTime", "EndTime"
		 ORDER BY i."StartTime"

--- generic function outputing json ...

DROP FUNCTION IF EXISTS anpr.json_anpr_results;
CREATE OR REPLACE FUNCTION anpr.json_anpr_results(
)
  RETURNS jsonb 
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
   period RECORD;
   site RECORD;
   route RECORD;
   total INTEGER;
   total_in INTEGER;
   total_out INTEGER;
   total_route INTEGER;
   output_jsonb JSONB;
   curr_output_jsonb JSONB;
   curr_time_period_jsonb JSONB;
   curr_route_jsonb JSONB;
   curr_results_jsonb JSONB = '[]';
   curr_site_jsonb JSONB = '[]';
   curr_details_jsonb JSONB = '[]';
   len_output_jsonb INTEGER;
   len_curr_details_jsonb INTEGER;
   
   time_period VARCHAR;

BEGIN

	FOR period IN SELECT "StartTime", "EndTime"
	    			FROM anpr."TimePeriods"
	    			ORDER BY "StartTime"
	LOOP
	
		RAISE NOTICE '*** Considering time period % - %', period."StartTime", period."EndTime";
		
		SELECT CONCAT(TO_CHAR(period."StartTime", 'HH24:MI'), '-', TO_CHAR(period."EndTime", 'HH24:MI'))
        INTO time_period;

		curr_details_jsonb = NULL;
			
		FOR site IN SELECT "SiteID", "IN", "OUT"
					FROM anpr."Sites"
					ORDER BY "SiteID"
		LOOP
		
			-- Get totals at site
			
			SELECT 
				COUNT(*) AS "Total",
				SUM (CASE WHEN v."Direction" = site."IN" THEN 1 ELSE 0 END) AS "Total_IN",
				SUM (CASE WHEN v."Direction" = site."OUT" THEN 1 ELSE 0 END) AS "Total_OUT"
			INTO total, total_in, total_out
			FROM anpr."VRMs" v
			WHERE v."SiteID" = site."SiteID"
			AND v."CaptureTime" >= period."StartTime" and v."CaptureTime" < period."EndTime";

			-- reset results array
			curr_results_jsonb = '[]';
			
		    FOR route IN SELECT "ToSiteID"
		    		     FROM anpr."Routes" r
		    		     WHERE r."FromSiteID" = site."SiteID"
		    		     ORDER BY "ToSiteID"
	    	LOOP
	    	
	    		RAISE NOTICE '*** Considering % -> %', site."SiteID", route."ToSiteID";
	    		
	    		SELECT 
		    		COUNT(*) AS "Total_Route"
				INTO total_route
				FROM anpr."VRMs" v1, anpr."VRMs" v2
				WHERE v1."SiteID" = site."SiteID"
				AND v2."SiteID" = route."ToSiteID"
				AND v1."MatchedTo" = v2."ID"
				AND v1."CaptureTime" >= period."StartTime" and v1."CaptureTime" < period."EndTime";
			 
			 	RAISE NOTICE '  -- total % -> % = %', site."SiteID", route."ToSiteID", total_route;
			 	
				--SELECT jsonb_build_object('Route', CONCAT(site."SiteID", '-', route."ToSiteID"), 'Matched', total_route) INTO curr_route_jsonb;
				SELECT jsonb_build_object(CONCAT(site."SiteID", '-', route."ToSiteID"), total_route) INTO curr_route_jsonb;
				SELECT curr_results_jsonb::jsonb || curr_route_jsonb::jsonb INTO curr_results_jsonb;
				
				RAISE NOTICE '*-*-* curr results %', curr_results_jsonb;
				
			END LOOP;
		
			-- create object to hold results for site
			--SELECT jsonb_build_object('Site', site."SiteID", 'Results', 
			--			jsonb_build_object(CONCAT('Count ', site."SiteID"), total, 'Routes', curr_results_jsonb, CONCAT('Total In ', site."SiteID"), total_in, CONCAT('Total Out ', site."SiteID"), total_out)
			--						 ) INTO curr_site_jsonb;
									 
			SELECT jsonb_build_object(CONCAT('Total In ', site."SiteID"), total_in) ||
						jsonb_build_object(CONCAT('Total Out ', site."SiteID"), total_out) || 
						curr_results_jsonb	
					INTO curr_site_jsonb;

			SELECT jsonb_array_length(curr_details_jsonb) INTO len_curr_details_jsonb;
			IF len_curr_details_jsonb > 0 THEN
				SELECT curr_details_jsonb::jsonb || curr_site_jsonb::jsonb INTO curr_details_jsonb;
			ELSE
				curr_details_jsonb = curr_site_jsonb::jsonb;
			END IF;
			RAISE NOTICE '*-*-* curr details %', curr_details_jsonb;

			
		END LOOP;
			
		SELECT jsonb_build_object('Date', TO_CHAR(period."StartTime", 'dd/mm/yyyy'), 'TimePeriod', time_period
								  ) INTO curr_time_period_jsonb;
		
		RAISE NOTICE '*** json %', curr_time_period_jsonb;
		SELECT jsonb_build_array(curr_time_period_jsonb::jsonb || curr_details_jsonb::jsonb) INTO curr_details_jsonb;
		RAISE NOTICE '*-*-*=== curr details %', curr_details_jsonb;

		SELECT jsonb_array_length(output_jsonb) INTO len_output_jsonb;
		
		IF len_output_jsonb > 0 THEN
			SELECT output_jsonb::jsonb || curr_details_jsonb::jsonb INTO output_jsonb;
		ELSE
			output_jsonb = curr_details_jsonb;
		END IF;

		RAISE NOTICE '*-*-*--- Output %', output_jsonb;
			
	END LOOP;
	
	RAISE NOTICE '*-*-*--- Output %', output_jsonb;
	RETURN output_jsonb;
	
END
$BODY$;
***/

/***
 
 Useful sites
 
 https://www.freeformatter.com/json-validator.html
 https://conversiontools.io/convert/json-to-excel
 
 ***/
 
-- Output

--SELECT (anpr.json_anpr_results())::json AS a

-- then need to manipulate to make like example file


-- for car parks

-- Output table

DROP TABLE IF EXISTS "anpr"."ANPRRouteSummaryResults";
CREATE TABLE "anpr"."ANPRRouteSummaryResults" (
    "gid" SERIAL,
	"Route" character varying(12),
	"TimePeriodID" integer,
	"TotalIn" integer,
	"TotalOut" integer
);

ALTER TABLE "anpr"."ANPRRouteSummaryResults" OWNER TO "postgres";

ALTER TABLE "anpr"."ANPRRouteSummaryResults"
    ADD PRIMARY KEY ("gid");

DO
$do$
DECLARE
   car_park RECORD;
   time_period RECORD;
   from_site RECORD;
   route RECORD;
   obs RECORD;
   total_at_start INTEGER;
   total_in INTEGER;
   total_out INTEGER;
   total_at_end INTEGER;
   site_id TEXT;
BEGIN

	-- Going into the car park will be matchedTo
	-- Going out of the car park will be matchedFrom
				   
	FOR route IN SELECT "RouteID", "FromSiteID", "ToSiteID", "MinimumTimeLimit", "MaximumTimeLimit"
				 FROM anpr."Routes"
				 ORDER BY "FromSiteID"
	LOOP
	
		RAISE NOTICE '--- Considering route %-% ...', route."FromSiteID", route."ToSiteID";
		
		FOR time_period IN SELECT "TimePeriodID", "StartTime", "EndTime"
						   FROM anpr."TimePeriods"
						   ORDER BY "StartTime"
		LOOP

			RAISE NOTICE '--- Considering time period %-%...', time_period."StartTime", time_period."EndTime";
			
			SELECT 

				SUM (CASE WHEN v1."CaptureTime" >= time_period."StartTime" and v1."CaptureTime" < time_period."EndTime" THEN 1 ELSE 0 END) AS "Total_IN",
				SUM (CASE WHEN v2."CaptureTime" >= time_period."StartTime" and v2."CaptureTime" < time_period."EndTime" THEN 1 ELSE 0 END) AS "Total_OUT"

			INTO total_in, total_out
FROM 
			(SELECT v."ID", "SiteID", v."VRM", v."CaptureTime", v."MatchedTo"
			 FROM anpr."VRMs" v --, anpr."Sites" s
			 WHERE v."SiteID" = route."FromSiteID") v1,
			 (SELECT v."ID", "SiteID", v."VRM", v."CaptureTime", v."MatchedFrom"
			 FROM anpr."VRMs" v --, anpr."Sites" s
			 WHERE v."SiteID" = route."ToSiteID") v2
			WHERE v1."MatchedTo" = v2."ID"
			AND v2."MatchedFrom" = v1."ID";

			INSERT INTO "anpr"."ANPRRouteSummaryResults" ("Route", "TimePeriodID", "TotalIn", "TotalOut")
			VALUES (CONCAT('''', route."FromSiteID", '-', route."ToSiteID"), time_period."TimePeriodID", total_in, total_out);
			
			--RAISE NOTICE '--- Car Park: %. Time period % (%-%) START:%; IN:%; OUT:%; END:%', site."SiteID", time_period."TimePeriodID", time_period."StartTime", time_period."EndTime", total_at_start, total_in, total_out, total_at_end;

		END LOOP;
		
	END LOOP;

END
$do$;				   

-- Output from results table

SELECT "FromSiteID", "ToSiteID", TO_CHAR(t."StartTime", 'Day') AS "Survey Day", CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriod",
"TotalIn", "TotalOut"
FROM "anpr"."ANPRRouteSummaryResults" r, anpr."TimePeriods" t
WHERE r."TimePeriodID" = t."TimePeriodID";



/***

SELECT "Route",
	"VRM_1", "Site_IN", "VRM_2", "Site_OUT", "Time_IN",  "Time_OUT", TO_CHAR(t1."StartTime", 'Day') AS "SurveyDay_IN", 
		CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriod_IN",
		--TO_CHAR(t2."StartTime", 'Day') AS "SurveyDay_OUT", 
		 CONCAT(TO_CHAR(t2."StartTime", 'HH24:MI'), '-', TO_CHAR(t2."EndTime", 'HH24:MI')) AS "TimePeriod_OUT", "Duration", d."Description"
 
 FROM (
			SELECT CONCAT('''', r."FromSiteID", '-', r."ToSiteID") AS "Route", v1."ID", v1."SiteID" AS "Site_IN", v2."SiteID" AS "Site_OUT", v1."VRM" AS "VRM_1", v2."VRM" AS "VRM_2",
				   v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT", 
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration", v1."TimePeriodID" AS "TimePeriod_IN", v2."TimePeriodID" AS "TimePeriod_OUT"
			FROM 
			(SELECT v."ID", r."RouteID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedTo", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Routes" r, anpr."TimePeriods" t
			 WHERE v."SiteID" = r."FromSiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" ) v1,
			 (SELECT v."ID", r."RouteID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedFrom", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Routes" r, anpr."TimePeriods" t
			 WHERE v."SiteID" = r."ToSiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime") v2, anpr."Routes" r
			WHERE v1."RouteID" = v2."RouteID"
			AND v1."RouteID" = r."RouteID"
			AND v1."MatchedTo" = v2."ID"
			AND v2."MatchedFrom" = v1."ID" ) x,
			anpr."DurationCategories" d, anpr."TimePeriods" t1, anpr."TimePeriods" t2
WHERE x."TimePeriod_IN" = t1."TimePeriodID"
AND x."TimePeriod_OUT" = t2."TimePeriodID"
AND x."Duration" >= d."StartTime"
AND x."Duration" < d."EndTime"
ORDER BY "Route", "TimePeriod_IN", "VRM_1"

***/

/***

-- Anonomised ...

SELECT "Route",
	"VRM_1", "Site_IN", "VRM_2", "Site_OUT", "Time_IN",  "Time_OUT", TO_CHAR(t1."StartTime", 'Day') AS "SurveyDay_IN", 
		CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriod_IN",
		--TO_CHAR(t2."StartTime", 'Day') AS "SurveyDay_OUT", 
		 CONCAT(TO_CHAR(t2."StartTime", 'HH24:MI'), '-', TO_CHAR(t2."EndTime", 'HH24:MI')) AS "TimePeriod_OUT", "Duration", d."Description"  AS "DurationCategory"
 
 FROM (
			SELECT CONCAT('''', r."FromSiteID", '-', r."ToSiteID") AS "Route", v1."ID", v1."SiteID" AS "Site_IN", v2."SiteID" AS "Site_OUT", v1."VRM" AS "VRM_1", v2."VRM" AS "VRM_2",
				   v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT", 
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration", v1."TimePeriodID" AS "TimePeriod_IN", v2."TimePeriodID" AS "TimePeriod_OUT"
			FROM 
			(SELECT v."ID", r."RouteID", v."SiteID", v."AnonomisedVRM" AS "VRM", v."CaptureTime", v."MatchedTo", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Routes" r, anpr."TimePeriods" t
			 WHERE v."SiteID" = r."FromSiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" ) v1,
			 (SELECT v."ID", r."RouteID", v."SiteID", v."AnonomisedVRM" AS "VRM", v."CaptureTime", v."MatchedFrom", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Routes" r, anpr."TimePeriods" t
			 WHERE v."SiteID" = r."ToSiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime") v2, anpr."Routes" r
			WHERE v1."RouteID" = v2."RouteID"
			AND v1."RouteID" = r."RouteID"
			AND v1."MatchedTo" = v2."ID"
			AND v2."MatchedFrom" = v1."ID" ) x,
			anpr."DurationCategories" d, anpr."TimePeriods" t1, anpr."TimePeriods" t2
WHERE x."TimePeriod_IN" = t1."TimePeriodID"
AND x."TimePeriod_OUT" = t2."TimePeriodID"
AND x."Duration" >= d."StartTime"
AND x."Duration" < d."EndTime"
ORDER BY "Route", "TimePeriod_IN", "VRM_1"


***/