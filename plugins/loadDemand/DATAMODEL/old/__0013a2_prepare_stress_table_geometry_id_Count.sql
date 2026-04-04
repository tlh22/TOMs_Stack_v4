-- create view with join to demand table

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByGeometryID";

CREATE MATERIALIZED VIEW demand."StressResults_ByGeometryID"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS id,

    RiS."SurveyID", s."GeometryID", s.geom, s."RestrictionTypeID", s."RoadName", s."SideOfStreet", s."CapacityFromDemand" AS "Capacity", COALESCE(RiS."NrBaysSuspended", 0) AS "NrBaysSuspended",
	RiS."Demand",
    RiS."Demand_Standard" AS "NrParkedInBays", RiS."Demand_Other" AS "NrParkedOnYLs", -- for Camden
    RiS."Stress"
	FROM mhtc_operations."Supply" s, demand."RestrictionsInSurveys" RiS
	WHERE RiS."GeometryID" = s."GeometryID"
	AND s."SurveyArea" IS NOT NULL
	AND LENGTH(s."RoadName") > 0
WITH DATA;

ALTER TABLE demand."StressResults_ByGeometryID"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_ByGeometryID_id"
    ON demand."StressResults_ByGeometryID" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults_ByGeometryID";