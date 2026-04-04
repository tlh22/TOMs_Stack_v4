/*
Load from csv
*/

-- Demand lookups
CREATE SCHEMA IF NOT EXISTS "anpr";
ALTER SCHEMA "anpr" OWNER TO "postgres";

DROP TABLE IF EXISTS anpr."VRMs" CASCADE;
CREATE TABLE anpr."VRMs"
(
  "ID" SERIAL,
  "SiteID" integer NOT NULL,
  "VRM" character varying(12) NOT NULL,
  "InternationalCode" character varying(12),
  "CaptureTime" timestamp without time zone NOT NULL,
  "Direction" character varying(12),
  "VehicleType" character varying(12),
  "PermitTypeID" INTEGER,
  "MatchedTo" integer,
  "MatchedFrom" integer,
  CONSTRAINT "VRMs_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE anpr."VRMs"
  OWNER TO postgres;

--ALTER TABLE anpr."VRMs"
--    ADD COLUMN "MatchedAt" integer;
    
-- Now copy details into the VRMs table

COPY anpr."VRMs"("SiteID", "VRM", "InternationalCode", "CaptureTime", "Direction", "VehicleType")
FROM 'C:\Users\Public\Documents\VRMs_CP01.csv'
DELIMITER ','
CSV HEADER;

-- create index

CREATE INDEX idx_vrms ON anpr."VRMs"
(
    "VRM"
);


-- Change VehicleType

ALTER TABLE anpr."VRMs" RENAME COLUMN "VehicleType" TO "VehicleTypeID";

ALTER TABLE anpr."VRMs" ALTER COLUMN "VehicleTypeID" TYPE INTEGER USING ("VehicleTypeID"::integer);

-- Change InternationalCode

ALTER TABLE anpr."VRMs" RENAME COLUMN "InternationalCode" TO "InternationalCodeID";

ALTER TABLE anpr."VRMs" ALTER COLUMN "InternationalCodeID" TYPE INTEGER USING ("InternationalCodeID"::integer);


-- Now copy additional details into the VRMs table

COPY anpr."VRMs"("SiteID", "VRM", "InternationalCodeID", "CaptureTime", "Direction", "VehicleTypeID", "PermitTypeID")
FROM 'C:\Users\Public\Documents\ADL2501_VRMs_101_CP01.csv'
DELIMITER ','
CSV HEADER;


/***

Need to check that:
 - opening/closing records are present
 - no records exist on day before opening records (as this creates duplicates)
 - 
 
 
 ***/