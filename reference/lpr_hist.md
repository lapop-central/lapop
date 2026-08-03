# LAPOP Bar/Histogram Graphs

This function creates dataframes which can then be input in lapop_hist
for showing a bar graph using LAPOP formatting.

## Usage

``` r
lpr_hist(
  data,
  outcome,
  filesave = "",
  cfmt = "",
  sort = "xv",
  order = "lo-hi",
  keep_nr = FALSE
)
```

## Arguments

- data:

  A survey object. The data that should be analyzed.

- outcome:

  Character. Outcome variable of interest.

- filesave:

  Character. Path and file name to save the dataframe as csv.

- cfmt:

  Character. Changes the format of the numbers displayed above the bars.
  Uses sprintf string formatting syntax. Default is whole numbers.

- sort:

  Character. On what value the bars are sorted. Options are "y" (for the
  value of the outcome variable), "xv" (default; for the underlying
  values of the x variable), "xl" (for the labels of the x variable,
  i.e., alphabetical).

- order:

  Character. How the bars should be sorted. Options are "hi-lo" or
  "lo-hi" (default).

- keep_nr:

  Logical. If TRUE, will convert "don't know" (missing code .a) and "no
  response" (missing code .b) into valid data (value = 99). The default
  is to examine valid responses only. Default: FALSE.

## Value

Returns a data frame, with data formatted for visualization by
lapop_hist

## Author

Shashwat Dhar <shashwat.dhar@vanderbilt.edu> & Luke Plutowski,
<luke.plutowski@vanderbilt.edu>

## Examples

``` r

require(lapop); data(bra23)

# Set Survey Context: single country and year (requires wt = T)
bra23lpr <- lpr_data(bra23, wt = TRUE)

lpr_hist(bra23lpr,
outcome = "ing4",
sort = "xv",
order = "hi-lo")
#>   cat      prop proplabel
#> 1   1  6.024089        6%
#> 2   2  5.566048        6%
#> 3   3  8.222090        8%
#> 4   4 16.370278       16%
#> 5   5 19.058429       19%
#> 6   6 12.600554       13%
#> 7   7 32.158512       32%
```
