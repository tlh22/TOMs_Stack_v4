--DELETE FROM anpr."VRMs"
--WHERE UPPER("VRM") = 'NOPLATE';

UPDATE anpr."VRMs"
SET "Direction" = 'UNKNOWN'
WHERE "Direction" = '#N/A';
