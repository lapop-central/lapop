# Extract original response codes and labels

Reads dataset dictionaries and haven labels before considering factor
levels. Factor positions are never substituted for the original survey
codes.

## Usage

``` r
lpr_extract_ros(
  data,
  lang_id = "en",
  include_special = FALSE,
  restrict_to_present = TRUE,
  one_row_per_var = FALSE,
  pair_sep = " | ",
  attr_name = "label.table",
  special_values = NULL
)
```

## Arguments

- data:

  A data frame imported with readstata13 or haven.

- lang_id:

  Requested dictionary language, e.g. "en", "es", or "pt". \`NULL\` or
  \`""\` uses the variable's \`val.labels\` link, then the dataset's
  active language. A sole unambiguous dictionary is a final fallback.
  For haven vectors without language metadata, their attached labels are
  used.

- include_special:

  Include tagged missing codes and explicitly labelled nonresponses.
  Valid codes are not excluded merely because they exceed 1000.

- restrict_to_present:

  Keep only observed options. For questionnaire inventories use
  \`FALSE\`, so unobserved response options are retained.

- one_row_per_var:

  Collapse into one row per variable with code-label pairs.

- pair_sep:

  Separator between collapsed pairs.

- attr_name:

  Preferred dictionary attribute. Even when \`"levels"\` is requested,
  an available original code dictionary takes precedence.

- special_values:

  Additional response codes to exclude when \`include_special = FALSE\`.

## Value

A tibble with \`variable_name\`, \`value\`, and \`answer_text\`, or just
\`variable_name\` and \`answer_text\` when collapsed. Numeric codes
remain numeric (including haven tagged NAs). If a dictionary has
character codes, \`value\` is character. Empty variables have genuine NA
cells. Plain factors without a code dictionary return their labels with
unknown (\`NA\`) codes and a warning.

## Examples

``` r
toy <- data.frame(x = c(0, 1))
attr(toy, "label.table") <- list(x_en = c(No = 0, Yes = 1, Other = 152501))
lpr_extract_ros(toy, restrict_to_present = FALSE)
#> # A tibble: 3 × 3
#>   variable_name  value answer_text
#>   <chr>          <dbl> <chr>      
#> 1 x                  0 No         
#> 2 x                  1 Yes        
#> 3 x             152501 Other      
lpr_extract_ros(toy, restrict_to_present = FALSE, one_row_per_var = TRUE)
#> # A tibble: 1 × 2
#>   variable_name answer_text                      
#>   <chr>         <chr>                            
#> 1 x             (0) No | (1) Yes | (152501) Other
```
