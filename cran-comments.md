## Test environments

* Local: Windows 11 x64 (build 22631)
  - R version 4.4.1 (2024-06-14 ucrt)
  - Platform: x86_64-w64-mingw32
* Additional test environments:
  - GitHub Actions CI: ubuntu-latest, windows-latest, macOS-latest
  - R-hub: Windows, Fedora, Ubuntu

## R CMD check results

0 errors | 0 warnings | 0 note


Notes:
1. **Installed size is 5.0 Mb** (the guideline is ~5 MB).  
   This is due to included fonts and data objects, but is necessary for the package functionality.

2. **Unable to verify current time for future file timestamps.**  
   This is a benign note caused by the system clock check and does not affect package correctness.

## Additional comments

* This is a submission of version 2.1.0 with updated functions and examples.
* All checks pass on local and remote environments.
* There are no reverse dependencies.
* All vignettes build correctly.
* No non-CRAN dependencies are used.

Thank you for reviewing this submission!
