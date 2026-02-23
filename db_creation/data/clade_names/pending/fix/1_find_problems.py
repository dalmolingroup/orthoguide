import csv
import re
import os
import glob
import hashlib

FIX_MAP_FILE = 'fix_map.tsv'
with open(FIX_MAP_FILE, 'w', newline='', encoding='utf-8') as f:
    f.write('problematic\tfix\tfrom_root\tto_root\n')

INPUT_FILES = glob.glob('../*_root_names.tsv')
OUTPUT_DIR = 'problems'
COLUMNS_TO_PRINT = ['root', 'clade_name']

def clean_clade_set(clade_str):
    """
    Parses "Sar (38); Haptista (1)" into set({'Sar', 'Haptista'}).
    Removes parentheses/numbers and splits by semicolon.
    """
    if not clade_str:
        return set()
    
    # Split by semicolon
    parts = clade_str.split(';')
    cleaned_names = set()
    
    for part in parts:
        # Regex: remove whitespace followed by (digits), then strip outer whitespace
        # e.g. " Sar (38) " -> "Sar"
        clean_name = re.sub(r'\s*\(\d+\)', '', part).strip()
        cleaned_names.add(clean_name)
            
    return cleaned_names

for INPUT_FILE in INPUT_FILES:
    print(f"Reading {INPUT_FILE}...")
    with open(INPUT_FILE, 'r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        rows = list(reader)

    flagged_roots = set()

    for i, row in enumerate(rows):

        # 1st rule: flagging roots with non-monophyletic taxa (containing ";")
        if ';' in row["clade_name"]:
            flagged_roots.add(int(row['root']))
            continue
            
        # 2nd rule: flagging roots containing the same taxa
        current_set = clean_clade_set(row["clade_name"])

        # Standardizes column format ("15,Metatheria,3" -> "15,Metatheria (3)")
        row['clade_name'] = f"{row['clade_name']} ({row['counts']})"
        
        # Checks row above (i-1)
        if i > 0:
            prev_set = clean_clade_set(rows[i-1].get('clade_name', ''))
            if not current_set.isdisjoint(prev_set): # True if intersection exists
                flagged_roots.add(int(row['root']))
                continue

        # Checks row below (i+1)
        if i < len(rows) - 1:
            next_set = clean_clade_set(rows[i+1].get('clade_name', ''))
            if not current_set.isdisjoint(next_set):
                flagged_roots.add(int(row['root']))
                continue

    # Groups roots according to gaps in the sequence ([1, 2, 5, 6] -> [[1, 2], [5, 6]])
    # Sort first to ensure sequence logic works
    flagged_roots = sorted(flagged_roots)

    groups = []
    if flagged_roots:
        current_group = [flagged_roots[0]]
        
        for root in flagged_roots[1:]:
            # If gap > 1, start new group
            if root - current_group[-1] > 1:
                groups.append(current_group)
                current_group = [root]
            else:
                current_group.append(root)
        groups.append(current_group)

    # 4. Write Output Files
    base_name = os.path.splitext(os.path.basename(INPUT_FILE))[0]
    file_output_dir = os.path.join(OUTPUT_DIR, base_name)
    
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    for group in groups:
        # Determine filename bounds
        min_root = group[0]
        max_root = group[-1]
        filename = f"{min_root:03d}-{max_root:03d}.counts.tsv"
        filepath = os.path.join(OUTPUT_DIR, f"{base_name}_{filename}")
        
        # Filter original rows (+/- 1 root)
        rows_to_write = [r for r in rows if (min_root - 1) <= int(r['root']) <= (max_root + 1)]

        # Check actual min/max root values in filtered rows
        actual_min_root = min(int(r['root']) for r in rows_to_write)
        actual_max_root = max(int(r['root']) for r in rows_to_write)

        # Renumber root column
        for j, r in enumerate(rows_to_write):
            r['root'] = j + 1
        
        if rows_to_write:
            with open(filepath, 'w', newline='', encoding='utf-8') as f:
                writer = csv.DictWriter(f, fieldnames=COLUMNS_TO_PRINT, delimiter='\t', extrasaction='ignore')
                writer.writeheader()
                writer.writerows(rows_to_write)
            
            with open(filepath, 'rb') as f:
                file_hash = hashlib.md5(f.read()).hexdigest()
            
            new_filename = f"{file_hash}.counts.tsv"
            new_filepath = os.path.join(OUTPUT_DIR, new_filename)
            os.replace(filepath, new_filepath)
            
            with open(FIX_MAP_FILE, 'a', newline='', encoding='utf-8') as f:
                f.write(f"{INPUT_FILE}\t{file_hash}\t{actual_min_root}\t{actual_max_root}\n")

            print(f"-> Wrote {filename} ({len(rows_to_write)} rows) -> hashed to {new_filename}")

print("Done.")
