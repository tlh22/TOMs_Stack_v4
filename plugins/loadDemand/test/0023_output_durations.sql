/**

**/


DROP TYPE possible_spans CASCADE;
CREATE TYPE possible_spans AS ("VRM" VARCHAR(12), "GeometryID" VARCHAR(12), "RestrictionTypeID" INTEGER, "RoadName" VARCHAR(254),
                               "SurveyDay" VARCHAR(50), "firstSurveyID" INTEGER, "lastSurveyID" INTEGER,
                               span INTEGER);

--DROP FUNCTION get_all_durations();

CREATE OR REPLACE FUNCTION get_all_durations_test() RETURNS SETOF possible_spans AS
$BODY$
--DO
--$do$
DECLARE
    possible_spans RECORD;
    currentVRM TEXT;
    lastVRM TEXT;
    currentStartSurveyID INTEGER;
    lastStartSurveyID INTEGER;
    skip BOOLEAN;
BEGIN

    FOR possible_spans IN
        SELECT "VRM", "GeometryID", "RestrictionTypeID", "RoadName", "SurveyDay", "firstSurveyID", "lastSurveyID", "lastSurveyID"-"firstSurveyID"+1 As span
        FROM (
            SELECT
                first."VRM", first."GeometryID", first."RestrictionTypeID", first."RoadName", first."SurveyDay", first."SurveyID" As "firstSurveyID",
                MIN(last."SurveyID") OVER (PARTITION BY last."SurveyID") As "lastSurveyID"
            FROM
                (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
                FROM demand."VRMs_test" v, demand."Surveys_test" s, mhtc_operations."Supply_test" su
                WHERE v."isFirst" = true
                AND v."GeometryID" = su."GeometryID"
                AND v."SurveyID" = s."SurveyID") AS first,
                (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
                FROM demand."VRMs_test" v, demand."Surveys_test" s, mhtc_operations."Supply_test" su
                WHERE v."isLast" = true
                AND v."GeometryID" = su."GeometryID"
                AND v."SurveyID" = s."SurveyID") AS last
            WHERE first."VRM" = last."VRM"
            AND first."RoadName" = last."RoadName"
            AND first."SurveyDay" = last."SurveyDay"
            AND first."SurveyID" < last."SurveyID"
            ) AS y
            --ORDER BY "VRM", "firstSurveyID", "lastSurveyID"
        UNION
            SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", s."SurveyDay", v."SurveyID" As "firstSurveyID", v."SurveyID" AS "lastSurveyID", 1 AS span
            FROM demand."VRMs_test" v, demand."Surveys_test" s, mhtc_operations."Supply_test" su
            WHERE v."orphan" = true
            AND v."GeometryID" = su."GeometryID"
            AND v."SurveyID" = s."SurveyID"
         ORDER BY "VRM", "firstSurveyID", "lastSurveyID"
    LOOP

        skip = false;
        currentVRM = possible_spans."VRM";
        currentStartSurveyID = possible_spans."firstSurveyID";

        RAISE NOTICE '*****--- Considering (%) starting at survey id %', currentVRM, currentStartSurveyID;

        IF currentVRM = lastVRM THEN
            IF currentStartSurveyID = lastStartSurveyID THEN
                -- Skip
                --skip = true;
                CONTINUE;
            END IF;
        END IF;

        RETURN NEXT possible_spans;

        lastVRM = currentVRM;
        lastStartSurveyID = currentStartSurveyID;

    END LOOP;

END;
--$do$;
$BODY$
LANGUAGE plpgsql;

--

SELECT * FROM get_all_durations();