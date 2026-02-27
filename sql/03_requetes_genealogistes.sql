-- ============================================================
-- Requêtes pour les 5 questions des généalogistes
-- ============================================================

-- 1. La quantité de communes par département
SELECT d.code_departement, COUNT(c.id_commune) AS nb_communes
FROM departement d
LEFT JOIN commune c ON c.code_departement = d.code_departement
GROUP BY d.code_departement
ORDER BY d.code_departement;

-- 2. La quantité d'actes à LUÇON
SELECT COUNT(*) AS nb_actes_lucon
FROM acte a
JOIN commune c ON a.id_commune = c.id_commune
WHERE c.nom_commune = 'LUÇON';

-- 3. La quantité de "contrats de mariage" avant 1855
SELECT COUNT(*) AS nb_contrats_avant_1855
FROM acte a
JOIN type_acte t ON a.id_type_acte = t.id_type_acte
WHERE t.libelle = 'Contrat de mariage'
  AND a.date_acte < '1855-01-01';

-- 4. La commune avec la plus grande quantité de "publications de mariage"
SELECT c.nom_commune, c.code_departement, COUNT(*) AS nb_publications
FROM acte a
JOIN type_acte t ON a.id_type_acte = t.id_type_acte
JOIN commune c ON a.id_commune = c.id_commune
WHERE t.libelle = 'Publication de mariage'
GROUP BY c.id_commune, c.nom_commune, c.code_departement
ORDER BY nb_publications DESC
LIMIT 1;

-- 5. La date du premier acte et la date du dernier acte
SELECT MIN(a.date_acte) AS premier_acte, MAX(a.date_acte) AS dernier_acte
FROM acte a
WHERE a.date_acte IS NOT NULL;
