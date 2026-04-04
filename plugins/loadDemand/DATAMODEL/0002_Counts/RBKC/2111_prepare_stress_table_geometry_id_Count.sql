-- create view with join to demand table

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByGeometryID";

CREATE MATERIALIZED VIEW demand."StressResults_ByGeometryID"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS id,

    RiS."SurveyID", s."GeometryID", s.geom, s."RestrictionTypeID",
    s."Description" AS "RestrictionType Description", s."RoadName",
    s."Capacity" AS "SupplyCapacity", COALESCE(RiS."NrBaysSuspended", 0) AS "NrBaysSuspended",
    RiS."CapacityAtTimeOfSurvey" AS "CapacityAtTimeOfSurvey",
	RiS."Demand", RiS."Stress",
	RiS."PerceivedCapacityAtTimeOfSurvey" AS "PerceivedCapacityAtTimeOfSurvey",
	RiS."PerceivedStress"
	FROM demand."RestrictionsInSurveys" RiS,
	(mhtc_operations."Supply" AS a
    LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
	WHERE RiS."GeometryID" = s."GeometryID"
	--AND s."SurveyArea" IS NOT NULL
	AND LENGTH(s."RoadName") > 0
WITH DATA;

ALTER TABLE demand."StressResults_ByGeometryID"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_ByGeometryID_id"
    ON demand."StressResults_ByGeometryID" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults_ByGeometryID";