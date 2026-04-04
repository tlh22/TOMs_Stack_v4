/***

checks for typos .. and missing data

***/

-- typos will typically show as high stress


-- missing data is seen in comparison to other counts of the same restriction (or as a lower total for the street)

SELECT DISTINCT RiS1."GeometryID", s."RoadName", s."Description" AS "RestrictionType Description", s."Capacity" --, RiS1."SurveyID",
FROM demand."RestrictionsInSurveys" RiS1,
(mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
WHERE RiS1."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (101)
AND EXISTS (SELECT 1
                FROM demand."RestrictionsInSurveys" RiS2
                WHERE RiS1."GeometryID" = RiS2."GeometryID"
                AND RiS1."SurveyID" != RiS2."SurveyID"
				AND RiS1."CapacityAtTimeOfSurvey" > 5
				AND RiS2."CapacityAtTimeOfSurvey" > 5
				AND RiS1."SurveyID" > 0
				AND RiS2."SurveyID" > 0
				AND RiS1."Demand" = 0
				AND RiS1."NrCars" IS NULL
				AND RiS1."NrSpaces" IS NULL
                AND RiS2."Demand" > 0)

ORDER BY s."RoadName", s."Capacity", RiS1."GeometryID"


-- *** Cars in MCL bays

SELECT DISTINCT RiS1."GeometryID", s."RoadName", s."Description" AS "RestrictionType Description",
s."Capacity", RiS1."SurveyID", RiS1."NrCars", RiS1."NrMCLs", RiS1."NrPCLs", RiS1."NrEScooters", RiS1."NrDocklessPCLs",
RiS1."CapacityAtTimeOfSurvey" , RiS1."Demand", RiS1."Stress",
RiS1."Notes"
FROM demand."RestrictionsInSurveys" RiS1,
(mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
WHERE RiS1."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (117, 118, 119, 168, 169)
AND RiS1."NrCars" > 0

-- Check to see if any/all should be moved ...

UPDATE demand."RestrictionsInSurveys" AS RiS
SET "NrMCLs" = "NrCars"
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (117, 118)
--AND s."GeometryID" NOT IN ('S_007437', 'S_008018', 'S_009371', 'S_011591')
AND RiS."NrCars" > 0;

UPDATE demand."RestrictionsInSurveys" AS RiS
SET "NrCars" = 0
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (117, 118)
--AND s."GeometryID" NOT IN ('S_007437', 'S_008018', 'S_009371', 'S_011591')
AND RiS."NrCars" > 0;

-- *** Check for PCLs, etc in Bays

SELECT DISTINCT RiS1."GeometryID", s."RoadName", s."Description" AS "RestrictionType Description",
s."Capacity", RiS1."SurveyID", RiS1."NrCars", RiS1."NrPCLs", RiS1."NrEScooters", RiS1."NrDocklessPCLs",
RiS1."CapacityAtTimeOfSurvey" , RiS1."Demand", RiS1."Stress",
RiS1."Notes", RIS1."Enumerator"
FROM demand."RestrictionsInSurveys" RiS1,
(mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
WHERE RiS1."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (101, 103)
AND (RiS1."NrPCLs" > 0
    OR RiS1."NrPCLs" > 0
    OR RiS1."NrPCLs" > 0)
AND COALESCE(RiS1."NrMCLs",0) = 0
--AND RiS1."Enumerator" = 'TT'

-- Check to see if any should be moved

UPDATE demand."RestrictionsInSurveys" AS RiS
SET "NrMCLs" = "NrPCLs"
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (101, 103)
AND RiS."NrPCLs" > 0
AND COALESCE(RiS."NrMCLs", 0) = 0
--AND RiS."Enumerator" = 'TT'

UPDATE demand."RestrictionsInSurveys" AS RiS
SET "NrPCLs" = 0
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (101, 103)
AND RiS."NrPCLs" > 0
AND COALESCE(RiS."NrMCLs", 0) > 0
--AND RiS."Enumerator" = 'TT'


-- ** Check for SYL acceptability

SELECT DISTINCT s."GeometryID", s."RoadName"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (221, 222)    -- SYL, SRL unacc
AND RiS."Demand" > 3
ORDER BY s."RoadName"

-- ** Check for numbers on SYL unacceptable (doesn't show up in stress)

SELECT DISTINCT s."GeometryID", s."RoadName", s."RestrictionLength", RiS."Demand", RiS."NrCars"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (221, 222)    -- SYL, SRL unacc
AND RiS."Demand" > (s."RestrictionLength" / 5.0)::int
ORDER BY s."RoadName"

-- ** Check for issues with Disabled Badges

-- General check
SELECT s."GeometryID", s."RoadName", RiS."CapacityAtTimeOfSurvey", RiS."Demand", RiS."NrCars", RiS."NrCarsWithDisabledBadgeParkedInPandD"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (103)
AND RiS."Demand" > "CapacityAtTimeOfSurvey"
AND RiS."NrCarsWithDisabledBadgeParkedInPandD" IS NOT NULL

-- Full with cars
SELECT s."GeometryID", s."RoadName", RiS."CapacityAtTimeOfSurvey", RiS."Demand", RiS."NrCars", RiS."NrCarsWithDisabledBadgeParkedInPandD"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (103)
AND RiS."Demand" > "CapacityAtTimeOfSurvey"
AND RiS."NrCars" = RiS."CapacityAtTimeOfSurvey"
AND RiS."NrCarsWithDisabledBadgeParkedInPandD" IS NOT NULL

UPDATE demand."RestrictionsInSurveys" AS RiS
SET "NrCars" = "NrCars" - "NrCarsWithDisabledBadgeParkedInPandD"
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" IN (103)
AND RiS."Demand" > "CapacityAtTimeOfSurvey"
AND RiS."NrCars" = RiS."CapacityAtTimeOfSurvey"
AND RiS."NrCarsWithDisabledBadgeParkedInPandD" IS NOT NULL;


-- ** Check for excess in marked bays

SELECT DISTINCT s."GeometryID", s."RoadName", s."Description" AS "RestrictionType Description", RiS."CapacityAtTimeOfSurvey"
FROM demand."RestrictionsInSurveys" RiS,
(mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."NrBays" > 0
AND s."RestrictionTypeID" NOT IN (117, 118, 119, 147, 168, 169)
AND RiS."Demand" > "CapacityAtTimeOfSurvey"
ORDER BY s."Description", s."RoadName", s."GeometryID"


SELECT DISTINCT s."GeometryID", s."RoadName", s."Description" AS "RestrictionType Description", s."NrBays", RiS."CapacityAtTimeOfSurvey", RiS."Demand"
FROM demand."RestrictionsInSurveys" RiS,
(mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
WHERE RiS."GeometryID" = s."GeometryID"
AND s."NrBays" > 0
AND s."RestrictionTypeID" IN (103)
AND RiS."Demand" > "CapacityAtTimeOfSurvey"
ORDER BY s."Description", s."RoadName", s."GeometryID"


-- ** Check for item_ref link

SELECT "GeometryID", s."Description" AS "RestrictionType Description", "RoadName"
FROM (mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
WHERE "RestrictionTypeID" NOT IN (107, 122, 128, 129, 132, 141, 142, 143, 147, 155, 160, 161, 162, 163, 164, 217, 218, 222, 226)
AND "GeometryID" NOT IN (
    SELECT DISTINCT "GeometryID"
    FROM mhtc_operations."RBKC_item_ref_links")


-- ** TRIM

UPDATE mhtc_operations."Supply"
SET "RoadName" = TRIM ("RoadName");