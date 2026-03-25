-- Update approach for linking to PM after load

UPDATE toms."Bays" b
SET "GeomShapeID" = 23
WHERE "GeometryID" IN (

SELECT r."GeometryID"

	FROM local_authority."All Confirmed Orders_lines" p,
	(SELECT "GeometryID", SUBSTRING(b."Notes", '\d+')::integer AS pmid
	FROM toms."Bays" b) r

	WHERE p.pmid = r.pmid
	AND p.order_type = '4 Wheel Parking'
	);