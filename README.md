# Modélisation de bases de données — Archives Vendée (Mariages)

Projet universitaire de modélisation et d’exploitation d’une base de données à partir des archives départementales de la Vendée (actes de mariage). Conception du schéma relationnel, normalisation, import des données CSV dans PostgreSQL et requêtes SQL pour les généalogistes.

**Cours :** 160-6-12 — Modélisation de bases de données (2024-2025)  
**Auteur :** Mohamed Kaba

---

## Description

Ce dépôt contient la modélisation complète d’une base de données dédiée aux actes de mariage (et types d’actes associés) issus de fichiers CSV fournis par le cours. Le projet inclut :

- **Modèle relationnel** : 5 tables (département, commune, type_acte, personne, acte) avec clés et relations, conforme aux contraintes métier (départements 44, 49, 79, 85 ; types d’acte définis ; personne avec identifiant unique).
- **Scripts d’extraction** : lecture des CSV, déduplication des personnes/communes/types, génération des fichiers d’import.
- **Schéma PostgreSQL** : création des tables, contraintes, index.
- **Import des données** : chargement via `\copy` (psql) ou `COPY` (pgAdmin).
- **Requêtes** : les 5 questions des généalogistes (communes par département, actes à LUÇON, contrats avant 1855, commune avec le plus de publications, premier/dernier acte).
- **Bonus** : prise en charge du fichier complet (~564k lignes) avec gestion des données bruitées (champs vides, virgules dans les champs, identifiants invalides).

Le projet est **autonome** : les données 5k sont incluses dans `data/`. Il fonctionne sur **Linux, macOS et Windows** (voir sections dédiées).

---

## Technologies

- **Python 3** — extraction et préparation des données CSV
- **PostgreSQL** — base de données relationnelle
- **SQL** — schéma, import, requêtes
- **DBDesigner** (dbdesigner.net) — modélisation visuelle (optionnel)

---

## Structure du projet

```
├── README.md                 # Ce fichier
├── INSTALL_Windows.txt       # Instructions pas à pas pour Windows
├── .gitattributes            # Fins de ligne LF pour les scripts .sh
├── data/                     # Fichiers CSV
│   ├── mariages_L3_5k.csv   # Données obligatoires (incluses)
│   ├── mariages_L3.csv      # Optionnel : bonus (~564k lignes)
│   └── README.txt
├── sql/
│   ├── 01_schema_postgresql.sql   # Création des tables
│   ├── 02_import_data.sql         # Import (psql \copy)
│   ├── 02_import_data_pgAdmin.sql # Import (COPY pour pgAdmin)
│   └── 03_requetes_genealogistes.sql # Les 5 requêtes
├── scripts/
│   ├── extract_and_prepare_data.py  # CSV → fichiers d’import
│   ├── run_5k.sh                     # Tout-en-un : projet obligatoire
│   ├── run_bonus.sh                  # Tout-en-un : bonus
│   └── load_into_postgres.sh        # Schéma + import (après extraction)
├── docs/
│   ├── RAPPORT_PROJET_Mohamed_Kaba.md   # Rapport (source)
│   ├── RAPPORT_PROJET_Mohamed_Kaba.pdf  # Rapport (PDF)
│   ├── modele_dbdesigner.png            # Schéma DBDesigner
│   └── 01_modele_conceptuel_et_normalisation.md
└── import_data/              # Généré par les scripts (CSV d’import)
```

---

## Prérequis

- **Python 3**
- **PostgreSQL** avec `psql` en ligne de commande

---

## Installation et utilisation

### Linux / macOS

```bash
# Cloner ou télécharger le dépôt, puis :
cd "Mon projet"

# Corriger les fins de ligne si besoin (erreur ^M)
sed -i 's/\r$//' scripts/*.sh

# Rendre les scripts exécutables
chmod +x scripts/*.sh

# Lancer le projet obligatoire (extraction + BDD + import + 5 requêtes)
./scripts/run_5k.sh
```

**Bonus** (après avoir placé `mariages_L3.csv` dans `data/`) :

```bash
./scripts/run_bonus.sh
```

**Mac** : si `sudo -u postgres psql` échoue, utiliser `export PSQL_CMD=psql` puis relancer le script.

### Windows

Voir **INSTALL_Windows.txt** pour les commandes PowerShell/CMD (extraction Python puis exécution des fichiers SQL avec `psql` ou pgAdmin). Alternative : utiliser WSL et suivre les commandes Linux ci-dessus.

---

## Résultats des requêtes (données 5k)

| Question | Résultat |
|----------|----------|
| Communes par département | 44: 9, 49: 2, 79: 51, 85: 313 |
| Actes à LUÇON | 105 |
| Contrats de mariage avant 1855 | 196 |
| Commune avec le plus de publications | SAINT PIERRE DU CHEMIN (85) — 20 |
| Premier / dernier acte | 1581-12-23 / 1915-09-14 |

---

## Licence et contexte

Projet réalisé dans le cadre du cours **Modélisation de bases de données** (160-6-12). Les données proviennent des archives départementales de la Vendée (usage pédagogique).

---

## Auteur

**Mohamed Kaba**
@skjunior
