# # -----------------------------------------------------------------------
### lapop R package
# # -----------------------------------------------------------------------
# Authors: Luke Plutowski, Ph.D. & Robert Vidigal, Ph.D. (maintaner)
# These are the helper functions to wrangle and produce visualizations of 
# AmericasBarometer data following LAPOP Lab's editorial guidelines

# To install the package in your machine you need to run in R console
`devtools::install_github("https://https://github.com/lapop-central/lapop/")`

# # -----------------------------------------------------------------------
### The workflow of visualizations using LAPOP Lab guidelines is as follow
# # -----------------------------------------------------------------------
1) Load lapop package in R `library(lapop)`
2) Load `lapop_fonts()` function into console
3) Load AmericasBarometer data with `lpr_data()` function 
4) Choose the appropriate type of `lpr` graph to represent data. For instance, 
histograms `lpr_hist`, cross country comparison `lpr_cc`, time series `lpr_ts`, 
or break down by covariates `lpr_mover` and store it in a R object
5) Use the correspoding `lapop` ploting function to produce the visualization
6) You can also export the figure object using `lapop_save()`

### The workflow to contribute to the lapop R package project is as follows
# # -----------------------------------------------------------------------
1) Clone the repository to your machine
2) Add the new function to the `\R` folder
3) Add the .Rd file in the `\man` folder using `roxygen2`
4) Collate the new function in the DESCRIPTION file
5) Commit and push to GitHub

<!-- badges: start -->
[![R-CMD-check](https://github.com/lapop-central/lapop-viz/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lapop-central/lapop-viz/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->
