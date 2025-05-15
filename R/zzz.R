.onAttach <- function(libname, pkgname, ...){
   packageStartupMessage(lapopWelcomeMessage())
}

# Package startup message
lapopWelcomeMessage <- function(){   
   paste("\n",     
    pkgname, "R package. Version:", utils::packageVersion(pkgname), "loaded successfully\n",
    "For documentation, run: browseVignettes('", pkgname, "') or ?", pkgname, "\n",
    "For Americasbarometer datasets, please visit https://www.vanderbilt.edu/lapop/", "\n", 
    "To report issues or suggestions, please visit: https://github.com/lapop-central/lapop/issues", "\n",               
    "Contact: <robert.vidigal@vanderbilt.edu>\n", sep="")
}
