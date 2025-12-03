# LAPOP Map Graph

\`lapop_map()\` generates a stylized choropleth map using ISO2 country
codes from both continuous and factor variables. It is designed to map
cross-country results from \`lpr_cc()\` and supports either a full world
map (\`survey = "CSES"\`) \# or an Americas-only map (\`survey =
"AmericasBarometer"\`).

## Usage

``` r
lapop_map(
  data,
  outcome = "value",
  pais_lab = "pais_lab",
  survey = c("CSES", "AmericasBarometer"),
  zoom = 1,
  title = NULL,
  palette = c("#F2A344", "#D97A1E", "#BF5A00", "#8A3900", "#4A1E00")
)
```

## Arguments

- data:

  A data frame containing ISO2 country codes and a value to map.

- outcome:

  String. Column name containing the numeric or categorical variable to
  visualize.

- pais_lab:

  String. Column name containing ISO2 country codes (e.g., \`"US"\`,
  \`"BR"\`).

- survey:

  Either \`"CSES"\` (full world map) or \`"AmericasBarometer"\`
  (Americas only).

- zoom:

  Numeric (0–1). Controls how tightly the map zooms when \`survey =
  "AmericasBarometer"\`. Default is \`1\`.

- title:

  Optional plot title.

- palette:

  Vector of up to 5 colors for continuous and factor variables.

## Value

A \`ggplot2\` choropleth map object.

## Author

Robert Vidigal, <robert.vidigal@vanderbilt.edu>

## Examples

``` r
if (FALSE) { # \dontrun{
# Continuous variable example
data_cont <- data.frame(
  vallabel = c("US", "AR", "VE", "CH", "EC"),
  prop = c(37, 52, 94, 17, 69)
)
lapop_map(data_cont, pais_lab = "vallabel", outcome = "prop",
          survey = "AmericasBarometer", zoom = 0.9)

# Factor variable example
data_fact <- data.frame(
  valalbel = c("CA", "BR", "MX", "PE", "CO"),
  group = c("A","A","B","B","C")
)
lapop_map(data_fact, pais_lab = "vallabel", outcome = "group",
          survey = "AmericasBarometer")
} # }
```
