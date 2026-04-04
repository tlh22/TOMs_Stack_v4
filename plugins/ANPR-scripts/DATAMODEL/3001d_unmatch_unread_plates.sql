
--- Remove any matches for 'noPlate'

UPDATE anpr."VRMs"
SET "MatchedTo" = NULL, "MatchedFrom" = NULL
WHERE UPPER("VRM") IN ('NOPLATE', 'UNKNOWN', 'UNKN-OWN');

-- Also unmatch "matches" across days
UPDATE anpr."VRMs" As v1
SET "MatchedTo" = NULL, "MatchedFrom" = NULL
FROM anpr."VRMs" As v2
WHERE DATE_TRUNC('day', v2."CaptureTime") != DATE_TRUNC('day', v1."CaptureTime")
