#!/bin/bash
# Bonus : import des données mariages_L3.csv (~564k) et exécution des 5 requêtes
# Usage : se placer DANS le dossier du projet puis : ./scripts/run_bonus.sh
# Prérequis : data/mariages_L3.csv doit exister (à ajouter pour le bonus)

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$PROJECT_DIR/data"
DB_NAME="${1:-mariages_bdd}"

# psql : Linux souvent "sudo -u postgres psql", Mac souvent "psql"
PSQL_CMD="${PSQL_CMD:-sudo -u postgres psql}"

if [ ! -f "$DATA_DIR/mariages_L3.csv" ]; then
  echo "Erreur: $DATA_DIR/mariages_L3.csv introuvable."
  echo "Pour le bonus, placez le fichier mariages_L3.csv dans le dossier data/ du projet."
  exit 1
fi

echo "=== 1. Extraction des données depuis data/mariages_L3.csv ==="
python3 "$SCRIPT_DIR/extract_and_prepare_data.py" "$DATA_DIR/mariages_L3.csv"

echo ""
echo "=== 2. Vidage des tables et réimport ==="
cd "$PROJECT_DIR"
$PSQL_CMD -d "$DB_NAME" -c "TRUNCATE acte, personne, commune, type_acte, departement RESTART IDENTITY CASCADE;"
$PSQL_CMD -d "$DB_NAME" -f sql/02_import_data.sql

echo ""
echo "=== 3. Exécution des 5 requêtes (bonus) ==="
$PSQL_CMD -d "$DB_NAME" -f sql/03_requetes_genealogistes.sql

echo ""
echo "Bonus terminé."
