-- create supply table that shows bay divisions

DROP TABLE IF EXISTS demand."Supply_for_viewing_parking_locations" CASCADE;

CREATE TABLE demand."Supply_for_viewing_parking_locations"
(
    gid INT GENERATED ALWAYS AS IDENTITY,
	"SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    geom geometry(LineString,27700) NOT NULL,
    "RestrictionLength" double precision NOT NULL,
    "RestrictionTypeID" integer NOT NULL,
    "GeomShapeID" integer NOT NULL,
    "AzimuthToRoadCentreLine" double precision,
    "BayOrientation" double precision,
    "NrBays" integer NOT NULL DEFAULT '-1'::integer,
    "Capacity" integer,
    CONSTRAINT "Supply_for_viewing_parking_locations_pkey" UNIQUE ("SurveyID", "GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE demand."Supply_for_viewing_parking_locations"
    OWNER to postgres;
-- Index: sidx_Supply_geom

-- DROP INDEX mhtc_operations."sidx_Supply_geom";

CREATE INDEX "sidx_Supply_for_viewing_parking_locations_geom"
    ON demand."Supply_for_viewing_parking_locations" USING gist
    (geom)
    TABLESPACE pg_default;


-- populate

INSERT INTO demand."Supply_for_viewing_parking_locations"(
	"SurveyID", "GeometryID", geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", 
	"AzimuthToRoadCentreLine", "BayOrientation", "NrBays", "Capacity")
SELECT "SurveyID", "GeometryID", geom, "RestrictionLength", "RestrictionTypeID",
        CASE WHEN "GeomShapeID" < 10 THEN "GeomShapeID" + 20
             WHEN "GeomShapeID" >= 10 AND "GeomShapeID" < 20 THEN 21
             ELSE "GeomShapeID"
         END
         , "AzimuthToRoadCentreLine", "BayOrientation",
         CASE WHEN "NrBays" = -1 THEN 
			CASE WHEN "Capacity" = 0 THEN ROUND(ST_LENGTH(geom)/5.0)
				ELSE "Capacity"
				END
              ELSE "NrBays"
         END AS "NrBays", "Capacity"  -- increase the NrBays value to deal with over parked areas

	FROM 

	(SELECT ris."SurveyID", ris."GeometryID", s.geom, "RestrictionLength", "RestrictionTypeID",
	        CASE WHEN "GeomShapeID" < 10 THEN "GeomShapeID" + 20
	             WHEN "GeomShapeID" >= 10 AND "GeomShapeID" < 20 THEN 21
	             ELSE "GeomShapeID"
	         END
	         , "AzimuthToRoadCentreLine", "BayOrientation",
			 CASE WHEN "NrBays" = -1 THEN 
				CASE WHEN "Capacity" = 0 THEN ROUND(ST_LENGTH(s.geom)/5.0)
					ELSE "Capacity"
					END
				  ELSE "NrBays"
			 END AS "NrBays",
			 "CapacityAtTimeOfSurvey" AS "Capacity",  -- increase the NrBays value to deal with over parked areas
			 "Demand"
		FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, mhtc_operations."Supply" s
		WHERE ris."SurveyID" = su."SurveyID"
	    AND ris."GeometryID" = s."GeometryID"
	 	AND su."SurveyID" > 0) y 
