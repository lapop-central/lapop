######################################################

# LAPOP Histogram Graph Pre-Processing #

######################################################

#' LAPOP Bar/Histogram Graphs
#'
#' This function creates dataframes which can then be input in lapop_hist for
#' showing a bar graph using LAPOP formatting.
#'
#' @param data A survey object.  The data that should be analyzed.
#' @param outcome Character. Outcome variable of interest.
#' @param filesave Character.  Path and file name to save the dataframe as csv.
#' @param cfmt Character. Changes the format of the numbers displayed above the bars.
#' Uses sprintf string formatting syntax. Default is whole numbers.
#' @param sort Character. On what value the bars are sorted.
#' Options are "y" (for the value of the outcome variable), "xv" (default; for
#' the underlying values of the x variable), "xl" (for the labels of the x variable,
#' i.e., alphabetical).
#' @param order Character.  How the bars should be sorted.  Options are "hi-lo"
#' or "lo-hi" (default).
#' @param keep_nr Logical.  If TRUE, will convert "don't know" (missing code .a)
#' and "no response" (missing code .b) into valid data (value = 99).
#' The default is to examine valid responses only.  Default: FALSE.
#'
#'
#' @return Returns a data frame, with data formatted for visualization by lapop_hist
#'
#' @examples
#'
#' \dontrun{lpr_hist(bra23,
#' outcome = "aoj11",
#' sort = "xv",
#' order = "hi-lo")}
#'
#'@export
#'@import dplyr
#'@import srvyr
#'
#'@author Shashwat Dhar \email{shashwat.dhar@@vanderbilt.edu},
#'Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}


lpr_hist <- function(data,
                     outcome,
                     filesave = "",
                     cfmt = "",
                     sort = "xv",
                     order = "lo-hi",
                     keep_nr = FALSE) {

  # If keep_nr is TRUE, convert don't knows (NA(a)) and no answers (NA(b)) to
  # non-NA data (a value of 99).
  if (keep_nr) {
    data = data %>%
      mutate(!!sym(outcome) := case_when(
        na_tag(!!sym(outcome)) %in% c("a", "b") ~ 99,
        TRUE ~ as.numeric(!!sym(outcome))
      ))
  }

  # Create the data frame
  hist_df = data %>%
    drop_na(outcome) %>%
    group_by(across(outcome)) %>%  #
    summarise(n = n()) %>%
    rename(cat = 1) %>%
    mutate(
      prop = prop.table(n) * 100,
      proplabel = if (cfmt != "") {
        sprintf(cfmt, round(prop))
      } else {
        sprintf("%.0f%%", round(prop))
      },
      cat = (haven::as_factor(cat))
    ) %>%
    select(-n)

  # Apply sorting
  if (sort == "y") {
    hist_df = hist_df %>%
      arrange(if (order == "lo-hi") prop else desc(prop))
  }

  if (sort == "xv") {
    hist_df = hist_df %>%
      arrange(if (order == "lo-hi") match(cat, levels(cat)) else desc(match(cat, levels(cat))))
  }

  if (sort == "xl") {
    hist_df = hist_df %>%
      arrange(if (order == "lo-hi") as.character(cat) else desc(as.character(cat)))
  }

  if (filesave != "") {
    write.csv(hist_df, filesave)
  }

  # Return the data frame
  return(hist_df)
}
