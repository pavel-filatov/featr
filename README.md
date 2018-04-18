`featr` package
================

`featr` stands for “feature” (oh, really?) and pronounced the same way.
There is a bunch of functions to produce not-so-common tasks such as
renaming variables in the data frame or list of data frames,
one-hot-encoding with custom parameters etc. Please see
[Examples](#examples) section

## Installation

To install `featr` please use `devtools`:

``` r
devtools::install_github("pavel-filatov/featr")
```

Please note: you may need to install development version of `rlang`
package **before** the installation of
`featr`:

``` r
devtools::install_github("r-lib/rlang")
```

## Examples

### `cor_index()` makes a correlation index: it gets each pair of variables and calculate

correlation between them and turn it all to data frame. Then the
function arrange data frame by absolute value of correlation.

``` r
featr::cor_index(mtcars)
```

    ## # A tibble: 55 x 3
    ##    Var1  Var2     Cor
    ##    <chr> <chr>  <dbl>
    ##  1 cyl   disp   0.902
    ##  2 disp  wt     0.888
    ##  3 mpg   wt    -0.868
    ##  4 mpg   cyl   -0.852
    ##  5 mpg   disp  -0.848
    ##  6 cyl   hp     0.832
    ##  7 cyl   vs    -0.811
    ##  8 am    gear   0.794
    ##  9 disp  hp     0.791
    ## 10 cyl   wt     0.782
    ## # ... with 45 more rows
