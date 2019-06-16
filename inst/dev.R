# Steps used to create the package (not super thorough)

library(usethis)

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
