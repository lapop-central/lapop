#######################################

# LAPOP Stacked Bar Graph #

#######################################

#' @rdname lapop-deprecated
#' @section \code{lapop_sb}:
#' For \code{lapop_sb}, use \code{\link{lapop_stack}}.
#'
#' @export

lapop_sb <- function(data, outcome_var = data$prop, prop_labels = data$proplabel,
                        var_labels = data$varlabel, value_labels = data$vallabel,
                        lang = "en",
                        main_title = "",
                        subtitle = "",
                        source_info = "",
                        rev_values = FALSE,
                        rev_variables = FALSE,
                        hide_small_values = TRUE,
                        order_bars = FALSE,
                        subtitle_h_just = 0,
                        color_scheme = c("#2D708E", "#1F9689", "#00ADA9", "#21A356", "#568424", "#ACB014")){
  .Deprecated("lapop_stack")
  lapop_stack(data = data, outcome_var = outcome_var, prop_labels = prop_labels,
              var_labels = var_labels, value_labels = value_labels,
              lang = lang,
              main_title = main_title,
              subtitle = subtitle,
              source_info = source_info,
              rev_values = rev_values,
              rev_variables = rev_variables,
              hide_small_values = hide_small_values,
              order_bars = order_bars,
              subtitle_h_just = subtitle_h_just,
              color_scheme = color_scheme)
}


#' @include lapop_fonts.R
NULL

#' LAPOP Stacked Bar Graphs
#'
#' This function shows a stacked bar graph using LAPOP formatting.
#'
#' @param data Data Frame. Dataset to be used for analysis.  The data frame should have columns
#' titled varlabel (name(s)/label(s) of variable(s) of interest; character), vallabel (names/labels of values for each variable; character),
#' prop (outcome variable value; numeric), and proplabel (text of outcome variable value; character).
#' Default: None (must be provided).
#' @param outcome_var,prop_labels,var_labels,value_labels Numeric, character, character, character.
#' Each component of the data to be plotted can be manually specified in case
#' the default columns in the data frame should not be used (if, for example, the values for a given
#' variable were altered and stored in a new column).
#' @param xvar Character. Column name to group the plots by. This should match a column name in the dataset.
#' Default: NULL (no grouping).
#' @param main_title Character.  Title of graph.  Default: None.
#' @param source_info Character.  Information on dataset used (country, years, version, etc.),
#' which is added to the end of "Source: " in the bottom-left corner of the graph.
#' Default: LAPOP ("Source: LAPOP Lab" will be printed).
#' @param subtitle Character.  Describes the values/data shown in the graph, e.g., "Percent who support...".
#' Default: None.
#' @param lang Character.  Changes default subtitle text and source info to either Spanish or English.
#' Will not translate input text, such as main title or variable labels.  Takes either "en" (English)
#' or "es" (Spanish).  Default: "en".
#' @param color_scheme Character.  Color of data bars for each value.  Allows up to 6 values.
#' Takes hex numbers, beginning with "#".
#' Default: c("#2D708E", "#008381", "#C74E49", "#784885", "#a43d6a","#202020")
#' (navy blue, turquoise, teal, green, sap green, pea soup).
#' @param subtitle_h_just Numeric.  Move the subtitle/legend text left (negative numbers) or right (positive numbers).
#' Ranges from -100 to 100.  Default: 0.
#' @param fixed_aspect_ratio Logical.  Should the aspect ratio be set to a specific value (0.35)?
#' This prevents bars from stretching vertically to fit the plot area.  Set to false when you have
#' a large number of bars (> 10).  Default: TRUE.
#' @param rev_variables Logical.  Should the order of the variables be reversed?  Default: FALSE.
#' @param rev_values Logical.  Should the order of the values for each variable be reversed?  Default: FALSE.
#' @return Returns an object of class \code{ggplot}, a ggplot stacked bar graph
#' @param hide_small_values Logical.  Should labels for categories with less than 5 percent be hidden?  Default: TRUE.
#' @param order_bars Logical.  Should categories be placed in descending order for each bar?  Default: FALSE.
#' showing the distributions of multiple categorical variables.
#' @param legendnrow Numeric.  How many rows for legend labels. Default: 1.
#'
#' @examples
#'df <- data.frame(varlabel = c(rep("Politicians can\nidentify voters", 5),
#'                              rep("Wealthy can\nbuy results", 5),
#'                              rep("Votes are\ncounted correctly", 5)),
#'                 vallabel = rep(c("Always", "Often", "Sometimes",
#'                                  "Never", "Other"), 3),
#'                 prop = c(36, 10, 19, 25, 10, 46, 10, 23, 11, 10, 35,
#'                          10, 32, 13, 10),
#'                 proplabel = c("36%", "10%", "19%", "25%", "10%", "46%",
#'                               "10%", "23%", "11%", "10%", "35%", "10%",
#'                               "32%", "13%", "10%"))
#'
#'lapop_stack(df,
#'         main_title = "Trust in key features of the electoral process is low in Latin America",
#'         subtitle = "% believing it happens:",
#'         source_info = "Source: LAPOP Lab, AmericasBarometer 2019")
#'
#'@export
#'@import ggplot2
#'@import ggtext
#'@import showtext
#'@importFrom stats reorder

#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} & Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}

lapop_stack <- function(data,
                        outcome_var = data$prop,
                        prop_labels = data$proplabel,
                        var_labels = data$varlabel,
                        value_labels = data$vallabel,
                        xvar = NULL,
                        lang = "en",
                        main_title = "",
                        subtitle = "",
                        source_info = "LAPOP",
                        rev_values = FALSE,
                        rev_variables = FALSE,
                        hide_small_values = TRUE,
                        order_bars = FALSE,
                        subtitle_h_just = 0,
                        fixed_aspect_ratio = TRUE,
                        legendnrow = 1,
                        color_scheme = c("#2D708E", "#008381", "#C74E49", "#784885", "#a43d6a","#202020")){

  # Ensure proper data types
  if(!inherits(var_labels, "character") & !inherits(var_labels, "factor")){
    var_labels = as.character(var_labels)
    data$varlabels = as.character(data$varlabel)
  }
  if(!inherits(value_labels, "character") & !inherits(value_labels, "factor")){
    value_labels = as.character(value_labels)
    data$vallabel = as.character(data$vallabel)
  }

  # Create a new data frame for plotting
  plot_data <- data.frame(
    var_labels = var_labels,
    value_labels = value_labels,
    outcome_var = outcome_var,
    prop_labels = prop_labels
  )

  # Add grouping variable if provided
  if (!is.null(xvar)) {
    if (xvar %in% colnames(data)) {
      plot_data$group_var <- data[[xvar]]
    } else {
      warning(paste("Column", xvar, "not found in data. Ignoring grouping."))
      xvar <- NULL
    }
  }

  # Set up colors
  mycolors = rev(color_scheme[seq_along(unique(value_labels))])

  # Handle value label ordering
  if(rev_values == TRUE){
    plot_data$value_labels = factor(plot_data$value_labels, levels = unique(plot_data$value_labels))
  } else{
    plot_data$value_labels = factor(plot_data$value_labels, levels = rev(unique(plot_data$value_labels)))
  }

  # Determine x-axis positions
  if (!is.null(xvar)) {
    # When grouped, create a combined label of var_label and group_var
    plot_data$combined_label <- plot_data$group_var

    # Handle variable ordering
    if (rev_variables) {
      positions <- rev(unique(plot_data$combined_label))
    } else {
      positions <- unique(plot_data$combined_label)
    }

    # For x-axis label display
    plot_data$x_display <- plot_data$combined_label
  } else {
    # When not grouped, use var_labels directly
    if (rev_variables) {
      positions <- rev(unique(plot_data$var_labels))
    } else {
      positions <- unique(plot_data$var_labels)
    }

    # For x-axis label display
    plot_data$x_display <- plot_data$var_labels
  }

  update_geom_defaults("text", list(family = "roboto"))

  # Handle ordering of bars if requested
  if(order_bars == TRUE){
    if (!is.null(xvar)) {
      # With grouping, order within each group
      plot_data$x_display <- factor(plot_data$x_display)

      # Create an ordering function that works with grouped data
      plot <- ggplot(plot_data, aes(y = outcome_var, x = x_display,
                                    fill = reorder(value_labels, outcome_var), label = prop_labels))
    } else {
      # Without grouping, order as before
      plot_data$var_labels <- factor(plot_data$var_labels, levels = unique(plot_data$var_labels))
      plot_data$x_display <- plot_data$var_labels

      plot <- ggplot(plot_data, aes(y = outcome_var, x = x_display,
                                    fill = reorder(value_labels, outcome_var), label = prop_labels))
    }

    # Generate the ordered plot
    plot +
      geom_bar(position = "stack", stat = "identity", width = 0.6) +
      geom_text(aes(label = ifelse(outcome_var >= 5, prop_labels, NA)),
                position = position_stack(vjust = 0.5), color = "#FFFFFF",
                fontface = "bold", size = 5, na.rm=T) +
      ggrepel::geom_text_repel(aes(label = ifelse(outcome_var < 5 & hide_small_values == FALSE, prop_labels, NA)),
                               position = position_stack(vjust = 0.5),
                               color = "#FFFFFF", segment.color = 'transparent',
                               fontface = "bold", size = 4, family = "roboto",
                               direction = "y",
                               force_pull = 0.2, force = 5, na.rm=T) +
      coord_flip() +
      scale_fill_manual(values = mycolors, guide = guide_legend(reverse = TRUE, nrow = legendnrow), na.translate = FALSE) +
      scale_x_discrete(limits = positions, expand = c(0, 0)) +
      scale_y_continuous(expand = c(0.02, 0)) +
      labs(title = main_title,
           y = "",
           x = " ",
           caption = paste0(ifelse(lang == "es" & source_info == "LAPOP", "Fuente: LAPOP Lab",
                                   ifelse(lang == "en" & source_info == "LAPOP", "Source: LAPOP Lab",
                                          source_info))),
           subtitle = subtitle) +
      theme(text = element_text(size = 14, family = "roboto"),
            plot.title = element_text(size = 17, family = "nunito", face = "bold"),
            plot.caption = element_text(size = 10.5, hjust = 0.02, vjust = 2, family = "nunito", color="#585860"),
            plot.subtitle = element_text(size = 14, family = "nunito-light", color="#585860"),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_text(margin=margin(r=0)),
            axis.ticks = element_blank(),
            axis.text = element_text(size = 14, family = "roboto", color = "#585860", margin=margin(r=5)),
            panel.background = element_rect(fill = "white"),
            panel.grid = element_blank(),
            legend.position = "top",
            plot.title.position = "plot",
            plot.caption.position = "plot",
            legend.text = element_text(family = "roboto", color = "#585860"),
            legend.title = element_blank(),
            legend.justification='left',
            legend.key.size = unit(1, "line"),
            legend.margin = margin(t=5,b=5, 0, subtitle_h_just)) +
      {if(fixed_aspect_ratio)theme(aspect.ratio = 0.35)}
  } else {
    # Create the standard plot without ordering bars
    ggplot(plot_data, aes(fill = value_labels, y = outcome_var, x = x_display, label = prop_labels)) +
      geom_bar(position = "stack", stat = "identity", width = 0.6) +
      geom_text(aes(label = ifelse(outcome_var >= 5, prop_labels, NA)),
                position = position_stack(vjust = 0.5), color = "#FFFFFF",
                fontface = "bold", size = 5, na.rm=T) +
      ggrepel::geom_text_repel(aes(label = ifelse(outcome_var < 5 & hide_small_values == FALSE, prop_labels, NA)),
                               position = position_stack(vjust = 0.5),
                               color = "#FFFFFF", segment.color = 'transparent',
                               fontface = "bold", size = 4, family = "nunito",
                               direction = "y",
                               force_pull = 0.2, force = 5, na.rm=T) +
      coord_flip() +
      scale_fill_manual(values = mycolors, guide=guide_legend(reverse = TRUE, nrow = legendnrow)) +
      scale_x_discrete(limits = positions, expand = c(0, 0)) +
      scale_y_continuous(expand = c(0.02, 0)) +
      labs(title = main_title,
           y = "",
           x = " ",
           caption = paste0(ifelse(lang == "es" & source_info == "LAPOP", "Fuente: LAPOP Lab",
                                   ifelse(lang == "en" & source_info == "LAPOP", "Source: LAPOP Lab",
                                          source_info))),
           subtitle = subtitle) +
      theme(text = element_text(size = 14, family = "roboto"),
            plot.title = element_text(size = 17, family = "nunito", face = "bold"),
            plot.caption = element_text(size = 10.5, hjust = 0, vjust = 2, family = "roboto-light", color="#585860"),
            plot.subtitle = element_text(size = 14, family = "nunito-light", color="#585860"),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_text(margin=margin(r=0)),
            axis.ticks = element_blank(),
            axis.text = element_text(size = 14, family = "roboto", color = "#585860", margin=margin(r=5)),
            panel.background = element_rect(fill = "white"),
            panel.grid = element_blank(),
            legend.position = "top",
            plot.title.position = "plot",
            plot.caption.position = "plot",
            legend.text = element_text(family = "roboto", color = "#585860"),
            legend.title = element_blank(),
            legend.justification='left',
            legend.key.size = unit(1, "line"),
            legend.margin = margin(t=5,b=5, 0, subtitle_h_just)) +
      {
        if (fixed_aspect_ratio) theme(aspect.ratio = 0.35)
        }
  }
}
