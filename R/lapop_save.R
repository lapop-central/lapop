#######################################

# LAPOP Save #

#######################################

#' LAPOP Save
#'
#' This function creates exports graphs created using the LAPOP templates.
#'
#' @param figure Ggplot object.
#' @param filename File path + name to be saved + .filetype.
#' @param format Character.  Options: "png", "svg". Default = "svg".
#' @param logo Logical.  Should logo be added to plot?  Default: FALSE.
#' @param width_px Numeric. Width in pixels.  Default: 750.
#' @param height_px Numeric.  Height in pixels.
#'
#' @return Saves a file (in either .svg or .png format) to provided directory.
#'
#' @examples
#' \dontrun{df <- data.frame(
#'cat = c("Far Left", 1, 2, 3, 4, "Center", 6, 7, 8, 9, "Far Right"),
#'prop = c(4, 3, 5, 12, 17, 23, 15, 11, 5, 4, 1),
#'proplabel = c("4%", "3%", "5%", "12%", "17%", "23%", "15%", "11%", "5%", "4%", "1%")
#')
#' myfigure <- lapop_hist(df,
#'           main_title = "Centrists are a plurality among Peruvians",
#'           subtitle = "Distribution of ideological preferences",
#'           source_info = "Peru, 2019",
#'           ymax = 27
#')
#'
#' f <- file.path(tempdir(), "fig1.svg")
#' lapop_save(myfigure, f, format = "svg", width_px = 800)
#'}
#'@import grDevices
#'@import ggplot2
#'@importFrom svglite svglite
#'@export
#'

lapop_save <- function(figure, filename,
                       format = "svg",
                       logo = FALSE,
                       width_px = 895,
                       height_px = 500){
  dev.new()
  if(format == "svg"){
    ggsave(filename, width = width_px/96, height = height_px/96, device = svglite)
  } else if(format == "png"){
    png(filename, width = width_px/96, height = height_px/96)
  }
  print(figure)
  dev.off()
}
