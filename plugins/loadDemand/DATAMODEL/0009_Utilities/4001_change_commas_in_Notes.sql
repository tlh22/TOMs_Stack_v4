/***

If there are commas in the Notes field, change them to full stops.

NB: there may be other characters that need changing

SELECT "Notes", REGEXP_REPLACE("Notes",',','.', 'g') 
FROM demand."Counts"
WHERE "Notes" LIKE '%,%'

**/

UPDATE demand."Counts"
SET "Notes" = REGEXP_REPLACE("Notes",',','.', 'g') 
WHERE "Notes" LIKE '%,%';

UPDATE demand."Counts"
SET "Notes" = regexp_replace("Notes", E'[\\n\\r]+', '; ', 'g' )
WHERE "Notes" LIKE E'%\n%';

UPDATE demand."RestrictionsInSurveys"
SET "SuspensionReason" = REGEXP_REPLACE("SuspensionReason",',','.', 'g') 
WHERE "SuspensionReason" LIKE '%,%';

UPDATE demand."RestrictionsInSurveys"
SET "SuspensionReason" = regexp_replace("SuspensionReason", E'[\\n\\r]+', '; ', 'g' )
WHERE "SuspensionReason" LIKE E'%\n%';

UPDATE demand."RestrictionsInSurveys"
SET "Enumerator" = regexp_replace("Enumerator", E'[\\n\\r]+', '; ', 'g' )
WHERE "Enumerator" LIKE E'%\n%';

UPDATE demand."RestrictionsInSurveys"
SET "Enumerator" = REGEXP_REPLACE("Enumerator",',','.', 'g') 
WHERE "Enumerator" LIKE '%,%';