/***

Pivot style table including all time periods for duration

***/

CREATE EXTENSION IF NOT EXISTS tablefunc;

DROP TABLE IF EXISTS anpr."DurationDetails" CASCADE;

-- Create a staging table

CREATE TABLE anpr."DurationDetails" AS

SELECT "CarParkDescription"
        , "VRM"
		, "Site_IN"
		, "Site_OUT"
		, "Time_IN"
		, "Time_OUT"
		, "TimePeriodID_IN"
		, "TimePeriodID_OUT"
		, "SurveyDay_IN"
		, "TimePeriodDescription_IN"
		, "TimePeriodDescription_OUT"
		, "Duration"
		, "DurationCategoryID"
		, "DurationCatergoryDescription"
FROM (

SELECT "CarParkDescription"
        , "VRM"
		, "Site_IN"
		, "Site_OUT"
		, "Time_IN"
		, "Time_OUT"
		, "TimePeriod_IN" AS "TimePeriodID_IN"
		, "TimePeriod_OUT" AS "TimePeriodID_OUT"
		, TO_CHAR(t1."StartTime", 'Day (dd/mm)') AS "SurveyDay_IN"
		, CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriodDescription_IN"
		--, TO_CHAR(t2."StartTime", 'Day (dd/mm)') AS "SurveyDay_OUT"
		, CONCAT(TO_CHAR(t2."StartTime", 'HH24:MI'), '-', TO_CHAR(t2."EndTime", 'HH24:MI')) AS "TimePeriodDescription_OUT"
		, "Duration"
		, d."DurationCategoryID"
		, CASE WHEN "Time_IN"::TIME <= TO_TIMESTAMP('06:00:00', 'HH24:MI:SS')::TIME THEN 'Unknown'
	          WHEN "Time_OUT"::TIME >= TO_TIMESTAMP('22:00:00', 'HH24:MI:SS')::TIME THEN 'Unknown'
	          ELSE d."Description" 
			  END AS "DurationCatergoryDescription"
 
 FROM (
			SELECT c."Description" AS "CarParkDescription"
			       , v1."ID"
				   , v1."SiteID" AS "Site_IN"
				   , v2."SiteID" AS "Site_OUT"
				   , v1."VRM"
				   , v1."CaptureTime" AS "Time_IN"
				   , v2."CaptureTime" AS "Time_OUT"
	 			   , v2."CaptureTime" - v1."CaptureTime" AS "Duration"
				   , v1."TimePeriodID" AS "TimePeriod_IN"
				   , v2."TimePeriodID" AS "TimePeriod_OUT"
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedTo", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" ) v1,
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedFrom", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime") v2, anpr."CarParks" c
			WHERE v1."CarParkID" = v2."CarParkID"
			AND v1."CarParkID" = c."CarParkID"
			--AND c."CarParkID" = 1  -- car park being considered *** need to change !!!
			AND v1."MatchedTo" = v2."ID"
			--AND v2."MatchedFrom" = v1."ID" 
			) x,
			anpr."DurationCategories" d, anpr."TimePeriods" t1, anpr."TimePeriods" t2
WHERE x."TimePeriod_IN" = t1."TimePeriodID"
AND x."TimePeriod_OUT" = t2."TimePeriodID"
AND x."Duration" >= d."StartTime"
AND x."Duration" < d."EndTime"

-- Include those exiting after last time period of day
UNION

SELECT "CarParkDescription"
        , "VRM"
		, "Site_IN"
		, "Site_OUT"
		, "Time_IN"
		, "Time_OUT"
		, "TimePeriod_IN" AS "TimePeriodID_IN"
		, NULL AS "TimePeriodID_OUT"
		, TO_CHAR(t1."StartTime", 'Day (dd/mm)') AS "SurveyDay_IN"
		, CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriodDescription_IN"
		, NULL AS "TimePeriodDescription_OUT"
		, NULL AS "Duration"
		,  14 AS "DurationCategoryID"
		, 'Unknown' AS "DurationCatergoryDescription"
 
 FROM (
			SELECT c."Description" AS "CarParkDescription"
			       , v1."ID"
				   , v1."SiteID" AS "Site_IN"
				   , v2."SiteID" AS "Site_OUT"
				   , v1."VRM"
				   , v1."CaptureTime" AS "Time_IN"
				   , v2."CaptureTime" AS "Time_OUT"
	 			   , v2."CaptureTime" - v1."CaptureTime" AS "Duration"
				   , v1."TimePeriodID" AS "TimePeriod_IN"
				   , NULL AS "TimePeriod_OUT"
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedTo", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" ) v1, 
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedFrom"
			 FROM anpr."VRMs" v, anpr."Sites" s
			 WHERE v."SiteID" = s."SiteID"
			 ) v2, anpr."CarParks" c
			WHERE v1."CarParkID" = v2."CarParkID"
			AND v1."MatchedTo" = v2."ID"
			AND v2."CaptureTime"::TIME > '22:00:00'::TIME   -- *** End time of survey day
			) x
			, anpr."TimePeriods" t1
WHERE x."TimePeriod_IN" = t1."TimePeriodID"
		
-- include Unmatched

UNION

SELECT "CarParkDescription"
        , "VRM"
		, "Site_IN"
		, NULL
		, "Time_IN"
		, NULL
		, "TimePeriod_IN" AS "TimePeriodID_IN"
		, NULL
		, TO_CHAR(t1."StartTime", 'Day (dd/mm)') AS "SurveyDay_IN"
		, CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriodDescription_IN"
		--, NULL
		, NULL
		, NULL
		, 14 AS "DurationCategoryID"
		, 'Unknown' AS "DurationCatergoryDescription"
FROM (
		SELECT c."Description" AS "CarParkDescription"
	   , v1."ID"
	   , v1."SiteID" AS "Site_IN"
	   , v1."VRM"
	   , v1."CaptureTime" AS "Time_IN"
	   , v1."TimePeriodID" AS "TimePeriod_IN"

		FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."CaptureTime", v."MatchedTo", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 --AND s."SiteID" = 11
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" ) v1, anpr."CarParks" c
			WHERE v1."CarParkID" = c."CarParkID"
			--AND c."CarParkID" = 1  -- car park being considered *** need to change !!!
			AND v1."MatchedTo" IS NULL
			--AND v2."MatchedFrom" = v1."ID" 
			) x, anpr."TimePeriods" t1
			WHERE x."TimePeriod_IN" = t1."TimePeriodID"

) z 
WHERE "CarParkDescription" = ''  -- need to change
AND "Site_IN" IN (SELECT "FromSiteID" FROM anpr."Routes")

ORDER BY "CarParkDescription", "TimePeriodID_IN", "VRM";

-- Generate pivot style table - NB: need to change day

SELECT * FROM CROSSTAB(
  '
  SELECT 
    --y."TimePeriodID"
	y."TimePeriodDescription"
    --, y."SurveyDay"
	--, y."DurationCategoryID"
	, y."DurationCategoryDescription"
    , COUNT("VRM")
FROM
(SELECT t."TimePeriodID"
        , CONCAT(TO_CHAR(t."StartTime", ''HH24:MI''), ''-'', TO_CHAR(t."EndTime", ''HH24:MI'')) AS "TimePeriodDescription"
		, TO_CHAR(t."StartTime", ''Day (dd/mm)'') AS "SurveyDay"
		, c."DurationCategoryID"
		, c."Description" AS "DurationCategoryDescription"
FROM (anpr."TimePeriods" t CROSS JOIN anpr."DurationCategories" c) 
ORDER BY t."TimePeriodID", c."DurationCategoryID") y
LEFT JOIN anpr."DurationDetails" d
ON ( y."SurveyDay" = d."SurveyDay_IN"
AND  y."TimePeriodID" =  d."TimePeriodID_IN"
AND y."DurationCategoryID" = d."DurationCategoryID")
WHERE y."SurveyDay" LIKE ''Sat%''     -- day being considered *** need to change !!!
GROUP BY y."TimePeriodDescription", y."DurationCategoryDescription"
ORDER BY y."TimePeriodDescription", y."DurationCategoryDescription"

  ',
  'SELECT "Description" 
FROM anpr."DurationCategories" m'
) AS (
  "Time of Entry" TEXT,
	"<5 mins" INTEGER,
	"5-30 mins" INTEGER,
	"30-60 mins" INTEGER,
	"1-1.5 hours" INTEGER,
	"1.5-2 hours" INTEGER,
	"2-2.5 hours" INTEGER,
	"2.5-3 hours" INTEGER,
	"3-3.5 hours" INTEGER,
	"3.5-4 hours" INTEGER,
	"4-5 hrs" INTEGER,
	"5-6 hrs" INTEGER,
	"6-8 hrs" INTEGER,
	">8 hrs" INTEGER,
	"unknown" INTEGER
);


/*** Checks

SELECT * FROM anpr."VRMs"
WHERE "SiteID" = 11
AND "CaptureTime" > '2025-12-02 07:00:00'
AND "CaptureTime" < '2025-12-02 08:15:00'

ORDER BY "CaptureTime"

--

SELECT COUNT(*)
FROM demand."VRMs"v, mhtc_operations."Supply" s
WHERE v."GeometryID" = s."GeometryID"
AND v."SurveyID" = 116
AND s."RoadName" = 'Site A (Bury Lane Car Park)'

--

SELECT * FROM anpr."VRMs"
WHERE "VRM" = 'NL61-DYP'

--

SELECT COUNT(*)
FROM demand."VRMs"v, mhtc_operations."Supply" s
WHERE v."GeometryID" = s."GeometryID"
AND v."SurveyID" = 116
AND s."RoadName" = 'Site A (Bury Lane Car Park)'


--

SELECT "CarParkDescription", "VRM", "Site_IN", "Site_OUT", "Time_IN", "Time_OUT", "TimePeriodID_IN", "TimePeriodID_OUT", "SurveyDay_IN", "TimePeriodDescription_IN", "TimePeriodDescription_OUT", "Duration", "DurationCategoryID", "DurationCatergoryDescription"
	FROM anpr."DurationDetails"
	WHERE  "Time_IN" >= '2025-12-02 08:00:00'
AND "Time_IN" < '2025-12-02 08:15:00'

--
SELECT 
	y."TimePeriodDescription"
	, y."DurationCategoryDescription"
    , COUNT("VRM")
FROM
(SELECT t."TimePeriodID"
        , CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriodDescription"
		, TO_CHAR(t."StartTime", 'Day (dd/mm)') AS "SurveyDay"
		, c."DurationCategoryID"
		, c."Description" AS "DurationCategoryDescription"
FROM (anpr."TimePeriods" t CROSS JOIN anpr."DurationCategories" c) 
ORDER BY t."TimePeriodID", c."DurationCategoryID") y
LEFT JOIN anpr."DurationDetails" d
ON ( y."SurveyDay" = d."SurveyDay_IN"
AND  y."TimePeriodID" =  d."TimePeriodID_IN"
AND y."DurationCategoryID" = d."DurationCategoryID")
WHERE y."SurveyDay" LIKE 'Tue%'     -- day being considered *** need to change !!!
AND y."TimePeriodID" = 9
GROUP BY y."TimePeriodDescription", y."DurationCategoryDescription"
ORDER BY y."TimePeriodDescription", y."DurationCategoryDescription"

***/