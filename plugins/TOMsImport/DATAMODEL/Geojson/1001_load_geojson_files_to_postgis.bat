REM  load_geojson_files_to_postgis STH2219_ArnosGrove_Enfield_Office "import_geojson" "Z:\Tim\STH22-19 Arnos Grove, Enfield\Office\Mapping\Arnos Grove files"

SET SERVICE_NAME=%1
SET SCHEMA=%2
SET SOURCE_FOLDER=%3
echo input params %SERVICE_NAME% %SCHEMA% %SOURCE_FOLDER%
@echo off
cd /d %SOURCE_FOLDER%

for %%f in (*.geojson) do (
    call :Sub %%f 
)

:Sub
set file="%*"
set table=%file:~0,-9%"
echo input file %SOURCE_FOLDER%/%file%
echo creating table %table%
@echo on
ogr2ogr -f "PostgreSQL" PG:"service=%SERVICE_NAME%" %SOURCE_FOLDER%/%file% -s_srs "EPSG:27700" -spat_srs "EPSG:27700" -overwrite -unsetFid -nln %SCHEMA%.%table% -skipfailures
@echo off




