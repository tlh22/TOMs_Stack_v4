

-- Update RiS

UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "Done" = true, "Enumerator" = 'MASTER', "DemandSurveyDateTime" = now()
FROM
    (
        SELECT DISTINCT RiS2."SurveyID", RiS2."GeometryID" --, RiS."Done"
        FROM demand."RestrictionsInSurveys_Final" RiS2, demand."VRMs_Final" v
        WHERE RiS2."SurveyID" = v."SurveyID"
        AND RiS2."GeometryID" = v."GeometryID"
        AND RiS2."Done" IS NOT True
     ) AS t
WHERE RiS."SurveyID" = t."SurveyID"
AND RiS."GeometryID" = t."GeometryID";