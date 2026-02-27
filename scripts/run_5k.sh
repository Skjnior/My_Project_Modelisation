#!/bin/bash
# Projet obligatoire : extraction 5k + création BDD + import + 5 requêtes
# Usage : se placer DANS le dossier du projet puis : ./scripts/run_5k.sh
# Prérequis : data/mariages_L3_5k.csv (inclus dans le projet)

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$PROJECT_DIR/data"
DB_NAME="${1:-mariages_bdd}"

# psql : Linux souvent "sudo -u postgres psql", Mac souvent "psql"
PSQL_CMD="${PSQL_CMD:-sudo -u postgres psql}"

if [ ! -f "$DATA_DIR/mariages_L3_5k.csv" ]; then
  echo "Erreur: $DATA_DIR/mariages_L3_5k.csv introuvable."
  exit 1
fi

echo "=== 1. Extraction des données (data/mariages_L3_5k.csv) ==="
python3 "$SCRIPT_DIR/extract_and_prepare_data.py" "$DATA_DIR/mariages_L3_5k.csv"

echo ""
echo "=== 2. Création des tables ==="
cd "$PROJECT_DIR"
$PSQL_CMD -d postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || true
$PSQL_CMD -d "$DB_NAME" -f sql/01_schema_postgresql.sql

echo ""
echo "=== 3. Import des données ==="
$PSQL_CMD -d "$DB_NAME" -f sql/02_import_data.sql

echo ""
echo "=== 4. Les 5 requêtes ==="
$PSQL_CMD -d "$DB_NAME" -f sql/03_requetes_genealogistes.sql

echo ""
echo "Projet 5k terminé."
