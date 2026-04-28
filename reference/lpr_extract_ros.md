# Extract Response Option (RO) values and texts for all variables into a tidy table.

Works with: (a) dataset-level dictionaries (e.g., attr(data,
"label.table") is a list keyed by "\<VAR\>\_\<lang\>"), or (b)
per-variable attributes (e.g., attr(data\[\[VAR\]\], "levels") or factor
levels).

## Usage

``` r
lpr_extract_ros(
  data,
  lang_id = "en",
  include_special = FALSE,
  restrict_to_present = TRUE,
  one_row_per_var = FALSE,
  pair_sep = " | ",
  attr_name = "label.table"
)
```

## Arguments

- data:

  A data.frame read with readstata13/haven/etc.

- lang_id:

  Language code used in label table names ("en", "es", "pt"). If
  \`NULL\` or \`""\`, auto-detect per variable (dataset-level only).
  Ignored for per-variable \`levels\`.

- include_special:

  Logical; if FALSE, drop codes \>= 1000 when codes are numeric. Default
  FALSE.

- restrict_to_present:

  Logical; if TRUE, keep only codes that appear in the data. Default
  TRUE.

- one_row_per_var:

  Logical; if TRUE, return one row per variable_name with concatenated
  ROs. Default FALSE.

- pair_sep:

  String used to separate each "(value) answer_text" pair when
  collapsing. Default " \| ".

- attr_name:

  Name of the attribute that stores RO info. Default "label.table".

## Value

If \`one_row_per_var = FALSE\`: tibble with columns \`variable_name\`,
\`value\`, \`answer_text\`. If \`one_row_per_var = TRUE\`: tibble with
columns \`variable_name\`, \`answer_text\` (collapsed pairs).

## Author

Robert Vidigal, <robert.vidigal@vanderbilt.edu>

## Examples

``` r
toy <- data.frame(
  ing4 = c(1L, 2L, 1L),
  b12 = c(1L, 2L, NA_integer_)
)
attr(toy, "label.table") <- list(
  ing4_pt = c("Apoia muito" = 1L, "Apoia" = 2L, "NS/NR" = 1000L),
  b12_pt = c("Muito" = 1L, "Algo" = 2L, "NS/NR" = 1000L)
)

lpr_extract_ros(toy, lang_id = "pt")
#> # A tibble: 4 × 3
#>   variable_name value answer_text
#>   <chr>         <int> <chr>      
#> 1 b12               1 Muito      
#> 2 b12               2 Algo       
#> 3 ing4              1 Apoia muito
#> 4 ing4              2 Apoia      
lpr_extract_ros(toy, lang_id = "pt", one_row_per_var = TRUE)
#> # A tibble: 2 × 2
#>   variable_name answer_text                
#>   <chr>         <chr>                      
#> 1 b12           (1) Muito | (2) Algo       
#> 2 ing4          (1) Apoia muito | (2) Apoia
```
