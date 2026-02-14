# Project Brief: OrthoGuide

OrthoGuide is a web tool designed for evolutionary rooting analysis based on GeneBridge results.

## Core Requirements
- Provide a web interface for analyzing evolutionary rooting data.
- Visualize results using graphs and charts.
- Operate as a Single Page Application (SPA).
- Utilize a client-side database (SQLite-wasm) for offline-capable or server-light operation (database size dependent).

## Architecture Overview
- **Frontend**: Vue.js 3 application built with Vite.
- **Database**: SQLite3, accessed in the browser via `sql.js` (WebAssembly).
- **Data Generation**: Pipeline involving R, Bash, and Nextflow to generate the SQLite database from biological data.
- **Deployment**: Dockerized application.

## Key Features
- **Evolutionary Root Inference**: Query local SQLite database to infer evolutionary roots for input genes.
- **Network Graph Visualization**: Interactive force-directed graphs (D3.js) enriched with Protein-Protein Interaction (PPI) data from STRING-DB.
- **Statistical Analysis**: Bar charts showing cumulative gene counts per clade and sortable results tables.
- **Interactive Filtering**: Filter networks by evolutionary clade depth.
