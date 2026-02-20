import glob
import csv
import re
import os
import sys

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
        if not part.strip():
            continue
        # Regex: remove whitespace followed by (digits), then strip outer whitespace
        # e.g. " Sar (38) " -> "Sar"
        clean_name = re.sub(r'\s*\(\d+\)', '', part).strip()
        if clean_name:
            cleaned_names.add(clean_name)
    return cleaned_names

def main():
    lineages = []

    with open('../../../../species_lineage.tsv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            lineages.append(row.get('lineage_txt', ''))

    # Find missing fix files
    counts_files = glob.glob('problems/*.counts.tsv')
    counts_files.sort()
    
    processed_count = 0
    
    for counts_path in counts_files:
        fix_path = counts_path.replace('.counts.tsv', '.fix.tsv')
        
        if not os.path.exists(fix_path):
            processed_count += 1
            file_rows = []
            
            try:
                with open(counts_path, 'r', encoding='utf-8') as f:
                    reader = csv.DictReader(f, delimiter='\t')
                    for row in reader:
                        root = row.get('root', '')
                        clade_str = row.get('clade_name', '')
                        
                        clean_names = clean_clade_set(clade_str)
                        sorted_names = sorted(list(clean_names))
                        
                        for name in sorted_names:
                            matched_lineage = None
                            for lin in lineages:
                                if name in lin:
                                    idx = lin.find(name)
                                    matched_lineage = lin[:idx + len(name)]
                                    break
                            
                            if matched_lineage:
                                file_rows.append({'root': root, 'lineage': matched_lineage})
                
                if not file_rows:
                    continue

                # Find longest common prefix of components
                split_lineages = [row['lineage'].split('; ') for row in file_rows]
                
                if not split_lineages:
                    continue
                    
                common_prefix = split_lineages[0]
                for other in split_lineages[1:]:
                    new_len = 0
                    for i in range(min(len(common_prefix), len(other))):
                        if common_prefix[i] == other[i]:
                            new_len += 1
                        else:
                            break
                    common_prefix = common_prefix[:new_len]
                    if not common_prefix:
                        break
                
                # Keep last component of common prefix
                remove_count = max(0, len(common_prefix) - 1)
                
                lineage_out_path = counts_path.replace('.counts.tsv', '.lineage.tsv')
                
                with open(lineage_out_path, 'w', encoding='utf-8', newline='') as f_out:
                    writer = csv.writer(f_out, delimiter='\t')
                    for row in file_rows:
                        parts = row['lineage'].split('; ')
                        if len(parts) >= remove_count:
                            kept_parts = parts[remove_count:]
                        else:
                            kept_parts = parts
                            
                        cleaned_lineage = " -> ".join(kept_parts)
                        writer.writerow([row['root'], cleaned_lineage])

            except Exception as e:
                print(f"Error processing {counts_path}: {e}", file=sys.stderr)

    if processed_count == 0:
        print("No missing fix files found.", file=sys.stderr)

if __name__ == "__main__":
    main()