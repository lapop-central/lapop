# LAPOP Multi-Line Time Series Graph Pre-Processing

This function creates a dataframe which can then be input in lapop_mline
for to show a time series plot with multiple lines. If one "outcome"
variable and an \`xvar\` variable is supplied, the function produces the
values of a single outcome variable, broken down by a secondary
variable, across time. If multiple outcome variables (up to four) are
supplied, it will show means/percentages of those variables across time
(essentially, it allows you to do lpr_ts for multiple variables).

## Usage

``` r
lpr_mline(
  data,
  outcome,
  rec = c(1, 1),
  rec2 = c(1, 1),
  rec3 = c(1, 1),
  rec4 = c(1, 1),
  xvar,
  use_wave = FALSE,
  use_cat = FALSE,
  ci_level = 0.95,
  mean = FALSE,
  filesave = "",
  cfmt = "",
  ttest = FALSE,
  keep_nr = FALSE
)
```

## Arguments

- data:

  A survey object. The data that should be analyzed.

- outcome:

  Character vector. Outcome variable(s) of interest to be plotted across
  time. If only one value is provided, the graph will show the outcome
  variable, over time, broken down by a secondary variable (x-var). If
  more than one value is supplied, the graph will show each outcome
  variable across time (no secondary variable).

- rec, rec2, rec3, rec4:

  Numeric. The minimum and maximum values of the outcome variable that
  should be included in the numerator of the percentage. For example, if
  the variable is on a 1-7 scale and rec is c(5, 7), the function will
  show the percentage who chose an answer of 5, 6, 7 out of all valid
  answers. Can also supply one value only, to produce the percentage
  that chose that value out of all other values. Default: c(1, 1).

- xvar:

  Character. Variable on which to break down the outcome variable. In
  other words, the line graph will produce multiple lines for each value
  of xvar (technically, it is the z-variable, not the x variable, which
  is year/wave). Ignored if multiple outcome variables are supplied.

- use_wave:

  Logical. If TRUE, will use "wave" for the x-axis; otherwise, will use
  "year". Default: FALSE.

- use_cat:

  Logical. If TRUE, will show the percentages of category values of a
  single variable; otherwise will show percentages of the range of
  values from rec(). Default FALSE.

- ci_level:

  Numeric. Confidence interval level for estimates. Default: 0.95

- mean:

  Logical. If TRUE, will produce the mean of the variable rather than
  rescaling to percentage. Default: FALSE.

- filesave:

  Character. Path and file name to save the dataframe as csv.

- cfmt:

  Character. changes the format of the numbers displayed above the bars.
  Uses sprintf string formatting syntax. Default is whole numbers for
  percentages and tenths place for means.

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

Returns a data frame, with data formatted for visualization by
lapop_mline

## Author

Luke Plutowski, <luke.plutowski@vanderbilt.edu> & Robert Vidigal,
<robert.vidigal@vanderbilt.edu>

## Examples

``` r
# \donttest{
require(lapop); data(ym23)

# Set Survey Context
ym23lpr <- lpr_data(ym23)

# Single Variable by Country and Year
lpr_mline(ym23lpr,
outcome = "ing4",
rec = c(5, 7),
xvar = "pais",
use_wave = TRUE)
#> # A tibble: 41 × 6
#> # Groups:   varlabel [23]
#>    varlabel    wave     prop    lb    ub proplabel
#>    <fct>       <chr>   <dbl> <dbl> <dbl> <chr>    
#>  1 México      2018/19  62.7  60.3  65.2 63%      
#>  2 México      2023     61.8  59.4  64.1 62%      
#>  3 Guatemala   2018/19  48.9  46.2  51.5 49%      
#>  4 Guatemala   2023     47.6  44.7  50.5 48%      
#>  5 El Salvador 2018/19  58.6  56.1  61.1 59%      
#>  6 El Salvador 2023     67.2  64.6  69.8 67%      
#>  7 Honduras    2018/19  45.0  42.7  47.4 45%      
#>  8 Honduras    2023     48.5  46.2  50.9 49%      
#>  9 Nicaragua   2018/19  51.5  48.8  54.3 52%      
#> 10 Nicaragua   2023     57.1  54.9  59.2 57%      
#> # ℹ 31 more rows

# Multiple Variables
lpr_mline(ym23lpr,
outcome = c("b12", "b18"),
rec = c(5, 7),
rec2 = c(1, 2),
rec3 = c(5, 7),
use_wave = TRUE)
#>      wave                         varlabel     prop       lb       ub proplabel
#> 1 2018/19 Confianza en la policía nacional 29.95807 29.33650 30.57963       30%
#> 2    2021 Confianza en la policía nacional       NA       NA       NA      <NA>
#> 3    2023 Confianza en la policía nacional 31.61360 31.05338 32.17383       32%
#> 4 2018/19 Confianza en las fuerzas armadas 55.31597 54.62786 56.00408       55%
#> 5    2021 Confianza en las fuerzas armadas       NA       NA       NA      <NA>
#> 6    2023 Confianza en las fuerzas armadas 53.72345 53.04600 54.40089       54%

# Binary Single Variable by Category
lpr_mline(ym23lpr,
outcome = "pn4",
use_cat = TRUE,
use_wave = TRUE)
#>       wave category      prop        lb        ub proplabel            varlabel
#> 1  2018/19        1  6.420406  6.116673  6.724139        6%   Muy satisfecho(a)
#> 2     2021        1        NA        NA        NA      <NA>   Muy satisfecho(a)
#> 3     2023        1  5.803635  5.534485  6.072786        6%   Muy satisfecho(a)
#> 4  2018/19        2 33.038521 32.425446 33.651595       33%       Satisfecho(a)
#> 5     2021        2        NA        NA        NA      <NA>       Satisfecho(a)
#> 6     2023        2 34.084235 33.526635 34.641835       34%       Satisfecho(a)
#> 7  2018/19        3 46.252173 45.592718 46.911628       46%     Insatisfecho(a)
#> 8     2021        3        NA        NA        NA      <NA>     Insatisfecho(a)
#> 9     2023        3 44.970893 44.404458 45.537327       45%     Insatisfecho(a)
#> 10 2018/19        4 14.288900 13.833773 14.744027       14% Muy insatisfecho(a)
#> 11    2021        4        NA        NA        NA      <NA> Muy insatisfecho(a)
#> 12    2023        4 15.141237 14.710237 15.572237       15% Muy insatisfecho(a)

# Recode Categorical Variable (max 4-categories)
lpr_mline(ym23lpr,
outcome = "ing4",
rec = c(5, 7),
use_cat = TRUE,
use_wave = TRUE)
#>      wave category     prop       lb       ub proplabel       varlabel
#> 1 2018/19        5 22.03577 21.50632 22.56523       22%              5
#> 2    2021        5       NA       NA       NA      <NA>              5
#> 3    2023        5 20.66152 20.21572 21.10732       21%              5
#> 4 2018/19        6 14.76881 14.34927 15.18835       15%              6
#> 5    2021        6       NA       NA       NA      <NA>              6
#> 6    2023        6 14.74627 14.37051 15.12203       15%              6
#> 7 2018/19        7 20.90733 20.39790 21.41677       21% Muy de acuerdo
#> 8    2021        7       NA       NA       NA      <NA> Muy de acuerdo
#> 9    2023        7 23.11706 22.61955 23.61456       23% Muy de acuerdo
# }
```
