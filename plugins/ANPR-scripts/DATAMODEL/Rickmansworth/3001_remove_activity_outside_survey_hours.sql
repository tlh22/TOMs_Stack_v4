/***

remove any entry/exit details before or after the survey hours (excluding opening/closing records)

***/

/***
Need to unmatch before deleting
***/

UPDATE anpr."VRMs"
SET "MatchedTo" = NULL, "MatchedFrom" = NULL
WHERE "ID" IN (
	SELECT "MatchedTo"
	FROM anpr."VRMs" v
	WHERE v."CaptureTime"::TIME < '05:58:00'::TIME  -- 'Start of Day'
	OR v."CaptureTime"::TIME > '22:02:00'::TIME -- 'End of Day'
	UNION
	SELECT "MatchedFrom"
	FROM anpr."VRMs" v
	WHERE v."CaptureTime"::TIME < '05:59:00'::TIME  -- 'Start of Day'
	OR v."CaptureTime"::TIME > '22:01:00'::TIME -- 'End of Day'
	)
;

DELETE FROM anpr."VRMs"
WHERE "ID" IN 
(
	SELECT "ID"
	FROM anpr."VRMs" v
	WHERE v."CaptureTime"::TIME < '05:58:00'::TIME  -- 'Start of Day'
	OR v."CaptureTime"::TIME > '22:02:00'::TIME -- 'End of Day'
)
;