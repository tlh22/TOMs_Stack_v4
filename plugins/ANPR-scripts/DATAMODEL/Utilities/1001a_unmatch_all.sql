
UPDATE anpr."VRMs"
SET "MatchedTo" = NULL, "MatchedFrom" = NULL;

UPDATE anpr."VRMs"
  set "VRM" = replace("VRM", ' ', '');
