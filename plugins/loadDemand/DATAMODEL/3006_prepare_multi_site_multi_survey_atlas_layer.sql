/***

QGIS atlas will only support one coverage layer so if there are multiple layers required, need to generate special table

***/

DROP TABLE IF EXISTS demand."AreasWithSurveys" CASCADE;

CREATE TABLE "demand"."AreasWithSurveys" (
    id SERIAL,
    "SurveyID" integer NOT NULL,
    "SurveyDay" character varying (50) COLLATE pg_catalog."default",
    "SurveyDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "BeatStartTime" character varying (10) COLLATE pg_catalog."default",
    "BeatEndTime" character varying (10) COLLATE pg_catalog."default",
    "BeatTitle" character varying (100) COLLATE pg_catalog."default",
    "SurveyAreaName" character varying (50) COLLATE pg_catalog."default",
    geom geometry(Polygon,27700),
    CONSTRAINT "AreasWithSurveys_pkey" PRIMARY KEY (id));

ALTER TABLE "demand"."AreasWithSurveys" OWNER TO "postgres";

-- Populate

INSERT INTO demand."AreasWithSurveys" ("SurveyID", "SurveyDay", "SurveyDate", "BeatStartTime", "BeatEndTime", "BeatTitle",
									   "SurveyAreaName", geom)
SELECT "SurveyID", "SurveyDay", "SurveyDate", "BeatStartTime", "BeatEndTime", "BeatTitle",
	   a."SurveyAreaName", a.geom
FROM demand."Surveys" s, mhtc_operations."SurveyAreas" a

/*** Southwark Areas

INSERT INTO demand."AreasWithSurveys" ("SurveyID", "SurveyDay", "SurveyDate", "BeatStartTime", "BeatEndTime", "BeatTitle",
									   "SurveyAreaName", geom)
SELECT "SurveyID", "SurveyDay", "SurveyDate", "BeatStartTime", "BeatEndTime", "BeatTitle",
	   a."zonename", a.geom
FROM demand."Surveys" s, import_geojson."SouthwarkProposedDeliveryZones" a


UPDATE demand."AreasWithSurveys"
SET "BeatTitle" = "SurveyDay" || ' - Overnight (' || LEFT("BeatStartTime", 2) || ':' || RIGHT("BeatStartTime", 2) || '-' || LEFT("BeatEndTime", 2) || ':' || RIGHT("BeatEndTime", 2) || ')'
WHERE MOD("SurveyID", 100) = 1
AND "SurveyID" > 0;

UPDATE demand."AreasWithSurveys"
SET "BeatTitle" = "SurveyDay" || ' - Morning (' || LEFT("BeatStartTime", 2) || ':' || RIGHT("BeatStartTime", 2) || '-' || LEFT("BeatEndTime", 2) || ':' || RIGHT("BeatEndTime", 2) || ')'
WHERE MOD("SurveyID", 100) = 2
AND "SurveyID" > 0;

UPDATE demand."AreasWithSurveys"
SET "BeatTitle" = "SurveyDay" || ' - Afternoon (' || LEFT("BeatStartTime", 2) || ':' || RIGHT("BeatStartTime", 2) || '-' || LEFT("BeatEndTime", 2) || ':' || RIGHT("BeatEndTime", 2) || ')'
WHERE MOD("SurveyID", 100) = 3
AND "SurveyID" > 0;

***/