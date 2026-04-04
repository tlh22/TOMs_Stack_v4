DROP TABLE IF EXISTS "anpr"."PossibleMatches";
CREATE TABLE "anpr"."PossibleMatches" (
    "gid" SERIAL,
    "Letter1" TEXT,
    "Letter2" TEXT
);

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('B', 'D');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('B', '3');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('B', '8');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('B', 'O');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('B', '0');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('B', 'R');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('C', 'G');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('C', 'O');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('C', '0');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('C', 'D');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('D', 'O');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('D', '0');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('D', 'U');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('D', 'J');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('E', 'F');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('F', 'P');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('G', 'O');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('G', '0');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('G', 'Q');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('G', '6');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('H', 'M');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('H', 'N');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('H', 'W');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('I', '1');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('I', 'T');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('J', 'U');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('K', 'X');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('K', 'N');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('K', 'M');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('K', '4');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('M', 'N');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('M', 'W');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('N', 'V');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('N', 'U');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('N', 'W');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('O', 'Q');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('O', '0');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('O', 'U');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('P', '0');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('P', 'R');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('S', '5');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('S', '6');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('S', '9');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('U', 'V');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('U', '0');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('V', 'W');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('V', 'Y');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('X', 'Y');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('Z', '2');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('3', '8');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('3', '0');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('5', '6');
INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('5', '9');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('6', '8');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('7', '1');

INSERT INTO "anpr"."PossibleMatches" ("Letter1", "Letter2") VALUES ('8', '0');

ALTER TABLE "anpr"."PossibleMatches"
    ADD PRIMARY KEY ("gid");
