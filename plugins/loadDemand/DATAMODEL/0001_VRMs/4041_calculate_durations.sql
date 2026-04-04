/***
Taken from
-- https://dba.stackexchange.com/questions/17045/efficiently-select-beginning-and-end-of-multiple-contiguous-ranges-in-postgresql

fields added to VRMs
Final query amended ...



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

***/


-- add fields to "VRMs"

ALTER TABLE demand."VRMs"
    ADD COLUMN IF NOT EXISTS "isLast" boolean;
ALTER TABLE demand."VRMs"
    ADD COLUMN IF NOT EXISTS "isFirst" boolean;
ALTER TABLE demand."VRMs"
    ADD COLUMN IF NOT EXISTS "orphan" boolean;


UPDATE demand."VRMs"
SET "isLast" = NULL;
UPDATE demand."VRMs"
SET "isFirst" = NULL;
UPDATE demand."VRMs"
SET "orphan" = NULL;


-- In this case, considering by road name (could also consider by GeometryID)

UPDATE demand."VRMs" AS v
SET "isLast" = (lead <> t."SurveyID" + 1 or lead is null),
    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),
    "orphan" = (lead <> t."SurveyID" + 1 or lead is null) and (lag <> t."SurveyID" - 1 or lag is null)
FROM
    (
        SELECT v."ID", v."VRM", v."SurveyID", su."RoadName",
               lead(v."SurveyID", 1) over( partition by "VRM", "RoadName", "SurveyDay" order by v."SurveyID", su."RoadName", v."VRM"),
               lag(v."SurveyID", 1) over(partition by "VRM", "RoadName", "SurveyDay" order by v."SurveyID", su."RoadName", v."VRM")
        FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
        WHERE s."SurveyID" = v."SurveyID"
		AND v."GeometryID" = su."GeometryID"
        ORDER BY "VRM", "SurveyID"
     ) AS t
WHERE v."ID" = t."ID"
;


-- Now close at the end of the day

UPDATE demand."VRMs" AS v
SET "isLast" = true
WHERE "SurveyID" IN (
	SELECT MAX("SurveyID")
	FROM demand."Surveys"
	WHERE "SurveyID" > 0
	GROUP BY "SurveyID"/100::int
)
AND "isLast" = false;

-- Now open at the start of the day

UPDATE demand."VRMs" AS v
SET "isFirst" = true
WHERE MOD("SurveyID", 100) = 1
AND "isFirst" = false;

/***
-- deal with overnights

UPDATE demand."VRMs" AS v
SET "orphan" = true, "isFirst" = false, "isLast" = false
WHERE "SurveyID" IN (101, 201)
;
***/

/***
Using 2hr duration categories


-- In this case, considering by road name (could also consider by GeometryID)

UPDATE demand."VRMs" AS v
SET "isLast" = (lead <> t."SurveyID" + 1 or lead is null),
    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),
    "orphan" = (lead <> t."SurveyID" + 1 or lead is null) and (lag <> t."SurveyID" - 1 or lag is null)
FROM
    (
        SELECT v."ID", v."VRM", v."SurveyID", su."RoadName",
               lead(v."SurveyID", 1) over( partition by "VRM", "RoadName", "SurveyDay" order by v."SurveyID", su."RoadName", v."VRM"),
               lag(v."SurveyID", 1) over(partition by "VRM", "RoadName", "SurveyDay" order by v."SurveyID", su."RoadName", v."VRM")
        FROM demand."VRMs" v, demand."Surveys" s, mhtc_operations."Supply" su
        WHERE s."SurveyID" = v."SurveyID"
		AND v."GeometryID" = su."GeometryID"
        ORDER BY "VRM", "SurveyID"
     ) AS t
WHERE v."ID" = t."ID"
;

***/