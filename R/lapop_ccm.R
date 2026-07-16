#######################################

# LAPOP Cross-Country Bar Graphs #

#######################################

#' @include lapop_fonts.R
NULL

#' LAPOP Cross-Country Bar Graphs
#'
#' This function creates bar graphs for comparing values across countries using LAPOP formatting.
#' @param data Data Frame. Dataset to be used for analysis.  The data frame should have columns
#' titled pais (values of x-axis variable (usually pais); character vector), prop (outcome variable; numeric),
#' proplabel (text of outcome variable; character), lb (lower bound of estimate; numeric),
#'  ub (upper bound of estimate; numeric), and var (labels of secondary variables; character).
#'  Default: None (must be supplied).
#' @param pais,outcome_var,label_var,lower_bound,upper_bound,var Character, numeric, character,
#' numeric, numeric, character. Each component of the plot data can be manually specified in case
#' the default columns in the data frame should not be used (if, for example, the values for a given
#' variable were altered and stored in a new column).
#' @param ymin,ymax Numeric.  Minimum and maximum values for y-axis. Default: 0 to 100.
#' @param sort Character. Method of sorting bars.  Options: "var1" (highest to lowest on variable 1),
#' "var2" (highest to lowest on variable 2), "var3" (highest to lowest on variable 3),
#' "var4" (highest to lowest on variable 4),
#' "alpha" (alphabetical along x-axis/pais). Default: Order of data frame.
#' @param main_title Character.  Title of graph.  Default: None.
#' @param source_info Character.  Information on dataset used (country, years, version, etc.),
#' which is added to the end of "Source: " in the bottom-left corner of the graph.
#' Default: None (only "Source: " will be printed).
#' @param subtitle Character.  Describes the values/data shown in the graph, e.g., "percentage of Mexicans who say...)".
#' Default: None.
#' @param y_label Character.  Y-axis label.
#' @param x_label Character.  X-axis label.
#' @param highlight Character.  Country of interest.  Will highlight (make darker) that country's bar.
#' Input must match entry in "vallabel" exactly. Default: None.
#' @param lang Character.  Changes default subtitle text and source info to either Spanish or English.
#' Will not translate input text, such as main title or variable labels.  Takes either "en" (English)
#' or "es" (Spanish).  Default: "en".
#' @param color_scheme Character.  Color of bars.  Takes hex number, beginning with "#".
#' Default: "#784885", "#008381", "#C74E49", "#2D708E".
#' @param label_size Numeric.  Size of text for data labels (percentages above bars).  Default: 4.
#' @param text_position Numeric.  Amount that text above error bars should be offset (to avoid overlap).  Default: 0.7
#' @param horizontal Logical. If TRUE, display the grouped bars horizontally. Default: FALSE.
#'
#' @return Returns an object of class \code{ggplot}, a ggplot figure showing
#' average values of some variables across multiple countries.
#'
#' @examples
#' \donttest{
#' require(lapop); lapop_fonts()
#'
#' df <- data.frame(pais = c(rep("HT", 2), rep("PE", 2), rep("HN", 2), rep("CO", 2),
#'              rep("UY", 2), rep("CR", 2), rep("EC", 2), rep("CL", 2),
#'               rep("BR", 2), rep("BO", 2), rep("JA", 2), rep("PN", 2)),
#'               var = rep(c("countfair1", "countfair3"), 3),
#'               prop = c(30, 38, 40, 49, 57, 33, 80, 54, 30, 43, 61, 42,
#'                        38, 54, 74, 61, 50, 34, 48, 34, 72, 41, 58, 57),
#'               proplabel = c("30%", "38%", "40%", "49%", "57%", "33%",
#'                             "80%", "54%", "30%", "43%", "61%", "42%",
#'                             "38%", "54%", "74%", "61%", "50%", "34%",
#'                             "48%", "34%", "72%", "41%", "58%", "57%"),
#'               lb = c(27, 35, 37, 46, 54, 30, 77, 51, 27, 40, 58, 39,
#'                      35, 51, 71, 58, 47, 31, 45, 31, 69, 38, 55, 54),
#'               ub = c(33, 41, 43, 52, 60, 36, 83, 57, 33, 46, 64, 45,
#'                      41, 57, 77, 64, 53, 37, 51, 37, 75, 44, 61, 60))
#'
#' lapop_ccm(df, sort = "var", source_info = ", AmericasBarometer")
#' lapop_ccm(df, sort = "var", source_info = ", AmericasBarometer", horizontal = TRUE)
#'}
#'@export
#'@import ggplot2
#'@import dplyr
#'@import ggtext
#'@import sysfonts
#'@import showtext
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} & Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}

lapop_ccm <- function(
    data,
    pais = data$pais,
    outcome_var = data$prop,
    lower_bound = data$lb,
    upper_bound = data$ub,
    label_var = data$proplabel,
    var = data$var,
    ymin = 0,
    ymax = 100,
    lang = "en",
    main_title = "",
    source_info = "",
    subtitle = "",
    sort = "",
    y_label = "",
    x_label = "",
    highlight = "",
    color_scheme = c("#784885", "#008381", "#C74E49", "#2D708E"),
    label_size = 4,
    text_position = 0.7,
    horizontal = FALSE
) {

  # Preserve the order of the incoming variable
  if (is.factor(var)) {
    var_order <- levels(droplevels(var))
  } else {
    var_order <- unique(as.character(var))
  }

  # Add plotting variables to the data
  data$pais <- pais
  data$prop <- outcome_var
  data$lb <- lower_bound
  data$ub <- upper_bound
  data$proplabel <- label_var

  # Convert to character before any replacement
  # This prevents factor values from becoming integer codes
  data$var <- as.character(var)

  # Retain only levels actually present in the data
  var_order <- var_order[var_order %in% unique(data$var)]

  if (length(unique(data$var)) > 4) {
    stop("`lapop_ccm()` supports a maximum of 4 variables.")
  }

  if (length(color_scheme) < length(unique(data$var))) {
    stop(
      "`color_scheme` must have at least as many colors as ",
      "the number of variables being plotted."
    )
  }

  # Use only the colors required
  color_scheme <- color_scheme[
    seq_len(length(unique(data$var)))
  ]

  fill_colors <- paste0(color_scheme, "52")

  # Highlight selected country/category
  if (highlight != "") {
    data$hl_var <- ifelse(
      data$pais == highlight,
      "hl",
      "other"
    )
  } else {
    data$hl_var <- "other"
  }

  data$alpha_value <- ifelse(
    data$hl_var == "hl",
    0.6,
    0.32
  )

  # Confidence-interval explanation added to final legend entry
  if (lang == "es") {

    ci_text <- paste0(
      "<span style='color:#FFFFFF00'>-------</span>",
      "<span style='color:#585860; font-size:18pt'>&#305;&mdash;&#305;</span>"
      "<span style='color:#585860; font-size:13pt'> ",
      "95% intervalo de confianza </span>"
    )

  } else if (lang == "fr") {

    ci_text <- paste0(
      "<span style='color:#FFFFFF00'>-------</span>",
      "<span style='color:#585860; font-size:18pt'>&#305;&mdash;&#305;</span>"
      "<span style='color:#585860; font-size:13pt'> ",
      "Intervalle de confiance de 95% </span>"
    )

  } else {

    ci_text <- paste0(
      "<span style='color:#FFFFFF00'>-------</span>",
      "<span style='color:#585860; font-size:18pt'> ı—ı</span>",
      "<span style='color:#585860; font-size:13pt'> ",
      "95% confidence interval </span>"
    )
  }

  # Identify the final legend category according to factor order
  last_var <- utils::tail(var_order, 1)

  # Construct legend labels without ifelse()
  legend_levels <- var_order

  legend_levels[legend_levels == last_var] <- paste0(
    last_var,
    ci_text
  )

  # Replace only the final category in the data
  data$var[data$var == last_var] <- paste0(
    last_var,
    ci_text
  )

  # Rebuild the factor while preserving the requested order
  data$var <- factor(
    data$var,
    levels = legend_levels
  )

  # Sorting
  if (sort == "var1") {

    data <- data %>%
      dplyr::group_by(var) %>%
      dplyr::mutate(rank = rank(-prop)) %>%
      dplyr::arrange(var, rank) %>%
      dplyr::ungroup()

  } else if (sort == "var2") {

    data <- data %>%
      dplyr::group_by(var) %>%
      dplyr::mutate(rank = rank(-prop)) %>%
      dplyr::arrange(
        match(var, unique(var)[2]),
        rank
      ) %>%
      dplyr::ungroup()

  } else if (sort == "var3") {

    data <- data %>%
      dplyr::group_by(var) %>%
      dplyr::mutate(rank = rank(-prop)) %>%
      dplyr::arrange(
        match(var, unique(var)[3]),
        rank
      ) %>%
      dplyr::ungroup()

  } else if (sort == "var4") {

    data <- data %>%
      dplyr::group_by(var) %>%
      dplyr::mutate(rank = rank(-prop)) %>%
      dplyr::arrange(
        match(var, unique(var)[4]),
        rank
      ) %>%
      dplyr::ungroup()

  } else if (sort == "alpha") {

    data <- data[order(data$pais), ]
  }

  # Label positions
  data$label_position <- ifelse(
    data$prop < 0,
    data$lb - text_position,
    data$ub + text_position
  )

  data$label_vjust <- ifelse(
    data$prop < 0,
    1.4,
    -0.5
  )

  data$label_hjust <- ifelse(
    data$prop < 0,
    1,
    0
  )

  ggplot2::update_geom_defaults(
    "text",
    list(family = "inter")
  )

  axis_labels <- if (horizontal) {
    list(
      x = y_label,
      y = x_label
    )
  } else {
    list(
      x = x_label,
      y = y_label
    )
  }

  p <- ggplot2::ggplot(
    data = data,
    ggplot2::aes(
      x = factor(pais, levels = unique(pais)),
      y = prop,
      fill = var,
      color = var
    )
  ) +
    ggplot2::geom_bar(
      ggplot2::aes(alpha = alpha_value),
      position = "dodge",
      stat = "identity",
      width = 0.7
    ) +
    ggplot2::geom_text(
      ggplot2::aes(
        label = proplabel,
        y = label_position,
        group = var
      ),
      position = ggplot2::position_dodge(width = 0.7),
      vjust = if (horizontal) {
        0.5
      } else {
        data$label_vjust
      },
      hjust = if (horizontal) {
        data$label_hjust
      } else {
        0.5
      },
      size = label_size,
      fontface = "bold",
      show.legend = FALSE
    ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(
        ymin = lb,
        ymax = ub,
        group = var
      ),
      width = 0.15,
      position = ggplot2::position_dodge(width = 0.7),
      linetype = "solid",
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(
      values = fill_colors,
      drop = FALSE
    ) +
    ggplot2::scale_color_manual(
      values = color_scheme,
      drop = FALSE
    ) +
    ggplot2::scale_y_continuous(
      limits = c(ymin, ymax),
      expand = if (horizontal) {
        ggplot2::expansion(mult = c(0.002, 0.08))
      } else {
        ggplot2::expansion(mult = c(0.002, 0.03))
      }
    ) +
    ggplot2::labs(
      title = main_title,
      y = axis_labels$y,
      x = axis_labels$x,
      caption = paste0(
        ifelse(
          lang == "es",
          "Fuente: LAPOP Lab",
          "Source: LAPOP Lab"
        ),
        source_info
      )
    ) +
    {
      if (subtitle != "") {
        ggplot2::labs(subtitle = subtitle)
      }
    } +
    {
      if (!horizontal && x_label != "") {
        ggplot2::theme(
          axis.title.x = ggplot2::element_text(
            margin = ggplot2::margin(
              b = 10,
              t = 10
            )
          )
        )
      }
    } +
    {
      if (horizontal && y_label != "") {
        ggplot2::theme(
          axis.title.x = ggplot2::element_text(
            margin = ggplot2::margin(
              b = 10,
              t = 10
            )
          )
        )
      }
    } +
    ggplot2::theme(
      text = ggplot2::element_text(
        size = 14,
        family = "inter"
      ),
      plot.title = ggplot2::element_text(
        size = 18,
        family = "inter",
        face = "bold"
      ),
      plot.caption = ggplot2::element_text(
        size = 10.5,
        vjust = 2,
        hjust = 0,
        family = "inter",
        color = "#585860"
      ),
      panel.background = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_line(
        linewidth = 0.6,
        linetype = "solid",
        colour = "#dddddf"
      ),
      axis.text = ggplot2::element_text(
        size = 14,
        color = "#585860",
        face = "bold"
      ),
      axis.text.y = if (horizontal) {
        ggplot2::element_text(
          size = 14,
          color = "#585860",
          face = "bold"
        )
      } else {
        ggplot2::element_blank()
      },
      axis.text.x = if (horizontal) {
        ggplot2::element_blank()
      } else {
        ggplot2::element_text(
          size = 14,
          color = "#585860",
          face = "bold"
        )
      },
      axis.ticks = ggplot2::element_blank(),
      legend.position = "top",
      legend.title = ggplot2::element_blank(),
      legend.justification = "left",
      legend.margin = ggplot2::margin(
        t = 0,
        b = 0,
        l = 0
      ),
      plot.margin = if (horizontal) {
        ggplot2::margin(
          t = 10,
          r = 50,
          b = 10,
          l = 10
        )
      } else {
        ggplot2::margin(
          t = 10,
          r = 10,
          b = 10,
          l = 10
        )
      },
      legend.text = ggtext::element_markdown(
        family = "inter-light"
      )
    ) +
    ggplot2::guides(alpha = "none")

  if (horizontal) {
    p <- p + ggplot2::coord_flip(clip = "off")
  }

  p
}
