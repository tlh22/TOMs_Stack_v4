/***
Setup details for demand
***/

DROP TABLE IF EXISTS demand."RestrictionsInSurveys" CASCADE;

CREATE TABLE demand."RestrictionsInSurveys"
(
    gid INT GENERATED ALWAYS AS IDENTITY,
    "SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "DemandSurveyDateTime" timestamp without time zone,
    "Enumerator" character varying (100) COLLATE pg_catalog."default",
    "Done" boolean,
    "SuspensionReference" character varying (100) COLLATE pg_catalog."default",
    "SuspensionReason" character varying (255) COLLATE pg_catalog."default",
    "SuspensionLength" double precision,
    "NrBaysSuspended" integer,
    "SuspensionNotes" character varying (255) COLLATE pg_catalog."default",
    "Photos_01" character varying (255) COLLATE pg_catalog."default",
    "Photos_02" character varying (255) COLLATE pg_catalog."default",
    "Photos_03" character varying (255) COLLATE pg_catalog."default",
    "CaptureSource" character varying (255) COLLATE pg_catalog."default",

    "Demand_ALL" double precision,  -- All vehicles within restriction
    "Demand" double precision,  -- Vehicles "parked" within restriction (but not in suspended areas) - and not waiting or idling
    "DemandInSuspendedAreas" double precision,
    "Demand_Waiting" double precision,  -- vehicles waiting
    "Demand_Idling" double precision,
    "Demand_ParkedIncorrectly" double precision,
    "CapacityAtTimeOfSurvey" double precision,
    "Stress" double precision,

    "PerceivedAvailableSpaces" double precision,
    "PerceivedCapacityAtTimeOfSurvey" double precision,
    "PerceivedStress" double precision,

    "Supply_Notes" character varying(10000),
    "MCL_Notes" character varying(10000),

    geom geometry(LineString,27700) NOT NULL,
    UNIQUE ("SurveyID", "GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE demand."RestrictionsInSurveys"
    OWNER to postgres;

ALTER TABLE demand."RestrictionsInSurveys" ADD PRIMARY KEY ("gid");

CREATE UNIQUE INDEX "idx_RestrictionsInSurveys_SurveyID_GeometryID" ON demand."RestrictionsInSurveys" ("SurveyID", "GeometryID");

CREATE INDEX RiS_geom_idx
  ON demand."RestrictionsInSurveys"
  USING GIST (geom);
  
/***

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN "CaptureSource" character varying(255);

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "Demand_Standard" double precision; -- This is the count of all vehicles in the main count tab
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "DemandInSuspendedAreas" double precision;  -- This is the count of all vehicles in the suspensions tab

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Waiting" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Idling" double precision;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_ParkedIncorrectly" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "SupplyCapacity" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "CapacityAtTimeOfSurvey" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Stress" double precision;

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", gid::text AS "GeometryID", r.geom As geom
FROM mhtc_operations."RC_Sections_merged" r, demand."Surveys";
***/

-- OR

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys";

/***
UPDATE demand."RestrictionsInSurveys"
SET "Done" = false
WHERE "Done" IS true;
***/

/***
-- Following changes in supply ...

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN
(SELECT "GeometryID"
FROM demand."RestrictionsInSurveys");

UPDATE demand."RestrictionsInSurveys" AS RiS
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";


INSERT INTO "demand"."Counts" ("SurveyID", "GeometryID")
SELECT "SurveyID", "GeometryID"
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN
(SELECT "GeometryID"
FROM demand."Counts");

***/