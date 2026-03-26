-- Compatibility export views for TRDC projects expecting export.* layers.
-- Safe to re-run.

CREATE SCHEMA IF NOT EXISTS export;

DROP VIEW IF EXISTS export."Bays";
CREATE VIEW export."Bays" AS
SELECT b.*
FROM toms."Bays" b;

DROP VIEW IF EXISTS export."Lines";
CREATE VIEW export."Lines" AS
SELECT l.*
FROM toms."Lines" l;

DROP VIEW IF EXISTS export."Signs";
CREATE VIEW export."Signs" AS
SELECT s.*
FROM toms."Signs" s;

-- Some projects reference Sign_point as a separate export layer.
DROP VIEW IF EXISTS export."Sign_point";
CREATE VIEW export."Sign_point" AS
SELECT * FROM export."Signs";

DROP VIEW IF EXISTS export."RestrictionPolygons";
CREATE VIEW export."RestrictionPolygons" AS
SELECT r.*
FROM toms."RestrictionPolygons" r;

DROP VIEW IF EXISTS export."CPZs";
CREATE VIEW export."CPZs" AS
SELECT c.*
FROM toms."ControlledParkingZones" c;
