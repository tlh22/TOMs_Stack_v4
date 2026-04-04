/***
 * For situations where the supply is changed during a demand survey, add the new restrictions into "RestrictionsInSurveys"
 ***/

ALTER TABLE demand."RestrictionsInSurveys" DISABLE TRIGGER update_demand;

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN
(SELECT "GeometryID"
FROM demand."RestrictionsInSurveys");

-- for count type surveys

INSERT INTO demand."Counts" ("SurveyID", "GeometryID")
SELECT "SurveyID", "GeometryID"
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN
(SELECT "GeometryID"
FROM demand."Counts");

-- Add extra Surveys

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "SurveyID" NOT IN
(SELECT "SurveyID"
FROM demand."RestrictionsInSurveys");

-- for count type surveys
INSERT INTO demand."Counts" ("SurveyID", "GeometryID")
SELECT "SurveyID", "GeometryID"
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "SurveyID" NOT IN
(SELECT "SurveyID"
FROM demand."Counts");

-- Update geom
						   
UPDATE demand."RestrictionsInSurveys" AS RiS
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";

-- remove RiS entries for which there is no supply ...

DELETE FROM demand."RestrictionsInSurveys"
WHERE "GeometryID" NOT IN (SELECT "GeometryID"
					       FROM mhtc_operations."Supply");
						   
DELETE FROM demand."Counts"
WHERE "GeometryID" NOT IN (SELECT "GeometryID"
					       FROM mhtc_operations."Supply");

-- Deal with unique id

UPDATE demand."RestrictionsInSurveys"
SET "GeometryID_SurveyID" = NULL;

UPDATE demand."RestrictionsInSurveys"
SET "GeometryID_SurveyID" = CONCAT("GeometryID", '_', "SurveyID"::text);

UPDATE demand."Counts"
SET "GeometryID_SurveyID" = NULL;

UPDATE demand."Counts" c
SET "GeometryID_SurveyID" = RiS."GeometryID_SurveyID"
FROM demand."RestrictionsInSurveys" RiS
WHERE c."SurveyID" = RiS."SurveyID"
AND c."GeometryID" = RiS."GeometryID"
;

ALTER TABLE demand."RestrictionsInSurveys" ENABLE TRIGGER update_demand;
