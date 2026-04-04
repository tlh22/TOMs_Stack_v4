/***
 * Set up table with new ananomised ids for each VRM
 ***/

-- DROP SEQUENCE IF EXISTS demand."VRMs_id_seq";

CREATE SEQUENCE IF NOT EXISTS demand."VRMs_id_seq"
    INCREMENT 1
    START 10000
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE demand."VRMs_id_seq"
    OWNER TO postgres;

GRANT ALL ON SEQUENCE demand."VRMs_id_seq" TO postgres;

GRANT SELECT, USAGE ON SEQUENCE demand."VRMs_id_seq" TO toms_admin;

GRANT SELECT, USAGE ON SEQUENCE demand."VRMs_id_seq" TO toms_operator;

GRANT SELECT, USAGE ON SEQUENCE demand."VRMs_id_seq" TO toms_public;

--

DROP TABLE IF EXISTS demand."Anonomise_VRMs";

CREATE TABLE demand."Anonomise_VRMs"
(
  "NewID" character varying(12) COLLATE pg_catalog."default" NOT NULL DEFAULT ('V_'::text || to_char(nextval('demand."VRMs_id_seq"'::regclass), 'FM0000000'::text)),
  "VRM" character varying(12),
  CONSTRAINT "Anonomise_VRMs_pkey" PRIMARY KEY ("NewID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE demand."Anonomise_VRMs"
  OWNER TO postgres;

--
 
INSERT INTO demand."Anonomise_VRMs" ("VRM")
SELECT DISTINCT "VRM"
FROM demand."VRMs"
ORDER BY "VRM";

--

ALTER TABLE demand."VRMs"
    ADD COLUMN IF NOT EXISTS "AnonomisedVRM" character varying(12);

--

UPDATE demand."VRMs" AS v
SET "AnonomisedVRM" = a."NewID"
FROM demand."Anonomise_VRMs" a
WHERE v."VRM" = a."VRM";