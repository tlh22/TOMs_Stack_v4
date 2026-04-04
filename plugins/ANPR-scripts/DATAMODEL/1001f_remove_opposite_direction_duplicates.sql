
-- Remove duplicates with wrong direction


-- OUT has already been matched (v1) - delete near IN (v2)

DELETE FROM anpr."VRMs" AS v
USING (
	SELECT v2."ID", v1."SiteID", v1."VRM", v1."CaptureTime", v1."Direction", v2."CaptureTime", v2."Direction", v2."CaptureTime" - v1."CaptureTime"
	FROM anpr."VRMs" v1, anpr."VRMs" v2
	WHERE v1."VRM" = v2."VRM"
	AND v1."CaptureTime" <= v2."CaptureTime"
	AND v2."CaptureTime" - v1."CaptureTime" < INTERVAL '1' minute 
	AND v2."CaptureTime" - v1."CaptureTime" > INTERVAL '0' minute 
	AND v1."SiteID" = v2."SiteID"
	AND v1."Direction" != v2."Direction"  
	AND v1."ID" != v2."ID"
	AND v1."MatchedTo" IS NULL
	AND v1."MatchedFrom" IS NOT NULL
	AND v2."MatchedTo" IS NULL
	AND v2."MatchedFrom" IS NULL
) f 
WHERE v."ID" = f."ID"
;

-- IN has already been matched (v1) - delete near OUT (v2)

DELETE FROM anpr."VRMs" AS v
USING (
	SELECT v2."ID", v1."SiteID", v1."VRM", v1."CaptureTime", v1."Direction", v2."CaptureTime", v2."Direction", v2."CaptureTime" - v1."CaptureTime"
	FROM anpr."VRMs" v1, anpr."VRMs" v2
	WHERE v1."VRM" = v2."VRM"
	AND v1."CaptureTime" <= v2."CaptureTime"
	AND v2."CaptureTime" - v1."CaptureTime" < INTERVAL '1' minute 
	AND v2."CaptureTime" - v1."CaptureTime" > INTERVAL '0' minute 
	AND v1."SiteID" = v2."SiteID"
	AND v1."Direction" != v2."Direction"  
	AND v1."ID" != v2."ID"
	AND v1."MatchedTo" IS NOT NULL
	AND v1."MatchedFrom" IS NULL
	AND v2."MatchedTo" IS NULL
	AND v2."MatchedFrom" IS NULL
) f 
WHERE v."ID" = f."ID"
;