/***
Add column to keep original details
***/

ALTER TABLE demand."VRMs"
    ADD COLUMN IF NOT EXISTS "VRM_Orig" character varying(12);

UPDATE demand."VRMs" AS v
SET "VRM_Orig" = v."VRM"
WHERE "VRM_Orig" IS NULL
;

/***
-- For specific area ...
UPDATE demand."VRMs" AS v
SET "VRM_Orig" = v."VRM"
FROM 
(SELECT s."GeometryID", sa."SurveyAreaName"
 FROM mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" sa
 WHERE s."SurveyAreaID" = sa."Code") AS p
WHERE "VRM_Orig" IS NULL
AND v."GeometryID" = p."GeometryID"
AND (p."SurveyAreaName" LIKE 'E-0%' OR
     p."SurveyAreaName" LIKE 'E-0%'
     )
;
***/