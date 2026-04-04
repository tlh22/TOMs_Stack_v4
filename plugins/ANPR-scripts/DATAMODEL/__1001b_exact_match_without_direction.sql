/***
 * Choose matches within specified time
 ***/
 
 /***
 -- from 1 -> 2
 SELECT v1."VRM", v1."CaptureTime", v1."Direction", v2."CaptureTime" - v1."CaptureTime" AS "TimeDifference"
 FROM anpr."VRMs" v1, anpr."VRMs" v2
 WHERE v1."VRM" = v2."VRM"
 AND v1."SiteID" = 1 
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 2
 AND (v2."Direction" = 'Forward' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" > v1."CaptureTime"
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:05:00';
 
 -- from 2 -> 1
 SELECT v1."VRM", v1."CaptureTime", v1."Direction", v1."CaptureTime" - v2."CaptureTime" AS "TimeDifference"
 FROM anpr."VRMs" v1, anpr."VRMs" v2
 WHERE v1."VRM" = v2."VRM"
 AND v1."SiteID" = 2
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 1
 AND (v2."Direction" = 'Forward' OR v2."Direction" = 'Unknown')
 AND v1."CaptureTime" > v2."CaptureTime"
 AND v1."CaptureTime" - v2."CaptureTime" <= '00:05:00';
 
  -- from 1 -> 3
 SELECT v1."VRM", v1."CaptureTime", v1."Direction", v2."CaptureTime" - v1."CaptureTime" AS "TimeDifference"
 FROM anpr."VRMs" v1, anpr."VRMs" v2
 WHERE v1."VRM" = v2."VRM"
 AND v1."SiteID" = 1 
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 3
 AND (v2."Direction" = 'Reverse' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" > v1."CaptureTime"
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:05:00';
 
  -- from 3 -> 1
 SELECT v1."VRM", v1."CaptureTime", v1."Direction", v1."CaptureTime" - v2."CaptureTime" AS "TimeDifference"
 FROM anpr."VRMs" v1, anpr."VRMs" v2
 WHERE v1."VRM" = v2."VRM"
 AND v1."SiteID" = 3 
 AND (v1."Direction" = 'Forward' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 1
 AND (v2."Direction" = 'Forward' OR v2."Direction" = 'Unknown')
 AND v1."CaptureTime" > v2."CaptureTime"
 AND v1."CaptureTime" - v2."CaptureTime" <= '00:05:00';
 
 -- Fuzzy match
 
 CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch" WITH SCHEMA "public";
 
 -- 1 -> 2
 SELECT v1."VRM", v2."VRM", v1."CaptureTime", v2."CaptureTime", v1."Direction", v2."CaptureTime" - v1."CaptureTime" AS "TimeDifference"
 FROM anpr."VRMs" v1, anpr."VRMs" v2
 WHERE levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
 -- AND v1."VRM" != v2."VRM"
 AND v1."SiteID" = 1 
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 2
 AND (v2."Direction" = 'Forward' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" > v1."CaptureTime"
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:05:00'
 AND v2."CaptureTime" - v1."CaptureTime" > '00:01:00';
 
 -- 1 -> 3
 SELECT v1."VRM", v2."VRM", v1."CaptureTime", v2."CaptureTime", v1."Direction", v2."CaptureTime" - v1."CaptureTime" AS "TimeDifference"
 FROM anpr."VRMs" v1, anpr."VRMs" v2
 WHERE levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
 --AND v1."VRM" != v2."VRM"
 AND v1."SiteID" = 1 
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 3
 AND (v2."Direction" = 'Reverse' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" > v1."CaptureTime"
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:05:00'
 AND v2."CaptureTime" - v1."CaptureTime" > '00:01:00';
 
 
 -- Set "MatchedAt" - set for 5 mins
 

 
 -- 1 -> 2
 UPDATE anpr."VRMs" AS v1
 SET "MatchedAt" = v2."SiteID"
 FROM anpr."VRMs" AS v2
 WHERE levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
 --AND v1."VRM" != v2."VRM"
 AND v1."SiteID" = 1 
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 2
 AND (v2."Direction" = 'Forward' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" > v1."CaptureTime"
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:03:00'
 AND v2."CaptureTime" - v1."CaptureTime" > '00:01:00';
 
 -- 1 -> 3
 UPDATE anpr."VRMs" AS v1
 SET "MatchedAt" = v2."SiteID"
 FROM anpr."VRMs" AS v2
 WHERE levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
 --AND v1."VRM" != v2."VRM"
 AND v1."SiteID" = 1 
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 3
 AND (v2."Direction" = 'Reverse' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" > v1."CaptureTime"
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:03:00'
 AND v2."CaptureTime" - v1."CaptureTime" > '00:01:00';
 
 -- from 2 -> 1
 UPDATE anpr."VRMs" AS v1
 SET "MatchedAt" = v2."SiteID"
 FROM anpr."VRMs" AS v2
 WHERE levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
 --AND v1."VRM" != v2."VRM"
 AND v1."SiteID" = 2
 AND (v1."Direction" = 'Reverse' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 1
 AND (v2."Direction" = 'Forward' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" > v1."CaptureTime"
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:03:00'
 AND v2."CaptureTime" - v1."CaptureTime" > '00:01:00';
 
 -- from 3 -> 1
 UPDATE anpr."VRMs" AS v1
 SET "MatchedAt" = v2."SiteID"
 FROM anpr."VRMs" AS v2
 WHERE levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
 --AND v1."VRM" != v2."VRM"
 AND v1."SiteID" = 3
 AND (v1."Direction" = 'Forward' OR v1."Direction" = 'Unknown')
 AND v2."SiteID" = 1
 AND (v2."Direction" = 'Forward' OR v2."Direction" = 'Unknown')
 AND v2."CaptureTime" > v1."CaptureTime"
 AND v2."CaptureTime" - v1."CaptureTime" <= '00:03:00'
 AND v2."CaptureTime" - v1."CaptureTime" > '00:01:00';
***/

CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch" WITH SCHEMA "public";

-- https://www.postgresql.org/message-id/4A6A75A5.4070203@intera.si

CREATE OR REPLACE FUNCTION stringdiff(text, text)
RETURNS TEXT
AS $$
     SELECT array_to_string(ARRAY(
         SELECT
             CASE WHEN substring($1 FROM n FOR 1) = substring($2 FROM n FOR 1)
                  THEN ' '
                  ELSE substring($2 FROM n FOR 1)
             END
         FROM generate_series(1, character_length($1)) as n), '');
$$ language sql;


UPDATE anpr."VRMs"
SET "MatchedTo" = NULL, "MatchedFrom" = NULL;

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
BEGIN

    FOR car_park IN SELECT DISTINCT "CarParkID", "Description"
    		         FROM anpr."CarParks" r
					 ORDER BY "CarParkID"
    LOOP

        RAISE NOTICE '*** Considering % ...', car_park."Description";
		
		count = 0;
		   
		FOR obs IN SELECT "FromID", "FromVRM", "FromCaptureTime", "FromDirection", "ToSiteID", "ToID", "ToVRM", "ToCaptureTime", "FromDirection", "Duration", "Difference", "DifferentLetterFrom", "DifferentLetterTo"
				   FROM					  
				  (SELECT v1."ID" AS "FromID", v1."VRM" AS "FromVRM", v1."CaptureTime" AS "FromCaptureTime", v1."Direction" AS "FromDirection",
				          v2."SiteID" AS "ToSiteID", v2."ID" AS "ToID", v2."VRM" AS "ToVRM", v2."Direction" AS "ToDirection",
				          v2."CaptureTime" AS "ToCaptureTime", v2."CaptureTime" - v1."CaptureTime" AS "Duration", 
						  levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) AS "Difference",
						  stringdiff(v1."VRM"::text, v2."VRM"::text) AS "DifferentLetterFrom",
						  stringdiff(v2."VRM"::text, v1."VRM"::text) AS "DifferentLetterTo",
					     row_number() over (partition by v1."ID" order by v2."CaptureTime" - v1."CaptureTime" asc) AS row_number
				   FROM anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
				   WHERE v1."ID" != v2."ID"
				   AND v1."VRM" = v2."VRM"
				   
				   AND v2."CaptureTime" - v1."CaptureTime" >= 
								   (SELECT "MinimumTimeLimit"
								   FROM anpr."Routes"
								   WHERE "FromSiteID" = v1."SiteID"
								   AND "ToSiteID" = v2."SiteID")

				   AND v2."CaptureTime" >= v1."CaptureTime"
				   AND (v1."MatchedTo" IS NULL AND v1."MatchedFrom" IS NULL)
				   AND (v2."MatchedTo" IS NULL AND v2."MatchedFrom" IS NULL)
				   --AND v1."SiteID" = from_site."FromSiteID"
		           --/***
				   AND v2."SiteID" IN (SELECT "ToSiteID"
									   FROM anpr."Routes"
									   WHERE "FromSiteID" = v1."SiteID")
				   --AND (v1."Direction" = (SELECT "IN" FROM anpr."Sites" WHERE "SiteID" = v1."SiteID") OR UPPER(v1."Direction") = 'UNKNOWN')
				   --AND (v2."Direction" = (SELECT "OUT" FROM anpr."Sites" WHERE "SiteID" = v2."SiteID") OR UPPER(v2."Direction") = 'UNKNOWN')
				   --***/
				   AND v1."SiteID" = s1."SiteID"
				   AND v2."SiteID" = s2."SiteID"
				   AND ( ((UPPER(v1."Direction") = 'IN' OR UPPER(v1."Direction") = 'UNKNOWN') AND (UPPER(v2."Direction") = 'OUT' OR UPPER(v2."Direction") = 'UNKNOWN'))
				     --OR  (UPPER(v1."Direction") = 'OUT' AND UPPER(v2."Direction") = 'IN') 
					 )
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
			
				RAISE NOTICE '---*** % % % % % % ...', obs."FromVRM", obs."FromID", obs."ToID", not_updated_to, not_updated_from, correct_match;
			
			END IF;

		END LOOP;
		
		RAISE NOTICE '----Matched % ...', count;
		
	END LOOP;
	
END
$do$;

-- Same but without considering direction

DO
$do$
DECLARE
   car_park RECORD;
   obs RECORD;
   count integer = 0;
   not_updated_to BOOLEAN;
   not_updated_from BOOLEAN;
   correct_match BOOLEAN;
BEGIN

    FOR car_park IN SELECT DISTINCT "CarParkID", "Description"
    		         FROM anpr."CarParks" r
					 ORDER BY "CarParkID"
    LOOP

        RAISE NOTICE '*** Considering % ...', car_park."Description";
		
		count = 0;
		   
		FOR obs IN SELECT "FromID", "FromVRM", "FromCaptureTime", "FromDirection", "ToSiteID", "ToID", "ToVRM", "ToCaptureTime", "FromDirection", "Duration", "Difference", "DifferentLetterFrom", "DifferentLetterTo"
				   FROM					  
				  (SELECT v1."ID" AS "FromID", v1."VRM" AS "FromVRM", v1."CaptureTime" AS "FromCaptureTime", v1."Direction" AS "FromDirection",
				          v2."SiteID" AS "ToSiteID", v2."ID" AS "ToID", v2."VRM" AS "ToVRM", v2."Direction" AS "ToDirection",
				          v2."CaptureTime" AS "ToCaptureTime", v2."CaptureTime" - v1."CaptureTime" AS "Duration", 
						  levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) AS "Difference",
						  stringdiff(v1."VRM"::text, v2."VRM"::text) AS "DifferentLetterFrom",
						  stringdiff(v2."VRM"::text, v1."VRM"::text) AS "DifferentLetterTo",
					     row_number() over (partition by v1."ID" order by v2."CaptureTime" - v1."CaptureTime" asc) AS row_number
				   FROM anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
				   WHERE v1."ID" != v2."ID"
				   AND v1."VRM" = v2."VRM"
				   /***AND v2."CaptureTime" - v1."CaptureTime" >= 
								   (SELECT "MinimumTimeLimit"
								   FROM anpr."Routes"
								   WHERE "FromSiteID" = v1."SiteID"
								   AND "ToSiteID" = v2."SiteID")
								   ***/
				   AND v2."CaptureTime" >= v1."CaptureTime"
				   AND (v1."MatchedTo" IS NULL AND v1."MatchedFrom" IS NULL)
				   AND (v2."MatchedTo" IS NULL AND v2."MatchedFrom" IS NULL)
				   --AND v1."SiteID" = from_site."FromSiteID"
		           --/***
				   AND v2."SiteID" IN (SELECT "ToSiteID"
									   FROM anpr."Routes"
									   WHERE "FromSiteID" = v1."SiteID")
				   --AND (v1."Direction" = (SELECT "IN" FROM anpr."Sites" WHERE "SiteID" = v1."SiteID") OR UPPER(v1."Direction") = 'UNKNOWN')
				   --AND (v2."Direction" = (SELECT "OUT" FROM anpr."Sites" WHERE "SiteID" = v2."SiteID") OR UPPER(v2."Direction") = 'UNKNOWN')
				   --***/
				   AND v1."SiteID" = s1."SiteID"
				   AND v2."SiteID" = s2."SiteID"
				   --AND ( ((UPPER(v1."Direction") = 'IN' OR UPPER(v1."Direction") = 'UNKNOWN') AND (UPPER(v2."Direction") = 'OUT' OR UPPER(v2."Direction") = 'UNKNOWN'))
				     --OR  (UPPER(v1."Direction") = 'OUT' AND UPPER(v2."Direction") = 'IN') 
				--	 )
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
			
				RAISE NOTICE '---*** % % % % % % ...', obs."FromVRM", obs."FromID", obs."ToID", not_updated_to, not_updated_from, correct_match;
			
			END IF;

		END LOOP;
		
		RAISE NOTICE '----Matched % ...', count;
		
	END LOOP;
	
END
$do$;


--- Now look for near matches

DO
$do$
DECLARE
   car_park RECORD;
   obs RECORD;
   count integer = 0;
   not_updated_to BOOLEAN;
   not_updated_from BOOLEAN;
   correct_match BOOLEAN;
BEGIN

    FOR car_park IN SELECT DISTINCT "CarParkID", "Description"
    		         FROM anpr."CarParks" r
					 ORDER BY "CarParkID"
    LOOP

        RAISE NOTICE '*** Considering % ...', car_park."Description";
		
		count = 0;
		   
		FOR obs IN SELECT "FromID", "FromVRM", "FromCaptureTime", "FromDirection", "ToSiteID", "ToID", "ToVRM", "ToCaptureTime", "FromDirection", "Duration", "Difference", TRIM("DifferentLetterFrom") AS "DifferentLetterFrom", TRIM("DifferentLetterTo") AS "DifferentLetterTo"
				   FROM					  
				  (SELECT v1."ID" AS "FromID", v1."VRM" AS "FromVRM", v1."CaptureTime" AS "FromCaptureTime", v1."Direction" AS "FromDirection",
				          v2."SiteID" AS "ToSiteID", v2."ID" AS "ToID", v2."VRM" AS "ToVRM", v2."Direction" AS "ToDirection",
				          v2."CaptureTime" AS "ToCaptureTime", v2."CaptureTime" - v1."CaptureTime" AS "Duration", 
						  levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) AS "Difference",
						  stringdiff(v1."VRM"::text, v2."VRM"::text) AS "DifferentLetterFrom",
						  stringdiff(v2."VRM"::text, v1."VRM"::text) AS "DifferentLetterTo",
					     row_number() over (partition by v1."ID" order by v2."CaptureTime" - v1."CaptureTime" asc) AS row_number
				   FROM anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
				   WHERE v1."ID" != v2."ID"
				   AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
				   /***AND v2."CaptureTime" - v1."CaptureTime" >= 
								   (SELECT "MinimumTimeLimit"
								   FROM anpr."Routes"
								   WHERE "FromSiteID" = v1."SiteID"
								   AND "ToSiteID" = v2."SiteID")
								   ***/
				   AND v2."CaptureTime" >= v1."CaptureTime"
				   AND (v1."MatchedTo" IS NULL AND v1."MatchedFrom" IS NULL)
				   AND (v2."MatchedTo" IS NULL AND v2."MatchedFrom" IS NULL)
				   --AND v1."SiteID" = from_site."FromSiteID"
		           --/***
				   AND v2."SiteID" IN (SELECT "ToSiteID"
									   FROM anpr."Routes"
									   WHERE "FromSiteID" = v1."SiteID")
				   --AND (v1."Direction" = (SELECT "IN" FROM anpr."Sites" WHERE "SiteID" = v1."SiteID") OR UPPER(v1."Direction") = 'UNKNOWN')
				   --AND (v2."Direction" = (SELECT "OUT" FROM anpr."Sites" WHERE "SiteID" = v2."SiteID") OR UPPER(v2."Direction") = 'UNKNOWN')
				   --***/
				   AND v1."SiteID" = s1."SiteID"
				   AND v2."SiteID" = s2."SiteID"
				   AND ( ((UPPER(v1."Direction") = 'IN' OR UPPER(v1."Direction") = 'UNKNOWN') AND (UPPER(v2."Direction") = 'OUT' OR UPPER(v2."Direction") = 'UNKNOWN'))
				     --OR  (UPPER(v1."Direction") = 'OUT' AND UPPER(v2."Direction") = 'IN') 
					 )
				   AND s1."CarParkID" = s2."CarParkID"
				   AND s1."CarParkID" = car_park."CarParkID"
				   ORDER BY "Duration" ASC) t
				   WHERE row_number = 1

		LOOP
		
			correct_match = true;
			
			IF obs."Difference" > 0 THEN
			
				correct_match = false;

				IF obs."DifferentLetterFrom" = 'D' AND (obs."DifferentLetterTo" = 'O' OR obs."DifferentLetterTo" = '0' OR obs."DifferentLetterTo" = 'B') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = 'O' AND (obs."DifferentLetterTo" = 'D' OR obs."DifferentLetterTo" = '0' OR obs."DifferentLetterTo" = 'Q') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = '0' AND (obs."DifferentLetterTo" = 'D' OR obs."DifferentLetterTo" = 'O' OR obs."DifferentLetterTo" = 'Q') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = 'B' AND (obs."DifferentLetterTo" = 'D') THEN
					correct_match = true;
					
				ELSIF obs."DifferentLetterFrom" = 'F' AND (obs."DifferentLetterTo" = 'E') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = 'E' AND (obs."DifferentLetterTo" = 'F') THEN
					correct_match = true;
					
				ELSIF obs."DifferentLetterFrom" = '5' AND (obs."DifferentLetterTo" = 'S') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = 'S' AND (obs."DifferentLetterTo" = '5') THEN
					correct_match = true;
					
				ELSIF obs."DifferentLetterFrom" = 'C' AND (obs."DifferentLetterTo" = 'G') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = 'G' AND (obs."DifferentLetterTo" = 'C') THEN
					correct_match = true;

				ELSIF obs."DifferentLetterFrom" = 'V' AND (obs."DifferentLetterTo" = 'Y') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = 'Y' AND (obs."DifferentLetterTo" = 'V') THEN
					correct_match = true;

				ELSIF obs."DifferentLetterFrom" = 'M' AND (obs."DifferentLetterTo" = 'N') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = 'N' AND (obs."DifferentLetterTo" = 'M') THEN
					correct_match = true;

				ELSIF obs."DifferentLetterFrom" = 'I' AND (obs."DifferentLetterTo" = '1') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = '1' AND (obs."DifferentLetterTo" = 'I') THEN
					correct_match = true;

				ELSIF obs."DifferentLetterFrom" = 'Z' AND (obs."DifferentLetterTo" = '2') THEN
					correct_match = true;
				ELSIF obs."DifferentLetterFrom" = '2' AND (obs."DifferentLetterTo" = 'Z') THEN
					correct_match = true;
					
				END IF;

				/***
				CASE obs."DifferentLetterFrom"
					WHEN 'Z' THEN
						IF obs."DifferentLetterTo" = '2' THEN correct_match = true END IF;
					WHEN '2' THEN
						IF obs."DifferentLetterTo" = 'Z' THEN correct_match = true END IF;
						
				END CASE;
				***/
				
				RAISE NOTICE '*** Difference: % %...', obs."DifferentLetterFrom", obs."DifferentLetterTo";
				
			END IF;
			
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
			
				RAISE NOTICE '---*** % % % % % % ...', obs."FromVRM", obs."FromID", obs."ToID", not_updated_to, not_updated_from, correct_match;
			
			END IF;

		END LOOP;
		
		RAISE NOTICE '----Matched % ...', count;
		
	END LOOP;
	
END
$do$;

--- Remove any matches for 'noPlate'

UPDATE anpr."VRMs"
SET "MatchedTo" = NULL, "MatchedFrom" = NULL
WHERE UPPER("VRM") = 'NOPLATE' OR UPPER("VRM") = 'UNKNOWN';
	
---
/***

-- Matched details

SELECT v1."VRM", v1."CaptureTime", v1."SiteID", v1."Direction", v2."VRM", v2."CaptureTime", v2."SiteID", v2."Direction"
FROM anpr."VRMs" v1, anpr."VRMs" v2
WHERE v1."MatchedTo" = v2."ID"
AND v2."MatchedFrom" = v1."ID"
ORDER BY v1."CaptureTime"



DO
$do$
DECLARE
   from_site RECORD;
   obs RECORD;
   count integer = 0;
BEGIN

    FOR from_site IN SELECT DISTINCT "FromSiteID"
    		         FROM anpr."Routes" r
					 ORDER BY "FromSiteID"
    LOOP

        RAISE NOTICE '*** Considering site % ...', from_site."FromSiteID";
		
		count = 0;
		   
		FOR obs IN SELECT "FromSiteID", "FromID", "FromVRM", "FromCaptureTime", "FromDirection", "ToSiteID", "ToID", "ToVRM", "ToCaptureTime", "FromDirection", "Duration"
				   FROM					  
				  (SELECT v1."SiteID" AS "FromSiteID", v1."ID" AS "FromID", v1."VRM" AS "FromVRM", v1."CaptureTime" AS "FromCaptureTime", v1."Direction" AS "FromDirection",
				          v2."SiteID" AS "ToSiteID", v2."ID" AS "ToID", v2."VRM" AS "ToVRM", v2."Direction" AS "ToDirection",
				          v2."CaptureTime" AS "ToCaptureTime", v2."CaptureTime" - v1."CaptureTime" AS "Duration", 
					     row_number() over (partition by v1."ID" order by v2."CaptureTime" - v1."CaptureTime" asc) AS row_number
				   FROM anpr."VRMs" v1, anpr."VRMs" v2
				   WHERE v1."ID" != v2."ID"
				   AND v1."VRM" = 'SC21-HKO'
				   AND levenshtein(v1."VRM"::text, v2."VRM"::text, 10, 10, 1) <= 1
				   AND v2."CaptureTime" - v1."CaptureTime" >= 
								   (SELECT "MinimumTimeLimit"
								   FROM anpr."Routes"
								   WHERE "FromSiteID" = v1."SiteID"
								   AND "ToSiteID" = v2."SiteID")
				   --AND v2."CaptureTime" - v1."CaptureTime" >= INTERVAL '30' second
				   --AND (v1."MatchedTo" IS NULL AND v1."MatchedFrom" IS NULL)
				   --AND (v2."MatchedTo" IS NULL AND v2."MatchedFrom" IS NULL)
				   --AND v1."SiteID" = from_site."FromSiteID"
		           AND v2."SiteID" IN (SELECT "ToSiteID"
									   FROM anpr."Routes"
									   WHERE "FromSiteID" = v1."SiteID")
				   AND (v1."Direction" = (SELECT "IN" FROM anpr."Sites" WHERE "SiteID" = v1."SiteID") OR v1."Direction" = 'Unknown')
				   AND (v2."Direction" = (SELECT "OUT" FROM anpr."Sites" WHERE "SiteID" = v2."SiteID") OR v2."Direction" = 'Unknown')
				   ORDER BY "Duration" ASC) t
				   WHERE row_number = 1

		LOOP
		
			RAISE NOTICE '*** Considering site % ...', from_site."FromSiteID";


		END LOOP;
		
		RAISE NOTICE '----Matched % % % % % % % % ...', obs."FromSiteID", obs."FromID", obs."FromVRM", obs."FromCaptureTime", obs."ToSiteID", obs."ToID", obs."ToVRM", obs."ToCaptureTime";
		
	END LOOP;
	
END
$do$;

***/