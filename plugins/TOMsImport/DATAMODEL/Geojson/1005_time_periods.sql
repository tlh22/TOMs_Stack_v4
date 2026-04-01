-- deal with the time periods

CREATE TABLE import_geojson."TimePeriods_Transfer"
(
    id SERIAL,
    control_time_details character varying(254) COLLATE pg_catalog."default",
    "TimePeriodDescription" character varying(254) COLLATE pg_catalog."default",
    "AdditionalConditionDescription" character varying(254) COLLATE pg_catalog."default",
    "TimePeriodCode" integer,
    "AdditionalConditionCode" integer
)

TABLESPACE pg_default;

ALTER TABLE import_geojson."TimePeriods_Transfer"
    OWNER to postgres;

ALTER TABLE import_geojson."TimePeriods_Transfer"
    ADD PRIMARY KEY (id);

INSERT INTO import_geojson."TimePeriods_Transfer"(
	control_time_details)
SELECT DISTINCT hours_of_operation
FROM (SELECT hours_of_operation
     FROM import_geojson."Merged_Bays"
     UNION
     SELECT hours_of_operation
     FROM import_geojson."Merged_Lines") AS a;

UPDATE import_geojson."TimePeriods_Transfer"
SET "TimePeriodDescription" = control_time_details;

 ... manual update of values ...

UPDATE import_geojson."TimePeriods_Transfer" As p
	SET "TimePeriodCode"=l."Code"
	FROM toms_lookups."TimePeriods" l
	WHERE p."TimePeriodDescription" = l."Description"
    AND p."TimePeriodCode" IS NULL;

-- now update

UPDATE import_geojson."Merged_Bays" As p
	SET "TimePeriodID"=l."TimePeriodCode"
	FROM import_geojson."TimePeriods_Transfer" l
	WHERE p.hours_of_operation = l.control_time_details;

UPDATE import_geojson."Merged_Lines" As p
	SET "NoWaitingTimeID"=l."TimePeriodCode"
	FROM import_geojson."TimePeriods_Transfer" l
	WHERE p.hours_of_operation = l.control_time_details;