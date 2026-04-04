-- With time periods
 
 
SELECT 	CONCAT(''''', "Site_IN", '-', "Site_OUT") AS "Route",
		CASE
			WHEN "Site_IN" = 1 and "Site_OUT" = 1 THEN 'North-North'
			WHEN "Site_IN" = 1 and "Site_OUT" = 2 THEN 'North-South'
			WHEN "Site_IN" = 2 and "Site_OUT" = 1 THEN 'South-North'
			WHEN "Site_IN" = 2 and "Site_OUT" = 2 THEN 'South-South'
		END AS "RouteDescription", 
		"AnonomisedVRM" AS "VRM_1", "Site_IN",  "AnonomisedVRM" AS "VRM_2", "Site_OUT", "Time_IN",  "Time_OUT", TO_CHAR(t1."StartTime", 'Day') AS "SurveyDay_IN", 
		CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriod_IN",
		--TO_CHAR(t2."StartTime", 'Day') AS "SurveyDay_OUT", 
		 CONCAT(TO_CHAR(t2."StartTime", 'HH24:MI'), '-', TO_CHAR(t2."EndTime", 'HH24:MI')) AS "TimePeriod_OUT", "Duration", d."Description" AS "DurationCategory",
		 
		CASE
			WHEN d."DurationCategoryID" > 1 AND (("Site_IN" = 1 and "Site_OUT" = 2) OR ("Site_IN" = 2 and "Site_OUT" = 1)) THEN 'Non-Development'
			ELSE 'Development'
		END AS "JourneyType", 
		CASE
			WHEN d."DurationCategoryID" > 1 AND (("Site_IN" = 1 and "Site_OUT" = 2) OR ("Site_IN" = 2 and "Site_OUT" = 1)) THEN FALSE
			ELSE TRUE
		END AS "RelatedJourney"
 
 FROM (
			SELECT c."Description" AS "CarParkDescription", v1."ID", v1."SiteID" AS "Site_IN", v2."SiteID" AS "Site_OUT", v1."AnonomisedVRM", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT", 
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration", v1."TimePeriodID" AS "TimePeriod_IN", v2."TimePeriodID" AS "TimePeriod_OUT"
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."AnonomisedVRM", v."CaptureTime", v."MatchedTo", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" ) v1,
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."AnonomisedVRM", v."CaptureTime", v."MatchedFrom", t."TimePeriodID"
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
ORDER BY "CarParkDescription", "TimePeriod_IN", "AnonomisedVRM"

-- For TRICS ANPR ??

SELECT "CarParkDescription", --"TimePeriod_IN", TO_CHAR(t."StartTime", 'Day') AS "Survey Day", CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriod", 
		"ID", "Site IN", "Site OUT", "AnonomisedVRM", "Time_IN", "Time_OUT", "Duration" --, d."Description"
 
 FROM (
			SELECT c."Description" AS "CarParkDescription", v1."ID", v1."SiteID" AS "Site IN", v2."SiteID" AS "Site OUT", v1."AnonomisedVRM", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT", 
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration" --, v1."TimePeriodID" AS "TimePeriod_IN", v2."TimePeriodID" AS "TimePeriod_OUT"
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."AnonomisedVRM", v."CaptureTime", v."MatchedTo" --, t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s --, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 --AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" 
			) v1,
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."AnonomisedVRM", v."CaptureTime", v."MatchedFrom" --, t."TimePeriodID"
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
ORDER BY "CarParkDescription", "AnonomisedVRM", "Time_IN"

---

SELECT "CarParkDescription", "AnonomisedVRM", "Site_IN",  "Site_OUT", "Time_IN",  "Time_OUT", TO_CHAR(t1."StartTime", 'Day (dd/mm)') AS "SurveyDay_IN", 
		CONCAT(TO_CHAR(t1."StartTime", 'HH24:MI'), '-', TO_CHAR(t1."EndTime", 'HH24:MI')) AS "TimePeriod_IN",
		--TO_CHAR(t2."StartTime", 'Day') AS "SurveyDay_OUT", 
		 CONCAT(TO_CHAR(t2."StartTime", 'HH24:MI'), '-', TO_CHAR(t2."EndTime", 'HH24:MI')) AS "TimePeriod_OUT", "Duration", d."Description"
 
 FROM (
			SELECT c."Description" AS "CarParkDescription", v1."ID", v1."SiteID" AS "Site_IN", v2."SiteID" AS "Site_OUT", v1."AnonomisedVRM", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT", 
	 			   v2."CaptureTime" - v1."CaptureTime" AS "Duration", v1."TimePeriodID" AS "TimePeriod_IN", v2."TimePeriodID" AS "TimePeriod_OUT"
			FROM 
			(SELECT v."ID", s."CarParkID", v."SiteID", v."AnonomisedVRM", v."CaptureTime", v."MatchedTo", t."TimePeriodID"
			 FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
			 WHERE v."SiteID" = s."SiteID"
			 AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime" ) v1,
			 (SELECT v."ID", s."CarParkID", v."SiteID", v."AnonomisedVRM", v."CaptureTime", v."MatchedFrom", t."TimePeriodID"
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
ORDER BY "CarParkDescription", "TimePeriod_IN", "AnonomisedVRM"