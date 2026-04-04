--

REVOKE ALL ON ALL TABLES IN SCHEMA compliance FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA compliance TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA compliance TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA compliance TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA compliance TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA compliance_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA compliance_lookups TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA compliance_lookups TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA compliance_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA compliance_lookups TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA demand FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA demand TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA demand TO toms_admin, toms_operator;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA demand TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA demand TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA demand_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA demand_lookups TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA demand_lookups TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA demand_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA demand_lookups TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA highway_asset_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA highway_asset_lookups TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA highway_asset_lookups TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA highway_asset_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA highway_asset_lookups TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA highway_assets FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA highway_assets TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA highway_assets TO toms_admin, toms_operator;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA highway_assets TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA highway_assets TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA highways_network FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA highways_network TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA highways_network TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA highways_network TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA highways_network TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA local_authority FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA local_authority TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA local_authority TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA local_authority TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA local_authority TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA mhtc_operations FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA mhtc_operations TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA mhtc_operations TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA toms FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA toms TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA toms TO toms_admin, toms_operator;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA toms TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA toms TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA toms_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA toms_lookups TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA toms_lookups TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA toms_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA toms_lookups TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA topography FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA topography TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA topography TO toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA topography TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA topography TO toms_public, toms_operator, toms_admin;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."Corners" TO toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."SectionBreakPoints" TO toms_operator, toms_admin;
