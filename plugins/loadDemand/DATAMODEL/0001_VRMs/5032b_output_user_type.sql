/***
 * Use both VRMs and RiS
 ***/

UPDATE "demand"."RestrictionsInSurveys" SET "Photos_03" = "Photos_03";

-- Now add details to RiS

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Residents" double precision;

ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Commuters" double precision;
    
ALTER TABLE demand."RestrictionsInSurveys"
    ADD COLUMN IF NOT EXISTS "Demand_Visitors" double precision;

DO
$do$
DECLARE
   row RECORD;
   demand_residents real :=0;
   demand_commuters real :=0;
   demand_visitors real :=0;
BEGIN

	ALTER TABLE demand."RestrictionsInSurveys"
	    DISABLE TRIGGER update_demand;

    FOR row IN SELECT "SurveyID", "GeometryID"
                FROM demand."RestrictionsInSurveys"
    LOOP

         RAISE NOTICE '***** Considering (%) for %', row."GeometryID", row."SurveyID";

	    SELECT 
	    SUM(CASE WHEN v."UserTypeID" = 1 THEN b."PCU" ELSE 0 END) AS demand_residents,
	    SUM(CASE WHEN v."UserTypeID" = 2 THEN b."PCU" ELSE 0 END) AS demand_commuters,
	    SUM(CASE WHEN v."UserTypeID" = 3 THEN b."PCU" ELSE 0 END) AS demand_visitors	    
	    INTO demand_residents, demand_commuters, demand_visitors
	    FROM demand."VRMs" v, "demand_lookups"."VehicleTypes" b
	    WHERE v."VehicleTypeID" = b."Code"
	    AND v."SurveyID" = row."SurveyID"
	    AND v."GeometryID" = row."GeometryID"
	    GROUP BY v."SurveyID", v."GeometryID"
	    ;
   
		UPDATE demand."RestrictionsInSurveys" AS RiS
		SET "Demand_Residents" = demand_residents,
		    "Demand_Commuters" = demand_commuters,
		    "Demand_Visitors" = demand_visitors
		WHERE RiS."SurveyID" = row."SurveyID"
	    AND RiS."GeometryID" = row."GeometryID";
	    	    
    END LOOP;
    
    ALTER TABLE demand."RestrictionsInSurveys"
	    ENABLE TRIGGER update_demand;
END
$do$;
 
--- RiS

SELECT d."SurveyID", d."BeatTitle", d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID",
d."RestrictionTypeID", d."RestrictionType Description",
d."UnacceptableType Description", 
d."RestrictionLength", d."RoadName", d."CPZ",
d."SupplyCapacity", d."CapacityAtTimeOfSurvey", ROUND(d."Demand"::numeric, 2) AS "Demand",
 d."Demand_Residents", d."Demand_Commuters", d."Demand_Visitors"
FROM
(
SELECT ris."SurveyID", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."RestrictionType Description", 
s."UnacceptableType Description", s."RestrictionLength", 
 s."RoadName", s."SideOfStreet", s."SurveyAreaName", s."CPZ",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", ris."SupplyCapacity", ris."CapacityAtTimeOfSurvey", ris."Demand",
ris."Demand_Residents", ris."Demand_Commuters", ris."Demand_Visitors"
FROM demand."RestrictionsInSurveys" ris, demand."Surveys" su,
(
SELECT a."GeometryID", a."RestrictionTypeID", a."RestrictionLength", a."Capacity" AS "SupplyCapacity",
"UnacceptableTypes"."Description" AS "UnacceptableType Description", 
"BayLineTypes"."Description" AS "RestrictionType Description",
a."RoadName", a."SideOfStreet", a."CPZ", "SurveyAreas"."SurveyAreaName", 
 a.geom AS "SupplyGeom"
 FROM
(((  mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
 LEFT JOIN "mhtc_operations"."SurveyAreas" AS "SurveyAreas" ON a."SurveyAreaID" is not distinct from "SurveyAreas"."Code")
 LEFT JOIN "toms_lookups"."UnacceptableTypes" AS "UnacceptableTypes" ON a."UnacceptableTypeID" is not distinct from "UnacceptableTypes"."Code")
 ) AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

WHERE d."SurveyID" > 0
--AND d."Done" IS true
ORDER BY d."SurveyID", d."GeometryID";
