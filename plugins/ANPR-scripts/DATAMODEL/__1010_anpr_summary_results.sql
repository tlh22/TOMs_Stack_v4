-- Output table

DROP TABLE IF EXISTS "anpr"."ANPRSummaryResults";
CREATE TABLE "anpr"."ANPRSummaryResults" (
    "gid" SERIAL,
    "CarParkID" integer,
	"TimePeriodID" integer,
	"TotalStartTimePeriod" integer,
	"TotalIn" integer,
	"TotalOut" integer,
	"TotalEndTimePeriod" integer
);

ALTER TABLE "anpr"."ANPRSummaryResults" OWNER TO "postgres";

ALTER TABLE "anpr"."ANPRSummaryResults"
    ADD PRIMARY KEY ("gid");