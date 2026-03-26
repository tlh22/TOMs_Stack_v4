/**
Tidy ...
**/

INSERT INTO "moving_traffic_lookups"."vehicleQualifiers" ("Code", "Description", "vehicle", "use", "load") VALUES (16, 'Buses, Taxis and Pedal Cycles', '{Buses,Taxis, "Pedal Cycles"}', NULL, NULL)
ON CONFLICT ("Code") DO UPDATE
SET "Description" = EXCLUDED."Description",
    "vehicle" = EXCLUDED."vehicle",
    "use" = EXCLUDED."use",
    "load" = EXCLUDED."load";

INSERT INTO "moving_traffic_lookups"."vehicleQualifiers" ("Code", "Description", "vehicle", "use", "load") VALUES (17, 'Taxis and Permit Holders', '{Taxis, "Permit Holders"}', NULL, NULL)
ON CONFLICT ("Code") DO UPDATE
SET "Description" = EXCLUDED."Description",
    "vehicle" = EXCLUDED."vehicle",
    "use" = EXCLUDED."use",
    "load" = EXCLUDED."load";

INSERT INTO "moving_traffic_lookups"."vehicleQualifiers" ("Code", "Description", "vehicle", "use", "load") VALUES (18, 'Goods Vehicles Exceeding 18.5t', '{"Goods Vehicles Exceeding 18.5t"}', NULL, NULL)
ON CONFLICT ("Code") DO UPDATE
SET "Description" = EXCLUDED."Description",
    "vehicle" = EXCLUDED."vehicle",
    "use" = EXCLUDED."use",
    "load" = EXCLUDED."load";

INSERT INTO "moving_traffic_lookups"."vehicleQualifiers" ("Code", "Description", "vehicle", "use", "load") VALUES (19, 'Goods Vehicles Exceeding 5t', '{"Goods Vehicles Exceeding 5t"}', NULL, NULL)
ON CONFLICT ("Code") DO UPDATE
SET "Description" = EXCLUDED."Description",
    "vehicle" = EXCLUDED."vehicle",
    "use" = EXCLUDED."use",
    "load" = EXCLUDED."load";

-- Modify T to t

DO $$
BEGIN
  BEGIN
    ALTER TYPE "moving_traffic_lookups"."vehicleTypeValue"
      RENAME VALUE 'Goods Vehicles Exceeding 7.5T' TO 'Goods Vehicles Exceeding 7.5t';
  EXCEPTION WHEN OTHERS THEN
    -- Idempotent: ignore if the label was already renamed / missing.
    NULL;
  END;
END $$;
UPDATE "moving_traffic_lookups"."vehicleQualifiers"
SET "Description" = 'Goods Vehicles Exceeding 7.5t'
WHERE "Code" = 1;

DO $$
BEGIN
  BEGIN
    ALTER TYPE "moving_traffic_lookups"."vehicleTypeValue"
      RENAME VALUE 'Goods Vehicles Exceeding 16.5T' TO 'Goods Vehicles Exceeding 16.5t';
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
END $$;
UPDATE "moving_traffic_lookups"."vehicleQualifiers"
SET "Description" = 'Goods Vehicles Exceeding 16.5t'
WHERE "Code" = 5;

DO $$
BEGIN
  BEGIN
    ALTER TYPE "moving_traffic_lookups"."vehicleTypeValue"
      RENAME VALUE 'Goods Vehicles Exceeding 18T' TO 'Goods Vehicles Exceeding 18t';
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
END $$;
UPDATE "moving_traffic_lookups"."vehicleQualifiers"
SET "Description" = 'Goods Vehicles Exceeding 18t'
WHERE "Code" = 6;

DO $$
BEGIN
  BEGIN
    ALTER TYPE "moving_traffic_lookups"."vehicleTypeValue"
      RENAME VALUE 'Goods Vehicles Exceeding 3T' TO 'Goods Vehicles Exceeding 3t';
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
END $$;
UPDATE "moving_traffic_lookups"."vehicleQualifiers"
SET "Description" = 'Goods Vehicles Exceeding 3t'
WHERE "Code" = 11;
