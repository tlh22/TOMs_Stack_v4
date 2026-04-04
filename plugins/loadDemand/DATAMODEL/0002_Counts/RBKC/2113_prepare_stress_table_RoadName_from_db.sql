-- Now prepare stress details - with comparison to 2018

DROP MATERIALIZED VIEW IF EXISTS demand."StressResults_ByRoadName";

CREATE MATERIALIZED VIEW demand."StressResults_ByRoadName"
TABLESPACE pg_default
AS
    SELECT
        row_number() OVER (PARTITION BY true::boolean) AS sid,
    r1."RoadName", r.geom,
    r1."SurveyID", r1."BeatTitle", d."Capacity" As "Capacity_All_2022", d."CapacityAtTimeOfSurvey" AS  "CapacityAtTimeOfSurvey_All_2022", 
	d."Demand" AS "Demand_All_2022", d."Stress" AS "Stress_All_2022",
    d."Residents Bay Capacity" AS "Capacity_ResidentBays_2022", d."Residents Bay CapacityAtTimeOfSurvey" AS "CapacityAtTimeOfSurvey_ResidentBays_2022",
	d."Residents Bay Demand" AS "Demand_ResidentBays_2022", d."Residents Bay Stress" AS "Stress_ResidentBays_2018",
    d."Residents Bay PerceivedCapacityAtTimeOfSurvey", d."Residents Bay PerceivedStress",
    d."PayByPhone Bay Capacity" AS "Capacity_PayByPhone_2022", 
	d."PayByPhone Bay CapacityAtTimeOfSurvey" As "CapacityAtTimeOfSurvey_PayByPhone_2022",
	d."PayByPhone Bay Demand" AS "Demand_PayByPhone_2022", d."PayByPhone Bay Stress",
    e."Capacity_All_2018", e."CapacityAtTimeOfSurvey_All_2018", "Demand_All_2018", e."Stress_All_2018",
	e."Capacity_ResidentBays_2018", e."CapacityAtTimeOfSurvey_ResidentBays_2018", e."Demand_ResidentBays_2018",
    e."Capacity_PayByPhone_2018", e."CapacityAtTimeOfSurvey_PayByPhone_2018", e."Demand_PayByPhone_2018"
	FROM highways_network."roadlink" r,
	(
	(SELECT DISTINCT "roadname1_name" AS "RoadName", "SurveyID", "BeatTitle"
	FROM highways_network."roadlink", demand."Surveys"
	WHERE "SurveyID" > 0
	AND ("Private" IS false OR "Private" IS NULL)) r1 LEFT JOIN
	
	(
	SELECT a."SurveyID", --su."BeatTitle", 
		"RoadName", "Capacity", "CapacityAtTimeOfSurvey", "Demand",
        CASE
            WHEN "CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Demand" / ("CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress",
        "Residents Bay Capacity", "Residents Bay CapacityAtTimeOfSurvey", "Residents Bay Demand",
        CASE
            WHEN "Residents Bay CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Residents Bay CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Residents Bay Demand" / ("Residents Bay CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Residents Bay Stress",

--
        "Residents Bay PerceivedCapacityAtTimeOfSurvey", 
        CASE
            WHEN "Residents Bay PerceivedCapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Residents Bay PerceivedCapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "Residents Bay Demand" / ("Residents Bay PerceivedCapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "Residents Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Residents Bay PerceivedStress",

--

        "PayByPhone Bay Capacity", "PayByPhone Bay CapacityAtTimeOfSurvey", "PayByPhone Bay Demand",
        CASE
            WHEN "PayByPhone Bay CapacityAtTimeOfSurvey" = 0 THEN
                CASE
                    WHEN "PayByPhone Bay Demand" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "PayByPhone Bay CapacityAtTimeOfSurvey"::float > 0.0 THEN
                        "PayByPhone Bay Demand" / ("PayByPhone Bay CapacityAtTimeOfSurvey"::float)
                    ELSE
                        CASE
                            WHEN "PayByPhone Bay Demand" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "PayByPhone Bay Stress"
    FROM (
    SELECT "SurveyID", s."RoadName", 
		SUM(CASE WHEN "RestrictionTypeID" IN (107, 116, 117, 118, 119, 122, 144, 146, 147, 149, 150, 151, 168, 169, 201, 216, 217, 224, 225, 226) THEN 0 ELSE RiS."SupplyCapacity" END) AS "Capacity", 
		SUM(CASE WHEN "RestrictionTypeID" IN (107, 116, 117, 118, 119, 122, 144, 146, 147, 149, 150, 151, 168, 169, 201, 216, 217, 224, 225, 226) THEN 0 ELSE RiS."CapacityAtTimeOfSurvey" END) AS "CapacityAtTimeOfSurvey",
	SUM(RiS."Demand") AS "Demand",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."SupplyCapacity" END) AS "Residents Bay Capacity",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."CapacityAtTimeOfSurvey" END) AS "Residents Bay CapacityAtTimeOfSurvey",
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."PerceivedCapacityAtTimeOfSurvey" END) AS "Residents Bay PerceivedCapacityAtTimeOfSurvey",	
	SUM (CASE WHEN "RestrictionTypeID" != 101 THEN 0 ELSE RiS."Demand" END) AS "Residents Bay Demand",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE RiS."SupplyCapacity" END) AS "PayByPhone Bay Capacity",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE RiS."CapacityAtTimeOfSurvey" END) AS "PayByPhone Bay CapacityAtTimeOfSurvey",
	SUM (CASE WHEN "RestrictionTypeID" != 103 THEN 0 ELSE RiS."Demand" END) AS "PayByPhone Bay Demand"
    FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
    WHERE s."GeometryID" = RiS."GeometryID"
    AND s."RestrictionTypeID" NOT IN (107, 116, 117, 118, 119, 122, 144, 146, 147, 149, 150, 151, 168, 169)  -- MCL, PCL, Scooters, etc
    AND RiS."SurveyID" > 0
    GROUP BY RiS."SurveyID", s."RoadName"
    ORDER BY s."RoadName", RiS."SurveyID" ) a ) d ON d."SurveyID" = r1."SurveyID" AND d."RoadName" = r1."RoadName"
    )
    
	LEFT JOIN
	
    	(
	SELECT "SurveyID", "RoadName", "Capacity_All_2018", "CapacityAtTimeOfSurvey_All_2018", "Demand_All_2018",
        CASE
            WHEN "Capacity_All_2018" = 0 THEN
                CASE
                    WHEN "Demand_All_2018" > 0.0 THEN 1.0
                    ELSE -1.0
                END
            ELSE
                CASE
                    WHEN "Capacity_All_2018"::float > 0.0 THEN
                        "Demand_All_2018" / ("Capacity_All_2018"::float)
                    ELSE
                        CASE
                            WHEN "Demand_All_2018" > 0.0 THEN 1.0
                            ELSE -1.0
                        END
                END
        END "Stress_All_2018",
        "Capacity_ResidentBays_2018", "CapacityAtTimeOfSurvey_ResidentBays_2018", "Demand_ResidentBays_2018",
        "Capacity_PayByPhone_2018", "CapacityAtTimeOfSurvey_PayByPhone_2018", "Demand_PayByPhone_2018"
    FROM (
    SELECT "SurveyID", "RoadName", 
    SUM(
	CASE WHEN "RestrictionGroup" IN ('Bus Stop',  'Bus Stop (Red Route)',  'Bus Stand',  'Bus Stand (Red Route)',
    'Cycle Hire bay',  'Motorcycle Permit Holders bay',  'On-Carriageway Bicycle Bay',  'Solo Motorcycle bay (Visitors)',  -- MCL, PCL, Scooters, etc
	'No Stopping (Acceptable) (SRL)',  'No Stopping At Any Time (DRL)',  'No Waiting (Acceptable) (SYL)',  'No Waiting (Unacceptable) (SYL)',  
	'No Waiting At Any Time (DYL)' ,  'Crossing - Unmarked and no signals') THEN 0 ELSE "ParkingAvailableDuringSurveyHours" END
	) AS "Capacity_All_2018", 
	SUM(
	CASE WHEN "RestrictionGroup" IN ('Bus Stop',  'Bus Stop (Red Route)',  'Bus Stand',  'Bus Stand (Red Route)',
    'Cycle Hire bay',  'Motorcycle Permit Holders bay',  'On-Carriageway Bicycle Bay',  'Solo Motorcycle bay (Visitors)',  -- MCL, PCL, Scooters, etc
	'No Stopping (Acceptable) (SRL)',  'No Stopping At Any Time (DRL)',  'No Waiting (Acceptable) (SYL)',  'No Waiting (Unacceptable) (SYL)',  
	'No Waiting At Any Time (DYL)' ,  'Crossing - Unmarked and no signals') THEN 0 ELSE "AvailableSpacesForParking" END
	) AS "CapacityAtTimeOfSurvey_All_2018", 
	SUM(
	CASE WHEN "RestrictionGroup" IN ('Resident Permit Holder Bay') THEN "ParkingAvailableDuringSurveyHours" ELSE 0 END
	) AS "Capacity_ResidentBays_2018", 
	SUM(
	CASE WHEN "RestrictionGroup" IN ('Pay & Display/Pay by Phone Bay') THEN "ParkingAvailableDuringSurveyHours" ELSE 0 END
	) AS "Capacity_PayByPhone_2018",
		SUM(
	CASE WHEN "RestrictionGroup" IN ('Resident Permit Holder Bay') THEN "AvailableSpacesForParking" ELSE 0 END
	) AS "CapacityAtTimeOfSurvey_ResidentBays_2018", 
	SUM(
	CASE WHEN "RestrictionGroup" IN ('Pay & Display/Pay by Phone Bay') THEN "AvailableSpacesForParking" ELSE 0 END
	) AS "CapacityAtTimeOfSurvey_PayByPhone_2018",
	SUM("AllVehiclesParked_Weighted") AS "Demand_All_2018",
	SUM(
	CASE WHEN "RestrictionGroup" IN ('Resident Permit Holder Bay') THEN "AllVehiclesParked_Weighted" ELSE 0 END
	) AS "Demand_ResidentBays_2018",
	SUM(
	CASE WHEN "RestrictionGroup" IN ('Pay & Display/Pay by Phone Bay') THEN "AllVehiclesParked_Weighted" ELSE 0 END
	) AS "Demand_PayByPhone_2018"
    FROM mhtc_operations."2018_Demand_ALL"
    --WHERE "RestrictionGroup" NOT IN ('Bus Stop',  'Bus Stop (Red Route)',  'Bus Stand' ,  'Bus Stand (Red Route)' ,
    --'Cycle Hire bay' ,  'Motorcycle Permit Holders bay' ,  'On-Carriageway Bicycle Bay' ,  'Solo Motorcycle bay (Visitors)',  -- MCL, PCL, Scooters, etc
	--'No Stopping (Acceptable) (SRL)' ,  'No Stopping At Any Time (DRL)' ,  'No Waiting (Acceptable) (SYL)' ,  'No Waiting (Unacceptable) (SYL)' ,  
	--'No Waiting At Any Time (DYL)' ,  'Crossing - Unmarked and no signals' )
    GROUP BY "SurveyID", "RoadName"
    ORDER BY "RoadName", "SurveyID" ) f ) e
	ON e."SurveyID" = r1."SurveyID" AND e."RoadName" = r1."RoadName"
	WHERE r1."RoadName" = r."roadname1_name"

WITH DATA;

ALTER TABLE demand."StressResults_ByRoadName"
    OWNER TO postgres;

CREATE UNIQUE INDEX "idx_StressResults_ByRoadName_sid"
    ON demand."StressResults_ByRoadName" USING btree
    (sid)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."StressResults_ByRoadName";

-- Output
SELECT DISTINCT "RoadName", "SurveyID", "BeatTitle", "Capacity_All_2022", "CapacityAtTimeOfSurvey_All_2022", 
	"Demand_All_2022", "Stress_All_2022" AS "Occupancy_2022", 
	"Capacity_ResidentBays_2022", "CapacityAtTimeOfSurvey_ResidentBays_2022", "Demand_ResidentBays_2022",
    "Capacity_PayByPhone_2022", "CapacityAtTimeOfSurvey_PayByPhone_2022", "Demand_PayByPhone_2022",
	"Capacity_All_2018", "CapacityAtTimeOfSurvey_All_2018", "Demand_All_2018", 
	"Stress_All_2018" AS "Occupancy_2018",
	"Capacity_ResidentBays_2018", "CapacityAtTimeOfSurvey_ResidentBays_2018", "Demand_ResidentBays_2018",
    "Capacity_PayByPhone_2018", "CapacityAtTimeOfSurvey_PayByPhone_2018", "Demand_PayByPhone_2018"
	FROM demand."StressResults_ByRoadName"
	ORDER BY "RoadName", "SurveyID";