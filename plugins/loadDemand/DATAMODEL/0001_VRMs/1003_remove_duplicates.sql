/**

--Remove records that are the same, i.e., same VRM within same GeometryID within same beat

SELECT v1.*
FROM demand."VRMs" v1, demand."VRMs" v2
WHERE v1."VRM" = v2."VRM"
AND v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" = v2."SurveyID"
AND v1."ID" < v2."ID";

**/

DELETE FROM demand."VRMs" AS v1
 USING demand."VRMs" v2, mhtc_operations."Supply" s
WHERE v1."VRM" = v2."VRM"
AND v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" = v2."SurveyID"
AND v1."ID" < v2."ID"
AND v1."GeometryID" = s."GeometryID"
AND v1."VRM" NOT IN ('COVE-RED', 'DK-', 'SYL-', 'SKIP-', 'TRAI-LER', 'NOP-LATE', 'NOPL-ATES')
--AND s."CPZ" IN ('P', 'F', 'Y')
;

/***
DELETE FROM demand."VRMs" AS v1
 USING demand."VRMs" v2,(SELECT s."GeometryID", sa."SurveyAreaName"
 FROM mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" sa
 WHERE s."SurveyAreaID" = sa."Code") AS p
WHERE v1."VRM" = v2."VRM"
AND v1."GeometryID" = v2."GeometryID"
AND v1."SurveyID" = v2."SurveyID"
AND v1."ID" < v2."ID"
AND v1."GeometryID" = p."GeometryID"
AND (p."SurveyAreaName" LIKE 'L%' OR
     p."SurveyAreaName" LIKE 'E-0%' OR
     p."SurveyAreaName" LIKE 'P%' OR
     p."SurveyAreaName" LIKE 'T%' OR
     p."SurveyAreaName" LIKE 'V%'
     )
;
***/

-- Remove blanks

DELETE FROM demand."VRMs" AS v
USING mhtc_operations."Supply" s
WHERE ("VRM" = '-' OR "VRM" IS NULL)
AND ("VehicleTypeID" IS NULL OR "VehicleTypeID" = 0)
AND ("PermitTypeID" IS NULL OR "PermitTypeID" = 0)
AND ("InternationalCodeID" IS NULL OR "InternationalCodeID" = 0)
AND (v."Notes" IS NULL OR LENGTH(TRIM(v."Notes")) = 0)
AND v."GeometryID" = s."GeometryID"
--AND s."CPZ" IN ('P', 'F', 'Y')
;

/***
DELETE FROM demand."VRMs" AS v
USING 
(SELECT s."GeometryID", sa."SurveyAreaName"
 FROM mhtc_operations."Supply" s, mhtc_operations."SurveyAreas" sa
 WHERE s."SurveyAreaID" = sa."Code") AS p
WHERE ("VRM" = '-' OR "VRM" IS NULL)
AND ("VehicleTypeID" IS NULL OR "VehicleTypeID" = 0)
AND ("PermitTypeID" IS NULL OR "PermitTypeID" = 0)
AND ("InternationalCodeID" IS NULL OR "InternationalCodeID" = 0)
AND (v."Notes" IS NULL OR LENGTH(TRIM(v."Notes")) = 0)
AND v."GeometryID" = p."GeometryID"
AND (p."SurveyAreaName" LIKE 'L%' OR
     p."SurveyAreaName" LIKE 'E-0%' OR
     p."SurveyAreaName" LIKE 'P%' OR
     p."SurveyAreaName" LIKE 'T%' OR
     p."SurveyAreaName" LIKE 'V%'
     )
;
***/