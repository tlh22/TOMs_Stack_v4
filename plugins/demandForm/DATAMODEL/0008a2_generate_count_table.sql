
DROP TABLE IF EXISTS demand."Counts" CASCADE;

CREATE TABLE "demand"."Counts" (
  gid INT GENERATED ALWAYS AS IDENTITY,
  "SurveyID" integer NOT NULL,
  "GeometryID" character varying(12) NOT NULL,

  "NrCars" integer,
  "NrLGVs" integer,
  "NrMCLs" integer,
  "NrTaxis" integer,
  "NrPCLs" integer,
  "NrEScooters" integer,
  "NrDocklessPCLs" integer,
  "NrOGVs" integer,
  "NrMiniBuses" integer,
  "NrBuses" integer,
  "NrSpaces" integer,
  "Notes" character varying(10000) COLLATE pg_catalog."default",

  "DoubleParkingDetails" character varying COLLATE pg_catalog."default",

  "NrCars_Suspended" integer,
  "NrLGVs_Suspended" integer,
  "NrMCLs_Suspended" integer,
  "NrTaxis_Suspended" integer,
  "NrPCLs_Suspended" integer,
  "NrEScooters_Suspended" integer,
  "NrDocklessPCLs_Suspended" integer,
  "NrOGVs_Suspended" integer,
  "NrMiniBuses_Suspended" integer,
  "NrBuses_Suspended" integer,

   UNIQUE ("SurveyID", "GeometryID")
)
WITH (
  OIDS=FALSE
);

ALTER TABLE demand."Counts"
  OWNER TO postgres;

ALTER TABLE "demand"."Counts"
    ADD PRIMARY KEY ("gid");

CREATE UNIQUE INDEX "idx_Counts_SurveyID_GeometryID" ON demand."Counts" ("SurveyID", "GeometryID");

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

CREATE INDEX idx_count_notes ON demand."Counts" USING GIN ("Notes");


-- and populate

INSERT INTO "demand"."Counts" ("SurveyID", "GeometryID")
SELECT "SurveyID", "GeometryID"
FROM mhtc_operations."Supply" r, demand."Surveys";

ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrCarsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrLGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMCLsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrTaxisWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrOGVsWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesWaiting" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrBusesWaiting" integer;

/***
 For RBKC
***/

-- Idling
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrCarsIdling" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrLGVsIdling" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMCLsIdling" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrTaxisIdling" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrOGVsIdling" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesIdling" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrBusesIdling" integer;

-- Parked incorrectly
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrCarsParkedIncorrectly" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrLGVsParkedIncorrectly" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMCLsParkedIncorrectly" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrTaxisParkedIncorrectly" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrOGVsParkedIncorrectly" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrMiniBusesParkedIncorrectly" integer;
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrBusesParkedIncorrectly" integer;

-- Disabled in P&D bay
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN IF NOT EXISTS "NrCarsWithDisabledBadgeParkedInPandD" integer;

