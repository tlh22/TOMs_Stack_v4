--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3 (Debian 12.3-1.pgdg100+1)
-- Dumped by pg_dump version 12.4

-- Started on 2020-12-13 12:03:34

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
-- TOC entry 246 (class 1259 OID 20756)
-- Name: Bays_MultiLineString; Type: TABLE; Schema: export; Owner: postgres
--

CREATE TABLE "export"."Bays_MultiLineString" (
    "GeometryID" character varying NOT NULL,
    "geom" "public"."geometry"(MultiLineString,27700),
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


ALTER TABLE "export"."Bays_MultiLineString" OWNER TO "postgres";

--
-- TOC entry 4177 (class 0 OID 20756)
-- Dependencies: 246
-- Data for Name: Bays_MultiLineString; Type: TABLE DATA; Schema: export; Owner: postgres
--

INSERT INTO "export"."Bays_MultiLineString" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000029', '0105000020346C000001000000010200000004000000277FFE140FDE1341584EF5F35E9224410532C80B11DE13415AC3F2975B922441DB7F6942C4DD1341D0E9DF5E50922441FDCC9F4BC2DD1341CE74E2BA53922441', 1, 107, 'George Street', '1012', '2020-05-01', 'A', -1, 1, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiLineString" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000030', '0105000020346C000001000000010200000004000000FDCC9F4BC2DD1341CE74E2BA53922441EB8D55A0C7DD13414069929C4A922441D634A63BA1DD13417BFC080045922441E873F0E69BDD13410908591E4E922441', 2, 119, 'George Street', '1012', '2020-05-01', 'A', -1, 1, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiLineString" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000031', '0105000020346C000002000000010200000004000000E873F0E69BDD13410908591E4E9224416C776BBE9CDD1341E5A7C5AD4C922441571EBC5976DD1341203B3C1147922441D31A418275DD1341449BCF81489224410102000000040000003A1C49579BDD1341779D10144F922441B618CE7F9ADD13419BFDA38450922441A1BF1E1B74DD1341D6901AE84A92244125C399F274DD1341B230877749922441', 3, 115, 'George Street', '1012', '2020-05-01', 'A', -1, 15, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiLineString" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000032', '0105000020346C000001000000010200000004000000D31A418275DD1341449BCF81489224414A4B59C171DD134113CA8F233F92244135F2A95C4BDD13414E5D068739922441BEC1911D4FDD13417F2E46E542922441', 4, 116, 'George Street', '1012', '2020-05-01', 'A', -1, 1, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiLineString" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000033', '0105000020346C000001000000010200000004000000E6B78BC401DD134164EAEAA138922441F7F6D56FFCDC1341F2F53AC0419224414D49E3B8DDDC1341873800433D9224413C0A990DE3DC1341F92CB02434922441', 5, 115, 'George Street', '1012', '2020-05-01', 'A', -1, 15, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiLineString" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000034', '0105000020346C0000010000000102000000040000003C0A990DE3DC1341F92CB024349224415E57CF16E1DC1341F7B7B28037922441BF51C87FA7DC1341D094E4152F9224419D049276A9DC1341D209E2B92B922441', 6, 119, 'George Street', '1012', '2020-05-01', 'A', -1, 15, NULL, NULL, NULL, NULL);
INSERT INTO "export"."Bays_MultiLineString" ("GeometryID", "geom", "fid", "RestrictionTypeID", "RoadName", "USRN", "OpenDate", "CPZ", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "ParkingTariffArea") VALUES ('B_ 000000035', '0105000020346C000001000000010200000005000000CBFC6A88C7DD1341F817CC58449224419CFD1396EDDD1341CD5A9DE849922441D5A1D4AEF6DD13419D1D51593A922441EE54232BD0DD1341D707ECF234922441CBFC6A88C7DD1341F817CC5844922441', 7, 116, 'Hanover Street', '1003', '2020-05-01', 'B', -1, 1, NULL, NULL, NULL, 'C2');


--
-- TOC entry 4040 (class 2606 OID 21169)
-- Name: Bays_MultiLineString Bays_MultiLineString_pkey; Type: CONSTRAINT; Schema: export; Owner: postgres
--

ALTER TABLE ONLY "export"."Bays_MultiLineString"
    ADD CONSTRAINT "Bays_MultiLineString_pkey" PRIMARY KEY ("GeometryID");


--
-- TOC entry 4183 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE "Bays_MultiLineString"; Type: ACL; Schema: export; Owner: postgres
--

GRANT SELECT ON TABLE "export"."Bays_MultiLineString" TO "toms_public";
GRANT SELECT ON TABLE "export"."Bays_MultiLineString" TO "toms_operator";
GRANT SELECT ON TABLE "export"."Bays_MultiLineString" TO "toms_admin";


-- Completed on 2020-12-13 12:03:40

--
-- PostgreSQL database dump complete
--

