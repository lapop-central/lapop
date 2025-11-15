# AmericasBarometer Labels Guide

## Introduction

This concise guide demonstrates how R users can effectively work with
AmericasBarometer datasets to access variable metadata directly
eliminating the need for external codebooks. While these features are
more readily visible in Stata, they often require specific approaches in
R. The guide outlines:

1.  The multilingual structure and storage of AmericasBarometer data
    (including variable labels and value labels).

2.  How to implement our custom LAPOP Lab functions for seamless dataset
    analysis.

## Installing LAPOP Lab package

The `lapop` package contains custom functions to analyze data and plot
figures following the LAPOP Lab’s guidelines.

If you do not have the LAPOP Lab package already installed in your
machine you can install it using the `devtools` package below:

``` r
# Install the LAPOP Lab package:
devtools::install_github("https://github.com/lapop-central/lapop", 
                         force=TRUE, 
                         build_vignettes = TRUE)
```

After installation is successful, you will need to load the package into
your library:

``` r
library(lapop)
# Note: no need for lapop_fonts() 
# because we are not plotting figures
```

## How LAPOP Lab stores variables metadata

LAPOP Lab’s AmericasBarometer stores variable labels and value labels in
parallel languages (i.e., Spanish/English/Portuguese) directly within
the dataset structure. This allows researchers to access metadata
without external codebooks by:

Embedding language-specific labels as attributes in Stata-formatted
files and to use standardized variable naming conventions that maintain
consistency across survey waves since 2004. Therefore, Metadata is
structured to facilitate longitudinal analysis. The project employs
Stata-formatted datasets (.dta) with embedded metadata, preserving:

- Variable labels (i.e., question wording).

- Value labels (i.e., responses options).

- Missing value codes (i.e., Not Applicable, Don’t Know, Refused).

As a result, a key advantage is LAPOP Lab’s active metadata preservation
even when distributing data through third-party platforms like ICPSR or
NORC, the Stata-formatted metadata remains intact, allowing R/python
users to still access labels via the `readstata13` package.

## How to load AmericasBarometer Data in R

The preferred method for loading LAPOP Lab datasets is to use the
`read.dta13()` function from the `readstata13` package. Below, I show a
key difference between this recommended approach and two alternative
methods commonly used by researchers:
[`haven::read_dta()`](https://haven.tidyverse.org/reference/read_dta.html)
and
[`rio::import()`](http://gesistsa.github.io/rio/reference/import.md).

In the R programming language, attributes are additional metadata that
can be attached to R objects. Attributes provide a way to store extra
information about an object beyond its basic data structure. To access
the attributes of an object, you can use the
[`attr()`](https://rdrr.io/r/base/attr.html) or
[`attributes()`](https://rdrr.io/r/base/attributes.html) base functions.

``` r
# READSTATA13 PACKAGE (RECOMMENDED FOR LABELS)
data1 <- read.dta13("./BRA 2023 LAPOP AmericasBarometer (v1.0s).dta")
names(attributes(data1))

# HAVEN PACKAGE (RECOMMENDED FOR PLOTTING)
data2 <- read_dta("./BRA 2023 LAPOP AmericasBarometer (v1.0s).dta")
names(attributes(data2))

# RIO PACKAGE (NOT RECOMMENDED)
data3 <- import("./BRA 2023 LAPOP AmericasBarometer (v1.0s).dta")
names(attributes(data3))
```

The methods `haven` and `rio` packages do not recover all the metadata
from `dta` files. Thereby, we proceed with the dataset loaded with the
`readstata13` package.

## AmericasBarometer Variables Labels (Question Wording)

AmericasBarometer variable labels are stored as `notes` in Stata .dta
files. We can find them inside the “expansion.fields” attribute.

The `varlabels` object created is a nested list (much like a JSON
object) that will contain multilingual notes with the question wording
of each variable. For instance, for the variable `ing4` in the
`Brazil AB 2023` dataset will contain notes with the question wording
and lead-in in English, Spanish, and Portuguese.

``` r
data(bra23)

# Extracting attributes from expasion.fields
names(attributes(bra23))
```

    ##  [1] "row.names"        "names"            "datalabel"        "time.stamp"      
    ##  [5] "formats"          "types"            "val.labels"       "var.labels"      
    ##  [9] "version"          "label.table"      "expansion.fields" "byteorder"       
    ## [13] "orig.dim"         "data.label"       "class"

``` r
varlabels = attr(bra23, "expansion.fields")
```

## How do I find the correct language labels?

It is important to keep in mind that note numbers may change across
countries datasets and years depending on the language the survey was
fielded. For Brazil, it is Brazilian-Portuguese, whereas in most other
countries it is in Spanish but also in English like in Jamaica.

A streamlined approach for users who want to quickly find the values of
the notes on variable labels without assigning to the dataset would be
assessing those notes directly with a combination of
[`lapply()`](https://rdrr.io/r/base/lapply.html) and
[`Filter()`](https://rdrr.io/r/base/funprog.html) functions from base R,
or also `compact()` and `map()` functions from the `purrr` package.

Both approaches extract the third element (x\[3\]) from each list in the
“expansion.fields” attribute of the dataset, but only if the first
element (x\[1\]) equals “ing4” (i.e., the variable of interest). Both
produce a semi-structured list of matching third nested elements.

``` r
# Base R approach:
# The base R version uses lapply to iterate over the list and returns NULL when 
# the condition isn't met, then Filter(Negate(is.null), ...) removes those NULLs.
head(
  Filter(Negate(is.null), lapply(attr(bra23, "expansion.fields"), 
  function(x) {
    if (x[1] == "ing4") list(note_id = x[2], note_value = x[3])})), n = 3)
```

    ## [[1]]
    ## [[1]]$note_id
    ## [1] "_lang_l_en"
    ## 
    ## [[1]]$note_value
    ## [1] "ing4_en"
    ## 
    ## 
    ## [[2]]
    ## [[2]]$note_id
    ## [1] "_lang_v_en"
    ## 
    ## [[2]]$note_value
    ## [1] "Support for democracy"
    ## 
    ## 
    ## [[3]]
    ## [[3]]$note_id
    ## [1] "note0"
    ## 
    ## [[3]]$note_value
    ## [1] "7"

``` r
# purrr package approach
#  The purrr version uses map() to do the same, and also remove NULL results. 
tail(
  purrr::map_dfr(attr(bra23, "expansion.fields"), ~ {
  if (.x[1] == "ing4") 
    data.frame(
      note_id = .x[2],
      note_value = .x[3],
      stringsAsFactors = FALSE
    )
})
)
```

    ##            note_id
    ## 9  _lang_l_default
    ## 10 _lang_v_default
    ## 11           note1
    ## 12           note2
    ## 13      _lang_v_pt
    ## 14      _lang_l_pt
    ##                                                                                                                                                       note_value
    ## 9                                                                                                                                                     labels2670
    ## 10                                                                               ING4. A democracia tem seus problemas, mas é melhor que qualquer outra forma de
    ## 11 Puede que la democracia tenga problemas, pero es mejor que cualquier otra forma de gobierno. ¿Hasta qué punto está de acuerdo o en desacuerdo con esta frase?
    ## 12                Democracy may have problems, but it is better than any other form of government.  To what extent do you agree or disagree with this statement?
    ## 13                                                                                                                                            Apoio à democracia
    ## 14                                                                                                                                                       ing4_pt

To ease the researchers and analysts job, LAPOP Lab developed custom
functions to deal with those labels in R. First, we will use
`lpr_extract_notes` to transform the nested lists from
`expansion.fields` attribute into a long dataframe format that will
contain 3 columns: `variable_name`, `note_id`, and `note_value`

``` r
# Extract AB notes with lpr function
BRA23notes <- lpr_extract_notes(bra23)
head(BRA23notes, n = 10) # columns names
```

    ##    variable_name    note_id                       note_value
    ## 1         strata _lang_l_en                        strata_en
    ## 2         strata _lang_v_en                    Survey strata
    ## 3            q1n _lang_l_en                           q1n_en
    ## 4            q1n _lang_v_en Gender determined by interviewer
    ## 5           q1tb _lang_l_en                          q1tb_en
    ## 6           q1tb _lang_v_en                           Gender
    ## 7          q1tcb _lang_l_en                         q1tcb_en
    ## 8          q1tcb _lang_v_en                           Gender
    ## 9          q1tca _lang_l_en                         q1tca_en
    ## 10         q1tca _lang_v_en                           Gender

``` r
table(BRA23notes$note_id) # note information available!
```

    ## 
    ##     _lang_l_default          _lang_l_en          _lang_l_pt     _lang_v_default 
    ##                 190                1332                1332                 202 
    ##          _lang_v_en          _lang_v_pt            destring        destring_cmd 
    ##                1321                1320                   7                   7 
    ##               note0               note1              note10              note11 
    ##                 861                 846                   7                   6 
    ##              note12              note13               note2               note3 
    ##                   1                   1                 833                 265 
    ##               note4               note5               note6               note7 
    ##                 189                 172                 134                  91 
    ##               note8               note9 spss_variable_label 
    ##                  68                  25                   3

One can assign variable labels to their preferred language as attributes
to the dataset using another LAPOP Lab function called
[`lpr_set_attr()`](https://lapop-central.github.io/lapop/reference/lpr_set_attr.md)
and than access it during data analysis without the need of an
accompanying codebook.

``` r
# English
bra23<-lpr_set_attr(bra23, BRA23notes, verbose = F,
                    noteid = "note2", 
                    attribute_name = "qwording_en") 
# Spanish
bra23<-lpr_set_attr(bra23, BRA23notes, verbose = F,
                    noteid = "note1", 
                    attribute_name = "qwording_es")

# Portuguese
bra23<-lpr_set_attr(bra23, BRA23notes, verbose = F,
                    noteid = "note3", 
                    attribute_name = "qwording_pt") 

# Printing languages
attr(bra23$ing4, "qwording_en") # English
```

    ## [1] "Democracy may have problems, but it is better than any other form of government.  To what extent do you agree or disagree with this statement?"

``` r
attr(bra23$ing4, "qwording_es") # Spanish
```

    ## [1] "Puede que la democracia tenga problemas, pero es mejor que cualquier otra forma de gobierno. ¿Hasta qué punto está de acuerdo o en desacuerdo con esta frase?"

``` r
attr(bra23$ing4, "qwording_pt") # Portuguese
```

    ## [1] "A democracia tem seus problemas, mas é melhor que qualquer outra forma de governo. Até que ponto concorda ou discorda desta frase?"

## AmericasBarometer Values Labels (Response Options)

AmericasBarometer values labels (i.e., response options) differently
from the variable labels are stored inside the “label.table” attribute.
To extract them we will use another LAPOP Lab custom function called
`lpr_format_labels` that will set up the response options as an
attribute across languages. Default language is English and default
attribute name is `roslabel` but the function allows custom attribute
names as shown below:

``` r
bra23 <- lpr_set_ros(bra23) # Default English

bra23 <- lpr_set_ros(bra23, lang_id = "es", 
                     attribute_name = "respuestas") # Spanish

bra23 <- lpr_set_ros(bra23, lang_id = "pt", 
                     attribute_name = "ROsLabels_pt") # Portuguese

# Printing ROs
attr(bra23$ing4, "roslabel") # English
```

    ## [1] "Response Options: (1) Strongly disagree (7) Strongly agree"

``` r
attr(bra23$ing4, "respuestas") # Spanish
```

    ## [1] "Opciones de Respuesta: (1) Muy en desacuerdo (7) Muy de acuerdo"

``` r
attr(bra23$ing4, "ROsLabels_pt") # Portuguese
```

    ## [1] "Alternativas de Resposta: (1) Discorda muito (7) Concorda muito"

  

## Takeaways (TLDR)

  

### Data Structure

AmericasBarometer datasets are distributed in Stata .dta format with
multilingual metadata (question wording and response options) embedded
as attributes. These support cross-national and longitudinal
comparability.

  

### Preferred Loading Method

Use the readstata13::read.dta13() function to preserve full metadata
structure. Other methods such as
[`haven::read_dta()`](https://haven.tidyverse.org/reference/read_dta.html)
or [`rio::import()`](http://gesistsa.github.io/rio/reference/import.md)
often fail to import these critical attributes.

  

### Variable Labels (Question Wording):

Stored in the “expansion.fields” attribute. Use the custom
[`lpr_extract_notes()`](https://lapop-central.github.io/lapop/reference/lpr_extract_notes.md)
function to convert this into a tidy data frame.

Assign preferred language labels to each variable with
[`lpr_set_attr()`](https://lapop-central.github.io/lapop/reference/lpr_set_attr.md)
using the appropriate noteid.

  

### Value Labels (Response Options):

Stored in the “label.table” attribute. Use
[`lpr_set_ros()`](https://lapop-central.github.io/lapop/reference/lpr_set_ros.md)
to assign these response labels as attributes in English, Spanish, or
Portuguese.

  

### Quick Access Options

For advanced users, the guide also demonstrates streamlined methods
using [`lapply()`](https://rdrr.io/r/base/lapply.html) and
[`purrr::map()`](https://purrr.tidyverse.org/reference/map.html) to
quickly view variable labels without modifying the dataset.
