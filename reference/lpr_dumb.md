# LAPOP Dumbbell Graphs

This function creates dataframes which can then be input in lapop_dumb
for comparing means of a variable across countries and two waves using
LAPOP formatting.

## Usage

``` r
lpr_dumb(
  data,
  outcome,
  xvar = "pais",
  over,
  rec = c(1, 1),
  ci_level = 0.95,
  mean = FALSE,
  filesave = "",
  cfmt = "",
  sort = "prop2",
  order = "hi-lo",
  ttest = FALSE,
  keep_nr = FALSE
)
```

## Arguments

- data:

  A survey object. The data that should be analyzed.

- outcome:

  Outcome variable(s) of interest to be plotted across countries and
  waves, supplied as a character string or vector of strings.

- xvar:

  Character. The grouping variable to be plotted along the x-axis
  (technically, the vertical axis for lapop_dumb). Usually country
  (pais). Default: "pais".

- over:

  Numeric. A vector of values for "wave" that specify which two waves
  should be included in the plot.

- rec:

  Numeric. The minimum and maximum values of the outcome variable that
  should be included in the numerator of the percentage. For example, if
  the variable is on a 1-7 scale and rec is c(5, 7), the function will
  show the percentage who chose an answer of 5, 6, 7 out of all valid
  answers. Can also supply one value only, to produce the percentage
  that chose that value out of all other values. Default: c(1, 1).

- ci_level:

  Numeric. Confidence interval level for estimates. Default: 0.95

- mean:

  Logical. If TRUE, will produce the mean of the variable rather than
  recoding to percentage. Default: FALSE.

- filesave:

  Character. Path and file name to save the dataframe as csv.

- cfmt:

  Character. Changes the format of the numbers displayed above the bars.
  Uses sprintf string formatting syntax. Default is whole numbers for
  percentages and tenths place for means.

- sort:

  Character. On what value the bars are sorted. Options are "prop1" (for
  the value of the outcome variable in wave 1), "prop2" (default; for
  the value of the outcome variable in wave 2), "xv" (for the underlying
  values of the x variable), "xl" (for the labels of the x variable,
  i.e., alphabetical), and "diff" (for the difference between the
  outcome between the two waves).

- order:

  Character. How the bars should be sorted. Options are "hi-lo"
  (default) or "lo-hi".

- ttest:

  Logical. If TRUE, will conduct pairwise t-tests for difference of
  means between all pais-wave combinations and save them in attr(x,
  "t_test_results"). Default: FALSE.

- keep_nr:

  Logical. If TRUE, will convert "don't know" (missing code .a) and "no
  response" (missing code .b) into valid data (value = 99) and use them
  in the denominator when calculating percentages. The default is to
  examine valid responses only. Default: FALSE.

## Value

Returns a data frame, with data formatted for visualization by
lapop_dumb()

## Author

Luke Plutowski, <luke.plutowski@vanderbilt.edu> & Robert Vidigal,
<robert.vidigal@vanderbilt.edu>

## Examples

``` r
require(lapop); data(cm23)

# Set Survey Context
cm23lpr <- lpr_data(cm23)

# Single outcome over years
lpr_dumb(cm23lpr,
outcome = "ing4",
rec = c(5, 7),
over = c("2018/19", "2023"),
sort = "diff")
#>     pais   wave1   prop1      lb1      ub1 proplabel1 wave2   prop2      lb2
#> 1 Brasil 2018/19 59.9975 56.91498 63.08002        60%  2023 63.8175 60.94615
#>        ub2 proplabel2     diff
#> 1 66.68884        64% 3.819996

# Multiple outcomes over years
lpr_dumb(cm23lpr,
outcome=c("b13","b21", "b31"),
rec=c(5,7),
over=c("2018/19", "2023"))
#>   pais   wave1    prop1 proplabel1 wave2    prop2 proplabel2      lb1      ub1
#> 1  b31 2018/19 43.08618        43%  2023 42.16415        42% 40.06770 46.10465
#> 2  b13 2018/19 30.32138        30%  2023 35.25472        35% 27.76127 32.88150
#> 3  b21 2018/19 13.61917        14%  2023 20.52433        21% 11.52554 15.71279
#>        lb2      ub2
#> 1 38.97057 45.35774
#> 2 32.18235 38.32709
#> 3 17.82247 23.22619
```
