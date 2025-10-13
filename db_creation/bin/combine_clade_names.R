library(dplyr)
library(readr)
library(purrr)

input_directory <- "./data/"

output_file <- file.path(input_directory, "combined_roots.tsv")
# --------------------------------------------------------------------------

file_paths <- list.files(
  path = input_directory,
  pattern = "_root_names\\.tsv$",
  full.names = TRUE
)


combined_data <- map_dfr(file_paths, function(path) {

  filename <- basename(path)

  species_id <- sub("_root_names\\.tsv$", "", filename)

  read_tsv(path, col_types = cols()) %>%

    mutate(species_id = species_id) %>%

    select(species_id, root, clade_name)
})

write_tsv(combined_data, output_file)

