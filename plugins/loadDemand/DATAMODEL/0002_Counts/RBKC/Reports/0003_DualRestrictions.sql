-- Dual restriction details

SELECT DISTINCT d."GeometryID" AS "Secondary GeometryID", s1."RestrictionType Description" AS "Secondary Restriction", s2."RestrictionType Description" AS "Primary Restriction",
s1."RoadName",
        CASE WHEN (s1."RestrictionTypeID" < 200 OR s1."RestrictionTypeID" IN (227, 228, 229, 231)) THEN COALESCE(s1."TimePeriod", '')
            ELSE COALESCE(s1."NoWaitingTime", '')
            END  AS "Secondary DetailsOfControl",
        CASE WHEN (s2."RestrictionTypeID" < 200 OR s2."RestrictionTypeID" IN (227, 228, 229, 231)) THEN COALESCE(s2."TimePeriod", '')
            ELSE COALESCE(s2."NoWaitingTime", '')
            END  AS "Primary DetailsOfControl",
        s1.item_refs
 FROM
 mhtc_operations."DualRestrictions" d,
(
 SELECT "GeometryID", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionType Description", "RoadName",
        "TimePeriodID", "TimePeriods1"."Description" AS "TimePeriod",
        "NoWaitingTimeID", "TimePeriods2"."Description" AS "NoWaitingTime", l.item_refs
 FROM mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code"
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoWaitingTimeID" is not distinct from "TimePeriods2"."Code"
 LEFT JOIN (SELECT "GeometryID" AS "GeometryID_Links", ARRAY_AGG ("item_ref") AS item_refs
											 FROM mhtc_operations."RBKC_item_ref_links"
											 GROUP BY "GeometryID" ) AS l ON a."GeometryID" = l."GeometryID_Links") AS s1,
(
 SELECT "GeometryID", "RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionType Description", "RoadName",
        "TimePeriodID", "TimePeriods1"."Description" AS "TimePeriod",
        "NoWaitingTimeID", "TimePeriods2"."Description" AS "NoWaitingTime", l.item_refs
 FROM mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code"
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoWaitingTimeID" is not distinct from "TimePeriods2"."Code"
 LEFT JOIN (SELECT "GeometryID" AS "GeometryID_Links", ARRAY_AGG ("item_ref") AS item_refs
											 FROM mhtc_operations."RBKC_item_ref_links"
											 GROUP BY "GeometryID" ) AS l ON a."GeometryID" = l."GeometryID_Links") AS s2
 WHERE d."GeometryID" = s1."GeometryID"
 AND d."LinkedTo" = s2."GeometryID"
 ORDER BY s1."RoadName", s1."RestrictionType Description"