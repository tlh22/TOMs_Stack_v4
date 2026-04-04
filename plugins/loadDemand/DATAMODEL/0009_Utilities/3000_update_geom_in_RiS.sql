-- Update after changes to supply to help with checking

UPDATE demand."RestrictionsInSurveys" AS RiS
SET geom = s.geom
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";

-- and add any new restrictions 

INSERT INTO demand."RestrictionsInSurveys" ("SurveyID", "GeometryID", geom)
SELECT "SurveyID", "GeometryID", r.geom As geom
FROM mhtc_operations."Supply" r, demand."Surveys"
WHERE "GeometryID" NOT IN
(SELECT "GeometryID"
FROM demand."RestrictionsInSurveys");

-- remove any old restrictions ???
