#######################################

# LAPOP Cross-Country Bar Graphs #

#######################################

#' @include lapop_fonts.R
NULL

#' LAPOP Cross-Country Bar Graphs
#'
#' This function creates bar graphs for comparing values across countries using LAPOP formatting.
#'
#' @param data Data Frame. Dataset to be used for analysis.  The data frame should have columns
#' titled vallabel (values of x-axis variable (e.g. pais); character vector), prop (outcome variable; numeric),
#' proplabel (text of outcome variable; character), lb (lower bound of estimate; numeric),
#' and ub (upper bound of estimate; numeric). Default: None (must be supplied).
#' @param vallabel,outcome_var,label_var,lower_bound,upper_bound Character, numeric, character,
#' numeric, numeric. Each component of the plot data can be manually specified in case
#' the default columns in the data frame should not be used (if, for example, the values for a given
#' variable were altered and stored in a new column). x
#' @param ymin,ymax Numeric.  Minimum and maximum values for y-axis. Default: 0 to 100.
#' @param highlight Character.  Country of interest.  Will highlight (make darker) that country's bar.
#' Input must match entry in "vallabel" exactly. Default: None.
#' @param sort Character. Method of sorting bars.  Options: "hi-lo" (highest to lowest y value), "lo-hi" (lowest to highest),
#' "alpha" (alphabetical by vallabel/x-axis label). Default: Order of data frame.
#' @param main_title Character.  Title of graph.  Default: None.
#' @param source_info Character.  Information on dataset used (country, years, version, etc.),
#' which is added to the bottom-left corner of the graph. Default: LAPOP ("Source: LAPOP Lab" will be printed).
#' @param subtitle Character.  Describes the values/data shown in the graph, e.g., "percentage of Mexicans who say...)".
#' Default: None.
#' @param lang Character.  Changes default subtitle text and source info to either Spanish or English.
#' Will not translate input text, such as main title or variable labels.  Takes either "en" (English)
#' or "es" (Spanish).  Default: "en".
#' @param color_scheme Character.  Color of bars.  Takes hex number, beginning with "#".
#' Default: #784885.
#' @param label_size Numeric.  Size of text for data labels (percentages above bars).  Default: 5.
#' @param max_countries Numeric. Threshold for automatic x-axis label rotation. When the number of unique
#' country labels exceeds this value, labels will be rotated for better readability. Default: 20.
#' @param label_angle Numeric. Angle (in degrees) to rotate x-axis labels when max_countries is exceeded. Default: 0.
#'
#' @return Returns an object of class \code{ggplot}, a ggplot figure showing
#' average values of some variables across multiple countries.
#'
#' @examples
#'\donttest{
#' require(lapop); lapop_fonts()
#'
#' df <- data.frame(
#' vallabel = c("PE", "CO", "BR", "PN", "GT", "DO", "MX", "BO", "EC"),
#' prop      = c(36.1, 19.3, 16.6, 13.3, 13.0, 11.1,  9.5,  9.0,  8.1),
#' proplabel = c("36%" ,"19%" ,"17%" ,"13%" ,"13%" ,"11%" ,"10%", "9%", "8%"),
#' lb        = c(34.9, 18.1, 15.4, 12.1, 11.8,  9.9,  8.3,  7.8,  6.9),
#' ub        = c(37.3, 20.5, 17.8, 14.5, 14.2, 12.3, 10.7, 10.2,  9.3)
#' )
#' lapop_cc(df,
#'          main_title = "Normalization of Intimate Partner Violence in LAC Countries",
#'          subtitle = "% who say domestic violence is private matter",
#'          source_info = "LAPOP Lab, AmericasBarometer 2021",
#'          highlight = "PE",
#'          ymax = 50)
#'}
#'@export
#'@import ggplot2
#'@import ggtext
#'@import sysfonts
#'@import showtext
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} & Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}

lapop_cc <- function(data, outcome_var = data$prop, lower_bound = data$lb, vallabel = data$vallabel,
                     upper_bound = data$ub, label_var = data$proplabel,
                     ymin = 0,
                     ymax = 100,
                     lang = "en",
                     highlight = "",
                     main_title = "",
                     source_info = "LAPOP",
                     subtitle = "",
                     sort = "",
                     color_scheme = "#784885",
                     label_size = 5,  # Default size
                     max_countries = 30,
                     label_angle = 0) {  # Removed label_adjust

  # Check if we need to rotate labels based on number of unique countries
  rotate_labels <- length(unique(data$vallabel)) > max_countries
  # Adjust label size if rotation is needed
  current_label_size <- ifelse(rotate_labels, (label_size * 0.5), label_size)


  if(all(highlight != "")){
    data$hl_var = factor(ifelse(vallabel %in% highlight, 0, 1), labels = c("hl", "other"))
    fill_values = c(paste0(color_scheme, "47"), paste0(color_scheme, "20"))
  }
  else{
    data$hl_var = factor("other")
    fill_values = paste0(color_scheme, "47")
  }

  if(sort == "hi-lo"){
    data = data[order(-data$prop),]
  } else if(sort == "lo-hi"){
    data = data[order(data$prop),]
  } else if(sort == "alpha"){
    data = data[order(data$vallabel),]
  }

  ci_text = ifelse(lang == "es",
                   paste0(" <span style='color:", color_scheme, "; font-size:18pt'> \u0131\u2014\u0131</span> ",
                          "<span style='color:#585860; font-size:13pt'>95% intervalo de confianza </span>"),
                   ifelse(lang == "fr",
                          paste0(" <span style='color:", color_scheme, "; font-size:18pt'> \u0131\u2014\u0131</span> ",
                                 "<span style='color:#585860; font-size:13pt'>Intervalle de confiance de 95% </span>"),
                          paste0(" <span style='color:", color_scheme, "; font-size:18pt'> \u0131\u2014\u0131</span> ",
                                 "<span style='color:#585860; font-size:13pt'>95% confidence </span>",
                                 "<span style='color:#585860'>interval</span>")))

  update_geom_defaults("text", list(family = "roboto"))

  # Create base plot
   cc <- ggplot(data=data, aes(x=factor(vallabel, levels = vallabel), y=prop, fill = hl_var)) +
    geom_bar(stat="identity", color = color_scheme, width = 0.6) +
    geom_text(aes(label=label_var, y = upper_bound), vjust= -0.5,
              size=current_label_size, fontface = "bold", color = color_scheme) +
    geom_errorbar(aes(ymin=lower_bound, ymax=upper_bound), width = 0.15, color = color_scheme, linetype = "solid") +
    scale_fill_manual(breaks = "other",
                      values = fill_values,
                      labels = paste0(" <span style='color:#585860; font-size:13pt'> ",
                                      subtitle,
                                      "<span style='color:#FFFFFF00'>-----------</span>",
                                      ci_text),
                      na.value = paste0(color_scheme, "90")) +
    scale_y_continuous(limits = c(ymin, ymax), expand = expansion(mult = 0.002)) +
    labs(title=main_title,
         y = "",
         x = "",
         caption = paste0(ifelse(lang == "es" & source_info == "LAPOP", "Fuente: LAPOP Lab",
                                 ifelse(lang == "en" & source_info == "LAPOP", "Source: LAPOP Lab",
                                        source_info)))) +
    theme(text = element_text(size = 14, family = "roboto"),
          plot.title = element_text(size = 18, family = "nunito", face = "bold"),
          plot.caption = element_text(size = 10.5, vjust = 2, hjust = 0, family = "nunito", color="#585860"),
          panel.background = element_blank(),
          panel.border = element_blank(),
          axis.line.x = element_line(linewidth = 0.6, linetype = "solid", colour = "#dddddf"),
          axis.text = element_text(size = ifelse(rotate_labels, 10, 14), color = "#585860", face = "bold"),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "top",
          legend.title = element_blank(),
          legend.justification='left',
          legend.margin = margin(t=0, b=0, l=0, r=0),
          legend.text = element_markdown(family = "nunito-light"))

  # Apply label rotation if needed
  if(rotate_labels) {
   cc <- cc + theme(axis.text.x = element_text(angle = label_angle,
                                              hjust = 0.5, vjust = 1))

    # Adjust plot margins to accommodate rotated labels
     cc <-  cc + theme(plot.margin = margin(t = 10, r = 10, b = max(10, current_label_size*5), l = 10))
  }

  return(cc)
}
