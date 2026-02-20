# OrthoGuide Database Creation Pipeline

This directory contains the Nextflow pipeline and the necessary scripts to generate the orthoguide_data.db database from scratch.

## Overview

The pipeline automates the process of phylogenetic rooting analysis for multiple species and the subsequent creation of a consolidated SQLite database. It is composed of two main processes:

1. GENEBRIDGE: Runs an R script that uses the GeneBridge package to analyze the data for each species and generate CSV files with the results.

2. DB_CREATION: Takes the generated CSV files and imports them into a single SQLite database file, with one table for each species.

Prerequisites

To run this pipeline, you will need:

- Nextflow (version 21.10.x or higher).

- A container engine:

  - Docker or

  - Singularity

## File Structure

The pipeline expects input data files in the `data/` folder. Most of these can be downloaded automatically (see below).

```
.
├── db_creation/
│   ├── main.nf
│   ├── nextflow.config
│   └── ...
├── data/
│   ├── final_species_list.txt      # List of species to process
│   ├── clade_names/                # Directory with clade names per species
│   ├── string_eukaryotes.rda       # Required R data
│   ├── gpdata_string_v11.RData     # Downloadable reference
│   ├── COG.mappings.v11.0.txt.gz   # Downloadable reference
│   └── protein.info.v11.0.txt.gz   # Downloadable reference
└── orthoguide_front/
```

## Configuration Parameters

The pipeline parameters can be configured in `nextflow.config` or overridden at runtime via the command line.

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `download_references` | Set to `true` to download reference datasets (`gpdata`, `COG`, `protein.info`) automatically. | `false` |
| `species_list` | Path to the file containing the list of species IDs. | `${baseDir}/data/final_species_list.txt` |
| `clade_names_dir` | Directory containing clade name mappings. | `${baseDir}/data/clade_names/` |
| `string_eukaryotes` | Path to the `string_eukaryotes.rda` file. | `${baseDir}/data/string_eukaryotes.rda` |
| `geneplast_data` | Path to Geneplast data. | `${baseDir}/data/gpdata_string_v11.RData` |
| `cogdata_table` | Path to COG mappings. | `${baseDir}/data/COG.mappings.v11.0.txt.gz` |
| `protein_info` | Path to protein info. | `${baseDir}/data/protein.info.v11.0.txt.gz` |
| `outdir` | Output directory for the generated database. | `../orthoguide_front/public/` |

## Downloading References

If you do not have the large reference files (`gpdata_string_v11.RData`, `COG.mappings.v11.0.txt.gz`, `protein.info.v11.0.txt.gz`), you can instruct the pipeline to download them by adding `--download_references`:

```bash
nextflow run main.nf -profile docker --download_references
```

## How to Run the Pipeline

1. **Navigate to the directory:**
   Open your terminal at the root of the `db_creation` directory.

2. **Run the pipeline:**
   Execute the Nextflow command, selecting your container engine (`docker` or `singularity`).

   *Standard run (using existing data):*
   ```bash
   nextflow run main.nf -profile docker
   ```

   *Run with reference download:*
   ```bash
   nextflow run main.nf -profile docker --download_references
   ```

## Output

After a successful run, the pipeline will generate the `orthoguide_data.db` SQLite database in `orthoguide_front/public/` (or the location specified by `--outdir`).