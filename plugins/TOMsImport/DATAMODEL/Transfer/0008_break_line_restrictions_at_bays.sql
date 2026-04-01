-- Lines_orig

DROP TABLE IF EXISTS mhtc_operations."Lines_orig" CASCADE;

CREATE TABLE mhtc_operations."Lines_orig"
(
    "RestrictionID" character varying(254) COLLATE pg_catalog."default" NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL DEFAULT ('L_'::text || to_char(nextval('toms."Lines_id_seq"'::regclass), 'FM0000000'::text)),
    geom geometry(LineString,27700) NOT NULL,
    "RestrictionLength" double precision NOT NULL,
    "RestrictionTypeID" integer NOT NULL,
    "GeomShapeID" integer NOT NULL,
    "AzimuthToRoadCentreLine" double precision,
    "Notes" character varying(254) COLLATE pg_catalog."default",
    "Photos_01" character varying(255) COLLATE pg_catalog."default",
    "Photos_02" character varying(255) COLLATE pg_catalog."default",
    "Photos_03" character varying(255) COLLATE pg_catalog."default",
    "RoadName" character varying(254) COLLATE pg_catalog."default",
    "USRN" character varying(254) COLLATE pg_catalog."default",
    "label_Rotation" double precision,
    "label_TextChanged" character varying(254) COLLATE pg_catalog."default",
    "OpenDate" date,
    "CloseDate" date,
    "CPZ" character varying(40) COLLATE pg_catalog."default",
    "LastUpdateDateTime" timestamp without time zone NOT NULL,
    "LastUpdatePerson" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "NoWaitingTimeID" integer,
    "NoLoadingTimeID" integer,
    "UnacceptableTypeID" integer,
    "AdditionalConditionID" integer,
    "ParkingTariffArea" character varying(10) COLLATE pg_catalog."default",
    "labelLoading_Rotation" double precision,
    "ComplianceRoadMarkingsFaded" integer,
    "ComplianceRestrictionSignIssue" integer,
    "ComplianceNotes" character varying(254) COLLATE pg_catalog."default",
    "MHTC_CheckIssueTypeID" integer,
    "MHTC_CheckNotes" character varying(254) COLLATE pg_catalog."default",
    label_pos geometry(MultiPoint,27700),
    label_ldr geometry(MultiLineString,27700),
    label_loading_pos geometry(MultiPoint,27700),
    label_loading_ldr geometry(MultiLineString,27700),
    "ComplianceLoadingMarkingsFaded" integer,
    "MatchDayTimePeriodID" integer,
    "FieldCheckCompleted" boolean NOT NULL DEFAULT false,
    "Last_MHTC_Check_UpdateDateTime" timestamp without time zone,
    "Last_MHTC_Check_UpdatePerson" character varying(255) COLLATE pg_catalog."default",
    "CreateDateTime" timestamp without time zone NOT NULL,
    "CreatePerson" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Capacity" integer,
    "MatchDayEventDayZone" character varying(40) COLLATE pg_catalog."default",

    CONSTRAINT "Lines_orig_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

--- populate

INSERT INTO mhtc_operations."Lines_orig"(
	"RestrictionID",
	"GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID",
	"CreateDateTime", "CreatePerson"
    )
SELECT
    "RestrictionID",
    "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID",
    "CreateDateTime", "CreatePerson"
	FROM toms."Lines";


-- set up crossover nodes table
DROP TABLE IF EXISTS  mhtc_operations."BayNodes" CASCADE;

CREATE TABLE mhtc_operations."BayNodes"
(
  id SERIAL,
  geom geometry(Point,27700),
  CONSTRAINT "BayNodes_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."BayNodes"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."BayNodes" TO postgres;

CREATE INDEX "sidx_BayNodes_geom"
  ON mhtc_operations."BayNodes"
  USING gist
  (geom);

--

INSERT INTO mhtc_operations."BayNodes" (geom)
SELECT ST_StartPoint(geom) As geom
FROM toms."Bays";

INSERT INTO mhtc_operations."BayNodes" (geom)
SELECT ST_EndPoint(geom) As geom
FROM toms."Bays";

-- Make "blade" geometry

DROP TABLE IF EXISTS  mhtc_operations."BayNodes_Single" CASCADE;

CREATE TABLE mhtc_operations."BayNodes_Single"
(
  id SERIAL,
  geom geometry(MultiPoint,27700),
  CONSTRAINT "BayNodes_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."BayNodes_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."BayNodes_Single" TO postgres;

CREATE INDEX "sidx_BayNodes_Single_geom"
  ON mhtc_operations."BayNodes_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."BayNodes_Single" (geom)
SELECT ST_Multi(ST_Collect(geom)) As geom
FROM mhtc_operations."BayNodes";

-- ***

DELETE FROM toms."Lines";

--

INSERT INTO "toms"."Lines" ( "RestrictionID",
	"RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID",
    "CreateDateTime", "CreatePerson",
    geom)
SELECT uuid_generate_v4(),
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID",
    "CreateDateTime", "CreatePerson",
    (ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM "mhtc_operations"."Lines_orig" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Lines_orig" s1,
									  (SELECT geom
									  FROM "mhtc_operations"."BayNodes"
									  ) cnr) c
WHERE ST_DWithin(s1.geom, c.geom, 0.25)
union
SELECT uuid_generate_v4(),
    "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "MatchDayEventDayZone", "LastUpdateDateTime", "LastUpdatePerson", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "MatchDayTimePeriodID",
    "CreateDateTime", "CreatePerson",
    s1.geom
FROM "mhtc_operations"."Lines_orig" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "mhtc_operations"."Lines_orig" s1,
									  (SELECT geom
									  FROM "mhtc_operations"."BayNodes"
									  ) cnr) c
WHERE NOT ST_DWithin(s1.geom, c.geom, 0.25);

DELETE FROM "toms"."Lines"
WHERE ST_Length(geom) < 0.0001;

DELETE FROM "toms"."Lines"
USING toms."Bays" s2
WHERE ST_Within(s1.geom, ST_Buffer(s2.geom, 0.1));

