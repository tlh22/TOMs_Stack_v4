-- echelon bays

UPDATE local_authority."Bays_Transfer"
SET "GeomShapeID" = 5
WHERE "GeomShapeID" < 10
AND "bEchelon" = 'Y';

UPDATE local_authority."Bays_Transfer"
SET "GeomShapeID" = 25
WHERE "GeomShapeID" < 20
AND "bEchelon" = 'Y';


-- take the tables with the processed records and move them to TOMs structure
INSERT INTO "toms_lookups"."TimePeriodsInUse" ("Code")
SELECT u."TimePeriodID"
FROM (
SELECT DISTINCT "TimePeriodID"
FROM local_authority."PM_BayRestrictions_processed"
WHERE "TimePeriodID" IS NOT NULL
UNION
SELECT DISTINCT "TimePeriodID"
FROM local_authority."PM_LineRestrictions_processed"
WHERE "TimePeriodID" IS NOT NULL ) u
WHERE u."TimePeriodID" NOT IN (
    SELECT "Code" FROM "toms_lookups"."TimePeriodsInUse"
);

INSERT INTO "toms_lookups"."BayTypesInUse" ("Code", "GeomShapeGroupType")
SELECT DISTINCT l."RestrictionTypeID", 'LineString'
FROM local_authority."PM_BayRestrictions_processed" l
WHERE l."RestrictionTypeID" IS NOT NULL
AND l."RestrictionTypeID" NOT IN (
    SELECT "Code" FROM "toms_lookups"."BayTypesInUse"
);

INSERT INTO "toms_lookups"."LineTypesInUse" ("Code", "GeomShapeGroupType")
SELECT DISTINCT l."RestrictionTypeID", 'LineString'
FROM local_authority."PM_LineRestrictions_processed" l
WHERE l."RestrictionTypeID" IS NOT NULL
AND l."RestrictionTypeID" NOT IN (
    SELECT "Code" FROM "toms_lookups"."LineTypesInUse"
);

--ALTER TABLE toms."Bays" DISABLE TRIGGER update_capacity_bays;

ALTER TABLE toms."Bays"
    ADD COLUMN "item_ref" integer;
ALTER TABLE toms."Bays"
    ADD COLUMN "RBKC_NrBays" integer;
	
INSERT INTO toms."Bays"(
	geom, "RoadName", "RBKC_NrBays", "RestrictionID", "GeometryID", "RestrictionTypeID", "TimePeriodID",  "GeomShapeID", "item_ref")
SELECT (ST_Dump(geom)).geom AS geom, 
    "Street_nam", "bNoBays", uuid_generate_v4(), "GeometryID", "RestrictionTypeID", "TimePeriodID",  "GeomShapeID", "item_ref"
	FROM local_authority."Bays_Transfer";

--ALTER TABLE toms."Bays" ENABLE TRIGGER update_capacity_bays;

--ALTER TABLE toms."Lines" DISABLE TRIGGER update_capacity_lines;

ALTER TABLE toms."Lines"
    ADD COLUMN "item_ref" integer;

INSERT INTO toms."Lines"(
	geom, "RoadName", "RestrictionID", "GeometryID", "RestrictionTypeID", "NoWaitingTimeID",  "GeomShapeID", "item_ref")
SELECT (ST_Dump(geom)).geom AS geom, 
    "Street_nam", uuid_generate_v4(), "GeometryID", "RestrictionTypeID", "TimePeriodID",  "GeomShapeID", "item_ref"
	FROM local_authority."Lines_Transfer";


--ALTER TABLE toms."Lines" ENABLE TRIGGER update_capacity_lines;

-- Need to add Open date ...

-- echelon bays

UPDATE toms."Bays" AS r
SET "GeomShapeID" = t."GeomShapeID"
FROM local_authority."Bays_Transfer" t
WHERE t."item_ref" = r."item_ref";