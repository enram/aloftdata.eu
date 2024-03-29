library(jsonlite)
library(dplyr)

# Read source JSON files from OPERA
radars_main <- jsonlite::read_json(
  "http://eumetnet.eu/wp-content/themes/aeron-child/observations-programme/current-activities/opera/database/OPERA_Database/OPERA_RADARS_DB.json",
  simplifyDataFrame = TRUE
)
radars_archive <- jsonlite::read_json(
  "http://eumetnet.eu/wp-content/themes/aeron-child/observations-programme/current-activities/opera/database/OPERA_Database/OPERA_RADARS_ARH_DB.json",
  simplifyDataFrame = TRUE
)

# Add source column
radars_main <- dplyr::mutate(radars_main, source = "main")
radars_archive <- dplyr::mutate(radars_archive, source = "archive")

# Combine and sort data
radars <-
  radars_main %>%
  dplyr::bind_rows(radars_archive) %>%
  # Set all "" to NA
  dplyr::mutate(across(where(is.character), ~ if_else(.x == "", NA_character_, .x))) %>%
  # Remove erroneous records that have no country assigned
  dplyr::filter(!is.na(country)) %>%
  # Move source column to end
  dplyr::relocate(source, .after = last_col()) %>%
  # Sort data for consistent git diffs
  dplyr::arrange(country, number, startyear)

# Write
radars_json <- jsonlite::toJSON(radars, pretty = TRUE, auto_unbox = TRUE)
write(radars_json, "OPERA_RADARS_DB.json")
