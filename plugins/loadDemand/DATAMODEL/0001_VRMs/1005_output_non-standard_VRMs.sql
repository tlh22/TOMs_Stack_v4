
--- Any VRMs that are not "standard"

SELECT DISTINCT "VRM"
FROM anpr."VRMs"
WHERE "VRM" NOT IN (
SELECT "VRM"
FROM anpr."VRMs"
WHERE "VRM" =
    CASE
        -- Current UK VRM  (AA99-AAA)
        WHEN "VRM" SIMILAR TO '[A-Z]{2}[0-9]{2}-[A-Z]{3}' THEN "VRM" -- Normal

        -- Previous UK (A999-AAA)
        WHEN "VRM" SIMILAR TO '[A-Z][0-9]{3}-[A-Z]{3}' THEN "VRM"

        -- Tidy Previous UK (A99-AAA)
        WHEN "VRM" SIMILAR TO '[A-Z][0-9]{2}-[A-Z]{3}' THEN "VRM"

        -- Tidy Previous UK (A9-AAA)
        WHEN "VRM" SIMILAR TO '[A-Z][0-9]-[A-Z]{3}' THEN "VRM"

        -- Early UK (AAA-999A)
        WHEN "VRM" SIMILAR TO '[A-Z]{3}-[0-9]{3}[A-Z]' THEN "VRM"

        -- Northern Ireland (AAA-9999 or AAA-999)
        WHEN "VRM" SIMILAR TO '[A-Z]{3}-[0-9]{4}' THEN "VRM"

        -- Others
        -- (999-AAA or 99-AAA or 9-AAA)
        WHEN "VRM" SIMILAR TO '[A-Z]{3}-[0-9]{3}' THEN "VRM"
        WHEN "VRM" SIMILAR TO '[A-Z]{2}-[0-9]{3}' THEN "VRM"
        WHEN "VRM" SIMILAR TO '[A-Z]{1}-[0-9]{3}' THEN "VRM"

        -- (9-AAAA)
        WHEN "VRM" SIMILAR TO '[0-9]{1}-[A-Z]{4}' THEN "VRM"

    END
)
AND "SiteID" IN (171, 172)
ORDER BY "VRM";
