/***
  Need to create any time periods that do not exist
  - Need to do this against the "Master" database. Currently this is on ISL.
  ** check for nulls and n/a
  So, copy to ISL and run ...

***/

INSERT INTO "toms_lookups"."TimePeriods" ("Description", "LabelText")
SELECT DISTINCT u."TimePeriodDescription", u."TimePeriodDescription"
FROM public."PM_TimePeriods_Transfer_RBKC_2020" u
WHERE u."TimePeriodCode" IS NULL;

UPDATE public."PM_TimePeriods_Transfer_RBKC_2020" As p
SET "TimePeriodCode"=l."Code"
FROM toms_lookups."TimePeriods" l
WHERE p."TimePeriodDescription" = l."Description"
AND p."TimePeriodCode" IS NULL;

--   ... and copy "TimePeriods" back ... create table "TimePeriods_MASTER"

INSERT INTO "toms_lookups"."TimePeriods" ("Code", "Description", "LabelText")
SELECT DISTINCT u."Code", u."Description", u."LabelText"
FROM "toms_lookups"."TimePeriods_MASTER" u
WHERE u."Code" NOT IN (
    SELECT "Code" FROM "toms_lookups"."TimePeriods"
);

INSERT INTO "toms_lookups"."TimePeriodsInUse" ("Code")
SELECT DISTINCT u."TimePeriodCode"
FROM local_authority."PM_TimePeriods_Transfer_RBKC_2020" u
WHERE u."TimePeriodCode" NOT IN (
    SELECT "Code" FROM "toms_lookups"."TimePeriodsInUse"
);

--

ALTER TABLE local_authority."PM_BayRestrictions_processed"
    ADD COLUMN "TimePeriodID" integer;

UPDATE local_authority."PM_BayRestrictions_processed" As p
	SET "TimePeriodID"=l."TimePeriodCode"
	FROM local_authority."PM_TimePeriods_Transfer" l
	WHERE p.times_of_e = l.times_of_e;

UPDATE local_authority."PM_BayRestrictions_processed" As p
	SET "TimePeriodID" = 0
	WHERE "times_of_e" IS NULL;

--

ALTER TABLE local_authority."PM_LineRestrictions_processed"
    ADD COLUMN "TimePeriodID" integer;

UPDATE local_authority."PM_LineRestrictions_processed" As p
	SET "TimePeriodID"=l."TimePeriodCode"
	FROM local_authority."PM_TimePeriods_Transfer" l
	WHERE p.times_of_e = l.times_of_e;

UPDATE local_authority."PM_LineRestrictions_processed" As p
	SET "TimePeriodID" = 0
	WHERE "times_of_e" IS NULL;