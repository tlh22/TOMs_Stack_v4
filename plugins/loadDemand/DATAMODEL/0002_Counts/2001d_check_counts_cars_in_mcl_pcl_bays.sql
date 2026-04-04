-- Find obvious errors

-- Check for cars in MCL/PCL bays
SELECT RiS."GeometryID", RiS."SurveyID", c."NrCars"
FROM demand."RestrictionsInSurveys" RiS, demand."Counts" c, mhtc_operations."Supply" s
WHERE s."GeometryID" = RiS."GeometryID"
AND RiS."GeometryID" = c."GeometryID"
AND RiS."SurveyID" = c."SurveyID"
AND s."RestrictionTypeID" IN (117, 118, 119, 168, 169)
AND COALESCE(c."NrCars", 0) > 0
ORDER BY "GeometryID", "SurveyID";
