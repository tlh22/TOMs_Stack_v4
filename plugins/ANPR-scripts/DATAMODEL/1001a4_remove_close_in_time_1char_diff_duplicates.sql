--
CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch" WITH SCHEMA "public";

CREATE OR REPLACE FUNCTION stringdiff(text, text)
RETURNS TEXT
AS $$
     SELECT array_to_string(ARRAY(
         SELECT
             CASE WHEN substring($1 FROM n FOR 1) = substring($2 FROM n FOR 1)
                  THEN ' '
                  ELSE substring($2 FROM n FOR 1)
             END
         FROM generate_series(1, character_length($1)) as n), '');
$$ language sql;


DELETE FROM anpr."VRMs" AS v1
USING (
		SELECT e."ID", e."VRM_1", e."VRM_2", "CaptureTime_1", "CaptureTime_2", "DifferentLetterFrom",  "DifferentLetterTo"
		FROM 
				(SELECT v1."ID", v1."VRM" AS "VRM_1", v2."VRM" AS "VRM_2", v1."CaptureTime" AS "CaptureTime_1", v2."CaptureTime" AS "CaptureTime_2",

				 TRIM(stringdiff(v1."VRM"::text, v2."VRM"::text)) AS "DifferentLetterFrom",
						  TRIM(stringdiff(v2."VRM"::text, v1."VRM"::text)) AS "DifferentLetterTo"
		FROM anpr."VRMs" v1, anpr."VRMs" v2
		WHERE levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) = 1
		AND v2."CaptureTime" - v1."CaptureTime" <= INTERVAL '1' minute
		AND v2."CaptureTime" - v1."CaptureTime" >= INTERVAL '0' minute
		AND v1."Direction" = v2."Direction"
		AND v1."SiteID" = v2."SiteID"
		AND v1."ID" < v2."ID") e, 
		"anpr"."PossibleMatches" p 
		WHERE e."DifferentLetterFrom" = p."Letter1"
		AND e."DifferentLetterTo" = p."Letter2"
		) f 
WHERE v1."ID" = f."ID"
;

-- Sort out directions
/***
SELECT v1."SiteID", v1."VRM", v1."CaptureTime", v1."Direction", v2."CaptureTime", v2."Direction", v2."CaptureTime" - v1."CaptureTime"
FROM anpr."VRMs" v1, anpr."VRMs" v2
WHERE v1."VRM" = v2."VRM"
AND v1."CaptureTime" <= v2."CaptureTime"
AND v2."CaptureTime" - v1."CaptureTime" < INTERVAL '1' minute 
AND v2."CaptureTime" - v1."CaptureTime" > INTERVAL '0' minute 
AND v1."SiteID" = v2."SiteID"
AND ( v1."Direction" = v2."Direction"  
      OR UPPER(v1."Direction") = 'UNKNOWN' OR UPPER(v2."Direction") = 'UNKNOWN')
AND v1."ID" != v2."ID";

SELECT v1.*, v2."CaptureTime", v2."Direction", v2."CaptureTime" - v1."CaptureTime"
FROM anpr."VRMs" v1, anpr."VRMs" v2
WHERE v1."VRM" = v2."VRM"
AND v1."CaptureTime" <= v2."CaptureTime"
AND v2."CaptureTime" - v1."CaptureTime" < INTERVAL '1' minute 
AND v2."CaptureTime" - v1."CaptureTime" > INTERVAL '0' minute 
AND v1."SiteID" = v2."SiteID"
AND ( (UPPER(v1."Direction") = 'IN' AND UPPER(v2."Direction") = 'OUT') OR
      (UPPER(v1."Direction") = 'OUT' AND UPPER(v2."Direction") = 'IN') )
AND v1."ID" != v2."ID";

***/