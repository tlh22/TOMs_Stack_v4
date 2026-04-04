
SELECT DISTINCT a1."Geometry", a2."GeometryID"
FROM
(SELECT v1."GeometryID", v1."VRM", s1.geom
FROM mhtc_operations."Supply" s1, demand."VRMs" v1
WHERE v1."GeometryID" = s1."GeometryID"
AND s1."SurveyAreaID" = 19
AND v1."SurveyID" = 103) a1,
(SELECT v2."GeometryID", v2."VRM", s2.geom
FROM mhtc_operations."Supply" s2, demand."VRMs" v2
WHERE v2."GeometryID" = s2."GeometryID"
AND s2."SurveyAreaID" = 19
AND v2."SurveyID" = 104) a2

WHERE a1."GeometryID" != a1."GeometryID"
AND ST_DWithin(a1.geom, a2.geom, 1.0)