-----------------------------------------------------------------------
### lapop R package
-----------------------------------------------------------------------
These are the helper functions to wrangle and produce visualizations of 
AmericasBarometer data following LAPOP Lab's editorial guidelines

### To install the package in your machine you need to run in R console
`devtools::install_github("https://github.com/lapop-central/lapop/", force=TRUE, build_vignettes = TRUE)`

-----------------------------------------------------------------------
### Workflow of AmericasBarometer data visualization using LAPOP Lab guidelines 
-----------------------------------------------------------------------

1) Load lapop package in R `library(lapop)`
2) Load `lapop_fonts()` function into console
3) Apply AmericasBarometer sampling design effect with `lpr_data()` function 
4) Choose the appropriate type of `lpr` graph to represent data. For instance, 
histograms `lpr_hist`, cross country comparison `lpr_cc`, time series `lpr_ts`, 
or break down by covariates `lpr_mover` and store it in a R object
5) Use the correspoding `lapop` ploting function to produce the visualization (e.g., `lapop_hist`, `lapop_cc`, `lapop_ts`, and so on).
6) Export the figure with `lapop_save()` to your machine.

-----------------------------------------------------------------------
### Workflow of AmericasBarometer data variables and values labels
-----------------------------------------------------------------------
Please refer to `/inst/LAPOP_Data_Guide_for_R_Users.html` for the full guide.

1) Data Structure: AmericasBarometer datasets are distributed in Stata .dta format with
multilingual metadata (question wording and response options) embedded
as attributes. These support cross-national and longitudinal
comparability.

2) Preferred Loading Method
Use the readstata13::read.dta13() function to preserve full metadata
structure. Other methods such as `haven::read_dta()` or
`rio::import()` often fail to import these critical attributes.

3) Variable Labels (Question Wording): Stored in the “expansion.fields” attribute.
Use the custom `lpr_extract_notes()` function to convert this into a tidy
data frame. Next, assign preferred language labels to each variable with
`lpr_set_attr()` using the appropriate noteid.

5) Value Labels (Response Options): Stored in the “label.table” attribute. 
Use `lpr_set_ros()` to assign these response labels as attributes
in English, Spanish, or Portuguese.

-----------------------------------------------------------------------
### Workflow to contribute to the `lapop` R package
-----------------------------------------------------------------------
1) Clone the repository to your machine
2) Add the new function to the `\R` folder
3) Add the .Rd file in the `\man` folder using `roxygen2`
4) Collate the new function in the DESCRIPTION file
-----------------------------------------------------------------------
<!-- badges: start -->
[![R-CMD-check](https://github.com/lapop-central/lapop-viz/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lapop-central/lapop-viz/actions/workflows/R-CMD-check.yaml)
[![GitHub stars](https://img.shields.io/github/stars/lapop-central/lapop.svg?style=social&label=Star&maxAge=3600)](https://github.com/lapop-central/lapop/stargazers)
[![Tweet](https://cdn.prod.website-files.com/5e0f1144930a8bc8aace526c/65dd9eb5aaca434fac4f1ca4_shields.io.svg)](https://twitter.com/intent/tweet?url=https://github.com/lapop-central/lapop&text=Check%20out%20the%20lapop%20R%20package%20for%20working%20with%20the%20AmericasBarometer%20data!%20%23rstats%20%23lapop%20%23AmericasBarometer%20%23opensource)
<!-- badges: end -->
