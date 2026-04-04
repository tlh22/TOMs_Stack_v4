-- Dates for demand by street

/***
SELECT RiS."SurveyID", su."BeatTitle", s."RoadName",TO_CHAR( MIN(RiS."DemandSurveyDateTime"), 'dd/mm/yyyy')  AS "DemandSurveyDate"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY RiS."SurveyID", su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", RiS."SurveyID"

***/

-- can we do this as a crosstab query?



CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab('
SELECT d1."RoadName"::text, d1."BeatTitle"::text, 
CASE WHEN "DemandSurveyDate_Road" >= ''2022-09-20''::date OR "DemandSurveyDate_Road" <= ''2022-11-14''::date THEN
         TO_CHAR("DemandSurveyDate_Road", ''dd/mm/yyyy'')::text
     ELSE
         TO_CHAR("DemandSurveyDate_Area", ''dd/mm/yyyy'')::text
	 END
FROM

(SELECT s."RoadName"::text, su."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Road"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", su."BeatTitle") d1,

(SELECT a."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Area"
FROM (SELECT "SurveyID", "GeometryID", "RoadName", "BeatTitle"
      FROM mhtc_operations."Supply" s, demand."Surveys" su) a LEFT JOIN demand."RestrictionsInSurveys" RiS ON a."GeometryID" = RiS."GeometryID" AND a."SurveyID" = RiS."SurveyID"
WHERE RiS."SurveyID" > 0
AND RiS."DemandSurveyDateTime" >= ''2022-09-20''::date
AND RiS."DemandSurveyDateTime" <= ''2022-11-14''::date
GROUP BY a."BeatTitle"
ORDER BY a."BeatTitle") d2
WHERE d1."BeatTitle" = d2."BeatTitle"
ORDER BY d1."RoadName", d1."BeatTitle"
')
    AS ct("RoadName" text, "Saturday Afternoon" text, "Sunday Afternoon" text, 
		  "Weekday Afternoon" text, "Weekday Evening" text, "Weekday Overnight" text);

-- with days of week

SELECT * FROM crosstab('
SELECT d1."RoadName"::text, d1."BeatTitle"::text, 
CASE WHEN "DemandSurveyDate_Road" >= ''2022-09-20''::date OR "DemandSurveyDate_Road" <= ''2022-11-14''::date THEN
         TO_CHAR("DemandSurveyDate_Road", ''Day'')::text
     ELSE
         TO_CHAR("DemandSurveyDate_Area", ''Day'')::text
	 END
FROM

(SELECT s."RoadName"::text, su."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Road"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", su."BeatTitle") d1,

(SELECT a."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Area"
FROM (SELECT "SurveyID", "GeometryID", "RoadName", "BeatTitle"
      FROM mhtc_operations."Supply" s, demand."Surveys" su) a LEFT JOIN demand."RestrictionsInSurveys" RiS ON a."GeometryID" = RiS."GeometryID" AND a."SurveyID" = RiS."SurveyID"
WHERE RiS."SurveyID" > 0
AND RiS."DemandSurveyDateTime" >= ''2022-09-20''::date
AND RiS."DemandSurveyDateTime" <= ''2022-11-14''::date
GROUP BY a."BeatTitle"
ORDER BY a."BeatTitle") d2
WHERE d1."BeatTitle" = d2."BeatTitle"
ORDER BY d1."RoadName", d1."BeatTitle"
')
    AS ct("RoadName" text, "Saturday Afternoon" text, "Sunday Afternoon" text, 
		  "Weekday Afternoon" text, "Weekday Evening" text, "Weekday Overnight" text);
		  
-- Standalone query ...

SELECT d1."RoadName"::text, d1."BeatTitle"::text, 
CASE WHEN "DemandSurveyDate_Road" >= '2022-09-20'::date OR "DemandSurveyDate_Road" <= '2022-11-14'::date THEN
         TO_CHAR("DemandSurveyDate_Road", 'dd/mm/yyyy')::text
     ELSE
         TO_CHAR("DemandSurveyDate_Area", 'dd/mm/yyyy')::text
	 END AS "SurveyDate",
	 
	 CASE WHEN "DemandSurveyDate_Road" >= '2022-09-20'::date OR "DemandSurveyDate_Road" <= '2022-11-14'::date THEN
         TO_CHAR("DemandSurveyDate_Road", 'Day')::text
     ELSE
         TO_CHAR("DemandSurveyDate_Area", 'Day')::text
	 END AS "SurveyDay"
FROM

(SELECT s."RoadName"::text, s."SurveyAreaID", RiS."SurveyID", su."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Road"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY su."BeatTitle", RiS."SurveyID", s."SurveyAreaID", s."RoadName"
ORDER BY s."SurveyAreaID", s."RoadName", su."BeatTitle") d1,

(SELECT a."SurveyAreaID", a."BeatTitle"::text, MIN(RiS."DemandSurveyDateTime") AS "DemandSurveyDate_Area"
FROM (SELECT "SurveyID", "GeometryID", "RoadName", "SurveyAreaID", "BeatTitle"
      FROM mhtc_operations."Supply" s, demand."Surveys" su) a LEFT JOIN demand."RestrictionsInSurveys" RiS ON a."GeometryID" = RiS."GeometryID" AND a."SurveyID" = RiS."SurveyID"
WHERE RiS."SurveyID" > 0
--AND RiS."DemandSurveyDateTime" >= '2022-09-20'::date
--AND RiS."DemandSurveyDateTime" <= '2022-11-14'::date
GROUP BY a."BeatTitle",  a."SurveyAreaID"
ORDER BY  a."SurveyAreaID", a."BeatTitle") d2
	 
WHERE d1."BeatTitle" = d2."BeatTitle"
AND d1."SurveyAreaID" = d2."SurveyAreaID"
AND d1."SurveyID" = 104
AND d1."SurveyAreaID" = 31
ORDER BY d1."RoadName", d1."BeatTitle"


-- Orig

SELECT s."RoadName"::text, su."BeatTitle"::text, TO_CHAR( MIN(RiS."DemandSurveyDateTime"), 'dd/mm/yyyy')::text AS "DemandSurveyDate"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, demand."Surveys" su
WHERE RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = su."SurveyID"
AND RiS."SurveyID" > 0
GROUP BY su."BeatTitle", s."RoadName"
ORDER BY s."RoadName", su."BeatTitle"
