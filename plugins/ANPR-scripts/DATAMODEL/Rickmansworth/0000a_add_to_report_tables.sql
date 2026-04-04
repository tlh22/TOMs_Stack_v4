/***

Add additional details for processing

***/


-- Car Parks

COPY anpr."CarParks"("CarParkID", "Description")
FROM 'C:\Users\Public\Documents\CarParks.csv'
DELIMITER ','
CSV HEADER;

-- Sites

COPY anpr."Sites"("SiteID", "Description", "CarParkID", "IN", "OUT")
FROM 'C:\Users\Public\Documents\Sites.csv'
DELIMITER ','
CSV HEADER;

-- Routes

COPY anpr."Routes"("FromSiteID", "ToSiteID", "MinimumTimeLimit", "MaximumTimeLimit")
FROM 'C:\Users\Public\Documents\Routes.csv'
DELIMITER ','
CSV HEADER;


