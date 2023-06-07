DROP TABLE IF EXISTS import CASCADE;
DROP TABLE IF EXISTS noc CASCADE;
DROP TABLE IF EXISTS Athlete CASCADE;
DROP TABLE IF EXISTS Team CASCADE;
DROP TABLE IF EXISTS Session CASCADE;
DROP TABLE IF EXISTS Epreuve CASCADE;
DROP TABLE IF EXISTS Participe CASCADE;

CREATE TEMPORARY TABLE import (
       n1 CHAR(6),
       n2 TEXT,
       n3 CHAR(1),
       n4 INT,
       n5 INT,
       n6 FLOAT,
       n7 TEXT,
       n8 CHAR(3),
       n9 TEXT,
       n10 INT,
       n11 TEXT,
       n12 TEXT,
       n13 TEXT,
       n14 TEXT,
       n15 CHAR(6));

\copy import from athlete_events.csv WITH (delimiter ',', null 'NA', format CSV) ;

DELETE FROM import
       WHERE n10<1920 OR n13 LIKE '%Art%';
-- Mise à jour vieux NOC de Singapour
UPDATE import
SET n8 = 'SIN'
WHERE n8 = 'SGP';
       
CREATE TABLE noc (
       noc CHAR(3),
       region TEXT,
       notes TEXT,
       CONSTRAINT pk_noc PRIMARY KEY(noc));

\copy noc from noc_regions.csv WITH (delimiter ',', format CSV) ;


CREATE TABLE Athlete (
       	     aid CHAR(6),
	     nom TEXT,
	     sexe CHAR(1),
	     CONSTRAINT pk_Athlete PRIMARY KEY(aid));
INSERT INTO Athlete
       SELECT DISTINCT n1, n2, n3
       FROM import;


CREATE TABLE Team (
       	     tid SERIAL,
	     team TEXT,
	     noc CHAR(3),
	     CONSTRAINT pk_Team PRIMARY KEY (tid),
	     CONSTRAINT fk_Team_noc FOREIGN KEY (noc) REFERENCES noc(noc));
INSERT INTO Team(team,noc)
       SELECT DISTINCT n7, n8
       FROM import;


CREATE TABLE Session (
       	     sid SERIAL,
	     ville TEXT,
	     saison CHAR(6),
	     annee INT,
	     CONSTRAINT pk_Session PRIMARY KEY (sid));
INSERT INTO Session(ville, saison, annee)
       SELECT DISTINCT n12, n11, n10
       FROM import;


CREATE TABLE Epreuve (
       	     eid SERIAL,
	     sport TEXT,
	     event TEXT,
	     CONSTRAINT pk_Epreuve PRIMARY KEY (eid));
INSERT INTO Epreuve(sport, event)
       SELECT DISTINCT n13, n14
       FROM import;


CREATE TABLE Participe (
       	     aid CHAR(6),
	     sid INT,
	     eid INT,
	     tid INT,
	     age INT,
	     taille INT,
	     poids FLOAT,
	     medaille CHAR(6),
	     CONSTRAINT pk_Participe PRIMARY KEY(aid,sid,eid,tid),
	     CONSTRAINT fk_Participe_aid FOREIGN KEY (aid) REFERENCES Athlete(aid),
	     CONSTRAINT fk_Participe_sid FOREIGN KEY (sid) REFERENCES Session(sid),
	     CONSTRAINT fk_Participe_eid FOREIGN KEY (eid) REFERENCES Epreuve(eid),
	     CONSTRAINT fk_Participe_noc FOREIGN KEY (tid) REFERENCES Team(tid));
INSERT INTO Participe
       SELECT i.n1 AS aid,
       	      s.sid AS sid,
    	      e.eid AS eid,
    	      t.tid AS tid,
    	      i.n4 AS age,
    	      i.n5 AS taille,
    	      i.n6 AS poids,
    	      i.n15 AS medaille
       FROM import as i, Session as s, Epreuve as e, Team AS t
       WHERE s.saison = i.n11
       AND s.annee = i.n10
       AND s.ville = i.n12
       AND e.sport = i.n13
       AND e.event = i.n14
       AND t.noc = i.n8
       AND t.team = i.n7;
