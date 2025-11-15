# LAPOP Time-Series Line Graph Pre-Processing

This function creates dataframes which can then be input in lapop_ts for
comparing values across time with a line graph using LAPOP formatting.

## Usage

``` r
lpr_ts(
  data,
  outcome,
  rec = c(1, 1),
  use_wave = FALSE,
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

  Character. Outcome variable of interest to be plotted across time.

- rec:

  Numeric. The minimum and maximum values of the outcome variable that
  should be included in the numerator of the percentage. For example, if
  the variable is on a 1-7 scale and rec is c(5, 7), the function will
  show the percentage who chose an answer of 5, 6, 7 out of all valid
  answers. Can also supply one value only, to produce the percentage
  that chose that value out of all other values. Default: c(1, 1).

- use_wave:

  Logical. If TRUE, will use "wave" for the x-axis; otherwise, will use
  "year". Default: FALSE.

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
lapop_ts()

## Author

Berta Diaz, <berta.diaz.martinez@vanderbilt.edu> & Luke Plutowski,
<luke.plutowski@vanderbilt.edu>

## Examples

``` r
require(lapop); data(ym23)

# Set Survey Context
ym23lpr<-lpr_data(ym23)

# Run lpr_ts
lpr_ts(ym23lpr,
outcome = "ing4",
use_wave = TRUE,
mean = TRUE,
ttest = TRUE)
#>       wave     prop       lb       ub proplabel         se
#> 8  2018/19 4.753684 4.731888 4.775480       4.8 0.01112058
#> 9     2021       NA       NA       NA      <NA>         NA
#> 10    2023 4.756581 4.734816 4.778347       4.8 0.01110472
```
