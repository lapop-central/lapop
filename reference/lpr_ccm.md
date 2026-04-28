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

# Set Survey Context on a small cross-country subset
ym23_small <- subset(ym23, pais %in% c(1, 15, 17))
ym23lpr <- lpr_data(ym23_small)

# Multiple outcomes over countries
lpr_ccm(ym23lpr,
outcome_vars = c("b12", "b18"),
rec1 = c(1, 3),
rec2 = c(5, 7))
#> # A tibble: 6 × 6
#> # Groups:   var [2]
#>   pais   prop    lb    ub proplabel var  
#>   <fct> <dbl> <dbl> <dbl> <chr>     <chr>
#> 1 AR     34.9  32.9  36.9 35%       b12  
#> 2 BR     25.1  23.4  26.9 25%       b12  
#> 3 MX     21.3  19.7  22.9 21%       b12  
#> 4 BR     51.0  48.7  53.3 51%       b18  
#> 5 AR     34.4  32.2  36.6 34%       b18  
#> 6 MX     26.7  24.8  28.5 27%       b18  

# Multiple outcomes over years
# \donttest{
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
#> 1 2023     27.8  26.3  29.3 28%       b12   0.771
#> 2 2018/19  26.4  25.0  27.8 26%       b12   0.715
#> 3 2023     38.2  36.5  39.9 38%       b18   0.872
#> 4 2018/19  36.6  34.8  38.3 37%       b18   0.900
# }
```
