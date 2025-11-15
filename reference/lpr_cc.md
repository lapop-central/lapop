# LAPOP Cross-Country Bar Graph Pre-Processing

This function creates dataframes which can then be input in lapop_cc for
comparing values across countries with a bar graph using LAPOP
formatting.

## Usage

``` r
lpr_cc(
  data,
  outcome,
  xvar = "pais_lab",
  rec = list(c(1, 1)),
  rec2 = list(c(1, 1)),
  rec3 = list(c(1, 1)),
  rec4 = list(c(1, 1)),
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

- outcome:

  Outcome variable(s) of interest to be plotted across countries. It can
  handle a single variable across countries, or multiple variables
  instead of multiple countries. See examples below.

- xvar:

  Grouping variable. Default: pais_lab. It can handle other variables
  grouping like year/wave.

- rec:

  Numeric. The minimum and maximum values of the outcome variable that
  should be included in the numerator of the percentage. For example, if
  the variable is on a 1-7 scale and rec is c(5, 7), the function will
  show the percentage who chose an answer of 5, 6, 7 out of all valid
  answers. Default: c(1, 1).

- rec2:

  Numeric. Same as rec(). Default: c(1, 1).

- rec3:

  Numeric. Same as rec(). Default: c(1, 1).

- rec4:

  Numeric. Same as rec(). Default: c(1, 1).

- ci_level:

  Numeric. Confidence interval level for estimates. Default: 0.95

- mean:

  Logical. If TRUE, will produce the mean of the variable rather than
  rescaling to percentage. Default: FALSE.

- filesave:

  Character. Path and file name to save the dataframe as csv.

- cfmt:

  changes the format of the numbers displayed above the bars. Uses
  sprintf string formatting syntax. Default is whole numbers for
  percentages and tenths place for means.

- sort:

  Character. On what value the bars are sorted: the x or the y. Options
  are "y" (default; for the value of the outcome variable), "xv" (for
  the underlying values of the x variable), "xl" (for the labels of the
  x variable, i.e., alphabetical).

- order:

  Character. How the bars should be sorted. Options are "hi-lo"
  (default) or "lo-hi".

- ttest:

  Logical. If TRUE, will conduct pairwise t-tests for difference of
  means between all individual x levels and save them in attr(x,
  "t_test_results"). Default: FALSE.

- keep_nr:

  Logical. If TRUE, will convert "don't know" (missing code .a) and "no
  response" (missing code .b) into valid data (value = 99) and use them
  in the denominator when calculating percentages. The default is to
  examine valid responses only. Default: FALSE.

## Value

Returns a data frame, with data formatted for visualization by lapop_cc

## Author

Luke Plutowski, <luke.plutowski@vanderbilt.edu> & Robert Vidigal,
<robert.vidigal@vanderbilt.edu>

## Examples

``` r
require(lapop); data(ym23); data(bra23)

# Set Survey Context
bra23lpr <- lpr_data(bra23, wt = TRUE)
ym23lpr <- lpr_data(ym23)

# Multiple variables in Single Country
lpr_cc(data = bra23lpr,
outcome = c("b12", "b13"),
rec = c(5, 7))
#> # A tibble: 2 × 5
#>   vallabel  prop proplabel    lb    ub
#>   <chr>    <dbl> <chr>     <dbl> <dbl>
#> 1 b12       57.4 57%        54.6  60.2
#> 2 b13       35.3 35%        32.2  38.3

# Single variable in Multiple Countries
lpr_cc(data = ym23lpr,
      outcome = "ing4",
      rec = c(5, 7),
      xvar = "pais")
#> # A tibble: 23 × 5
#>    vallabel              prop proplabel    lb    ub
#>    <fct>                <dbl> <chr>     <dbl> <dbl>
#>  1 Uruguay               75.8 76%        73.8  77.9
#>  2 Costa Rica            72.2 72%        70.3  74.1
#>  3 Argentina             69.4 69%        67.5  71.4
#>  4 Chile                 66.7 67%        64.9  68.6
#>  5 Bahamas               64.9 65%        62.3  67.5
#>  6 El Salvador           62.9 63%        61.1  64.7
#>  7 México                62.2 62%        60.5  63.9
#>  8 Brasil                61.9 62%        59.8  64.0
#>  9 República Dominicana  61.5 62%        59.9  63.1
#> 10 Grenada               58.7 59%        56.1  61.3
#> # ℹ 13 more rows
```
