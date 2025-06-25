#######################################

# LAPOP Regression Coefficient Graphs #

#######################################

#' @include lapop_fonts.R
NULL
#'
#' LAPOP Regression Graphs
#'
#' This function creates plots of regression coefficients and predicted probabilities using LAPOP formatting.
#'
#' @param data Data Frame. Dataset to be used for analysis.  The data frame should have columns
#' titled coef (regression coefficients/predicted probabilities; numeric), proplabel (text of outcome variable; character),
#' varlabel (names of variables to be plotted; character), lb (lower bound of coefficient estimate; numeric),
#' ub (upper bound of estimate; numeric), and pvalue (p value of coefficient estimate; numeric).
#'  Default: None (must be supplied).
#' @param coef_var,label_var,varlabel_var,lb,ub,pval_var Numeric, character, character, numeric,
#' numeric, numeric. Each component of the data to be plotted can be manually specified in case
#' the default columns in the data frame should not be used (if, for example, the values for a given
#' variable were altered and stored in a new column).
#' @param ymin,ymax Numeric.  Minimum and maximum values for y-axis. Default: dynamic.
#' @param main_title Character.  Title of graph.  Default: None.
#' @param source_info Character.  Information on dataset used (country, years, version, etc.),
#' which is added to the end of "Source: " in the bottom-left corner of the graph.
#' Default: None (only "Source: " will be printed).
#' @param subtitle Character.  Describes the values/data shown in the graph, e.g., "Regression coefficients".
#' Default: None.
#' @param lang Character.  Changes default subtitle text and source info to either Spanish or English.
#' Will not translate input text, such as main title or variable labels.  Takes either "en" (English)
#' or "es" (Spanish).  Default: "en".
#' @param color_scheme Character.  Color of bars.  Takes hex number, beginning with "#".
#' Default: "#784885" (purple).
#' @param pred_prob Logical.  Is the graph showing predicted probabilities (instead of regression coefficients)?
#' Will only change text in the legend, not the data.  Default: FALSE.
#' @param subtitle_h_just Numeric.  Move the subtitle/legend text left (negative numbers) or right (positive numbers).
#' Ranges from -100 to 100.  Default: 0.
#' @return Returns an object of class \code{ggplot}, a ggplot figure showing
#' coefficients or predicted probabilities from a multivariate regression.
#'
#' @examples
#'
#' \dontrun{df <- data.frame(
#'   varlabel = c("Intimate\nPartner", "wealth", "Education", "Age", "Male"),
#'   coef = c(0.02, -0.07, -0.24, 0.01, 0.11),
#'   lb = c(-0.002, -0.110, -0.295, -0.060, 0.085),
#'   ub = c(0.049, -0.031, -0.187, 0.080, 0.135),
#'   pvalue = c(0.075, 0.000, 0.000, 0.784, 0.000),
#'   proplabel = c("0.02", "-0.07", "-0.24", "0.01", "0.11")
#' )
#'
#' lapop_coef(df,
#'            main_title = "Demographic and Socioeconomic Predictors of Normalizing IPV",
#'            pred_prob = TRUE,
#'            source_info = "2021",
#'            ymin = -0.3,
#'            ymax = 0.2)}
#'
#'@export
#'@import ggplot2
#'@import ggtext
#'@import showtext
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}
#'

lapop_coef <- function(data, coef_var = data$coef, label_var = data$proplabel,
                       varlabel_var = data$varlabel, lb = data$lb, ub = data$ub,
                       pval_var = data$pvalue,
                       lang = "en",
                       main_title = "",
                       subtitle = "",
                       source_info = "",
                       ymin = NULL,
                       ymax = NULL,
                       pred_prob = FALSE,
                       color_scheme = "#784885",
                       subtitle_h_just = 0){
  varlabel_var = factor(varlabel_var, levels = rev(unique(varlabel_var)))
  sig = ifelse(pval_var < 0.05, FALSE, TRUE)
  ci_text = ifelse(lang == "es",
                   paste0(" <span style='color:", color_scheme, "; font-size:18pt'> \u0131\u2014\u0131</span> ",
                          "<span style='color:#585860; font-size:13pt'>95% intervalo de confianza </span>"),
                   paste0(" <span style='color:", color_scheme, "; font-size:18pt'> \u0131\u2014\u0131</span> ",
                          "<span style='color:#585860; font-size:13pt'>95% confidence </span>",
                          "<span style='color:#585860'>interval</span>"))
  update_geom_defaults("text", list(family = "roboto"))
  ggplot(data, aes(x = varlabel_var, y = coef_var)) +
    geom_hline(yintercept = 0, color = "#dddddf", lty = 2) +
    geom_errorbar(aes(x=varlabel_var, ymin = lb, ymax = ub), width = 0.3, lty = 1, color = color_scheme) +
    geom_point(aes(x = varlabel_var, y = coef_var, fill = sig), color = "black", size = 5.5, shape = 21) +
    geom_text(aes(label = label_var, vjust = -1.25), size = 5, color = color_scheme, fontface = "bold") +
    scale_fill_manual(values = color_scheme,
                      labels = paste0(" <span style='color:#585860; font-size:13pt'> ",
                                      ifelse(lang == "es", ifelse(pred_prob == TRUE, "Probabilidades pronosticadas", "Coeficientes de regresi\u00f3n"),
                                             ifelse(pred_prob == TRUE, "Predicted probabilities", "Regression coefficients")),
                                      "<span style='color:#FFFFFF00'>-----------</span>",
                                      ci_text),
                      limits = "FALSE",
                      na.value = "white") +
    coord_flip() +
    scale_y_continuous(limits = c(ymin, ymax)) +
    labs(title = main_title,
         y = " ",
         x = " ",
         caption = paste0(ifelse(lang == "es", "Fuente: LAPOP Lab", "Source: LAPOP Lab"),
                          source_info)) +
    theme(text = element_text(size = 14, family = "roboto"),
          plot.title = element_text(size = 18, family = "nunito", face = "bold"),
          plot.caption = element_text(size = 10.5, hjust = 0, vjust = 2, family = "nunito", color="#585860"),
          plot.subtitle = element_text(size = 14, family = "nunito-light", color="#585860"),
          axis.title.y = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_text(size = 14, family = "roboto", color = "#585860"),
          panel.background = element_rect(fill = "white"),
          panel.grid = element_blank(),
          legend.position = "top",
          legend.title = element_blank(),
          plot.title.position = "plot",
          plot.caption.position = "plot",
          legend.justification='left',
          # legend.margin = margin(t=0, b=0),
          legend.text = element_markdown(family = "nunito-light"),
          legend.key=element_blank(),
          legend.margin=margin(0, 0, 0, -30-subtitle_h_just))
  }


