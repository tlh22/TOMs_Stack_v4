--

SELECT v."ID", v."SurveyID", s."SurveyDay", s."BeatStartTime" || '-' || s."BeatEndTime" AS "SurveyTime",
        v."GeometryID", v."RestrictionTypeID", v."RestrictionType Description",
        v."RoadName", v."SideOfStreet",
		v."PositionID", v."VRM",
		v."VehicleTypeID", v."VehicleType Description", v."PCU",
        v."PermitTypeID", v."PermitType Description",
        v."Notes", "Enumerator", "DemandSurveyDateTime",
        r."NrBaysSuspended",
        CONCAT( COALESCE("SuspensionReference" || '; ', ''), COALESCE("SuspensionReason" || '; ', ''),
                 COALESCE("SuspensionLength" || '; ', ''), COALESCE("SuspensionNotes" || '; ', '') )

FROM
(SELECT "ID", "SurveyID", a."GeometryID", "PositionID", "VRM",
"VehicleTypeID", "VehicleTypes"."Description" AS "VehicleType Description", "VehicleTypes"."PCU" AS "PCU",
       su."RestrictionTypeID",
		"BayLineTypes"."Description" AS "RestrictionType Description",
        "PermitTypeID", "PermitTypes"."Description" AS "PermitType Description",
        a."Notes", "RoadName", "SideOfStreet"

FROM
     ((((demand."VRMs_Final" AS a
	 LEFT JOIN mhtc_operations."Supply" AS su ON a."GeometryID" = su."GeometryID")
     LEFT JOIN "toms_lookups"."BayLineTypes" AS "BayLineTypes" ON su."RestrictionTypeID" is not distinct from "BayLineTypes"."Code")
     LEFT JOIN "demand_lookups"."VehicleTypes" AS "VehicleTypes" ON a."VehicleTypeID" is not distinct from "VehicleTypes"."Code")
     LEFT JOIN "demand_lookups"."PermitTypes" AS "PermitTypes" ON a."PermitTypeID" is not distinct from "PermitTypes"."Code")
ORDER BY "GeometryID", "VRM") As v
	 	, demand."Surveys" s
		, demand."RestrictionsInSurveys_Final" r
WHERE v."SurveyID" = s."SurveyID"
AND r."SurveyID" = s."SurveyID"
AND r."GeometryID" = v."GeometryID"
AND s."SurveyID" > 0
--AND su."CPZ" = 'HS'
--AND s."SurveyID" > 20 and s."SurveyID" < 30
ORDER BY "GeometryID", "VRM", "SurveyID"
