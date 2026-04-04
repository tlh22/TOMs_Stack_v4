/***
 * Set up permisssions for wider use ...
 ***/

REVOKE ALL ON ALL TABLES IN SCHEMA addresses FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA addresses TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA addresses TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA addresses TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA compliance FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA compliance TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA compliance TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA compliance TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA compliance_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA compliance_lookups TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA compliance_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA compliance_lookups TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA demand FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA demand TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA demand TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA demand TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA demand_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA demand_lookups TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA demand_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA demand_lookups TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA highways_network FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA highways_network TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA highways_network TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA highways_network TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA local_authority FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA local_authority TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA local_authority TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA local_authority TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA mhtc_operations FROM toms_public, toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA mhtc_operations TO toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA toms TO toms_public;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA toms_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA toms_lookups TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA toms_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA toms_lookups TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA topography FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA topography TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA topography TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA topography TO toms_public, toms_operator, toms_admin;

--- TOMs main tables

REVOKE ALL ON ALL TABLES IN SCHEMA toms FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA toms TO toms_public, toms_operator, toms_admin;
GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA toms TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA toms TO toms_public, toms_operator, toms_admin;

-- Demand tables

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE demand."RestrictionsInSurveys" TO toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE demand."Counts" TO toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE demand."VRMs" TO toms_operator, toms_admin;
GRANT SELECT ON TABLE demand."Surveys" TO toms_operator, toms_admin;
GRANT SELECT ON TABLE demand."TimePeriodsControlledDuringSurveyHours" TO toms_operator, toms_admin;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."Supply" TO toms_operator, toms_admin;

GRANT CREATE ON SCHEMA local_authority TO toms_admin;


GRANT CREATE ON SCHEMA mhtc_operations TO toms_admin;