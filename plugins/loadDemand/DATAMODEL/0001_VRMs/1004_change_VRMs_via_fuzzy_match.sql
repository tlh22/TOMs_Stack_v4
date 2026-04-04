/**
Check for close matches within same GeometryID - and make changes (if not for same SurveyID)
**/

CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch" WITH SCHEMA "public";

/**
SELECT DISTINCT v1."GeometryID", v1."VRM", v2."VRM"
FROM (SELECT v."SurveyID", s."SurveyDay", su."RoadName", v."GeometryID", v."ID", v."VRM_Orig" AS "VRM"
	  FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
	  WHERE v."SurveyID" = s."SurveyID"
	  AND v."GeometryID" = su."GeometryID"
	 ) AS v1,
     (SELECT v."SurveyID", s."SurveyDay", su."RoadName", v."GeometryID", v."ID", v."VRM_Orig" AS "VRM"
	  FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
	  WHERE v."SurveyID" = s."SurveyID"
	  AND v."GeometryID" = su."GeometryID"
	  ) AS v2
--WHERE v1."GeometryID" = v2."GeometryID"
WHERE v1."RoadName" = v2."RoadName"
AND v1."GeometryID" != v2."GeometryID"
AND v1."SurveyID" != v2."SurveyID"
AND v1."VRM" != v2."VRM"
AND v1."ID" > v2."ID"
AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 2
--AND v1."SurveyID" > 30
--AND v1."SurveyDay" = v2."SurveyDay"
--AND v1."RoadName" = 'Gibbet Marsh Car Park'
AND v1."VRM" NOT IN (
    SELECT DISTINCT v11."VRM"
    FROM demand."VRMs" v11, demand."VRMs" v12
    WHERE v11."GeometryID" = v12."GeometryID"
    AND v11."SurveyID" = v12."SurveyID"
    AND v11."VRM" != v12."VRM"
    AND v11."ID" > v12."ID"
    AND levenshtein(v11."VRM"::text, v12."VRM"::text, 10, 10, 1) <= 2
)
ORDER BY v1."VRM";


SELECT v1.*, v2."VRM", v2."SurveyID"
FROM demand."VRMs_Final" v2 , demand."VRMs_Final" v1
WHERE v1."GeometryID" = v2."GeometryID"
AND v2."SurveyID" = v1."SurveyID" + 1
AND v1."VRM" != v2."VRM"
AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
AND (v1."VRM" NOT LIKE 'NO%');
**/

-- Change details
--SELECT v2."VRM", v1."VRM"
--FROM demand."VRMs_Final" AS v1, demand."VRMs_Final" AS v2
UPDATE demand."VRMs" AS v2
SET "VRM" = v1."VRM"
FROM demand."VRMs" v1, mhtc_operations."Supply" s
WHERE v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" != v2."SurveyID"
AND v1."VRM" != v2."VRM"
AND v1."ID" > v2."ID"
AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 2
AND v1."SurveyID" / 100 = v2."SurveyID" / 100   -- need to ensure that v1 and v2 have the same "SurveyDay"
AND v1."VRM" NOT IN (
    SELECT DISTINCT v11."VRM"
    FROM demand."VRMs" v11, demand."VRMs" v12
    WHERE v11."GeometryID" = v12."GeometryID"
    AND v11."SurveyID" = v12."SurveyID"
    AND v11."VRM" != v12."VRM"
    AND v11."ID" < v12."ID"
    AND levenshtein(v11."VRM"::text, v12."VRM"::text, 10, 10, 1) <= 2
)
AND v2."GeometryID" = s."GeometryID"
--AND s."CPZ" IN ('P', 'F', 'Y')
;

-- Very occassionally there is an incorrect change, e.g., when there is already a series with the candidate


-- View changes
/*
SELECT "VRM", "VRM_Orig"
FROM demand."VRMs"
WHERE "VRM" <> "VRM_Orig";
*/

