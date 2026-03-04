# Compute Design-Based Proportion and Confidence Interval

Computes a weighted proportion (mean of a binary outcome) and its
confidence interval using complex survey design features. When
stratification and PSU variables are supplied, the function uses Taylor
linearized variance estimation via the survey package.

## Usage

``` r
lpr_ci(
  data,
  outcome,
  weight = "weight1500",
  strata = NULL,
  psu = NULL,
  conf.level = 0.95,
  na.rm = TRUE
)
```

## Arguments

- data:

  A data frame containing the outcome and survey design variables.

- outcome:

  Character string. Name of a binary variable coded 0/1.

- weight:

  Character string. Name of the sampling weight variable. Default is
  \`"weight1500"\`.

- strata:

  Character string. Name of the stratification variable. Default is
  \`NULL\`. If provided together with \`psu\`, a complex survey design
  is used.

- psu:

  Character string. Name of the primary sampling unit (cluster)
  variable. Default is \`NULL\`.

- conf.level:

  Numeric. Confidence level for the interval. Default is \`0.95\`.

- na.rm:

  Logical. If \`TRUE\`, rows with missing values in the required
  variables are removed prior to estimation.

## Value

A data frame with:

- prop:

  Estimated proportion (mean of binary outcome).

- lb:

  Lower bound of the confidence interval.

- ub:

  Upper bound of the confidence interval.

- se:

  Standard error of the estimate.

## Details

If both \`strata\` and \`psu\` are provided, a full complex survey
design is declared. If they are \`NULL\`, the function computes a
weighted estimate assuming simple random sampling (SRS) with weights.

Lonely PSUs are handled using \`survey.lonely.psu = "adjust"\`.

Variance estimation is performed using Taylor linearization as
implemented in
[`svymean`](https://rdrr.io/pkg/survey/man/surveysummary.html). When
both \`strata\` and \`psu\` are supplied, clustering and stratification
are incorporated in the variance estimator.

If \`strata\` and \`psu\` are not provided, the function assumes a
weighted simple random sample and estimates variance accordingly.

## Examples

``` r
if (FALSE) { # \dontrun{
# Design-based estimate
data(cm23)
lpr_ci(data = cm23,
         outcome = "b13",
         weight = "weight1500",
         strata = "strata",
         psu = "upm")

# Weighted SRS estimate
data(bra23)
lpr_ci(data = bra23,
         outcome = "b13",
         weight = "wt")
} # }
```
