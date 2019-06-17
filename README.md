
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mixtape

<!-- badges: start -->

<!-- badges: end -->

This package contains the data sets for [“Causal Inference: The
Mixtape”](http://scunning.com/mixtape.html).

## Installation

You can install the latest version of mixtape with:

``` r
# install.packages("remotes")
remotes::install_github("mpaulacaldas/mixtape")
```

## Usage

To see a list of the data sets included in this package, type:

``` r
data(package = "mixtape")
```

After you have loaded the package, you can use a data set by calling it
by its name:

``` r
library(mixtape)

head(acemogluetal)
#>       countryn shortnam africa  latitude euro     prot     lgdp  logmort
#> 1       Angola      AGO      1 0.1366667    0 5.363636 7.770645 5.634789
#> 2    Argentina      ARG      0 0.3777778   90 6.386364 9.133459 4.262680
#> 3    Australia      AUS      0 0.3000000   99 9.318182 9.897972 2.145931
#> 4 Burkina Faso      BFA      1 0.1444445    0 4.454545 6.845880 5.634789
#> 5   Bangladesh      BGD      0 0.2666667    0 5.136364 6.877296 4.268438
#> 6      Bahamas      BHS      0 0.2683333   10 7.500000 9.285448 4.442651
```
