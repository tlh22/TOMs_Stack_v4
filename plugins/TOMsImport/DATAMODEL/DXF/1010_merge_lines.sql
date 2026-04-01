/**
deal with lines that are completely disjoint
**/

ALTER TABLE public."Shandon"
  ADD COLUMN geom_single geometry(LineString,27700);

UPDATE public."Shandon"
SET geom_single = ST_GeometryN(geom, 1);

DROP TABLE IF EXISTS local_authority."DXF_Merged_initial" CASCADE;

CREATE TABLE local_authority."DXF_Merged_initial"
(
    id SERIAL,
    "Layer" character varying COLLATE pg_catalog."default",
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    geom geometry,
    CONSTRAINT dxf_merged_initial_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

-- DROP INDEX local_authority.fp_geom_geom_idx;

CREATE INDEX dxf_merged_initial_geom_idx
    ON local_authority."DXF_Merged_initial" USING gist
    (geom)
    TABLESPACE pg_default;

WITH endpoints AS (SELECT id, layer, ST_Collect(ST_StartPoint(geom_single), ST_EndPoint(geom_single)) AS geom FROM public."Shandon"),
     clusters  AS (SELECT layer, unnest(ST_ClusterWithin(geom, 1e-8)) AS geom FROM endpoints GROUP BY layer),
     clusters_with_ids AS (SELECT row_number() OVER () AS cid, layer, ST_CollectionHomogenize(geom) AS geom FROM clusters)

INSERT INTO local_authority."DXF_Merged_initial" ("Layer", geom)
SELECT clusters_with_ids.layer, ST_Collect(a.geom) AS geom
FROM public."Shandon" a
LEFT JOIN clusters_with_ids ON ST_Intersects(a.geom, clusters_with_ids.geom)

GROUP BY cid, clusters_with_ids.layer;