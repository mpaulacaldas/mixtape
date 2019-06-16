library(haven)

txdd <- read_dta("http://scunning.com/txdd.dta")

usethis::use_data(txdd)
