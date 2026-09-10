# Extract Stata variable notes and characteristics

Returns the original characteristic identifiers, without assuming that a
particular note number is a question or that a variable label is a
wording.

## Usage

``` r
lpr_extract_notes(data, note_ids = NULL, include_dataset = FALSE)
```

## Arguments

- data:

  A data frame with an \`expansion.fields\` attribute, or that
  attribute's list of three-element character vectors.

- note_ids:

  Optional character vector of identifiers to retain.

- include_dataset:

  Include characteristics belonging to \`\_dta\`.

## Value

A data frame with character columns \`variable_name\`, \`note_id\`, and
\`note_value\`. These columns are also present when no notes are
available.

## Examples

``` r
toy <- data.frame(x = 1)
attr(toy, "expansion.fields") <- list(c("x", "note1", "Question?"))
lpr_extract_notes(toy)
#>   variable_name note_id note_value
#> 1             x   note1  Question?
```
