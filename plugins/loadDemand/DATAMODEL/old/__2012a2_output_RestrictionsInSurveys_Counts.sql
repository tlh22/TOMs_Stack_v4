/*

Need to change for each CPZ - and ensure correct Supply details

*/

SELECT d."SurveyID", d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description",
d."DetailsOfControl",
d."RoadName", d."SideOfStreet",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03",
d."RestrictionLength", d."Capacity", d."AvailableSpaces", v."Demand", v."NrSpaces",
CASE WHEN d."AvailableSpaces" = 0 THEN
        CASE WHEN v."Demand" > 0 THEN 1.0
        ELSE 0.0
        END
     ELSE v."Demand"/d."AvailableSpaces"
     END AS "Stress",
regexp_replace(v."Notes", '(.*?)(?<=<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">)(.*?)(?=<\/p>)', '\2', 'g')  AS "Notes",
"SurveyAreaName",
        "NrCars", "NrLGVs", "NrMCLs", "NrTaxis", "NrPCLs", "NrEScooters", "NrDocklessPCLs", "NrOGVs", "NrMiniBuses", "NrBuses",
        "NrSpaces", "Notes", "DoubleParkingDetails",
        "NrCars_Suspended", "NrLGVs_Suspended", "NrMCLs_Suspended", "NrTaxis_Suspended", "NrPCLs_Suspended", "NrEScooters_Suspended",
        "NrDocklessPCLs_Suspended", "NrOGVs_Suspended", "NrMiniBuses_Suspended", "NrBuses_Suspended",
        "NrCarsIdling", "NrCarsParkedIncorrectly", "NrLGVsIdling", "NrLGVsParkedIncorrectly", "NrMCLsIdling", "NrMCLsParkedIncorrectly",
        "NrTaxisIdling", "NrTaxisParkedIncorrectly", "NrOGVsIdling", "NrOGVsParkedIncorrectly", "NrMiniBusesIdling", "NrMiniBusesParkedIncorrectly",
        "NrBusesIdling", "NrBusesParkedIncorrectly", "NrCarsWithDisabledBadgeParkedInPandD"
FROM
(SELECT ris."SurveyID", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", su."BeatTitle", ris."GeometryID", a."RestrictionTypeID", "BayLineTypes"."Description" AS "RestrictionType Description",
       CASE WHEN ("RestrictionTypeID" < 200 OR "RestrictionTypeID" IN (227, 228, 229, 231)) THEN COALESCE("TimePeriods1"."Description", '')
            ELSE COALESCE("TimePeriods2"."Description", '')
            END  AS "DetailsOfControl",
a."RoadName", a."SideOfStreet", a."RestrictionLength",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", a."Capacity",
     CASE WHEN (a."Capacity" - COALESCE(ris."NrBaysSuspended", 0)) > 0 THEN (a."Capacity" - COALESCE(ris."NrBaysSuspended", 0))
         ELSE 0
         END AS "AvailableSpaces",
"SurveyAreas"."SurveyAreaName", ris.geom
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su,
((((mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
 LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoWaitingTimeID" is not distinct from "TimePeriods2"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = a."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID",
        "NrCars", "NrLGVs", "NrMCLs", "NrTaxis", "NrPCLs", "NrEScooters", "NrDocklessPCLs", "NrOGVs", "NrMiniBuses", "NrBuses",
        "NrSpaces", "Notes", "DoubleParkingDetails",
        "NrCars_Suspended", "NrLGVs_Suspended", "NrMCLs_Suspended", "NrTaxis_Suspended", "NrPCLs_Suspended", "NrEScooters_Suspended",
        "NrDocklessPCLs_Suspended", "NrOGVs_Suspended", "NrMiniBuses_Suspended", "NrBuses_Suspended",
        "NrCarsIdling", "NrCarsParkedIncorrectly", "NrLGVsIdling", "NrLGVsParkedIncorrectly", "NrMCLsIdling", "NrMCLsParkedIncorrectly",
        "NrTaxisIdling", "NrTaxisParkedIncorrectly", "NrOGVsIdling", "NrOGVsParkedIncorrectly", "NrMiniBusesIdling", "NrMiniBusesParkedIncorrectly",
        "NrBusesIdling", "NrBusesParkedIncorrectly", "NrCarsWithDisabledBadgeParkedInPandD",

        COALESCE("NrCars"::float, 0.0) +
        COALESCE("NrLGVs"::float, 0.0) +
        COALESCE("NrMCLs"::float, 0.0)*0.2 +
        (COALESCE("NrOGVs"::float, 0.0) + COALESCE("NrMiniBuses"::float, 0.0) + COALESCE("NrBuses"::float, 0.0))*1.5 +
        COALESCE("NrTaxis"::float, 0.0) +
        (COALESCE("NrPCLs"::float, 0.0) + COALESCE("NrEScooters"::float, 0.0) + COALESCE("NrDocklessPCLs"::float, 0.0))*0.1
        +
        COALESCE("NrCarsIdling"::float, 0.0) + COALESCE("NrCarsParkedIncorrectly"::float, 0.0) +
        COALESCE("NrLGVsIdling"::float, 0.0) + COALESCE("NrLGVsParkedIncorrectly"::float, 0.0) +
        COALESCE("NrMCLsIdling"::float, 0.0)*0.2 + COALESCE("NrMCLsIdling"::float, 0.0)*0.2 +
        (COALESCE("NrOGVsIdling"::float, 0.0) + COALESCE("NrOGVsParkedIncorrectly"::float, 0.0) +
        COALESCE("NrMiniBusesIdling"::float, 0.0) + COALESCE("NrMiniBusesParkedIncorrectly"::float, 0.0) +
        COALESCE("NrBusesIdling"::float, 0.0)*1.5 + COALESCE("NrBusesParkedIncorrectly"::float, 0.0))*1.5 +
        COALESCE("NrTaxisIdling"::float, 0.0) + COALESCE("NrTaxisParkedIncorrectly"::float, 0.0) +
        COALESCE("NrCarsWithDisabledBadgeParkedInPandD"::float, 0.0)
         AS "Demand"

   FROM demand."Counts"
   --GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"
WHERE d."SurveyID" > 0
AND d."Done" IS true
ORDER BY d."SurveyID", d."GeometryID";


-- check total count for each pass


SELECT d."SurveyID", d."BeatTitle", SUM(d."NrBaysSuspended") AS "NrBaysSuspended", SUM(d."Capacity") AS "Capacity", SUM(v."Demand") As "Demand"
FROM
(SELECT ris."SurveyID", su."BeatTitle", s."GeometryID", ris."NrBaysSuspended", s."Capacity"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su, mhtc_operations."Supply" s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

 LEFT JOIN  (SELECT "SurveyID", "GeometryID",
   SUM(CASE WHEN "VehicleTypeID" = 1 or "VehicleTypeID" = 2 or "VehicleTypeID" = 7 THEN 1.0  -- Car, LGV or Taxi
            WHEN "VehicleTypeID" = 3 THEN 0.4  -- MCL
            WHEN "VehicleTypeID" = 4 THEN 1.5  -- OGV
            WHEN "VehicleTypeID" = 5 THEN 2.0  -- Bus
            ELSE 1.0  -- Other or Null
      END) AS "Demand"
   FROM demand."VRMs"
   GROUP BY "SurveyID", "GeometryID"
  ) AS v ON d."SurveyID" = v."SurveyID" AND d."GeometryID" = v."GeometryID"
WHERE d."SurveyID" > 0
GROUP BY d."SurveyID", d."BeatTitle"
ORDER BY d."SurveyID";




SELECT "GeometryID", regexp_replace("Notes", '(.*?)(?<=0px;\">)(.*?)(?=</p)', '\3'), "Notes"

SELECT "GeometryID", regexp_replace("Notes", '(.*?)(?<=<p)(.*?)>(.*?)', '\2'), "Notes"

SELECT "GeometryID", "Notes", regexp_replace("Notes", '[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">
<html><head><meta name="qrichtext" content="1" /><style type="text/css">
p, li { white-space: pre-wrap; }
</style></head><body style=" font-family:''MS Shell Dlg 2''; font-size:11pt; font-weight:400; font-style:normal;">
<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">w</p></body></html>](.*)', '\1')
FROM demand."Counts"
WHERE "Notes" IS NOT NULL;


UPDATE mhtc_operations."Supply"
SET "NrBays" = -2
FROM demand."Counts" c
WHERE c."Notes" IS NOT NULL
AND c."Notes" LIKE '%perp%';