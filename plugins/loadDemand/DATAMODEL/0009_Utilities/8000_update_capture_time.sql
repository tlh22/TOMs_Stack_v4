
SELECT "DemandSurveyDateTime", "DemandSurveyDateTime" + INTERVAL '99' day + INTERVAL '10' hour + INTERVAL '45' minute
FROM "demand"."RestrictionsInSurveys"
WHERE "CaptureSource" LIKE '%rainbow%'

UPDATE "demand"."RestrictionsInSurveys"
SET "DemandSurveyDateTime" = "DemandSurveyDateTime" + INTERVAL '99' day + INTERVAL '10' hour + INTERVAL '45' minute
WHERE "CaptureSource" LIKE '%rainbow%'