/***

To allow reporting by road segment, find the closest road segment to the mid-point of the restriction

***/

ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN IF NOT EXISTS "RoadLinkID" integer;

UPDATE mhtc_operations."Supply" AS s
SET "RoadLinkID" = id
FROM
(
SELECT DISTINCT ON (s."GeometryID") s."GeometryID", r.id, ST_Length(ST_ShortestLine(r.geom, ST_LineInterpolatePoint(s.geom, 0.5))) AS dist
FROM mhtc_operations."Supply" s, highways_network."roadlink" r
WHERE ST_DWithin(s.geom, r.geom, 15.0)
ORDER BY s."GeometryID", dist
) AS p
WHERE s."GeometryID" = p."GeometryID";

-- See https://gis.stackexchange.com/questions/136403/postgis-nearest-points-with-st-distance-knn
