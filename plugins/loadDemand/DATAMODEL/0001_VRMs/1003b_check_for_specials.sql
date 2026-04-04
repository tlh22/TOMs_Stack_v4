/**

-- check for special situations

**/

SELECT DISTINCT "VRM", s."GeometryID", s."RoadName"
FROM demand."VRMs" v, mhtc_operations."Supply" s
WHERE v."GeometryID" = s."GeometryID"
AND "VRM" IN ('COVE-RED', 'DK-', 'SYL-', 'SKIP-', 'TRAI-LER', 'UNKN-OWN')



