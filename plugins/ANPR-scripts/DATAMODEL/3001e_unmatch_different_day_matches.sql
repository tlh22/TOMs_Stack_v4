-- Also unmatch "matches" across days
UPDATE anpr."VRMs" v1
SET "MatchedTo" = NULL, "MatchedFrom" = NULL
FROM anpr."VRMs" v2
WHERE v2."MatchedTo" = v1."ID"
AND DATE_TRUNC('day', v2."CaptureTime") != DATE_TRUNC('day', v1."CaptureTime");

UPDATE anpr."VRMs" v1
SET "MatchedTo" = NULL, "MatchedFrom" = NULL
FROM anpr."VRMs" v2
WHERE v1."MatchedFrom" = v2."ID"
AND DATE_TRUNC('day', v2."CaptureTime") != DATE_TRUNC('day', v1."CaptureTime");
