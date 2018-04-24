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
package:

``` r
devtools::install_github("r-lib/rlang")
```

## Examples

#### `cor_index()`

`cor_index()` fucntion makes a correlation index: it gets each pair of
variables, calculate correlation between them, and turn it all to data
frame. Then the function sort data frame by absolute value of
correlation.

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

#### `identity_index()`

For each pair of variables in input data frame `identity_index()`
calculates three numbers:

  - **`identical`** - number of observations where first and second
    variables are equal;
  - **`non_identical`** - number of observations where first and second
    variables aren’t equal;
  - **`other`** all the other cases (e.g. when one of the entries is
    `NA`).

**`identitity_index`** is computed as ratio
\[identity\ index = \frac{identical}{identical + non\_identical}\]

That’s how the fuction works:

``` r
set.seed(42)
df <- tibble(letter1 = sample(c(letters[1:3], NA, NaN), 100, TRUE),
             letter2 = sample(c(letters[1:3], NA), 100, TRUE),
             letter3 = sample(c(letters[1:3], NA), 100, TRUE),
             num1 = sample(1:4, 100, TRUE),
             num2 = sample(1:4, 100, TRUE),
             num3 = sample(c(1:3, NA), 100, TRUE))

identity_index(df)
```

    ## # A tibble: 15 x 6
    ##    Var1    Var2    identical non_identical other identity_index
    ##    <chr>   <chr>       <int>         <int> <int>          <dbl>
    ##  1 letter1 letter3        22            40    38          0.355
    ##  2 letter2 letter3        17            39    44          0.304
    ##  3 letter1 letter2        15            43    42          0.259
    ##  4 num1    num2           23            77     0          0.230
    ##  5 num2    num3           17            58    25          0.227
    ##  6 num1    num3           11            64    25          0.147
    ##  7 letter1 num1            0            77    23          0.   
    ##  8 letter1 num2            0            77    23          0.   
    ##  9 letter1 num3            0            57    43          0.   
    ## 10 letter2 num1            0            74    26          0.   
    ## 11 letter2 num2            0            74    26          0.   
    ## 12 letter2 num3            0            59    41          0.   
    ## 13 letter3 num1            0            79    21          0.   
    ## 14 letter3 num2            0            79    21          0.   
    ## 15 letter3 num3            0            55    45          0.

You see that variables `letter1` and `letter3` have 22 equal, 40
different observations and 38 cases where at least on of them has `NA`.

`.na_include` flag lets you consider as identical cases where `var1 ==
NA` and `var2 == NA`. The same way if `var1 == NA` and `var2 != NA` it
will count this case as `non_identical`.

``` r
identity_index(df, .na_include = TRUE)
```

    ## # A tibble: 15 x 6
    ##    Var1    Var2    identical non_identical other identity_index
    ##    <chr>   <chr>       <int>         <int> <int>          <dbl>
    ##  1 letter1 letter3        28            72     0         0.280 
    ##  2 num1    num2           23            77     0         0.230 
    ##  3 letter1 letter2        22            78     0         0.220 
    ##  4 letter2 letter3        20            80     0         0.200 
    ##  5 num2    num3           17            83     0         0.170 
    ##  6 num1    num3           11            89     0         0.110 
    ##  7 letter2 num3           10            90     0         0.100 
    ##  8 letter1 num3            5            95     0         0.0500
    ##  9 letter3 num3            1            99     0         0.0100
    ## 10 letter1 num1            0           100     0         0.    
    ## 11 letter1 num2            0           100     0         0.    
    ## 12 letter2 num1            0           100     0         0.    
    ## 13 letter2 num2            0           100     0         0.    
    ## 14 letter3 num1            0           100     0         0.    
    ## 15 letter3 num2            0           100     0         0.

Now `letter1` and `letter3` have 6 more identical cases.

#### `make_shift()`

`make_shift()` is great option when you need to make a lot of lags (move
down) and leads (move up) for one or more variables. This function
captures variables to apply shifting and vector of window sizes and
returns a list of quoted expressions:

``` r
make_shift(mpg, qsec, .n = -2:2)
```

    ## $mpg_lead2
    ## dplyr::lead(mpg, 2L)
    ## 
    ## $mpg_lead1
    ## dplyr::lead(mpg, 1L)
    ## 
    ## $mpg_lag1
    ## dplyr::lag(mpg, 1L)
    ## 
    ## $mpg_lag2
    ## dplyr::lag(mpg, 2L)
    ## 
    ## $qsec_lead2
    ## dplyr::lead(qsec, 2L)
    ## 
    ## $qsec_lead1
    ## dplyr::lead(qsec, 1L)
    ## 
    ## $qsec_lag1
    ## dplyr::lag(qsec, 1L)
    ## 
    ## $qsec_lag2
    ## dplyr::lag(qsec, 2L)

To make new variables you simply need to unqoute the function output
inside the `dplyr::mutate()` call **using `!!!`** (bang-bang-bang)
opearator:

``` r
select(mtcars, mpg, qsec) %>% 
  mutate(!!!make_shift(mpg, qsec, .n = -1:2))
```

    ##     mpg  qsec mpg_lead1 mpg_lag1 mpg_lag2 qsec_lead1 qsec_lag1 qsec_lag2
    ## 1  21.0 16.46      21.0       NA       NA      17.02        NA        NA
    ## 2  21.0 17.02      22.8     21.0       NA      18.61     16.46        NA
    ## 3  22.8 18.61      21.4     21.0     21.0      19.44     17.02     16.46
    ## 4  21.4 19.44      18.7     22.8     21.0      17.02     18.61     17.02
    ## 5  18.7 17.02      18.1     21.4     22.8      20.22     19.44     18.61
    ## 6  18.1 20.22      14.3     18.7     21.4      15.84     17.02     19.44
    ## 7  14.3 15.84      24.4     18.1     18.7      20.00     20.22     17.02
    ## 8  24.4 20.00      22.8     14.3     18.1      22.90     15.84     20.22
    ## 9  22.8 22.90      19.2     24.4     14.3      18.30     20.00     15.84
    ## 10 19.2 18.30      17.8     22.8     24.4      18.90     22.90     20.00
    ## 11 17.8 18.90      16.4     19.2     22.8      17.40     18.30     22.90
    ## 12 16.4 17.40      17.3     17.8     19.2      17.60     18.90     18.30
    ## 13 17.3 17.60      15.2     16.4     17.8      18.00     17.40     18.90
    ## 14 15.2 18.00      10.4     17.3     16.4      17.98     17.60     17.40
    ## 15 10.4 17.98      10.4     15.2     17.3      17.82     18.00     17.60
    ## 16 10.4 17.82      14.7     10.4     15.2      17.42     17.98     18.00
    ## 17 14.7 17.42      32.4     10.4     10.4      19.47     17.82     17.98
    ## 18 32.4 19.47      30.4     14.7     10.4      18.52     17.42     17.82
    ## 19 30.4 18.52      33.9     32.4     14.7      19.90     19.47     17.42
    ## 20 33.9 19.90      21.5     30.4     32.4      20.01     18.52     19.47
    ## 21 21.5 20.01      15.5     33.9     30.4      16.87     19.90     18.52
    ## 22 15.5 16.87      15.2     21.5     33.9      17.30     20.01     19.90
    ## 23 15.2 17.30      13.3     15.5     21.5      15.41     16.87     20.01
    ## 24 13.3 15.41      19.2     15.2     15.5      17.05     17.30     16.87
    ## 25 19.2 17.05      27.3     13.3     15.2      18.90     15.41     17.30
    ## 26 27.3 18.90      26.0     19.2     13.3      16.70     17.05     15.41
    ## 27 26.0 16.70      30.4     27.3     19.2      16.90     18.90     17.05
    ## 28 30.4 16.90      15.8     26.0     27.3      14.50     16.70     18.90
    ## 29 15.8 14.50      19.7     30.4     26.0      15.50     16.90     16.70
    ## 30 19.7 15.50      15.0     15.8     30.4      14.60     14.50     16.90
    ## 31 15.0 14.60      21.4     19.7     15.8      18.60     15.50     14.50
    ## 32 21.4 18.60        NA     15.0     19.7         NA     14.60     15.50
