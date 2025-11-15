# LAPOP "Multiple-Over" Breakdown Graphs

This function creates a dataframe which can then be input in
lapop_mover() for comparing means across values of secondary variable(s)
using LAPOP formatting.

## Usage

``` r
lpr_mover(
  data,
  outcome,
  grouping_vars,
  rec = list(c(1, 1)),
  rec2 = c(1, 1),
  rec3 = c(1, 1),
  rec4 = c(1, 1),
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

  Character. Outcome variable(s) of interest to be plotted across
  secondary variable(s).

- grouping_vars:

  A character vector specifying one or more grouping variables. For each
  variable, the function calculates the average of the outcome variable,
  broken down by the distinct values within the grouping variable(s).

- rec:

  Numeric. The minimum and maximum values of the frst outcome variable
  that should be included in the numerator of the percentage. For
  example, if the variable is on a 1-7 scale and rec is c(5, 7), the
  function will show the percentage who chose an answer of 5, 6, 7 out
  of all valid answers. Can also supply one value only, to produce the
  percentage that chose that value out of all other values. Default:
  c(1, 1).

- rec2:

  Numeric. Similar to 'rec' for the second outcome. Default: c(1, 1).

- rec3:

  Numeric. Similar to 'rec' for the third outcome. Default: c(1, 1).

- rec4:

  Numeric. Similar to 'rec' for the fourth outcome. Default: c(1, 1).

- ci_level:

  Numeric. Confidence interval level for estimates. Default: 0.95

- mean:

  Logical. If TRUE, will produce the mean of the variable rather than
  recoding to percentage. Default: FALSE.

- filesave:

  Character. Path and file name to save the dataframe as csv.

- cfmt:

  Changes the format of the numbers displayed above the bars. Uses
  sprintf string formatting syntax. Default is whole numbers for
  percentages and tenths place for means.

- ttest:

  Logical. If TRUE, will conduct pairwise t-tests for difference of
  means between all individual year-xvar levels and save them in attr(x,
  "t_test_results"). Default: FALSE.

- keep_nr:

  Logical. If TRUE, will convert "don't know" (missing code .a) and "no
  response" (missing code .b) into valid data (value = 99) and use them
  in the denominator when calculating percentages. The default is to
  examine valid responses only. Default: FALSE.

## Value

Returns a data frame, with data formatted for visualization by
lapop_mover

## Author

Luke Plutowski, <luke.plutowski@vanderbilt.edu> && Robert Vidigal,
<robert.vidigal@vanderbilt.edu>

## Examples

``` r
# \donttest{
require(lapop); data(ym23)

# Set SUrvey Context
ym23lpr<-lpr_data(ym23)

# Single DV
lpr_mover(data = ym23lpr,
 outcome = "ing4",
 grouping_vars = c("q1tc_r", "edre"),
 rec = c(5, 7), ttest = FALSE)
#> # A tibble: 10 × 7
#>    outcome               varlabel           vallabel  prop proplabel    lb    ub
#>    <chr>                 <chr>              <chr>    <dbl> <chr>     <dbl> <dbl>
#>  1 Apoyo a la democracia Género             Hombre/…  59.3 59%        58.6  60.1
#>  2 Apoyo a la democracia Género             Mujer/f…  58.0 58%        57.2  58.7
#>  3 Apoyo a la democracia Género             No se i…  55.4 55%        40.6  70.2
#>  4 Apoyo a la democracia Nivel de educación Ninguna   55.1 55%        51.6  58.7
#>  5 Apoyo a la democracia Nivel de educación Primari…  54.5 55%        52.7  56.4
#>  6 Apoyo a la democracia Nivel de educación Primari…  56.9 57%        55.4  58.4
#>  7 Apoyo a la democracia Nivel de educación Secunda…  56.2 56%        54.9  57.6
#>  8 Apoyo a la democracia Nivel de educación Secunda…  56.6 57%        55.7  57.6
#>  9 Apoyo a la democracia Nivel de educación Terciar…  63.3 63%        61.7  64.9
#> 10 Apoyo a la democracia Nivel de educación Terciar…  66.3 66%        65.0  67.6

# Multiple DV
lpr_mover(data = ym23lpr,
outcome = c("ing4", "pn4"),
grouping_vars = c("q1tc_r", "edre"),
rec = c(5, 7), rec2 = c(1, 2),
ttest = FALSE)
#> # A tibble: 20 × 7
#>    outcome                         varlabel vallabel  prop proplabel    lb    ub
#>    <chr>                           <chr>    <chr>    <dbl> <chr>     <dbl> <dbl>
#>  1 Apoyo a la democracia           q1tc_r … Hombre/…  59.3 59%        58.6  60.1
#>  2 Apoyo a la democracia           q1tc_r … Mujer/f…  58.0 58%        57.2  58.7
#>  3 Apoyo a la democracia           q1tc_r … No se i…  55.4 55%        40.6  70.2
#>  4 Satisfacción con democracia de… q1tc_r … Hombre/…  42.1 42%        41.4  42.9
#>  5 Satisfacción con democracia de… q1tc_r … Mujer/f…  37.5 38%        36.7  38.3
#>  6 Satisfacción con democracia de… q1tc_r … No se i…  43.4 43%        27.8  58.9
#>  7 Apoyo a la democracia           edre x … Ninguna   55.1 55%        51.6  58.7
#>  8 Apoyo a la democracia           edre x … Primari…  54.5 55%        52.7  56.4
#>  9 Apoyo a la democracia           edre x … Primari…  56.9 57%        55.4  58.4
#> 10 Apoyo a la democracia           edre x … Secunda…  56.2 56%        54.9  57.6
#> 11 Apoyo a la democracia           edre x … Secunda…  56.6 57%        55.7  57.6
#> 12 Apoyo a la democracia           edre x … Terciar…  63.3 63%        61.7  64.9
#> 13 Apoyo a la democracia           edre x … Terciar…  66.3 66%        65.0  67.6
#> 14 Satisfacción con democracia de… edre x … Ninguna   51.7 52%        47.9  55.5
#> 15 Satisfacción con democracia de… edre x … Primari…  46.2 46%        44.3  48.0
#> 16 Satisfacción con democracia de… edre x … Primari…  43.5 44%        42.0  45.0
#> 17 Satisfacción con democracia de… edre x … Secunda…  38.1 38%        36.9  39.4
#> 18 Satisfacción con democracia de… edre x … Secunda…  38.3 38%        37.4  39.3
#> 19 Satisfacción con democracia de… edre x … Terciar…  37.0 37%        35.4  38.7
#> 20 Satisfacción con democracia de… edre x … Terciar…  38.9 39%        37.4  40.3

# Single DV X Single IV
lpr_mover(data = ym23lpr,
outcome="ing4",
grouping_vars="pn4",
rec=c(5,7),
ttest = FALSE)
#> # A tibble: 4 × 7
#>   outcome               varlabel            vallabel  prop proplabel    lb    ub
#>   <chr>                 <chr>               <chr>    <dbl> <chr>     <dbl> <dbl>
#> 1 Apoyo a la democracia Satisfacción con d… Muy sat…  64.9 65%        63.3  66.4
#> 2 Apoyo a la democracia Satisfacción con d… Satisfe…  68.2 68%        67.6  68.9
#> 3 Apoyo a la democracia Satisfacción con d… Insatis…  53.3 53%        52.7  53.9
#> 4 Apoyo a la democracia Satisfacción con d… Muy ins…  49.1 49%        48.0  50.2

# Multiple DV X Single IV
lpr_mover(data = ym23lpr,
outcome=c("ing4", "pn4"),
grouping_vars="edre",
rec=c(5,7), rec2=c(1,2),
ttest = FALSE)
#> # A tibble: 14 × 7
#>    outcome                         varlabel vallabel  prop proplabel    lb    ub
#>    <chr>                           <chr>    <chr>    <dbl> <chr>     <dbl> <dbl>
#>  1 Apoyo a la democracia           edre x … Ninguna   55.1 55%        51.6  58.7
#>  2 Apoyo a la democracia           edre x … Primari…  54.5 55%        52.7  56.4
#>  3 Apoyo a la democracia           edre x … Primari…  56.9 57%        55.4  58.4
#>  4 Apoyo a la democracia           edre x … Secunda…  56.2 56%        54.9  57.6
#>  5 Apoyo a la democracia           edre x … Secunda…  56.6 57%        55.7  57.6
#>  6 Apoyo a la democracia           edre x … Terciar…  63.3 63%        61.7  64.9
#>  7 Apoyo a la democracia           edre x … Terciar…  66.3 66%        65.0  67.6
#>  8 Satisfacción con democracia de… edre x … Ninguna   51.7 52%        47.9  55.5
#>  9 Satisfacción con democracia de… edre x … Primari…  46.2 46%        44.3  48.0
#> 10 Satisfacción con democracia de… edre x … Primari…  43.5 44%        42.0  45.0
#> 11 Satisfacción con democracia de… edre x … Secunda…  38.1 38%        36.9  39.4
#> 12 Satisfacción con democracia de… edre x … Secunda…  38.3 38%        37.4  39.3
#> 13 Satisfacción con democracia de… edre x … Terciar…  37.0 37%        35.4  38.7
#> 14 Satisfacción con democracia de… edre x … Terciar…  38.9 39%        37.4  40.3

# Multiple DV X Multiple IV
lpr_mover(data = ym23lpr,
outcome=c("ing4", "pn4"),
grouping_vars=c("edre", "q1tc_r"),
rec=c(5,7), rec2=c(1,2),
ttest = FALSE)
#> # A tibble: 20 × 7
#>    outcome                         varlabel vallabel  prop proplabel    lb    ub
#>    <chr>                           <chr>    <chr>    <dbl> <chr>     <dbl> <dbl>
#>  1 Apoyo a la democracia           edre x … Ninguna   55.1 55%        51.6  58.7
#>  2 Apoyo a la democracia           edre x … Primari…  54.5 55%        52.7  56.4
#>  3 Apoyo a la democracia           edre x … Primari…  56.9 57%        55.4  58.4
#>  4 Apoyo a la democracia           edre x … Secunda…  56.2 56%        54.9  57.6
#>  5 Apoyo a la democracia           edre x … Secunda…  56.6 57%        55.7  57.6
#>  6 Apoyo a la democracia           edre x … Terciar…  63.3 63%        61.7  64.9
#>  7 Apoyo a la democracia           edre x … Terciar…  66.3 66%        65.0  67.6
#>  8 Satisfacción con democracia de… edre x … Ninguna   51.7 52%        47.9  55.5
#>  9 Satisfacción con democracia de… edre x … Primari…  46.2 46%        44.3  48.0
#> 10 Satisfacción con democracia de… edre x … Primari…  43.5 44%        42.0  45.0
#> 11 Satisfacción con democracia de… edre x … Secunda…  38.1 38%        36.9  39.4
#> 12 Satisfacción con democracia de… edre x … Secunda…  38.3 38%        37.4  39.3
#> 13 Satisfacción con democracia de… edre x … Terciar…  37.0 37%        35.4  38.7
#> 14 Satisfacción con democracia de… edre x … Terciar…  38.9 39%        37.4  40.3
#> 15 Apoyo a la democracia           q1tc_r … Hombre/…  59.3 59%        58.6  60.1
#> 16 Apoyo a la democracia           q1tc_r … Mujer/f…  58.0 58%        57.2  58.7
#> 17 Apoyo a la democracia           q1tc_r … No se i…  55.4 55%        40.6  70.2
#> 18 Satisfacción con democracia de… q1tc_r … Hombre/…  42.1 42%        41.4  42.9
#> 19 Satisfacción con democracia de… q1tc_r … Mujer/f…  37.5 38%        36.7  38.3
#> 20 Satisfacción con democracia de… q1tc_r … No se i…  43.4 43%        27.8  58.9
# }
```
