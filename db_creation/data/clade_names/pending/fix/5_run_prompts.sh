#!/bin/bash

# Change the glob pattern to look in the 'prompts/' directory
for prompt_file in prompts/*.prompt.txt; do
    if [ -f "$prompt_file" ]; then
        
        # Determine the base filename (e.g., 'file') from 'prompts/file.prompt.txt'
        base_name=$(basename "$prompt_file" .prompt.txt)
        
        # Construct the output path in 'problems/'
        output_file="problems/${base_name}.fix.tsv"
        
        # Check if the output file already exists in 'problems/'
        if [ -f "$output_file" ]; then
            echo "$output_file already exists. Skipping."
            continue
        fi

        echo "Creating $output_file..."

        cat "$prompt_file" | gemini --model gemini-3-pro-preview > "$output_file" 2> .gemini.log
        
        if [ $? -ne 0 ]; then
            echo "Error processing $prompt_file"
        fi

        sleep 5
    fi
done

echo "Batch processing complete."
