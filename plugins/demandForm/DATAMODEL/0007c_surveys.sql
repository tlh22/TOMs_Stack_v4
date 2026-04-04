
-- Demand
DROP SCHEMA IF EXISTS "demand" CASCADE;
CREATE SCHEMA IF NOT EXISTS "demand";
ALTER SCHEMA "demand" OWNER TO "postgres";

-- surveys
DROP TABLE IF EXISTS "demand"."Surveys";
CREATE TABLE "demand"."Surveys" (
    "SurveyID" integer NOT NULL,
    "SurveyDay" character varying (50) COLLATE pg_catalog."default",
    "SurveyDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "BeatStartTime" character varying (10) COLLATE pg_catalog."default",
    "BeatEndTime" character varying (10) COLLATE pg_catalog."default",
    "BeatTitle" character varying (100) COLLATE pg_catalog."default"
);

ALTER TABLE "demand"."Surveys" OWNER TO "postgres";

ALTER TABLE "demand"."Surveys"
    ADD PRIMARY KEY ("SurveyID");


--
/***
ALTER TABLE demand."Surveys"
    ADD COLUMN "SurveyDate" date;

UPDATE demand."Surveys"
SET "SurveyDate" = '2021-11-24'
WHERE "SurveyID" = 1;

UPDATE demand."Surveys"
SET "SurveyDate" = '2021-11-30'
WHERE "SurveyID" = 2;
***/