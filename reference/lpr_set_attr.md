# Set Variable Attributes from AmericasBarometer Notes (with propagation)

Applies notes stored in a data frame as attributes to variables in
\`data\`. If a variable has expanded children (e.g., vb20_1, vb20_2),
the attribute is propagated to all of them by default.

## Usage

``` r
lpr_set_attr(
  data,
  notes,
  noteid = character(),
  attribute_name = character(),
  verbose = FALSE,
  propagate = TRUE,
  overwrite = TRUE
)
```

## Arguments

- data:

  data.frame with variables to annotate

- notes:

  data.frame with columns variable_name, note_id, note_value

- noteid:

  character scalar; which note_id to use (e.g., "qtext_en")

- attribute_name:

  character scalar; attribute name to set (e.g., "qwording_en")

- verbose:

  logical; if TRUE it prints all variables notes available but not found
  in data

- propagate:

  logical; if TRUE, also set on \<varname\>\_\* children. Useful for
  nominal variables or multiple response options variables. Default
  TRUE.

- overwrite:

  logical; if FALSE, do not overwrite existing attribute on a variable.
  Default TRUE.

## Value

The input data frame with attributes applied (i.e., question wording)
