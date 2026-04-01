-- these are the target layers

CREATE SCHEMA IF NOT EXISTS "import";
ALTER SCHEMA "import" OWNER TO "postgres";

CREATE TABLE "import"."Restrictions_Import" (
    "GeometryID" character varying NOT NULL,
    "geom" "public"."geometry"(MultiLineString,27700),
    "RestrictionTypeID" integer,
    "RoadName" character varying(254),
    "USRN" character varying(254),
    "OpenDate" "date",
    "CPZ" character varying(40),
    "NrBays" integer,
    "TimePeriodID" integer,
    "PayTypeID" integer,
    "MaxStayID" integer,
    "NoReturnID" integer,
    "NoWaitingTimeID" integer,
    "NoLoadingTimeID" integer
);


ALTER TABLE "import"."Restrictions_Import" OWNER TO "postgres";

ALTER TABLE ONLY "import"."Restrictions_Import"
    ADD CONSTRAINT "Restrictions_Import_pkey" PRIMARY KEY ("GeometryID");

GRANT USAGE ON SCHEMA import TO toms_public, toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE "import"."Restrictions_Import" TO toms_operator, toms_admin;