-- ============================================================
-- Import pour pgAdmin/DBeaver : COPY côté serveur.
-- Nécessite le droit pg_read_server_files (souvent réservé superuser).
-- Sinon, utilise psql et 02_import_data.sql avec \copy (recommandé).
-- ============================================================

-- 1. Départements
COPY departement(code_departement) FROM '/home/junior/Documents/Rochelle/Modelisation/projet_livrable/import_data/departement.csv' DELIMITER ',' CSV;

-- 2. Types d'acte
COPY type_acte(id_type_acte, libelle) FROM '/home/junior/Documents/Rochelle/Modelisation/projet_livrable/import_data/type_acte.csv' DELIMITER ',' CSV;

-- 3. Communes
COPY commune(nom_commune, code_departement) FROM '/home/junior/Documents/Rochelle/Modelisation/projet_livrable/import_data/commune.csv' DELIMITER ',' CSV;

-- 4. Personnes
COPY personne(id_personne, nom, prenom, prenom_pere, nom_mere, prenom_mere) FROM '/home/junior/Documents/Rochelle/Modelisation/projet_livrable/import_data/personne.csv' DELIMITER ',' CSV;

-- 5. Actes
COPY acte(id_acte, id_type_acte, id_personne_a, id_personne_b, id_commune, date_acte, num_vue) FROM '/home/junior/Documents/Rochelle/Modelisation/projet_livrable/import_data/acte.csv' DELIMITER ',' CSV NULL '\N';
