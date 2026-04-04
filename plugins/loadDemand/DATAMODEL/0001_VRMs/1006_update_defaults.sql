-- Need to be selective ...

UPDATE demand."VRMs"
SET "PermitTypeID" = 17  -- MCL
WHERE "VehicleTypeID" = 3;

UPDATE demand."VRMs"
SET "PermitTypeID" = 9
WHERE "PermitTypeID" = 0 OR "PermitTypeID" IS NULL;

--

UPDATE demand."VRMs"
SET "VehicleTypeID" = 2
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 2
);

UPDATE demand."VRMs"
SET "VehicleTypeID" = 3
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 3
);

UPDATE demand."VRMs"
SET "VehicleTypeID" = 4
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 4
);

UPDATE demand."VRMs"
SET "VehicleTypeID" = 5
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 5
);

UPDATE demand."VRMs"
SET "VehicleTypeID" = 14
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 14
);

UPDATE demand."VRMs"
SET "VehicleTypeID" = 15
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 15
);


UPDATE demand."VRMs"
SET "VehicleTypeID" = 16
WHERE "VRM" IN (
    SELECT "VRM"
    FROM demand."VRMs"
    WHERE "VehicleTypeID" = 16
);


-- anything else is car

UPDATE demand."VRMs"
SET "VehicleTypeID" = 1  -- Car
WHERE "VehicleTypeID" = 0;


-- Parking Activity Types
UPDATE demand."VRMs"
SET "ParkingActivityTypeID" = 1  -- Parked
WHERE "ParkingActivityTypeID" IS NULL OR "ParkingActivityTypeID" = 0;

-- Parking Manner Types
UPDATE demand."VRMs" AS v
SET "ParkingMannerTypeID" = -- Should match the type of the bay
	CASE WHEN s."GeomShapeID" IN (4, 6, 24, 26) THEN 2  -- Perpendicular
	     WHEN s."GeomShapeID" IN (5, 9, 25, 29) THEN 3  -- Echelon
		 ELSE 1
		 END 
FROM mhtc_operations."Supply" s
WHERE v."GeometryID" = s."GeometryID"
AND "ParkingMannerTypeID" IS NULL OR "ParkingMannerTypeID" = 0;