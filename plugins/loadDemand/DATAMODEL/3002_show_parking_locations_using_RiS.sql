-- create view with to show stress

drop materialized view IF EXISTS demand."Demand_view_to_show_parking_locations" CASCADE;

create MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations"
TABLESPACE pg_default
AS

    select row_number() over (partition by true::boolean) as id,
    sv."GeometryID", sv.geom, sv."RestrictionTypeID", sv."GeomShapeID", sv."AzimuthToRoadCentreLine", sv."BayOrientation",
    case when f."Demand" > sv."NrBays" then f."Demand"
         else sv."NrBays"
    end as "NrBays",
    f."Capacity",
    f."SurveyID", ROUND(CAST(f."Demand" AS numeric), 0) as "Demand"

    from demand."Supply_for_viewing_parking_locations" sv,

        (select d."SurveyID", d."BeatTitle", d."GeometryID", d."RestrictionTypeID", d."RestrictionType Description",
        d."DemandSurveyDateTime", d."Enumerator", d."Done", d."SuspensionReference", d."SuspensionReason", d."SuspensionLength", d."NrBaysSuspended", d."SuspensionNotes",
        d."Photos_01", d."Photos_02", d."Photos_03", d."Capacity", d."Demand"
        from
        (select ris."SurveyID", su."BeatTitle", ris."GeometryID", s."RestrictionTypeID", s."Description" as "RestrictionType Description",
        "DemandSurveyDateTime", "Enumerator", "Done", "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended", "SuspensionNotes",
        ris."CapacityAtTimeOfSurvey" As "Capacity", "Demand", "Stress",
        ris."Photos_01", ris."Photos_02", ris."Photos_03"
        from demand."RestrictionsInSurveys" ris, demand."Surveys" su,
        (mhtc_operations."Supply" as a
         left join "toms_lookups"."BayLineTypes" as "BayLineTypes" on a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code") as s
         where ris."SurveyID" = su."SurveyID"
         and ris."GeometryID" = s."GeometryID"
         AND s."RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169, 130, 165, 166)  -- MCL, PCL, Scooters, etc (and private areas)
 		 AND su."SurveyID" > 0
		 --AND s."RoadName" != 'Spurgeon''s College Car Park'
			 ) as d

        order by d."RestrictionTypeID", d."GeometryID", d."SurveyID") as f

	WHERE f."GeometryID" = sv."GeometryID"
	AND f."SurveyID" = sv."SurveyID"
	
with DATA;

alter table demand."Demand_view_to_show_parking_locations"
    OWNER TO postgres;

create UNIQUE INDEX "idx_Demand_view_to_show_parking_locations_id"
    ON demand."Demand_view_to_show_parking_locations" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations";


--
-- Active suspensions
/***
drop materialized view IF EXISTS demand."Demand_view_to_show_parking_locations" CASCADE;

create MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations"
TABLESPACE pg_default
AS

    select row_number() over (partition by true::boolean) as id,
    "SurveyID", "GeometryID", geom, "RestrictionTypeID", "GeomShapeID", "AzimuthToRoadCentreLine", "BayOrientation",
    case when "Demand" > "NrBays" then "Demand"
         else "NrBays"
    end as "NrBays",
    "Capacity", "Demand"

    from demand."Supply_for_viewing_parking_locations" s

         WHERE "RestrictionTypeID" NOT IN (116, 117, 118, 119, 144, 147, 149, 150, 168, 169)  -- MCL, PCL, Scooters, etc

        order by "RestrictionTypeID", "GeometryID", "SurveyID"

with DATA;

alter table demand."Demand_view_to_show_parking_locations"
    OWNER TO postgres;

create UNIQUE INDEX "idx_Demand_view_to_show_parking_locations_id"
    ON demand."Demand_view_to_show_parking_locations" USING btree
    (id)
    TABLESPACE pg_default;

REFRESH MATERIALIZED VIEW demand."Demand_view_to_show_parking_locations";
***/