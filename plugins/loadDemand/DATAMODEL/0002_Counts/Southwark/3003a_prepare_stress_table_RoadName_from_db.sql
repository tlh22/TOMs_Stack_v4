-- Now prepare stress

-- Ensure "BeatTitle" is correct
/***
UPDATE demand."Surveys"
SET "BeatTitle" = "SurveyDay" || ' - Overnight (' || LEFT("BeatStartTime", 2) || ':' || RIGHT("BeatStartTime", 2) || '-' || LEFT("BeatEndTime", 2) || ':' || RIGHT("BeatEndTime", 2) || ')'
WHERE MOD("SurveyID", 100) = 1
AND "SurveyID" > 0;

UPDATE demand."Surveys"
SET "BeatTitle" = "SurveyDay" || ' - Morning (' || LEFT("BeatStartTime", 2) || ':' || RIGHT("BeatStartTime", 2) || '-' || LEFT("BeatEndTime", 2) || ':' || RIGHT("BeatEndTime", 2) || ')'
WHERE MOD("SurveyID", 100) = 2
AND "SurveyID" > 0;

UPDATE demand."Surveys"
SET "BeatTitle" = "SurveyDay" || ' - Afternoon (' || LEFT("BeatStartTime", 2) || ':' || RIGHT("BeatStartTime", 2) || '-' || LEFT("BeatEndTime", 2) || ':' || RIGHT("BeatEndTime", 2) || ')'
WHERE MOD("SurveyID", 100) = 3
AND "SurveyID" > 0;

***/

--Southwark 

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
		, "SouthwarkProposedDeliveryZoneID"
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
		, "SouthwarkProposedDeliveryZones"."ogc_fid" As "SouthwarkProposedDeliveryZoneID"
		, COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SurveyAreaName"
		, SUM(RiS."CapacityAtTimeOfSurvey") AS "Capacity"
		, SUM(RiS."Demand") AS "Demand"

    FROM demand."RestrictionsInSurveys" RiS,
			mhtc_operations."Supply" su
				LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON su."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
    WHERE su."GeometryID" = RiS."GeometryID"
    AND su."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- specials incl MCL, PCL, Scooters, etc
    -- AND ("UnacceptableTypeID" IS NULL OR "UnacceptableTypeID" NOT IN (1,11))  -- vehicle crossovers
	--AND COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('D')
    GROUP BY RiS."SurveyID", su."RoadName", "SouthwarkProposedDeliveryZones"."ogc_fid", "SurveyAreaName"
    ORDER BY su."RoadName", RiS."SurveyID" ) a
    ) d
	WHERE s."name1" = d."RoadName"
	AND s."SouthwarkProposedDeliveryZoneID" = d."SouthwarkProposedDeliveryZoneID"

	/***

	Remove details from the area surveyed earlier in 2025

	AND s.primaryindex NOT IN (
	SELECT p.primaryindex FROM highways_network."roadlink" p, local_authority."AreasAlreadySurveyed" a
	WHERE ST_WITHIN (p.geom, a.geom)
	AND a.id = 4
	)
	
	***/

WITH DATA;


ALTER TABLE demand."StressResults"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_sid"
    ON demand."StressResults" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults";

REVOKE ALL ON ALL TABLES IN SCHEMA demand FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA demand TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA demand TO toms_admin, toms_operator;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA demand TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA demand TO toms_public, toms_operator, toms_admin;

