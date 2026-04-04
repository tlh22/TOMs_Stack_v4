
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Notes" character varying(255) COLLATE pg_catalog."default";


UPDATE "demand"."RestrictionsInSurveys" RiS
SET "Notes" = v."VRM_Notes"
FROM
(SELECT "SurveyID", "GeometryID", STRING_AGG("Notes", ' | ') AS "VRM_Notes"
 FROM demand."VRMs"
 WHERE "Notes" IS NOT NULL
 GROUP BY  "SurveyID", "GeometryID") v
 WHERE v."SurveyID" = RiS."SurveyID"
 AND v."GeometryID" = RiS."GeometryID"
