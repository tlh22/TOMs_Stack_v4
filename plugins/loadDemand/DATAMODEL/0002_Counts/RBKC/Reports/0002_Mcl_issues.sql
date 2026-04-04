
ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN "MCL_Notes" character varying(10000);

ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN "Supply_Notes" character varying(10000);

ALTER TABLE IF EXISTS demand."Counts"
    ADD COLUMN "Parking_Notes" character varying(10000);

/***
 * Output details of MCL bays with chains / broken anchors
 ***/

 SELECT
"GeometryID", a."SurveyID", "BeatTitle", "RestrictionTypeID",
"BayLineTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",
a."RoadName", COALESCE("SurveyAreas"."SurveyAreaName", '')  AS "SurveyAreaName",
 COALESCE("TimePeriods1"."Description", '')  AS "DetailsOfControl",
"RestrictionLength" AS "KerblineLength", "Capacity" AS "TheoreticalBays",
"MCL_Notes", "Photos_01"

FROM
     ((((((
     --(
     (SELECT s."GeometryID", ris."SurveyID", s."RestrictionTypeID", s."GeomShapeID", s."TimePeriodID", s."RoadName", s."RestrictionLength",
	        s."NrBays", s."Capacity", s."CPZ", s."SurveyAreaID", ris."Photos_01", ris."MCL_Notes"
        FROM mhtc_operations."Supply" s, demand."RestrictionsInSurveys" ris
        WHERE s."RestrictionTypeID" IN (117, 118)
		AND s."GeometryID" = ris."GeometryID"
	    AND LENGTH("MCL_Notes") > 0
	  )
	 ) AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
	 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
     LEFT JOIN "demand"."Surveys" AS "Surveys" ON a."SurveyID" is not distinct from "Surveys"."SurveyID")
	 
ORDER BY  "RoadName", "SurveyID", "GeometryID"

-- Would be good to output photos with labels??

-- separate out "general" photos from one relating to suspensions

SELECT CONCAT('copy ', RiS."Photos_01", ' "../MCL_Photos/', su."RoadName", '_', s."BeatTitle", '_', RiS."Photos_01", '"')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" s, mhtc_operations."Supply" su
WHERE RiS."Photos_01" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND su."GeometryID" = RiS."GeometryID"
AND LENGTH(RiS."MCL_Notes") > 0

UNION

SELECT CONCAT('copy ', RiS."Photos_02", ' "../MCL_Photos/', su."RoadName", '_', s."BeatTitle", '_', RiS."Photos_02", '"')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" s, mhtc_operations."Supply" su
WHERE RiS."Photos_02" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND su."GeometryID" = RiS."GeometryID"
AND LENGTH(RiS."MCL_Notes") > 0

UNION

SELECT CONCAT('copy ', RiS."Photos_03", ' "../MCL_Photos/', su."RoadName", '_', s."BeatTitle", '_', RiS."Photos_03", '"')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" s, mhtc_operations."Supply" su
WHERE RiS."Photos_03" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND su."GeometryID" = RiS."GeometryID"
AND LENGTH(RiS."MCL_Notes") > 0

