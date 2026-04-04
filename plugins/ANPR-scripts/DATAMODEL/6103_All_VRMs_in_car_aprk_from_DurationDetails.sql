-- Output of duration for ALL vehicles at car park with vehicle type and permit type

SELECT "CarParkDescription"
        , "VRM"
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
		, "DurationCatergoryDescription" AS DurationCategory

FROM anpr."DurationDetails"
WHERE "CarParkDescription" = ''
;
