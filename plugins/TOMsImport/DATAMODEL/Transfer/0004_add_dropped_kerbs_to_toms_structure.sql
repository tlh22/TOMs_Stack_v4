-- take the tables with the processed records and move them to TOMs structure

--ALTER TABLE toms."Lines" DISABLE TRIGGER update_capacity_lines;

INSERT INTO toms."Lines"(
	geom, "Notes", "RoadName", "USRN", "CPZ", "RestrictionID", "RestrictionTypeID", "GeomShapeID", "UnacceptableTypeID")
SELECT (ST_Dump(geom)).geom AS geom, CONCAT(pmid, ' ', order_type, ' ',  street_nam, ' ', side_of_ro, ' ', schedule, ' ', mr_schedul, ' ', echelon) ,
    street_nam, nsg, zoneno, uuid_generate_v4(), 220, 10, 4
	FROM local_authority."Dropped Kerb Data_lines"
	WHERE "order_type" = 'Dropped Kerb - PX';

INSERT INTO toms."Lines"(
	geom, "Notes", "RoadName", "USRN", "CPZ", "RestrictionID", "RestrictionTypeID", "GeomShapeID", "UnacceptableTypeID")
SELECT (ST_Dump(geom)).geom AS geom, CONCAT(pmid, ' ', order_type, ' ',  street_nam, ' ', side_of_ro, ' ', schedule, ' ', mr_schedul, ' ', echelon) ,
    street_nam, nsg, zoneno, uuid_generate_v4(), 220, 10, 1
	FROM local_authority."Dropped Kerb Data_lines"
	WHERE "order_type" != 'Dropped Kerb - PX';

--ALTER TABLE toms."Lines" ENABLE TRIGGER update_capacity_lines;

-- Need to add Open date ...