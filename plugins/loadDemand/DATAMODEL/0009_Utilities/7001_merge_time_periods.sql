/***
 * If the area required surveys over multiple days, i.e., SurveyIDs relate to specific days and these are to be merged into groups, e.g., all Saturday surveys
 ***/

DROP TABLE IF EXISTS demand."Surveys_Staging";

CREATE TABLE IF NOT EXISTS demand."Surveys_Staging"
(
    "SurveyID" integer NOT NULL,
    "SurveyDay" character varying(50) COLLATE pg_catalog."default",
    "SurveyDate" date NOT NULL DEFAULT CURRENT_DATE,
    "BeatStartTime" character varying(10) COLLATE pg_catalog."default",
    "BeatEndTime" character varying(10) COLLATE pg_catalog."default",
    "BeatTitle" character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT "Surveys_Staging_pkey" PRIMARY KEY ("SurveyID")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand."Surveys_Staging"
    OWNER to postgres;

GRANT ALL ON TABLE demand."Surveys_Staging" TO postgres;

--

INSERT INTO "demand"."Surveys_Staging" VALUES (1001, 'Saturday', '2022-10-01', '0000', '0200', '1001_Sat_0000_0200');
INSERT INTO "demand"."Surveys_Staging" VALUES (1002, 'Saturday', '2022-10-01', '0930', '1200', '1002_Sat_0930_1200');
INSERT INTO "demand"."Surveys_Staging" VALUES (1003, 'Saturday', '2022-10-01', '1500', '1700', '1003_Sat_1500_1700');
INSERT INTO "demand"."Surveys_Staging" VALUES (2001, 'Tuesday', '2022-10-01', '0000', '0200', '2001_Tue_0000_0200');
INSERT INTO "demand"."Surveys_Staging" VALUES (2002, 'Tuesday', '2022-10-01', '0930', '1200', '2002_Tue_0930_1200');
INSERT INTO "demand"."Surveys_Staging" VALUES (2003, 'Tuesday', '2022-10-01', '1500', '1700', '2003_Tue_1500_1700');
INSERT INTO "demand"."Surveys_Staging" VALUES (3001, 'Wednesday', '2022-10-01', '0000', '0200', '3001_Wed_0000_0200');
INSERT INTO "demand"."Surveys_Staging" VALUES (3002, 'Wednesday', '2022-10-01', '0930', '1200', '3002_Wed_0930_1200');
INSERT INTO "demand"."Surveys_Staging" VALUES (3003, 'Wednesday', '2022-10-01', '1500', '1700', '3003_Wed_1500_1700');

--

--DROP TABLE IF EXISTS demand."Surveys_Migration";

CREATE TABLE IF NOT EXISTS demand."Surveys_Migration"
(
    gid SERIAL,
    "origSurveyID" integer NOT NULL,
    "newSurveyID" integer
);

INSERT INTO demand."Surveys_Migration" ("origSurveyID")
SELECT "SurveyID"
FROM demand."Surveys"
WHERE "SurveyID" > 0;

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 1001
WHERE "origSurveyID" IN (101, 401);

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 1002
WHERE "origSurveyID" IN (102, 402);

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 1003
WHERE "origSurveyID" IN (103, 403);

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 2001
WHERE "origSurveyID" IN (201, 501);

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 2002
WHERE "origSurveyID" IN (202, 502);

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 2003
WHERE "origSurveyID" IN (203, 503);

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 3001
WHERE "origSurveyID" IN (301, 601);

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 3002
WHERE "origSurveyID" IN (302, 602);

UPDATE demand."Surveys_Migration"
SET "newSurveyID" = 3003
WHERE "origSurveyID" IN (303, 603);

-- RiS

DROP TABLE IF EXISTS demand."RestrictionsInSurveys_Staging";

CREATE TABLE IF NOT EXISTS demand."RestrictionsInSurveys_Staging"
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
    geom geometry(LineString,27700) NOT NULL,
    "CaptureSource" character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT "RestrictionsInSurveys_Staging_pkey" PRIMARY KEY ("SurveyID", "GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys_Staging"
    OWNER to postgres;

GRANT ALL ON TABLE demand."RestrictionsInSurveys_Staging" TO postgres;

-- Index: RiS_unique_idx

DROP INDEX IF EXISTS demand."RiS_Staging_unique_idx";

CREATE UNIQUE INDEX IF NOT EXISTS "RiS_Staging_unique_idx"
    ON demand."RestrictionsInSurveys_Staging" USING btree
    ("SurveyID" ASC NULLS LAST, "GeometryID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

-- Create entries

INSERT INTO demand."RestrictionsInSurveys_Staging" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys_Staging";

-- Update with "Done" values

UPDATE demand."RestrictionsInSurveys_Staging" stage
	SET "DemandSurveyDateTime"=ris."DemandSurveyDateTime", "Enumerator"=ris."Enumerator", "Done"=ris."Done", 
	    "SuspensionReference"=ris."SuspensionReference", "SuspensionReason"=ris."SuspensionReason", "SuspensionLength"=ris."SuspensionLength", 
	    "NrBaysSuspended"=ris."NrBaysSuspended", "SuspensionNotes"=ris."SuspensionNotes", 
	    "Photos_01"=ris."Photos_01", "Photos_02"=ris."Photos_02", "Photos_03"=ris."Photos_03", "CaptureSource"=ris."CaptureSource"
	FROM demand."RestrictionsInSurveys" ris, demand."Surveys_Migration" m
	WHERE ris."SurveyID" = m."origSurveyID"
	AND m."newSurveyID" = stage."SurveyID"
	AND stage."GeometryID" = ris."GeometryID"
	AND ris."Done" IS true;

-- VRMs

DROP TABLE IF EXISTS demand."VRMs_Staging";

CREATE TABLE IF NOT EXISTS demand."VRMs_Staging"
(
    "ID" SERIAL,
    "SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "PositionID" integer,
    "VRM" character varying(12) COLLATE pg_catalog."default",
    "InternationalCodeID" integer,
    "VehicleTypeID" integer,
    "PermitTypeID" integer,
    "Notes" character varying(255) COLLATE pg_catalog."default",
    "ParkingActivityTypeID" integer,
    "ParkingMannerTypeID" integer,
    CONSTRAINT "VRMs_Staging_pkey" PRIMARY KEY ("ID")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand."VRMs_Staging"
    OWNER to postgres;

GRANT ALL ON TABLE demand."VRMs_Staging" TO postgres;

--

INSERT INTO demand."VRMs_Staging"(
	"SurveyID", "GeometryID", "PositionID", "VRM", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "Notes", "ParkingActivityTypeID", "ParkingMannerTypeID")
SELECT m."newSurveyID", "GeometryID", "PositionID", "VRM", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "Notes", "ParkingActivityTypeID", "ParkingMannerTypeID"
	FROM demand."VRMs" v, demand."Surveys_Migration" m
	WHERE v."SurveyID" = m."origSurveyID";

-- Now swap around tables

ALTER TABLE IF EXISTS demand."Surveys"
    RENAME TO "Surveys_orig";

ALTER TABLE IF EXISTS demand."Surveys_Staging"
    RENAME TO "Surveys";

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    RENAME TO "RestrictionsInSurveys_orig";

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys_Staging"
    RENAME TO "RestrictionsInSurveys";

ALTER TABLE IF EXISTS demand."VRMs"
    RENAME TO "VRMs_orig";

ALTER TABLE IF EXISTS demand."VRMs_Staging"
    RENAME TO "VRMs";

/***
 * Change back ...


ALTER TABLE IF EXISTS demand."Surveys"
    RENAME TO "Surveys_Staging";

ALTER TABLE IF EXISTS demand."Surveys_orig"
    RENAME TO "Surveys";


ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    RENAME TO "RestrictionsInSurveys_Staging";

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys_orig"
    RENAME TO "RestrictionsInSurveys";


ALTER TABLE IF EXISTS demand."VRMs"
    RENAME TO "VRMs_Staging";

ALTER TABLE IF EXISTS demand."VRMs_orig"
    RENAME TO "VRMs";

***/

-- For Islington
UPDATE demand."VRMs"
SET "SurveyID" = 101
WHERE "SurveyID" IN (201, 301, 401);

UPDATE demand."VRMs"
SET "SurveyID" = 102
WHERE "SurveyID" IN (202, 302, 402);

UPDATE demand."VRMs"
SET "SurveyID" = 103
WHERE "SurveyID" IN (203, 303, 403);

UPDATE demand."RestrictionsInSurveys" ris1
	SET "DemandSurveyDateTime"=ris2."DemandSurveyDateTime", "Enumerator"=ris2."Enumerator", "Done"=ris2."Done", 
	    "SuspensionReference"=ris2."SuspensionReference", "SuspensionReason"=ris2."SuspensionReason", "SuspensionLength"=ris2."SuspensionLength", 
	    "NrBaysSuspended"=ris2."NrBaysSuspended", "SuspensionNotes"=ris2."SuspensionNotes", 
	    "Photos_01"=ris2."Photos_01", "Photos_02"=ris2."Photos_02", "Photos_03"=ris2."Photos_03", "CaptureSource"=ris2."CaptureSource"
	FROM demand."RestrictionsInSurveys" ris2
	WHERE ris1."SurveyID" = 101
	AND ris2."SurveyID" IN (201, 301, 401)
	AND ris1."GeometryID" = ris2."GeometryID"
	AND ris2."Done" IS true
	AND ris1."Enumerator" IS NULL;

UPDATE demand."RestrictionsInSurveys" ris1
	SET "DemandSurveyDateTime"=ris2."DemandSurveyDateTime", "Enumerator"=ris2."Enumerator", "Done"=ris2."Done", 
	    "SuspensionReference"=ris2."SuspensionReference", "SuspensionReason"=ris2."SuspensionReason", "SuspensionLength"=ris2."SuspensionLength", 
	    "NrBaysSuspended"=ris2."NrBaysSuspended", "SuspensionNotes"=ris2."SuspensionNotes", 
	    "Photos_01"=ris2."Photos_01", "Photos_02"=ris2."Photos_02", "Photos_03"=ris2."Photos_03", "CaptureSource"=ris2."CaptureSource"
	FROM demand."RestrictionsInSurveys" ris2
	WHERE ris1."SurveyID" = 102
	AND ris2."SurveyID" IN (202, 302, 402)
	AND ris1."GeometryID" = ris2."GeometryID"
	AND ris2."Done" IS true
	AND ris1."Enumerator" IS NULL;

UPDATE demand."RestrictionsInSurveys" ris1
	SET "DemandSurveyDateTime"=ris2."DemandSurveyDateTime", "Enumerator"=ris2."Enumerator", "Done"=ris2."Done", 
	    "SuspensionReference"=ris2."SuspensionReference", "SuspensionReason"=ris2."SuspensionReason", "SuspensionLength"=ris2."SuspensionLength", 
	    "NrBaysSuspended"=ris2."NrBaysSuspended", "SuspensionNotes"=ris2."SuspensionNotes", 
	    "Photos_01"=ris2."Photos_01", "Photos_02"=ris2."Photos_02", "Photos_03"=ris2."Photos_03", "CaptureSource"=ris2."CaptureSource"
	FROM demand."RestrictionsInSurveys" ris2
	WHERE ris1."SurveyID" = 103
	AND ris2."SurveyID" IN (203, 303, 403)
	AND ris1."GeometryID" = ris2."GeometryID"
	AND ris2."Done" IS true
	AND ris1."Enumerator" IS NULL;