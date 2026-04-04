-- Now prepare stress

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByWard";

CREATE MATERIALIZED VIEW demand."StressResults_ByWard"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    wa.id, wa."Name" AS "WardName", wa.geom,
    d."SurveyID", d."BeatTitle", COALESCE(d."Capacity", 0) AS "Capacity", COALESCE(d."CapacityAtTimeOfSurvey", 0) AS "CapacityAtTimeOfSurvey", 
    COALESCE(d."Demand", 0) AS "Demand", COALESCE(d."Stress", -1) AS "Stress",
    COALESCE(d."Residents Bay Capacity", 0) AS "Residents Bay Capacity", COALESCE(d."Residents Bay CapacityAtTimeOfSurvey", 0) AS "Residents Bay CapacityAtTimeOfSurvey",
    COALESCE(d."Residents Bay Demand", 0) AS "Residents Bay Demand", COALESCE(d."Residents Bay Stress", -1) AS "Residents Bay Stress",
    COALESCE(d."Residents Bay PerceivedCapacityAtTimeOfSurvey", 0) AS "Residents Bay PerceivedCapacityAtTimeOfSurvey", COALESCE(d."Residents Bay PerceivedStress", 0) AS "Residents Bay PerceivedStress", 
    COALESCE(d."PayByPhone Bay Capacity", 0) AS "PayByPhone Bay Capacity", COALESCE(d."PayByPhone Bay CapacityAtTimeOfSurvey", 0) AS "PayByPhone Bay CapacityAtTimeOfSurvey", 
    COALESCE(d."PayByPhone Bay Demand", 0) AS "PayByPhone Bay Demand", COALESCE(d."PayByPhone Bay Stress", -1) AS "PayByPhone Bay Stress"
    
	FROM local_authority."Wards_2022" wa LEFT JOIN
	(
	SELECT a."SurveyID", su."BeatTitle", "WardID", "Capacity", "CapacityAtTimeOfSurvey", "Demand",
        CASE
            WHEN "CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Demand" / ("CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress",
        "Residents Bay Capacity", "Residents Bay CapacityAtTimeOfSurvey", "Residents Bay Demand",
        CASE
            WHEN "Residents Bay CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Residents Bay CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Residents Bay Demand" / ("Residents Bay CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Residents Bay Stress",
        
        "Residents Bay PerceivedCapacityAtTimeOfSurvey", 
        CASE
            WHEN "Residents Bay PerceivedCapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Residents Bay PerceivedCapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Residents Bay Demand" / ("Residents Bay PerceivedCapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Residents Bay PerceivedStress",

        "PayByPhone Bay Capacity", "PayByPhone Bay CapacityAtTimeOfSurvey", "PayByPhone Bay Demand",
        CASE
            WHEN "PayByPhone Bay CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "PayByPhone Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "PayByPhone Bay CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "PayByPhone Bay Demand" / ("PayByPhone Bay CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "PayByPhone Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "PayByPhone Bay Stress"
    FROM (
    SELECT "SurveyID", s."WardID", SUM(s."Capacity") AS "Capacity", SUM(RiS."CapacityAtTimeOfSurvey") AS "CapacityAtTimeOfSurvey",
	SUM(RiS."Demand") AS "Demand",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE s."Capacity" END) AS "Residents Bay Capacity",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."CapacityAtTimeOfSurvey" END) AS "Residents Bay CapacityAtTimeOfSurvey",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."PerceivedCapacityAtTimeOfSurvey" END) AS "Residents Bay PerceivedCapacityAtTimeOfSurvey",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."Demand" END) AS "Residents Bay Demand",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE s."Capacity" END) AS "PayByPhone Bay Capacity",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE RiS."CapacityAtTimeOfSurvey" END) AS "PayByPhone Bay CapacityAtTimeOfSurvey",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE RiS."Demand" END) AS "PayByPhone Bay Demand"
    FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
    WHERE s."GeometryID" = RiS."GeometryID"
    AND s."RestrictionTypeID" NOT IN (107, 116, 117, 118, 119, 122, 144, 146, 147, 149, 150, 151, 168, 169, 201, 221, 217, 222)  -- MCL, PCL, Scooters, etc
    AND RiS."SurveyID" > 0
    GROUP BY RiS."SurveyID", s."WardID"
    ORDER BY s."WardID", RiS."SurveyID" ) a, demand."Surveys" su
	WHERE a."SurveyID" = su."SurveyID"
    ) d ON wa."id" = d."WardID"
	
WITH DATA;

ALTER TABLE demand."StressResults_ByWard"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_ByWard_sid"
    ON demand."StressResults_ByWard" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults_ByWard";

--

SELECT "WardName", "SurveyID", "BeatTitle", "Capacity", "CapacityAtTimeOfSurvey", "Demand", "Stress", "Residents Bay Capacity", "Residents Bay CapacityAtTimeOfSurvey", "Residents Bay Demand", "Residents Bay Stress", "Residents Bay PerceivedCapacityAtTimeOfSurvey", "Residents Bay PerceivedStress", "PayByPhone Bay Capacity", "PayByPhone Bay CapacityAtTimeOfSurvey", "PayByPhone Bay Demand", "PayByPhone Bay Stress"
	FROM demand."StressResults_ByWard"
	ORDER BY "WardName", "SurveyID"
