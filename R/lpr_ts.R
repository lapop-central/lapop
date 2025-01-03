#######################################

# LAPOP Time-Series Line Graph Pre-Processing #

#######################################

#' LAPOP Time-Series Line Graph Pre-Processing
#'
#' This function creates dataframes which can then be input in lapop_ts for
#' comparing values across time with a line graph using LAPOP formatting.
#'
#' @param data A survey object.  The data that should be analyzed.
#' @param outcome Character.  Outcome variable of interest to be plotted
#' across time.
#' @param rec Numeric. The minimum and maximum values of the outcome variable that
#' should be included in the numerator of the percentage.  For example, if the variable
#' is on a 1-7 scale and rec is c(5, 7), the function will show the percentage who chose
#' an answer of 5, 6, 7 out of all valid answers.  Default: c(1, 1).
#' @param use_wave Logical.  If TRUE, will use "wave" for the x-axis; otherwise,
#' will use "year".  Default: FALSE.
#' @param ci_level Numeric. Confidence interval level for estimates.  Default: 0.95
#' @param mean Logical.  If TRUE, will produce the mean of the variable rather than
#' rescaling to percentage.  Default: FALSE.
#' @param filesave Character.  Path and file name to save the dataframe as csv.
#' @param cfmt Character. changes the format of the numbers displayed above the bars.
#' Uses sprintf string formatting syntax. Default is whole numbers for percentages
#' and tenths place for means.
#' @param ttest Logical.  If TRUE, will conduct pairwise t-tests for difference
#' of means between all individual x levels and save them in attr(x,
#' "t_test_results"). Default: FALSE.
#' @param keep_nr Logical.  If TRUE, will convert "don't know" (missing code .a)
#' and "no response" (missing code .b) into valid data (value = 99) and use them
#' in the denominator when calculating percentages.  The default is to examine
#' valid responses only.  Default: FALSE.
#'
#' @return Returns a data frame, with data formatted for visualization by lapop_ts
#'
#' @examples
#'
#' \dontrun{lpr_ts(jam23,
#' outcome = "ing4",
#' use_wave = TRUE,
#' mean = TRUE,
#' ttest = TRUE)}
#'
#'@export
#'@import dplyr
#'@import srvyr
#'
#'@author Berta Diaz, \email{berta.diaz.martinez@@vanderbilt.edu} &
#' Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}



lpr_ts <- function(data,
                   outcome,
                   rec = c(1, 1),
                   use_wave = FALSE,
                   ci_level = 0.95,
                   mean = FALSE,
                   filesave = "",
                   cfmt = "",
                   ttest = FALSE,
                   keep_nr = FALSE) {


  # If keep_nr is TRUE, convert don't knows (NA(a)) and no answers (NA(b)) to
  # non-NA data (a value of 99).
  if (keep_nr) {
    data <- data %>%
      mutate(!!sym(outcome) := case_when(
        na_tag(!!sym(outcome)) %in% c("a", "b") ~ 99,
        TRUE ~ as.numeric(!!sym(outcome))
      ))
  }


  ts_df <- data %>%
    group_by(wave = if (use_wave) as.character(as_factor(wave)) else year) %>%
    {
      if (mean) {
        summarize(.,
                  prop = survey_mean(!!sym(outcome),
                                     na.rm = TRUE,
                                     vartype = "ci",
                                     level = ci_level)) %>%
          mutate(proplabel = if (cfmt != "") {
            sprintf(cfmt, prop)
          } else {
            sprintf("%.1f", prop)
          })
      } else {
        summarize(.,
                  prop = survey_mean(between(!!sym(outcome), rec[1], rec[2]),
                                     na.rm = TRUE,
                                     vartype = "ci",
                                     level = ci_level) * 100) %>%
          mutate(proplabel = if (cfmt != "") {
            sprintf(cfmt, round(prop))
          } else {
            sprintf("%.0f%%", round(prop))
          })}
    } %>%
    filter(prop != 0) %>%
    rename(lb = prop_low, ub = prop_upp)


  if (ttest) {

    ts_df <- ts_df %>%
      mutate(se = (ub - lb) / (2 * 1.96))

    t_test_results <- data.frame(
      test = character(),
      diff = numeric(),
      t_stat = numeric(),
      p_value = numeric(),
      stringsAsFactors = FALSE
    )

    for (i in 1:(nrow(ts_df) - 1)) {
      for (j in (i + 1):nrow(ts_df)) {
        prop1 <- ts_df$prop[i]
        se1 <- ts_df$se[i]
        prop2 <- ts_df$prop[j]
        se2 <- ts_df$se[j]

        diff <- prop1 - prop2
        t_stat <- diff / sqrt(se1^2 + se2^2)
        df <- (se1^2 + se2^2)^2 /
          ((se1^2)^2 / (nrow(ts_df) - 1) + (se2^2)^2 / (nrow(ts_df) - 1))
        p_value <- 2 * pt(-abs(t_stat), df)

        t_test_results <- rbind(
          t_test_results,
          data.frame(
            test = paste0("Wave ", ts_df$wave[i], " vs Wave ", ts_df$wave[j]),
            diff = diff,
            t_stat = t_stat,
            p_value = p_value
          )
        )
      }
    }

    attr(ts_df, "t_test_results") <- t_test_results
  }


  if (filesave != "") {
    write.csv(ts_df, filesave, row.names = FALSE)
  }

  return(ts_df)
}



