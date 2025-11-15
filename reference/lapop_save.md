# LAPOP Save

This function creates exports graphs created using the LAPOP templates.

## Usage

``` r
lapop_save(
  figure,
  filename,
  format = "svg",
  logo = FALSE,
  width_px = 895,
  height_px = 500
)
```

## Arguments

- figure:

  Ggplot object.

- filename:

  File path + name to be saved + .filetype.

- format:

  Character. Options: "png", "svg". Default = "svg".

- logo:

  Logical. Should logo be added to plot? Default: FALSE.

- width_px:

  Numeric. Width in pixels. Default: 750.

- height_px:

  Numeric. Height in pixels.

## Value

Saves a file (in either .svg or .png format) to provided directory.

## Examples

``` r
df <- data.frame(
cat = c("Far Left", 1, 2, 3, 4, "Center", 6, 7, 8, 9, "Far Right"),
prop = c(4, 3, 5, 12, 17, 23, 15, 11, 5, 4, 1),
proplabel = c("4%", "3%", "5%", "12%", "17%", "23%", "15%", "11%", "5%", "4%", "1%")
)
myfigure <- lapop_hist(df,
          main_title = "Centrists are a plurality among Peruvians",
          subtitle = "Distribution of ideological preferences",
          source_info = "Peru, 2019",
          ymax = 27
)

f <- file.path(tempdir(), "fig1.svg")
lapop_save(myfigure, f, format = "svg", width_px = 800)
#> agg_record_1522022033 
#>                     2 
```
