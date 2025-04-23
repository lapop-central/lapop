#######################################

# LAPOP Multiple-Over/Breakdown Graph #

#######################################

#' @rdname lapop-deprecated
#' @section \code{lapop_demog}:
#' For \code{lapop_demog}, use \code{\link{lapop_mover}}.
#'
#' @export


lapop_demog <- function(data,
                        lang = "en",
                        main_title = "",
                        subtitle = "",
                        source_info = "",
                        rev_values = FALSE,
                        rev_variables = FALSE,
                        subtitle_h_just = 0,
                        ymin = 0,
                        ymax = 100,
                        x_lab_angle = 90,
                        color_scheme = c("#7030A0", "#00ADA9", "#3CBC70", "#7EA03E", "#568424", "#ACB014")){
  .Deprecated("lapop_mover")
  lapop_mover(data = data,
  lang = lang,
  main_title = main_title,
  subtitle = subtitle,
  source_info = source_info,
  rev_values = rev_values,
  rev_variables = rev_variables,
  subtitle_h_just = subtitle_h_just,
  ymin = ymin,
  ymax = ymax,
  x_lab_angle = x_lab_angle,
  color_scheme = color_scheme)
}




#' @include lapop_fonts.R
NULL

#' LAPOP Multiple-Over/Breakdown Graphs
#'
#' This function shows the values of an outcome variable for subgroups of a secondary variable, using LAPOP formatting.
#'
#' @param data Data Frame. Dataset to be used for analysis.  The data frame should have columns
#' titled varlabel (name(s)/label(s) of secondary variable(s); character), vallabel (names/labels of values for secondary variable; character),
#' prop (outcome variable value; numeric), proplabel (text of outcome variable value; character),
#' lb (lower bound of estimate; numeric), and ub (upper bound of estimate; numeric).
#' Default: None (must be provided).
#' @param ymin,ymax Numeric.  Minimum and maximum values for y-axis. Defaults: 0 and 100.
#' @param main_title Character.  Title of graph.  Default: None.
#' @param source_info Character.  Information on dataset used (country, years, version, etc.),
#' which is added to the end of "Source: " in the bottom-left corner of the graph.
#' Default: None (only "Source: " will be printed).
#' @param subtitle Character.  Describes the values/data shown in the graph, e.g., "Percent who agree that...".
#' Default: None.
#' @param lang Character.  Changes default subtitle text and source info to either Spanish or English.
#' Will not translate input text, such as main title or variable labels.  Takes either "en" (English)
#' or "es" (Spanish).  Default: "en".
#' @param color_scheme Character.  Color of data points and text for each secondary variable.  Allows up to 6 values.
#' Takes hex numbers, beginning with "#".
#' Default: c("#784885", "#008381", "#c74e49", "#2d708e", "#a43d6a")
#' (purple, teal, green, olive, sap green, pea soup).
#' @param subtitle_h_just Numeric.  Move the subtitle/legend text left (negative numbers) or right (positive numbers).
#' Ranges from -100 to 100.  Default: 0.
#' @param x_lab_angle Numeric.  Angle/orientation of the value labels.  Default: 90.
#' @param rev_variables Logical.  Should the order of the variables be reversed?  Default: FALSE.
#' @param rev_values Logical.  Should the order of the values for each variable be reversed?  Default: FALSE.
#' @return Returns an object of class \code{ggplot}, a ggplot figure showing
#' average values of some variable broken down by one or more secondary variables
#' (commonly, demographic variables).
#'
#' @examples
#'
#' df <- data.frame(varlabel = c(rep("Gender", 2), rep("Age", 6),
#'                               rep("Education", 4), rep("Wealth", 5)),
#'                  vallabel = c("Women", "Men", "18-25", "26-35", "36-45",
#'                               "46-55", "56-65", "66+", "  None", "Primary",
#'                               "Secondary", "Post-Sec.", "Low", "2",
#'                               "3", "4", "High"),
#'                  prop = c(20, 22, 21, 24, 22, 21, 17, 15, 20, 18, 21, 25, 21,
#'                           21, 21, 21, 22),
#'                  proplabel = c("20%", "22%", "21%", "24%", "22%", "21%",
#'                                "17%", "15%", "20%", "18%", "21%", "25%",
#'                                "21%", "21%", "21%", "21%", "22%"),
#'                  lb = c(19, 21, 20, 23, 21, 20, 15, 13, 16, 17, 20, 24, 20,
#'                         20, 20, 20, 21),
#'                  ub = c(21, 23, 22, 25, 23, 22, 19, 17, 24, 19, 22, 26, 22,
#'                         22, 22, 22, 23))
#'
#' lapop_mover(df,
#'             main_title = paste0("More educated, men, and younger individuals",
#'                                 " in the LAC region are the\nmost likely",
#'                                   " to be crime victims"),
#'             subtitle = "% victim of a crime",
#'             ymin = 0,
#'             ymax = 40)
#'
#'@export
#'@import ggplot2
#'@importFrom ggh4x facet_grid2
#'@importFrom ggh4x strip_themed
#'@importFrom ggtext element_markdown
#'@importFrom stats setNames
#'@import showtext
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}
#'




lapop_mover <- function(data,
                         lang = "en",
                         main_title = "",
                         subtitle = "",
                         source_info = "",
                         rev_values = FALSE,
                         rev_variables = FALSE,
                         subtitle_h_just = 0,
                         ymin = 0,
                         ymax = 100,
                         x_lab_angle = 90,
                         color_scheme = c("#784885", "#008381", "#c74e49", "#2d708e", "#a43d6a")){
  data$varlabel = factor(data$varlabel, levels = unique(data$varlabel))
  data$order = 1:nrow(data)
  data$order = factor(data$order, levels = unique(data$order))
  mycolors = color_scheme[seq_along(unique(data$varlabel))]
  ci_text = ifelse(lang == "es",
                   paste0(" <span style='color:#585860; font-size:18pt'>\u0131\u2014\u0131 </span>",
                          "<span style='color:#585860; font-size:13pt'>95% intervalo de confianza </span>"),
                   ifelse(lang == "fr",
                          paste0(" <span style='color:#585860; font-size:18pt'>\u0131\u2014\u0131 </span>",
                                 "<span style='color:#585860; font-size:13pt'>Intervalle de confiance de 95% </span>"),
                          paste0(" <span style='color:#585860; font-size:18pt'> \u0131\u2014\u0131 </span> ",
                                 "<span style='color:#585860; font-size:13pt'>95% confidence interval</span>")))
  update_geom_defaults("text", list(family = "roboto"))
  ggplot(data, aes(x = order, y = prop, color = factor(varlabel), label = proplabel)) +
    geom_point(alpha=0.47, key_glyph = "point") +
    ggh4x::facet_grid2(cols = vars(varlabel),
                scales = "free",
                space = "free",
                axes = "all",
                strip = strip_themed(
                  text_x = list(element_text(color = mycolors[1]),
                                element_text(color = mycolors[2]),
                                element_text(color = mycolors[3]),
                                element_text(color = mycolors[4]),
                                element_text(color = mycolors[5]))
                )) +
    geom_errorbar(aes(ymin=lb, ymax=ub), width = 0.2, show.legend = FALSE) +
    geom_text(aes(y = ub), fontface = "bold", size = 5, vjust = -0.8, show.legend = FALSE) +
    scale_color_manual(values = mycolors,
                       labels = paste0("<span style='color:#585860; font-size:13pt'> ",
                                       subtitle,
                                       "<span style='color:#FFFFFF00'>-----------</span>",
                                       ci_text),
                       guide = guide_legend(override.aes = list(shape = 16,
                                                                color = c("black", rep("white", length(unique(data$varlabel)) -1)),
                                                                fill = c("black", rep("white", length(unique(data$varlabel)) -1))))) +
    scale_y_continuous(limits = c(ymin, ymax),
                       breaks = seq(ymin, ymax, ifelse(ymax - ymin <= 50, 5, 10)),
                       expand = c(0,0)) +
   scale_x_discrete(labels = setNames(
        stringr::str_wrap(data$vallabel, width = 3),  data$order),
        expand = expansion(add = 0.5)) +
    geom_vline(xintercept = seq(0.5, length(data$vallabel), by = 1), color="#dddddf", size = 0.5) +
    labs(title = main_title,
         y = "",
         x = " ",
         caption = paste0(ifelse(lang == "es", "Fuente: LAPOP Lab", "Source: LAPOP Lab"),
                          source_info)) +
    theme(text = element_text(size = 14, family = "roboto"),
          plot.title = element_text(size = 17, family = "nunito", face = "bold"),
          plot.caption = element_text(size = 10.5, hjust = 0, vjust = 2, family = "nunito", color="#585860"),
          plot.subtitle = element_text(size = 14, family = "nunito", color="#585860"),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(size=.5, color="#dddddf"),
          panel.background = element_rect(fill = "white"),
          panel.border = element_rect(linetype = "solid", color = "#dddddf", fill = NA, linewidth = 1),
          axis.text.y = element_blank(),
          axis.text.x = element_text(angle = x_lab_angle, vjust = 0.5),
          axis.ticks = element_blank(),
          axis.text = element_text(size = 14, family = "roboto", color = "#585860"),
          legend.position = "top",
          legend.title = element_blank(),
          legend.justification='left',
          legend.margin=margin(0, 0, -5, 0-subtitle_h_just),
          legend.text=element_markdown(family = "nunito-light"),
          legend.key=element_blank(),
          strip.text = element_text(size = 14),
          strip.background = element_blank()
    )
}
