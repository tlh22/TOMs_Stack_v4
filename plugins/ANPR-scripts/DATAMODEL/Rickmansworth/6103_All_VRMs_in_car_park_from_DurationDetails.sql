-- Output of duration for ALL vehicles at car park with vehicle type and permit type

SELECT "CarParkDescription"
        --, "VRM"
		, "AnonomisedVRM"
		, "VehicleTypeID"
		, "VehicleTypeDescription"
		, "PermitTypeID"
		, "PermitTypeDescription"
		, "SurveyDay"
		, "Time_IN"
		, "TimePeriodDescription_IN" AS "TimePeriod_IN"
		, "Time_OUT"
		, "TimePeriodDescription_OUT" AS "TimePeriod_OUT"
		, "Duration"
		, "DurationCategoryDescription" AS "DurationCategory"

FROM anpr."DurationDetails"
WHERE "CarParkID" = x
;
