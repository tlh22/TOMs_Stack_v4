
DROP TABLE IF EXISTS demand."VRMs" CASCADE;
CREATE TABLE demand."VRMs"
(
  "ID" SERIAL,
  "SurveyID" integer NOT NULL,
  "GeometryID" character varying(12) NOT NULL,
  "PositionID" integer,
  "VRM" character varying(12),
  "InternationalCodeID" integer,
  "VehicleTypeID" integer,
  "PermitTypeID" integer,
  "ParkingActivityTypeID" integer,
  "ParkingMannerTypeID" integer,
  "Notes" character varying(255),
  CONSTRAINT "VRMs_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE demand."VRMs"
  OWNER TO postgres;


/***
ALTER TABLE demand."VRMs" ALTER "Foreign" TYPE INTEGER USING CASE WHEN false THEN 0 ELSE 1 END;
ALTER TABLE demand."VRMs" RENAME COLUMN "Foreign" TO "InternationalCodeID";
ALTER TABLE IF EXISTS demand."VRMs" ADD COLUMN "ParkingActivityTypeID" integer;
ALTER TABLE IF EXISTS demand."VRMs" ADD COLUMN "ParkingMannerTypeID" integer;
***/

-- TODO: foreign keys ...

ALTER TABLE ONLY demand."VRMs"
    ADD CONSTRAINT "VRMs_SurveyID_fkey" FOREIGN KEY ("SurveyID") REFERENCES "demand"."Surveys"("SurveyID");

ALTER TABLE ONLY demand."VRMs"
    ADD CONSTRAINT "VRMs_GeometryID_fkey" FOREIGN KEY ("GeometryID") REFERENCES "mhtc_operations"."Supply"("GeometryID");

-- ALTER TABLE IF EXISTS demand."VRMs" DROP CONSTRAINT IF EXISTS "VRMs_GeometryID_fkey";

ALTER TABLE ONLY demand."VRMs"
    ADD CONSTRAINT "VRMs_InternationalCodeID_fkey" FOREIGN KEY ("InternationalCodeID") REFERENCES "demand_lookups"."InternationalCodes"("Code");

ALTER TABLE ONLY demand."VRMs"
    ADD CONSTRAINT "VRMs_VehicleTypeID_fkey" FOREIGN KEY ("VehicleTypeID") REFERENCES "demand_lookups"."VehicleTypes"("Code");

ALTER TABLE ONLY demand."VRMs"
    ADD CONSTRAINT "VRMs_PermitTypeID_fkey" FOREIGN KEY ("PermitTypeID") REFERENCES "demand_lookups"."PermitTypes"("Code");

ALTER TABLE ONLY demand."VRMs"
    ADD CONSTRAINT "VRMs_ParkingActivityTypeID_fkey" FOREIGN KEY ("ParkingActivityTypeID") REFERENCES "demand_lookups"."ParkingActivityTypes"("Code");

ALTER TABLE ONLY demand."VRMs"
    ADD CONSTRAINT "VRMs_ParkingMannerTypeID_fkey" FOREIGN KEY ("ParkingMannerTypeID") REFERENCES "demand_lookups"."ParkingMannerTypes"("Code");
    
CREATE INDEX idx_SurveyID_GeometryID ON demand."VRMs"
(
    "SurveyID", "GeometryID"
);