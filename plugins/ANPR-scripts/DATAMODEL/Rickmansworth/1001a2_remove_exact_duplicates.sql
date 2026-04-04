-- Remove duplicates - NB: Could be at different sites ...

DELETE FROM anpr."VRMs" AS v1
 USING anpr."VRMs" v2
--SELECT * FROM anpr."VRMs" AS v1, anpr."VRMs" v2
WHERE v1."VRM" = v2."VRM"
AND v1."CaptureTime" = v2."CaptureTime"
AND (v1."Direction" = v2."Direction"
OR UPPER(v1."Direction") = 'UNKNOWN' OR UPPER(v2."Direction") = 'UNKNOWN')
AND v1."SiteID" = v2."SiteID"
AND UPPER(v1."VRM") != 'NOPLATE'
AND v1."ID" < v2."ID";
