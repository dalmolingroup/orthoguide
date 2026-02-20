import glob
import os
import sys

def main():
    try:
        with open('prompt.template.txt', 'r', encoding='utf-8') as f:
            template = f.read()
    except FileNotFoundError:
        print("Error: prompt.txt not found.", file=sys.stderr)
        return

    lineage_files = glob.glob('problems/*.lineage.tsv')
    lineage_files.sort()
    
    if not lineage_files:
        print("No lineage files found in problems/", file=sys.stderr)
        return

    # Create the output directory if it doesn't exist
    os.makedirs('prompts', exist_ok=True)

    for lineage_path in lineage_files:
        counts_path = lineage_path.replace('.lineage.tsv', '.counts.tsv')
        
        if not os.path.exists(counts_path):
            print(f"Warning: Corresponding counts file not found for {lineage_path}", file=sys.stderr)
            continue
            
        try:
            with open(lineage_path, 'r', encoding='utf-8') as f:
                lineage_content = f.read().strip()
                
            with open(counts_path, 'r', encoding='utf-8') as f:
                counts_content = f.read().strip()
                
            prompt_content = template.replace('{{COUNTS_FILE_CONTENT}}', counts_content)
            prompt_content = prompt_content.replace('{{LINEAGES_FILE_CONTENT}}', lineage_content)
            
            # Construct output path in the prompts/ folder
            base_filename = os.path.basename(lineage_path).replace('.lineage.tsv', '.prompt.txt')
            output_path = os.path.join('prompts', base_filename)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(prompt_content)
                
            print(f"Created {os.path.basename(output_path)}")
            
        except Exception as e:
            print(f"Error processing {lineage_path}: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
