import glob
import csv
import os
import sys

def check_file(filepath):
    """
    Checks if a root_names.tsv file has a contiguous sequence of roots starting at 1.
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f, delimiter='	')
            
            # Extract root numbers
            roots = []
            for row in reader:
                try:
                    roots.append(int(row['root']))
                except (ValueError, KeyError):
                    continue
            
            if not roots:
                return "Empty file or no 'root' column"
            
            # Sort roots to ensure sequence check works regardless of file order
            roots.sort()
            
            issues = []
            
            # Check if it starts at 1
            if roots[0] != 1:
                issues.append(f"Starts at {roots[0]} instead of 1")
            
            # Check for gaps
            gaps = []
            for i in range(len(roots) - 1):
                if roots[i+1] != roots[i] + 1:
                    gaps.append(f"{roots[i]}->{roots[i+1]}")
                    
            if gaps:
                # Summarize gaps if there are too many
                if len(gaps) > 3:
                    issues.append(f"Has {len(gaps)} gaps (e.g., {', '.join(gaps[:3])}...)")
                else:
                    issues.append(f"Has gaps: {', '.join(gaps)}")
            
            if issues:
                return "; ".join(issues)
            
            return None

    except Exception as e:
        return f"Error reading file: {e}"

def main():
    # Search for files in the parent directory
    files = glob.glob('../*_root_names.tsv')
    files.sort()
    
    if not files:
        print("No *_root_names.tsv files found in parent directory.")
        return

    print(f"Checking {len(files)} files...")
    
    problem_count = 0
    for filepath in files:
        result = check_file(filepath)
        if result:
            print(f"{os.path.basename(filepath)}: {result}")
            problem_count += 1
            
    if problem_count == 0:
        print("All files look good! (Start at 1, contiguous)")
    else:
        print(f"\nFound issues in {problem_count} files.")

if __name__ == "__main__":
    main()
