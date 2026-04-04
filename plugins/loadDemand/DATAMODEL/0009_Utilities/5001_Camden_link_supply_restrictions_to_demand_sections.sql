/***
 *
 * To link demand to supply
 
 ***/
 
 ALTER TABLE IF EXISTS mhtc_operations."Supply"
    ADD COLUMN IF NOT EXISTS "Demand_GeometryID" character varying(12);
	
UPDATE mhtc_operations."Supply" AS c
SET "Demand_GeometryID" = NULL;

-- set details

UPDATE mhtc_operations."Supply" AS c
SET "Demand_GeometryID" = closest."Demand_GeometryID"
FROM (SELECT DISTINCT ON (s."GeometryID") s."GeometryID" AS id, c1."GeometryID" AS "Demand_GeometryID",
        --ST_ClosestPoint(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS geom,
        ST_Distance(c1.geom, ST_LineInterpolatePoint(s.geom, 0.5)) AS length
      FROM mhtc_operations."Supply" s, mhtc_operations."SupplyForDemand" c1
      WHERE ST_DWithin(c1.geom, s.geom, 2.0)
      ORDER BY s."GeometryID", length) AS closest
WHERE c."GeometryID" = closest.id
AND c."Demand_GeometryID" IS NULL
;

-- NOW output Supply
-- Make sure capacities are updated

UPDATE "mhtc_operations"."Supply"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);

--

SELECT
"GeometryID",
        CASE WHEN "RestrictionTypeID" = 225 THEN
                 CASE
                    WHEN "UnacceptableTypeID" IS NOT NULL THEN 220
                    ELSE 216
                 END
                 WHEN "RestrictionTypeID" = 224 THEN
                 CASE
                    WHEN "UnacceptableTypeID" IS NOT NULL THEN 221
                    ELSE 201
                 END
             ELSE "RestrictionTypeID"
        END AS "RestrictionTypeID",
"BayLineTypes"."Description" AS "RestrictionDescription",
"GeomShapeID", COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "Restriction Shape Description",
a."RoadName", a."StartStreet" AS "RoadFrom", a."EndStreet" AS "RoadTo", a."SideOfStreet", "RC_Sections_merged"."SectionName", 
COALESCE("SurveyAreas"."SurveyAreaName", '')  AS "SurveyAreaName",

       CASE WHEN ("RestrictionTypeID" < 200 OR "RestrictionTypeID" IN (227, 228, 229, 231)) THEN COALESCE("TimePeriods1"."Description", '')
            ELSE COALESCE("TimePeriods2"."Description", '')
            END  AS "DetailsOfControl",
       COALESCE("UnacceptableTypes"."Description", '') AS "UnacceptabilityReason",
       "RestrictionLength" AS "KerblineLength",
       "NrBays" AS "MarkedBays", "Capacity" AS "TheoreticalBays",

       CASE WHEN "RestrictionTypeID" IN (122, 162, 107, 161, 202, 218, 220, 221, 222, 209, 210, 211, 212, 213, 214, 215) THEN 0
            --WHEN "RestrictionTypeID" IN (201, 217) THEN
                --CASE WHEN "Allowable" IS NULL THEN "Capacity"
                     --ELSE 0
                     --END
            ELSE
                "Capacity"
            END AS "ParkingAvailableDuringSurveyHours", "CPZ", "Demand_GeometryID" AS "DemandSection"

FROM
     (((((((
     --(
     (SELECT CASE WHEN "RestrictionTypeID" = 225 THEN
                 CASE
                    WHEN "UnacceptableTypeID" IS NOT NULL THEN 220
                    ELSE 216
                 END
                 WHEN "RestrictionTypeID" = 224 THEN
                 CASE
                    WHEN "UnacceptableTypeID" IS NOT NULL THEN 221
                    ELSE 201
                 END
             ELSE "RestrictionTypeID"
        END AS "RestrictionTypeID_Amended", *
        FROM mhtc_operations."Supply"
	 	--WHERE "CPZ" IN ('P', 'F', 'Y')
	 ) AS a
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID_Amended" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code")
     LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoWaitingTimeID" is not distinct from "TimePeriods2"."Code")
	 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
	 LEFT JOIN "mhtc_operations"."RC_Sections_merged" AS "RC_Sections_merged" ON a."SectionID" is not distinct from "RC_Sections_merged"."gid")
	 --LEFT JOIN "demand_lookups"."UserTypes" AS "UserTypes" ON a."UserTypeID" is not distinct from "UserTypes"."Code")
	 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")

ORDER BY "RestrictionTypeID", "GeometryID"
