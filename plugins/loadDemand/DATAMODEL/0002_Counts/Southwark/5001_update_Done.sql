/***

Set "Done" to ensure there is no over-writting

***/

UPDATE demand."RestrictionsInSurveys"
SET "Done" = 'true'
--SELECT "GeometryID", "Done"
--FROM demand."RestrictionsInSurveys" RiS
WHERE "Demand" > 0
AND ("Done" = 'false' OR "Done" IS NULL)