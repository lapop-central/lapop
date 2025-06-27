# lapop R package

These are helper functions to wrangle labels and produce visualizations of AmericasBarometer data following LAPOP Lab's editorial guidelines.

🔗 **Package website:** [https://lapop-central.github.io/lapop/](https://lapop-central.github.io/lapop/)

---

## 🛠️ Installation

To install the package in your R console, run:

```r
devtools::install_github("lapop-central/lapop", 
                         force = TRUE, 
                         build_vignettes = TRUE)
```

---

## 🎨 Workflow: AmericasBarometer Data Visualization

1. Load the package in R:

   ```r
   library(lapop)
   ```

2. Load LAPOP Lab fonts:

   ```r
   lapop_fonts()
   ```

3. Apply the AmericasBarometer sampling design with:

   ```r
   lpr_data()
   ```

4. Choose the appropriate `lpr` graph type:
   - Histograms: `lpr_hist()`
   - Cross-country comparison: `lpr_cc()`
   - Time series: `lpr_ts()`
   - Breakdown by covariates: `lpr_mover()`

5. Store the output in an R object.
   - File names: .csv and graphics files should have the same name. Their names should be in the following standard format: CountryYear/ts_DVcode(s)_IVcode(s)_graphtype.filetype.
   - Examples:
      
      - mex21_countfair1_hist.csv
      - hndts_b4_ts.svg
      - ab23_vic1ext_pais_cc.png
   - There will be some cases that do not easily fit this standard. Use your best judgment.

7. Use the corresponding `lapop` plotting function to produce the visualization:
   - Examples: `lapop_hist()`, `lapop_cc()`, `lapop_ts()`, etc.

8. Export the figure to your machine with:

   ```r
   lapop_save()
   ```

---

## ⚙️ Workflow: AmericasBarometer Variable & Value Labels

For the full online guide, see:

<a href="https://lapop-central.github.io/lapop/articles/lapop-r-labels.html" target="_blank">📖 LAPOP Data Guide for R Users (pkgdown article)</a>

### 1. Data Structure

AmericasBarometer datasets are distributed in Stata `.dta` format with multilingual metadata (question wording and response options) embedded as attributes. These support cross-national and longitudinal comparability.

### 2. Preferred Loading Method

Use:

```r
readstata13::read.dta13()
```

to preserve the full metadata structure.

Other methods such as `haven::read_dta()` or `rio::import()` may fail to import these critical attributes.

### 3. Variable Labels (Question Wording)

- Stored in the `expansion.fields` attribute.
- Use `lpr_extract_notes()` to convert into a tidy data frame.
- Assign preferred language labels with `lpr_set_attr()` using the appropriate `noteid`.

### 4. Value Labels (Response Options)

- Stored in the `label.table` attribute.
- Use `lpr_set_ros()` to assign these response labels in English, Spanish, or Portuguese.

---

## 🤝 Workflow: Contributing to the `lapop` R Package

1. Clone the repository to your machine.
2. Add the new function to the `R/` folder.
3. Document the function with `roxygen2` to create the `.Rd` file in `man/`.
4. Add the new function to the `Collate` field in the `DESCRIPTION` file.

---
<!-- badges: start -->
[![R-CMD-check](https://github.com/lapop-central/lapop-viz/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lapop-central/lapop-viz/actions/workflows/R-CMD-check.yaml)
[![GitHub stars](https://img.shields.io/github/stars/lapop-central/lapop.svg?style=social&label=Star&maxAge=3600)](https://github.com/lapop-central/lapop/stargazers)
[![Tweet](https://cdn.prod.website-files.com/5e0f1144930a8bc8aace526c/65dd9eb5aaca434fac4f1ca4_shields.io.svg)](https://twitter.com/intent/tweet?url=https://github.com/lapop-central/lapop&text=Check%20out%20the%20lapop%20R%20package%20for%20working%20with%20the%20AmericasBarometer%20data!%20%23rstats%20%23lapop%20%23AmericasBarometer%20%23opensource)
<!-- badges: end -->
