.onAttach <- function(lib, pkg, ...){
   packageStartupMessage(lapopWelcomeMessage(pkg))
}

# Package startup message
lapopWelcomeMessage <- function(pkg){
   paste("\n",
    "LAPOP Lab R package. Version: ", utils::packageVersion(pkg), " loaded successfully\n",
    "For Americasbarometer datasets, please visit https://www.vanderbilt.edu/lapop/", "\n\n",
    "For documentation and vignettes, run: browseVignettes('lapop') or ?lapop", "\n",
    "To report issues or suggestions, please visit: https://github.com/lapop-central/lapop/issues", "\n",
    "Contact: <robert.vidigal@vanderbilt.edu>\n", sep="")
}
