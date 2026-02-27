#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Extraction et préparation des données pour le projet Modélisation BDD.
Lit le CSV mariages, déduplique personnes/communes/types, produit les fichiers
d'import pour PostgreSQL.
Usage: python3 extract_and_prepare_data.py [mariages_L3_5k.csv|mariages_L3.csv]
"""

import csv
import sys
import os
from datetime import datetime
from collections import OrderedDict

# Répertoires (portable : tout est relatif au dossier du projet)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
DATA_DIR = os.path.join(PROJECT_ROOT, "data")
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "import_data")

# Départements valides
DEPARTEMENTS_VALIDES = {"44", "49", "79", "85"}

# Types d'acte officiels (pour filtrer / normaliser)
TYPES_ACTE = [
    "Certificat de mariage",
    "Contrat de mariage",
    "Divorce",
    "Mariage",
    "Promesse de mariage - fiançailles",
    "Publication de mariage",
    "Rectification de mariage",
]


def norm(val):
    """Remplace n/a et chaîne vide par None (NULL en base)."""
    if val is None or (isinstance(val, str) and val.strip().lower() in ("", "n/a")):
        return None
    return val.strip() if isinstance(val, str) else val


def norm_str(val):
    """Pour affichage CSV : chaîne vide si None."""
    if val is None:
        return ""
    return str(val).strip()


def date_to_iso(s):
    """Convertit JJ/MM/AAAA en AAAA-MM-JJ ou retourne None."""
    if not s or norm(s) is None:
        return None
    s = s.strip()
    try:
        d = datetime.strptime(s, "%d/%m/%Y")
        return d.strftime("%Y-%m-%d")
    except ValueError:
        return None


def main():
    if len(sys.argv) > 1:
        csv_path = os.path.abspath(sys.argv[1])
    else:
        csv_path = os.path.join(DATA_DIR, "mariages_L3_5k.csv")

    if not os.path.isfile(csv_path):
        print(f"Fichier non trouvé: {csv_path}")
        print("Usage: python3 extract_and_prepare_data.py [fichier.csv]")
        print("  Sans argument: utilise data/mariages_L3_5k.csv")
        sys.exit(1)

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Structures pour déduplication (ordre conservé)
    type_acte_set = OrderedDict()  # libelle -> id_type_acte (1, 2, ...)
    commune_set = OrderedDict()    # (nom_commune, code_dept) -> id_commune
    personne_set = OrderedDict()   # (nom, prenom, prenom_pere, nom_mere, prenom_mere) -> id_personne

    # Liste des actes à écrire à la fin (après avoir tous les id)
    actes_rows = []

    with open(csv_path, "r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) < 16:
                continue
            id_acte_s, type_lib, nom_a, prenom_a, pp_a, nm_a, pm_a, nom_b, prenom_b, pp_b, nm_b, pm_b, commune, dept, date_s, num_vue = row[:16]
            # Ignorer les lignes où l'id_acte n'est pas un entier (données bruitées)
            if not (id_acte_s and str(id_acte_s).strip().isdigit()):
                continue

            # Département valide uniquement
            dept = norm(dept)
            if dept not in DEPARTEMENTS_VALIDES:
                continue

            # Type d'acte
            type_lib = (norm(type_lib) or "").strip()
            if type_lib and type_lib not in type_acte_set:
                type_acte_set[type_lib] = len(type_acte_set) + 1

            # Commune
            nom_commune = (norm(commune) or "").strip()
            if nom_commune:
                key_c = (nom_commune, dept)
                if key_c not in commune_set:
                    commune_set[key_c] = len(commune_set) + 1

            # Personne A (nom/prenom vides → placeholder pour éviter NULL en base)
            nom_a = norm_str(nom_a) or "."
            prenom_a = norm_str(prenom_a) or "."
            key_a = (nom_a, prenom_a, norm_str(pp_a), norm_str(nm_a), norm_str(pm_a))
            if key_a not in personne_set:
                personne_set[key_a] = len(personne_set) + 1

            # Personne B (nom/prenom vides → placeholder pour éviter NULL en base)
            nom_b = norm_str(nom_b) or "."
            prenom_b = norm_str(prenom_b) or "."
            key_b = (nom_b, prenom_b, norm_str(pp_b), norm_str(nm_b), norm_str(pm_b))
            if key_b not in personne_set:
                personne_set[key_b] = len(personne_set) + 1

            id_type = type_acte_set.get(type_lib)
            id_commune = commune_set.get((nom_commune, dept))
            id_personne_a = personne_set[key_a]
            id_personne_b = personne_set[key_b]

            if not id_type or not id_commune:
                continue

            date_iso = date_to_iso(date_s)
            num_vue_val = norm(num_vue)  # None si vide ou n/a
            num_vue = norm_str(num_vue_val) if num_vue_val is not None else None
            # Sanitizer num_vue : pas de virgule (délimiteur) ni retours à la ligne (casse les lignes CSV)
            if num_vue:
                num_vue = num_vue.replace(",", " ").replace("\n", " ").replace("\r", " ").strip()

            actes_rows.append({
                "id_acte": id_acte_s.strip(),
                "id_type_acte": id_type,
                "id_personne_a": id_personne_a,
                "id_personne_b": id_personne_b,
                "id_commune": id_commune,
                "date_acte": date_iso,   # None si invalide → \N en CSV
                "num_vue": num_vue or None,
            })

    # Écrire départements
    with open(os.path.join(OUTPUT_DIR, "departement.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        for code in ["44", "49", "79", "85"]:
            w.writerow([code])

    # Écrire type_acte (id_type_acte, libelle)
    with open(os.path.join(OUTPUT_DIR, "type_acte.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        for lib, id_t in type_acte_set.items():
            w.writerow([id_t, lib])

    # Écrire commune (nom_commune, code_departement) — id_commune = SERIAL en base
    with open(os.path.join(OUTPUT_DIR, "commune.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        for (nom_c, code_d), _ in commune_set.items():
            w.writerow([nom_c, code_d])

    # Écrire personne (id_personne, nom, prenom, prenom_pere, nom_mere, prenom_mere)
    # nom et prenom jamais vides (sinon COPY peut les lire comme NULL)
    with open(os.path.join(OUTPUT_DIR, "personne.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        for (nom, prenom, pp, nm, pm), id_p in personne_set.items():
            w.writerow([id_p, nom or ".", prenom or ".", pp or "", nm or "", pm or ""])

    # Écrire acte (id_acte, id_type_acte, id_personne_a, id_personne_b, id_commune, date_acte, num_vue)
    # PostgreSQL COPY : NULL = \N
    with open(os.path.join(OUTPUT_DIR, "acte.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        for a in actes_rows:
            w.writerow([
                a["id_acte"],
                a["id_type_acte"],
                a["id_personne_a"],
                a["id_personne_b"],
                a["id_commune"],
                a["date_acte"] if a["date_acte"] is not None else "\\N",
                a["num_vue"] if a["num_vue"] is not None else "\\N",
            ])

    print(f"Source: {csv_path}")
    print(f"Sortie: {OUTPUT_DIR}")
    print(f"  type_acte:   {len(type_acte_set)} lignes")
    print(f"  commune:     {len(commune_set)} lignes")
    print(f"  personne:    {len(personne_set)} lignes")
    print(f"  acte:        {len(actes_rows)} lignes")
    print("Terminé.")


if __name__ == "__main__":
    main()
