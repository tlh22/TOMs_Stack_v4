/***
 Add new field to hold cpacity for 5.5m
 ***/

-- Supply

ALTER TABLE IF EXISTS mhtc_operations."Supply"
    RENAME "Capacity" TO "Capacity_55m";
    
ALTER TABLE mhtc_operations."Supply"
    ADD COLUMN IF NOT EXISTS "Capacity" integer;
    
-- RestrictionsInSurveys

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    RENAME "SupplyCapacity" TO "SupplyCapacity_55m";

ALTER TABLE IF EXISTS demand."RestrictionsInSurveys"
    RENAME "CapacityAtTimeOfSurvey" TO "CapacityAtTimeOfSurvey_55m";
    
