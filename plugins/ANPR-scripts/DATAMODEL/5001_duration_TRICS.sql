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

