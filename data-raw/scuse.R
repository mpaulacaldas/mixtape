library(haven)
library(purrr)
library(pdftools)
library(stringr)
library(usethis)

# Get everything from scuse.ado -------------------------------------------

scuse_txt <- pdf_text("inst/scuse_files.pdf")

files_raw <- scuse_txt %>%
  paste0(collapse = "\n") %>%
  str_extract_all("scuse .*\n", simplify = TRUE) %>%
  str_replace("scuse (.*)\n", "\\1")

files_with_ending <- ifelse(
  str_detect(files_raw, "\\.(dta|zip)"),
  files_raw,
  paste0(files_raw, ".dta")
)

download_scuse <- function(file) {

  from <- paste0("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/", file)
  to <- paste0("data-raw/", file)

  try(download.file(url = from, destfile = to))
}

# Message shows that card91.zip could not be downloaded
walk(files_with_ending, download_scuse)

# Transform to rds --------------------------------------------------------

dta_paths <- dir("data-raw", pattern = "dta$", recursive = TRUE, full.names = TRUE)
names_obj <- str_replace(dta_paths, "data-raw/(.*)\\.dta", "\\1")

obj <- dta_paths %>%
  map(read_dta) %>%
  setNames(names_obj)

# Save to data/ -----------------------------------------------------------

use_directory("data")

list2env(obj, globalenv())

names_obj %>%
  walk(~ save(list = .x, file = paste0("data/", .x, ".rda")))
