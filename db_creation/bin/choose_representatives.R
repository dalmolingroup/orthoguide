#!/usr/bin/env Rscript

library(dplyr)
library(tidyr)
library(readr)
library(stringr)

load("data/string_eukaryotes.rda")

# Load orthology scores
orthology_scores <- read_tsv(
  "data/COG.mappings.v11.0.txt.gz",
  col_names = c("protein", "start", "end", "og", "annotation"),
  col_types = cols(.default = "c")
) %>%
  filter(!is.na(protein)) %>%
  mutate(taxon_id = str_extract(protein, "^[0-9]+")) %>%
  filter(!is.na(taxon_id)) %>%
  count(taxon_id, name = "orthology_score")

priority_ids <- read_lines("data/species_list.txt") %>% as.integer()

# Prepare priority species data
priority_species <- string_eukaryotes %>%
  filter(taxid %in% priority_ids) %>%
  separate(ncbi_name, into = c("genus", "species"), sep = " ", extra = "merge", remove = FALSE)

# Select representatives for other genera
representatives <- string_eukaryotes %>%
  filter(!taxid %in% priority_ids) %>%
  separate(ncbi_name, into = c("genus", "species"), sep = " ", extra = "merge", remove = FALSE) %>%
  left_join(orthology_scores, by = c("taxid" = "taxon_id")) %>%
  replace_na(list(orthology_score = 0)) %>%
  filter(!genus %in% priority_species$genus) %>%
  group_by(genus) %>%
  arrange(desc(orthology_score), species) %>%
  slice(1) %>%
  ungroup()

# Combine and save
bind_rows(priority_species, representatives) %>%
  select(taxid) %>%
  write_tsv("data/final_species_list.txt", col_names = F)
