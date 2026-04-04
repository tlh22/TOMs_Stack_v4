
-- Make sure capacities are updated

UPDATE "mhtc_operations"."Supply"
SET "RestrictionLength" = ROUND(ST_Length (geom)::numeric,2);

--


/*** Southwark areas  ***/

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
COALESCE("SouthwarkProposedDeliveryZones"."zonename", '')  AS "SurveyAreaName",

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
            END AS "ParkingAvailableDuringSurveyHours", "CPZ"

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
	 LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON a."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid")
WHERE COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('I')
ORDER BY "RestrictionTypeID", "GeometryID"

/***

-- restrictionPolygon areas


UPDATE toms."RestrictionPolygons" AS p
SET "RoadName" = r.name1
FROM highways_network."roadlink" r
WHERE ST_Intersects (p.geom, r.geom)
;

UPDATE toms."RestrictionPolygons" AS p
SET "CPZ" = r."CPZ"
FROM toms."ControlledParkingZones" r
WHERE ST_Intersects (p.geom, r.geom)
;

SELECT "GeometryID", "RoadName", "CPZ"
FROM toms."RestrictionPolygons" p
	 LEFT JOIN import_geojson."SouthwarkProposedDeliveryZones" AS "SouthwarkProposedDeliveryZones" ON p."SouthwarkProposedDeliveryZoneID" is not distinct from "SouthwarkProposedDeliveryZones"."ogc_fid"
WHERE COALESCE("SouthwarkProposedDeliveryZones"."zonename", '') IN ('J')
ORDER BY "RoadName"


***/