/***
 Add dash after 4th CHARACTER

SELECT "VRM", CONCAT(LEFT("VRM", 4), '-', RIGHT("VRM", -4))
FROM anpr."VRMs"

 ***/
 
 
ALTER TABLE anpr."VRMs"
    ADD COLUMN IF NOT EXISTS "VRM_Orig" character varying(12);

ALTER TABLE anpr."VRMs"
    ADD COLUMN IF NOT EXISTS "VRM_Extracted" character varying(12);

UPDATE anpr."VRMs" AS v
SET "VRM_Extracted" = v."VRM"
WHERE "VRM_Orig" IS NULL;

UPDATE anpr."VRMs"
SET "VRM" = CONCAT(LEFT("VRM", 4), '-', RIGHT("VRM", -4))
WHERE UPPER("VRM") != 'UNKNOWN'
AND "VRM_Orig" IS NULL;

UPDATE anpr."VRMs" AS v
SET "VRM_Orig" = v."VRM"
WHERE "VRM_Orig" IS NULL
;