world_sf <- NULL

.lapop_try_autoload_fonts <- function(pkg) {
   tryCatch(
      {
         .lapop_register_fonts(pkg = pkg)
         showtext::showtext_auto(enable = TRUE)
         TRUE
      },
      error = function(e) FALSE
   )
}

.onAttach <- function(lib, pkg, ...){
   .lapop_try_autoload_fonts(pkg)
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
  if (identical(rda_path, "")) {
    stop("The bundled `world.rda` file could not be found.")
  }

  # Load into a private environment
  env <- new.env(parent = emptyenv())
  load(rda_path, envir = env)   # loads an object named "world"

  # Store the sf object in the package namespace without polluting the global env.
  assign("world_sf", env$world, envir = asNamespace(pkgname))

  invisible(TRUE)
}
