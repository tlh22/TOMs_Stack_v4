-- surveys

--INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (1, 'Monday', '0030', '0300');
--INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (2, 'Tuesday', '0030', '0300');

UPDATE demand."Surveys"
--SET "BeatTitle" = LPAD("SurveyID"::text, 3, '0') || '_' || "SurveyDay" || '_' || "BeatStartTime" || '_' || "BeatEndTime"
SET "BeatTitle" = LPAD("SurveyID"::text, 3, '0') || '_' || to_char("SurveyDate", 'Dy_DD_Mon') || '_' || "BeatStartTime" || '_' || "BeatEndTime"
WHERE "BeatTitle" IS NULL;

-- Add test survey

INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle") VALUES (0, 'Wednesday', 'start', 'end', 'TestBeat');