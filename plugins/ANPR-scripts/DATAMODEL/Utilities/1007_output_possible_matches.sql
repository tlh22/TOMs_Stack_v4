/***
 * Look for difficult ones to match
 *
 * Amend within "VRMs_View"
 * order using "Sort" concat("SurveyID", "VRM", "GeometryID")
 ***/
 

/*
 *  Differences in front part of reg plate
 */


SELECT DISTINCT (v1."VRM") AS "First",  v2."VRM" AS "Second", substring(v1."VRM", '(.+)-(.+)'), substring(v1."VRM", '.+-(.+)'), substring(v2."VRM", '(.+)-(.+)'), substring(v2."VRM", '.+-(.+)'), v1."SiteID", v1."CaptureTime", v2."SiteID", v2."CaptureTime"
FROM anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
FROM anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
WHERE v1."ID" > v2."ID"
AND v1."SiteID" = s1."SiteID"
AND v2."SiteID" = s2."SiteID"
AND s1."CarParkID" = 4
AND s2."CarParkID" = 4
AND v2."CaptureTime" >= v1."CaptureTime"
AND DATE_TRUNC('day', v2."CaptureTime") = DATE_TRUNC('day', v1."CaptureTime")
AND substring(v1."VRM", '.+-(.+)') = substring(v2."VRM", '.+-(.+)')
AND substring(v1."VRM", '(.+)-.+') != substring(v2."VRM", '(.+)-.+')

 /*
  * Differences in rear part
  */

UNION

SELECT DISTINCT (v1."VRM") AS "First",  v2."VRM" AS "Second", substring(v1."VRM", '(.+)-(.+)'), substring(v1."VRM", '.+-(.+)'), substring(v2."VRM", '(.+)-(.+)'), substring(v2."VRM", '.+-(.+)'), v1."SiteID", v1."CaptureTime", v2."SiteID", v2."CaptureTime"
FROM anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
FROM anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
WHERE v1."ID" > v2."ID"
AND v1."SiteID" = s1."SiteID"
AND v2."SiteID" = s2."SiteID"
AND s1."CarParkID" = 4
AND s2."CarParkID" = 4
AND v2."CaptureTime" >= v1."CaptureTime"
AND DATE_TRUNC('day', v2."CaptureTime") = DATE_TRUNC('day', v1."CaptureTime")
AND substring(v1."VRM", '.+-(.+)') != substring(v2."VRM", '.+-(.+)')
AND substring(v1."VRM", '(.+)-.+') = substring(v2."VRM", '(.+)-.+')
	 
ORDER BY "First"


/**/

/*** Checking

SELECT * FROM anpr."VRMs"
WHERE "VRM_Orig" LIKE 'YY5%-FJU'
ORDER BY "SurveyID";

***/