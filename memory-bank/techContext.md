# Tech Context

## Frontend Stack
-   **Framework**: Vue.js 3 (Composition API, `<script setup>`).
-   **Build Tool**: Vite 7.0.0.
-   **Routing**: vue-router 4.5.1.
-   **State/Data**:
    -   `sql.js` (WebAssembly) for client-side SQLite.
    -   Native `fetch` for external API and database loading.
-   **Visualization**:
    -   `d3` (7.9.0) for network graphs.
    -   `chart.js` (4.5.0) via `vue-chartjs` (likely) or direct integration for statistical charts.
    -   `datatables.net-vue3` for interactive tables.
-   **Testing**: Vitest.
-   **Styling**: Standard CSS, scoped to components or global assets.

## Data Pipeline Stack
-   **Orchestration**: Nextflow.
-   **Analysis**: R with GeneBridge package.
-   **Scripting**: Bash for database construction.
-   **Database**: SQLite3.

## Environment
-   **Development**: Docker Compose is used to standardize the dev environment.
-   **Run Requirements**: Modern browser with WebAssembly support. Internet connection required for STRING-DB PPI network features.

## Constraints
-   **Database Size**: The `.db` file is downloaded to the client. Size must be managed to ensure reasonable initial load times (current logic fetches arrayBuffer).
-   **Browser Memory**: Large datasets or network graphs (capped at ~500 nodes in logic) can strain browser memory and rendering performance.
-   **CORS/API Limits**: STRING-DB API usage is subject to rate limiting and CORS policies, though currently functioning via direct fetch.
