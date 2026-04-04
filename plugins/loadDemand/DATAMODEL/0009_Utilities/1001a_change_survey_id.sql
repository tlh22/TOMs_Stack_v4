/***
 * When SurveyID needs to be changed ...
 ***/

DROP TABLE IF EXISTS "demand"."SurveyIDs_To_Change" CASCADE;

CREATE TABLE "demand"."SurveyIDs_To_Change" (
    id SERIAL,
    "curr_survey_id" INTEGER NOT NULL,
    "new_survey_id" INTEGER NOT NULL,
	CONSTRAINT "SurveyIDs_To_Change_pkey" PRIMARY KEY ("curr_survey_id", "new_survey_id")
);

--INSERT INTO "demand"."SurveyIDs_To_Change"("curr_survey_id", "new_survey_id") VALUES (201, 108);

INSERT INTO "demand"."SurveyIDs_To_Change"("curr_survey_id", "new_survey_id") VALUES (107, 108);
INSERT INTO "demand"."SurveyIDs_To_Change"("curr_survey_id", "new_survey_id") VALUES (106, 107);
INSERT INTO "demand"."SurveyIDs_To_Change"("curr_survey_id", "new_survey_id") VALUES (105, 106);
INSERT INTO "demand"."SurveyIDs_To_Change"("curr_survey_id", "new_survey_id") VALUES (104, 105);
INSERT INTO "demand"."SurveyIDs_To_Change"("curr_survey_id", "new_survey_id") VALUES (103, 104);
INSERT INTO "demand"."SurveyIDs_To_Change"("curr_survey_id", "new_survey_id") VALUES (102, 103);
INSERT INTO "demand"."SurveyIDs_To_Change"("curr_survey_id", "new_survey_id") VALUES (101, 102);

-- Ensure that SurveyIDs are present

--INSERT INTO demand."Surveys"("SurveyID",  "SurveyDay", "SurveyDate", "BeatStartTime", "BeatEndTime") VALUES (201,'Saturday','23/08/2025','0030','0530');
UPDATE demand."Surveys"
SET "BeatStartTime" = '0500', "BeatEndTime" = '0700'
WHERE "SurveyID" = 101;

UPDATE demand."Surveys"
SET "BeatStartTime" = '0700', "BeatEndTime" = '0900'
WHERE "SurveyID" = 102;

UPDATE demand."Surveys"
SET "BeatStartTime" = '0900', "BeatEndTime" = '1100'
WHERE "SurveyID" = 103;

UPDATE demand."Surveys"
SET "BeatStartTime" = '1100', "BeatEndTime" = '1300'
WHERE "SurveyID" = 104;

UPDATE demand."Surveys"
SET "BeatStartTime" = '1300', "BeatEndTime" = '1500'
WHERE "SurveyID" = 105;

UPDATE demand."Surveys"
SET "BeatStartTime" = '1500', "BeatEndTime" = '1700'
WHERE "SurveyID" = 106;

UPDATE demand."Surveys"
SET "BeatStartTime" = '1500', "BeatEndTime" = '1700'
WHERE "SurveyID" = 106;

UPDATE demand."Surveys"
SET "BeatStartTime" = '1700', "BeatEndTime" = '1900'
WHERE "SurveyID" = 107;

INSERT INTO demand."Surveys"("SurveyID",  "SurveyDay", "SurveyDate", "BeatStartTime", "BeatEndTime") VALUES (108,'Thursday','21/08/2025','1900','2000');


-- for VRMs
DO
$do$
DECLARE
      survey_to_change RECORD;
	  --curr_survey_id INTEGER;
	  --new_survey_id INTEGER;

BEGIN

	FOR survey_to_change IN
		SELECT id, curr_survey_id, new_survey_id
		FROM "demand"."SurveyIDs_To_Change"
		ORDER BY id ASC

    LOOP
	
		RAISE NOTICE '*****--- Moving from (%) to (%)', survey_to_change.curr_survey_id, survey_to_change.new_survey_id;
		
		--UPDATE "demand"."Surveys" Su
		--SET "SurveyID" = survey_to_change.new_survey_id
		--WHERE "SurveyID" = survey_to_change.curr_survey_id;
		
		UPDATE "demand"."RestrictionsInSurveys" RiS
		SET "SurveyID" = survey_to_change.new_survey_id
		WHERE "SurveyID" = survey_to_change.curr_survey_id;
		
		UPDATE "demand"."VRMs" v
		SET "SurveyID" = survey_to_change.new_survey_id
		WHERE "SurveyID" = survey_to_change.curr_survey_id;
		
    END LOOP;
	
END;
$do$;
