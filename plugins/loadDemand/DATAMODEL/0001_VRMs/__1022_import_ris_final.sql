/***
 * Reload amended RiS
 ***/

DROP TABLE IF EXISTS demand."RestrictionsInSurveys_Final" CASCADE;

CREATE TABLE IF NOT EXISTS demand."RestrictionsInSurveys_Final"
(
    "SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "DemandSurveyDateTime" timestamp without time zone,
    "Enumerator" character varying(100) COLLATE pg_catalog."default",
    "Done" boolean,
    "SuspensionReference" character varying(100) COLLATE pg_catalog."default",
    "SuspensionReason" character varying(255) COLLATE pg_catalog."default",
    "SuspensionLength" double precision,
    "NrBaysSuspended" integer,
    "SuspensionNotes" character varying(255) COLLATE pg_catalog."default",
    "Photos_01" character varying(255) COLLATE pg_catalog."default",
    "Photos_02" character varying(255) COLLATE pg_catalog."default",
    "Photos_03" character varying(255) COLLATE pg_catalog."default",
    geom geometry(LineString,27700),
    "CaptureSource" character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT "RestrictionsInSurveys_Final_pkey" PRIMARY KEY ("SurveyID", "GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys_Final"
    OWNER to postgres;
-- Index: RiS_unique_idx

DROP INDEX IF EXISTS demand."RiS_Final_unique_idx";

CREATE UNIQUE INDEX IF NOT EXISTS "RiS_Final_unique_idx"
    ON demand."RestrictionsInSurveys_Final" USING btree
    ("SurveyID" ASC NULLS LAST, "GeometryID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

COPY demand."RestrictionsInSurveys_Final"("SurveyID", "GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference",
"SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", "Photos_01", "Photos_02", "Photos_03")
FROM 'C:\Users\Public\Documents\SYS2201_RiS_Final.csv'
DELIMITER ','
CSV HEADER;

-- Insert records that were not Done

INSERT INTO demand."RestrictionsInSurveys_Final"("SurveyID", "GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference",
"SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", "Photos_01", "Photos_02", "Photos_03")
SELECT "SurveyID", RiS."GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference",
"SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
AND "Done" IS NULL OR "Done" IS false;

-- add geom

UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "geom" = s."geom"
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";

-- add CaptureSource

UPDATE demand."RestrictionsInSurveys_Final" RiS_f
SET "CaptureSource" = RiS."CaptureSource"
FROM demand."RestrictionsInSurveys" RiS
WHERE RiS_f."GeometryID" = RiS."GeometryID"
AND RiS_f."SurveyID" = RiS."SurveyID";