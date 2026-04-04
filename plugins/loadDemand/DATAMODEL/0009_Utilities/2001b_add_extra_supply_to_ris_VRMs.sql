/***
 * For situations where the supply is changed during a demand survey, add the new restrictions into "RestrictionsInSurveys"
 ***/

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN
(SELECT "GeometryID"
FROM demand."RestrictionsInSurveys");

-- Add extra Surveys

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "SurveyID" NOT IN
(SELECT "SurveyID"
FROM demand."RestrictionsInSurveys");

-- Update geom
						   
UPDATE demand."RestrictionsInSurveys" AS RiS
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";

-- remove RiS entries for which there is no supply ...

DELETE FROM demand."RestrictionsInSurveys"
WHERE "GeometryID" NOT IN (SELECT "GeometryID"
					       FROM mhtc_operations."Supply");

-- Deal with unique id

UPDATE demand."RestrictionsInSurveys"
SET "GeometryID_SurveyID" = CONCAT("GeometryID", '_', "SurveyID"::text);
