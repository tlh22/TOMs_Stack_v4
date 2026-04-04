/***

Delete any tables that are not required

***/

-- Corner Protection tables

DROP TABLE IF EXISTS mhtc_operations."CornerApexPts" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."CornerProtectionSections" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."CornerProtectionSections_Single" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."CornerSegmentEndPts" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."CornerSegments" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."LineLengthAtCorner" CASCADE;

-- Supply tables

DROP TABLE IF EXISTS mhtc_operations."Corners_Single" CASCADE;

DROP TABLE IF EXISTS mhtc_operations."CrossoverNodes" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."CrossoverNodes_Single" CASCADE;

DROP TABLE IF EXISTS mhtc_operations."Supply_Copy" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."Supply_orig" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."Supply_orig2" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."Supply_orig3" CASCADE;
DROP TABLE IF EXISTS mhtc_operations."Supply_Overlaps" CASCADE;

-- Highways network

DROP TABLE IF EXISTS highways_network."RoadLink_2019" CASCADE;
DROP TABLE IF EXISTS highways_network."itn_roadcentreline" CASCADE;
DROP TABLE IF EXISTS highways_network."roadlink2" CASCADE;

-- schemas not required

DROP SCHEMA IF EXISTS addresses CASCADE;
DROP SCHEMA IF EXISTS audit CASCADE;
DROP SCHEMA IF EXISTS compliance CASCADE;
DROP SCHEMA IF EXISTS compliance_lookups CASCADE;
DROP SCHEMA IF EXISTS export CASCADE;
DROP SCHEMA IF EXISTS moving_traffic CASCADE;
DROP SCHEMA IF EXISTS moving_traffic_lookups CASCADE;
DROP SCHEMA IF EXISTS topography_updates CASCADE;
DROP SCHEMA IF EXISTS transfer CASCADE;

-- Other tables that are not required

DROP TABLE IF EXISTS public."RC_Polyline" CASCADE;
--DROP TABLE IF EXISTS public."RC_Sections_merged" CASCADE;


