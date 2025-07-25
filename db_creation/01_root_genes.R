library(GeneBridge)
library(dplyr)
library(ape)
library(here)
library(vroom)
library(stringi)
library(magrittr)

#' Processes the evolutionary rooting for a specific species.
#'
#' This function runs the GeneBridge pipeline for a given species ID,
#' processes the results, and returns them as a dataframe.
#'
#' @param species_id Character. The NCBI taxon ID for the reference species (e.g., "9606" for Homo sapiens).
#' @param cogdata Dataframe. The `cogdata` dataframe containing orthologous group information.
#' @param phyloTree phylo object. The phylogenetic tree used by GeneBridge.
#' @param protein_info Dataframe. Dataframe mapping protein IDs to gene names.
#' @param lca_names Dataframe. Dataframe with LCA clade names.
#'
#' @return A dataframe containing the final rooting results for the species.
process_species_rooting <- function(species_id, cogdata, phyloTree, protein_info, lca_names) {
  
  # --- A. Filter data for the species of interest ---
  message(paste("Starting analysis for species:", species_id))
  
  species_proteins <- cogdata %>%
    filter(ssp_id == species_id)
  
  if (nrow(species_proteins) == 0) {
    stop(paste("No proteins found for species_id:", species_id, "in the cogdata dataframe."))
  }
  
  message("Running the GeneBridge pipeline...")
  
  ogr <- newBridge(
    ogdata = cogdata,
    phyloTree = phyloTree,
    ogids = unique(species_proteins$cog_id),
    refsp = species_id
  )
  
  ogr <- runBridge(ogr,
                   penalty = 2,
                   threshold = 0.5,
                   verbose = TRUE)
  
  ogr <- runPermutation(ogr, nPermutations = 1000, verbose = FALSE)
  
  res <- getBridge(ogr, what = "results")
  
  # --- C. Process and annotate the results ---
  message("Processing and annotating results...")
  
  groot_df <- res %>%
    tibble::rownames_to_column("cog_id") %>%
    dplyr::select(cog_id, root = Root) %>%
    inner_join(lca_names, by = "root") %>%
    inner_join(species_proteins, by = "cog_id") %>%
    mutate(gene_merge = paste0(species_id, ".", protein_id)) %>%
    left_join(protein_info, by = c("gene_merge" = "protein_external_id")) %>%
    dplyr::select(-c(gene_merge))
  
  message(paste("Analysis for species", species_id, "completed."))
  
  return(groot_df)
}

# Vector of NCBI Taxon IDs for the species to be processed.
TARGET_SPECIES_IDS <- c(
  "9606",  # Homo sapiens
  "10090", # Mus musculus
  "3702",  # Arabidopsis thaliana
  "4932",  # Saccharomyces cerevisiae
  "6239",  # Caenorhabditis elegans
  "7227"   # Drosophila melanogaster
)

# GenePlast and STRING data
load(here("data/string_eukaryotes.rda"))
load(here("data/gpdata_string_v11.RData"))

CLADE_NAMES_URL <- here("data/geneplast_clade_names.tsv")
lca_names <- vroom(CLADE_NAMES_URL)

protein_info <- vroom(here("data/protein.info.v11.0.txt.gz")) %>%
  dplyr::select(protein_external_id, preferred_name)

for (current_species_id in TARGET_SPECIES_IDS) {
  
  tryCatch({
    final_results <- process_species_rooting(
      species_id = current_species_id,
      cogdata = cogdata,
      phyloTree = phyloTree,
      protein_info = protein_info,
      lca_names = lca_names
    )
    
    output_file_path <- here("results", paste0(current_species_id, "_result.csv"))
    message(paste("Saving results for species", current_species_id, "to:", output_file_path))
    
    vroom::vroom_write(
      x = final_results,
      file = output_file_path,
      delim = ","
    )
    
  }, error = function(e) {
    # If an error occurs for one species, print it and continue to the next.
    message(paste("An error occurred for species", current_species_id, ":", e$message))
    message("Skipping to the next species.")
  })
  
}

message("All processes finished.")
