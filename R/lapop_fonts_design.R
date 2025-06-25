#######################################

# LAPOP Visualization Templates #

#######################################


#' LAPOP Fonts (design)
#'
#' This function loads fonts needed for LAPOP graph formatting.  In contrast to lapop_fonts(),
#' this renders text as text instead of polygons, which allows post-hoc editing.
#'
#'@import sysfonts
#'@import systemfonts
#'
#'@export
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}
#'@return No return value, called for side effects
#'@examples
#'\dontrun{lapop_fonts_design()}
#'

lapop_fonts_design <- function(){
  showtext::showtext_auto(enable = FALSE)
  systemfonts::register_variant(
    name = "roboto-light",
    family = "roboto",
    weight = "light"
  )
  systemfonts::register_variant(
    name = "nunito-light",
    family = "nunito",
    weight = "light"
  )
}
