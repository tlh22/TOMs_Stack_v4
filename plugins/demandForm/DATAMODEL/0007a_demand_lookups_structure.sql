-- Demand lookups
--DROP SCHEMA IF EXISTS "demand_lookups" CASCADE;
CREATE SCHEMA IF NOT EXISTS "demand_lookups";
ALTER SCHEMA "demand_lookups" OWNER TO "postgres";

-- RestrictionTypes In Use

-- RestrictionTypes In Use
DROP MATERIALIZED VIEW IF EXISTS "demand_lookups"."SupplyRestrictionTypesInUse_View";
CREATE MATERIALIZED VIEW "demand_lookups"."SupplyRestrictionTypesInUse_View" AS
 SELECT DISTINCT "BayLineTypes"."Code",
    "BayLineTypes"."Description"
   FROM "toms_lookups"."BayLineTypes",
    "mhtc_operations"."Supply"
  WHERE ("BayLineTypes"."Code" = "Supply"."RestrictionTypeID")
  ORDER BY "BayLineTypes"."Code"
  WITH DATA;

ALTER TABLE "demand_lookups"."SupplyRestrictionTypesInUse_View" OWNER TO "postgres";

-- Vehicle types

DROP TABLE IF EXISTS "demand_lookups"."VehicleTypes";
CREATE TABLE "demand_lookups"."VehicleTypes" (
    "Code" SERIAL,
    "Description" character varying,
    "PCU" double precision,
    "PCUinSameTypeBay" double precision
);

ALTER TABLE "demand_lookups"."VehicleTypes" OWNER TO "postgres";

ALTER TABLE demand_lookups."VehicleTypes"
    ADD PRIMARY KEY ("Code");

/***
ALTER TABLE IF EXISTS demand_lookups."VehicleTypes"
    ADD COLUMN "PCUinSameTypeBay" double precision;
***/

-- permit types

DROP TABLE IF EXISTS "demand_lookups"."PermitTypes";
CREATE TABLE "demand_lookups"."PermitTypes" (
    "Code" SERIAL,
    "Description" character varying
);

ALTER TABLE "demand_lookups"."PermitTypes" OWNER TO "postgres";

ALTER TABLE demand_lookups."PermitTypes"
    ADD PRIMARY KEY ("Code");

-- user types

DROP TABLE IF EXISTS "demand_lookups"."UserTypes";
CREATE TABLE "demand_lookups"."UserTypes" (
    "Code" SERIAL,
    "Description" character varying
);

ALTER TABLE "demand_lookups"."UserTypes" OWNER TO "postgres";

ALTER TABLE demand_lookups."UserTypes"
    ADD PRIMARY KEY ("Code");

-- International codes

DROP TABLE IF EXISTS "demand_lookups"."InternationalCodes";
CREATE TABLE "demand_lookups"."InternationalCodes" (
    "Code" SERIAL,
    "Description" character varying,
    "Country" character varying
);

ALTER TABLE "demand_lookups"."InternationalCodes" OWNER TO "postgres";

ALTER TABLE demand_lookups."InternationalCodes"
    ADD PRIMARY KEY ("Code");

-- Activity Type

DROP TABLE IF EXISTS "demand_lookups"."ParkingActivityTypes";
CREATE TABLE "demand_lookups"."ParkingActivityTypes" (
    "Code" SERIAL,
    "Description" character varying
);

ALTER TABLE "demand_lookups"."ParkingActivityTypes" OWNER TO "postgres";

ALTER TABLE demand_lookups."ParkingActivityTypes"
    ADD PRIMARY KEY ("Code");

-- Parking Manner Type

DROP TABLE IF EXISTS "demand_lookups"."ParkingMannerTypes";
CREATE TABLE "demand_lookups"."ParkingMannerTypes" (
    "Code" SERIAL,
    "Description" character varying
);

ALTER TABLE "demand_lookups"."ParkingMannerTypes" OWNER TO "postgres";

ALTER TABLE demand_lookups."ParkingMannerTypes"
    ADD PRIMARY KEY ("Code");

-- Duration Categories

/***
DROP TABLE IF EXISTS "demand_lookups"."DurationCategories";
CREATE TABLE "demand_lookups"."DurationCategories" (
    "Code" SERIAL,
    "Description" character varying
);

ALTER TABLE "demand_lookups"."DurationCategories" OWNER TO "postgres";

ALTER TABLE demand_lookups."DurationCategories"
    ADD PRIMARY KEY ("Code");
***/

-- Duration Categories

DROP TABLE IF EXISTS "demand_lookups"."DurationCategories";
CREATE TABLE "demand_lookups"."DurationCategories" (
    "DurationCategoryID" SERIAL,
    "StartTime" INTERVAL,
    "EndTime" INTERVAL,
    "Description" character varying
);

ALTER TABLE "demand_lookups"."DurationCategories"
    ADD PRIMARY KEY ("DurationCategoryID");

