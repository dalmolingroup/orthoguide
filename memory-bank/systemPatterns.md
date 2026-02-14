# System Patterns

## Architecture
The application follows a decoupled architecture where data generation is a separate upstream process from the interactive frontend.

```mermaid
flowchart LR
    subgraph DataPipeline [Data Generation Pipeline]
        RawData[Biological Data] --> Nextflow[Nextflow Pipeline]
        Nextflow --> R[R Scripts (GeneBridge)]
        R --> CSV[CSV Results]
        CSV --> SQLite[SQLite Database Building]
    end

    subgraph FrontendApp [Frontend Application]
        DB[SQLite DB (WASM)] --> SQLJS[sql.js]
        SQLJS --> View[HomeView Logic]
        View --> Components[ResultsCard / NetworkGraph]
        View -- "Fetch PPI" --> STRING[STRING-DB API]
    end

    SQLite -->|Static Asset Deployment| DB
```

## Data Integration Pattern
- **Static Database File**: The SQLite database (`orthoguide_data.db`) is fetched via HTTP and loaded into memory by `sql.js`.
- **Hybrid Data Source**:
    - **Core Rooting Data**: Served locally from the SQLite DB (fast, offline-capable).
    - **Network Interaction Data**: Fetched dynamically from external STRING-DB API (requires internet, rich context).

## Component Patterns
- **Orchestrator View**: `HomeView.vue` acts as the main controller. It handles:
    - Database initialization.
    - Global loading states.
    - Data fetching (SQLite lookup + STRING API calls).
    - Filtering logic (Clade processing).
- **Presentation Components**:
    - `AnalysisCard`: Input form for genes and species selection.
    - `ResultsCard`: Container for all results visualizations.
    - `NetworkGraph`: D3.js visualization wrapper.
    - `CladeSlider`: UI control for filtering depth.

## Pipeline Patterns
- **Nextflow Orchestration**: Manages the parallel execution of R scripts for multiple species.
- **Dockerization**: Both the data generation tools and the frontend dev environment are containerized.
