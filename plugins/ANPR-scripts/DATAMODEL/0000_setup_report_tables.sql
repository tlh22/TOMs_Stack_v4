-- Schema

CREATE SCHEMA IF NOT EXISTS "anpr";
ALTER SCHEMA "anpr" OWNER TO "postgres";

-- Time Periods

DROP TABLE IF EXISTS "anpr"."TimePeriods";
CREATE TABLE "anpr"."TimePeriods" (
    "TimePeriodID" SERIAL,
    "StartTime" timestamp without time zone,
    "EndTime" timestamp without time zone
);

ALTER TABLE "anpr"."TimePeriods" OWNER TO "postgres";

ALTER TABLE "anpr"."TimePeriods"
    ADD PRIMARY KEY ("TimePeriodID");

-- Now load

COPY anpr."TimePeriods"("StartTime", "EndTime")
FROM 'C:\Users\Public\Documents\SurveyTimePeriods.csv'
DELIMITER ','
CSV HEADER;

-- Car Parks

DROP TABLE IF EXISTS "anpr"."CarParks";
CREATE TABLE "anpr"."CarParks" (
    "CarParkID" SERIAL,
    "Description" character varying
);

ALTER TABLE "anpr"."CarParks"
    ADD PRIMARY KEY ("CarParkID");

-- Now load

COPY anpr."CarParks"("CarParkID", "Description")
FROM 'C:\Users\Public\Documents\CarParks.csv'
DELIMITER ','
CSV HEADER;

-- Sites

DROP TABLE IF EXISTS "anpr"."Sites";
CREATE TABLE "anpr"."Sites" (
    "SiteID" integer NOT NULL,
    "Description" character varying,
	"CarParkID" integer,
    "IN" character varying,
    "OUT" character varying
);

ALTER TABLE "anpr"."Sites"
    ADD PRIMARY KEY ("SiteID");
	
--ALTER TABLE IF EXISTS anpr."Sites"
--    ADD COLUMN "CarParkID" integer;

-- Now load

COPY anpr."Sites"("SiteID", "Description", "CarParkID", "IN", "OUT")
FROM 'C:\Users\Public\Documents\Sites.csv'
DELIMITER ','
CSV HEADER;

-- Routes

DROP TABLE IF EXISTS "anpr"."Routes";
CREATE TABLE "anpr"."Routes" (
    "RouteID" SERIAL,
    "FromSiteID" integer,
    "ToSiteID" integer,
    "MinimumTimeLimit" INTERVAL,
    "MaximumTimeLimit" INTERVAL
);

ALTER TABLE "anpr"."Routes"
    ADD PRIMARY KEY ("RouteID");

-- Now load

COPY anpr."Routes"("FromSiteID", "ToSiteID", "MinimumTimeLimit", "MaximumTimeLimit")
FROM 'C:\Users\Public\Documents\Routes.csv'
DELIMITER ','
CSV HEADER;

-- Duration Categories

DROP TABLE IF EXISTS "anpr"."DurationCategories";
CREATE TABLE "anpr"."DurationCategories" (
    "DurationCategoryID" SERIAL,
    "StartTime" INTERVAL,
    "EndTime" INTERVAL,
    "Description" character varying
);

ALTER TABLE "anpr"."DurationCategories"
    ADD PRIMARY KEY ("DurationCategoryID");

-- Now load

COPY anpr."DurationCategories"("DurationCategoryID", "StartTime", "EndTime", "Description")
FROM 'C:\Users\Public\Documents\DurationCategories.csv'
DELIMITER ','
CSV HEADER;

