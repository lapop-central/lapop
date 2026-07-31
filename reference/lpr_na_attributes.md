# Convert LAPOP missing-value codes to haven tagged NAs

Converts numeric sentinel codes used in LAPOP/Stata workflows to
\[haven::tagged_na()\] values. By default, \`888888\`, \`988888\`, and
\`999999\` are converted to \`NA(a)\`, \`NA(b)\`, and \`NA(c)\`,
respectively.

## Usage

``` r
lpr_na_attributes(
  data,
  na_values = c(888888, 988888, 999999),
  na_tags = c("a", "b", "c"),
  vars = NULL,
  preserve_labels = TRUE,
  print = FALSE
)
```

## Arguments

- data:

  A data frame.

- na_values:

  Numeric vector of sentinel values to convert.

- na_tags:

  Character vector of single-letter missing-value tags. Must be the same
  length as \`na_values\`.

- vars:

  Optional character vector of variable names to process. Defaults to
  all variables.

- preserve_labels:

  Logical. If \`TRUE\`, labels attached to converted sentinel values are
  reassigned to the corresponding tagged NAs.

- print:

  Logical. If \`TRUE\`, prints a compact missing-value summary for each
  processed variable. Defaults to \`FALSE\`.

## Value

\`data\` with selected numeric variables converted from sentinel
missing-value codes to haven tagged NAs.

## Details

Unlike ordinary \`NA\` values or variable-level attributes, tagged NAs
retain the missing-value reason for each observation and can be written
to Stata as extended missing values by haven.

## Examples

``` r
x <- haven::labelled(
  c(1, 888888, 988888, 999999),
  labels = c(Yes = 1, DK = 888888, NR = 988888, NotApplicable = 999999)
)
dat <- data.frame(x = x)
out <- lpr_na_attributes(dat)
haven::is_tagged_na(out$x)
#> [1] FALSE  TRUE  TRUE  TRUE
```
