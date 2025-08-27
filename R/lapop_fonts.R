#######################################

# LAPOP Visualization Templates #

#######################################

#' LAPOP Fonts
#'
#' This function loads fonts needed for LAPOP graph formatting.
#' No arguments needed; just run lapop_fonts() at the beginning of your session.
#'
#'@import showtext sysfonts
#'@export
#'
#'@return No return value, called for side effects
#'@examples
#'require(lapop); lapop_fonts()
#'
#'lapop_fonts <- function(){
#'  sysfonts::font_add_google("inter", "inter")
#'  sysfonts::font_add_google("inter", family = "inter-light", regular.wt = 300)
#'  sysfonts::font_add_google("roboto", "roboto")
#'  sysfonts::font_add_google("roboto", family = "roboto-light", regular.wt = 300)
#'  sysfonts::font_add_google("nunito", "nunito")
#'  sysfonts::font_add_google("nunito", family = "nunito-light", regular.wt = 300)
#'  showtext::showtext_auto()
#'  message("LAPOP fonts loaded successfully: Inter, Roboto, and Nunito (regular and light).")
#'}
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} & Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}
