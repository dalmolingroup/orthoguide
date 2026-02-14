# Progress Status

## Project Status: Functional Beta / Active Development

The project has a functional frontend implementation that successfully connects input analysis with visualization. The core loop of Input -> DB Query -> Visualization is working.

## What Works
-   **Core Pipeline**: Data generation scripts (R/Nextflow) are available.
-   **Frontend App**:
    -   **Database Loading**: Successfully fetches and initializes `orthoguide_data.db` using `sql.js`.
    -   **Analysis Logic**: Correctly queries local DB for rooting info and filters by species.
    -   **External Integration**: Fetches PPI network data from STRING-DB.
    -   **Visualization**:
        -   Cumulative gene count charts.
        -   Interactive network graph with clade filtering.
        -   Data export to CSV.

## What's Left to Build
-   **Optimization**: Check performance with larger databases.
-   **Error Handling**: Refine error messages for API failures or malformed network data.
-   **Testing**: Expand Vitest coverage for components like `NetworkGraph` and `HomeView` logic.
-   **UI Refinement**: Polish transitions and loading states (currently basic text fallback for DB load).
-   **Documentation**: Add detailed setup guide for the data pipeline portion.

## Known Issues
-   **Scalability**: Network graph visualization disabled/limited for >500 genes to prevent browser hang.
-   **Dependencies**: Heavy reliance on client-side processing power; older devices may struggle with large networks.
