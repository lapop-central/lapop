# LAPOP Cross-Country Bar Graphs

This function creates bar graphs for comparing values across countries
using LAPOP formatting.

## Usage

``` r
lapop_cc(
  data,
  outcome_var = data$prop,
  lower_bound = data$lb,
  vallabel = data$vallabel,
  upper_bound = data$ub,
  label_var = data$proplabel,
  ymin = 0,
  ymax = 100,
  lang = "en",
  highlight = "",
  main_title = "",
  source_info = "LAPOP",
  subtitle = "",
  sort = "",
  color_scheme = "#784885",
  label_size = 5,
  max_countries = 30,
  label_angle = 0
)
```

## Arguments

- data:

  Data Frame. Dataset to be used for analysis. The data frame should
  have columns titled vallabel (values of x-axis variable (e.g. pais);
  character vector), prop (outcome variable; numeric), proplabel (text
  of outcome variable; character), lb (lower bound of estimate;
  numeric), and ub (upper bound of estimate; numeric). Default: None
  (must be supplied).

- vallabel, outcome_var, label_var, lower_bound, upper_bound:

  Character, numeric, character, numeric, numeric. Each component of the
  plot data can be manually specified in case the default columns in the
  data frame should not be used (if, for example, the values for a given
  variable were altered and stored in a new column). x

- ymin, ymax:

  Numeric. Minimum and maximum values for y-axis. Default: 0 to 100.

- lang:

  Character. Changes default subtitle text and source info to either
  Spanish or English. Will not translate input text, such as main title
  or variable labels. Takes either "en" (English) or "es" (Spanish).
  Default: "en".

- highlight:

  Character. Country of interest. Will highlight (make darker) that
  country's bar. Input must match entry in "vallabel" exactly. Default:
  None.

- main_title:

  Character. Title of graph. Default: None.

- source_info:

  Character. Information on dataset used (country, years, version,
  etc.), which is added to the bottom-left corner of the graph. Default:
  LAPOP ("Source: LAPOP Lab" will be printed).

- subtitle:

  Character. Describes the values/data shown in the graph, e.g.,
  "percentage of Mexicans who say...)". Default: None.

- sort:

  Character. Method of sorting bars. Options: "hi-lo" (highest to lowest
  y value), "lo-hi" (lowest to highest), "alpha" (alphabetical by
  vallabel/x-axis label). Default: Order of data frame.

- color_scheme:

  Character. Color of bars. Takes hex number, beginning with "#".
  Default: \#784885.

- label_size:

  Numeric. Size of text for data labels (percentages above bars).
  Default: 5.

- max_countries:

  Numeric. Threshold for automatic x-axis label rotation. When the
  number of unique country labels exceeds this value, labels will be
  rotated for better readability. Default: 20.

- label_angle:

  Numeric. Angle (in degrees) to rotate x-axis labels when max_countries
  is exceeded. Default: 0.

## Value

Returns an object of class `ggplot`, a ggplot figure showing average
values of some variables across multiple countries.

## Author

Luke Plutowski, <luke.plutowski@vanderbilt.edu> & Robert Vidigal,
<robert.vidigal@vanderbilt.edu>

## Examples

``` r
# \donttest{
require(lapop); lapop_fonts()
#> LAPOP fonts loaded successfully: Inter, Roboto, and Nunito (regular and light).

df <- data.frame(
vallabel = c("PE", "CO", "BR", "PN", "GT", "DO", "MX", "BO", "EC"),
prop      = c(36.1, 19.3, 16.6, 13.3, 13.0, 11.1,  9.5,  9.0,  8.1),
proplabel = c("36%" ,"19%" ,"17%" ,"13%" ,"13%" ,"11%" ,"10%", "9%", "8%"),
lb        = c(34.9, 18.1, 15.4, 12.1, 11.8,  9.9,  8.3,  7.8,  6.9),
ub        = c(37.3, 20.5, 17.8, 14.5, 14.2, 12.3, 10.7, 10.2,  9.3)
)
lapop_cc(df,
         main_title = "Normalization of Intimate Partner Violence in LAC Countries",
         subtitle = "% who say domestic violence is private matter",
         source_info = "LAPOP Lab, AmericasBarometer 2021",
         highlight = "PE",
         ymax = 50)

# }
```
