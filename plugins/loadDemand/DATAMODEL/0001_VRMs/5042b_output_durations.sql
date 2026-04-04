/***

Output for use with charts, etc in client spreadsheet

***/


SELECT "VRM", "VehicleType", "GeometryID", "RestrictionTypeID", "RestrictionDescription", "RoadName", "SurveyAreaName", '' AS "SiteAreaName", b."SurveyDay", first AS "FirstSeen SurveyID", last AS "LastSeen SurveyID", span AS "Nr BeatsSeen", 
LPAD(b."first"::text, 3, '0') || ' - ' || to_char("SurveyDate", 'Dy') || ' - ' || "BeatStartTime" || ' - ' || "BeatEndTime" AS "FirstSeen BeatTitle",
"UserTypes"."Description" AS "User Type Description",
CASE WHEN ("first" IN (101, 201, 301) AND "span" = 1) THEN 'unknown'
     WHEN ("first" IN (101, 201, 301) AND "span" = 2) THEN 'at least 2 hrs'
     WHEN ("last" IN (113, 213, 313, x) AND "span" = 1) THEN 'unknown'
	 --WHEN CEILING(b.span/2::float) > 6 THEN '>10 hours'  -- for 2hr intervals
     WHEN CEILING(b.span::float) > 12 THEN '>12 hours'
ELSE c."Description" 
END AS "DurationCategory"

FROM (

-- find first/last beat

SELECT "VRM", "VehicleType", "GeometryID", "RestrictionTypeID", "RestrictionDescription", "RoadName", "SurveyAreaName"
		--,  "SiteAreaName"
		, "SurveyDay", first, last, last-first+1 As span, "UserTypeID"

FROM (
SELECT DISTINCT ON ("VRM", "RoadName", "SurveyDay", first) 
        first."VRM", first."VehicleType", first."GeometryID", first."RestrictionTypeID", first."Description" As "RestrictionDescription", first."RoadName", first."SurveyAreaName", 
		--first."SiteAreaName", 
		first."SurveyDay", first."SurveyID" As first, last."SurveyID" AS last, first."UserTypeID"
FROM
    (SELECT v."VRM", v."Description" AS "VehicleType", v."GeometryID", su."RestrictionTypeID", su."Description", su."RoadName", su."SurveyAreaName"
			--, su."SiteAreaName"
			, v."SurveyID", s."SurveyDay", v."UserTypeID"
    FROM (demand."VRMs" a  LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code") v
	, demand."Surveys" s, 
	(SELECT s."GeometryID", s."RestrictionTypeID", l."Description", s."RoadName", "SurveyAreas"."SurveyAreaName"
			--, SiteArea"."SiteAreaName"
	FROM --(
	((mhtc_operations."Supply" s 
		LEFT JOIN toms_lookups."BayLineTypes" l ON s."RestrictionTypeID" = l."Code") 
		--LEFT JOIN "local_authority"."SiteArea" AS "SiteArea" ON s."SiteAreaID" is not distinct from "SiteArea"."id")
		LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code")) su
    WHERE v."isFirst" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	--AND su."RoadName" LIKE '%Car Park%'
	) AS first,
    (SELECT v."VRM", v."Description" AS "VehicleType", v."GeometryID", su."RestrictionTypeID", su."Description", su."RoadName", 
	su."SurveyAreaName", 
	v."SurveyID", s."SurveyDay"
    FROM (demand."VRMs" a  LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code") v
		, demand."Surveys" s, 
	(SELECT s."GeometryID", s."RestrictionTypeID", l."Description", s."RoadName", "SurveyAreas"."SurveyAreaName"
	FROM ((mhtc_operations."Supply" s 
		LEFT JOIN toms_lookups."BayLineTypes" l ON s."RestrictionTypeID" = l."Code") 
		LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code")) su
    WHERE v."isLast" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	--AND su."RoadName" LIKE '%Car Park%'
	) AS last
WHERE first."VRM" = last."VRM"
AND first."RoadName" = last."RoadName"
--AND first."SurveyDay" = last."SurveyDay"
AND first."SurveyID" < last."SurveyID"
ORDER BY "VRM", "RoadName", "SurveyDay", first, last
) y

UNION

-- add in orphans

SELECT v."VRM", v."Description" AS "VehicleType", v."GeometryID", su."RestrictionTypeID", su."Description", su."RoadName", su."SurveyAreaName", 
	   --su."SiteAreaName", 
	   s."SurveyDay", v."SurveyID" As first, v."SurveyID" AS last, 1 AS span, v."UserTypeID"
    FROM (demand."VRMs" a  LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code") v
	, demand."Surveys" s, 
	(SELECT s."GeometryID", s."RestrictionTypeID", l."Description", s."RoadName", "SurveyAreas"."SurveyAreaName"
	--, "SiteArea"."SiteAreaName"
	 FROM --(
	 ((mhtc_operations."Supply" s 
		LEFT JOIN toms_lookups."BayLineTypes" l ON s."RestrictionTypeID" = l."Code") 
		--LEFT JOIN "local_authority"."SiteArea" AS "SiteArea" ON s."SiteAreaID" is not distinct from "SiteArea"."id")
		LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code")) su
    WHERE v."orphan" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	--AND su."RoadName" LIKE '%Car Park%'
	AND v."SurveyID" NOT IN (101, 201, 301)
	) b 
	LEFT JOIN demand_lookups."DurationCategories" c ON CEILING(b.span::float) = (c."DurationCategoryID")
	LEFT JOIN demand_lookups."UserTypes" AS "UserTypes" ON b."UserTypeID" is not distinct from "UserTypes"."Code"
	LEFT JOIN demand."Surveys" AS "Surveys" ON "Surveys"."SurveyID" = b."first"
		
	--WHERE "SiteAreaName" IS NOT NULL

ORDER BY "VRM", "GeometryID", "SurveyDay", first

