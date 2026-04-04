/***
 * Look for difficult ones to match
 *
 * Amend within "VRMs_View"
 * order using "Sort" concat("SurveyID", "VRM", "GeometryID")
 ***/
 

/*
 *  Differences in front part of reg plate
 */


SELECT DISTINCT (v1."VRM") AS "First",  v2."VRM" AS "Second", substring(v1."VRM", '(.+)-(.+)'), substring(v1."VRM", '.+-(.+)'), substring(v2."VRM", '(.+)-(.+)'), substring(v2."VRM", '.+-(.+)')
FROM demand."VRMs" v1, demand."VRMs" v2, 
    (mhtc_operations."Supply" sp LEFT JOIN mhtc_operations."SurveyAreas" sa ON sp."SurveyAreaID" = sa."Code") AS su
WHERE v1."ID" > v2."ID"
AND v1."GeometryID" = v2."GeometryID"
AND v1."GeometryID" = su."GeometryID"
AND substring(v1."VRM", '.+-(.+)') = substring(v2."VRM", '.+-(.+)')
AND substring(v1."VRM", '(.+)-.+') != substring(v2."VRM", '(.+)-.+')
--AND (su."SurveyAreaName" LIKE 'L%' OR
--     su."SurveyAreaName" LIKE 'E-0%' OR
--     su."SurveyAreaName" LIKE 'P%' OR
--     su."SurveyAreaName" LIKE 'T%' OR
--     su."SurveyAreaName" LIKE 'V%'
--     )
AND su."RoadName" IN ('White Sands Car Park', 'Brewery Street Car Park' )

 /*
  * Differences in rear part
  */

UNION

SELECT DISTINCT (v1."VRM") AS "First",  v2."VRM" AS "Second", substring(v1."VRM", '(.+)-(.+)'), substring(v1."VRM", '.+-(.+)'), substring(v2."VRM", '(.+)-(.+)'), substring(v2."VRM", '.+-(.+)')
FROM demand."VRMs" v1, demand."VRMs" v2, 
    (mhtc_operations."Supply" sp LEFT JOIN mhtc_operations."SurveyAreas" sa ON sp."SurveyAreaID" = sa."Code") AS su
WHERE v1."ID" > v2."ID"
AND v1."GeometryID" = v2."GeometryID"
AND v1."GeometryID" = su."GeometryID"
AND substring(v1."VRM", '.+-(.+)') != substring(v2."VRM", '.+-(.+)')
AND substring(v1."VRM", '(.+)-.+') = substring(v2."VRM", '(.+)-.+')
--AND (su."SurveyAreaName" LIKE 'L%' OR
--     su."SurveyAreaName" LIKE 'E-0%' OR
--     su."SurveyAreaName" LIKE 'P%' OR
--     su."SurveyAreaName" LIKE 'T%' OR
--     su."SurveyAreaName" LIKE 'V%'
--     )
AND su."RoadName" IN ('White Sands Car Park', 'Brewery Street Car Park' )
	 
ORDER BY "First"


/**/

/***
UPDATE demand."VRMs" AS v2
SET "VRM" = v1."VRM"
FROM demand."VRMs" v1, (SELECT s."GeometryID", sa."SurveyAreaName"
 FROM mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" sa
 WHERE s."SurveyAreaID" = sa."Code") AS p
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
AND v2."GeometryID" = p."GeometryID"
--AND (su."SurveyAreaName" LIKE 'L%' OR
--     su."SurveyAreaName" LIKE 'E-0%' OR
--     su."SurveyAreaName" LIKE 'P%' OR
--     su."SurveyAreaName" LIKE 'T%' OR
--     su."SurveyAreaName" LIKE 'V%'
--     )
;
;
***/

/*** Checking

SELECT * FROM demand."VRMs"
WHERE "VRM_Orig" LIKE 'YY5%-FJU'
ORDER BY "SurveyID";

***/