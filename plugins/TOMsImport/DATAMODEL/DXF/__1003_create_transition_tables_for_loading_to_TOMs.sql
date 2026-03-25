/***
Now import into structure
***/

-- Split into different tables

DROP TABLE IF EXISTS local_authority."Transition_Bays" CASCADE;

CREATE TABLE local_authority."Transition_Bays"
(
    id SERIAL,
    "RestrictionTypeID" integer,
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry(LineString,27700),
    "NrBays" integer,
    "TimePeriodID" integer,
    CONSTRAINT "Transition_Bays_pkey" PRIMARY KEY (id)
)
;

DROP TABLE IF EXISTS local_authority."Transition_Lines" CASCADE;

CREATE TABLE local_authority."Transition_Lines"
(
    id SERIAL,
    "RestrictionTypeID" integer,
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry(LineString,27700),
    "NoWaitingTimeID" integer,
    CONSTRAINT "Transition_Lines_pkey" PRIMARY KEY (id)
)
;

DROP TABLE IF EXISTS local_authority."Transition_RestrictionPolygons" CASCADE;

CREATE TABLE local_authority."Transition_RestrictionPolygons"
(
    id SERIAL,
    "RestrictionTypeID" integer,
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry(Polygon,27700),
    CONSTRAINT "Transition_RestrictionPolygons_pkey" PRIMARY KEY (id)
)
;

DROP TABLE IF EXISTS local_authority."Transition_CrossingPoints" CASCADE;

CREATE TABLE local_authority."Transition_CrossingPoints"
(
    id SERIAL,
    "RestrictionTypeID" integer,
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry(Polygon,27700),
    CONSTRAINT "Transition_Crossovers_pkey" PRIMARY KEY (id)
)
;

-- import

INSERT INTO local_authority."Transition_Bays"(
	geom, "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "NrBays", "TimePeriodID")
SELECT geom, "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", -1, 1
	FROM local_authority."DXF_Merged_single"
	WHERE "RestrictionTypeID" < 200
	AND "RestrictionTypeID" > 100
	;

INSERT INTO local_authority."Transition_Lines"(
	geom, "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "NoWaitingTimeID")
SELECT geom, "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", 1
	FROM local_authority."DXF_Merged_single"
	WHERE "RestrictionTypeID" > 200
	;

INSERT INTO local_authority."Transition_RestrictionPolygons"(
	geom, "RestrictionTypeID", "GeomShapeID")
SELECT ST_MakePolygon(geom), "RestrictionTypeID", 50
	FROM local_authority."DXF_Merged_single"
	WHERE "RestrictionTypeID" < 100
	;

/*** ??
INSERT INTO local_authority."Transition_CrossingPoints"(
	geom, "RestrictionTypeID", "GeomShapeID")
SELECT geom, "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", 35
	FROM local_authority."DXF_??"
	;
***/