/***

Assign VehicleTypeID and PermitTypeID to details recorded from camera using details from manual survey

Logic is:
  1. Find VRMs that match
     - Find the "earliest" match, i.e., start with the beat following the vehicle entry (and not after it leaves)

***/

/***
SELECT a."VRM"
, a."Time_IN"
, a."Time_OUT"
, c."BeatStartTime"
, "VehicleTypeID"
, "PermitTypeID"

FROM
(
SELECT v1."SiteID", v1."VRM", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT"
FROM anpr."VRMs" v1, anpr."VRMs" v2
WHERE v1."MatchedTo" = v2."ID" 
UNION
SELECT v1."SiteID", v1."VRM", v1."CaptureTime" AS "Time_IN", NULL AS "Time_OUT"
FROM anpr."VRMs" v1
WHERE v1."MatchedTo" IS NULL 
ORDER BY "VRM", "Time_IN"
) a, 

(SELECT "VRM"
, v."SurveyID"
, "VehicleTypeID"
, "PermitTypeID"
, TO_TIMESTAMP( CONCAT(TO_CHAR("SurveyDate", 'YYYY-MM-DD'), ' ', LEFT("BeatStartTime", 2), ':', RIGHT("BeatStartTime", 2)), 'YYYY-MM-DD HH24:MI:SS') AS "BeatStartTime"
FROm demand."VRMs" v, mhtc_operations."Supply" s, demand."Surveys" sv
WHERE v."GeometryID" = s."GeometryID"
AND v."SurveyID" = sv."SurveyID"
AND sv."SurveyID" > 0
AND s."RoadName" = 'A - Bury Lane Car Park'
) c 

WHERE a."VRM" = c."VRM"
AND a."Time_IN" < "BeatStartTime"
AND "BeatStartTime" < a."Time_OUT"
AND DATE("Time_IN") = DATE("BeatStartTime")
AND a."SiteID" = 11
ORDER BY "VRM", "BeatStartTime"
--LIMIT 1

SELECT cp."CarParkID", cp."Description", rt."FromSiteID", rt."ToSiteID"
FROM anpr."CarParks" cp, anpr."Sites" st, anpr."Routes" rt 
WHERE cp."CarParkID" = st."CarParkID"
AND st."SiteID" = rt."FromSiteID"
AND cp."CarParkID" = 1


SELECT v1."VRM", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT"
FROM anpr."VRMs" v1, anpr."VRMs" v2
WHERE v1."MatchedTo" = v2."ID" 
UNION
SELECT v1."VRM", v1."CaptureTime" AS "Time_IN", NULL AS "Time_OUT"
FROM anpr."VRMs" v1
WHERE v1."MatchedTo" IS NULL 
ORDER BY "VRM", "Time_IN"

***/



-- First look for exact matches

DO
$do$
DECLARE
   car_park RECORD;
   obs RECORD;
   count integer = 0;
   not_updated_to BOOLEAN;
   not_updated_from BOOLEAN;
   correct_match BOOLEAN;
   
   car_park_id INTEGER = 1;
   vehicle_type_id INTEGER;
   permit_type_id INTEGER;
   beat_start_time TIMESTAMP;
   survey_id INTEGER;
   
BEGIN

	FOR car_park IN
		SELECT cp."CarParkID", cp."Description", rt."FromSiteID", rt."ToSiteID"
		FROM anpr."CarParks" cp, anpr."Sites" st, anpr."Routes" rt 
		WHERE cp."CarParkID" = st."CarParkID"
		AND st."SiteID" = rt."FromSiteID"
		AND cp."CarParkID" = car_park_id
    LOOP

        RAISE NOTICE '*** Considering % ...', car_park."Description";
		
		count = 0;
		 
		FOR obs IN
			SELECT v1."SiteID", v1."VRM", v1."CaptureTime" AS "Time_IN", v2."CaptureTime" AS "Time_OUT"
			, v1."ID"
			, v1."MatchedTo"
			FROM anpr."VRMs" v1, anpr."VRMs" v2
			WHERE v1."MatchedTo" = v2."ID" 
			AND v1."SiteID" = car_park."FromSiteID"
			AND v1."VehicleTypeID" IS NULL
			AND v1."PermitTypeID" IS NULL
			UNION
			SELECT v1."SiteID", v1."VRM", v1."CaptureTime" AS "Time_IN", NULL AS "Time_OUT"
			, v1."ID"
			, v1."MatchedTo"
			FROM anpr."VRMs" v1
			WHERE v1."MatchedTo" IS NULL
			AND v1."SiteID" = car_park."FromSiteID"
			AND v1."VehicleTypeID" IS NULL
			AND v1."PermitTypeID" IS NULL
			ORDER BY "VRM", "Time_IN"		
		LOOP

			--RAISE NOTICE '*** Considering % % % ...', obs."VRM", obs."Time_IN", obs."Time_OUT";
			
			-- Find next time period
			
			SELECT "SurveyID"
				, "BeatStartTime"
				INTO survey_id, beat_start_time
			FROM
				(SELECT "SurveyID"
				, TO_TIMESTAMP( CONCAT(TO_CHAR("SurveyDate", 'YYYY-MM-DD'), ' ', LEFT("BeatStartTime", 2), ':', RIGHT("BeatStartTime", 2)), 'YYYY-MM-DD HH24:MI:SS') AS "BeatStartTime"
				FROM demand."Surveys"
				WHERE "SurveyID" > 0
				) sv
			WHERE obs."Time_IN" < sv."BeatStartTime"
			AND DATE(obs."Time_IN") = DATE(sv."BeatStartTime")
			ORDER BY "SurveyID"
			LIMIT 1;
			
			--RAISE NOTICE '*** Considering % % ...', survey_id, beat_start_time;

			vehicle_type_id = NULL;
			permit_type_Id = NULL;
			
			SELECT 
			  "VehicleTypeID"
			, "PermitTypeID"
			INTO 
			  vehicle_type_id
			, permit_type_id
			FROM demand."VRMs" v, mhtc_operations."Supply" s
			WHERE v."GeometryID" = s."GeometryID"
			AND v."SurveyID" = survey_id
			AND s."RoadName" = car_park."Description"
			AND v."VRM" = obs."VRM"
			AND (v."VehicleTypeID" IS NOT NULL
			OR v."PermitTypeID" IS NOT NULL)
			;

			-- Update if details are found

			IF vehicle_type_id IS NOT NULL OR permit_type_Id IS NOT NULL THEN
			
				RAISE NOTICE '!!! FOUND MATCH % % % % % ...', obs."VRM", survey_id, beat_start_time, vehicle_type_id, permit_type_id;
				count = count + 1;
				
				UPDATE anpr."VRMs"
				SET "VehicleTypeID" = vehicle_type_id, "PermitTypeID" = permit_type_id
				WHERE "ID" IN (obs."ID", obs."MatchTo");
				
			END IF;
						
		END LOOP;
		
		RAISE NOTICE '----Matched % ...', count;
		
	END LOOP;
	
END
$do$;