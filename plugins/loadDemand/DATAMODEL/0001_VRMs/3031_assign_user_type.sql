/***
 *  identify different user types within amended VRMs

    There are three types of user category:
     - Resident: VRM observed overnight
     - Commuter: VRM observed in morning and afternoon beat
     - Visitor: VRM observed in either morning or afternoon beat

 ***/

ALTER TABLE demand."VRMs"
    ADD COLUMN IF NOT EXISTS "UserTypeID" INTEGER;

UPDATE demand."VRMs"
SET "UserTypeID" = NULL;

-- Residents
UPDATE demand."VRMs" v
SET "UserTypeID" = 1
WHERE MOD("SurveyID", 100) = x;  -- should match overnight beat - usually 1

UPDATE demand."VRMs"
SET "UserTypeID" = 1
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "UserTypeID" = 1
);

-- Commuter
/***
UPDATE demand."VRMs"
SET "UserTypeID" = 2
WHERE "UserTypeID" IS NULL
AND "VRM" IN (
    SELECT v1."VRM"
    FROM demand."VRMs" v1, demand."VRMs" v2
    WHERE v1."VRM" = v2."VRM"
    AND v1."ID" < v2."ID"
    AND (
            (v1."SurveyID" = 102 AND v2."SurveyID" = 103)
            OR (v1."SurveyID" = 202 AND v2."SurveyID" = 203)
            OR (v1."SurveyID" = 302 AND v2."SurveyID" = 303)
        )
);
***/

UPDATE demand."VRMs"
SET "UserTypeID" = 2
WHERE "UserTypeID" IS NULL
AND "VRM" IN (
	SELECT "VRM" FROM
	(SELECT "VRM", FLOOR("SurveyID"::float/100.0) AS "Day", COUNT(*) AS "Total"
	FROM demand."VRMs"
	WHERE MOD("SurveyID", 100) != 1
	GROUP BY "VRM", "Day"
	HAVING COUNT(*) > y  -- need to adjust depeidning on categories
	) a
);

-- Visitor
UPDATE demand."VRMs"
SET "UserTypeID" = 3
WHERE "UserTypeID" IS NULL;


/*** SLR25-02 
-- setting user types from span

UPDATE demand."VRMs" AS d
SET d."UserTypeID" = 2
FROM 
(
	SELECT "AnonomisedVRM", "VehicleType", "GeometryID", "RestrictionTypeID", "RestrictionDescription", "RoadName", "SurveyAreaName"
			--,  "SiteAreaName"
			, "SurveyDay", first, last, last-first+1 As span, "UserTypeID"

	FROM (
	SELECT DISTINCT ON ("AnonomisedVRM", "RoadName", "SurveyDay", first) 
			first."AnonomisedVRM", first."VehicleType", first."GeometryID", first."RestrictionTypeID", first."Description" As "RestrictionDescription", first."RoadName", first."SurveyAreaName", 
			--first."SiteAreaName", 
			first."SurveyDay", first."SurveyID" As first, last."SurveyID" AS last, first."UserTypeID"
	FROM
		(SELECT v."AnonomisedVRM", l."Description" AS "VehicleType", v."GeometryID", su."RestrictionTypeID", su."Description", su."RoadName", su."SurveyAreaName"
				--, su."SiteAreaName"
				, v."SurveyID", s."SurveyDay", v."UserTypeID"
		FROM demand."Surveys" s, demand."VRMs" v LEFT JOIN demand_lookups."VehicleTypes" l ON v."VehicleTypeID" = l."Code",
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
		AND su."RoadName" NOT LIKE '%Car Park%'
		) AS first,
		(SELECT v."AnonomisedVRM", v."GeometryID", su."RestrictionTypeID", su."Description", su."RoadName", 
		su."SurveyAreaName", 
		v."SurveyID", s."SurveyDay"
		FROM demand."VRMs" v, demand."Surveys" s, 
		(SELECT s."GeometryID", s."RestrictionTypeID", l."Description", s."RoadName", "SurveyAreas"."SurveyAreaName"
		FROM ((mhtc_operations."Supply" s 
			LEFT JOIN toms_lookups."BayLineTypes" l ON s."RestrictionTypeID" = l."Code") 
			LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON s."SurveyAreaID" is not distinct from "SurveyAreas"."Code")) su
		WHERE v."isLast" = true
			AND v."orphan" IS NOT true
		AND v."GeometryID" = su."GeometryID"
		AND v."SurveyID" = s."SurveyID"
		AND su."RoadName" NOT LIKE '%Car Park%'
		) AS last
	WHERE first."AnonomisedVRM" = last."AnonomisedVRM"
	AND first."RoadName" = last."RoadName"
	AND first."SurveyID" < last."SurveyID" 
	AND first."SurveyID" > 0 AND first."SurveyID" NOT IN (301, 314, 401, 414) AND last."SurveyID" NOT IN (301, 314, 401, 414)
	ORDER BY "AnonomisedVRM", "RoadName", "SurveyDay", first, last
	) y

	WHERE "UserTypeID" IS NULL
	AND last-first+1 > 4
	
) b

WHERE d."AnonomisedVRM" = b."AnonomisedVRM"

***/