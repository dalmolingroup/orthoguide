#!/usr/bin/env Rscript
library('AnnotationHub')
cache_dir <- file.path(tempdir(), "ahub_cache")
dir.create(cache_dir, showWarnings = FALSE)

# Set the global option for AnnotationHub
setAnnotationHubOption("CACHE", cache_dir)
ah <- AnnotationHub()
meta <- query(ah, "geneplast")
load(meta[["AH83116"]])
save(cogdata, phyloTree, file = "gpdata_string_v11.RData")
