/***
For ANPR data, need

- summary by (hour) of parked vehicles

- Output table

***/

DROP TABLE IF EXISTS "anpr"."ANPR_Durations";
CREATE TABLE "anpr"."ANPR_Durations" (
    "gid" SERIAL,
	"VRM" character varying(12),
	"SiteID" character varying(12),
	"TimeIN" timestamp without time zone ,
	"TimeOUT" timestamp without time zone ,	
	"Duration" interval
);

ALTER TABLE "anpr"."ANPR_Durations" OWNER TO "postgres";

ALTER TABLE "anpr"."ANPR_Durations"
    ADD PRIMARY KEY ("gid");
	

INSERT INTO "anpr"."ANPR_Durations" ("SiteID", "VRM", "TimeIN", "TimeOUT", "Duration")

SELECT v1."SiteID", v1."VRM", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT", 
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration" 
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedTo" --, t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s 
			 WHERE v."SiteID" = s."SiteID"
			 
			) v1,
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedFrom" --, t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s 
			 WHERE v."SiteID" = s."SiteID"
			 
			 ) v2
			 WHERE v1."MatchedTo" = v2."ID"
			AND v2."MatchedFrom" = v1."ID"
			ORDER BY "SiteID", "Time_IN"

/***	

-- Not quite correct. Trying to pick up situations where there is no match within the time periods, i.e., duration of stay is "unknown"
UNION

SELECT v."SiteID", v."VRM", v."CaptureTime" AS "Time_IN", NULL AS "Time_OUT", 
	 			  NULL AS "Duration" 
			FROM anpr."VRMs" v
WHERE v."MatchedTo" IS NULL
AND v."MatchedFrom" IS NULL
AND v."Direction" = 'IN';
***/

DROP TABLE IF EXISTS "anpr"."ANPRSummaryResults";
CREATE TABLE "anpr"."ANPRSummaryResults" (
    "gid" SERIAL,
    "CarParkID" integer,
	"SiteID" character varying(12),
	"TimePeriodID" integer,
	"TotalStartTimePeriod" integer,
	"TotalIn" integer,
	"TotalOut" integer,
	"TotalEndTimePeriod" integer
);

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
   site_id TEXT;
BEGIN

	FOR site IN SELECT "CarParkID", "SiteID", "Description"
					FROM anpr."Sites"
					WHERE "SiteID" = 'S_000338'
					ORDER BY "SiteID"
	LOOP
		FOR time_period IN SELECT "TimePeriodID", "StartTime", "EndTime"
						   FROM anpr."TimePeriods"
						   ORDER BY "StartTime"
		LOOP

			RAISE NOTICE '--- Considering time period %-%...', time_period."StartTime", time_period."EndTime";
			
			SELECT 
				SUM (CASE WHEN d."TimeIN" < time_period."StartTime"
						   AND (d."TimeOUT" >= time_period."StartTime" OR d."TimeOUT" IS NULL) THEN 1 ELSE 0 END) AS "Total_At_Start",
				SUM (CASE WHEN d."TimeIN" >= time_period."StartTime" and (d."TimeIN" < time_period."EndTime") THEN 1 ELSE 0 END) AS "Total_IN",
				SUM (CASE WHEN d."TimeOUT" >= time_period."StartTime" and d."TimeOUT" < time_period."EndTime" THEN 1 ELSE 0 END) AS "Total_OUT",
				SUM (CASE WHEN d."TimeIN" < time_period."EndTime"
						   AND (d."TimeOUT" >= time_period."EndTime" OR d."TimeOUT" IS NULL) THEN 1 ELSE 0 END) AS "Total_AtEnd"
			INTO total_at_start, total_in, total_out, total_at_end
			FROM anpr."ANPR_Durations" d
			WHERE "SiteID" = site."SiteID";
			
			INSERT INTO "anpr"."ANPRSummaryResults" ("CarParkID", "SiteID", "TimePeriodID", "TotalStartTimePeriod", "TotalIn", "TotalOut", "TotalEndTimePeriod")
			VALUES (site."CarParkID", site."SiteID", time_period."TimePeriodID", total_at_start, total_in, total_out, total_at_end);
			
			RAISE NOTICE '--- Site: %. Time period % (%-%) START:%; IN:%; OUT:%; END:%', site."SiteID", time_period."TimePeriodID", time_period."StartTime", time_period."EndTime", total_at_start, total_in, total_out, total_at_end;

		END LOOP;
		
	END LOOP;

END
$do$;

-- Output

SELECT "SiteID" AS "GeometryID", s."RestrictionTypeID", s."Description", r."TimePeriodID", "TotalStartTimePeriod", "TotalIn", "TotalOut", "TotalEndTimePeriod"
	FROM anpr."ANPRSummaryResults" r, (mhtc_operations."Supply" su LEFT JOIN toms_lookups."BayLineTypes" l ON su."RestrictionTypeID" = l."Code") s
	WHERE r."SiteID" = s."GeometryID"
	

/*** Durations ***/

-- With time periods

SELECT d."SiteID" AS "GeometryID", a."VRM", a."NewID", d."TimeIN" AS "Time_IN", d."TimeOUT" AS "Time_OUT", 
	   "Duration", x."Description",
	   t1."TimePeriodID" AS "TimePeriodIN", 
	   CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriod_IN",
	   t2."TimePeriodID" AS "TimePeriodOUT",
	   CONCAT(TO_CHAR(t2."StartTime", 'HH24:MI'), '-', TO_CHAR(t2."EndTime", 'HH24:MI')) AS "TimePeriod_OUT"
FROM anpr."ANPR_Durations" d, anpr."Anonomise_VRMs" a, anpr."TimePeriods" t1, anpr."TimePeriods" t2, anpr."DurationCategories" x
WHERE d."VRM" = a."VRM"
AND d."TimeIN" >= t1."StartTime" and d."TimeIN" < t1."EndTime"
AND d."TimeOUT" >= t2."StartTime" and d."TimeOUT" < t2."EndTime"
AND d."Duration" >= x."StartTime"
AND d."Duration" < x."EndTime"

UNION

SELECT d."SiteID" AS "GeometryID", a."VRM", a."NewID", d."TimeIN" AS "Time_IN", d."TimeOUT" AS "Time_OUT", 
	   d."Duration", x."Description",
	   t1."TimePeriodID" AS "TimePeriodIN", 
	   CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriod_IN",
	   NULL AS "TimePeriodOUT",
	   NULL AS "TimePeriod_OUT"
FROM anpr."ANPR_Durations" d, anpr."Anonomise_VRMs" a , anpr."TimePeriods" t1, --anpr."TimePeriods" t2, 
anpr."DurationCategories" x
WHERE d."VRM" = a."VRM"
AND d."TimeIN" >= t1."StartTime" and d."TimeIN" <= t1."EndTime"
--AND d."TimeOUT" >= t2."StartTime" and d."TimeOUT" < t2."EndTime"
AND d."Duration" <= x."StartTime"
AND d."Duration" > x."EndTime"
AND d."Duration" < '1 minute'::interval
ORDER BY t1."TimePeriodID"

-- still missign vehicles parked at start ...

UPDATE anpr."ANPR_Durations"
SET "Duration" = -1
WHERE (TO_CHAR("TimeIN"::timestamp, 'HH24:MI') = '07:00'
	OR TO_CHAR("TimeOUT"::timestamp, 'HH24:MI') = '23:59')











