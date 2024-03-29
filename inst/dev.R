# Steps used to create the package (not super thorough)

library(usethis)
library(purrr)
library(pdftools)
library(stringr)
library(tibble)
library(tidyr)
library(dplyr)

# Download pdfs and do files ----------------------------------------------

use_directory("inst")

download.file("http://scunning.com/scuse_files.pdf", "inst/scuse_files.pdf")
download.file("http://scunning.com/scuse.ado", "inst/scuse.ado")

use_directory("inst/synthetic-control")

download.file("http://scunning.com/readme-2.pdf", "inst/synthetic-control/readme.pdf")
download.file("http://scunning.com/texas_synth.do", "inst/synthetic-control/texas_synth.do")

use_directory("inst/permutation-tests")

download.file("http://scunning.com/readme_permute.pdf", "inst/permutation-tests/readme.pdf")
download.file("http://scunning.com/permute.do", "inst/permutation-tests/permute.do")

# Create cleaning scripts -------------------------------------------------

use_data_raw("texas")
use_data_raw("txdd")
use_data_raw("scuse")

# Set-up documentation ----------------------------------------------------

use_readme_rmd()

# Document data sets
use_roxygen_md()

txt <- paste0(pdf_text("inst/scuse_files.pdf"), collapse = "\n")

titles <- txt %>%
  str_remove_all("scuse .*\n") %>%
  str_remove_all("http.*\n") %>%
  str_split("\\d\\. .*\n") %>%
  map(str_replace_all, "\n", " ") %>%
  map(str_squish) %>%
  pluck(1) %>%
  str_subset("") %>%
  str_remove_all(".*\\.pdf ")

files <- txt %>%
  str_remove_all("scuse .*\n") %>%
  str_remove_all("http.*\n") %>%
  str_extract_all("\\d\\. .*\n") %>%
  pluck(1) %>%
  str_replace("\\d\\. (.*)\\.dta\n", "\\1") %>%
  str_remove_all("\\.dta")

content <- tibble(path = files, lines = titles) %>%
  separate_rows(path, sep = ", ") %>%
  mutate(lines = paste0("#' ", lines, "\n#'\n", '"', path,'"\n')) %>%
  pull(lines) %>%
  paste0(collapse = "\n\n") %>%
  str_split("\n") %>%
  pluck(1)

use_r("data")
write_over("R/data.R", content)

# Tibble ------------------------------------------------------------------

use_tibble()
use_r("mixtape-package.R")
