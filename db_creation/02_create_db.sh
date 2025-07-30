#!/bin/bash

# =============================================================================
# Script to Create SQLite Database from GeneBridge CSV Results
# =============================================================================

DB_FILE="../orthoguide_front/public/orthoguide_data.db"
CSV_DIR="results"


if [ -f "$DB_FILE" ]; then
    echo "Removing existing database file: $DB_FILE"
    rm "$DB_FILE"
fi

if [ ! -d "$CSV_DIR" ]; then
    echo "Error: Directory '$CSV_DIR' not found."
    echo "Please run the R script first to generate the result files."
    exit 1
fi

find "$CSV_DIR" -name "*_result.csv" | while read -r filepath; do
    
    filename=$(basename "$filepath")
    
    species_id=$(echo "$filename" | cut -d'_' -f1)
    
    if [ -z "$species_id" ]; then
        echo "Warning: Could not extract species ID from '$filename'. Skipping."
        continue
    fi
    
    
    sqlite3 "$DB_FILE" <<EOF
.mode csv
.import "$filepath" "$species_id"
EOF
    
done

echo ""
echo "Database '$DB_FILE' created successfully with the following tables:"
sqlite3 "$DB_FILE" ".tables"



