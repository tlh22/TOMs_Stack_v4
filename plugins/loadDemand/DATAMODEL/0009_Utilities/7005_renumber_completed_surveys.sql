/***

Use in Southwark to renumber re-surveys

***/

UPDATE demand."RestrictionsInSurveys"
SET "SurveyID" = "SurveyID" + 500
WHERE "SurveyID" > 0;

UPDATE demand."Counts"
SET "SurveyID" = "SurveyID" + 500
WHERE "SurveyID" > 0;

UPDATE demand."Surveys"
SET "SurveyID" = "SurveyID" + 500
WHERE "SurveyID" > 0;