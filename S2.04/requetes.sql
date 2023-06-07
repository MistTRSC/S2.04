-- EXERCICE 3 :
-- Q1. Combien de colonnes dans import ?
SELECT COUNT(*)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'import';

-- Q2. Combien de lignes dans import ?
SELECT COUNT(*)
FROM import;

-- Q3. Combien de codes NOC dans noc ? 
SELECT COUNT(*)
FROM noc;

-- Q4. Combien d’athletes différents sont référencés dans ce fichier ?
SELECT COUNT(*)
FROM (SELECT DISTINCT n2 FROM import) AS tab;

-- Q5. Combien y-a t-il de médailles d’or dans ce fichier ?
SELECT COUNT(*)
FROM import
WHERE n15='Gold';

-- Q6. Retrouvez Carl Lewis; Combien de lignes se réfèrent à Carl Lewis ?
SELECT COUNT(*)
FROM import
WHERE n2 LIKE '%Carl Lewis%';


-----------------------------------------------
-- EXERCICE 5 :
-- Q1. Liste des pays classés par participation aux épreuves (Nombre de participation aux JO) (2 cols)
SELECT region, COUNT(DISTINCT sid)
FROM (Participe JOIN Team USING(tid)) AS tab JOIN noc USING(noc)
GROUP BY region
ORDER BY COUNT(DISTINCT sid) DESC;

-- Q2. Liste des pays classés par nombre de médailles d’or (2 cols)
SELECT region, COUNT(*)
FROM (Participe JOIN Team USING(tid)) AS tab JOIN noc USING(noc)
WHERE medaille = 'Gold'
GROUP BY region
ORDER BY COUNT(*) DESC;

-- Q3. Liste des pays classés par nombre médailles totales (2 cols)
SELECT region, COUNT(*)
FROM (Participe JOIN Team USING(tid)) AS tab JOIN noc USING(noc)
WHERE medaille IS NOT NULL
GROUP BY region
ORDER BY COUNT(*) DESC;

-- Q4. Liste des sportifs ayant le plus de médailles d’or, avec le nombre (3 cols)
SELECT aid, nom, COUNT(*)
FROM Participe JOIN Athlete USING(aid)
WHERE medaille = 'Gold'
GROUP BY aid, nom
ORDER BY COUNT(*) DESC;

-- Q5. Nombre de médailles cumulées par pays pour les Jeux d’Albertville, par ordre décroissant (2 cols)
SELECT region, COUNT(*)
FROM ((Participe JOIN Team USING(tid)) AS tab1
     JOIN noc USING(noc)) AS tab2
     JOIN Session USING(sid)
WHERE ville = 'Albertville'
AND medaille IS NOT NULL
GROUP BY region
ORDER BY COUNT(*) DESC;

-- Q6. Combien de sportifs ont fait les jeux olympiques sous 2 drapeaux différents, le dernier étant la France ? (1 valeur) Selon vous quel est le plus connu/célèbre/titré/... ?
DROP VIEW IF EXISTS test;
CREATE VIEW test
AS SELECT *
FROM ((Participe JOIN Team USING(tid)) AS tab1
     JOIN noc USING(noc)) AS tab2
     JOIN Session USING(sid);

SELECT COUNT(DISTINCT aid)
FROM test AS t1 JOIN test AS t2 USING(aid)
WHERE t1.region<>t2.region
AND t1.annee<=t2.annee
AND t2.region='France';

/*
SELECT * FROM import WHERE n2 IN (SELECT nom
FROM Athlete
WHERE aid IN(SELECT DISTINCT aid
FROM test AS t1 JOIN test AS t2 USING(aid)
WHERE t1.region<>t2.region
AND t1.annee<=t2.annee
AND t2.region='France'));

On trouve la liste de ces athlètes, Angelo Parisi, judoka, a décroché beaucoup de médailles et semble être l'athlète le plus reconnu de la liste.
*/

-- Q7. Combien de sportifs ont fait les jeux olympiques sous 2 drapeaux différents, le premier étant la France ? (1 valeur) Selon vous quel est le plus connu/célèbre/titré/... ?
DROP VIEW IF EXISTS test;
CREATE VIEW test
AS SELECT *
FROM ((Participe JOIN Team USING(tid)) AS tab1
     JOIN noc USING(noc)) AS tab2
     JOIN Session USING(sid);

SELECT COUNT(DISTINCT aid)
FROM test AS t1 JOIN test AS t2 USING(aid)
WHERE t1.region<>t2.region
AND t1.annee<=t2.annee
AND t1.region='France';

/*
SELECT *
FROM Athlete
WHERE aid IN(SELECT DISTINCT aid
FROM test AS t1 JOIN test AS t2 USING(aid)
WHERE t1.region<>t2.region
AND t1.annee<=t2.annee
AND t1.region='France');

On trouve la liste de ces athlètes, Julien Bahain, rameur, a obtenu de nombreux titres dans sa discipline et semble être l'athlète le plus connu de cette liste.
*/

-- Q8. Distribution des âges des médaillés d’or (2 cols)
SELECT age, COUNT(*)
FROM Participe
WHERE medaille = 'Gold'
GROUP BY age;

-- Q9. Distribution des disciplines donnant des médailles aux plus de 50 ans par ordre décroissant (2 cols)
SELECT sport, COUNT(*)
FROM Participe JOIN Epreuve USING(eid)
WHERE age>50 AND medaille IS NOT NULL
GROUP BY sport
ORDER BY COUNT(*) DESC;

-- Q10. Nombre d’épreuves par type de jeux (hivers,été), par année croissante (3 cols)
SELECT annee, saison, COUNT(DISTINCT event) AS NbreEpreuve
FROM (Participe JOIN Session USING(sid)) AS tab
     JOIN Epreuve USING(eid)
GROUP BY annee, saison
ORDER BY annee ASC;

-- Q11. Nombre de médailles féminines aux jeux d’été par année croissante (2 cols)
SELECT annee, COUNT(medaille)
FROM (Participe JOIN Session USING(sid)) AS tab1
     JOIN Athlete USING(aid)
WHERE sexe = 'F' AND saison = 'Summer'
GROUP BY annee
ORDER BY annee ASC;


-----------------------------------------------
-- Exercice 6 :
-- Pays : Norway ; Sport : Canoeing
DROP VIEW IF EXISTS canoeingnorway;
CREATE VIEW canoeingnorway
AS SELECT *
FROM (((Participe JOIN Team USING(tid)) AS tab1
     JOIN noc USING(noc)) AS tab2
     JOIN Epreuve USING(eid)) AS tab3
     JOIN Session USING(sid)
WHERE sport = 'Canoeing'
AND region = 'Norway';

-- 1 - Nombre de médailles d'or, d'argent et de bronze remportées par la Norvège en canoë durant l'intégralité des jeux.
SELECT (SELECT COUNT(*) FROM canoeingnorway WHERE medaille='Gold') AS Gold,
       (SELECT COUNT(*) FROM canoeingnorway WHERE medaille='Silver') AS Silver,
       (SELECT COUNT(*) FROM canoeingnorway WHERE medaille='Bronze') AS Bronze;

-- 2 - Âge, taille et poids moyen des athlètes canoéistes norvégiens.
SELECT AVG(age) AS MoyenneAge, AVG(taille) AS MoyenneTaille, AVG(poids) AS MoyennePoids
FROM canoeingnorway;

-- 3 - Nombre d'athlètes et de médailles(par type et total) par année croissante.
SELECT annee, COUNT(DISTINCT aid) AS NbreAthlete,
       COUNT(CASE WHEN medaille = 'Gold' THEN 1 ELSE NULL END) AS Gold,
       COUNT(CASE WHEN medaille = 'Silver' THEN 1 ELSE NULL END) AS Silver,
       COUNT(CASE WHEN medaille = 'Bronze' THEN 1 ELSE NULL END) AS Bronze,
       COUNT(medaille) AS totalMedailles
FROM canoeingnorway
GROUP BY annee
ORDER BY annee ASC;

-- 4 - Pourcentage des médailles remportées par la norvège en canoë par épreuve de la discipline.
SELECT event,
       COUNT(medaille)::float/(SELECT COUNT(medaille)
			FROM canoeingnorway)::float AS medaillePercentage
FROM canoeingnorway
GROUP BY event
ORDER BY event ASC;
