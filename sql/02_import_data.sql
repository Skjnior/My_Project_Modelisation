-- ============================================================
-- Import des données — À exécuter UNIQUEMENT avec psql (ligne de commande)
-- \copy lit les fichiers côté client, donc pas besoin de droit pg_read_server_files.
--
-- Depuis le dossier projet_livrable, selon ton installation :
--   psql -d mariages_bdd -f sql/02_import_data.sql
-- ou (si ton user PostgreSQL = ton user Linux) :
--   sudo -u postgres psql -d mariages_bdd -f sql/02_import_data.sql
-- ============================================================

-- 1. Départements
\copy departement(code_departement) FROM 'import_data/departement.csv' DELIMITER ',' CSV;

-- 2. Types d'acte (id, libelle)
\copy type_acte(id_type_acte, libelle) FROM 'import_data/type_acte.csv' DELIMITER ',' CSV;

-- 3. Communes (nom_commune, code_departement) — id_commune en SERIAL
\copy commune(nom_commune, code_departement) FROM 'import_data/commune.csv' DELIMITER ',' CSV;

-- 4. Personnes
\copy personne(id_personne, nom, prenom, prenom_pere, nom_mere, prenom_mere) FROM 'import_data/personne.csv' DELIMITER ',' CSV;

-- 5. Actes (format TEXT : \N = NULL par défaut, pas de guillemets CSV à gérer)
\copy acte(id_acte, id_type_acte, id_personne_a, id_personne_b, id_commune, date_acte, num_vue) FROM 'import_data/acte.csv' DELIMITER ',';
