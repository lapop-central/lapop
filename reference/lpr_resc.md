# LAPOP Rescale

This function allows users to rescale and reorder variables. It is
designed for variables of class "labelled" but the rescaling will work
for numeric and factor variables too.

## Usage

``` r
lpr_resc(
  var,
  min = 0L,
  max = 1L,
  reverse = FALSE,
  only_reverse = FALSE,
  only_flip = FALSE,
  map = FALSE,
  new_varlabel = NULL,
  new_vallabels = NULL
)
```

## Arguments

- var:

  Vector (class "labelled" or "haven_labelled"). The original variable
  to rescale.

- min:

  Integer. Minimum value for the new rescaled variables; default is 0.

- max:

  Integer. Maximum value for the new rescaled variables; default is 1.

- reverse:

  Logical. Reverse code the variable before rescaling. Default: FALSE.

- only_reverse:

  Logical. Reverse code the variable, but do not rescale. Default:
  FALSE.

- only_flip:

  Logical. Flip the variable coding. Unlike "only_reverse", this will
  exactly preserve the values of the old variable. For example, for a
  variable with codes 1, 2, 3, 5, 10, only_flip will code the values 10,
  5, 3, 2, 1 (instead of 10, 9, 8, 6, 1). Generally, reverse should be
  preferred to preserve the underlying scale. Not compatible with
  rescale. Default: FALSE.

- map:

  Logical. If TRUE, will print a cross-tab showing the old variable and
  the new, recoded variable. Used to verify the new variable is coded
  correctly. Default: FALSE.

- new_varlabel:

  Character. Variable label for the new variable. Default: old
  variable's label.

- new_vallabels:

  Character vector. Supply custom names for value labels. Default: value
  labels of old variable.

## Value

The input variable rescaled

## Author

Luke Plutowski, <luke.plutowski@vanderbilt.edu> & Robert Vidigal,
<robert.vidigal@vanderbilt.edu>

## Examples

``` r
require(lapop); data(ym23)

# Regular data.frame
ym23$pn4r <- lpr_resc(ym23$pn4,
reverse = TRUE,
map = TRUE)
#>                      
#>                           1     2     3     4
#>   Muy satisfecho(a)       0     0     0  3735
#>   Satisfecho(a)           0     0 20398     0
#>   Insatisfecho(a)         0 27707     0     0
#>   Muy insatisfecho(a)  9105     0     0     0

# LPR data.frame
ym23lpr<-lpr_data(ym23)
ym23lpr$variables$pn4r <- lpr_resc(ym23lpr$variables$pn4,
reverse = TRUE,
map = TRUE)
#>                      
#>                           1     2     3     4
#>   Muy satisfecho(a)       0     0     0  3735
#>   Satisfecho(a)           0     0 20398     0
#>   Insatisfecho(a)         0 27707     0     0
#>   Muy insatisfecho(a)  9105     0     0     0
```
