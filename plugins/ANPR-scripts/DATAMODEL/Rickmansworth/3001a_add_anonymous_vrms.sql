/***
 * Set up table with new ananomised ids for each VRM
 ***/


--
 
INSERT INTO anpr."Anonomise_VRMs" ("VRM")
SELECT DISTINCT "VRM"
FROM anpr."VRMs"
WHERE "VRM" NOT IN (SELECT "VRM" FROM anpr."Anonomise_VRMs")
ORDER BY "VRM";

--

ALTER TABLE anpr."VRMs"
    ADD COLUMN IF NOT EXISTS "AnonomisedVRM" character varying(12);

--

UPDATE anpr."VRMs" AS v
SET "AnonomisedVRM" = a."NewID"
FROM anpr."Anonomise_VRMs" a
WHERE v."VRM" = a."VRM"
AND v."AnonomisedVRM" IS NULL;