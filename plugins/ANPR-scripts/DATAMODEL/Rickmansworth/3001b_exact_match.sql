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
   car_park_id INTEGER = x;
BEGIN

    FOR car_park IN SELECT DISTINCT "CarParkID", "Description"
    		         FROM anpr."CarParks" r
					 WHERE "CarParkID" = car_park_id
					 ORDER BY "CarParkID"
    LOOP

        RAISE NOTICE '*** Considering % ...', car_park."Description";
		
		count = 0;
		   
		FOR obs IN SELECT "FromID", "FromVRM", "FromCaptureTime", "FromDirection", "ToSiteID", "ToID", "ToVRM", "ToCaptureTime", "FromDirection", "Duration"
				   FROM					  
				  (SELECT v1."ID" AS "FromID", v1."VRM" AS "FromVRM", v1."CaptureTime" AS "FromCaptureTime", v1."Direction" AS "FromDirection",
				          v2."SiteID" AS "ToSiteID", v2."ID" AS "ToID", v2."VRM" AS "ToVRM", v2."Direction" AS "ToDirection",
				          v2."CaptureTime" AS "ToCaptureTime", v2."CaptureTime" - v1."CaptureTime" AS "Duration"
					     , row_number() over (partition by v1."ID" order by v2."CaptureTime" - v1."CaptureTime" asc) AS row_number
				   FROM anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
				   WHERE v1."ID" != v2."ID"
				   AND v1."VRM" = v2."VRM"
				   AND UPPER(v1."VRM") NOT IN ('NOPLATE', 'UNKNOWN', 'UNKN-OWN')
				   
				   AND v2."CaptureTime" - v1."CaptureTime" >= 
								   (SELECT "MinimumTimeLimit"
								   FROM anpr."Routes"
								   WHERE "FromSiteID" = v1."SiteID"
								   AND "ToSiteID" = v2."SiteID")

				   AND v2."CaptureTime" >= v1."CaptureTime"
				   AND DATE_TRUNC('day', v2."CaptureTime") = DATE_TRUNC('day', v1."CaptureTime")
				   AND (v1."MatchedTo" IS NULL AND v1."MatchedFrom" IS NULL)
				   AND (v2."MatchedTo" IS NULL AND v2."MatchedFrom" IS NULL)

				   AND v2."SiteID" IN (SELECT "ToSiteID"
									   FROM anpr."Routes"
									   WHERE "FromSiteID" = v1."SiteID")

				   AND v1."SiteID" = s1."SiteID"
				   AND v2."SiteID" = s2."SiteID"
				   --AND ( ((UPPER(v1."Direction") = 'IN' OR UPPER(v1."Direction") = 'UNKNOWN') AND (UPPER(v2."Direction") = 'OUT' OR UPPER(v2."Direction") = 'UNKNOWN')) )
				   AND s1."CarParkID" = s2."CarParkID"
				   AND s1."CarParkID" = car_park."CarParkID"
				   ORDER BY "Duration" ASC) t
				   WHERE row_number = 1

		LOOP
		
			correct_match = true;
						
			not_updated_to = false;
			not_updated_from = false;

			SELECT true
			INTO not_updated_to
			FROM anpr."VRMs"
			WHERE "ID" = obs."ToID" 
			--AND "MatchedTo" IS NULL
			AND "MatchedFrom" IS NULL;

			SELECT true
			INTO not_updated_from
			FROM anpr."VRMs"
			WHERE "ID" = obs."FromID"
			AND "MatchedTo" IS NULL
			--AND "MatchedFrom" IS NULL
			;
			
			--RAISE NOTICE '*** Considering % % % % ...', obs."FromID", obs."ToID", not_updated_to, not_updated_from, correct_match;
			
			IF not_updated_to = true AND not_updated_from = true AND correct_match = true THEN
			
				UPDATE anpr."VRMs"
				SET "MatchedTo" = obs."ToID"
				WHERE "ID" = obs."FromID";

				UPDATE anpr."VRMs"
				SET "MatchedFrom" = obs."FromID"
				WHERE "ID" = obs."ToID";

				count = count + 1;

			ELSIF correct_match = true THEN
			
				-- RAISE NOTICE '---*** % % % % % % ...', obs."FromVRM", obs."FromID", obs."ToID", not_updated_to, not_updated_from, correct_match;
			
			END IF;

		END LOOP;
		
		RAISE NOTICE '----Matched % ...', count;
		
	END LOOP;
	
END
$do$;

