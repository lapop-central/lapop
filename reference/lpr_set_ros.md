# Set Response Option (ROS) labels for variables in AmericasBarometer datasets

This function extracts formatted response option labels for
AmericasBarometer variables, using label tables stored as attributes.
The labels are formatted with their corresponding numeric codes and can
be pulled in multiple languages.

## Usage

``` r
lpr_set_ros(data, lang_id = "en", attribute_name = "roslabel")
```

## Arguments

- data:

  A data frame loaded using readstata13 containing label.table
  attributes.

- lang_id:

  Language identifier for the labels ("en" for English, "es" for
  Spanish, "pt" for Portuguese). Default is "en" (English).

- attribute_name:

  The name of the attribute where the formatted response options string
  will be stored. Default is "roslabel".

## Value

The input data frame with response option labels added to variables as
attributes

## Details

The function looks for label tables stored as attributes of the data
frame, with names following the pattern "VARNAME_lang_id" (e.g.,
"ing4_en" for English labels of variable ing4). Each label table should
be a named numeric vector where names are the response labels and values
are the corresponding codes.

Special codes (values \>= 1000) are excluded from the response options
string.

## Examples

``` r
require(lapop); data(bra23)

# Apply the function
bra23 <- lpr_set_ros(bra23) # Default English
bra23 <- lpr_set_ros(bra23, lang_id = "es", attribute_name = "respuestas") # Spanish
bra23 <- lpr_set_ros(bra23, lang_id = "pt", attribute_name = "ROsLabels_pt") # Portuguese

# View the resulting attribute
attr(bra23$ing4, "roslabel")
#> [1] "Response Options: (1) Strongly disagree (7) Strongly agree"
attr(bra23$ing4, "respuestas")
#> [1] "Opciones de Respuesta: (1) Muy en desacuerdo (7) Muy de acuerdo"
attr(bra23$ing4, "ROsLabels_pt")
#> [1] "Alternativas de Resposta: (1) Discorda muito (7) Concorda muito"
```
