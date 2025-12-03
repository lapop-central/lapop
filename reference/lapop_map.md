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
  main_title = "",
  subtitle = "",
  palette = c("#F2A344", "#D97A1E", "#BF5A00", "#8A3900", "#4A1E00"),
  source_info = "LAPOP",
  lang = "en"
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

- main_title:

  Character. Title of graph. Default: None.

- subtitle:

  Character. Describes the values/data shown in the graph, e.g.,
  "percentage of Mexicans who say...)". Default: None.

- palette:

  Vector of up to 5 colors for continuous and factor variables.

- source_info:

  Character. Information on dataset used (country, years, version,
  etc.), which is added to the bottom-left corner of the graph. Default:
  LAPOP ("Source: LAPOP Lab" will be printed).

- lang:

  Character. Changes default subtitle text and source info to either
  Spanish or English. Will not translate input text, such as main title
  or variable labels. Takes either "en" (English) or "es" (Spanish).
  Default: "en".

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
lapop_map(data_cont, pais_lab = "vallabel", outcome = "prop", zoom = 0.9,
          survey = "AmericasBarometer", main_title = "LAC Countries",
          subtitle = "% of respondents")

# Factor variable example
data_fact <- data.frame(
  vallabel = c("CA", "BR", "MX", "PE", "CO"),
  group = c("A","A","B","B","C")
)
lapop_map(data_fact, pais_lab = "vallabel", outcome = "group", zoom = 0.9,
          survey = "AmericasBarometer", main_title = "LAC Countries",
          subtitle = "% of respondents")
} # }
```
