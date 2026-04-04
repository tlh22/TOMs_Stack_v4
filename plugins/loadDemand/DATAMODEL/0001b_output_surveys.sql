
SELECT "SurveyID", concat("BeatStartTime", '-', "BeatEndTime") AS "TimePeriod", "SurveyDay", "SurveyDate", "BeatTitle"
	FROM demand."Surveys"
	WHERE "SurveyID" > 0
    ORDER BY "SurveyID";


-- =CONCAT("Beat ", A1, CHAR(10), LEFT(C1, 3), " ", B1)