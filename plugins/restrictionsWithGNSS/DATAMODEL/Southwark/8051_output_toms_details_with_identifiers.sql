/***
Script to transfer AppyWay ids to TOMs data

Original import used ogc_fid field as identifier. This has been transferred? to TOMs data.

New id from AppyWay is ospId. Need create table to link this IDs


***/


-- Now output details

DROP TABLE IF EXISTS mhtc_operations."Southwark_output_with_identifers";

CREATE TABLE IF NOT EXISTS mhtc_operations."Southwark_output_with_identifers"
AS

SELECT "GeometryID"
, x.ogc_fid
, "ospId"
, "RoadName"
, "RestrictionTypeID"
, "RestrictionDescription"
, "RestrictionGeometryShapeTypeID"
, "RestrictionGeometryShapeDescription"
, "AzimuthToRoadCentreLine"
, "CPZ"
, "NrBays"
, "TimePeriodID"
, "TimePeriodDescription"
, "MaxStayID"
, "MaxStayDescription"
, "NoReturnID"
, "NoReturnDescription"
, "NoWaitingTimeID"
, "NoWaitingTimeDescription"
, "NoLoadingTimeID"
, "NoLoadingTimeDescription"
, "Length"
, geom

FROM (

	SELECT a."GeometryID"
	, ogc_fid
	, "RoadName"
	, a."RestrictionTypeID"
	, "BayLineTypes"."Description" AS "RestrictionDescription"
	, "GeomShapeID" AS "RestrictionGeometryShapeTypeID"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionGeometryShapeDescription"
	, "AzimuthToRoadCentreLine"
	, a."CPZ"
	, "NrBays"
	, a."TimePeriodID"
	, COALESCE("TimePeriods1"."Description", '') AS "TimePeriodDescription"
	, "MaxStayID"
	, COALESCE("LengthOfTime1"."Description", '') AS "MaxStayDescription"
	, "NoReturnID"
	, COALESCE("LengthOfTime2"."Description", '') AS "NoReturnDescription"
	, NULL AS "NoWaitingTimeID" 
	, NULL AS "NoWaitingTimeDescription"
	, NULL AS "NoLoadingTimeID"
	, NULL AS "NoLoadingTimeDescription"
	, ST_Length(a.geom) AS "Length"
	, a.geom

	FROM toms."Bays" a 
			LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
			LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
			LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."TimePeriodID" is not distinct from "TimePeriods1"."Code"
			LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime1" ON a."MaxStayID" is not distinct from "LengthOfTime1"."Code"
			LEFT JOIN "toms_lookups"."LengthOfTime" AS "LengthOfTime2" ON a."NoReturnID" is not distinct from "LengthOfTime2"."Code"
			, toms."ControlledParkingZones" c
			
	WHERE c."CPZ" = 'C1'
	AND ST_Within(a.geom, c.geom)
	
	UNION
	
	SELECT a."GeometryID"
	, ogc_fid
	, "RoadName"
	, a."RestrictionTypeID"
	, "BayLineTypes"."Description" AS "RestrictionDescription"
	, "GeomShapeID" AS "RestrictionGeometryShapeTypeID"
	, COALESCE("RestrictionGeomShapeTypes"."Description", '') AS "RestrictionGeometryShapeDescription"
	, "AzimuthToRoadCentreLine"
	, a."CPZ"
	, NULL AS "NrBays"
	, NULL AS "TimePeriodID"
	, NULL AS "TimePeriodDescription"
	, NULL AS "MaxStayID"
	, NULL AS "MaxStayDescription"
	, NULL AS "NoReturnID"
	, NULL AS "NoReturnDescription"
	, a."NoWaitingTimeID"
	, COALESCE("TimePeriods1"."Description", '') AS "NoWaitingTimeDescription"
	, "NoLoadingTimeID"
	, COALESCE("TimePeriods2"."Description", '') AS "NoLoadingTimeDescription"
	, ST_Length(a.geom) AS "Length"
	, a.geom

	FROM toms."Lines" a 
		LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON a."RestrictionTypeID" is not distinct from "BayLineTypes"."Code"
		LEFT JOIN "toms_lookups"."RestrictionGeomShapeTypes" AS "RestrictionGeomShapeTypes" ON a."GeomShapeID" is not distinct from "RestrictionGeomShapeTypes"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods1" ON a."NoWaitingTimeID" is not distinct from "TimePeriods1"."Code"
		LEFT JOIN "toms_lookups"."TimePeriods" AS "TimePeriods2" ON a."NoLoadingTimeID" is not distinct from "TimePeriods2"."Code"
		, toms."ControlledParkingZones" c
			
	WHERE c."CPZ" = 'C1'
	AND ST_Within(a.geom, c.geom)	
	
	) x
	LEFT JOIN import_geojson."Identifier_Transfer" i ON i.ogc_fid = x.ogc_fid
;

ALTER TABLE mhtc_operations."Southwark_output_with_identifers"
    OWNER to postgres;

ALTER TABLE mhtc_operations."Southwark_output_with_identifers"
    ADD PRIMARY KEY ("GeometryID");