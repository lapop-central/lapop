#######################################

# LAPOP Split Bar Graph #

#######################################

#' LAPOP Split Bar Graph
#'
#' This function creates paired-diverging split bar graphs using LAPOP
#' formatting. The positive and negative responses share a center line, while
#' the neutral response is displayed in a separate panel.
#'
#' @param data Data frame containing one row per item-response combination.
#' @param item,response,outcome_var Plot components. Defaults use the `item`,
#'   `response`, and `prop` columns in `data`.
#' @param ymin,ymax Numeric. Minimum and maximum percentage values shown.
#'   Defaults are 0 and 100.
#' @param lang Character. Language used for default labels and source text.
#'   Options are `"en"`, `"es"`, and `"fr"`.
#' @param main_title Character. Plot title.
#' @param source_info Character. Source information. The default `"LAPOP"`
#'   prints the localized LAPOP Lab source line.
#' @param subtitle Character. Plot subtitle.
#' @param improve_level,worsen_level,neutral_level Character. Response labels
#'   treated as the positive, negative, and neutral categories.
#' @param sort Character. Sorting method: `"hi-lo"` sorts by the positive
#'   response from highest to lowest, `"lo-hi"` reverses it, `"worsen"` sorts
#'   by the negative response, and `""` preserves the item order.
#' @param diverging_panel_label,neutral_panel_label Character or `NULL`. Panel
#'   labels. `NULL` uses language-specific defaults.
#' @param color_scheme Character vector of three colors for the positive,
#'   negative, and neutral responses. It may be named `improve`, `worsen`, and
#'   `neutral`.
#' @param label_size Numeric. Size of the percentage labels.
#' @param bar_width Numeric. Width of the bars.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' repdem_plot <- data.frame(
#'   item = c(
#'     "Women", "Women", "Women",
#'     "Young adults", "Young adults", "Young adults",
#'     "People of poor backgrounds", "People of poor backgrounds",
#'     "People of poor backgrounds",
#'     "Business people", "Business people", "Business people",
#'     "Religious people", "Religious people", "Religious people",
#'     "Labor union members", "Labor union members", "Labor union members"
#'   ),
#'   response = rep(
#'     c("Improve", "Get worse", "Mostly stay the same"),
#'     times = 6
#'   ),
#'   prop = c(
#'     50, 17, 33, 42, 25, 33, 38, 29, 33,
#'     55, 15, 30, 47, 18, 35, 36, 31, 33
#'   )
#' )
#' lapop_splitbar(repdem_plot, subtitle = "% of respondents")
#'
#' @export
#' @import ggplot2
#' @author Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}
lapop_splitbar <- function(data,
                            item = data$item,
                            response = data$response,
                            outcome_var = data$prop,
                            ymin = 0,
                            ymax = 100,
                            lang = "en",
                            main_title = "",
                            source_info = "LAPOP",
                            subtitle = "",
                            improve_level = "Improve",
                            worsen_level = "Get worse",
                            neutral_level = "Mostly stay the same",
                            sort = "hi-lo",
                            diverging_panel_label = NULL,
                            neutral_panel_label = NULL,
                            color_scheme = c(
                              improve = "#008381",
                              worsen = "#C74E49",
                              neutral = "#ACACAC"
                            ),
                            label_size = 4,
                            bar_width = 0.68) {
  if (!is.numeric(ymin) || !is.numeric(ymax) || length(ymin) != 1L ||
      length(ymax) != 1L || !is.finite(ymin) || !is.finite(ymax) ||
      ymin < 0 || ymax <= ymin) {
    stop("`ymin` and `ymax` must be finite values with 0 <= ymin < ymax.")
  }
  if (!lang %in% c("en", "es", "fr")) {
    stop("`lang` must be one of 'en', 'es', or 'fr'.")
  }

  if (exists(".lapop_register_fonts", mode = "function", inherits = TRUE)) {
    try(.lapop_register_fonts(), silent = TRUE)
  }
  available_fonts <- tryCatch(
    sysfonts::font_families(),
    error = function(e) character()
  )
  regular_font <- if ("inter" %in% available_fonts) "inter" else "sans"
  light_font <- if ("inter-light" %in% available_fonts) "inter-light" else regular_font

  plot_data <- data.frame(
    item = as.character(item),
    response = as.character(response),
    prop = as.numeric(outcome_var),
    stringsAsFactors = FALSE
  )
  if (nrow(plot_data) == 0L || any(!is.finite(plot_data$prop))) {
    stop("`outcome_var` must contain finite numeric values.")
  }

  expected_levels <- c(improve_level, worsen_level, neutral_level)
  if (!all(expected_levels %in% plot_data$response)) {
    stop("`response` must contain `improve_level`, `worsen_level`, and `neutral_level`.")
  }

  if (length(color_scheme) != 3L) {
    stop("`color_scheme` must contain three colors.")
  }
  if (is.null(names(color_scheme)) ||
      !all(c("improve", "worsen", "neutral") %in% names(color_scheme))) {
    color_scheme <- stats::setNames(
      color_scheme,
      c("improve", "worsen", "neutral")
    )
  }

  defaults <- switch(
    lang,
    es = c(diverging = "Empeorar\\u00eda / Mejorar\\u00eda", neutral = "Seguir\\u00eda igual"),
    fr = c(diverging = "Empirerait / Am\\u00e9liorerait", neutral = "Resterait pareil"),
    c(diverging = "Get worse / Improve", neutral = "Stay the same")
  )
  if (is.null(diverging_panel_label)) {
    diverging_panel_label <- unname(defaults["diverging"])
  }
  if (is.null(neutral_panel_label)) {
    neutral_panel_label <- unname(defaults["neutral"])
  }

  sort <- match.arg(sort, c("hi-lo", "lo-hi", "worsen", ""))
  sort_level <- if (identical(sort, "worsen")) worsen_level else improve_level
  item_scores <- plot_data$prop[plot_data$response == sort_level]
  names(item_scores) <- plot_data$item[plot_data$response == sort_level]
  item_order <- unique(plot_data$item)
  if (!identical(sort, "")) {
    decreasing <- !identical(sort, "lo-hi")
    item_order <- names(sort(item_scores, decreasing = decreasing))
  }

  plot_data$item <- factor(plot_data$item, levels = rev(item_order))
  plot_data$response <- factor(plot_data$response, levels = expected_levels)
  plot_data$x_value <- ifelse(
    plot_data$response == worsen_level,
    -plot_data$prop,
    plot_data$prop
  )
  plot_data$panel <- ifelse(
    plot_data$response == neutral_level,
    neutral_panel_label,
    diverging_panel_label
  )
  plot_data$panel <- factor(
    plot_data$panel,
    levels = c(diverging_panel_label, neutral_panel_label)
  )

  fill_values <- stats::setNames(
    c(
      color_scheme[["improve"]],
      color_scheme[["worsen"]],
      color_scheme[["neutral"]]
    ),
    expected_levels
  )
  label_colors <- stats::setNames(
    c("white", "white", "#202124"),
    expected_levels
  )
  axis_step <- if ((ymax - ymin) <= 50) 10 else 20
  axis_breaks <- seq(-ymax, ymax, by = axis_step)
  label_offset <- max(1, (ymax - ymin) * 0.018)
  limit_data <- data.frame(
    x_value = c(-ymax, ymax, ymin, ymax),
    panel = factor(
      c(
        diverging_panel_label,
        diverging_panel_label,
        neutral_panel_label,
        neutral_panel_label
      ),
      levels = c(diverging_panel_label, neutral_panel_label)
    )
  )

  caption_text <- if (identical(source_info, "LAPOP")) {
    switch(
      lang,
      es = "Fuente: LAPOP Lab",
      fr = "Source : LAPOP Lab",
      "Source: LAPOP Lab"
    )
  } else {
    source_info
  }

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data$x_value, y = .data$item, fill = .data$response)
  ) +
    ggplot2::geom_blank(
      data = limit_data,
      ggplot2::aes(x = .data$x_value),
      inherit.aes = FALSE
    ) +
    ggplot2::geom_col(width = bar_width, color = "white", linewidth = 0.2) +
    ggplot2::geom_vline(xintercept = 0, color = "#dddddf", linewidth = 0.6) +
    ggplot2::geom_text(
      ggplot2::aes(
        label = .data$prop,
        x = ifelse(
          .data$response == worsen_level,
          .data$x_value + label_offset,
          .data$x_value - label_offset
        ),
        hjust = ifelse(.data$response == worsen_level, 0, 1),
        color = .data$response
      ),
      family = regular_font,
      fontface = "bold",
      size = label_size,
      show.legend = FALSE
    ) +
    ggplot2::facet_grid(. ~ panel, scales = "free_x", space = "free_x") +
    ggplot2::scale_fill_manual(values = fill_values, guide = "none") +
    ggplot2::scale_color_manual(values = label_colors, guide = "none") +
    ggplot2::scale_x_continuous(
      breaks = axis_breaks,
      expand = ggplot2::expansion(mult = c(0.02, 0.02))
    ) +
    ggplot2::labs(
      title = main_title,
      subtitle = subtitle,
      caption = caption_text,
      x = " ",
      y = " "
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      text = ggplot2::element_text(size = 14, family = regular_font),
      plot.title = ggplot2::element_text(size = 18, family = regular_font, face = "bold"),
      plot.subtitle = ggplot2::element_text(size = 14, family = light_font, color = "#585860", margin = ggplot2::margin(b = 10)),
      plot.caption = ggplot2::element_text(size = 10.5, hjust = 0, vjust = 2, family = regular_font, color = "#585860"),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      panel.background = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_line(linewidth = 0.6, color = "#dddddf"),
      axis.text.y = ggplot2::element_text(size = 12, family = regular_font, color = "#585860", face = "bold"),
      axis.text.x = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(size = 14, family = regular_font, face = "bold"),
      strip.background = ggplot2::element_blank(),
      panel.spacing.x = grid::unit(2.5, "lines"),
      plot.margin = ggplot2::margin(10, 16, 10, 10)
    )
}

#' @rdname lapop_splitbar
#' @export
lapop_butterfly <- lapop_splitbar
