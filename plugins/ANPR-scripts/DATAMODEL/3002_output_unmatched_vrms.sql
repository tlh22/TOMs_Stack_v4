-- With time periods
  
SELECT v."SiteID", s."Description", v."VRM", v."VehicleTypeID", v."Direction", v."CaptureTime", CONCAT(TO_CHAR(t."StartTime", 'HH24:MI'), '-', TO_CHAR(t."EndTime", 'HH24:MI')) AS "TimePeriod"
FROM anpr."VRMs" v, anpr."Sites" s, anpr."TimePeriods" t
WHERE v."SiteID" = s."SiteID"
AND v."MatchedTo" IS NULL
AND v."MatchedFrom" IS NULL
AND v."CaptureTime" >= t."StartTime" and v."CaptureTime" < t."EndTime"
AND UPPER("VRM") != 'UNKNOWN'
-- AND s."SiteID" IN (31, 32)
ORDER BY "VRM", "CaptureTime"


/***

SELECT * 
FROM anpr."VRMs"
WHERE "MatchedTo" IS NULL
AND "MatchedFrom" IS NULL
ORDER BY "VRM", "CaptureTime" ASC 

***/

/***

SELECT "ID", v."SiteID", "VRM", "InternationalCodeID", "CaptureTime", "Direction", "VehicleTypeID", "PermitTypeID", "MatchedTo", "MatchedFrom", "VRM_Orig", "VRM_Extracted", "AnonomisedVRM"
FROM anpr."VRMs", 
 (
	SELECT "SiteID", cp."CarParkID", cp."Description"
	FROM anpr."CarParks" cp, anpr."Sites" si
	WHERE cp."CarParkID" = si."CarParkID"
	) x
WHERE v."SiteID" = x."SiteID"
AND x."CarParkID" = x
AND "VRM" LIKE '%NNN%'

***/