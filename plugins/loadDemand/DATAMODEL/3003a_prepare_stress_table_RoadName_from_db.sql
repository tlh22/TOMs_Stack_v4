-- Now prepare stress

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults";

CREATE MATERIALIZED VIEW demand."StressResults"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    s."name1" AS "RoadName", 
    --s."roadName1_Name" AS "RoadName", 
	s.geom,
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
    SELECT "SurveyID", su."RoadName", SUM(RiS."CapacityAtTimeOfSurvey") AS "Capacity", SUM(RiS."Demand") AS "Demand"
    FROM mhtc_operations."Supply" su, demand."RestrictionsInSurveys" RiS
    WHERE su."GeometryID" = RiS."GeometryID"
    AND su."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- specials incl MCL, PCL, Scooters, etc
    -- AND ("UnacceptableTypeID" IS NULL OR "UnacceptableTypeID" NOT IN (1,11))  -- vehicle crossovers
    GROUP BY RiS."SurveyID", su."RoadName"
    ORDER BY su."RoadName", RiS."SurveyID" ) a
    ) d
	WHERE s."name1" = d."RoadName"
	--AND s."SouthwarkProposedDeliveryZoneID" = 1
	--WHERE s."roadName1_Name" = d."RoadName"
WITH DATA;


/***

Southwark 

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults";

CREATE MATERIALIZED VIEW demand."StressResults"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid
    , s."name1" AS "RoadName"
    --s."roadName1_Name" AS "RoadName", 
	, "SurveyAreaName"
	, s.geom
    , d."SurveyID", d."Capacity", d."Demand", d."Stress" AS "Stress"
	FROM highways_network."roadlink" s,
	(
	SELECT "SurveyID"
		, "RoadName"
		, "SurveyAreaName"
		, "Capacity"
		, "Demand"
        , CASE
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
    SELECT "SurveyID"
		, su."RoadName"
		, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SurveyAreaName"
		, SUM(RiS."CapacityAtTimeOfSurvey") AS "Capacity"
		, SUM(RiS."Demand") AS "Demand"
    FROM demand."RestrictionsInSurveys" RiS,
			mhtc_operations."Supply" su
				LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON su."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
    WHERE su."GeometryID" = RiS."GeometryID"
    AND su."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- specials incl MCL, PCL, Scooters, etc
    -- AND ("UnacceptableTypeID" IS NULL OR "UnacceptableTypeID" NOT IN (1,11))  -- vehicle crossovers
	AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I')
    GROUP BY RiS."SurveyID", su."RoadName", "SurveyAreaName"
    ORDER BY su."RoadName", RiS."SurveyID" ) a
    ) d
	WHERE s."name1" = d."RoadName"

WITH DATA;


***/

ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_sid"
    ON demand."StressResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";