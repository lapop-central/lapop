.onAttach <- function(lib, pkg, ...){
   packageStartupMessage(lapopWelcomeMessage())
}

# Package startup message
lapopWelcomeMessage <- function(){   
   paste("\n",     
    "LAPOP Lab R package. Version:", utils::packageVersion(pkg), "loaded successfully\n",
    "For documentation, run: browseVignettes('lapop') or ?lapop", "\n",
    "For Americasbarometer datasets, please visit https://www.vanderbilt.edu/lapop/", "\n", 
    "To report issues or suggestions, please visit: https://github.com/lapop-central/lapop/issues", "\n",               
    "Contact: <robert.vidigal@vanderbilt.edu>\n", sep="")
}
