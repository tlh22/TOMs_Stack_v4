/***

Queries:
 - Number of restrictions affected by a suspension
 - Details of all suspensions

***/

--- Totals

SELECT DISTINCT (ris."GeometryID")
FROM demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
WHERE ris."GeometryID" = s."GeometryID"
AND COALESCE("NrBaysSuspended", 0) > 0
AND s."RestrictionTypeID" < 200

-- Total by time period

SELECT p."SurveyID", su."BeatTitle", p."NrBaysSuspended"
FROM demand."Surveys" su,
(SELECT ris."SurveyID", SUM("NrBaysSuspended") AS "NrBaysSuspended"
FROM demand."RestrictionsInSurveys" ris, mhtc_operations."Supply" s
WHERE ris."GeometryID" = s."GeometryID"
AND COALESCE("NrBaysSuspended", 0) > 0
AND s."RestrictionTypeID" < 200
GROUP BY ris."SurveyID") p
WHERE su."SurveyID" = p."SurveyID"
ORDER BY su."SurveyID"

-- Details

SELECT ris."GeometryID", ris."SurveyID", su."BeatTitle", s."RoadName", s."Description" AS "RestrictionType Description",
	   ris."SuspensionReference", ris."SuspensionReason", ris."SuspensionLength", ris."NrBaysSuspended", ris."SuspensionNotes"
FROM demand."RestrictionsInSurveys" ris, ( mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") s, 
 demand."Surveys" su
WHERE ris."GeometryID" = s."GeometryID"
AND COALESCE("NrBaysSuspended", 0) > 0
AND s."RestrictionTypeID" < 200
AND ris."SurveyID" = su."SurveyID"
ORDER BY s."RoadName", ris."NrBaysSuspended"