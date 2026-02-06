import glob
import csv
import re
import requests
import time
import xml.etree.ElementTree as ET
import os

# Memoization cache to avoid redundant API calls
lineage_cache = {}

def get_taxon_id(term):
    url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    params = {
        "db": "taxonomy",
        "term": term,
        "retmode": "json"
    }
    try:
        r = requests.get(url, params=params)
        r.raise_for_status()
        data = r.json()
        id_list = data.get("esearchresult", {}).get("idlist", [])
        if id_list:
            return id_list[0]
        return None
    except Exception as e:
        print(f"Error searching {term}: {e}")
        return None

def get_lineage(taxon_id):
    url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    params = {
        "db": "taxonomy",
        "id": taxon_id
    }
    try:
        r = requests.get(url, params=params)
        r.raise_for_status()
        root = ET.fromstring(r.content)
        lineage_node = root.find(".//Lineage")
        if lineage_node is not None:
            return lineage_node.text
        return None
    except Exception as e:
        print(f"Error fetching lineage for {taxon_id}: {e}")
        return None

def process_file(filepath):
    problematic_lines = []
    
    with open(filepath, 'r', newline='') as f:
        content = f.read()
        f.seek(0)
        
        # Simple header detection
        has_header = False
        if content:
            first_line = content.splitlines()[0]
            if "root" in first_line.lower() or "clade" in first_line.lower():
                has_header = True
        
        reader = csv.reader(f, delimiter='	')
        if has_header:
            try:
                next(reader)
            except StopIteration:
                pass
        
        rows = list(reader)

    for row in rows:
        if len(row) > 1 and ';' in row[1]:
            problematic_lines.append(row)

    if not problematic_lines:
        return

    print(f"Processing {filepath} ({len(problematic_lines)} problematic lines)")

    base_name = filepath.replace(".tsv", "")
    prob_filename = f"{base_name}.tsv.problematic"
    
    with open(prob_filename, 'w', newline='') as f:
        writer = csv.writer(f, delimiter='	')
        for row in problematic_lines:
            writer.writerow(row)
    
    lineage_filename = f"{base_name}.tsv.lineage"
    
    with open(lineage_filename, 'w', newline='') as f:
        writer = csv.writer(f, delimiter='	')
        
        for row in problematic_lines:
            root_id = row[0]
            raw_clades = row[1]
            
            clades = raw_clades.split(';')
            for clade in clades:
                # Remove (numbers) and whitespace
                clean_name = re.sub(r'\s*\(\d+\)', '', clade).strip()
                if not clean_name:
                    continue
                
                # Use cache if available
                if clean_name in lineage_cache:
                    print(f"  Using cache for: '{clean_name}'")
                    lineage = lineage_cache[clean_name]
                    if lineage:
                        full_value = f"{lineage}; {clean_name}"
                        writer.writerow([root_id, full_value])
                    continue

                print(f"  Fetching: '{clean_name}'")
                
                # NCBI rate limit friendliness
                time.sleep(0.35)
                tid = get_taxon_id(clean_name)
                
                lineage = None
                if tid:
                    time.sleep(0.35)
                    lineage = get_lineage(tid)
                    if lineage:
                        full_value = f"{lineage}; {clean_name}"
                        writer.writerow([root_id, full_value])
                    else:
                        print(f"    No lineage for {clean_name}")
                else:
                    print(f"    No ID for {clean_name}")
                
                # Cache the result
                lineage_cache[clean_name] = lineage

def main():
    # Find .tsv files, excluding those we generate
    files = [f for f in glob.glob("*.tsv") if not f.endswith(".problematic") and not f.endswith(".lineage")]
    files.sort()
    for f in files:
        process_file(f)

if __name__ == "__main__":
    main()
