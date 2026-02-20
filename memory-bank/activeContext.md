# Active Context

## Current Focus
Establishing a comprehensive and up-to-date memory bank to guide future development. The project is currently in a functional state with implemented core features.

## Recent Changes
- Fixed hardcoded colors in `CladeSlider.vue`: Updated tooltip styling to use theme-aware variables (`var(--color-background-soft)`, `var(--color-text)`, `var(--color-border)`) instead of hardcoded dark gray.
- Fixed dark mode issue in `AboutView.vue`: Replaced hardcoded color values with theme-aware CSS custom properties (`var(--color-*)`) to ensure correct rendering in both light and dark modes.
- Fixed header/footer text color issue: Replaced hardcoded `#333` color in `main.css` with `var(--color-text)` to ensure proper contrast in both light and dark modes.
- Analyzed `orthoguide_front/src` to understand component relationships and business logic.
- Confirmed implementation of:
    - Client-side SQLite database loading (`sql.js`).
    - PPI Network fetching from STRING-DB.
    - Clade-based filtering logic.
    - Component structure: `HomeView` orchestrating `AnalysisCard` and `ResultsCard`.

## Active Decisions
- **Framework**: Vue 3 + Vite.
- **Database**: SQLite via `sql.js` (WASM), loaded as a static asset from requested URL.
- **External Data**: STRING-DB API used for fetching network interaction data to enrich local rooting results.

## Next Steps
- Verify specific test coverage if needed.
- Address any potential performance bottlenecks with large gene lists (currently capped/warned at 500 genes for network visualization).
- Refine UI/UX based on user feedback.
