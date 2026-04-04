-- deal with 0 and O
/***
 * Permitted marks are:

 1.  A group consisting of two letters and two numbers followed by a group of 3 letters (for example DE51 ABC).

Diagrams 1a and 1b.
2.  A group consisting of a single letter and not more than 3 numbers followed by a group of 3 letters (for example A123 ABC).

Diagrams 2a, 2b and 2c.
3.  A group of 3 letters followed by a group consisting of not more than 3 numbers and a single letter (for example ABC 123A).

Diagrams 3a, 3b and 3c.
4.  A group of 4 numbers followed by a single letter or a group of 2 letters (for example 1234 AB, 1234 A).

Diagrams 4a and 4b.
5.  A group of not more than 3 numbers followed by a group of not more than 3 letters (for example 123 ABC, 123 AB, 12 A).

Diagrams 5a and 5b.
6.  A group of not more than 3 letters followed by a group of not more than 3 numbers (for example ABC 123, AB 123, A 12).

Diagrams 6a and 6b.
7.  A single letter or group of 2 letters followed by a group of 4 numbers (for example AB 1234, A 1234).

Diagrams 7a and 7b.
8.  A group of 3 letters followed by a group of 4 numbers (for example ABZ 1234, being a form of mark issued only in Northern Ireland).

Diagrams 8a and 8b.
9.  A group of 4 numbers followed by a group of 3 letters (for example 1234 ABZ, being a form of mark issued only in Northern Ireland).


 ***/

UPDATE demand."VRMs" AS v
SET "VRM" =
--SELECT "VRM",  --"VRM" SIMILAR TO '[A-Z]{2}[O][0-9]-[A-Z]{3}',
CASE
    -- Current UK VRM  (AA99-AAA)
    WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z]{3}' THEN "VRM" -- Normal
	WHEN "VRM" SIMILAR TO '[0][A-Z][0-9]{2}-[A-Z]{3}' THEN regexp_replace("VRM", '[0]([A-Z][0-9]{2}-[A-Z]{3})', 'O\1')  -- First character is 0
	WHEN "VRM" SIMILAR TO '[A-Z][0][0-9]{2}-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z])[0]([0-9]{2}-[A-Z]{3})', '\1O\2')  -- Second character is 0
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[O][0-9]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2})[O]([0-9]-[A-Z]{3})', '\10\2') -- Third character is O
    WHEN "VRM" SIMILAR TO '[A-Z]{2}[I][0-9]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2})[O]([0-9]-[A-Z]{3})', '\11\2') -- Third character is 1
    WHEN "VRM" SIMILAR TO '[A-Z]{2}[I][O]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2})[I][O](-[A-Z]{3})', '\110\2')  -- Third/Forth character is IO
    WHEN "VRM" SIMILAR TO '[A-Z]{2}[I][I]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2})[I][I](-[A-Z]{3})', '\111\2')  -- Third/Forth character is II
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9][O]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9])[O](-[A-Z]{3})', '\10\2') -- Fourth character is O
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[0][A-Z]{2}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-)[0]([A-Z]{2})', '\1O\2')  -- Fifth character is 0
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z][0][A-Z]' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-[A-Z])[0]([A-Z])', '\1O\2')  -- Sixth character is 0
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z]{2}[0]' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-[A-Z]{2})[0]', '\1O')  -- Seventh character is 0

	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]-[0-9][A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9])-([0-9])([A-Z]{3})', '\1\2-\3') -- AA9-9AAA

	-- Also need to check for 1/I
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[I][0-9]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2})[I]([0-9]-[A-Z]{3})', '\11\2') -- Third character is I
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9][I]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9])[I](-[A-Z]{3})', '\11\2') -- Fourth character is I

	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[1][A-Z]{2}' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-)[1]([A-Z]{2})', '\1I\2')  -- Fifth character is 1
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z][1][A-Z]' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-[A-Z])[1]([A-Z])', '\1I\2')  -- Sixth character is 1
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z]{2}[1]' THEN regexp_replace("VRM", '([A-Z]{2}[0-9]{2}-[A-Z]{2})[1]', '\1I')  -- Seventh character is 1

    -- Previous UK (A999-AAA)
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{3}-[A-Z]{3}' THEN "VRM"
	WHEN "VRM" SIMILAR TO '[A-Z][O][0-9]{2}-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z])[O]([0-9]{2}-[A-Z]{3})', '\10\2')  -- First number is O
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][O][0-9]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z][0-9])[O]([0-9]-[A-Z]{3})', '\10\2')  -- Second number is O
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}[O]-[A-Z]{3}' THEN regexp_replace("VRM", '([A-Z][0-9]{2})[O](-[A-Z]{3})', '\10\2')  -- Second number is O

	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{3}-[0][A-Z]{2}' THEN regexp_replace("VRM", '([A-Z][0-9]{3}-)[0]([A-Z]{2})', '\1O\2')  -- Fifth character is 0
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{3}-[A-Z][0][A-Z]' THEN regexp_replace("VRM", '([A-Z][0-9]{3}-[A-Z])[0]([A-Z])', '\1O\2')  -- Sixth character is 0
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{3}-[A-Z]{2}[0]' THEN regexp_replace("VRM", '([A-Z][0-9]{3}-([A-Z]{2})[0]', '\1O')  -- Seventh character is 0

    -- Tidy Previous UK (A99-AAA)
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}-[A-Z]{3}' THEN "VRM"
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}[A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([A-Z][0-9]{2})([A-Z])-([A-Z]{2})', '\1-\2\3')

	WHEN "VRM" SIMILAR TO '[A-Z][O][0-9][A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([A-Z])[O]([0-9])([A-Z])-([A-Z]{2})', '\10\2-\3\4') -- Second character is O
    WHEN "VRM" SIMILAR TO '[A-Z][I][0-9][A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([A-Z])[I]([0-9])([A-Z])-([A-Z]{2})', '\11\2-\3\4') -- Second character is 1
    WHEN "VRM" SIMILAR TO '[A-Z][I][O][A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([A-Z])[I][0]([A-Z])-([A-Z]{2})', '\110-\2\3')  -- Second/Third character is IO
    WHEN "VRM" SIMILAR TO '[A-Z][I][I][A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([A-Z])[I][I]([A-Z])-([A-Z]{2})', '\111-\2\3')  -- Second/Third character is II
	
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}[A-Z]-[A-Z][0]' THEN regexp_replace("VRM", '([A-Z][0-9]{2})([A-Z])-([A-Z])[0]', '\1-\2\3O')
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}[A-Z]-[A-Z][1]' THEN regexp_replace("VRM", '([A-Z][0-9]{2})([A-Z])-([A-Z])[1]', '\1-\2\3I')

    -- Tidy Previous UK (A9-AAA)
	WHEN "VRM" SIMILAR TO '[A-Z][0-9]-[A-Z]{3}' THEN "VRM"
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][A-Z]{2}-[A-Z]' THEN regexp_replace("VRM", '([A-Z][0-9])([A-Z]{2})-([A-Z])', '\1-\2\3')      -- A9AA-A
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([A-Z])([0-9])([A-Z])-([A-Z]{2})', '\1\2-\3\4')  -- A9A-AA
	
	WHEN "VRM" SIMILAR TO '[A-Z][I][A-Z]{2}-[A-Z]' THEN regexp_replace("VRM", '([A-Z])[I]([A-Z]{2})-([A-Z])', '\11-\2\3')
	WHEN "VRM" SIMILAR TO '[A-Z][O][A-Z]{2}-[A-Z]' THEN regexp_replace("VRM", '([A-Z])[O]([A-Z]{2})-([A-Z])', '\10-\2\3')
	
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][A-Z][0]-[A-Z]' THEN regexp_replace("VRM", '([A-Z][0-9])([A-Z])[0]-([A-Z])', '\1-\2O\3')
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][A-Z][1]-[A-Z]' THEN regexp_replace("VRM", '([A-Z][0-9])([A-Z])[1]-([A-Z])', '\1-\2I\3')
	
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][A-Z]{2}-[0]' THEN regexp_replace("VRM", '([A-Z][0-9])([A-Z]{2})-([0])', '\1-\2O')
	WHEN "VRM" SIMILAR TO '[A-Z][0-9][A-Z]{2}-[1]' THEN regexp_replace("VRM", '([A-Z][0-9])([A-Z]{2})-([1])', '\1-\2I')
	
    -- Early UK (AAA-999A)
	WHEN "VRM" SIMILAR TO '[A-Z]{3}-[0-9]{3}[A-Z]' THEN "VRM"
	WHEN "VRM" SIMILAR TO '[A-Z]{3}[0-9]-[0-9]{2}[A-Z]' THEN regexp_replace("VRM", '([A-Z]{3})([0-9])-([0-9]{2}[A-Z])', '\1-\2\3')  -- AAA9-99A
	WHEN "VRM" SIMILAR TO '[A-Z]{3}[0-9]-[0-9][O][A-Z]' THEN regexp_replace("VRM", '([A-Z]{3})([0-9])-([0-9])[O]([A-Z])', '\1-\2\30\4')  -- 
	WHEN "VRM" SIMILAR TO '[A-Z]{3}[0-9]-[O][0-9][A-Z]' THEN regexp_replace("VRM", '([A-Z]{3})([0-9])-[O]([0-9])([A-Z])', '\1-\20\3\4')  -- 

    -- Northern Ireland (AAA-9999 or AAA-999)
    WHEN "VRM" SIMILAR TO '[A-Z]{3}[0-9]-[0-9]{3}' THEN regexp_replace("VRM", '([A-Z]{3})([0-9])-([0-9]{3})', '\1-\2\3')
    WHEN "VRM" SIMILAR TO '[A-Z]{3}[0-9]-[0-9]{2}' THEN regexp_replace("VRM", '([A-Z]{3})([0-9])-([0-9]{2})', '\1-\2\3')
    WHEN "VRM" SIMILAR TO '[A-Z][1][A-Z][0-9]-[0-9]{3}' THEN regexp_replace("VRM", '([A-Z])[1]([A-Z])([0-9])-([0-9]{3})', '\1I\2-\3\4') -- 2nd char is 1
    WHEN "VRM" SIMILAR TO '[A-Z][1][A-Z][0-9]-[0-9]{2}' THEN regexp_replace("VRM", '([A-Z])[1]([A-Z])([0-9])-([0-9]{2})', '\1I\2-\3\4') -- 2nd char is 1
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[1][0-9]-[0-9]{2}' THEN regexp_replace("VRM", '([A-Z]{2})[1]([0-9])-([0-9]{2})', '\1I-\2\3') -- 3rd char is 1
	WHEN "VRM" SIMILAR TO '[A-Z]{2}[1][0-9]-[0-9]{3}' THEN regexp_replace("VRM", '([A-Z]{2})[1]([0-9])-([0-9]{3})', '\1I-\2\3') -- 3rd char is 1
	
    -- Others
    -- (999-AAA or 99-AAA or 9-AAA)
    WHEN "VRM" SIMILAR TO '[0-9]{3}[A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([0-9]{3})([A-Z])-([A-Z]{2})', '\1-\2\3')
    WHEN "VRM" SIMILAR TO '[0-9]{2}[A-Z]{2}-[A-Z]' THEN regexp_replace("VRM", '([0-9]{2})([A-Z]{2})-([A-Z])', '\1-\2\3')
    WHEN "VRM" SIMILAR TO '[0-9][A-Z]{3}-' THEN regexp_replace("VRM", '([0-9])([A-Z]{3})', '\1-\2')

    -- (9-AAAA)
    WHEN "VRM" SIMILAR TO '[0-9][A-Z]{3}-[A-Z]' THEN regexp_replace("VRM", '([0-9])([A-Z]{3})-([A-Z])', '\1-\2\3')

    -- (999-AAA)
    WHEN "VRM" SIMILAR TO '[0-9]{3}[A-Z]-[A-Z]{2}' THEN regexp_replace("VRM", '([0-9]{3})([A-Z])-([A-Z]{2})', '\1-\2\3')
	
    -- (AAA-999)
	WHEN "VRM" SIMILAR TO '[A-Z]{3}[0-9]-[0-9]{2}' THEN regexp_replace("VRM", '([A-Z]{3})([0-9])-([0-9]{2})', '\1-\2\3')	
	WHEN "VRM" SIMILAR TO '[A-Z]{3}[I]-[0-9]{2}' THEN regexp_replace("VRM", '([A-Z]{3})[I]-([0-9]{2})', '\1-1\2')
	WHEN "VRM" SIMILAR TO '[A-Z]{3}[O]-[0-9]{2}' THEN regexp_replace("VRM", '([A-Z]{3})[O]-([0-9]{2})', '\1-0\2')

    --- anything where there are three letters at the end ??

	ELSE "VRM"
END
WHERE UPPER("VRM") != 'UNKNOWN'
AND v."InternationalCodeID" IN (0) OR v."InternationalCodeID" IS NULL

/***
FROM mhtc_operations."Supply" s
WHERE v."GeometryID" = s."GeometryID"
--AND s."CPZ" IN ('P', 'F', 'Y')
***/
;

/*** test

SELECT regexp_replace(s."VRM", '([A-Z]{2})[1]([0-9])-([0-9]{2})', '\1I-\2\3') 
FROM (SELECT 'AG16-533' AS "VRM") s
WHERE s."VRM" SIMILAR TO '[A-Z]{2}[1][0-9]-[0-9]{2}'

***/
