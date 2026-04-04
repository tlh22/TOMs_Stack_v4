/***
 * Capacity and Stress in RiS
 ***/

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "Capacity" INTEGER;

UPDATE demand."RestrictionsInSurveys" RiS
SET "Capacity" =
     CASE WHEN (s."Capacity" - COALESCE(RiS."NrBaysSuspended", 0)) > 0 THEN (s."Capacity" - COALESCE(RiS."NrBaysSuspended", 0))
         ELSE 0
         END
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";

-- Demand

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "Demand" FLOAT;

UPDATE demand."RestrictionsInSurveys" RiS
SET "Demand" = v."Demand"
FROM
(SELECT a."SurveyID", a."GeometryID", SUM("VehicleTypes"."PCU") AS "Demand"
        FROM (demand."VRMs_Final" AS a
        LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
        GROUP BY a."SurveyID", a."GeometryID"
  ) AS v
WHERE RiS."GeometryID" = v."GeometryID"
AND RiS."SurveyID" = v."SurveyID";

-- Stress

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN "Stress" FLOAT;

UPDATE demand."RestrictionsInSurveys" RiS
SET "Stress" =
    CASE
        WHEN "Capacity" = 0 THEN
            CASE
                WHEN COALESCE("Demand", 0) > 0.0 THEN 100.0
                ELSE 0.0
            END
        ELSE
            COALESCE("Demand", 0) / "Capacity"::float * 100.0
    END;