-- create an updatable view for VRMs - with geometry attached.

DROP VIEW IF EXISTS demand."VRMs_View" CASCADE;

CREATE OR REPLACE VIEW demand."VRMs_View"
AS
 SELECT v.*, s."RoadName", s."Description" AS "RestrictionDescription", RiS."Enumerator", s.geom
   FROM demand."VRMs" v, demand."RestrictionsInSurveys" RiS,
    (mhtc_operations."Supply" a LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") s
  WHERE s."GeometryID" = v."GeometryID"
  AND v."SurveyID" = RiS."SurveyID"
  ANd v."GeometryID" = RiS."GeometryID"
;

--

CREATE OR REPLACE FUNCTION demand."VRMs_View_upd_trig_fn" ()
    RETURNS TRIGGER
    AS $$
BEGIN

    RAISE NOTICE 'tg_op: %', tg_op;
	
    IF tg_op = 'UPDATE' THEN
        IF NEW."VRM" IS DISTINCT FROM OLD."VRM" OR
		   NEW."SurveyID" <> OLD."SurveyID" OR
		   NEW."GeometryID" <> OLD."GeometryID" OR
		   NEW."InternationalCodeID" <> OLD."InternationalCodeID" OR
		   NEW."VehicleTypeID" <> OLD."VehicleTypeID" OR
		   NEW."PermitTypeID" <> OLD."PermitTypeID" OR
		   NEW."ParkingActivityTypeID" <> OLD."ParkingActivityTypeID" OR
		   NEW."ParkingMannerTypeID" <> OLD."ParkingMannerTypeID" OR
		   NEW."Notes" IS DISTINCT FROM OLD."Notes"
		THEN
            RAISE NOTICE 'update VRM';
            UPDATE demand."VRMs"
            SET 
			"SurveyID" = NEW."SurveyID"
			, "GeometryID" = NEW."GeometryID"
			, "VRM" = NEW."VRM"
			, "InternationalCodeID" = NEW."InternationalCodeID"
			, "VehicleTypeID" = NEW."VehicleTypeID"
			, "PermitTypeID" = NEW."PermitTypeID"
			, "ParkingActivityTypeID" = NEW."ParkingActivityTypeID"
			, "ParkingMannerTypeID" = NEW."ParkingMannerTypeID"
			, "Notes" = NEW."Notes"
            WHERE "ID" = OLD."ID";
			RETURN new;
        END IF;
    END IF;
	
    RAISE NOTICE 'new.VRM_View:%', new;
    RAISE NOTICE 'old.VRM_View:%', old;
	
    RETURN NULL;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER "VRMs_View_upd_trig"
    INSTEAD OF UPDATE ON demand."VRMs_View"
    FOR EACH ROW EXECUTE PROCEDURE demand."VRMs_View_upd_trig_fn"();

--
	
CREATE OR REPLACE FUNCTION demand."VRMs_View_delete_trigger_fn" ()
    RETURNS TRIGGER
    AS $$
BEGIN
	IF tg_op = 'DELETE' THEN
	    RAISE NOTICE 'delete VRM';
        DELETE FROM demand."VRMs"
        WHERE "ID" = OLD."ID";
        RETURN old;
    END IF;
	
    RAISE NOTICE 'old.VRM_View:%', old;
	
    RETURN NULL;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER "VRMs_View_delete_trigger"
    INSTEAD OF DELETE ON demand."VRMs_View"
    FOR EACH ROW EXECUTE PROCEDURE demand."VRMs_View_delete_trigger_fn"();
	
--
	
CREATE OR REPLACE FUNCTION demand."VRMs_View_insert_trigger_fn" ()
    RETURNS TRIGGER
    AS $$
BEGIN
	IF tg_op = 'INSERT' THEN
	    RAISE NOTICE 'insert VRM';
		INSERT INTO demand."VRMs"(
			"SurveyID", "GeometryID", "PositionID", "VRM", "InternationalCodeID", "VehicleTypeID", "PermitTypeID", "ParkingActivityTypeID", "ParkingMannerTypeID", "Notes", "VRM_Orig")
		VALUES (new."SurveyID", new."GeometryID", new."PositionID", new."VRM", new."InternationalCodeID", new."VehicleTypeID", new."PermitTypeID", new."ParkingActivityTypeID", new."ParkingMannerTypeID", new."Notes", new."VRM_Orig");
        RETURN new;
    END IF;
	
    RAISE NOTICE 'issue with inserting ...';
	
    RETURN NULL;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER "VRMs_View_insert_trigger"
    INSTEAD OF INSERT ON demand."VRMs_View"
    FOR EACH ROW EXECUTE PROCEDURE demand."VRMs_View_insert_trigger_fn"();