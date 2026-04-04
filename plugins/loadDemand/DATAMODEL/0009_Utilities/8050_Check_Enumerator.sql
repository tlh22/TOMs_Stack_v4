/***

***/

SELECT s."SurveyID", s."BeatTitle", COUNT("VRM") AS "Count",  MIN ("DemandSurveyDateTime") AS "Start", MAX("DemandSurveyDateTime") AS "End", MAX("DemandSurveyDateTime") - MIN("DemandSurveyDateTime") AS "Duration"
FROm demand."RestrictionsInSurveys" RiS, demand."Surveys" s, demand."VRMs" v
WHERE RiS."SurveyID" = s."SurveyID"
AND RiS."SurveyID" = v."SurveyID"
AND RiS."GeometryID" = v."GeometryID"
AND LENGTH("VRM") > 0
AND RiS."Enumerator" In ('Manying' ,  'manying' ,  'MANYINGQI')
GROUP BY s."SurveyID"
ORDER BY s."SurveyID"