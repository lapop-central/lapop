# LAPOP Stacked Bar Graph Pre-Processing

This function creates dataframes which can then be input in
lapop_stack() for plotting variables categories with a stacked bar graph
using LAPOP formatting.

## Usage

``` r
lpr_stack(
  data,
  outcome,
  xvar = NULL,
  sort = "y",
  order = "hi-lo",
  filesave = "",
  keep_nr = FALSE
)
```

## Arguments

- data:

  The data that should be analyzed. It requires a survey object from
  lpr_data() function.

- outcome:

  Vector of variables be plotted.

- xvar:

  Character. Outcome variable will be broken down by this variable.
  Default is NULL

- sort:

  Character. On what value the bars are sorted: the x or the y. Options
  are "y" (default; for the value of the outcome variable), "xv" (for
  the underlying values of the x variable), "xl" (for the labels of the
  x variable, i.e., alphabetical).

- order:

  Character. How the bars should be sorted. Options are "hi-lo"
  (default) or "lo-hi".

- filesave:

  Character. Path and file name to save the dataframe as csv.

- keep_nr:

  Logical. If TRUE, will convert "don't know" (missing code .a) and "no
  response" (missing code .b) into valid data (value = 99) and use them
  in the denominator when calculating percentages. The default is to
  examine valid responses only. Default: FALSE.

## Value

Returns a data frame, with data formatted for visualization by
lapop_stack

## Author

Robert Vidigal, <robert.vidigal@vanderbilt.edu>

## Examples

``` r
# \donttest{
require(lapop); data(ym23)

# Set Survey Context
ym23lpr<-lpr_data(ym23)

# Multiple outcomes stacked
lpr_stack(data = ym23lpr,
outcome = c("b12", "b18"))
#> # A tibble: 14 × 4
#>    varlabel                         vallabel  prop proplabel
#>    <chr>                            <fct>    <dbl> <chr>    
#>  1 Confianza en las fuerzas armadas Mucho    20.6  21%      
#>  2 Confianza en las fuerzas armadas 5        18.6  19%      
#>  3 Confianza en las fuerzas armadas 6        15.3  15%      
#>  4 Confianza en las fuerzas armadas 4        15.1  15%      
#>  5 Confianza en las fuerzas armadas Nada     12.3  12%      
#>  6 Confianza en las fuerzas armadas 3        10.6  11%      
#>  7 Confianza en las fuerzas armadas 2         7.55 8%       
#>  8 Confianza en la policía nacional Nada     19.2  19%      
#>  9 Confianza en la policía nacional 4        16.7  17%      
#> 10 Confianza en la policía nacional 5        16.1  16%      
#> 11 Confianza en la policía nacional 3        14.2  14%      
#> 12 Confianza en la policía nacional 2        11.7  12%      
#> 13 Confianza en la policía nacional Mucho    11.4  11%      
#> 14 Confianza en la policía nacional 6        10.7  11%      

# Single outcome over years
lpr_stack(data = ym23lpr,
outcome = "q14f",
xvar="year")
#> # A tibble: 12 × 5
#>    varlabel                                  vallabel xvar_label  prop proplabel
#>    <chr>                                     <fct>    <fct>      <dbl> <chr>    
#>  1 Probabilidad de vivir/trabajar en otro p… Muy pro… 2018       44.9  45%      
#>  2 Probabilidad de vivir/trabajar en otro p… Algo pr… 2018       30.0  30%      
#>  3 Probabilidad de vivir/trabajar en otro p… Poco pr… 2018       19.4  19%      
#>  4 Probabilidad de vivir/trabajar en otro p… Nada pr… 2018        5.60 6%       
#>  5 Probabilidad de vivir/trabajar en otro p… Muy pro… 2019       40.1  40%      
#>  6 Probabilidad de vivir/trabajar en otro p… Algo pr… 2019       32.5  32%      
#>  7 Probabilidad de vivir/trabajar en otro p… Poco pr… 2019       23.1  23%      
#>  8 Probabilidad de vivir/trabajar en otro p… Nada pr… 2019        4.40 4%       
#>  9 Probabilidad de vivir/trabajar en otro p… Muy pro… 2023       33.8  34%      
#> 10 Probabilidad de vivir/trabajar en otro p… Algo pr… 2023       29.1  29%      
#> 11 Probabilidad de vivir/trabajar en otro p… Poco pr… 2023       23.6  24%      
#> 12 Probabilidad de vivir/trabajar en otro p… Nada pr… 2023       13.5  14%      
# }
```
