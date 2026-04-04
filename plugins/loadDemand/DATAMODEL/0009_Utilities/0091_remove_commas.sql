/***

Ensure that there are no commas in string

***/

UPDATE demand."VRMs"
SET "Notes" = replace("Notes", ',', '.')
WHERE "SuspensionReason" LIKE '%,%';

UPDATE demand."Counts"
SET "Notes" = replace("Notes", ',', '.')
WHERE "Notes" LIKE '%,%';

UPDATE demand."RestrictionsInSurveys"
SET "SuspensionReason" = replace("SuspensionReason", ',', '.')
WHERE "SuspensionReason" LIKE '%,%';

