
REVOKE ALL ON ALL TABLES IN SCHEMA demand FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA demand TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA demand TO toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA demand TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA demand TO toms_public, toms_operator, toms_admin;
GRANT CREATE ON SCHEMA demand TO toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA demand_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA demand_lookups TO toms_public, toms_operator;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA demand_lookups TO toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA demand_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA demand_lookups TO toms_public, toms_operator, toms_admin;
GRANT CREATE ON SCHEMA demand_lookups TO toms_operator, toms_admin;