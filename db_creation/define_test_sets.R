if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
if (!requireNamespace("KEGGREST", quietly = TRUE)) {
  BiocManager::install("KEGGREST")
}

library(KEGGREST)

# List of species KEGG organism codes
# hsa: Homo sapiens (human)
# mmu: Mus musculus (mouse)
# dme: Drosophila melanogaster (fruit fly)
# cel: Caenorhabditis elegans (roundworm)
# sce: Saccharomyces cerevisiae (yeast)
# ath: Arabidopsis thaliana (thale cress)
species_codes <- c("hsa", "mmu", "rno", "dme", "cel", "sce", "ath")

pathway_genes_by_species <- list()

for (species in species_codes) {
  cat("Processing species:", species, "...\n")
  
  if (species == "dme") {
      pathway_id <- "04013" # MAPK signaling pathway - fly
  } else if (species == "ath") {
      pathway_id <- "04016" # MAPK signaling pathway - plant
  } else if (species == "sce") {
      pathway_id <- "04011" # MAPK signaling pathway - yeast
  } else if (species == "cel") {
      pathway_id <- "04068" # Ras signaling pathway (includes MAPK cascade for worm)
  } else {
      pathway_id <- "04742" # Taste transduction pathway
  }
  
  species_pathway_id <- paste0(species, pathway_id)
  
  pathway_data <- tryCatch({
      keggGet(species_pathway_id)
  }, error = function(e) {
      warning("Could not retrieve pathway ", species_pathway_id, ". It may not exist for this species. Error: ", e$message)
      return(NULL)
  })
  
  if (!is.null(pathway_data) && !is.null(pathway_data[[1]]$GENE)) {
      
      gene_info <- pathway_data[[1]]$GENE
      
      gene_descriptions <- gene_info[seq(2, length(gene_info), by = 2)]
      
      gene_symbols <- sapply(gene_descriptions, function(desc) {
          symbol_part <- strsplit(desc, ";")[[1]][1]
          first_symbol <- strsplit(symbol_part, ",")[[1]][1]
          return(trimws(first_symbol))
      }, USE.NAMES = FALSE)
      
      gene_symbols <- na.omit(gene_symbols)
      
      pathway_genes_by_species[[species]] <- unique(gene_symbols)
      
  } else {
      pathway_genes_by_species[[species]] <- character(0)
      cat("No gene information found for pathway", species_pathway_id, "\n")
  }
  
  Sys.sleep(1)
}

cat("\n--- Retrieval Complete ---\n\n")

output_dir <- "data/test_gene_lists"

if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  cat("Created directory:", output_dir, "\n")
}

for (species in names(pathway_genes_by_species)) {
  gene_list <- pathway_genes_by_species[[species]]
  
  if (length(gene_list) > 0) {
    file_path <- file.path(output_dir, paste0(species, "_genes.txt"))
    
    writeLines(gene_list, file_path)
    
    cat("Saved", length(gene_list), "genes for", species, "to:", file_path, "\n")
  } else {
    cat("No genes to save for species:", species, "\n")
  }
}

cat("\n--- File Saving Complete ---\n\n")