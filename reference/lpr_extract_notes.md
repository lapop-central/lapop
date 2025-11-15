# Extract Notes from AmericasBarometer Attributes

Extracts notes stored in a dataset's attributes and organizes them into
a tidy data frame. This function is particularly useful for processing
Stata datasets imported into R that contain variable notes in their
attributes.

## Usage

``` r
lpr_extract_notes(data)
```

## Arguments

- data:

  A dataset (data frame) containing "expansion.fields" in its
  attributes.

## Value

A data frame with three columns:

- variable_name:

  Name of the variable the note belongs to

- note_id:

  Identifier for the note

- note_value:

  The actual note text

## Details

This function processes the attributes of a dataset to extract notes
that are typically stored in a specific format. It skips any notes
associated with "\_dta" (dataset-level notes) and only returns
variable-specific notes. The function expects the notes to be organized
as a list where each element contains exactly three components: variable
name, note ID, and note value.

## Examples

``` r
# \donttest{
require(lapop); data(bra23)

# Extract the notes
notesBRA23 <- lpr_extract_notes(bra23)
tail(notesBRA23[notesBRA23$variable_name=="ing4",]) # for ing4 variable
#>      variable_name         note_id
#> 4201          ing4 _lang_l_default
#> 4202          ing4 _lang_v_default
#> 5953          ing4           note1
#> 5954          ing4           note2
#> 7422          ing4      _lang_v_pt
#> 7423          ing4      _lang_l_pt
#>                                                                                                                                                         note_value
#> 4201                                                                                                                                                    labels2670
#> 4202                                                                               ING4. A democracia tem seus problemas, mas é melhor que qualquer outra forma de
#> 5953 Puede que la democracia tenga problemas, pero es mejor que cualquier otra forma de gobierno. ¿Hasta qué punto está de acuerdo o en desacuerdo con esta frase?
#> 5954                Democracy may have problems, but it is better than any other form of government.  To what extent do you agree or disagree with this statement?
#> 7422                                                                                                                                            Apoio à democracia
#> 7423                                                                                                                                                       ing4_pt
# }
```
