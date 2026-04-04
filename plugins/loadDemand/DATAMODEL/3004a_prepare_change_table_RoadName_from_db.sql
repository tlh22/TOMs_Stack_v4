-- Now prepare change results

DROP MATERIALIZED VIEW IF EXISTS demand."ChangeResults";

CREATE MATERIALIZED VIEW demand."ChangeResults"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    s."name1" AS "RoadName", s.geom,
    d."Capacity", d."Demand_Overnight", d."Demand_Afternoon", d."Change" AS "Change", "ChangeStress"
	FROM highways_network."roadlink" s,
	(
	SELECT "RoadName", "Capacity", "Demand_Overnight", "Demand_Afternoon", "Change",
        CASE
            WHEN "Capacity" = 0 THEN
                CASE
                    WHEN "Change" > 0.0 THEN 1.0
                    WHEN "Change" = 0.0 THEN 0.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity"::float > 0.0 THEN
                        "Change" / ("Capacity"::float)
                    ELSE
                        CASE
                            WHEN "Change" > 0.0 THEN 1.0
                            WHEN "Change" = 0.0 THEN 0.0
                            ELSE -1.0
                        END
                END
        END "ChangeStress"
    FROM (
    SELECT "RoadName", SUM("Capacity") AS "Capacity", SUM("Demand_Overnight") AS "Demand_Overnight", SUM("Demand_Afternoon") AS "Demand_Afternoon", SUM("Change") AS "Change"
    FROM
    (
    SELECT s."GeometryID", s."RoadName", "CapacityFromDemand" AS "Capacity", "Demand_Overnight", "Demand_Afternoon", ("Demand_Overnight" - "Demand_Afternoon")::float/2.0 AS "Change"
    FROM mhtc_operations."Supply" s,
    (SELECT "GeometryID", SUM("Demand") AS "Demand_Overnight"
     FROM demand."RestrictionsInSurveys_Final"
     WHERE "SurveyID" IN (101, 201)
     GROUP BY "GeometryID") AS RiS1,
    (SELECT "GeometryID", SUM("Demand") AS "Demand_Afternoon"
     FROM demand."RestrictionsInSurveys_Final"
     WHERE "SurveyID" IN (102, 202)
     GROUP BY "GeometryID") AS RiS2
    WHERE s."GeometryID" = RiS1."GeometryID"
    AND RiS1."GeometryID" = RiS2."GeometryID"
    AND s."RestrictionTypeID" NOT IN (117, 118)  -- Motorcycle bays
     ) a
    GROUP BY a."RoadName"
    ORDER BY a."RoadName" ) e
    ) d
	WHERE s."name1" = d."RoadName"
WITH DATA;

ALTER TABLE demand."ChangeResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_ChangeResults_sid"
    ON demand."ChangeResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."ChangeResults";