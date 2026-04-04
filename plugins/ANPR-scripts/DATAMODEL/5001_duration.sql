-- With time periods
 
 
SELECT "CarParkDescription", "VRM", "Site_IN",  "Site_OUT", "Time_IN",  "Time_OUT", TO_CHAR(t1."StartTime", 'Day (dd/mm)') AS "SurveyDay_IN", 
		CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriod_IN",
		--TO_CHAR(t."StartTime", 'Day (dd/mm)') AS "SurveyDay_OUT", 
		 CONCAT(TO_CHAR(t2."StartTime", 'HH24:MI'), '-', TO_CHAR(t2."EndTime", 'HH24:MI')) AS "TimePeriod_OUT", "Duration", d."Description"
 
 FROM (
			SELECT c."Description" AS "CarParkDescription", v1."ID", v1."SiteID" AS "Site_IN", v2."SiteID" AS "Site_OUT", v1."VRM", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT", 
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration", v1."TimePeriodID" AS "TimePeriod_IN", v2."TimePeriodID" AS "TimePeriod_OUT"
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
			AND v1."MatchedTo" = v2."ID"
			AND v2."MatchedFrom" = v1."ID" ) x,
			anpr."DurationCategories" d, anpr."TimePeriods" t1, anpr."TimePeriods" t2
WHERE x."TimePeriod_IN" = t1."TimePeriodID"
AND x."TimePeriod_OUT" = t2."TimePeriodID"
AND x."Duration" >= d."StartTime"
AND x."Duration" < d."EndTime"
ORDER BY "CarParkDescription", "TimePeriod_IN", "VRM"

-- For TRICS ANPR ??

SELECT "CarParkDescription", --"TimePeriod_IN", TO_CHAR(t."StartTime", 'Day (dd/mm)') AS "Survey Day", CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriod", 
		"ID", "Site IN", "Site OUT", "VRM", "VehicleTypeID", "Time_IN", "Time_OUT", "Duration" --, d."Description"
 
 FROM (
			SELECT c."Description" AS "CarParkDescription", v1."ID", v1."SiteID" AS "Site IN", v2."SiteID" AS "Site OUT", v1."VRM", v1."VehicleTypeID", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT", 
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration" --, v1."TimePeriodID" AS "TimePeriod_IN", v2."TimePeriodID" AS "TimePeriod_OUT"
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."VehicleTypeID", v."CaptureTime", v."MatchedTo" --, t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s --, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 --AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" 
			) v1,
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."VRM",  v."VehicleTypeID", v."CaptureTime", v."MatchedFrom" --, t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s --, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 --AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime"
			 ) v2
			  , anpr."CarParks" c
			WHERE v1."CarParkID" = v2."CarParkID"
			AND v1."CarParkID" = c."CarParkID"
			AND v1."MatchedTo" = v2."ID"
			AND v2."MatchedFrom" = v1."ID" ) x --,
			--anpr."DurationCategories" d, anpr."TimePeriods" t
--WHERE x."TimePeriod_IN" = t."TimePeriodID"
--AND x."Duration" >= d."StartTime"
--AND x."Duration" < d."EndTime"
ORDER BY "CarParkDescription", "VRM", "Time_IN"


-- another option

SELECT --"TimePeriod_IN", TO_CHAR(t."StartTime", 'Day (dd/mm)') AS "Survey Day", CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriod", 
		"VRM", "VehicleTypeID", "Site 1", "Direction 1", "Time 1", "TimePeriod 1", CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriod 1 Desc", 
		"Site 2", "Direction 2", "Time 2", "TimePeriod 2", CONCAT(TO_CHAR(t2."StartTime", 'HH24:MI'), '-', TO_CHAR(t2."EndTime", 'HH24:MI')) AS "TimePeriod 2 Desc", 
		"Duration", d."Description"
 
 FROM (
			SELECT c."Description" AS "CarParkDescription", v1."ID", v1."SiteID" AS "Site 1", v1."Direction" As "Direction 1",  v1."VRM" AS "VRM", 
	 				v1."VehicleTypeID" AS "VehicleTypeID",  v1."CaptureTime" AS "Time 1", v1."TimePeriodID" AS "TimePeriod 1", 
	 			   v2."SiteID" AS "Site 2", v2."Direction" As "Direction 2", v2."CaptureTime" AS "Time 2", v2."TimePeriodID" AS "TimePeriod 2",
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration"
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."Direction", v."VehicleTypeID", v."CaptureTime", v."MatchedTo", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" 
			) v1,
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."VRM", v."Direction", v."CaptureTime", v."MatchedFrom", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime"
			 ) v2
			  , anpr."CarParks" c
			WHERE v1."CarParkID" = v2."CarParkID"
			AND v1."CarParkID" = c."CarParkID"
			AND v1."MatchedTo" = v2."ID"
			AND v2."MatchedFrom" = v1."ID" ) x,
			anpr."DurationCategories" d, anpr."TimePeriods" t1, anpr."TimePeriods" t2
WHERE x."TimePeriod 1" = t1."TimePeriodID"
AND x."TimePeriod 2" = t2."TimePeriodID"
AND x."Duration" >= d."StartTime"
AND x."Duration" < d."EndTime"
ORDER BY "Time 1", "VRM"