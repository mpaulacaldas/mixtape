library(haven)

texas <- read_dta("http://scunning.com/texas.dta")

usethis::use_data(texas)
