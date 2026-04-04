/***
 Check for missed pass 
***/

SELECT RiS1."SurveyID", RiS2."SurveyID", RiS1."Demand", s."RoadName", RiS1."GeometryID"
FROM demand."RestrictionsInSurveys" RiS1, demand."RestrictionsInSurveys" RiS2, mhtc_operations."Supply" s
WHERE RiS1."GeometryID" = RiS2."GeometryID"
AND RiS1."GeometryID" = s."GeometryID"
AND RiS2."SurveyID" = RiS1."SurveyID" + 1
AND RiS2."Demand" = 0
AND RiS1."Demand" > 3
AND RiS1."SurveyID" < 400
ORDER BY RiS1."SurveyID", s."RoadName"
