# OrthoGuide Project

Welcome to the OrthoGuide project! This repository contains the full frontend application for OrthoGuide, a web tool for evolutionary rooting analysis based on [GeneBridge](https://doi.org/10.1093/molbev/msae019) results.

# Repository Structure

The project is organized into two main directories:

- `db_creation/`: Contains the R/bash code for creating the SQLite3 db used by the API

- `orthoguide_front/`: Contains the frontend single-page application with SQLite-wasm built with Vue.js.

# Serving the application

To serve the application in dev mode, run the following:

```bash
docker compose watch
```

The frontend is accessible through localhost:8080
