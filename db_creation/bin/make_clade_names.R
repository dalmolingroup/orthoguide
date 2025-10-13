#!/usr/bin/env Rscript


message("Loading libraries...")
library(GeneBridge)
library(dplyr)
library(tidyr)
library(ape)
library(vroom)
library(stringi)
library(magrittr)
library(purrr)
library(rentrez)
library(XML)

message("Defining input files and parameters...")

MANUAL_SPECIES_ID <- "7955"


species_list_file     <- "data/species_list.txt"
clade_names_file      <- "data/geneplast_clade_names.tsv"
string_eukaryotes_rda <- "data/string_eukaryotes.rda"
geneplast_data_rdata  <- "data/gpdata_string_v11.RData"
cogdata_table_string  <- "data/COG.mappings.v11.0.txt.gz"
protein_info_gz       <- "data/protein.info.v11.0.txt.gz"

message("Loading and pre-processing external data...")

load(string_eukaryotes_rda)
load(geneplast_data_rdata) # This loads 'cogdata' and 'phyloTree'

# Process COG mapping data from STRING
cogs <- vroom(cogdata_table_string, col_select = c(1, 4))
cogs <- cogs |>
  rename(
    `taxid.string_id` = "##protein",
    og_id = orthologous_group
  )

separated_ids <- cogs %$% stri_split_fixed(taxid.string_id, pattern = ".", n = 2, simplify = TRUE)
cogs[["taxid"]]      <- separated_ids[, 1]
cogs[["protein_id"]] <- separated_ids[, 2]
rm(separated_ids)

cogs %<>%
  dplyr::select(-taxid.string_id) %>%
  filter(taxid %in% string_eukaryotes[["taxid"]]) %>%
  dplyr::select(protein_id, ssp_id = taxid, og_id) %>%
  as.data.frame()

# Prepare GenePlast cogdata and combine with STRING's
cogdata <- dplyr::select(cogdata, "protein_id", "ssp_id", "og_id" = "cog_id")
ogdata <- unique(rbind(cogdata, cogs))

# Load protein annotation data
protein_info <- vroom(protein_info_gz) %>%
  dplyr::select(protein_external_id, preferred_name)

message(paste("Starting GeneBridge analysis for species:", MANUAL_SPECIES_ID))

# Select appropriate COG reference data based on the species
cogref <- if (MANUAL_SPECIES_ID %in% c("10090", "10116", "9606")) {
  ogdata
} else {
  cogs
}

# Check if any proteins are found for the target species
species_proteins <- cogref %>% filter(ssp_id == MANUAL_SPECIES_ID)
if (nrow(species_proteins) == 0) {
  stop(paste("No proteins found for species_id:", MANUAL_SPECIES_ID, "in the cogdata dataframe."))
}

message("Initializing GeneBridge object...")
ogr <- newBridge(
  ogdata = cogref,
  phyloTree = phyloTree,
  ogids = unique(species_proteins$og_id),
  refsp = MANUAL_SPECIES_ID
)

message("Running Bridge analysis (rooting)...")
ogr <- runBridge(ogr, penalty = 2, threshold = 0.5, verbose = TRUE)

message("Running permutation test for statistical significance...")
ogr <- runPermutation(ogr, nPermutations = 1000, verbose = TRUE)

message("GeneBridge analysis completed. The 'ogr' object has been created.")

message("Fetching taxonomic lineages from NCBI Entrez...")

all_taxon_ids <- string_eukaryotes[["taxid"]]
chunk_size <- 200 # Safe number for NCBI Entrez requests
id_chunks <- split(all_taxon_ids, ceiling(seq_along(all_taxon_ids) / chunk_size))

lineages_list <- purrr::map(id_chunks, function(chunk) {
  message(paste("Fetching data for", length(chunk), "IDs..."))
  Sys.sleep(1) # Pause to respect NCBI's rate limits (max 3/sec)
  rentrez::entrez_fetch(
    db = "taxonomy",
    id = chunk,
    rettype = "xml",
    parsed = TRUE
  )
})

# Parse the XML and extract lineage strings
lineages_list_two <- purrr::map(lineages_list, ~XML::xpathSApply(.x, "//Lineage", XML::xmlValue))
lineages <- unlist(lineages_list_two)
message("Finished fetching and parsing lineages.")

message("Calculating tip groups based on the rooted tree...")

# Calculate the distance from each node to the specified species tip
top.tip <- which(ogr@tree$tip.label == MANUAL_SPECIES_ID)
tgroup <- ape::dist.nodes(ogr@tree)[, top.tip]
mrcas <- mrca(ogr@tree)[, MANUAL_SPECIES_ID]
tgroup <- tgroup[mrcas]
names(tgroup) <- names(mrcas)

# Re-index the groups sequentially
ct <- 1; tp <- tgroup
for (i in sort(unique(tgroup))) {
  tgroup[tp == i] <- ct
  ct <- ct + 1
}

# Assign the calculated group to each tip in the tree
ogr@tree$tip.group <- tgroup

message("Annotating main dataframe with root group and lineage info...")
string_eukaryotes %<>% mutate(
  root = ogr@tree$tip.group[as.character(taxid)],
  lineage_txt = lineages
)

message("Determining informative names for each root...")

root_names_one <- string_eukaryotes %>%
  # Put lineages in a long format
  mutate(lineage_split = strsplit(lineage_txt, "; ")) %>%
  unnest_longer(col = lineage_split, values_to = "clade_name", indices_to = "clade_depth") %>%
  # Count occurrences of each clade name within each root and depth
  group_by(root, clade_depth, clade_name) %>%
  tally(sort = TRUE) %>%
  # Collapse lineages by clade depths to find where they diverge
  summarise(
    diverging_rank = n_distinct(clade_name) > 1,
    clade_name = ifelse(diverging_rank, paste0(clade_name, " (", n, ")", collapse = "; "), clade_name)
  ) %>%
  # Keep only ranks up to the first point of divergence
  filter(cumsum(diverging_rank) <= 1) %>%
  # Remove taxonomically broad basal ranks (like 'Eukaryota')
  group_by(clade_depth) %>%
  arrange(root)

root_names_final <- root_names_one %>%

  # 1. Group by root, then count how many times each clade_name appears.
  count(root, clade_name, name = "name_count", sort = TRUE) %>%

  # 2. Format the string for each name to be "Name (count)".
  mutate(formatted_name = paste0(clade_name, " (", name_count, ")")) %>%

  # 3. Group again by root to collapse the formatted strings together.
  group_by(root) %>%

  # 4. Paste all the formatted strings for a root into one, separated by "; ".
  summarise(clade_name = paste(formatted_name, collapse = "; ")) %>%

  # 5. Ungroup for a clean final tibble.
  ungroup()

# Select the most informative name for each root
root_names <- root_names_one %>%
  filter(!(duplicated(clade_name) | duplicated(clade_name, fromLast = TRUE)) | diverging_rank) %>%
  # Choose the first informative name based on clade depth
  group_by(root) %>%
  summarise(clade_name = first(clade_name, order_by = clade_depth))

output_filename <- paste0("data/", MANUAL_SPECIES_ID, "_root_names.tsv")
message(paste("Saving final root names to:", output_filename))

root_names_final %>%
  vroom::vroom_write(output_filename, delim = "\t")

# Optional: You can also inspect the main results dataframe from GeneBridge
# res <- getBridge(ogr, what = "results")
# print(head(res))

message("All processes finished successfully.")