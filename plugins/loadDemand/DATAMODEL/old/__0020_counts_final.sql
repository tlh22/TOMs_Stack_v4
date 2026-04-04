-- Counts_Final ??

-- RiS

DROP TABLE IF EXISTS demand."RestrictionsInSurveys_Final";

CREATE TABLE IF NOT EXISTS demand."RestrictionsInSurveys_Final"
(
    "SurveyID" integer NOT NULL,
    "GeometryID" character varying(12) COLLATE pg_catalog."default" NOT NULL,
    "DemandSurveyDateTime" timestamp without time zone,
    "Enumerator" character varying(100) COLLATE pg_catalog."default",
    "Done" boolean,
    "SuspensionReference" character varying(100) COLLATE pg_catalog."default",
    "SuspensionReason" character varying(255) COLLATE pg_catalog."default",
    "SuspensionLength" double precision,
    "NrBaysSuspended" integer,
    "SuspensionNotes" character varying(255) COLLATE pg_catalog."default",
    "Photos_01" character varying(255) COLLATE pg_catalog."default",
    "Photos_02" character varying(255) COLLATE pg_catalog."default",
    "Photos_03" character varying(255) COLLATE pg_catalog."default",
    --geom geometry(LineString,27700) NOT NULL,
    CONSTRAINT "RestrictionsInSurveys_Final_pkey" PRIMARY KEY ("SurveyID", "GeometryID")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys_Final"
    OWNER to postgres;
-- Index: RiS_unique_idx

DROP INDEX IF EXISTS demand."RiS_Final_unique_idx";

CREATE UNIQUE INDEX IF NOT EXISTS "RiS_Final_unique_idx"
    ON demand."RestrictionsInSurveys_Final" USING btree
    ("SurveyID" ASC NULLS LAST, "GeometryID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

-- Insert records that were not Done

INSERT INTO demand."RestrictionsInSurveys_Final"("SurveyID", "GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference",
"SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", "Photos_01", "Photos_02", "Photos_03")
SELECT "SurveyID", RiS."GeometryID", "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference",
"SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes", RiS."Photos_01", RiS."Photos_02", RiS."Photos_03"
FROM demand."RestrictionsInSurveys" RiS, mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID"
--AND "Done" IS NULL OR "Done" IS false
;

/***
UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "geom" = s."geom"
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";
***/

-- Update capacity and demand

ALTER TABLE demand."RestrictionsInSurveys_Final"
    ADD COLUMN "Capacity" INTEGER;

ALTER TABLE demand."RestrictionsInSurveys_Final"
    ADD COLUMN "Demand" FLOAT;

ALTER TABLE demand."RestrictionsInSurveys_Final"
    ADD COLUMN "Stress" FLOAT;

---

UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "Capacity" =
     CASE WHEN (s."Capacity" - COALESCE(RiS."NrBaysSuspended", 0)) > 0 THEN (s."Capacity" - COALESCE(RiS."NrBaysSuspended", 0))
         ELSE 0
         END
FROM mhtc_operations."Supply" s
WHERE RiS."GeometryID" = s."GeometryID";

-- Demand

UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "Demand" = v."Demand"
FROM
(SELECT "SurveyID", "GeometryID",
      COALESCE("NrCars"::float, 0.0) +
        COALESCE("NrLGVs"::float, 0.0) +
        COALESCE("NrMCLs"::float, 0.0)*0.33 +
        (COALESCE("NrOGVs"::float, 0.0) + COALESCE("NrMiniBuses"::float, 0.0) + COALESCE("NrBuses"::float, 0.0))*1.5 +
        COALESCE("NrTaxis"::float, 0.0) +
        (COALESCE("NrPCLs"::float, 0.0) + COALESCE("NrEScooters"::float, 0.0) + COALESCE("NrDocklessPCLs"::float, 0.0))*0.2
         AS "Demand",
			 "Notes"
   FROM demand."Counts"
  ) AS v
WHERE RiS."GeometryID" = v."GeometryID"
AND RiS."SurveyID" = v."SurveyID";

-- Stress

UPDATE demand."RestrictionsInSurveys_Final" RiS
SET "Stress" =
    CASE
        WHEN "Capacity" = 0 THEN
            CASE
                WHEN COALESCE("Demand", 0) > 0.0 THEN 100.0
                ELSE 0.0
            END
        ELSE
            COALESCE("Demand", 0) / "Capacity"::float * 100.0
    END;

-- Output

SELECT d."SurveyID", d."SurveyDay", d."BeatStartTime" || '-' || d."BeatEndTime" AS "SurveyTime", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description", d."RoadName", d."SideOfStreet",
d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", d."Demand"
FROM
(SELECT ris."SurveyID", su."SurveyDay", su."BeatStartTime", su."BeatEndTime", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" AS "RestrictionType Description", s."RoadName", s."SideOfStreet",
"DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
ris."Photos_01", ris."Photos_02", ris."Photos_03", ris."Capacity", ris."Demand"
FROM demand."RestrictionsInSurveys_Final" ris, demand."Surveys" su,
(mhtc_operations."Supply" AS a
 LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") AS s
 WHERE ris."SurveyID" = su."SurveyID"
 AND ris."GeometryID" = s."GeometryID"
 --AND s."CPZ" = '7S'
 --AND substring(su."BeatTitle" from '\((.+)\)') LIKE '7S%'
 ) as d

WHERE d."SurveyID" > 0
--AND d."Done" IS true
AND d."RoadName" NOT LIKE '%Car Park%'
ORDER BY d."SurveyID", d."GeometryID";