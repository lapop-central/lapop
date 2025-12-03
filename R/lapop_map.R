#######################################

# LAPOP World / Americas-Only Map

#######################################

#' LAPOP World and Americas Map Graph
#' `lapop_map()` generates a stylized choropleth map using ISO2 country codes
#' from both continuous and factor variables. It is designed to map cross-country
#' results from `lpr_cc()` and supports either a full world map (`survey = "CSES"`)
#' # or an Americas-only map (`survey = "AmericasBarometer"`).
#'
#' @param data A data frame containing ISO2 country codes and a value to map.
#' @param pais_lab String. Column name containing ISO2 country codes (e.g., `"US"`, `"BR"`).
#' @param outcome String. Column name containing the numeric or categorical variable to visualize.
#' @param survey Either `"CSES"` (full world map) or `"AmericasBarometer"` (Americas only).
#' @param zoom Numeric (0–1). Controls how tightly the map zooms when `survey = "AmericasBarometer"`. Default is `1`.
#' @param palette Vector of up to 5 colors for continuous and factor variables.
#' @param main_title Character. Title of graph.  Default: None.
#' @param source_info Character. Information on dataset used (country, years, version, etc.),
#' which is added to the bottom-left corner of the graph. Default: LAPOP ("Source: LAPOP Lab" will be printed).
#' @param subtitle Character.  Describes the values/data shown in the graph, e.g., "percentage of Mexicans who say...)".
#' Default: None.
#' @param lang Character.  Changes default subtitle text and source info to either Spanish or English.
#' Will not translate input text, such as main title or variable labels.  Takes either "en" (English)
#' or "es" (Spanish).  Default: "en".
#' @return A `ggplot2` choropleth map object.
#'
#' @examples
#' \dontrun{
#' # Continuous variable example
#' data_cont <- data.frame(
#'   vallabel = c("US", "AR", "VE", "CH", "EC"),
#'   prop = c(37, 52, 94, 17, 69)
#' )
#' lapop_map(data_cont, pais_lab = "vallabel", outcome = "prop", zoom = 0.9,
#'           survey = "AmericasBarometer", main_title = "LAC Countries",
#'           subtitle = "% of respondents")
#'
#' # Factor variable example
#' data_fact <- data.frame(
#'   vallabel = c("CA", "BR", "MX", "PE", "CO"),
#'   group = c("A","A","B","B","C")
#' )
#' lapop_map(data_fact, pais_lab = "vallabel", outcome = "group", zoom = 0.9,
#'           survey = "AmericasBarometer", main_title = "LAC Countries",
#'           subtitle = "% of respondents")
#' }
#'
#' @export
#' @import ggplot2
#' @import ggtext
#' @import sf
#' @import rnaturalearth
#' @importFrom dplyr filter select left_join rename
#'
#' @author Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}

lapop_map <- function(data,
                      outcome = "value",
                      pais_lab = "pais_lab",
                      survey = c("CSES", "AmericasBarometer"),
                      zoom = 1,
                      main_title = "",
                      subtitle = "",
                      palette = c("#F2A344", "#D97A1E", "#BF5A00", "#8A3900", "#4A1E00"),
                      source_info = "LAPOP",
                      lang = "en") {

  survey <- match.arg(survey)
  zoom <- max(0, min(1, zoom))

  # Americas-only ISO2 vector
  americas_iso2 <- c(
    "US","CA","MX",
    "CR","SV","GT","HN","NI","PA","BZ",
    "DO","HT","TT","JM","CU","BB","BS","GD","LC","VC",
    "AR","BO","BR","CL","CO","EC","GY","PE","PY","SR","UY","VE"
  )

  # Base world map
  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
    dplyr::select(iso2 = iso_a2, name, geometry) %>%
    dplyr::filter(iso2 != "AQ")

  if (survey == "AmericasBarometer") {
    world <- world %>% dplyr::filter(iso2 %in% americas_iso2)
  }

  # Merge data
  df <- data %>%
    dplyr::rename(
      iso2  = !!sym(pais_lab),
      value = !!sym(outcome)
    )

  merged <- world %>% dplyr::left_join(df, by = "iso2")

  value_is_factor <- is.factor(merged$value) || is.character(merged$value)

  # Base plot
  p <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = merged %>% dplyr::filter(is.na(value)),
      fill = "#dddddf", color = NA
    ) +
    ggplot2::geom_sf(
      data = merged %>% dplyr::filter(!is.na(value)),
      ggplot2::aes(fill = value, color = value),
      size = 0.25
    )

  # Palette logic

  if (value_is_factor) {
    p <- p +
      ggplot2::scale_fill_manual(values = palette, drop = FALSE) +
      ggplot2::scale_color_manual(values = palette, guide = "none")
  } else {
    p <- p +
      scale_fill_gradientn(
        colors = palette,
        na.value = "#dddddf",
        guide = guide_colorbar(
          direction = "horizontal",
          barwidth  = unit(80, "pt"),
          barheight = unit(12, "pt"),
          label.position = "top"
        )
      ) +
      ggplot2::scale_color_gradientn(colors = palette, guide = "none")
  }

  # Zoom logic for better presentation
  if (survey == "AmericasBarometer") {

    world_xlim <- c(-180, 180)
    world_ylim <- c(-90, 90)

    americas_xlim <- c(-170, -25)
    americas_ylim <- c(-60, 80)

    final_xlim <- world_xlim * (1 - zoom) + americas_xlim * zoom
    final_ylim <- world_ylim * (1 - zoom) + americas_ylim * zoom

    p <- p + ggplot2::coord_sf(
      xlim = final_xlim,
      ylim = final_ylim,
      expand = FALSE
    )
  }

# SOURCE INFO LOGIC (matches lapop_cc) ------------------------------
  caption_text <- ifelse(lang == "es" & source_info == "LAPOP", "Fuente: LAPOP Lab",
                         ifelse(lang == "en" & source_info == "LAPOP", "Source: LAPOP Lab",
                                source_info))

  # OUTPUT ------------------------------------------------------
  p + ggplot2::theme_void() +
    ggplot2::labs(
      title    = main_title,
      subtitle = subtitle,
      fill     = "",
      caption  = caption_text) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_markdown(family = "nunito-light"),
      plot.title = element_text(size = 18, family = "nunito", face = "bold"),
      plot.caption = element_text(size = 10.5, vjust = 2, hjust = 0, family = "nunito", color="#585860"),
      plot.subtitle = element_text(size = 13, hjust = 0, family = "nunito", color = "#585860"),
      )
}
