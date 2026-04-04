-- Now prepare stress

-- For Camden - identify private roads - and ignore
ALTER TABLE IF EXISTS highways_network.roadlink
    ADD COLUMN IF NOT EXISTS private boolean;
	
--

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults";

CREATE MATERIALIZED VIEW demand."StressResults"
TABLESPACE pg_default
AS

SELECT sid, "RoadName", geom, "SurveyID", "Capacity", "Demand", "Stress"
FROM (
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    s."roadName1_Name" AS "RoadName", s.geom,
    d."SurveyID", d."Capacity", d."Demand", d."Stress" AS "Stress"
	FROM highways_network."roadlink" s, 
	(
	SELECT "SurveyID", "RoadName", "Capacity", "Demand",
        CASE
            WHEN "Capacity" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity"::float > 0.0 THEN
                        "Demand" / ("Capacity"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", SUM(RiS."CapacityAtTimeOfSurvey") AS "Capacity", SUM(RiS."Demand") AS "Demand"
    FROM mhtc_operations."SupplyForDemand" s, demand."RestrictionsInSurveys" RiS
    WHERE s."GeometryID" = RiS."GeometryID"
    --AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc
    GROUP BY RiS."SurveyID", s."RoadName"
    ORDER BY s."RoadName", RiS."SurveyID" ) a
    ) d
	WHERE s."roadName1_Name" = d."RoadName"
	AND (s.private IS false or s.private is null)
	) z, local_authority."SiteArea" b
		WHERE ST_Within (z.geom, b.geom)
WITH DATA;

ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_sid"
    ON demand."StressResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";