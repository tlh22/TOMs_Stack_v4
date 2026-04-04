/***

Setup list of vehicles to be excluded 

***/

DROP TABLE IF EXISTS anpr."VRMs_Excluded" CASCADE;
CREATE TABLE anpr."VRMs_Excluded"
(
  "ID" SERIAL,
  "CarParkID" integer NOT NULL,
  "VRM" character varying(12) NOT NULL,
  CONSTRAINT "VRMs_Excluded_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE anpr."VRMs_Excluded"
  OWNER TO postgres;
    
-- get details

SELECT DISTINCT 10 AS "CarParkID", "VRM" FROM demand."VRMs"
WHERE "GeometryID" = 'B_0000400'
AND UPPER("Notes") LIKE '%PRIVATE%'	

-- Now copy details into the VRMs_Excluded table

COPY anpr."VRMs_Excluded"("CarParkID", "VRM")
FROM 'C:\Users\Public\Documents\ADL_CP10_VRMs_Excluded.csv'
DELIMITER ','
CSV HEADER;

-- Now remove them (and any matched vehicles)

SELECT v.*
FROM anpr."VRMs" v, anpr."Sites" s, anpr."CarParks" c
WHERE v."SiteID" = s."SiteID"
AND s."CarParkID" = c."CarParkID"
AND "VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded")
AND c."CarParkID" = 10


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
	
		FOR obs IN SELECT DISTINCT "ID"
		           FROM (	
					   SELECT v1."ID"
					   FROM	anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
					   WHERE v1."MatchedFrom" = v2."ID"
					   AND v1."SiteID" = s1."SiteID"
					   AND v2."SiteID" = s2."SiteID"
					   AND s1."CarParkID" = s2."CarParkID"
					   AND s1."CarParkID" = car_park."CarParkID"
					   AND (v1."VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded")
					   OR v2."VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded"))
					   
					   UNION
					   
					   SELECT v2."ID"
					   FROM	anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
					   WHERE v1."MatchedFrom" = v2."ID"
					   AND v1."SiteID" = s1."SiteID"
					   AND v2."SiteID" = s2."SiteID"
					   AND s1."CarParkID" = s2."CarParkID"
					   AND s1."CarParkID" = car_park."CarParkID"
					   AND (v1."VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded")
					   OR v2."VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded"))	
					) y

		LOOP
				
			RAISE NOTICE '*** Found: % ...', obs."ID";

		END LOOP;
		
	END LOOP;
	
END
$do$;


SELECT v1."ID" AS "FromID", v1."VRM" AS "FromVRM", v2."ID" AS "ToID", v2."VRM" AS "ToVRM"
				   FROM	anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
				   WHERE v1."MatchedFrom" = v2."MatchedTo"
				   AND v1."SiteID" IN (101, 102)
				   
DELETE FROM "anpr"
WHERE "ID" IN (
SELECT DISTINCT "ID"
FROM (
	SELECT v1."ID"
	FROM	anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
	WHERE v1."MatchedFrom" = v2."ID"
	AND v1."SiteID" = s1."SiteID"
	AND v2."SiteID" = s2."SiteID"
	AND s1."CarParkID" = s2."CarParkID"
	AND s1."CarParkID" = 10
	AND (v1."VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded")
	OR v2."VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded"))

	UNION

	SELECT v2."ID"
	FROM	anpr."VRMs" v1, anpr."VRMs" v2, anpr."Sites" s1, anpr."Sites" s2
	WHERE v1."MatchedFrom" = v2."ID"
	AND v1."SiteID" = s1."SiteID"
	AND v2."SiteID" = s2."SiteID"
	AND s1."CarParkID" = s2."CarParkID"
	AND s1."CarParkID" = 10
	AND (v1."VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded")
	OR v2."VRM" IN (SELECT "VRM" FROM anpr."VRMs_Excluded"))	
) y
)