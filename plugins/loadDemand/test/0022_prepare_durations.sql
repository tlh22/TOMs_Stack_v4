/**

**/

-- add fields to "VRMs_test"

ALTER TABLE demand."VRMs_test"
    ADD COLUMN "isLast" boolean;
ALTER TABLE demand."VRMs_test"
    ADD COLUMN "isFirst" boolean;
ALTER TABLE demand."VRMs_test"
    ADD COLUMN "orphan" boolean;

-- In this case, considering by road name (could also consider by GeometryID)

UPDATE demand."VRMs_test" AS v
SET "isLast" = (lead <> t."SurveyID" + 1 or lead is null),
    "isFirst" = (lag <> t."SurveyID" - 1 or lag is null),
    "orphan" = (lead <> t."SurveyID" + 1 or lead is null) and (lag <> t."SurveyID" - 1 or lag is null)
FROM
    (
        SELECT v."ID", v."VRM", v."SurveyID", su."RoadName",
               lead(v."SurveyID", 1) over( partition by "VRM", "SurveyDay" order by v."SurveyID", su."RoadName", v."VRM"),
               lag(v."SurveyID", 1) over(partition by "VRM", "SurveyDay" order by v."SurveyID", su."RoadName", v."VRM")
        FROM demand."VRMs_test" v, demand."Surveys_test" s, mhtc_operations."Supply_test" su
        WHERE s."SurveyID" = v."SurveyID"
		AND v."GeometryID" = su."GeometryID"
        ORDER BY "VRM", "SurveyID"
     ) AS t
WHERE v."ID" = t."ID"
;
