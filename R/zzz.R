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

.onLoad <- function(libname, pkgname) {

  rda_path <- system.file("data", "world.rda", package = pkgname)

  # Load into a private environment
  env <- new.env(parent = emptyenv())
  load(rda_path, envir = env)   # loads an object named "world"

  # Pull the sf object out
  world_sf <<- env$world        # THIS is the sf object

  invisible(TRUE)
}
