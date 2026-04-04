/**
setup test data for VRMs
**/

DROP TABLE IF EXISTS demand."VRMs_test" CASCADE;
CREATE TABLE demand."VRMs_test"
(
  "ID" SERIAL,
  "SurveyID" integer,
  "SectionID" integer,
  "GeometryID" character varying(12),
  "PositionID" integer,
  "VRM" character varying(12),
  "VehicleTypeID" integer,
  "RestrictionTypeID" integer,
  "PermitTypeID" integer,
  "Notes" character varying(255),
  CONSTRAINT "VRMs_test_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE demand."VRMs_test"
  OWNER TO postgres;

--
-- TOC entry 4710 (class 0 OID 2069533)
-- Dependencies: 527
-- Data for Name: VRMs_test; Type: TABLE DATA; Schema: demand; Owner: postgres
--

INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (299, 101, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (300, 101, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (301, 101, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (650, 102, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (651, 102, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (652, 102, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (1058, 103, NULL, 'S_002571', NULL, 'ND60-FEO', 2, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (1059, 103, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (1060, 103, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (1531, 104, NULL, 'S_002571', NULL, 'ND60-FEO', 2, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (1532, 104, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (1533, 104, NULL, 'S_002697', NULL, 'EG17-XYW', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (1534, 104, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (2037, 105, NULL, 'S_002571', NULL, 'ND60-FEO', 2, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (2038, 105, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (2039, 105, NULL, 'S_002697', NULL, 'EG17-XYW', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (2040, 105, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (2589, 106, NULL, 'S_002571', NULL, 'ND60-FEO', 2, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (2590, 106, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (2591, 106, NULL, 'S_002697', NULL, 'GK54-ZBN', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (2592, 106, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (3180, 107, NULL, 'S_002571', NULL, 'ND60-FEO', 2, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (3181, 107, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (3182, 107, NULL, 'S_002697', NULL, 'D166-EYP', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (3183, 107, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (3764, 108, NULL, 'S_002571', NULL, 'ND60-FEO', 2, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (3765, 108, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (3766, 108, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (4306, 109, NULL, 'S_002571', NULL, 'ND60-FEO', 2, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (4307, 109, NULL, 'S_002571', NULL, 'RJ05-UZL', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (4308, 109, NULL, 'S_002697', NULL, 'FR12-TWE', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (4827, 110, NULL, 'S_002571', NULL, 'B20-NED', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (4828, 110, NULL, 'S_002571', NULL, 'LB70-BKA', 1, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (4829, 110, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (5291, 111, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (5292, 111, NULL, 'S_002697', NULL, 'EA67-SYG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (5293, 111, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (5828, 112, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (5829, 112, NULL, 'S_002571', NULL, 'EW19-KJO', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (5830, 112, NULL, 'S_002697', NULL, 'EA67-SYG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (5831, 112, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (6263, 201, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (6264, 201, NULL, 'S_002571', NULL, 'OE68-LYH', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (6265, 201, NULL, 'S_002697', NULL, 'EA67-SYG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (6266, 201, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (6733, 202, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (6734, 202, NULL, 'S_002571', NULL, 'OE68-LYH', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (6735, 202, NULL, 'S_002697', NULL, 'EA67-SYG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (6736, 202, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (7243, 203, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (7244, 203, NULL, 'S_002571', NULL, 'OU65-AFK', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (7245, 203, NULL, 'S_002697', NULL, 'EA67-SYG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (7246, 203, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (7827, 204, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (7828, 204, NULL, 'S_002571', NULL, 'OU65-AFK', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (7829, 204, NULL, 'S_002697', NULL, 'EA67-SYG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (7830, 204, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (8495, 205, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (8496, 205, NULL, 'S_002571', NULL, 'OU65-AFK', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (8497, 205, NULL, 'S_002697', NULL, 'DG06-ZTH', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (8498, 205, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (9264, 206, NULL, 'S_002571', NULL, 'AK57-EXF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (9265, 206, NULL, 'S_002571', NULL, 'OU65-AFK', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (9266, 206, NULL, 'S_002697', NULL, 'PF57-RPV', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (9267, 206, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (10003, 207, NULL, 'S_002571', NULL, 'MRZ-5132', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (10004, 207, NULL, 'S_002571', NULL, 'OU65-AFK', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (10005, 207, NULL, 'S_002697', NULL, 'GL07-XUT', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (10006, 207, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (10767, 208, NULL, 'S_002571', NULL, 'LG59-VFB', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (10768, 208, NULL, 'S_002571', NULL, 'OU65-AFK', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (10769, 208, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (11443, 209, NULL, 'S_002571', NULL, 'OU65-AFK', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (11444, 209, NULL, 'S_002571', NULL, 'YO15-JWK', 9, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (11445, 209, NULL, 'S_002697', NULL, 'AP64-DTY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (11446, 209, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (12026, 210, NULL, 'S_002571', NULL, 'OU65-AFK', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (12027, 210, NULL, 'S_002571', NULL, 'YO15-JWK', 2, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (12028, 210, NULL, 'S_002697', NULL, 'AP64-DTY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (12029, 210, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (12570, 211, NULL, 'S_002571', NULL, 'GY69-FMA', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (12571, 211, NULL, 'S_002697', NULL, 'EA67-SYG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (12572, 211, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13035, 212, NULL, 'S_002571', NULL, 'GY62-XKZ', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13036, 212, NULL, 'S_002571', NULL, 'KS58-RMU', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13037, 212, NULL, 'S_002697', NULL, 'EA67-SYG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13038, 212, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13428, 301, NULL, 'S_002571', NULL, 'LG70-VJF', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13429, 301, NULL, 'S_002571', NULL, 'WR54-YZA', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13430, 301, NULL, 'S_002697', NULL, 'DU14-TKT', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13830, 302, NULL, 'S_002571', NULL, 'WR54-YZA', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (13831, 302, NULL, 'S_002697', NULL, 'DU14-TKT', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (14252, 303, NULL, 'S_002571', NULL, 'CK09-NHC', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (14253, 303, NULL, 'S_002571', NULL, 'WR54-YZA', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (14254, 303, NULL, 'S_002697', NULL, 'DU14-TKT', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (14255, 303, NULL, 'S_002697', NULL, 'EY59-RKU', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (14785, 304, NULL, 'S_002571', NULL, 'GM17-AUU', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (14786, 304, NULL, 'S_002697', NULL, 'DU14-TKT', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (14787, 304, NULL, 'S_002697', NULL, 'YK55-AGY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (15338, 305, NULL, 'S_002571', NULL, 'GF12-VNO', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (15953, 306, NULL, 'S_002571', NULL, 'GY63-XGN', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (15954, 306, NULL, 'S_002571', NULL, 'LS12-DZY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (15955, 306, NULL, 'S_002697', NULL, 'GP19-DWM', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (15956, 306, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (16579, 307, NULL, 'S_002571', NULL, 'GY63-XGN', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (16580, 307, NULL, 'S_002571', NULL, 'LS12-DZY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (16581, 307, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (17244, 308, NULL, 'S_002571', NULL, 'EG17-JOH', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (17245, 308, NULL, 'S_002571', NULL, 'VA59-BNO', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (17246, 308, NULL, 'S_002697', NULL, 'HV21-UJG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (17247, 308, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (17962, 309, NULL, 'S_002571', NULL, 'EG17-JOH', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (17963, 309, NULL, 'S_002571', NULL, 'VA59-BNO', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (17964, 309, NULL, 'S_002697', NULL, 'HV21-UJG', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (17965, 309, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (18540, 310, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (19063, 311, NULL, 'S_002697', NULL, 'GY65-HTJ', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (19598, 312, NULL, 'S_002571', NULL, 'GF19-URX', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (19599, 312, NULL, 'S_002571', NULL, 'YK66-ECJ', 0, NULL, NULL, NULL);
INSERT INTO "demand"."VRMs_test" ("ID", "SurveyID", "SectionID", "GeometryID", "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitTypeID", "Notes") VALUES (19600, 312, NULL, 'S_002697', NULL, 'V222-ROY', 0, NULL, NULL, NULL);

-- Surveys ...

DROP TABLE IF EXISTS demand."Surveys_test" CASCADE;
CREATE TABLE "demand"."Surveys_test" (
    "SurveyID" integer NOT NULL,
    "SurveyDay" character varying(50),
    "BeatStartTime" character varying(10),
    "BeatEndTime" character varying(10),
    "BeatTitle" character varying(100),
    "SiteArea" character varying(50)
);

ALTER TABLE "demand"."Surveys_test" OWNER TO "postgres";

INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (101, 'Wednesday', '0700', '0800', '101_Wednesday_0700_0800', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (102, 'Wednesday', '0800', '0900', '102_Wednesday_0800_0900', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (103, 'Wednesday', '0900', '1000', '103_Wednesday_0900_1000', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (104, 'Wednesday', '1000', '1100', '104_Wednesday_1000_1100', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (105, 'Wednesday', '1100', '1200', '105_Wednesday_1100_1200', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (106, 'Wednesday', '1200', '1300', '106_Wednesday_1200_1300', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (107, 'Wednesday', '1300', '1400', '107_Wednesday_1300_1400', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (108, 'Wednesday', '1400', '1500', '108_Wednesday_1400_1500', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (109, 'Wednesday', '1500', '1600', '109_Wednesday_1500_1600', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (110, 'Wednesday', '1600', '1700', '110_Wednesday_1600_1700', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (111, 'Wednesday', '1700', '1800', '111_Wednesday_1700_1800', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (112, 'Wednesday', '1800', '1900', '112_Wednesday_1800_1900', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (201, 'Thursday', '0700', '0800', '201_Thursday_0700_0800', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (202, 'Thursday', '0800', '0900', '202_Thursday_0800_0900', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (203, 'Thursday', '0900', '1000', '203_Thursday_0900_1000', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (204, 'Thursday', '1000', '1100', '204_Thursday_1000_1100', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (205, 'Thursday', '1100', '1200', '205_Thursday_1100_1200', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (206, 'Thursday', '1200', '1300', '206_Thursday_1200_1300', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (207, 'Thursday', '1300', '1400', '207_Thursday_1300_1400', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (208, 'Thursday', '1400', '1500', '208_Thursday_1400_1500', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (209, 'Thursday', '1500', '1600', '209_Thursday_1500_1600', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (210, 'Thursday', '1600', '1700', '210_Thursday_1600_1700', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (211, 'Thursday', '1700', '1800', '211_Thursday_1700_1800', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (212, 'Thursday', '1800', '1900', '212_Thursday_1800_1900', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (301, 'Saturday', '0700', '0800', '301_Saturday_0700_0800', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (302, 'Saturday', '0800', '0900', '302_Saturday_0800_0900', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (303, 'Saturday', '0900', '1000', '303_Saturday_0900_1000', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (304, 'Saturday', '1000', '1100', '304_Saturday_1000_1100', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (305, 'Saturday', '1100', '1200', '305_Saturday_1100_1200', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (306, 'Saturday', '1200', '1300', '306_Saturday_1200_1300', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (307, 'Saturday', '1300', '1400', '307_Saturday_1300_1400', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (308, 'Saturday', '1400', '1500', '308_Saturday_1400_1500', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (309, 'Saturday', '1500', '1600', '309_Saturday_1500_1600', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (310, 'Saturday', '1600', '1700', '310_Saturday_1600_1700', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (311, 'Saturday', '1700', '1800', '311_Saturday_1700_1800', NULL);
INSERT INTO "demand"."Surveys_test" ("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime", "BeatTitle", "SiteArea") VALUES (312, 'Saturday', '1800', '1900', '312_Saturday_1800_1900', NULL);

ALTER TABLE ONLY "demand"."Surveys_test"
    ADD CONSTRAINT "Surveys_test_pkey" PRIMARY KEY ("SurveyID");

-- Supply

DROP TABLE IF EXISTS "mhtc_operations"."Supply_test" CASCADE;
CREATE TABLE "mhtc_operations"."Supply_test" (
    "GeometryID" character varying(12),
    "geom" "public"."geometry"(LineString,27700),
    "RestrictionLength" double precision,
    "RestrictionTypeID" integer,
    "GeomShapeID" integer,
    "AzimuthToRoadCentreLine" double precision,
    "Notes" character varying(254),
    "Photos_01" character varying(255),
    "Photos_02" character varying(255),
    "Photos_03" character varying(255),
    "RoadName" character varying(254),
    "USRN" character varying(254),
    "label_pos" "public"."geometry"(MultiPoint,27700),
    "label_ldr" "public"."geometry"(MultiLineString,27700),
    "label_loading_pos" "public"."geometry"(MultiPoint,27700),
    "label_loading_ldr" "public"."geometry"(MultiLineString,27700),
    "OpenDate" "date",
    "CloseDate" "date",
    "CPZ" character varying(40),
    "LastUpdateDateTime" timestamp without time zone,
    "LastUpdatePerson" character varying(255),
    "BayOrientation" double precision,
    "NrBays" integer,
    "TimePeriodID" integer,
    "PayTypeID" integer,
    "MaxStayID" integer,
    "NoReturnID" integer,
    "NoWaitingTimeID" integer,
    "NoLoadingTimeID" integer,
    "UnacceptableTypeID" integer,
    "ParkingTariffArea" character varying(10),
    "AdditionalConditionID" integer,
    "ComplianceRoadMarkingsFaded" integer,
    "ComplianceRestrictionSignIssue" integer,
    "ComplianceLoadingMarkingsFaded" integer,
    "ComplianceNotes" character varying(254),
    "MHTC_CheckIssueTypeID" integer,
    "MHTC_CheckNotes" character varying(254),
    "PayParkingAreaID" character varying(255),
    "PermitCode" character varying(255),
    "MatchDayTimePeriodID" integer,
    "MatchDayEventDayZone" character varying(40),
    "SectionID" integer,
    "StartStreet" character varying(254),
    "EndStreet" character varying(254),
    "SideOfStreet" character varying(100),
    "Capacity" integer,
    "BayWidth" double precision,
    "SurveyArea" character varying(254),
    "DisplayLabel" boolean,
    "label_Rotation" double precision,
    "label_TextChanged" character varying(254),
    "RestrictionID" character varying(254),
    "labelLoading_Rotation" double precision,
    "labelLoading_TextChanged" character varying(254)
);

ALTER TABLE "mhtc_operations"."Supply_test" OWNER TO "postgres";

INSERT INTO "mhtc_operations"."Supply_test" ("GeometryID", "geom", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", "SurveyArea", "DisplayLabel", "label_Rotation", "label_TextChanged", "RestrictionID", "labelLoading_Rotation", "labelLoading_TextChanged") VALUES ('S_003073', '0102000020346C00004F0000003D039A99361022417B1A3D33735CFD400000000037102241CDCCCCCC7C5CFD40000000003710224101000000885CFD40CDCCCCCC36102241676666668E5CFD40AFF7AEF92C1022411212CEA15E5DFD40BB2B8FDA2710224146BCD32ECB5DFD406766666627102241CDCCCCCCD45DFD409A9999992610224134333333EB5DFD40000000002610224101000000005EFD403433333326102241676666660E5EFD409A9999992610224101000000205EFD40CDCCCCCC2610224134333333235EFD4034333333271022419A999999415EFD40E852D99128102241E53F288C6A5EFD40000000002B10224134333333B35EFD4051F71FB531102241C570BA036B5FFD40CDCCCCCC3D10224167666666B660FD400000000041102241676666660661FD40343333333F102241343333330B61FD4052B81E0544102241010000006061FD40000000004810224167666666A661FD4090C2F528481022415D8FC2F5A861FD40343333334A10224134333333CB61FD40E13531584B10224169BCA47DD961FD4090C2F5284D10224190C2F528F061FD40676666664D10224134333333F361FD409A9999994E1022419A9999990162FD40D7A3703D51102241AF47E17A1C62FD405BE7EA71511022417E86FE7B1E62FD409A99999951102241010000002062FD400000000056102241CDCCCCCC4462FD409A99999959102241676666665E62FD4037385B6C5A1022415ED981946362FD4015AE47615B1022419A9999996962FD40295C8F425E102241010000007C62FD40676666665E102241CDCCCCCC7C62FD4059AC74446210224183EC186D9162FD40CDCCCCCC631022419A9999999962FD4039075684681022414B83BE77AC62FD407B14AE476A10224153B81E85B362FD40CDCCCCCC6B1022419A999999B962FD40000000006F1022419A999999C162FD40E257D4F26F1022415E49427FC362FD40676666667A10224101000000C062FD40676666668510224101000000C062FD403433333389102241CDCCCCCCBC62FD40152AF1EB8A102241FC6C312DBA62FD40676666668D10224167666666B662FD40FEA47C5592102241C0C1FF89AD62FD403433333397102241CDCCCCCCA462FD40031AFEE3A4102241FFE629F08F62FD409A999999B4102241010000007862FD4000000000B91022419A9999997162FD406CC04F6FBB102241EB6817656F62FD409A999999C3102241010000006862FD4051E705DCC4102241BD1CC2476762FD4034333333C9102241CDCCCCCC6462FD4006A7E05CD110224176181B6C6162FD40CDCCCCCCD4102241010000006062FD4000000000DF1022419A9999996162FD4000000000E1102241343333336362FD40CDCCCCCCE9102241343333336B62FD403017B20BEC10224108433B9F6E62FD4034333333F2102241010000007862FD40F6FB80A6FB10224108A97C3E8662FD400000000000112241CDCCCCCC8C62FD4048E17A140B11224167666666B262FD40D3F5C85D0D112241C886E632BA62FD409A999999111122413E0AD7A3C862FD40343333B313112241713D0AD7CF62FD406822219F20112241289EFCBEFB62FD40151D71262D112241F78E0C512663FD400000000030112241010000003063FD40469AF71232112241D4D386EF3763FD409A999999341122419A9999994163FD403433333335112241CDCCCCCC4463FD409A99999935112241010000004863FD4067666666361122419A9999995163FD40F72F999936112241207F5C665663FD40', 218.88, 202, 10, 135, NULL, NULL, NULL, NULL, 'The Mint', '4', '0104000020346C000001000000010100000033E2BD4E6410224132EF5DA19B62FD40', '0105000020346C00000100000001020000000200000033E2BD4E6410224132EF5DA19B62FD4033E2BD4E6410224132EF5DA19B62FD40', '0104000020346C000001000000010100000033E2BD4E6410224132EF5DA19B62FD40', '0105000020346C00000100000001020000000200000033E2BD4E6410224132EF5DA19B62FD4033E2BD4E6410224132EF5DA19B62FD40', NULL, NULL, NULL, '2021-08-24 10:50:19.585393', 'postgres', NULL, -1, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 82, NULL, NULL, 'North', 0, NULL, '1', true, 26.56505117707799, NULL, NULL, 26.56505117707799, NULL);
INSERT INTO "mhtc_operations"."Supply_test" ("GeometryID", "geom", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", "SurveyArea", "DisplayLabel", "label_Rotation", "label_TextChanged", "RestrictionID", "labelLoading_Rotation", "labelLoading_TextChanged") VALUES ('S_002571', '0102000020346C000004000000343333330C1122419A9999995162FD4067666666091122419A9999994962FD400000000000112241CDCCCCCC2C62FD40B74FE0C9FC1022413BB4B2C22762FD40', 8.16, 103, 21, 342, 'Mon-Sat', NULL, NULL, NULL, 'The Mint', '10', '0104000020346C0000010000000101000000AED930BF7511224115DFB4574360FD40', '0105000020346C000001000000010200000002000000E830698F04112241305D8CC53A62FD40AED930BF7511224115DFB4574360FD40', '0104000020346C0000010000000101000000E830698F04112241305D8CC53A62FD40', '0105000020346C000001000000010200000002000000E830698F04112241305D8CC53A62FD40E830698F04112241305D8CC53A62FD40', NULL, NULL, NULL, '2021-08-24 10:49:06.745364', 'postgres', NULL, -1, 220, NULL, 3, 3, NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 104, NULL, NULL, 'South', 1, NULL, '5', true, NULL, NULL, NULL, 20.955774760343363, NULL);
INSERT INTO "mhtc_operations"."Supply_test" ("GeometryID", "geom", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", "SurveyArea", "DisplayLabel", "label_Rotation", "label_TextChanged", "RestrictionID", "labelLoading_Rotation", "labelLoading_TextChanged") VALUES ('S_002253', '0102000020346C000003000000A9E3313310112241CDCCCCCC5462FD40343333330F112241CDCCCCCC5462FD40343333330C1122419A9999995162FD40', 2.01, 202, 10, 66, NULL, NULL, NULL, NULL, 'The Mint', '10', '0104000020346C0000010000000101000000331B13320E112241EF6E88BA5362FD40', '0105000020346C000001000000010200000002000000331B13320E112241EF6E88BA5362FD40331B13320E112241EF6E88BA5362FD40', '0104000020346C0000010000000101000000331B13320E112241EF6E88BA5362FD40', '0105000020346C000001000000010200000002000000331B13320E112241EF6E88BA5362FD40331B13320E112241EF6E88BA5362FD40', NULL, NULL, NULL, '2021-08-24 10:48:22.233542', 'postgres', NULL, -1, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 104, NULL, NULL, 'South', 0, NULL, '5', true, 7.59464446326376, NULL, NULL, NULL, NULL);
INSERT INTO "mhtc_operations"."Supply_test" ("GeometryID", "geom", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", "SurveyArea", "DisplayLabel", "label_Rotation", "label_TextChanged", "RestrictionID", "labelLoading_Rotation", "labelLoading_TextChanged") VALUES ('S_002697', '0102000020346C000002000000F09E3440E510224155BE07D30262FD40B74FE0C9FC1022413BB4B2C22762FD40', 11.99, 110, 21, 347, NULL, NULL, NULL, NULL, 'The Mint', '10', '0104000020346C000001000000010100000054770A05F11022414839DD4A1562FD40', '0105000020346C00000100000001020000000200000054770A05F11022414839DD4A1562FD4054770A05F11022414839DD4A1562FD40', '0104000020346C000001000000010100000054770A05F11022414839DD4A1562FD40', '0105000020346C00000100000001020000000200000054770A05F11022414839DD4A1562FD4054770A05F11022414839DD4A1562FD40', NULL, NULL, NULL, '2021-08-24 10:49:06.745364', 'postgres', NULL, -1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 104, NULL, NULL, 'South', 2, NULL, '5', true, 11.097884334414506, NULL, NULL, NULL, NULL);
INSERT INTO "mhtc_operations"."Supply_test" ("GeometryID", "geom", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", "SurveyArea", "DisplayLabel", "label_Rotation", "label_TextChanged", "RestrictionID", "labelLoading_Rotation", "labelLoading_TextChanged") VALUES ('S_002844', '0102000020346C0000070000000B043D23BD102241914FAB512F62FD40295C8F42BE1022412A5C8FC22D62FD4086EB5138C61022410BD7A3702562FD40713D0AD7CD10224148E17A142262FD4048E17A94DF102241676666661A62FD40CDCCCCCCE0102241713D0AD7FB61FD40F09E3440E510224155BE07D30262FD40', 21.56, 202, 10, 1, NULL, NULL, NULL, NULL, 'The Mint', '10', '0104000020346C000001000000010100000010AEF696D2102241011915062062FD40', '0105000020346C00000100000001020000000200000010AEF696D2102241011915062062FD4010AEF696D2102241011915062062FD40', '0104000020346C000001000000010100000010AEF696D2102241011915062062FD40', '0105000020346C00000100000001020000000200000010AEF696D2102241011915062062FD4010AEF696D2102241011915062062FD40', NULL, NULL, NULL, '2021-08-24 10:50:19.585393', 'postgres', NULL, -1, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 104, NULL, NULL, 'South', 0, NULL, '5', true, -3.0975395517364093, NULL, NULL, NULL, NULL);
INSERT INTO "mhtc_operations"."Supply_test" ("GeometryID", "geom", "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "Notes", "Photos_01", "Photos_02", "Photos_03", "RoadName", "USRN", "label_pos", "label_ldr", "label_loading_pos", "label_loading_ldr", "OpenDate", "CloseDate", "CPZ", "LastUpdateDateTime", "LastUpdatePerson", "BayOrientation", "NrBays", "TimePeriodID", "PayTypeID", "MaxStayID", "NoReturnID", "NoWaitingTimeID", "NoLoadingTimeID", "UnacceptableTypeID", "ParkingTariffArea", "AdditionalConditionID", "ComplianceRoadMarkingsFaded", "ComplianceRestrictionSignIssue", "ComplianceLoadingMarkingsFaded", "ComplianceNotes", "MHTC_CheckIssueTypeID", "MHTC_CheckNotes", "PayParkingAreaID", "PermitCode", "MatchDayTimePeriodID", "MatchDayEventDayZone", "SectionID", "StartStreet", "EndStreet", "SideOfStreet", "Capacity", "BayWidth", "SurveyArea", "DisplayLabel", "label_Rotation", "label_TextChanged", "RestrictionID", "labelLoading_Rotation", "labelLoading_TextChanged") VALUES ('S_003066', '0102000020346C00002E00000019E725713F102241E18758B88C5CFD403CDF4FCD3E102241FFD478E9905CFD40F4FDD4B83C10224163105839BE5CFD407D3F351E391022416F1283C00C5DFD408C6CE73B36102241B17268914B5DFD4083C0CAA135102241115839B4585DFD40DE2406413110224148E17A14B85DFD407368912D31102241B39DEFA7BA5DFD4005560E2D2F10224192ED7C3FFF5DFD4096438BAC2E102241DCF97E6A105EFD40B7F3FD942E102241FFD478E9225EFD4046B6F37D2F102241631058395A5EFD4052B81EC531102241E04F8D97A85EFD40448B6C6732102241F6285C8FC25EFD403AB4C83635102241B5C876BE2F5FFD406BBC7493391022419A999999BF5FFD40676666663A102241A5703D0AD75FFD40CDCCCCCC3F102241A5703D0A5760FD40CDCCCCCC421022413E0AD7A39860FD40B91C775B4410224197FEEB8BB460FD40CDCCCCCC47102241D8A3703DF260FD40676666664D102241D8A3703D4A61FD40CDCCCCCC52102241D8A3703D9261FD400000000056102241D8A3703DBA61FD40000000005A102241713D0AD7EB61FD40BC3078E35B102241C724BCB9FE61FD40CDCCCCCC5E102241713D0AD71B62FD4034333333641022410BD7A3704562FD4036A52FC764102241C1DA38504962FD403E0AD72368102241713D0AD75F62FD409A999999691022411F85EB516862FD4086EB51B86B102241676666667262FD4090C2F5A86D102241F6285C8F7A62FD40C3F528DC6F1022410BD7A3708162FD40E27A142E74102241713D0AD78762FD40B91E856B761022412A5C8FC28962FD4015AE47E178102241343333338B62FD40034763E17A10224175D943C28B62FD40E27A142E7F1022415D8FC2F58C62FD40D7A370BD89102241F6285C8F8A62FD403433333391102241D8A3703D8262FD40AE47E17A9C102241343333336F62FD401D5908839D1022411C9D13276D62FD40F6285C0FA410224190C2F5286062FD40A4703D0AB8102241676666663662FD403D703A23BD10224115E4AE512F62FD40', 145.73, 202, 10, 285, NULL, NULL, NULL, NULL, 'The Mint', '10', '0104000020346C0000010000000101000000F35D641547102241550AC566E560FD40', '0105000020346C000001000000010200000002000000F35D641547102241550AC566E560FD40F35D641547102241550AC566E560FD40', '0104000020346C0000010000000101000000F35D641547102241550AC566E560FD40', '0105000020346C000001000000010200000002000000F35D641547102241550AC566E560FD40F35D641547102241550AC566E560FD40', NULL, NULL, NULL, '2021-08-24 10:50:19.585393', 'postgres', NULL, -1, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 84, NULL, NULL, 'East', 0, NULL, '1', true, 65.94265044083797, NULL, NULL, NULL, NULL);




