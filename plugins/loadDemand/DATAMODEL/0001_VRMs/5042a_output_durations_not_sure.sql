/***
Taken from
-- https://dba.stackexchange.com/questions/17045/efficiently-select-beginning-and-end-of-multiple-contiguous-ranges-in-postgresql

fields added to VRMs
Final query amended ...

***/
/***
-- Basic approach
SELECT
        "VRM",
        "SurveyID",
		"GeometryID",
        (lead <> "SurveyID" + 1 or lead is null) as islast,
        (lag <> "SurveyID" - 1 or lag is null) as isfirst,
        (lead <> "SurveyID" + 1 or lead is null) and (lag <> "SurveyID" - 1 or lag is null) as orphan
FROM
    (

        SELECT "VRM", "SurveyID", "GeometryID",
               lead("SurveyID", 1) over( partition by "VRM", "SurveyDay" order by "SurveyID", "GeometryID", "VRM"),
               lag("SurveyID", 1) over(partition by "VRM", "SurveyDay" order by "SurveyID", "GeometryID", "VRM")
        FROM demand."VRMs" v, "Surveys" s
        WHERE v."SurveyID" = s."SurveyID"
        ORDER BY "VRM", "SurveyID"

     ) AS t

ORDER BY "VRM", "SurveyID";

-- add fields to "VRMs"

ALTER TABLE demand."VRMs"
    ADD COLUMN "isLast" boolean;
ALTER TABLE demand."VRMs"
    ADD COLUMN "isFirst" boolean;
ALTER TABLE demand."VRMs"
    ADD COLUMN "orphan" boolean;

UPDATE demand."VRMs" AS v
SET "isLast" = (lead <> t."SurveyID" + 1 or lead is null),
    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),
    "orphan" = (lead <> t."SurveyID" + 1 or lead is null) and (lag <> t."SurveyID" - 1 or lag is null)
FROM
    (

        SELECT "VRM", v."SurveyID", "GeometryID",
               lead(v."SurveyID", 1) over( partition by "VRM", "SurveyDay" order by v."SurveyID", "GeometryID", "VRM"),
               lag(v."SurveyID", 1) over(partition by "VRM", "SurveyDay" order by v."SurveyID", "GeometryID", "VRM")
        FROM demand."VRMs" v, demand."Surveys" s
        WHERE s."SurveyID" = v."SurveyID"
        ORDER BY "VRM", "SurveyID"

     ) AS t
WHERE v."VRM" = t."VRM"
AND v."SurveyID" = t."SurveyID"
AND v."GeometryID" = t."GeometryID";

-- Now close at the end of the day

UPDATE demand."VRMs" AS v
SET "isLast" = true
WHERE "SurveyID" IN (108, 208, 308, 408)
AND "isLast" = false
-- ??    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),
***/
-- ?? do we need to open at start of day??

-- Select ...
/***
select
    "VRM", "SurveyID", "GeometryID",
    first,
    coalesce (last, first) as last,
    coalesce (last - first + 1, 1) as span
from
(
    select
    "VRM", "SurveyID", "GeometryID",
    "SurveyID" as first,
    -- this will not be excellent perf. since were calling the view
    -- for each row sequence found. Changing view into temp table
    -- will probably help with lots of values.
    (
        select min("SurveyID")
        from demand."VRMs" as last
        where "isLast" = true
        -- need this since isfirst=true, islast=true on an orphan sequence
        --and last."orphan" = false
        and first."SurveyID" <= last."SurveyID" --- amended
        and first."VRM" = last."VRM"
        and first."GeometryID" = last."GeometryID"
    ) as last
    from
        (select * from demand."VRMs" where "isFirst" = true) as first
) as t
;

----  Issue if vehicle changes GeometryID within day (but stays)

select
    --t."VRM",
	su."SurveyID", --t."GeometryID",
	y."RoadName",
    y.first,
    --coalesce (last, first) as last,
	y.last,
    y.span,
	y.NrInSpan
from
demand."Surveys" su LEFT JOIN
(
    select
        --t."VRM",
        t."SurveyID", --t."GeometryID",
        s."RoadName",
        t.first,
        coalesce (last, first) as last,
        coalesce (t.last - t.first + 1, 1) As span,
        COUNT (t."VRM") AS NrInSpan
    from
    (
        select
        "VRM", "SurveyID", "GeometryID",
        "SurveyID" as first,
        -- this will not be excellent perf. since were calling the view
        -- for each row sequence found. Changing view into temp table
        -- will probably help with lots of values.
        (
            select min(last."SurveyID")
            from demand."VRMs" as last, demand."Surveys" s
            where "isLast" = true
            -- need this since isfirst=true, islast=true on an orphan sequence
            --and last."orphan" = false
            and first."SurveyID" <= last."SurveyID" --- amended
            and first."VRM" = last."VRM"
            and first."GeometryID" = last."GeometryID"
            AND last."SurveyID" = s."SurveyID"
            AND s."SurveyDay" = first."SurveyDay"
        ) as last
        from
            (select v.*, s."SurveyDay" from demand."VRMs" v, demand."Surveys" s
             where "isFirst" = true
             AND v."SurveyID" = s."SurveyID") as first
    ) as t, mhtc_operations."Supply" s
    WHERE t."GeometryID" = s."GeometryID"
    AND s."RestrictionTypeID" = 103
    GROUP BY --t."VRM",
             t."SurveyID",
             --t."GeometryID",
             s."RoadName",
             t.first,
	         t.last,
             span

) y ON su."SurveyID" = y."SurveyID"
;
***/

--- ******* OK now ...

SELECT DISTINCT ON ("VRM", "GeometryID", "SurveyDay", first, last) "VRM", "GeometryID", "RestrictionTypeID", "RoadName", "SurveyDay", first, last, last-first+1 As span --, "UserTypeID"
FROM (
SELECT
        first."VRM", first."GeometryID", first."RestrictionTypeID", first."RoadName", first."SurveyDay", first."SurveyID" As first, MIN(last."SurveyID") OVER (PARTITION BY last."SurveyID") As last--, first."UserTypeID"
FROM
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay", v."UserTypeID"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isFirst" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	--AND su."RoadName" IN ('White Sands Car Park', 'Brewery Street Car Park', 'Art School Car Park', 'Loreburn Street Car Park', 'Dock Park Car Park', 'Dockhead Car Park')
	) AS first,
    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."isLast" = true
		AND v."orphan" IS NOT true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	--AND su."RoadName" IN ('White Sands Car Park', 'Brewery Street Car Park', 'Art School Car Park', 'Loreburn Street Car Park', 'Dock Park Car Park', 'Dockhead Car Park')
	) AS last
WHERE first."VRM" = last."VRM"
AND first."RoadName" = last."RoadName"
--AND first."SurveyDay" = last."SurveyDay"
AND first."SurveyID" < last."SurveyID"
AND (first."SurveyID"/100.0)::int = (last."SurveyID"/100.0)::int
AND first."SurveyID" NOT IN (101, 201)
AND last."SurveyID" NOT IN (107, 207)
--AND first."VRM" IN ('PX16-XCD', 'CA64-RDS')
) As y
GROUP BY "VRM", "GeometryID", "RestrictionTypeID","RoadName", "SurveyDay", first, last

UNION
SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", s."SurveyDay", v."SurveyID" As first, v."SurveyID" AS last, 1 AS span--, v."UserTypeID"
    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
    WHERE v."orphan" = true
    AND v."GeometryID" = su."GeometryID"
    AND v."SurveyID" = s."SurveyID"
	--AND su."RoadName" IN ('White Sands Car Park', 'Brewery Street Car Park', 'Art School Car Park', 'Loreburn Street Car Park', 'Dock Park Car Park', 'Dockhead Car Park');
	AND s."SurveyID" NOT IN (101, 201, 107, 207)
ORDER BY "VRM", "GeometryID", "SurveyDay", first


-- Check
SELECT v."SurveyID", s."SurveyDay", su."RoadName", v."GeometryID", su."RestrictionTypeID", v."VRM", "isFirst", "isLast", "orphan"
FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
WHERE v."GeometryID" = su."GeometryID"
AND v."SurveyID" = s."SurveyID"
--AND v."VRM" IN ('PX16-XCD', 'CA64-RDS')
AND su."RoadName" IN ('The Mint')
ORDER BY "SurveyID", "VRM"




--- Not sure about this ....


DROP TYPE possible_spans CASCADE;
CREATE TYPE possible_spans AS ("VRM" VARCHAR(12), "GeometryID" VARCHAR(12), "RestrictionTypeID" INTEGER, "RoadName" VARCHAR(254),
                               "SurveyDay" VARCHAR(50), "firstSurveyID" INTEGER, "lastSurveyID" INTEGER,
                               span INTEGER);

--DROP FUNCTION get_all_durations();

CREATE OR REPLACE FUNCTION get_all_durations() RETURNS SETOF possible_spans AS
$BODY$
--DO
--$do$
DECLARE
    row RECORD;
    possible_spans RECORD;
    currentVRM TEXT;
    lastVRM TEXT;
    currentStartSurveyID INTEGER;
    lastStartSurveyID INTEGER;
    skip BOOLEAN;
BEGIN

    FOR row IN SELECT "SurveyDay", min("SurveyID") as first, max("SurveyID") as last
                    FROM demand."Surveys" s
                    GROUP BY "SurveyDay"
                    ORDER BY min("SurveyID")
    LOOP

        RAISE NOTICE '***** Considering (%) [%-%]', row."SurveyDay", row.first, row.last;

        FOR possible_spans IN
            SELECT "VRM", "GeometryID", "RestrictionTypeID", "RoadName", "SurveyDay", "firstSurveyID", "lastSurveyID", "lastSurveyID"-"firstSurveyID"+1 As span
            FROM (
                SELECT
                    first."VRM", first."GeometryID", first."RestrictionTypeID", first."RoadName", first."SurveyDay", first."SurveyID" As "firstSurveyID",
                    MIN(last."SurveyID") OVER (PARTITION BY last."SurveyID") As "lastSurveyID"
                FROM
                    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
                    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
                    WHERE v."isFirst" = true
                    AND v."GeometryID" = su."GeometryID"
                    AND v."SurveyID" = s."SurveyID"
                    AND s."SurveyDay" = row."SurveyDay"
                    AND s."SurveyID" != row.first) AS first,
                    (SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", v."SurveyID", s."SurveyDay"
                    FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
                    WHERE v."isLast" = true
                    AND v."GeometryID" = su."GeometryID"
                    AND v."SurveyID" = s."SurveyID"
                    AND s."SurveyDay" = row."SurveyDay"
                    AND s."SurveyID" != row.last) AS last
                WHERE first."VRM" = last."VRM"
                AND first."RoadName" = last."RoadName"
                AND first."SurveyDay" = last."SurveyDay"
                AND first."SurveyID" < last."SurveyID"
                ) AS y
                --ORDER BY "VRM", "firstSurveyID", "lastSurveyID"
            UNION
                SELECT v."VRM", v."GeometryID", su."RestrictionTypeID", su."RoadName", s."SurveyDay", v."SurveyID" As "firstSurveyID", v."SurveyID" AS "lastSurveyID", 1 AS span
                FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
                WHERE v."orphan" = true
                AND v."GeometryID" = su."GeometryID"
                AND v."SurveyID" = s."SurveyID"
                AND s."SurveyDay" = row."SurveyDay"
                AND (s."SurveyID" != row.first
                AND s."SurveyID" != row.last)
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

    END LOOP;

END;
--$do$;
$BODY$
LANGUAGE plpgsql;

-- Check
SELECT v."SurveyID", s."SurveyDay", su."RoadName", v."GeometryID", su."RestrictionTypeID", v."VRM", "isFirst", "isLast", "orphan"
FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
WHERE v."GeometryID" = su."GeometryID"
AND v."SurveyID" = s."SurveyID"
--AND v."VRM" IN ('PX16-XCD', 'CA64-RDS')
AND su."RoadName" IN ('The Mint')
ORDER BY "SurveyID", "VRM"




DO
$do$
DECLARE
   row RECORD;
BEGIN
    FOR row IN SELECT "SurveyDay", min("SurveyID") as first, max("SurveyID") as last
                FROM demand."Surveys" s
                GROUP BY "SurveyDay"
                ORDER BY min("SurveyID")
    LOOP

        RAISE NOTICE '***** Considering (%)', row."SurveyDay";

        SELECT * FROM get_all_durations()
        WHERE "SurveyDay" = row."SurveyDay"
        AND ("firstSurveyID" = row.first
        OR "lastSurveyID" = row.last)

    END LOOP;
END
$do$;



---

SELECT v."ID", v."SurveyID", v."GeometryID", v."VRM", v."VehicleTypeID", "VehicleTypes"."PCU", v."Notes", "UserTypes"."Description", "isFirst", "isLast", "orphan"
FROM mhtc_operations."Supply" su, ((demand."VRMs" AS v
      LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON v."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
      LEFT JOIN "demand_lookups"."UserTypes" AS "UserTypes" ON v."UserTypeID" is not distinct from "UserTypes"."Code")
WHERE v."GeometryID" = su."GeometryID"
ORDER BY "SurveyID", "VRM";

SELECT "ID", "SurveyID", "GeometryID", "VRM", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", "Notes", "UserTypeID", "isLast", "isFirst", orphan
	FROM demand."VRMs"
WHERE "GeometryID" IN (
SELECT "GeometryID"
FROM mhtc_operations."Supply"
WHERE "RoadName" NOT LIKE '%Car Park%')
ORDER BY "SurveyID", "VRM";

-- Output for data model

SELECT v."ID", v."SurveyID", v."GeometryID", v."VRM", v."InternationalCodeID", v."VehicleTypeID", v."PermitTypeID", v."ParkingActivityTypeID", 
       v."ParkingMannerTypeID", v."Notes", v."UserTypeID", "isLast", "isFirst", orphan, su."RoadName"
FROM mhtc_operations."Supply" su, ((demand."VRMs" AS v
      LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON v."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
      LEFT JOIN "demand_lookups"."UserTypes" AS "UserTypes" ON v."UserTypeID" is not distinct from "UserTypes"."Code")
WHERE v."GeometryID" = su."GeometryID"
ORDER BY "SurveyID", "VRM";