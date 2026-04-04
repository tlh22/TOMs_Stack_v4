-- Find obvious errors

-- *** Need to change area from < Q > to whatever is required - CountIssues_Q, ('Q')

DROP TABLE IF EXISTS demand."CountIssues_Q" CASCADE;

CREATE TABLE demand."CountIssues_Q" AS

SELECT "Enumerator", "SurveyID", RiS."GeometryID", "RoadName", s."RestrictionTypeID", l."Description", "Capacity", "CapacityAtTimeOfSurvey", "Demand", s."RestrictionLength", FLOOR(s."RestrictionLength"/5.5) AS "CapacityFromLength"
, 'Demand > Capacity' AS "Notes"
, s.geom
FROM demand."RestrictionsInSurveys" RiS, toms_lookups."BayLineTypes" l, 
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE RiS."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND s."RestrictionTypeID" = l."Code"
AND "Stress" >= 1
AND (
	("CapacityAtTimeOfSurvey" > 0 AND "Demand" > "CapacityAtTimeOfSurvey" + 2)
	OR ("CapacityAtTimeOfSurvey" = 0 AND "Demand" > (FLOOR(s."RestrictionLength"/5.5)) AND "Demand" > 1)
	)
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('Q')
Order By s."RestrictionTypeID",  RiS."GeometryID", "SurveyID";


--- Find differences within the same time periods for the same GeometryID - good check - possibly typo, possible miss

INSERT INTO demand."CountIssues_Q"(
	"Enumerator"
	, "SurveyID"
	, "GeometryID"
	, "RoadName"
	, "RestrictionTypeID"
	, "Description"
	, "Capacity"
	, "CapacityAtTimeOfSurvey"
	, "Demand"
	, "RestrictionLength"
	, "CapacityFromLength"
	, "Notes"
	, geom)
	
SELECT 
RiS1."Enumerator"
, RiS1."SurveyID"
, RiS1."GeometryID"
, s."RoadName"
, s."RestrictionTypeID"
, l."Description"
, s."Capacity"
, RiS1."CapacityAtTimeOfSurvey"
, RiS1."Demand"
, s."RestrictionLength"
, FLOOR(s."RestrictionLength"/5.5) AS "CapacityFromLength"
, 'Diff in same time beats - diff days' AS "Notes"
, s.geom
FROM demand."RestrictionsInSurveys" RiS1, demand."RestrictionsInSurveys" RiS2, toms_lookups."BayLineTypes" l,
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE  RiS1."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND RiS1."GeometryID" = RiS2."GeometryID"
AND RiS1."SurveyID" < RiS2."SurveyID"
AND ABS(RiS1."SurveyID" - RiS2."SurveyID") = 100
AND ABS(RiS1."Demand" - RiS2."Demand") >= 5
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('Q')
AND NOT EXISTS
	(SELECT 1
	 FROM demand."CountIssues_Q" i
	 WHERE i."SurveyID" = RiS1."SurveyID"
	 AND i."GeometryID" = RiS1."GeometryID")
	 
ORDER BY s."RestrictionTypeID", RiS1."GeometryID", RiS1."SurveyID"
;


-- check for signficant differences between beats - tends to pick misses


INSERT INTO demand."CountIssues_Q"(
	"Enumerator"
	, "SurveyID"
	, "GeometryID"
	, "RoadName"
	, "RestrictionTypeID"
	, "Description"
	, "Capacity"
	, "CapacityAtTimeOfSurvey"
	, "Demand"
	, "RestrictionLength"
	, "CapacityFromLength"
	, "Notes"
	, geom)

SELECT DISTINCT ON ("SurveyID", "GeometryID") 
"Enumerator"
, "SurveyID"
, "GeometryID"
, "RoadName"
, "RestrictionTypeID"
, "Description"
, "Capacity"
, "CapacityAtTimeOfSurvey"
, "Demand - Current" AS "Demand" 
, "RestrictionLength"
, FLOOR("RestrictionLength"/5.5) AS "CapacityFromLength"
, 'Demand different in consec beats' AS "Notes"
, geom

FROM (

-- check for signficant differences between beats - tends to pick misses

SELECT curr."Enumerator", curr."SurveyID"
, curr."GeometryID"
, s."RoadName"
, s."RestrictionTypeID"
, l."Description"
, s."Capacity"
, curr."CapacityAtTimeOfSurvey"
, before."Demand" As "Demand - Before"
, curr."Demand" As "Demand - Current"
, after."Demand" As "Demand - After"
, s."RestrictionLength"
, s.geom
FROM demand."RestrictionsInSurveys" curr, demand."RestrictionsInSurveys" before, demand."RestrictionsInSurveys" after, toms_lookups."BayLineTypes" l,
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE curr."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND curr."GeometryID" = before."GeometryID"
AND before."GeometryID" = after."GeometryID"
AND before."SurveyID" = curr."SurveyID" - 1
AND after."SurveyID" = curr."SurveyID" + 1
AND ABS(curr."Demand"::real - (before."Demand"::real + after."Demand"::real) / 2.0) > 5.0
--AND curr."SurveyID" = 113
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('Q')
--Order By s."RestrictionTypeID", before."GeometryID"

-- For first survey of day
UNION

SELECT curr."Enumerator"
, curr."SurveyID"
, curr."GeometryID"
, s."RoadName"
, s."RestrictionTypeID"
, l."Description"
, s."Capacity"
, curr."CapacityAtTimeOfSurvey"
, NULL As "Demand - Before"
, curr."Demand" As "Demand - Current"
, after."Demand" As "Demand - After"
, s."RestrictionLength"
, s.geom
FROM demand."RestrictionsInSurveys" curr, demand."RestrictionsInSurveys" after, toms_lookups."BayLineTypes" l,
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE curr."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND MOD(curr."SurveyID", 100) = 1
AND curr."GeometryID" = after."GeometryID"
AND after."SurveyID" = curr."SurveyID" + 1
AND ABS(curr."Demand"::real - after."Demand"::real) > 5.0
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('Q')
--Order By s."RestrictionTypeID", curr."GeometryID";

-- last survey of day
UNION

SELECT curr."Enumerator", curr."SurveyID", curr."GeometryID"
, s."RoadName"
, s."RestrictionTypeID"
, l."Description"
, s."Capacity"
, curr."CapacityAtTimeOfSurvey"
, before."Demand" As "Demand - Before"
, curr."Demand" As "Demand - Current"
, NULL As "Demand - After"
, s."RestrictionLength"
, s.geom
FROM demand."RestrictionsInSurveys" curr, demand."RestrictionsInSurveys" before, toms_lookups."BayLineTypes" l,
	mhtc_operations."Supply" s
		LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON s."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE curr."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = l."Code"
AND s."RestrictionTypeID" NOT IN (107, 109, 116, 117, 118, 119, 144, 147, 149, 150, 168, 169)
AND MOD(curr."SurveyID", 100) = 3
AND curr."GeometryID" = before."GeometryID"
AND before."SurveyID" = curr."SurveyID" - 1
AND ABS(curr."Demand"::real - before."Demand"::real) > 5.0
AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('Q')
-- Order By s."RestrictionTypeID", curr."GeometryID";

) y
-- Order By "RestrictionTypeID", "GeometryID"
WHERE NOT EXISTS
	(SELECT 1
	 FROM demand."CountIssues_Q" i
	 WHERE i."SurveyID" = y."SurveyID"
	 AND i."GeometryID" = y."GeometryID")
;

ALTER TABLE demand."CountIssues_Q"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_CountIssues_Q_survey_id_gemetry_id"
    ON demand."CountIssues_Q" USING btree
    ("SurveyID", "GeometryID")
    TABLESPACE pg_default;

-- Add "Done" field

ALTER TABLE IF EXISTS demand."CountIssues_Q"
    ADD COLUMN IF NOT EXISTS "Done" boolean;
	
UPDATE demand."CountIssues_Q"
SET "Done" = NULL;

-- Set permissions

REVOKE ALL ON ALL TABLES IN SCHEMA demand FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA demand TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA demand TO toms_admin, toms_operator;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA demand TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA demand TO toms_public, toms_operator, toms_admin;



