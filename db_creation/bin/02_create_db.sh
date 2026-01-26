#!/bin/bash

# =============================================================================
# Script to Create SQLite Database from GeneBridge CSV Results with Schema
# =============================================================================

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_csv_results_directory>"
    exit 1
fi

CSV_DIR=$1
DB_FILE="orthoguide_data.db"

if [ -f "$DB_FILE" ]; then
    echo "Removing existing database file: $DB_FILE"
    rm "$DB_FILE"
fi

if [ ! -d "$CSV_DIR" ]; then
    echo "Error: Directory '$CSV_DIR' not found."
    exit 1
fi

find "$CSV_DIR/" -name "*_result.csv" | while read -r filepath; do
    
    filename=$(basename "$filepath")
    
    species_id=$(echo "$filename" | cut -d'_' -f1)
    
    if [ -z "$species_id" ]; then
        echo "Warning: Could not extract species ID from '$filename'. Skipping."
        continue
    fi
    
    echo "Processing file: $filename -> Table: \"$species_id\""
    
    sqlite3 "$DB_FILE" <<EOF

-- Create a temporary table matching the CSV structure exactly
CREATE TABLE "${species_id}_temp" (
    cog_id          TEXT,
    root            INTEGER,
    Dscore          REAL,
    Statistic       REAL,
    Pvalue          REAL,
    AdjPvalue       REAL,
    clade_name      TEXT,
    protein_id      TEXT,
    ssp_id          INTEGER,
    preferred_name  TEXT
);

.mode csv
.import --skip 1 "$filepath" "${species_id}_temp"

-- Create the final table with only columns used by the application
CREATE TABLE "$species_id" (
    preferred_name  TEXT,
    protein_id      TEXT,
    clade_name      TEXT,
    root            INTEGER,
    cog_id          TEXT
);

-- Copy data from temp to final, sorting by root to improve compression
INSERT INTO "$species_id" (preferred_name, protein_id, clade_name, root, cog_id)
SELECT preferred_name, protein_id, clade_name, root, cog_id FROM "${species_id}_temp" ORDER BY root;

-- Drop the temporary table
DROP TABLE "${species_id}_temp";

EOF
    
done

echo "Optimizing database size..."
sqlite3 "$DB_FILE" "VACUUM;"

echo ""
echo "Database '$DB_FILE' created successfully with the following tables:"
sqlite3 "$DB_FILE" ".tables"

echo "Compressing database..."
gzip -9 -f "$DB_FILE"

echo ""
echo "Process finished. Created ${DB_FILE}.gz"
