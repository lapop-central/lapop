#######################################

# LAPOP Floating Bar Graph #

#######################################

#' LAPOP Floating Bar Graph
#'
#' This function creates a floating range plot using LAPOP formatting. Each
#' x-axis group displays its minimum-to-maximum range with all unit-level
#' observations overlaid as points.
#'
#' @param data Data frame containing unit-level values and group ranges.
#' @param xvar,outcome_var,lower_bound,upper_bound Plot components. Defaults
#'   use the `xvar`, `prop`, `lb`, and `ub` columns in `data`.
#' @param ymin,ymax Numeric or `NULL`. Y-axis limits. `NULL` calculates a limit
#'   from the data.
#' @param lang Character. Language used for the default source text. Options
#'   are `"en"`, `"es"`, and `"fr"`.
#' @param main_title Character. Plot title.
#' @param source_info Character. Source information. The default `"LAPOP"`
#'   prints the localized LAPOP Lab source line.
#' @param subtitle Character. Plot subtitle.
#' @param color_scheme Character vector of two colors for ranges and points.
#' @param percentages Logical. If `TRUE`, append percent signs to y-axis
#'   values. Default is `TRUE`, consistent with other LAPOP figures.
#' @param ref_line Numeric or `NULL`. Horizontal reference line. Use `NULL` to
#'   omit it.
#' @param note_text Character. Optional note appended below the source line.
#' @param range_alpha Numeric. Transparency of the range bars.
#' @param range_width Numeric. Width of the range bars.
#' @param point_size Numeric. Size of individual-observation points.
#' @param x_breaks,y_breaks Numeric vectors or `NULL`. Axis break points.
#' @param x_pad,y_pad Numeric. Additional axis padding in data units.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' election_plot <- data.frame(
#'   xvar = rep(c(2004, 2008, 2010, 2012, 2014, 2016, 2018), each = 2),
#'   prop = c(-8, 3, -6, 5, -10, 2, -4, 7, -9, 4, -3, 8, -7, 6),
#'   lb = rep(c(-8, -6, -10, -4, -9, -3, -7), each = 2),
#'   ub = rep(c(3, 5, 2, 7, 4, 8, 6), each = 2)
#' )
#' lapop_float(election_plot, subtitle = "Change in vote share")
#'
#' @export
#' @import ggplot2
#' @author Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}
lapop_float <- function(data,
                        xvar = data$xvar,
                        outcome_var = data$prop,
                        lower_bound = data$lb,
                        upper_bound = data$ub,
                        ymin = NULL,
                        ymax = NULL,
                        lang = "en",
                        main_title = "",
                        source_info = "LAPOP",
                        subtitle = "",
                        color_scheme = c("#A43D6A", "#8C8F98"),
                        percentages = TRUE,
                        ref_line = 0,
                        note_text = "",
                        range_alpha = 0.34,
                        range_width = 9,
                        point_size = 2.9,
                        x_breaks = NULL,
                        y_breaks = NULL,
                        x_pad = 1.15,
                        y_pad = 5) {
  if (!lang %in% c("en", "es", "fr")) {
    stop("`lang` must be one of 'en', 'es', or 'fr'.")
  }
  if (length(color_scheme) != 2L) {
    stop("`color_scheme` must contain two colors: range and point.")
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
    xvar = as.numeric(xvar),
    prop = as.numeric(outcome_var),
    lb = as.numeric(lower_bound),
    ub = as.numeric(upper_bound)
  )
  if (nrow(plot_data) == 0L || any(!is.finite(as.matrix(plot_data)))) {
    stop("Plot components must contain finite numeric values.")
  }
  if (any(plot_data$lb > plot_data$ub)) {
    stop("`lower_bound` cannot be greater than `upper_bound`.")
  }

  ranges <- unique(plot_data[c("xvar", "lb", "ub")])
  y_range <- range(c(plot_data$lb, plot_data$ub, plot_data$prop, ref_line), na.rm = TRUE)

  if (is.null(x_breaks)) {
    x_breaks <- sort(unique(plot_data$xvar))
  }
  if (is.null(y_breaks)) {
    y_step <- if (diff(y_range) <= 50) 10 else 20
    y_breaks <- seq(
      y_step * floor(y_range[1] / y_step),
      y_step * ceiling(y_range[2] / y_step),
      by = y_step
    )
    if (length(y_breaks) < 2L) {
      y_breaks <- c(y_breaks[1] - y_step, y_breaks[1], y_breaks[1] + y_step)
    }
  }
  if (is.null(ymin)) {
    ymin <- min(y_breaks) - y_pad
  }
  if (is.null(ymax)) {
    ymax <- max(y_breaks) + y_pad
  }
  if (!is.finite(ymin) || !is.finite(ymax) || ymax <= ymin) {
    stop("`ymin` and `ymax` must be finite values with `ymax > ymin`.")
  }

  x_axis_labels <- format(x_breaks, trim = TRUE, scientific = FALSE)
  y_axis_labels <- if (percentages) {
    paste0(format(y_breaks, trim = TRUE, scientific = FALSE), "%")
  } else {
    format(y_breaks, trim = TRUE, scientific = FALSE)
  }

  source_line <- if (identical(source_info, "LAPOP")) {
    switch(
      lang,
      es = "Fuente: LAPOP Lab",
      fr = "Source : LAPOP Lab",
      "Source: LAPOP Lab"
    )
  } else {
    source_info
  }
  caption_text <- paste(
    c(
      if (!identical(source_line, "")) source_line else NULL,
      if (!identical(note_text, "")) note_text else NULL
    ),
    collapse = "\n"
  )

  float_plot <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data$xvar, y = .data$prop)
  )
  if (!is.null(ref_line)) {
    float_plot <- float_plot + ggplot2::geom_hline(
      yintercept = ref_line,
      linewidth = 0.45,
      color = "#202124"
    )
  }

  float_plot +
    ggplot2::geom_linerange(
      data = ranges,
      ggplot2::aes(x = .data$xvar, ymin = .data$lb, ymax = .data$ub),
      inherit.aes = FALSE,
      linewidth = range_width,
      alpha = range_alpha,
      color = color_scheme[1],
      lineend = "butt"
    ) +
    ggplot2::geom_point(
      size = point_size,
      stroke = 0.7,
      shape = 21,
      fill = color_scheme[2],
      color = "#646873",
      alpha = 0.82
    ) +
    ggplot2::scale_x_continuous(
      breaks = x_breaks,
      labels = x_axis_labels,
      guide = ggplot2::guide_axis(check.overlap = FALSE),
      limits = c(min(x_breaks) - x_pad, max(x_breaks) + x_pad),
      expand = c(0, 0)
    ) +
    ggplot2::scale_y_continuous(
      breaks = y_breaks,
      labels = y_axis_labels,
      guide = ggplot2::guide_axis(check.overlap = FALSE),
      limits = c(ymin, ymax),
      expand = c(0, 0)
    ) +
    ggplot2::labs(
      title = main_title,
      subtitle = subtitle,
      caption = caption_text,
      x = "",
      y = ""
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      text = ggplot2::element_text(size = 14, family = regular_font),
      plot.title = ggplot2::element_text(size = 18, family = regular_font, face = "bold"),
      plot.subtitle = ggplot2::element_text(size = 14, family = light_font, color = "#585860", margin = ggplot2::margin(b = 10)),
      plot.caption = ggplot2::element_text(size = 10.5, family = regular_font, color = "#585860", hjust = 0, vjust = 2, lineheight = 1.3),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.text = ggplot2::element_text(size = 14, family = regular_font, color = "#585860"),
      axis.text.x = ggplot2::element_text(size = 14, family = regular_font, color = "#585860", margin = ggplot2::margin(t = 5)),
      axis.text.y = ggplot2::element_text(size = 14, family = regular_font, color = "#585860", margin = ggplot2::margin(r = 5)),
      axis.ticks = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.grid.major = ggplot2::element_line(color = "#dddddf", linewidth = 0.5),
      panel.grid.minor = ggplot2::element_line(color = "#dddddf", linewidth = 0.5),
      panel.border = ggplot2::element_rect(color = "#dddddf", fill = NA, linewidth = 1),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}
