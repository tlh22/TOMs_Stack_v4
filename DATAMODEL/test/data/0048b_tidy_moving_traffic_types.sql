/**
Tidy ...
**/

-- Add vehicleQualifiers
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    WHERE t.typnamespace = 'moving_traffic_lookups'::regnamespace
      AND t.typname = 'vehicleTypeValue'
      AND e.enumlabel = 'Permit Holders'
  ) THEN
    ALTER TYPE "moving_traffic_lookups"."vehicleTypeValue" ADD VALUE 'Permit Holders';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    WHERE t.typnamespace = 'moving_traffic_lookups'::regnamespace
      AND t.typname = 'vehicleTypeValue'
      AND e.enumlabel = 'Taxis'
  ) THEN
    ALTER TYPE "moving_traffic_lookups"."vehicleTypeValue" ADD VALUE 'Taxis';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    WHERE t.typnamespace = 'moving_traffic_lookups'::regnamespace
      AND t.typname = 'vehicleTypeValue'
      AND e.enumlabel = 'Goods Vehicles Exceeding 18.5t'
  ) THEN
    ALTER TYPE "moving_traffic_lookups"."vehicleTypeValue" ADD VALUE 'Goods Vehicles Exceeding 18.5t';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    WHERE t.typnamespace = 'moving_traffic_lookups'::regnamespace
      AND t.typname = 'vehicleTypeValue'
      AND e.enumlabel = 'Goods Vehicles Exceeding 5t'
  ) THEN
    ALTER TYPE "moving_traffic_lookups"."vehicleTypeValue" ADD VALUE 'Goods Vehicles Exceeding 5t';
  END IF;
END $$;

