/***

Steps:

 - Add supply
 - Create new records in RiS/Counts
 
Check data collected:
 - Check times match time period

***/

/*** Incorrect YEAR


SELECT RiS."GeometryID", RiS."SurveyID", a."SurveyAreaName", "DemandSurveyDateTime", "Enumerator", "CaptureSource"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND EXTRACT('YEAR' FROM "DemandSurveyDateTime") = 2024;

-- 2024

UPDATE demand."RestrictionsInSurveys" RiS
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + interval '1 year'
WHERE EXTRACT('YEAR' FROM "DemandSurveyDateTime") = 2024;

***/


SELECT RiS."GeometryID", RiS."SurveyID", a."SurveyAreaName", "DemandSurveyDateTime", "Enumerator", "CaptureSource"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
 
-- *** ALL 

-- Overnight

SELECT RiS."GeometryID", RiS."SurveyID", a."SurveyAreaName", "DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') AS "DoW", "Enumerator", "CaptureSource"
, CASE WHEN (RiS."DemandSurveyDateTime"::time >= '00:00' AND RiS."DemandSurveyDateTime"::time <= '04:00') THEN 'Overnight'
     WHEN (RiS."DemandSurveyDateTime"::time >= '09:00' AND RiS."DemandSurveyDateTime"::time <= '13:00') THEN 'Morning'
	 WHEN (RiS."DemandSurveyDateTime"::time >= '13:00' AND RiS."DemandSurveyDateTime"::time <= '17:00') THEN 'Afternoon'
	 END As "SurveyPeriod"
, "Demand"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND (
(RiS."SurveyID" IN (101, 201, 301, 401) AND (NOT (RiS."DemandSurveyDateTime"::time >= '00:00' AND RiS."DemandSurveyDateTime"::time <= '04:00')))
OR (RiS."SurveyID" IN (101, 201) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Tue', 'Wed', 'Thu')))
OR (RiS."SurveyID" IN (301) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sat')))
OR (RiS."SurveyID" IN (401) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sun')))
)
AND UPPER("CaptureSource") NOT LIKE '%LEOPARD%'

-- Morning

UNION

SELECT RiS."GeometryID", RiS."SurveyID", a."SurveyAreaName", "DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') AS "DoW", "Enumerator", "CaptureSource"
, CASE WHEN (RiS."DemandSurveyDateTime"::time >= '00:00' AND RiS."DemandSurveyDateTime"::time <= '04:00') THEN 'Overnight'
     WHEN (RiS."DemandSurveyDateTime"::time >= '09:00' AND RiS."DemandSurveyDateTime"::time <= '13:00') THEN 'Morning'
	 WHEN (RiS."DemandSurveyDateTime"::time >= '13:00' AND RiS."DemandSurveyDateTime"::time <= '17:00') THEN 'Afternoon'
	 END As "SurveyPeriod"
, "Demand"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND (
(RiS."SurveyID" IN (102, 202, 302, 402) AND (NOT (RiS."DemandSurveyDateTime"::time >= '09:00' AND RiS."DemandSurveyDateTime"::time <= '13:00')))
OR (RiS."SurveyID" IN (102, 202) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Tue', 'Wed', 'Thu')))
OR (RiS."SurveyID" IN (302) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sat')))
OR (RiS."SurveyID" IN (402) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sun')))
)
AND UPPER("CaptureSource") NOT LIKE '%LEOPARD%'

-- Afternoon

UNION

SELECT RiS."GeometryID", RiS."SurveyID", a."SurveyAreaName", "DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') AS "DoW", "Enumerator", "CaptureSource"
, CASE WHEN (RiS."DemandSurveyDateTime"::time >= '00:00' AND RiS."DemandSurveyDateTime"::time <= '04:00') THEN 'Overnight'
     WHEN (RiS."DemandSurveyDateTime"::time >= '09:00' AND RiS."DemandSurveyDateTime"::time <= '13:00') THEN 'Morning'
	 WHEN (RiS."DemandSurveyDateTime"::time >= '13:00' AND RiS."DemandSurveyDateTime"::time <= '17:00') THEN 'Afternoon'
	 END As "SurveyPeriod"
, "Demand"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND (
(RiS."SurveyID" IN (103, 203, 303, 403) AND (NOT (RiS."DemandSurveyDateTime"::time >= '13:00' AND RiS."DemandSurveyDateTime"::time <= '17:00')))
OR (RiS."SurveyID" IN (103, 203) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Tue', 'Wed', 'Thu')))
OR (RiS."SurveyID" IN (303) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sat')))
OR (RiS."SurveyID" IN (403) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sun')))
)
AND UPPER("CaptureSource") NOT LIKE '%LEOPARD%'

--ORDER BY a."SurveyAreaName", RiS."SurveyID"

ORDER BY 2, 3, 4

-- *** Summary

-- Overnight

SELECT a."SurveyAreaName", RiS."SurveyID", COUNT (RiS."GeometryID")
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND RiS."SurveyID" IN (101, 201, 301, 401)
AND NOT (RiS."DemandSurveyDateTime"::time >= '00:00'
AND RiS."DemandSurveyDateTime"::time <= '04:00'
)
GROUP BY a."SurveyAreaName", RiS."SurveyID"
--ORDER BY a."SurveyAreaName", RiS."SurveyID"

-- Morning

UNION

SELECT a."SurveyAreaName", RiS."SurveyID", COUNT (RiS."GeometryID")
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND RiS."SurveyID" IN (102, 202, 302, 402)
AND NOT (RiS."DemandSurveyDateTime"::time >= '09:00'
AND RiS."DemandSurveyDateTime"::time <= '13:00'
)
GROUP BY a."SurveyAreaName", RiS."SurveyID"
--ORDER BY a."SurveyAreaName", RiS."SurveyID"

-- Afternoon

UNION

SELECT a."SurveyAreaName", RiS."SurveyID", COUNT (RiS."GeometryID")
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND RiS."SurveyID" IN (103, 203, 303, 403)
AND NOT (RiS."DemandSurveyDateTime"::time >= '13:00'
AND RiS."DemandSurveyDateTime"::time <= '17:00'
)
GROUP BY a."SurveyAreaName", RiS."SurveyID"
--ORDER BY a."SurveyAreaName", RiS."SurveyID"
ORDER BY 1, 2


/***

Now remove these from the dataset ...

***/

/***

Specific area/survey

***/


SELECT a."SurveyAreaName", RiS."SurveyID", COUNT (RiS."GeometryID")
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND RiS."SurveyID" IN (303)
AND a."SurveyAreaName" = 'I-4'
GROUP BY a."SurveyAreaName", RiS."SurveyID"
--ORDER BY a."SurveyAreaName", RiS."SurveyID"
ORDER BY 1, 2




SELECT a."SurveyAreaName", RiS."SurveyID", RiS."Enumerator", COUNT (RiS."GeometryID"),
CASE WHEN (RiS."DemandSurveyDateTime"::time >= '00:00'
         AND RiS."DemandSurveyDateTime"::time <= '04:00') THEN 'Overnight'
     WHEN (RiS."DemandSurveyDateTime"::time >= '09:00'
         AND RiS."DemandSurveyDateTime"::time <= '13:00') THEN 'Morning'
     WHEN (RiS."DemandSurveyDateTime"::time >= '13:00'
         AND RiS."DemandSurveyDateTime"::time <= '17:00') THEN 'Morning'
     END AS "TimePeriod"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND RiS."SurveyID" IN (303)
AND a."SurveyAreaName" = 'I-4'
GROUP BY a."SurveyAreaName", RiS."SurveyID", RiS."Enumerator", "TimePeriod"
-- ORDER BY a."SurveyAreaName", RiS."SurveyID"
ORDER BY 1, 2, 3



/******************************/

SELECT "SurveyAreaName", "SurveyID", ("GeometryID")
FROM 
(
SELECT RiS."GeometryID", RiS."SurveyID", a."SurveyAreaName", "DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') AS "DoW", "Enumerator", "CaptureSource"
, CASE WHEN (RiS."DemandSurveyDateTime"::time >= '00:00' AND RiS."DemandSurveyDateTime"::time <= '04:00') THEN 'Overnight'
     WHEN (RiS."DemandSurveyDateTime"::time >= '09:00' AND RiS."DemandSurveyDateTime"::time <= '13:00') THEN 'Morning'
	 WHEN (RiS."DemandSurveyDateTime"::time >= '13:00' AND RiS."DemandSurveyDateTime"::time <= '17:00') THEN 'Afternoon'
	 END As "SurveyPeriod"
, "Demand"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND (
(RiS."SurveyID" IN (101, 201, 301, 401) AND (NOT (RiS."DemandSurveyDateTime"::time >= '00:00' AND RiS."DemandSurveyDateTime"::time <= '04:00')))
OR (RiS."SurveyID" IN (101, 201) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Tue', 'Wed', 'Thu')))
OR (RiS."SurveyID" IN (301) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sat')))
OR (RiS."SurveyID" IN (401) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sun')))
)
AND UPPER("CaptureSource") NOT LIKE '%LEOPARD%'
AND NOT (
	(RiS."SurveyID" IN (101, 201) AND ((RiS."DemandSurveyDateTime"::time >= '23:30' AND RiS."DemandSurveyDateTime"::time <= '23:59:59')) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') IN ('Mon', 'Tue', 'Wed')))
 OR (RiS."SurveyID" IN (301) AND ((RiS."DemandSurveyDateTime"::time >= '23:30' AND RiS."DemandSurveyDateTime"::time <= '23:59:59')) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') IN ('Fri')))
 OR (RiS."SurveyID" IN (401) AND ((RiS."DemandSurveyDateTime"::time >= '23:30' AND RiS."DemandSurveyDateTime"::time <= '23:59:59')) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') IN ('Sat')))
 )

-- Morning

UNION

SELECT RiS."GeometryID", RiS."SurveyID", a."SurveyAreaName", "DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') AS "DoW", "Enumerator", "CaptureSource"
, CASE WHEN (RiS."DemandSurveyDateTime"::time >= '00:00' AND RiS."DemandSurveyDateTime"::time <= '04:00') THEN 'Overnight'
     WHEN (RiS."DemandSurveyDateTime"::time >= '09:00' AND RiS."DemandSurveyDateTime"::time <= '13:00') THEN 'Morning'
	 WHEN (RiS."DemandSurveyDateTime"::time >= '13:00' AND RiS."DemandSurveyDateTime"::time <= '17:00') THEN 'Afternoon'
	 END As "SurveyPeriod"
, "Demand"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND (
(RiS."SurveyID" IN (102, 202, 302, 402) AND (NOT (RiS."DemandSurveyDateTime"::time >= '09:00' AND RiS."DemandSurveyDateTime"::time <= '13:00')))
OR (RiS."SurveyID" IN (102, 202) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Tue', 'Wed', 'Thu')))
OR (RiS."SurveyID" IN (302) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sat')))
OR (RiS."SurveyID" IN (402) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sun')))
)
AND UPPER("CaptureSource") NOT LIKE '%LEOPARD%'
AND NOT ("SurveyID" IN (302, 303) AND a."SurveyAreaName" = 'I-4')
AND NOT ("SurveyID" IN (302) AND a."SurveyAreaName" = 'O-01')
AND NOT RiS."DemandSurveyDateTime"::date = '11/11/2025'

-- Afternoon

UNION

SELECT RiS."GeometryID", RiS."SurveyID", a."SurveyAreaName", "DemandSurveyDateTime", TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') AS "DoW", "Enumerator", "CaptureSource"
, CASE WHEN (RiS."DemandSurveyDateTime"::time >= '00:00' AND RiS."DemandSurveyDateTime"::time <= '04:00') THEN 'Overnight'
     WHEN (RiS."DemandSurveyDateTime"::time >= '09:00' AND RiS."DemandSurveyDateTime"::time <= '13:00') THEN 'Morning'
	 WHEN (RiS."DemandSurveyDateTime"::time >= '13:00' AND RiS."DemandSurveyDateTime"::time <= '17:00') THEN 'Afternoon'
	 END As "SurveyPeriod"
, "Demand"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" a
WHERE RiS."GeometryID" = s."GeometryID"
AND a."Code" = s."SurveyAreaID"
AND (
(RiS."SurveyID" IN (103, 203, 303, 403) AND (NOT (RiS."DemandSurveyDateTime"::time >= '13:00' AND RiS."DemandSurveyDateTime"::time <= '17:00')))
OR (RiS."SurveyID" IN (103, 203) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Tue', 'Wed', 'Thu')))
OR (RiS."SurveyID" IN (303) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sat')))
OR (RiS."SurveyID" IN (403) AND (TO_CHAR(RiS."DemandSurveyDateTime", 'Dy') NOT IN ('Sun')))
)
AND UPPER("CaptureSource") NOT LIKE '%LEOPARD%'
AND NOT ("SurveyID" IN (302, 303) AND a."SurveyAreaName" = 'I-4')
AND NOT RiS."DemandSurveyDateTime"::date = '11/11/2025'

--ORDER BY "SurveyAreaName", "SurveyID"


) a
GROUP BY 1, 2
ORDER BY 1, 2