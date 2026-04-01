--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4 (Debian 12.4-1.pgdg100+1)
-- Dumped by pg_dump version 12.4

-- Started on 2020-12-13 12:49:14

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
-- TOC entry 387 (class 1259 OID 27492)
-- Name: PM_Lines_Transfer; Type: TABLE; Schema: local_authority; Owner: postgres
--

CREATE TABLE "local_authority"."PM_Lines_Transfer" (
    "id" integer NOT NULL,
    "geom" "public"."geometry"(LineString,27700),
    "pmid" bigint,
    "order_type" character varying(50),
    "street_nam" character varying(100),
    "side_of_ro" character varying(60),
    "schedule" character varying(15),
    "mr_schedul" character varying(15),
    "nsg" character varying(10),
    "zoneno" bigint,
    "no_of_spac" bigint,
    "echelon" character varying(1),
    "times_of_e" character varying(254),
    "RestrictionTypeID" integer,
    "TimePeriodID" integer,
    "GeometryID" character varying(12)
);


ALTER TABLE "local_authority"."PM_Lines_Transfer" OWNER TO "postgres";

--
-- TOC entry 386 (class 1259 OID 27490)
-- Name: PM_Lines_Transfer_id_seq; Type: SEQUENCE; Schema: local_authority; Owner: postgres
--

CREATE SEQUENCE "local_authority"."PM_Lines_Transfer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "local_authority"."PM_Lines_Transfer_id_seq" OWNER TO "postgres";

--
-- TOC entry 4360 (class 0 OID 0)
-- Dependencies: 386
-- Name: PM_Lines_Transfer_id_seq; Type: SEQUENCE OWNED BY; Schema: local_authority; Owner: postgres
--

ALTER SEQUENCE "local_authority"."PM_Lines_Transfer_id_seq" OWNED BY "local_authority"."PM_Lines_Transfer"."id";


--
-- TOC entry 4212 (class 2604 OID 27495)
-- Name: PM_Lines_Transfer id; Type: DEFAULT; Schema: local_authority; Owner: postgres
--

ALTER TABLE ONLY "local_authority"."PM_Lines_Transfer" ALTER COLUMN "id" SET DEFAULT "nextval"('"local_authority"."PM_Lines_Transfer_id_seq"'::"regclass");


--
-- TOC entry 4353 (class 0 OID 27492)
-- Dependencies: 387
-- Data for Name: PM_Lines_Transfer; Type: TABLE DATA; Schema: local_authority; Owner: postgres
--

INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (14, '0102000020346C000004000000173F690FE0DC13410491F4FF6D932441173F690FE0DC13410491F4FF6D9324412EEBB9D619DD134120B86016769324412EEBB9D619DD134120B8601676932441', 14, 'No Waiting At Any Time (DYL)', 'Queen Street', NULL, NULL, NULL, '1001', NULL, NULL, 'F', 'At Any Time', 202, 1, 'L_ 000000006');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (10, '0102000020346C000004000000D9756F60E7DB134124C4B40C4B932441D9756F60E7DB134124C4B40C4B932441AF9F016900DC13415DE1AB8F4E932441AF9F016900DC13415DE1AB8F4E932441', 10, 'No Waiting At Any Time (DYL)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'F', 'At Any Time', 202, 1, 'L_ 000000002');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (15, '0102000020346C00000F000000BEC1911D4FDD13417F2E46E54292244142C50CF54FDD13415BCEB27441922441C8B978B748DD13419C8EDAF54192244157B5DA2843DD1341958EDB953F922441DDA946EB3BDD1341D64E0317409224416CA5A85C36DD1341CF4E04B73D922441F299141F2FDD1341100F2C383E9224418195769029DD1341090F2DD83B922441078AE25222DD13414ACF54593C922441958544C41CDD134143CF55F9399224411C7AB08615DD1341858F7D7A3A922441AA7512F80FDD13417E8F7E1A38922441316A7EBA08DD1341BF4FA69B38922441BF65E02B03DD1341B84FA73B36922441940F335402DD1341F65433AC37922441', 15, 'Zig Zag - School', 'George Street', NULL, NULL, NULL, '1012', NULL, NULL, 'F', 'Mon-Fri 8.15am-9.15am 3.00pm-6.00pm', 203, 11, 'L_ 000000008');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (2, '0102000020346C000004000000277FFE140FDE1341584EF5F35E9224410532C80B11DE13415AC3F2975B922441DB7F6942C4DD1341D0E9DF5E50922441FDCC9F4BC2DD1341CE74E2BA53922441', 2, 'Bus Stop', 'George Street', NULL, NULL, NULL, '1012', NULL, 0, 'F', 'At Any Time', 107, 1, 'B_ 000000029');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (13, '0102000020346C00000F000000316D42B771DB13411E9577B83A9324417B9C37E870DB1341D2FF3F2A3C93244179E4CB4B6BDB134189276CD2399324410C8B4A1164DB1341A824295E3A9324410AD3DE745EDB13415F4C5506389324419D795D3A57DB13417E491292389324419BC1F19D51DB134135713E3A369324412E6870634ADB1341546EFBC5369324412CB004C744DB13410B96276E34932441BE56838C3DDB13412A93E4F934932441BD9E17F037DB1341E1BA10A2329324414F4596B530DB134100B8CD2D339324414E8D2A192BDB1341B7DFF9D530932441E033A9DE23DB1341D6DCB66131932441BD8781AD24DB1341F860E7EF2F932441', 13, 'Crossing - Zebra', 'Queen Street', NULL, NULL, NULL, '1001', NULL, NULL, 'F', 'At Any Time', 209, 1, 'L_ 000000005');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (16, '0102000020346C0000040000004B5C3906AADC134164742AC42A9224414B5C3906AADC134164742AC42A922441C1AFE1D396DC134102BEE5F527922441C1AFE1D396DC134102BEE5F527922441', 16, 'Crossing - Signalised', 'George Street', NULL, NULL, NULL, '1012', NULL, NULL, 'F', 'At Any Time', 214, 1, 'L_ 000000010');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (19, '0102000020346C00000400000036DED7B0FDDD1341A6D0C74D1793244136DED7B0FDDD1341A6D0C74D17932441372C5E8D5CDE1341D657D2C96A922441372C5E8D5CDE1341D657D2C96A922441', 19, 'No waiting (SYL)', 'North St David Street', NULL, NULL, NULL, '1005', NULL, NULL, 'F', 'Mon-Fri 8.00am-6.00pm Sat 8.00am-1.30pm', 224, 126, 'L_ 000000012');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (18, '0102000020346C000004000000D5BD6D47BDDD1341255083718C932441D5BD6D47BDDD1341255083718C932441078118ADE7DD134174B7FA563F932441078118ADE7DD134174B7FA563F932441', 18, 'No waiting (SYL)', 'North St David Street', NULL, NULL, NULL, '1005', NULL, NULL, 'F', 'Mon-Fri 8.00am-6.00pm Sat 8.00am-1.30pm', 224, 126, 'L_ 000000013');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (3, '0102000020346C000004000000FDCC9F4BC2DD1341CE74E2BA53922441EB8D55A0C7DD13414069929C4A922441D634A63BA1DD13417BFC080045922441E873F0E69BDD13410908591E4E922441', 3, 'On-Carriageway Bicycle Bay', 'George Street', NULL, NULL, NULL, '1012', NULL, 0, 'F', 'At Any Time', 119, 1, 'B_ 000000030');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (4, '0102000020346C000004000000E873F0E69BDD13410908591E4E9224416C776BBE9CDD1341E5A7C5AD4C922441571EBC5976DD1341203B3C1147922441D31A418275DD1341449BCF8148922441', 4, 'Loading Bay/Disabled Bay (Red Route)', 'George Street', NULL, NULL, NULL, '1012', NULL, 2, 'F', 'Mon-Fri 8.00am-6.00pm', 115, 15, 'B_ 000000031');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (5, '0102000020346C0000040000003A1C49579BDD1341779D10144F922441B618CE7F9ADD13419BFDA38450922441A1BF1E1B74DD1341D6901AE84A92244125C399F274DD1341B230877749922441', 4, 'Loading Bay/Disabled Bay (Red Route)', 'George Street', NULL, NULL, NULL, '1012', NULL, 2, 'F', 'Mon-Fri 8.00am-6.00pm', 115, 15, 'B_ 000000031');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (6, '0102000020346C000004000000D31A418275DD1341449BCF81489224414A4B59C171DD134113CA8F233F92244135F2A95C4BDD13414E5D068739922441BEC1911D4FDD13417F2E46E542922441', 6, 'Cycle Hire bay', 'George Street', NULL, NULL, NULL, '1012', NULL, 0, 'T', 'At Any Time', 116, 1, 'B_ 000000032');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (7, '0102000020346C000004000000E6B78BC401DD134164EAEAA138922441F7F6D56FFCDC1341F2F53AC0419224414D49E3B8DDDC1341873800433D9224413C0A990DE3DC1341F92CB02434922441', 7, 'Loading Bay/Disabled Bay (Red Route)', 'George Street', NULL, NULL, NULL, '1012', NULL, 3, 'F', 'Mon-Fri 8.00am-6.00pm', 115, 15, 'B_ 000000033');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (8, '0102000020346C0000040000003C0A990DE3DC1341F92CB024349224415E57CF16E1DC1341F7B7B28037922441BF51C87FA7DC1341D094E4152F9224419D049276A9DC1341D209E2B92B922441', 8, 'On-Carriageway Bicycle Bay', 'George Street', NULL, NULL, NULL, '1012', NULL, 0, 'F', 'Mon-Fri 8.00am-6.00pm', 119, 15, 'B_ 000000034');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (9, '0102000020346C000005000000CBFC6A88C7DD1341F817CC58449224419CFD1396EDDD1341CD5A9DE849922441D5A1D4AEF6DD13419D1D51593A922441EE54232BD0DD1341D707ECF234922441CBFC6A88C7DD1341F817CC5844922441', 9, 'Cycle Hire bay', 'Hanover Street', NULL, NULL, NULL, '1003', NULL, 0, 'F', 'At Any Time', 116, 1, 'B_ 000000035');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (17, '0102000020346C000004000000078118ADE7DD134174B7FA563F932441078118ADE7DD134174B7FA563F93244136DED7B0FDDD1341A6D0C74D1793244136DED7B0FDDD1341A6D0C74D17932441', 17, 'No waiting (SYL)', 'North St David Street', NULL, NULL, NULL, '1005', NULL, NULL, 'F', 'Mon-Fri 8.00am-9.30am 4.00pm-6.30pm', 224, 211, 'L_ 000000011');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (21, '0102000020346C000004000000E77D5CDE5BDE1341A469092D6A922441E77D5CDE5BDE1341A469092D6A922441217BCBB23FDE13419A7C020F66922441217BCBB23FDE13419A7C020F66922441', 21, 'No Waiting At Any Time (DYL)', 'George Street', NULL, NULL, NULL, '1012', NULL, NULL, 'F', 'At Any Time', 202, 1, 'L_ 000000017');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (20, '0102000020346C000004000000217BCBB23FDE13419A7C020F66922441217BCBB23FDE13419A7C020F6692244172FD73802CDE13411276BD406392244172FD73802CDE13411276BD4063922441', 20, 'No waiting (SYL)', 'George Street', NULL, NULL, NULL, '1012', NULL, NULL, 'F', 'Mon-Fri 8.00am-6.30pm', 224, 14, 'L_ 000000016');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (12, '0102000020346C0000040000003FA8F0C24DDC13419BADC05F599324413FA8F0C24DDC13419BADC05F59932441822EF5B89ADC1341AF34534B64932441822EF5B89ADC1341AF34534B64932441', 12, 'No waiting (SYL)', 'Queen Street', NULL, NULL, NULL, '1001', NULL, NULL, 'F', 'Mon-Fri 8.00am-6.00pm', 224, 15, 'L_ 000000004');
INSERT INTO "local_authority"."PM_Lines_Transfer" ("id", "geom", "pmid", "order_type", "street_nam", "side_of_ro", "schedule", "mr_schedul", "nsg", "zoneno", "no_of_spac", "echelon", "times_of_e", "RestrictionTypeID", "TimePeriodID", "GeometryID") VALUES (11, '0102000020346C000004000000A55203C1BEDB134144C9078145932441A55203C1BEDB134144C9078145932441316D42B771DB13411E9577B83A932441316D42B771DB13411E9577B83A932441', 11, 'No waiting (SYL)', 'Queen Street', NULL, NULL, NULL, '1001', NULL, NULL, 'F', 'Mon-Fri 8.00am-6.30pm', 224, 14, 'L_ 000000003');


--
-- TOC entry 4362 (class 0 OID 0)
-- Dependencies: 386
-- Name: PM_Lines_Transfer_id_seq; Type: SEQUENCE SET; Schema: local_authority; Owner: postgres
--

SELECT pg_catalog.setval('"local_authority"."PM_Lines_Transfer_id_seq"', 21, true);


--
-- TOC entry 4214 (class 2606 OID 35656)
-- Name: PM_Lines_Transfer PM_Lines_Transfer_pkey; Type: CONSTRAINT; Schema: local_authority; Owner: postgres
--

ALTER TABLE ONLY "local_authority"."PM_Lines_Transfer"
    ADD CONSTRAINT "PM_Lines_Transfer_pkey" PRIMARY KEY ("id");


--
-- TOC entry 4359 (class 0 OID 0)
-- Dependencies: 387
-- Name: TABLE "PM_Lines_Transfer"; Type: ACL; Schema: local_authority; Owner: postgres
--

GRANT SELECT ON TABLE "local_authority"."PM_Lines_Transfer" TO "toms_public";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "local_authority"."PM_Lines_Transfer" TO "toms_operator";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "local_authority"."PM_Lines_Transfer" TO "toms_admin";


--
-- TOC entry 4361 (class 0 OID 0)
-- Dependencies: 386
-- Name: SEQUENCE "PM_Lines_Transfer_id_seq"; Type: ACL; Schema: local_authority; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE "local_authority"."PM_Lines_Transfer_id_seq" TO "toms_public";
GRANT SELECT,USAGE ON SEQUENCE "local_authority"."PM_Lines_Transfer_id_seq" TO "toms_operator";
GRANT SELECT,USAGE ON SEQUENCE "local_authority"."PM_Lines_Transfer_id_seq" TO "toms_admin";


-- Completed on 2020-12-13 12:49:14

--
-- PostgreSQL database dump complete
--

