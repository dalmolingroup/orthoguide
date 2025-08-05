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

Before running, ensure your file structure is correct. The pipeline expects to find the input data files in the data/ folder, located at the root of the project.

```
.
├── db_creation/
│   ├── main.nf
│   ├── nextflow.config
├── data/
│   ├── species_list.txt
│   ├── geneplast_clade_names.tsv
│   ├── string_eukaryotes.rda
│   ├── gpdata_string_v11.RData
│   └── protein.info.v11.0.txt.gz
└── orthoguide_front/
```

## How to Run the Pipeline

- Open your terminal at the root of the db_creation directory.

- Run the Nextflow command, choosing the appropriate container profile (docker or singularity).

```
nextflow run main.nf -profile [docker,singularity]
```

## Output

After a successful run, the pipeline will update the orthoguide_data.db in orthoguide_front/public/ (or the directory specified by the --outdir parameter).
