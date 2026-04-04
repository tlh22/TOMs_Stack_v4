/***
 * Look for difficult ones to match
 ***/
 

/*
 *  Differences in front part of reg plate
 */



SELECT DISTINCT (v1."VRM") AS "First",  v2."VRM" AS "Second", substring(v1."VRM", '(.+)-(.+)'), substring(v1."VRM", '.+-(.+)'), substring(v2."VRM", '(.+)-(.+)'), substring(v2."VRM", '.+-(.+)'),
v1."Direction", v1."CaptureTime", v2."Direction", v2."CaptureTime"
FROM anpr."VRMs" v1, anpr."VRMs" v2
WHERE v1."ID" > v2."ID"
AND substring(v1."VRM", '.+-(.+)') = substring(v2."VRM", '.+-(.+)')
AND substring(v1."VRM", '(.+)-.+') != substring(v2."VRM", '(.+)-.+')
AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
AND v1."MatchedTo" IS NULL AND v1."MatchedFrom" IS NULL
AND v2."MatchedTo" IS NULL AND v2."MatchedFrom" IS NULL
AND v1."SiteID" = 172  -- IN 
AND v2."SiteId" = 171 -- OUT


	
 /*
  * Differences in rear part
  */

UNION

SELECT DISTINCT (v1."VRM") AS "First",  v2."VRM" AS "Second", substring(v1."VRM", '(.+)-(.+)'), substring(v1."VRM", '.+-(.+)'), substring(v2."VRM", '(.+)-(.+)'), substring(v2."VRM", '.+-(.+)'),
v1."Direction", v1."CaptureTime", v2."Direction", v2."CaptureTime"
FROM anpr."VRMs" v1, anpr."VRMs" v2
WHERE v1."ID" > v2."ID"
AND substring(v1."VRM", '.+-(.+)') != substring(v2."VRM", '.+-(.+)')
AND substring(v1."VRM", '(.+)-.+') = substring(v2."VRM", '(.+)-.+')
AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
AND v1."MatchedTo" IS NULL AND v1."MatchedFrom" IS NULL
AND v2."MatchedTo" IS NULL AND v2."MatchedFrom" IS NULL
AND v1."SiteID" = 172  -- IN 
AND v2."SiteId" = 171 -- OUT

ORDER BY "First"


/***

SELECT * FROM anpr."VRMs"
WHERE "VRM" IN ('DY23-FWV', 'OY23-FWV')
ORDER BY "CaptureTime"

***/