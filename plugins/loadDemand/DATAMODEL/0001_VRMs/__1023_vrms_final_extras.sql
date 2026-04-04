/***
 * Reload amended VRMs
 ***/

-- Load data into new table
-- Load data into new table
DROP TABLE IF EXISTS demand."VRMs_Final_extras" CASCADE;
CREATE TABLE demand."VRMs_Final_extras"
(
  "ID" SERIAL,
  "SurveyID" integer,
  "SectionID" integer,
  "GeometryID" character varying(12),
  "PositionID" integer,
  "VRM" character varying(12),
  "VehicleTypeID" integer,
  "RestrictionTypeID" integer,
  "PermitTypeID" integer,
  "Notes" character varying(255),
  CONSTRAINT "VRMs_Final_extras_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE demand."VRMs_Final_extras"
  OWNER TO postgres;

-- import
COPY demand."VRMs_Final_extras"("SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "PermitTypeID", "Notes")
FROM 'C:\Users\Public\Documents\PC2209_WGR_All_VRMs_3_extras.csv'
DELIMITER ','
CSV HEADER;

/***
--INSERT INTO demand."VRMs_Final_extras" ("SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "PermitTypeID", "Notes")
SELECT 401, v1."GeometryID", v1."PositionID", v1."VRM", v1."VehicleTypeID", v1."PermitTypeID", v1."Notes"
FROM demand."VRMs_Final" v1, demand."VRMs_Final" v2
WHERE v1."VRM" = v2."VRM"
AND v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" = 301
AND v2."SurveyID" = 301
--AND v1."GeometryID" IN (SELECT "GeometryID" FROM mhtc_operations."Supply" r
--                     WHERE r."SurveyArea" IN ('7S-1'))
AND v1."GeometryID" IN ('S_008826', 'S_008519', 'S_007999', 'S_007923', 'S_007439')
AND v1."VRM" NOT IN (SELECT "VRM" FROM demand."VRMs_Final_extras"
					 WHERE "SurveyID" = 401)
 AND v1."VRM" NOT IN (SELECT "VRM" FROM demand."VRMs_Final"
					 WHERE "SurveyID" = 401)
ORDER BY v1."GeometryID", v1."VRM"
***/

-- Update RiS

UPDATE demand."RestrictionsInSurveys" RiS
SET "Done" = true, "Enumerator" = 'MASTER', "DemandSurveyDateTime" = now()
FROM
    (
        SELECT DISTINCT RiS2."SurveyID", RiS2."GeometryID" --, RiS."Done"
        FROM demand."RestrictionsInSurveys" RiS2, demand."VRMs_Final_extras" v
        WHERE RiS2."SurveyID" = v."SurveyID"
        AND RiS2."GeometryID" = v."GeometryID"
        AND RiS2."Done" IS NOT True
     ) AS t
WHERE RiS."SurveyID" = t."SurveyID"
AND RiS."GeometryID" = t."GeometryID";

-- Now copy extras into final

-- first delete any already used
/***
DELETE FROM demand."VRMs_Final_extras" e
USING demand."VRMs_Final" v
WHERE e."SurveyID" = v."SurveyID"
AND e."GeometryID" = v."GeometryID"
AND e."VRM" = v."VRM";
***/

-- add any new ones
INSERT INTO demand."VRMs_Final" ("SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "PermitTypeID", "Notes")
SELECT "SurveyID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "PermitTypeID", "Notes"
FROM demand."VRMs_Final_extras";


-- Specials
DELETE FROM demand."VRMs_Final"
WHERE "VRM" = 'LX13-GJV'
AND "SurveyID" = 305;

DELETE FROM demand."VRMs_Final" v
USING mhtc_operations."Supply" s
WHERE v."GeometryID" = s."GeometryID"
AND s."RestrictionTypeID" = 219;  - Private Road

DELETE FROM demand."VRMs_Final"
WHERE "SurveyID" = 0;

DELETE FROM demand."VRMs_Final" v
USING mhtc_operations."Supply" s
WHERE v."GeometryID" IN (SELECT "GeometryID" FROM mhtc_operations."Supply" r
                     WHERE r."SurveyArea" IN ('7S-WGR'));