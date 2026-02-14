import glob
import csv
import re
import math
import os
import sys

def parse_clade_counts(clade_str):
    """
    Parses "Afrotheria (6); Xenarthra (1)" into [('Afrotheria', 6), ('Xenarthra', 1)].
    Returns a list of (name, count) tuples.
    """
    if not clade_str:
        return []
    
    parts = clade_str.split(';')
    result = []
    
    for part in parts:
        if not part.strip():
            continue
            
        # Extract count
        count_match = re.search(r'\((\d+)\)', part)
        if count_match:
            count = int(count_match.group(1))
        else:
            # If no count found, skip or treat as 0/1? 
            # Based on file format, counts seem mandatory.
            continue
            
        # Extract name: remove whitespace followed by (digits), then strip
        name = re.sub(r'\s*\(\d+\)', '', part).strip()
        
        if name:
            result.append((name, count))
            
    return result

def calculate_normalized_entropy(counts):
    """
    Calculates normalized Shannon entropy.
    H' = -sum(p_i * log2(p_i)) / log2(N)
    """
    if not counts or len(counts) <= 1:
        return 0.0
    
    total = sum(counts)
    if total == 0:
        return 0.0
        
    probs = [c / total for c in counts]
    entropy = -sum(p * math.log2(p) for p in probs if p > 0)
    
    max_entropy = math.log2(len(counts))
    if max_entropy == 0:
        return 0.0
        
    return entropy / max_entropy

def process_files():
    files = glob.glob('problems/*.counts.tsv')
    files.sort()
    
    if not files:
        print("No files found matching problems/*.counts.tsv")
        return

    for filepath in files:
        filename = os.path.basename(filepath)
        
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f, delimiter='\t')
                rows = list(reader)
        except Exception as e:
            print(f"Error reading {filepath}: {e}", file=sys.stderr)
            continue
            
        if not rows:
            continue

        if 'clade_name' not in rows[0]:
            print(f"Skipping {filename}: 'clade_name' column not found.", file=sys.stderr)
            continue

        # Pre-process rows to get sets for intersection checks
        row_sets = []
        parsed_data = []
        
        for row in rows:
            clade_str = row.get('clade_name', '')
            parsed = parse_clade_counts(clade_str)
            name_set = set(p[0] for p in parsed)
            row_sets.append(name_set)
            parsed_data.append(parsed)

        # Check entropy and intersection for ALL rows
        all_checks_passed = True
        final_rows = [] 
        
        for i in range(len(rows)):
            current_set = row_sets[i]
            
            # Check Intersection
            intersects = False
            
            # Check Above
            if i > 0:
                prev_set = row_sets[i-1]
                if not current_set.isdisjoint(prev_set):
                    intersects = True
            
            # Check Below
            if i < len(rows) - 1:
                next_set = row_sets[i+1]
                if not current_set.isdisjoint(next_set):
                    intersects = True
            
            if intersects:
                # If there is an intersection, we stop processing this file
                # as it violates the condition "only continue if there is no intersection"
                all_checks_passed = False
                break

            # Calculate Entropy
            parsed = parsed_data[i]
            counts = [p[1] for p in parsed]
            entropy = calculate_normalized_entropy(counts)
            
            if entropy >= 0.7:
                all_checks_passed = False
                break
            
            final_rows.append({
                'row': rows[i],
                'parsed': parsed,
                'entropy': entropy
            })
        
        if all_checks_passed:
            # Generate .fix.tsv
            fix_filename = filepath.replace('.counts.tsv', '.fix.tsv')
            
            try:
                # Collect rows to write
                rows_to_write = []
                for item in final_rows:
                    entropy = item['entropy']
                    if entropy > 0.0:
                        original_row = item['row']
                        parsed = item['parsed']
                        root_val = original_row.get('root', '')
                        
                        # Find name with greatest count
                        if parsed:
                            parsed.sort(key=lambda x: x[1], reverse=True)
                            best_name = parsed[0][0]
                        else:
                            best_name = original_row.get('clade_name', '')
                        
                        rows_to_write.append([root_val, best_name, "normalized entropy < 0.7"])
                
                if rows_to_write:
                    with open(fix_filename, 'w', encoding='utf-8', newline='') as f_out:
                        writer = csv.writer(f_out, delimiter='\t')
                        writer.writerow(['root', 'clade_name', 'reason'])
                        writer.writerows(rows_to_write)
                    print(f"Created {os.path.basename(fix_filename)}")
                else:
                    print(f"Skipping {os.path.basename(fix_filename)}: No rows with entropy > 0 found.")
            
            except Exception as e:
                print(f"Error writing {fix_filename}: {e}", file=sys.stderr)

if __name__ == "__main__":
    process_files()
