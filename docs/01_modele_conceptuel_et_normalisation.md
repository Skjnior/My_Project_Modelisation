# Étape 1 & 2 — Modèle conceptuel et normalisation

## 1. Conceptualisation

### Entités identifiées

D’après le sujet et le fichier CSV :

| Entité | Description |
|--------|-------------|
| **Type_acte** | Les 7 types d’actes (Mariage, Publication de mariage, Contrat de mariage, etc.) |
| **Departement** | Les 4 départements valides : 44, 49, 79, 85 |
| **Commune** | Une commune appartient à un seul département ; un département a plusieurs communes |
| **Personne** | Chaque personne avec un identifiant unique (nom, prénom, père, mère) |
| **Acte** | Un enregistrement d’acte : type, personne A, personne B, commune, date, numéro de vue |

### Relations

- Un **acte** a exactement **un type** (type_acte).
- Un **acte** concerne **deux personnes** (personne A et personne B).
- Un **acte** a lieu dans **une commune**.
- Une **commune** appartient à **un département**.
- Une **personne** peut apparaître dans **plusieurs actes** (rôles A ou B).

### Règles métier

1. **Personne** : identifiant unique (clé artificielle `id_personne`).
2. **Type_acte** : valeurs fixées (Certificat de mariage, Contrat de mariage, Divorce, Mariage, Promesse de mariage - fiançailles, Publication de mariage, Rectification de mariage).
3. **Departement** : codes 44, 49, 79, 85 uniquement.
4. **Commune** : une commune n’appartient qu’à un seul département.

---

## 2. Schéma relationnel (tables et clés)

### Table `type_acte`

| Attribut | Type | Contrainte |
|----------|------|------------|
| id_type_acte | SERIAL / INTEGER | PK |
| libelle | VARCHAR(100) | NOT NULL, UNIQUE |

Décrit les types d’actes (Mariage, Publication de mariage, etc.).

---

### Table `departement`

| Attribut | Type | Contrainte |
|----------|------|------------|
| code_departement | CHAR(2) | PK |

Valeurs : 44, 49, 79, 85.

---

### Table `commune`

| Attribut | Type | Contrainte |
|----------|------|------------|
| id_commune | SERIAL / INTEGER | PK |
| nom_commune | VARCHAR(200) | NOT NULL |
| code_departement | CHAR(2) | NOT NULL, FK → departement |

Une commune est unique par (nom_commune, code_departement) pour éviter les doublons entre départements.

---

### Table `personne`

| Attribut | Type | Contrainte |
|----------|------|------------|
| id_personne | SERIAL / INTEGER | PK |
| nom | VARCHAR(100) | NOT NULL |
| prenom | VARCHAR(150) | NOT NULL |
| prenom_pere | VARCHAR(150) | NULL |
| nom_mere | VARCHAR(100) | NULL |
| prenom_mere | VARCHAR(150) | NULL |

Chaque ligne = une personne physique avec identifiant unique. Les champs père/mère peuvent être NULL (n/a).

---

### Table `acte`

| Attribut | Type | Contrainte |
|----------|------|------------|
| id_acte | INTEGER | PK (identifiant d’acte du CSV) |
| id_type_acte | INTEGER | NOT NULL, FK → type_acte |
| id_personne_a | INTEGER | NOT NULL, FK → personne |
| id_personne_b | INTEGER | NOT NULL, FK → personne |
| id_commune | INTEGER | NOT NULL, FK → commune |
| date_acte | DATE | NULL (si date absente) |
| num_vue | VARCHAR(50) | NULL |

Un acte lie deux personnes (A et B), un type, une commune, une date et un numéro de vue.

---

## 3. Normalisation

- **1NF** : Tous les attributs sont atomiques ; pas de listes ou de répétitions dans une cellule. ✓  
- **2NF** : Toutes les tables ont une clé primaire ; pas d’attribut non clé dépendant d’une partie de la clé. ✓  
- **3NF** : Pas de dépendance transitive : département ne dépend que de commune, type que de acte, etc. ✓  

Les clés étrangères respectent les dépendances fonctionnelles (acte → type_acte, commune, personne ; commune → departement).

---

## 4. Diagramme relationnel (résumé)

```
departement (code_departement PK)
       |
       | 1..n
       v
commune (id_commune PK, nom_commune, code_departement FK)

type_acte (id_type_acte PK, libelle)

personne (id_personne PK, nom, prenom, prenom_pere, nom_mere, prenom_mere)

acte (id_acte PK, id_type_acte FK, id_personne_a FK, id_personne_b FK, id_commune FK, date_acte, num_vue)
```

Tu peux recopier ce schéma dans DBDesigner (dbdesigner.net) pour l’étape 3, puis exporter en SQL PostgreSQL.
