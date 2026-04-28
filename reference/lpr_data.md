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

## Author

Luke Plutowski, <luke.plutowski@vanderbilt.edu> & Robert Vidigal,
<robert.vidigal@vanderbilt.edu>

## Examples

``` r
# \donttest{
data(bra23)
data(cm23)

bra23w <- lpr_data(bra23, wt = TRUE)
cm23w <- lpr_data(cm23)
# }
```
