-- Duration Categories

DROP TABLE IF EXISTS "demand_lookups"."DurationCategories" CASCADE;
CREATE TABLE "demand_lookups"."DurationCategories" (
    "DurationCategoryID" SERIAL,
    "StartTime" INTERVAL,
    "EndTime" INTERVAL,
    "Description" character varying
);

ALTER TABLE "demand_lookups"."DurationCategories"
    ADD PRIMARY KEY ("DurationCategoryID");

-- Now load

COPY demand_lookups."DurationCategories"("DurationCategoryID", "StartTime", "EndTime", "Description")
FROM 'C:\Users\Public\Documents\DurationCategories.csv'
DELIMITER ','
CSV HEADER;
