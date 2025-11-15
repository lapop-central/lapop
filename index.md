# lapop R package

These are helper functions to wrangle labels and produce visualizations
of ‘AmericasBarometer’ data following LAPOP Lab’s editorial guidelines.

🔗 **Package website:** <https://lapop-central.github.io/lapop/>

------------------------------------------------------------------------

## 🛠️ Installation

To install the package in your console, run:

``` r
devtools::install_github("lapop-central/lapop", 
                         force = TRUE, 
                         build_vignettes = TRUE)
```

------------------------------------------------------------------------

## ⚙️ Workflow: ‘AmericasBarometer’ Variable & Value Labels

For the full online guide, see:

[📖 LAPOP Data Guide for R
Users](https://lapop-central.github.io/lapop/articles/lapop-r-labels.html)

### 1. Data Structure

‘AmericasBarometer’ datasets are distributed in Stata `.dta` format with
multilingual metadata (question wording and response options) embedded
as attributes. These support cross-national and longitudinal
comparability.

### 2. Preferred Loading Method

Use:

``` r
readstata13::read.dta13()
```

to preserve the full metadata structure.

Other methods such as
[`haven::read_dta()`](https://haven.tidyverse.org/reference/read_dta.html)
or [`rio::import()`](http://gesistsa.github.io/rio/reference/import.md)
may fail to import the STATA attributes.

### 3. Variable Labels (Question Wording)

- Stored in the `expansion.fields` attribute.
- Use
  [`lpr_extract_notes()`](https://lapop-central.github.io/lapop/reference/lpr_extract_notes.md)
  to convert into a tidy data frame.
- Assign preferred language labels with
  [`lpr_set_attr()`](https://lapop-central.github.io/lapop/reference/lpr_set_attr.md)
  using the appropriate `noteid`.

### 4. Value Labels (Response Options)

- Stored in the `label.table` attribute.
- Use
  [`lpr_set_ros()`](https://lapop-central.github.io/lapop/reference/lpr_set_ros.md)
  to assign these response labels in English, Spanish, or Portuguese.

------------------------------------------------------------------------

## 🎨 Workflow: ‘AmericasBarometer’ Data Visualization

[📖 LAPOP Visualization
Guide](https://lapop-central.github.io/lapop/articles/lapop-visualization.html)

1.  Load the package in R:

    ``` r
    library(lapop)
    ```

2.  Load LAPOP Lab fonts:

    ``` r
    lapop_fonts()
    ```

3.  Apply the ‘AmericasBarometer’ design effects with:

    ``` r
    lpr_data()
    ```

4.  Choose the appropriate `lpr` graph type:

    - Histograms:
      [`lpr_hist()`](https://lapop-central.github.io/lapop/reference/lpr_hist.md)
    - Cross-country comparison:
      [`lpr_cc()`](https://lapop-central.github.io/lapop/reference/lpr_cc.md)
    - Time series:
      [`lpr_ts()`](https://lapop-central.github.io/lapop/reference/lpr_ts.md)
    - Breakdown by covariates:
      [`lpr_mover()`](https://lapop-central.github.io/lapop/reference/lpr_mover.md)

&nbsp;

5.  Store the output in an R object.

    - File names: .csv and graphics files should have the same name.
      Their names should be in the following standard format:
      CountryYear/ts_DVcode(s)\_IVcode(s)\_graphtype.extension.

    - Examples:

      - mex21_countfair1_hist.csv
      - hnd_b4_ts.svg
      - ab23_vic1ext_pais_cc.svg

    - There will be some cases that do not easily fit this standard. Use
      your best judgment.

6.  Use the corresponding `lapop` plotting function to produce the
    visualization:

    - Examples:
      [`lapop_hist()`](https://lapop-central.github.io/lapop/reference/lapop_hist.md),
      [`lapop_cc()`](https://lapop-central.github.io/lapop/reference/lapop_cc.md),
      [`lapop_ts()`](https://lapop-central.github.io/lapop/reference/lapop_ts.md),
      etc.

&nbsp;

7.  Export the figure to your machine with:
    ``` r
    lapop_save()
    ```

    ------------------------------------------------------------------------

## 🤝 Workflow: Contributing to the `lapop` R Package

1.  **Fork** the repository and clone it to your local machine.
2.  **Create a new branch** for your feature or fix.
3.  Add your new function in the `R/` folder.
4.  Document the function with roxygen2 comments.
5.  Run `devtools::document()` to generate `.Rd` files in `man/` and
    update `NAMESPACE`.
6.  Commit your changes and push the branch to your fork.
7.  Submit a **pull request** to the main repository.
8.  If you find a bug, please consider contributing to the lapop package
    — we spent all our money on coffee and data cleaning.

------------------------------------------------------------------------
