/***
 *
 * Ensure only active suspensions are shown. Need to check and go through RiS
 *
 ***/

/*** 
SELECT sus.*
FROM demand."ActiveSuspensions" AS sus --, demand."RestrictionsInSurveys" ris
--DELETE FROM demand."ActiveSuspensions" AS sus
--USING demand."RestrictionsInSurveys" ris
WHERE EXISTS (SELECT 1
			  FROM demand."RestrictionsInSurveys" ris
			  WHERE sus."GeometryID" = ris."GeometryID"
			  AND sus."SurveyID" = ris."SurveyID"
			  AND ris."NrBaysSuspended" > 0
			  )

SELECT sus.*
FROM demand."ActiveSuspensions" AS sus --, demand."RestrictionsInSurveys" ris
--DELETE FROM demand."ActiveSuspensions" AS sus
--USING demand."RestrictionsInSurveys" ris
WHERE NOT EXISTS (SELECT 1
				  FROM demand."RestrictionsInSurveys" ris
				  WHERE sus."GeometryID" = ris."GeometryID"
				  AND sus."SurveyID" = ris."SurveyID"
				  AND ris."NrBaysSuspended" > 0
				  )
				  
***/
			  
DELETE FROM demand."ActiveSuspensions" AS sus
WHERE NOT EXISTS (SELECT 1
				  FROM demand."RestrictionsInSurveys" ris
				  WHERE sus."GeometryID" = ris."GeometryID"
				  AND sus."SurveyID" = ris."SurveyID"
				  AND ris."NrBaysSuspended" > 0
				  )

