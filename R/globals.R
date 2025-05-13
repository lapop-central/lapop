utils::globalVariables(
  c("wave", "prop1", "prop2", "prop1_low", "prop1_upp", "pais", "ub1", "lb1", "ub2", "lb2",
    
    "Estimate", "Pr(>|t|)", "Std. Error", "conf.high", "conf.low", 
    
    "contrast", "hl_var", "lb", "note_id", "p.value", "prop", 
    "prop2_low", "prop2_upp", "prop_low", "prop_upp", "proplabel",
    "proplabel1", "proplabel2", "pvalue", "strata", "ub", "upm",
    "vallabel", "varlabel", "varterm", "weight1500", "xvar_label",
    "year")
)

# Package startup message
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    pkgname, "Version:", utils::packageVersion(pkgname), "loaded successfully\n",
    "For documentation, run: browseVignettes('", pkgname, "') or ?", pkgname, "\n",
    "For Americasbarometer datasets, visit https://www.vanderbilt.edu/lapop/", "\n", 
    "To report issues, visit: https://github.com/lapop-central/lapop/issues"
  )
}
