# LAPOP Grouped Bar Graph Pre-Processing

This function creates dataframes which can then be input in lapop_ccm
for comparing values for multiple variables across countries with a bar
graph using LAPOP formatting.

## Usage

``` r
lpr_ccm(
  data,
  outcome_vars,
  xvar = "pais_lab",
  rec1 = c(1, 1),
  rec2 = c(1, 1),
  rec3 = c(1, 1),
  ci_level = 0.95,
  mean = FALSE,
  filesave = "",
  cfmt = "",
  sort = "y",
  order = "hi-lo",
  ttest = FALSE,
  keep_nr = FALSE
)
```

## Arguments

- data:

  A survey object. The data that should be analyzed.

- outcome_vars:

  Character vector. Outcome variable(s) of interest to be plotted across
  country (or other x variable). Max of 3 (three) variables.

- xvar:

  Character string. Outcome variables are broken down by this variable.
  You can set xvar to "wave" or "year" for cross-time comparisons.
  Default: pais_lab.

- rec1, rec2, rec3:

  Numeric. The minimum and maximum values of the outcome variable that
  should be included in the numerator of the percentage. For example, if
  the variable is on a 1-7 scale and rec1 is c(5, 7), the function will
  show the percentage who chose an answer of 5, 6, 7 out of all valid
  answers. Can also supply one value only, to produce the percentage
  that chose that value out of all other values. Default: c(1, 1).

- ci_level:

  Numeric. Confidence interval level for estimates. Default: 0.95

- mean:

  Logical. If TRUE, will produce the mean of the variable rather than
  rescaling to percentage. Default: FALSE.

- filesave:

  Character. Path and file name to save the dataframe as csv.

- cfmt:

  Character. Changes the format of the numbers displayed above the bars.
  Uses sprintf string formatting syntax. Default is whole numbers for
  percentages and tenths place for means.

- sort:

  Character. On what value the bars are sorted. Options are "y"
  (default; for the value of the first outcome variable), "xv" (for the
  underlying values of the x variable), "xl" (for the labels of the x
  variable, i.e., alphabetical).

- order:

  Character. How the bars should be sorted. Options are "hi-lo"
  (default) or "lo-hi".

- ttest:

  Logical. If TRUE, will conduct pairwise t-tests for difference of
  means between all outcomes vs. all x-vars and save them in attr(x,
  "t_test_results"). Default: FALSE.

- keep_nr:

  Logical. If TRUE, will convert "don't know" (missing code .a) and "no
  response" (missing code .b) into valid data (value = 99) and use them
  in the denominator when calculating percentages. The default is to
  examine valid responses only. Default: FALSE.

## Value

Returns a data frame, with data formatted for visualization by
lapop_ccm()

## Author

Luke Plutowski, <luke.plutowski@vanderbilt.edu> & Robert Vidigal,
<robert.vidigal@vanderbilt.edu>

## Examples

``` r
require(lapop); data(ym23)

# Set Survey Context
ym23lpr <- lpr_data(ym23)

# Multiple outcomes over countries
lpr_ccm(ym23lpr,
outcome_vars = c("b12", "b18"),
rec1 = c(1, 3),
rec2 = c(5, 7),
ttest = TRUE)
#> # A tibble: 41 × 7
#> # Groups:   var [2]
#>    pais   prop    lb    ub proplabel var      se
#>    <fct> <dbl> <dbl> <dbl> <chr>     <chr> <dbl>
#>  1 TT     44.5  42.4  46.7 45%       b12   1.12 
#>  2 NI     43.3  41.0  45.5 43%       b12   1.15 
#>  3 BO     37.7  35.6  39.7 38%       b12   1.05 
#>  4 DO     37.0  35.1  38.9 37%       b12   0.950
#>  5 HN     36.2  34.1  38.3 36%       b12   1.05 
#>  6 AR     34.9  32.9  36.9 35%       b12   1.03 
#>  7 UY     34.3  32.4  36.3 34%       b12   1.01 
#>  8 SR     33.6  31.2  35.9 34%       b12   1.19 
#>  9 PY     31.0  29.4  32.6 31%       b12   0.826
#> 10 CO     30.5  28.7  32.3 31%       b12   0.931
#> # ℹ 31 more rows

# Multiple outcomes over years
lpr_ccm(ym23lpr,
outcome_vars = c("b12", "b18"),
xvar = "wave",
rec1 = c(1, 3),
rec2 = c(5, 7),
ttest = TRUE)
#> # A tibble: 4 × 7
#> # Groups:   var [2]
#>   pais     prop    lb    ub proplabel var      se
#>   <fct>   <dbl> <dbl> <dbl> <chr>     <chr> <dbl>
#> 1 2023     31.1  30.5  31.7 31%       b12   0.310
#> 2 2018/19  29.7  29.1  30.4 30%       b12   0.322
#> 3 2018/19  38.4  37.7  39.0 38%       b18   0.338
#> 4 2023     38.2  37.6  38.7 38%       b18   0.289
```
