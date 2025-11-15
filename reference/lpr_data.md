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
if (FALSE) { # \dontrun{
# Single-country single-year (wt)
#' bra23w <- lpr_data(bra23, wt = TRUE)
print(bra23w)} # }

# Single-country  multi-year (weight1500)
if (FALSE) cm23w <- lpr_data(cm23)
print(cm23w) # \dontrun{}
#> Error: object 'cm23w' not found

#' # Multi-country  single-year (weight1500)
if (FALSE) ym23w <- lpr_data(ym23)
print(ym23w) # \dontrun{}
#> Error: object 'ym23w' not found
```
