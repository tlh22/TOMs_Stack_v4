/***

Pivot style table including all time periods for duration

***/

CREATE EXTENSION IF NOT EXISTS tablefunc;


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