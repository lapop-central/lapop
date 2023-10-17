#######################################

# LAPOP Visualization Templates #

#######################################


#' LAPOP Fonts (design)
#'
#' This function loads fonts needed for LAPOP graph formatting.
#' No arguments needed; just run lapop_fonts_design() at the beginning of your session.
#'
#'@import sysfonts
#'@import systemfonts
#'
#'@export
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}
#'@return No return value, called for side effects
#'@examples
#'lapop_fonts_design()
#'


lapop_fonts_design <- function(showtext_end = FALSE){
  if(showtext_end == TRUE){
    showtext_end()
  }
  register_variant(
    name = "roboto-light",
    family = "roboto",
    weight = "light"
  )
  register_variant(
    name = "nunito-light",
    family = "Nunito",
    weight = "light"
  )
  sysfonts::font_add_google("nunito", "nunito")
  sysfonts::font_add_google("roboto", "roboto")
  sysfonts::font_add_google("roboto", family = "roboto-light", regular.wt = 300)
  sysfonts::font_add_google("nunito", family = "nunito-light", regular.wt = 300)
}


