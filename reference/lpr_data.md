# LAPOP Data Processing

This function takes LAPOP datasets and adds survey features such as
sampling design effects, outputting a svy_tbl object that can then be
analyzed using lpr\_ wrangling commands.

## Usage

``` r
lpr_data(data_path, wt = FALSE)
```

## Arguments

- data_path:

  The path for a AmericasBarometer data or a an existing dataframe.

- wt:

  Logical. If TRUE, use \`wt\` (weights only for single-country
  single-year data) instead of \`weight1500\` (the default weights for
  multiple-country and multiple-year data). Default: FALSE.

## Value

Returns a svy_tbl object

## Examples
