/**

-- check for vehicles that have not been removed with the same survey area

**/

SELECT DISTINCT v1."VRM", v1."SurveyID", date_trunc('day', v1."DemandSurveyDateTime")
FROM (SELECT v."ID", v."VRM", v."SurveyID", v."GeometryID", "SurveyAreaID", ris."DemandSurveyDateTime"
	  FROM demand."VRMs" v, demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
	  WHERE v."GeometryID" = s."GeometryID"
	  AND v."GeometryID" = ris."GeometryID"
	  AND v."SurveyID" = ris."SurveyID"
	 ) as v1,
	 (SELECT v."ID", v."VRM", v."SurveyID", v."GeometryID", "SurveyAreaID", ris."DemandSurveyDateTime"
	  FROM demand."VRMs" v, demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
	  WHERE v."GeometryID" = s."GeometryID"
	  AND v."GeometryID" = ris."GeometryID"
	  AND v."SurveyID" = ris."SurveyID"
	 ) as v2
WHERE v1."VRM" = v2."VRM"
AND v1."ID" < v2."ID"
AND v1."SurveyID" = v2."SurveyID"
AND v1."SurveyAreaID" = v2."SurveyAreaID"
AND date_trunc('day', v1."DemandSurveyDateTime") = date_trunc('day', v2."DemandSurveyDateTime")