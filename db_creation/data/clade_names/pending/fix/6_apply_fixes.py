import csv
import os
import sys

def main():
    fix_map_path = 'fix_map.tsv'
    
    # 1. Read fix_map.tsv
    fixes_by_file = {}
    try:
        with open(fix_map_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f, delimiter='\t')
            for row in reader:
                prob_file = row['problematic']
                fix_hash = row['fix']
                from_root = int(row['from_root'])
                to_root = int(row['to_root'])
                
                if prob_file not in fixes_by_file:
                    fixes_by_file[prob_file] = []
                fixes_by_file[prob_file].append({
                    'hash': fix_hash,
                    'from_root': from_root,
                    'to_root': to_root
                })
    except FileNotFoundError:
        print(f"Error: {fix_map_path} not found.", file=sys.stderr)
        return

    # 2. Process each problematic file
    for prob_rel_path, fix_list in fixes_by_file.items():
        # Resolve path relative to current dir
        # fix_map.tsv is in current dir. prob_rel_path is like "../file.tsv"
        # We assume strict relative path resolution.
        prob_path = prob_rel_path 
        
        if not os.path.exists(prob_path):
            print(f"Warning: Problematic file {prob_path} not found.", file=sys.stderr)
            continue
            
        print(f"Processing {prob_path}...")
        
        # Load fixes into a lookup dict keyed by renumbered root
        fix_lookup = {}
        
        for fix_info in fix_list:
            fix_hash = fix_info['hash']
            from_root = fix_info['from_root']
            
            fix_file_path = f"problems/{fix_hash}.fix.tsv"
            if not os.path.exists(fix_file_path):
                # This is expected for files processed by explode_and_match which create .lineage.tsv instead of .fix.tsv
                # So we just skip if fix file doesn't exist.
                # print(f"  Info: Fix file {fix_file_path} not found (might be complex case).", file=sys.stderr)
                continue
                
            try:
                with open(fix_file_path, 'r', encoding='utf-8') as f:
                    reader = csv.DictReader(f, delimiter='\t')
                    for row in reader:
                        original_root = int(row['root'])
                        # Renumber: new_root = fix_root + (from_root - 1)
                        new_root = original_root + (from_root - 1)
                        
                        fix_lookup[new_root] = row
            except Exception as e:
                print(f"  Error reading {fix_file_path}: {e}", file=sys.stderr)

        # 3. Read problematic file and apply fixes
        updated_rows = []
        fieldnames = []
        
        try:
            with open(prob_path, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f, delimiter='\t')
                fieldnames = reader.fieldnames
                # Keep only original columns (root, clade_name, counts) - don't add 'reason'
                
                for row in reader:
                    try:
                        root_val = int(row['root'])
                    except ValueError:
                        # Handle potential header repetition or bad data
                        updated_rows.append(row)
                        continue
                    
                    if root_val in fix_lookup:
                        fix_row = fix_lookup[root_val]
                        # Apply fix - only update clade_name, not reason
                        row['clade_name'] = fix_row['clade_name']
                            
                    updated_rows.append(row)
                    
            # 4. Write back
            with open(prob_path, 'w', encoding='utf-8', newline='') as f:
                writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='\t')
                writer.writeheader()
                writer.writerows(updated_rows)
                
            print(f"  Updated {prob_path}")
            
        except Exception as e:
            print(f"  Error processing {prob_path}: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
