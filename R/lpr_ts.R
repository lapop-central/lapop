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
#' an answer of 5, 6, 7 out of all valid answers.  Can also supply one value only,
#' to produce the percentage that chose that value out of all other values.
#' Default: c(1, 1).
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

  if (length(rec) == 1) {
    rec = c(rec, rec)
  }


  ts_df <- data %>%
    group_by(wave = if (use_wave) as.character(as_factor(wave)) else as.character(year)) %>%
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

  # Below chunks add missing values for wave to the time series
  all_waves <- data.frame(
    wave = if (use_wave) {
      c("2004", "2006", "2008", "2010", "2012",
        "2014", "2016/17", "2018/19", "2021", "2023")
    } else {
      c("2004", "2006", "2008", "2010", "2012",
        "2014", "2016", "2017", "2016/17", "2018",
        "2019", "2018/19", "2021", "2023")
    }
  )

  ts_df = merge(ts_df, all_waves,
                by = "wave",
                all.x = TRUE,
                all.y = TRUE)

  # If missing prop at either end of the series, delete
  na_rows = apply(ts_df, 1, function(row) any(is.na(row)))
  first_non_na = which(!na_rows)[1]
  last_non_na = which(!na_rows)[length(which(!na_rows))]
  ts_df = ts_df[first_non_na:last_non_na, ]

  #Ugly code to handle 2016/17 and 2018/19 when using "year"
  # if using year (use_wave = FALSE), and 2016/17 wave is missing,
  # the graph should display "2016/17" (not "2016" and "2017") with no data
  # same for 2018/19
  if (!use_wave) {
    if (is.na(ts_df$prop[ts_df$wave == "2016"]) &
        is.na(ts_df$prop[ts_df$wave == "2017"])) {
      ts_df = ts_df[-(which(ts_df$wave %in% c("2016", "2017"))),]
    } else if (!is.na(ts_df$prop[ts_df$wave == "2016"])) {
      ts_df = ts_df[-(which(ts_df$wave %in% c("2017", "2016/17"))),]
    } else if (!is.na(ts_df$prop[ts_df$wave == "2017"])) {
      ts_df = ts_df[-(which(ts_df$wave %in% c("2016", "2016/17"))),]
    }

    if (is.na(ts_df$prop[ts_df$wave == "2018"]) &
        is.na(ts_df$prop[ts_df$wave == "2019"])) {
      ts_df = ts_df[-(which(ts_df$wave %in% c("2018", "2019"))),]
    } else if (!is.na(ts_df$prop[ts_df$wave == "2018"])) {
      ts_df = ts_df[-(which(ts_df$wave %in% c("2019", "2018/19"))),]
    } else if (!is.na(ts_df$prop[ts_df$wave == "2019"])) {
      ts_df = ts_df[-(which(ts_df$wave %in% c("2018", "2018/19"))),]
    }
  }


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
            diff = round(diff, 3),
            t_stat = round(t_stat, 3),
            p_value = round(p_value, 3)
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



