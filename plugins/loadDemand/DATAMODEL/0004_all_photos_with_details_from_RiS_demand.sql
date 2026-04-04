/*
To copy photos from folder tree

SET DATA_FOLDER=%1
SET PHOTOS_FOLDER=%2
echo %DATA_FOLDER% %PHOTOS_FOLDER%
@echo off
cd /d %DATA_FOLDER%
call :treeProcess
goto :eof

:treeProcess
for %%f in (*.png *.jpg) do (
    REM echo %%f %PHOTOS_FOLDER%
    COPY /Y %%f %PHOTOS_FOLDER%
)
for /D %%d in (*) do (
    cd /d %%d
    REM echo -- %%d
    call :treeProcess
    cd ..
)

*/

-- separate out "general" photos from one relating to suspensions

SELECT CONCAT('copy /y ', RiS."Photos_01", ' "../Photos_Demand/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_01", '"')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID"
--AND su."CPZ" = 'FPC'
--AND su."SouthwarkProposedDeliveryZoneID" = 1
) a
WHERE "Photos_01" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"

--AND s."SurveyID" in ( SELECT "SurveyID" FROM demand."Surveys" WHERE "SiteArea" LIKE 'FP%')

UNION

SELECT CONCAT('copy /y ', RiS."Photos_02", ' "../Photos_Demand/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_02", '"')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID"
--AND su."SouthwarkProposedDeliveryZoneID" = 1
--AND su."CPZ" = 'FPC'
) a
WHERE "Photos_02" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"

--AND s."SurveyID" in ( SELECT "SurveyID" FROM demand."Surveys" WHERE "SiteArea" LIKE 'FP%')

UNION

SELECT CONCAT('copy /y ', RiS."Photos_03", ' "../Photos_Demand/', a."SectionName", '_', s."BeatTitle", '_', RiS."Photos_03", '"')
FROM demand."RestrictionsInSurveys" RiS, demand."Surveys" s,
(SELECT su."GeometryID", r."SectionName"
FROM mhtc_operations."RC_Sections_merged" r, mhtc_operations."Supply" su
WHERE r."gid" = su."SectionID"
--AND su."SouthwarkProposedDeliveryZoneID" = 1
--AND su."CPZ" = 'FPC'
) a
WHERE "Photos_03" IS NOT NULL
AND RiS."SurveyID" = s."SurveyID"
AND a."GeometryID" = RiS."GeometryID"

--AND s."SurveyID" in ( SELECT "SurveyID" FROM demand."Surveys" WHERE "SiteArea" LIKE 'FP%')

