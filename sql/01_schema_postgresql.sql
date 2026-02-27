-- ============================================================
-- Projet Modélisation de bases de données - Archives Vendée
-- Schéma PostgreSQL (sans préfixe public. pour import DBDesigner)
-- ============================================================

-- Suppression des tables si elles existent (ordre inverse des FK)
DROP TABLE IF EXISTS acte;
DROP TABLE IF EXISTS personne;
DROP TABLE IF EXISTS commune;
DROP TABLE IF EXISTS departement;
DROP TABLE IF EXISTS type_acte;

-- ----------------------------------------
-- Table type_acte
-- ----------------------------------------
CREATE TABLE type_acte (
    id_type_acte INTEGER PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

-- ----------------------------------------
-- Table departement
-- ----------------------------------------
CREATE TABLE departement (
    code_departement CHAR(2) PRIMARY KEY
);

-- ----------------------------------------
-- Table commune
-- ----------------------------------------
CREATE TABLE commune (
    id_commune SERIAL PRIMARY KEY,
    nom_commune VARCHAR(200) NOT NULL,
    code_departement CHAR(2) NOT NULL,
    UNIQUE(nom_commune, code_departement),
    FOREIGN KEY (code_departement) REFERENCES departement(code_departement)
);

-- ----------------------------------------
-- Table personne
-- ----------------------------------------
CREATE TABLE personne (
    id_personne INTEGER PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(150) NOT NULL,
    prenom_pere VARCHAR(150),
    nom_mere VARCHAR(100),
    prenom_mere VARCHAR(150)
);

-- ----------------------------------------
-- Table acte
-- ----------------------------------------
CREATE TABLE acte (
    id_acte INTEGER PRIMARY KEY,
    id_type_acte INTEGER NOT NULL,
    id_personne_a INTEGER NOT NULL,
    id_personne_b INTEGER NOT NULL,
    id_commune INTEGER NOT NULL,
    date_acte DATE,
    num_vue VARCHAR(50),
    FOREIGN KEY (id_type_acte) REFERENCES type_acte(id_type_acte),
    FOREIGN KEY (id_personne_a) REFERENCES personne(id_personne),
    FOREIGN KEY (id_personne_b) REFERENCES personne(id_personne),
    FOREIGN KEY (id_commune) REFERENCES commune(id_commune)
);

-- Index pour accélérer les requêtes (commune, type, date)
CREATE INDEX idx_acte_commune ON acte(id_commune);
CREATE INDEX idx_acte_type ON acte(id_type_acte);
CREATE INDEX idx_acte_date ON acte(date_acte);
