/***
 *
 * For 2022, there are a few points to consider:
 * - At least one tablet (Blue) was not able to keep time and so was not displaying the correct date or time
 * - Some of the dates reflect changes made by TH and JB following the survey and so do not reflect the correct survey day/time
 *
 ***/
 
 -- ** Check for any records outside survey dates

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."DemandSurveyDateTime", "Demand"
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND NOT (RiS."DemandSurveyDateTime" >= '2022-09-20'::date
AND RiS."DemandSurveyDateTime" <= '2022-11-14'::date)
ORDER BY "DemandSurveyDateTime"

--**** CHECKS

-- ***** Check for time differences on overnights

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."Enumerator", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day'), RiS."CaptureSource"
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 101
--AND TRIM(TO_CHAR(RiS."DemandSurveyDateTime", 'Day')) NOT IN ('Tuesday', 'Wednesday', 'Thursday')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') NOT IN ('22/09/2022', '27/09/2022', '28/09/2022', '29/09/2022', '04/10/2022', '05/10/2022', '06/10/2022', '12/10/2022', '13/10/2022')
AND NOT ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 0
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT < 6)
AND RiS."Enumerator" NOT IN ('TH', 'JB', 'jb', 'mn')
ORDER BY "DemandSurveyDateTime"

-- Updates for overnight

-- Add an hour ...
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '1 hour'
WHERE "SurveyID" = 101
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT > 22
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022', '26/09/2022', '27/09/2022', '28/09/2022', '03/10/2022', '04/10/2022', '11/10/2022', '12/10/2022')
;

-- Deal with Blue - 1-A, 1-C and part of 1-D done on 21/9 Add six hours ... (not sure what happened here - showing done between 19 and 20)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '5 hour'
WHERE "SurveyID" = 101
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022')
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT < 22
;


-- ***** Check for time differences on afternoons

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."Enumerator", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day'), RiS."CaptureSource"
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 102
AND NOT (
 TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022', '22/09/2022', '27/09/2022', '28/09/2022', '29/09/2022', '04/10/2022', '06/10/2022', '12/10/2022', '18/10/2022')
AND ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 14
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT <= 16)
	)
AND RiS."Enumerator" NOT IN ('TH', 'JB', 'jb', 'mn')
ORDER BY s."SurveyAreaName", "DemandSurveyDateTime"

-- Updates


-- ***** Check for time differences on evenings

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."Enumerator", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day'), RiS."CaptureSource"
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 103
AND NOT (
	TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022', '22/09/2022', '27/09/2022', '28/09/2022', '29/09/2022', '04/10/2022', '12/10/2022')
AND ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 20
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT <= 22)
	)
AND RiS."Enumerator" NOT IN ('TH', 'JB', 'jb', 'mn')
ORDER BY s."SurveyAreaName", "DemandSurveyDateTime"

-- Updates

-- Add 25 hours ...
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" - interval '25 hour'
WHERE "SurveyID" = 103
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 18
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('11/10/2022', '24/10/2022')
;

-- Deal with Blue - 4-B done on 27/9 (showing 21/9)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '6 days 1 hour'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 103
AND s."SurveyAreaName" = '4-B'
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022')

-- Deal with Blue - 5-F done on 12/10 (showing 28/09)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '14 days 16 hours'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 103
AND s."SurveyAreaName" = '5-F'
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('28/09/2022')

-- ***** Check for time differences on Saturday afternoon

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."Enumerator", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day'), RiS."CaptureSource"
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 104
AND NOT (
 TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('24/09/2022', '01/10/2022', '15/10/2022', '12/11/2022')
AND ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 14
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT <= 17)
	)
AND RiS."Enumerator" NOT IN ('TH', 'JB', 'jb', 'mn')
ORDER BY s."SurveyAreaName", "DemandSurveyDateTime"

-- Updates
-- Deal with Blue - 3-C and 3-E done on 24/9 (showing 21/9)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '2 days 19 hour'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 104
AND s."SurveyAreaName" IN ('3-C', '3-E')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022')

-- Deal with Blue - 5-C done on 15/10 (showing 28/9)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '17 days 10 hour'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 104
AND s."SurveyAreaName" = '5-C'
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('28/09/2022')

-- Deal with Blue - 5-D done on 15/10 (showing 28/9)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '17 days 10 hour'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 104
AND s."SurveyAreaName" = '5-D'
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('28/09/2022')

-- 7-D - set to 15/10
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" - interval '120 days'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 104
AND s."SurveyAreaName" = '7-D'
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('11/02/2023')

-- Deal with Aqua - 6-D add 1 hour for 12/11
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '1 hour'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 104
AND s."SurveyAreaName" = '6-D'
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('12/11/2022')

-- ***** Check for time differences on Sunday afternoon

SELECT su."BeatTitle"::text, RiS."GeometryID", s."RoadName", s."SurveyAreaName", RiS."Enumerator", RiS."DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Day'), RiS."CaptureSource"
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" su, 
(mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE RiS."SurveyID" = su."SurveyID"
AND RiS."GeometryID" = s."GeometryID"
AND RiS."SurveyID" = 105
AND NOT (
 TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('25/09/2022', '09/10/2022', '16/10/2022', '13/11/2022')
AND ((TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT >= 14
AND (TO_CHAR(RiS."DemandSurveyDateTime", 'HH24'))::INT <= 17)
	)
AND RiS."Enumerator" NOT IN ('TH', 'JB', 'jb', 'mn')
ORDER BY s."SurveyAreaName", "DemandSurveyDateTime"

-- Updates

-- Deal with Blue - 3-C and 3-E done on 25/9 (showing 21/9)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '3 days 19 hour'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 105
AND s."SurveyAreaName" IN ('3-C', '3-E')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('21/09/2022')

-- Deal with Blue - 7-C on 9/10 (showing 28/9)
UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '11 days 10 hour'
FROM (mhtc_operations."Supply" a LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code") s
WHERE s."GeometryID" = RiS."GeometryID"
AND "SurveyID" = 105
AND s."SurveyAreaName" IN ('7-C')
AND TO_CHAR(RiS."DemandSurveyDateTime", 'dd/mm/yyyy') IN ('28/09/2022')