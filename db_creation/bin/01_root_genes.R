#!/usr/bin/env Rscript

# =============================================================================
# Script for Evolutionary Rooting Analysis with GeneBridge
# =============================================================================

library(GeneBridge)
library(dplyr)
library(ape)
library(vroom)
library(stringi)
library(magrittr)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 6) {
  stop("Usage: Rscript 01_root_genes.R <species_list_file> <clade_names_file> <string_eukaryotes_rda> <geneplast_data_rdata> <cogdata_table> <protein_info_gz>", call. = FALSE)
}

species_list_file <- args[1]
clade_names_file <- args[2]
string_eukaryotes_rda <- args[3]
geneplast_data_rdata <- args[4]
cogdata_table_string <- args[5]
protein_info_gz <- args[6]

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
    ogids = unique(species_proteins$og_id),
    refsp = species_id
  )
  
  ogr <- runBridge(ogr,
                   penalty = 2,
                   threshold = 0.5,
                   verbose = TRUE)
  
  ogr <- runPermutation(ogr, nPermutations = 1000, verbose = TRUE)
  
  res <- getBridge(ogr, what = "results")
  
  message("Processing and annotating results...")
  
  groot_df <- res %>%
    tibble::rownames_to_column("cog_id") %>%
    dplyr::select(cog_id, root = Root) %>%
    inner_join(lca_names, by = "root") %>%
    inner_join(species_proteins, by = c("cog_id" = "og_id")) %>%
    mutate(gene_merge = paste0(species_id, ".", protein_id)) %>%
    left_join(protein_info, by = c("gene_merge" = "protein_external_id")) %>%
    dplyr::select(-c(gene_merge))
  
  message(paste("Analysis for species", species_id, "completed."))
  
  return(groot_df)
}

message("Loading external data...")

TARGET_SPECIES_IDS <- readLines(species_list_file)

load(string_eukaryotes_rda)
load(geneplast_data_rdata)

cogs <- cogs <- vroom(
  cogdata_table_string,
  col_select = c(1, 4)
)

cogs <- cogs |> 
  rename(`taxid.string_id` = "##protein",
          og_id = orthologous_group)

separated_ids <- cogs %$%
  stri_split_fixed(taxid.string_id, pattern = ".", n = 2, simplify = T)

cogs[["taxid"]]     <- separated_ids[, 1]
cogs[["protein_id"]] <- separated_ids[, 2]

rm(separated_ids)

cogs %<>% dplyr::select(-taxid.string_id) %>% 
  filter(taxid %in% string_eukaryotes[["taxid"]])

cogs <- cogs %>% 
  dplyr::select(protein_id, ssp_id = taxid, og_id)
cogs <- as.data.frame(cogs)

cogdata <- dplyr::select(cogdata, "protein_id", "ssp_id", "og_id" = "cog_id")

ogdata <- unique(rbind(cogdata, cogs))

lca_names <- vroom(clade_names_file)

protein_info <- vroom(protein_info_gz) %>%
  dplyr::select(protein_external_id, preferred_name)

dir.create("results", showWarnings = FALSE)

for (current_species_id in TARGET_SPECIES_IDS) {
  
  tryCatch({
    final_results <- process_species_rooting(
      species_id = current_species_id,
      cogdata = ogdata,
      phyloTree = phyloTree,
      protein_info = protein_info,
      lca_names = lca_names
    )
    
    output_file_path <- file.path("results", paste0(current_species_id, "_result.csv"))
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
