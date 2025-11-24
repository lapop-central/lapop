# LAPOP Regression Coefficients Graph Pre-Processing

This function creates a data frame which can then be input in
lapop_coef() for plotting regression coefficients graph using LAPOP
formatting.

## Usage

``` r
lpr_coef(
  outcome = NULL,
  xvar = NULL,
  interact = NULL,
  model = "linear",
  data = NULL,
  estimate = c("coef"),
  vlabs = NULL,
  omit = NULL,
  filesave = NULL,
  replace = FALSE,
  level = 95
)
```

## Arguments

- outcome:

  Dependent variable for the svyglm regression model. (e.g.,
  "outcome_name"). Only one variable allowed.

- xvar:

  Vector of independent variables for the svyglm regression model (e.g.,
  "xvar1+xvar2+xvar3" and so on). Multiple variables are allowed.

- interact:

  Interaction terms (e.g., "xvar1\`\*\`xvar2 + xvar3\`:\`xvar4").
  Supports \`:\` and \`\*\` operators for interacting variables.
  Optional, default is NULL.

- model:

  Model family object for glm. Default is gaussian regression (i.e.,
  "linear"). For a logit model, use model="binomial"

- data:

  Survey design data from lpr_data() output.

- estimate:

  Character. Graph either the coefficients (i.e., \`coef\`) or the
  change in probabilities (i.e., \`contrast\`). Default is "coef."

- vlabs:

  Character. Rename variable labels to be displayed in the graph
  produced by lapop_coef(). For instance, vlabs=c("old_varname" =
  "new_varname").

- omit:

  Character. Do not display coefficients for these independent
  variables. Default is to display all variables included in the model.
  To omit any variables you need to include the raw "varname" in the
  omit argument.

- filesave:

  Character. Path and file name with csv extension to save the dataframe
  output.

- replace:

  Logical. Replace the dataset output if it already exists. Default is
  FALSE.

- level:

  Numeric. Set confidence level in numeric values; default is 95
  percent.

## Value

Returns a data frame, with data formatted for visualization by
lapop_coef

## Author

Robert Vidigal, <robert.vidigal@vanderbilt.edu>

## Examples

``` r
require(lapop); data(bra23)

# Set Survey Context
bra23lpr <- lpr_data(bra23, wt = TRUE)

# Example 1: Linear model
lpr_coef(data = bra23lpr,
 outcome = "ing4",
 xvar = "wealth+idio2",
 model = "linear",
 estimate = "coef")
#> CSV output file not created.
#>                varlabel         coef         lb        ub pvalue proplabel
#> (Intercept) (Intercept)  4.475856131  4.2348361 4.7168762  0.000     4.476
#> wealth           wealth  0.191626610  0.1209251 0.2623281  0.000     0.192
#> idio2Igual   idio2Igual -0.003091333 -0.2199569 0.2137742  0.978    -0.003
#> idio2Peor     idio2Peor -0.040723473 -0.2730561 0.1916092  0.729    -0.041

# Example 2: Logit model with contrasts
lpr_coef(data = bra23lpr,
 outcome = "fs2",
 xvar = "wealth+idio2",
 model = "binomial",
 estimate = "contrast")
#> CSV output file not created.
#>               varlabel        coef          lb           ub pvalue proplabel
#> 1    wealth: Max - Min -0.29702984 -0.34858163 -0.245478055 0.0000     -0.30
#> 2 idio2: Igual - Mejor -0.04387263 -0.08517791 -0.002567345 0.0374     -0.04
#> 3  idio2: Peor - Mejor  0.04304993 -0.01520200  0.101301853 0.1475      0.04

# Example 3: Interactive linear model
lpr_coef(data = bra23lpr,
 outcome = "ing4",
 xvar = "wealth+idio2",
 interact = "wealth*idio2",
 model = "linear",
 estimate = "coef")
#> CSV output file not created.
#>                            varlabel       coef          lb         ub pvalue
#> (Intercept)             (Intercept)  4.6564528  4.29602602 5.01687967  0.000
#> wealth                       wealth  0.1288742  0.01061972 0.24712865  0.033
#> idio2Igual               idio2Igual -0.1525902 -0.62365454 0.31847412  0.522
#> idio2Peor                 idio2Peor -0.5220352 -1.13114788 0.08707742  0.092
#> wealth:idio2Igual wealth:idio2Igual  0.0523350 -0.09917669 0.20384670  0.495
#> wealth:idio2Peor   wealth:idio2Peor  0.1638380 -0.02525802 0.35293398  0.089
#>                   proplabel
#> (Intercept)           4.656
#> wealth                0.129
#> idio2Igual           -0.153
#> idio2Peor            -0.522
#> wealth:idio2Igual     0.052
#> wealth:idio2Peor      0.164

# Example 4: Interactive logit model
lpr_coef(data = bra23lpr,
         outcome = "fs2",
         xvar = "wealth+idio2",
         interact = "wealth*idio2",
         model = "binomial",
         estimate = "contrast")
#> CSV output file not created.
#>               varlabel        coef          lb           ub pvalue proplabel
#> 1    wealth: Max - Min -0.29843627 -0.34983185 -0.247040693 0.0000     -0.30
#> 2 idio2: Igual - Mejor -0.04412517 -0.08593863 -0.002311707 0.0386     -0.04
#> 3  idio2: Peor - Mejor  0.04264438 -0.01579508  0.101083836 0.1527      0.04
```
