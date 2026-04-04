-- bayline type demand details


-- vehicle types

INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (0, NULL, 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (1, 'Car', 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (2, 'LGV', 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU", "PCUinSameTypeBay") VALUES (3, 'MCL', 0.2, 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (4, 'OGV', 1.5);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (5, 'Bus', 2.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU", "PCUinSameTypeBay") VALUES (6, 'PCL', 0.1, 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (7, 'Taxi', 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (8, 'Other', 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (9, NULL, 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (10, 'Obstruction', 0.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (11, 'Minibus', 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU", "PCUinSameTypeBay") VALUES (12, 'E-Scooter', 0.1, 1.0);
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU", "PCUinSameTypeBay") VALUES (13, 'Dockless PCL', 0.1, 1.0);
--INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (14, 'Campervan', 1.0);
--INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (15, 'Car+Caravan', 2.0);
--INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description", "PCU") VALUES (16, 'RV', 2.0);

-- permit types

INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (0, NULL);

INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (1, 'Resident (Zone)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (2, 'Resident (Other)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (3, 'Visitor voucher');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (4, 'Disabled (Blue badge)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (5, 'Essential Service Permit (ESP)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (6, 'Business permit');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (7, 'Companion');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (8, 'Carer''s permit');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (9, 'No visible permit');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (10, 'Boroughwide and Utility Permit');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (11, 'Car Club permit');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (12, 'Doctor''s Permit');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (13, 'Monthly Resident');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (14, 'Visitor Voucher concessionary');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (15, 'Trader''s permit');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (16, 'Other (inc. Coronavirus Permit)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (17, 'No permit required (MCL)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (18, 'No permit required (Non Resident MCL)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (19, 'Homes for Haringey');

INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (20, 'Short stay P&D');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (21, 'Long stay P&D');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (22, 'Councillor');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (23, 'Police');

-- User types

INSERT INTO "demand_lookups"."UserTypes" ("Code", "Description") VALUES (1, 'Resident');
INSERT INTO "demand_lookups"."UserTypes" ("Code", "Description") VALUES (2, 'Commuter');
INSERT INTO "demand_lookups"."UserTypes" ("Code", "Description") VALUES (3, 'Visitor');

-- Foreign reg plates

INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (0, '', 'Default');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (1, 'A', 'Austria');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (2, 'B', 'Belgium');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (3, 'BG', 'Bulgaria');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (4, 'CH', 'Switzerland');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (5, 'CZ', 'Czech Republic');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (6, 'D', 'Germany');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (7, 'DK', 'Denmark');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (8, 'E', 'Spain');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (9, 'EST', 'Estonia');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (10, 'F', 'France');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (11, 'FIN', 'Finland');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (12, 'GBG', 'Guernsey');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (13, 'GBJ', 'Jersey');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (14, 'GBM', 'Isle of Man');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (15, 'GR', 'Greece');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (16, 'H', 'Hungary');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (17, 'I', 'Italy');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (18, 'L', 'Luxembourg');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (19, 'N', 'Norway');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (20, 'NL', 'Netherlands');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (21, 'P', 'Portugal');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (22, 'PL', 'Poland');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (23, 'RO', 'Romania');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (24, 'S', 'Sweden');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (25, 'SK', 'Slovakia');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (26, 'SLO', 'Slovenia');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (27, 'UA', 'Ukraine');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (28, 'LV', 'Latvia');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (29, 'LT', 'Lithuania');
INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (30, 'IRL', 'Ireland');

INSERT INTO "demand_lookups"."InternationalCodes" ("Code", "Description", "Country") VALUES (99, 'Other', 'Other');

-- Parking Activity types

INSERT INTO "demand_lookups"."ParkingActivityTypes" ("Code", "Description") VALUES (0, NULL);
INSERT INTO "demand_lookups"."ParkingActivityTypes" ("Code", "Description") VALUES (1, 'Parked');
INSERT INTO "demand_lookups"."ParkingActivityTypes" ("Code", "Description") VALUES (2, 'Waiting');
INSERT INTO "demand_lookups"."ParkingActivityTypes" ("Code", "Description") VALUES (3, 'Loading');
INSERT INTO "demand_lookups"."ParkingActivityTypes" ("Code", "Description") VALUES (4, 'Other');

-- Parking Manner types

INSERT INTO "demand_lookups"."ParkingMannerTypes" ("Code", "Description") VALUES (0, NULL);
INSERT INTO "demand_lookups"."ParkingMannerTypes" ("Code", "Description") VALUES (1, 'Parallel');
INSERT INTO "demand_lookups"."ParkingMannerTypes" ("Code", "Description") VALUES (2, 'Perpendicular');
INSERT INTO "demand_lookups"."ParkingMannerTypes" ("Code", "Description") VALUES (3, 'Echelon');
INSERT INTO "demand_lookups"."ParkingMannerTypes" ("Code", "Description") VALUES (4, '2 Wheels on footpath');
INSERT INTO "demand_lookups"."ParkingMannerTypes" ("Code", "Description") VALUES (5, '4 Wheels on footpath');
INSERT INTO "demand_lookups"."ParkingMannerTypes" ("Code", "Description") VALUES (6, 'on crossover');

-- Duration categories

INSERT INTO "demand_lookups"."DurationCategories" VALUES (1, '00:00:00', '01:00:00', '<1 hour');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (2, '01:00:00', '02:00:00', '1-2 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (3, '02:00:00', '03:00:00', '2-3 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (4, '03:00:00', '04:00:00', '3-4 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (5, '04:00:00', '05:00:00', '4-5 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (6, '05:00:00', '06:00:00', '5-6 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (7, '06:00:00', '07:00:00', '6-7 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (8, '07:00:00', '08:00:00', '7-8 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (9, '08:00:00', '09:00:00', '8-9 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (10, '09:00:00', '10:00:00', '9-10 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (11, '10:00:00', '11:00:00', '10-11 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (12, '11:00:00', '100000:00:00', '>11 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (0, '00:00:00', '-1000:00:00', 'unknown');

/***
INSERT INTO "demand_lookups"."DurationCategories" VALUES (1, '00:00:00', '02:00:00', '<2 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (2, '02:00:00', '04:00:00', '2-4 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (3, '04:00:00', '06:00:00', '4-6 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (4, '06:00:00', '08:00:00', '6-8 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (5, '08:00:00', '10:00:00', '8-10 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (6, '10:00:00', '12:00:00', '10-12 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (7, '12:00:00', '14:00:00', '12-14 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (8, '14:00:00', '100000:00:00', '>14 hours');
INSERT INTO "demand_lookups"."DurationCategories" VALUES (0, '00:00:00', '-1000:00:00', 'unknown');
***/