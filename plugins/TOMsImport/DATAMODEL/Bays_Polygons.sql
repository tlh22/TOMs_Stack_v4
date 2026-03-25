--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3 (Debian 12.3-1.pgdg100+1)
-- Dumped by pg_dump version 12.4

-- Started on 2020-12-13 12:02:47

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- TOC entry 247 (class 1259 OID 20762)
-- Name: Bays_MultiPolygon; Type: TABLE; Schema: export; Owner: postgres
--

CREATE TABLE "export"."Bays_MultiPolygon" (
    "GeometryID" character varying NOT NULL,
    "geom" "public"."geometry"(MultiPolygon,27700),
    "fid" bigint,
    "RestrictionTypeID" integer,
    "RoadName" character varying(254),
    "USRN" character varying(254),
    "OpenDate" "date",
    "CPZ" character varying(40),
    "NrBays" integer,
    "TimePeriodID" integer,
    "PayTypeID" integer,
    "MaxStayID" integer,
    "NoReturnID" integer,
    "ParkingTariffArea" character varying(10)
);


ALTER TABLE "export"."Bays_MultiPolygon" OWNER TO "postgres";

--
-- TOC entry 4177 (class 0 OID 20762)
-- Dependencies: 247
-- Data for Name: Bays_MultiPolygon; Type: TABLE DATA; Schema: export; Owner: postgres
--

INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000020', '0106000020346C000001000000010300000001000000050000009C2E9C07C4DB134110DCB1DB3B932441807CA94EECDB1341070FBD5B41932441041C2C4DE7DB1341855FD0854A93244120CE1E06BFDB13418E2CC505459324419C2E9C07C4DB134110DCB1DB3B932441', 1, 101, NULL, NULL, '2020-05-01', NULL, -1, 15, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000021', '0106000020346C00000100000001030000000100000005000000B2CA5D6900DC1341E0C5B88F4E9324419DAC317A3ADC1341E95530A95693244153F1A79838DC134158CC3B085A932441680FD487FEDB13414F3CC4EE51932441B2CA5D6900DC1341E0C5B88F4E932441', 2, 103, NULL, NULL, '2020-05-01', 'A', 3, 15, 4, 3, 1, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000022', '0106000020346C0000010000000103000000010000000500000072B7A4793ADC1341BB961CA95693244163D47CC34DDC1341C47BD45F59932441F26418DE4BDC1341F5B755BE5C9324410148409438DC1341ECD29D075A93244172B7A4793ADC1341BB961CA956932441', 3, 110, NULL, NULL, '2020-05-01', 'A', -1, 1, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000023', '0106000020346C00000200000001030000000100000005000000623DD5B99ADC13417BC8724B649324411CB0B53EC1DC13418EE2BAAF6993244166DFAA6FC0DC1341424D83216B932441AC6CCAEA99DC13412F333BBD65932441623DD5B99ADC13417BC8724B64932441010300000001000000050000003073DC439BDC1341032CED5463932441EAE5BCC8C1DC1341164635B968932441A0B6C797C2DC134162DB6C4767932441E643E7129CDC13414FC124E3619324413073DC439BDC1341032CED5463932441', 4, 105, 'Queen Street', '1001', '2020-05-01', 'A', -1, 39, 4, 3, 1, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000024', '0106000020346C000001000000010300000001000000050000001CB0B53EC1DC13418EE2BAAF69932441173F690FE0DC13410491F4FF6D932441B0FD80CDE3DC1341B05ECD5D77932441B56ECDFCC4DC13413AB0930D739324411CB0B53EC1DC13418EE2BAAF69932441', 5, 118, 'Queen Street', '1001', '2020-05-01', 'A', -1, 1, NULL, 9, NULL, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000025', '0106000020346C00000100000001030000000100000005000000FC20C1601ADD1341A81BDB1F75932441F7AF743139DD13411ECA1470799324414BEC8D143BDD13417B26411176932441505DDA431CDD1341057807C171932441FC20C1601ADD1341A81BDB1F75932441', 6, 101, 'Queen Street', '1001', '2020-05-01', 'A', -1, 14, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000026', '0106000020346C00000100000001030000000100000005000000F7AF743139DD13411ECA14707993244154E9E4734CDD134127D738227C9324417F68299351DD1341B48843FC72932441222FB9503EDD1341AB7B1F4A70932441F7AF743139DD13411ECA147079932441', 7, 110, 'Queen Street', '1001', '2020-05-01', 'A', -1, 1, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000027', '0106000020346C0000010000000103000000010000000500000032D69CDAEDDA134164CF70BE2793244119D3F748FFDA13413ADF45D722932441760C688B12DB134144EC69892593244182DEC6591CDB13411EAD97402E93244132D69CDAEDDA134164CF70BE27932441', 8, 114, 'Queen Street', '1001', '2020-05-01', 'A', -1, 15, NULL, 9, 1, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000036', '0106000020346C0000010000000103000000010000000500000007323326E8DD134141E8335E3F932441F94A97E6EEDD134130E6CE4A40932441B1E878D904DE1341674F653518932441BFCF1419FEDD13417851CA481793244107323326E8DD134141E8335E3F932441', 9, 103, 'North St David Street', '1005', '2020-05-01', 'A', -1, 153, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiPolygon" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000037', '0106000020346C000001000000010300000001000000050000002A87FE140FDE1341844FF5F35E92244172FD73802CDE13411276BD40639224416BE83D772EDE134147F3BAE45F9224412372C80B11DE1341B9CCF2975B9224412A87FE140FDE1341844FF5F35E922441', 10, 114, 'George Street', '1012', '2020-05-15', 'A', -1, 15, NULL, 9, 1, NULL);


--
-- TOC entry 4040 (class 2606 OID 21171)
-- Name: Bays_MultiPolygon Bays_MultiPolygon_pkey; Type: CONSTRAINT; Schema: export; Owner: postgres
--

ALTER TABLE ONLY "export"."Bays_MultiPolygon"
    ADD CONSTRAINT "Bays_MultiPolygon_pkey" PRIMARY KEY ("GeometryID");


--
-- TOC entry 4183 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE "Bays_MultiPolygon"; Type: ACL; Schema: export; Owner: postgres
--

GRANT SELECT ON TABLE "export"."Bays_MultiPolygon" TO "toms_public";
GRANT SELECT ON TABLE "export"."Bays_MultiPolygon" TO "toms_operator";
GRANT SELECT ON TABLE "export"."Bays_MultiPolygon" TO "toms_admin";


-- Completed on 2020-12-13 12:02:53

--
-- PostgreSQL database dump complete
--

