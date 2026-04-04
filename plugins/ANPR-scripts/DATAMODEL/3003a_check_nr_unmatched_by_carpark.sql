-- With time periods and specific routes
 
-- Number unmatched by car park

SELECT c."Description", COUNT(v.*) --, v.*
FROM anpr."VRMs" v, anpr."CarParks" c, anpr."Sites" s
WHERE v."SiteID" = s."SiteID"
AND s."CarParkID" = c."CarParkID"
AND (v."MatchedTo" IS NULL AND v."MatchedFrom" IS NULL)
AND UPPER("VRM") NOT IN ('NOPLATE', 'UNKNOWN', 'UNKN-OWN')
GROUP BY c."Description"
--ORDER BY "VRM", "CaptureTime"
