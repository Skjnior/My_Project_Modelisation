#!/bin/bash
# Charge le schéma puis les données (après extraction).
# Usage : depuis le dossier du projet : ./scripts/load_into_postgres.sh [nom_base]

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SQL_DIR="$PROJECT_DIR/sql"
DB_NAME="${1:-mariages_bdd}"
PSQL_CMD="${PSQL_CMD:-sudo -u postgres psql}"

cd "$PROJECT_DIR"
$PSQL_CMD -d postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || true
$PSQL_CMD -d "$DB_NAME" -f "$SQL_DIR/01_schema_postgresql.sql"
$PSQL_CMD -d "$DB_NAME" -f "$SQL_DIR/02_import_data.sql"
echo "Import terminé."
