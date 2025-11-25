# LAPOP Map Graph

\`lapop_map()\` generates a stylized choropleth map using ISO2 country
codes. It is designed to map cross-country results from \`lpr_cc()\` and
supports either a full world map (\`survey = "CSES"\`) or an
Americas-only map (\`survey = "AmericasBarometer"\`).

## Usage

``` r
lapop_map(
  data,
  iso_col = "iso2",
  value_col = "value",
  survey = c("CSES", "AmericasBarometer"),
  zoom = 1,
  title = NULL,
  palette_cont = c("#F2A344", "#D97A1E", "#BF5A00", "#8A3900", "#4A1E00"),
  palette_disc = c("#F2A344", "#D97A1E", "#BF5A00", "#8A3900", "#4A1E00")
)
```

## Arguments

- data:

  A data frame containing ISO2 codes and a value to map.

- iso_col:

  String. Column name containing ISO2 country codes (e.g., \`"US"\`,
  \`"BR"\`).

- value_col:

  String. Column name containing the numeric or categorical variable to
  visualize.

- survey:

  Either \`"CSES"\` (full world map) or \`"AmericasBarometer"\`
  (Americas only).

- zoom:

  Numeric (0–1). Controls how tightly the map zooms when \`survey =
  "AmericasBarometer"\`. Default is \`1\`.

- title:

  Optional plot title.

- palette_cont:

  Vector of 5 colors for continuous variables.

- palette_disc:

  Vector of up to 5 colors for discrete variables.

## Value

A \`ggplot2\` choropleth map object.

## Author

Robert Vidigal, <robert.vidigal@vanderbilt.edu>

## Examples

``` r
if (FALSE) { # \dontrun{
# Continuous variable example
data_cont <- data.frame(
  vallabel = c("CA", "BR", "MX", "PE", "CO"),
  prop = c(37, 52, 94, 17, 69)
)
lapop_map(data_cont, iso_col = "vallabel", value_col = "prop",
          survey = "AmericasBarometer", zoom = 0.9)

# Factor variable example
data_fact <- data.frame(
  vallabel = c("CA", "BR", "MX", "PE", "CO"),
  group = c("A","A","B","B","C")
)
lapop_map(data_fact, iso_col = "vallabel", value_col = "group",
          survey = "AmericasBarometer")
} # }
```
