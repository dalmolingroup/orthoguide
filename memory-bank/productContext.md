# Product Context

## Purpose
OrthoGuide serves as a specialized visualization and analysis tool for researchers working with evolutionary biology, specifically focusing on rooting analysis using the GeneBridge methodology. It simplifies the complex data derived from these analyses into an interactive and accessible web format.

## Problem Solved
Raw outputs from evolutionary analysis pipelines like GeneBridge can be dense and difficult to interpret directly. Researchers need a way to explore these results visually, checking phylogenetic networks and statistical distributions without writing custom scripts for every analysis.

## How It Works
1.  **Data Ingestion**: The system pre-processes biological data using an R/Nextflow pipeline to create a structured SQLite database (`orthoguide_data.db`).
2.  **Client-Side Processing**: The Vue.js frontend loads this database directly in the user's browser using WebAssembly (`sql.js`).
3.  **Visualization**:
    *   **Network Graphs**: Users can explore gene/species relationships via D3.js force-directed graphs. PPI data is fetched dynamically from the STRING-DB API.
    *   **Charts & Tables**: Quantitative results are displayed using Chart.js (cumulative gene counts) and DataTables (detailed results list).
4.  **Interaction**: Users can input gene lists, filter results by species, and use a slider to filter the network view by evolutionary clade depth.

## User Experience Goals
-   **Responsiveness**: Fast interaction by keeping core rooting data client-side.
-   **Clarity**: Clean visualizations that make complex network data understandable.
-   **Accessibility**: Browser-based tool requiring no local installation of complex bioinformatics software for the end user.
