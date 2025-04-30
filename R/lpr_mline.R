#######################################

# LAPOP Multi-Line Time Series Graph Pre-Processing #

#######################################

#' LAPOP Multi-Line Time Series Graph Pre-Processing
#'
#'This function creates a dataframe which can then be input in lapop_mline for
#' to show a time series plot with multiple lines.  If one "outcome" variable and an
#' "xvar" variable is supplied, the function produces the values of a single outcome
#' variable, broken down by a secondary variable, across time.  If multiple outcome
#' variables (up to four) are supplied, it will show means/percentages of those
#' variables across time (essentially, it allows you to do lpr_ts for multiple variables).
#'
#' @param data A survey object.  The data that should be analyzed.
#' @param outcome Character vector.  Outcome variable(s) of interest to be plotted
#' across time.  If only one value is provided, the graph will show the outcome
#' variable, over time, broken down by a secondary variable (x-var).
#' If more than one value is supplied, the graph will show each outcome variable
#' across time (no secondary variable).
#' @param rec,rec2,rec3,rec4 Numeric. The minimum and maximum values of the outcome
#' variable that should be included in the numerator of the percentage.
#' For example, if the variable is on a 1-7 scale and rec is c(5, 7), the
#' function will show the percentage who chose an answer of 5, 6, 7 out of
#' all valid answers.  Can also supply one value only, to produce the percentage
#' that chose that value out of all other values. Default: c(1, 1).
#' @param xvar Character. Variable on which to break down the outcome variable.
#' In other words, the line graph will produce multiple lines for each value of
#' xvar (technically, it is the z-variable, not the x variable, which is year/wave).
#' Ignored if multiple outcome variables are supplied.
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
#' @return Returns a data frame, with data formatted for visualization by lapop_mline
#'
#' @examples
#'
#' \dontrun{lpr_mline_mv(ttots,
#' outcome = c("ing4", "pn4", "b2", "vic1ext"),
#' rec = c(5, 7),
#' rec2 = c(1, 2),
#' rec3 = c(5, 7),
#' rec4 = c(1, 1),
#' use_wave = TRUE)}
#'
#'@export
#'@import dplyr
#'@import srvyr
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}

lpr_mline <- function(data,
                   outcome,
                   rec = c(1, 1),
                   rec2 = c(1, 1),
                   rec3 = c(1, 1),
                   rec4 = c(1, 1),
                   xvar,
                   use_wave = FALSE,
                   ci_level = 0.95,
                   mean = FALSE,
                   filesave = "",
                   cfmt = "",
                   ttest = FALSE,
                   keep_nr = FALSE) {

  if (length(rec) == 1) {
    rec = c(rec, rec)
  }

  if (length(outcome) > 1) {

    if (length(rec2) == 1) {
      rec2 = c(rec2, rec2)
    }
    if (length(rec3) == 1) {
      rec3 = c(rec3, rec3)
    }
    if (length(rec4) == 1) {
      rec4 = c(rec4, rec4)
    }

    rec_list = list(rec, rec2, rec3, rec4)

    result_list <- list()

    for (var in outcome) {
      temp <- lpr_ts(data = data,
                     outcome = var,
                     rec = rec_list[[which(outcome == var)]],
                     use_wave = use_wave,
                     mean = mean,
                     cfmt = cfmt,
                     keep_nr = keep_nr)
      temp$varlabel <- attributes(data$variables[[var]])$label
      result_list[[var]] <- temp
    }

    mline <- do.call(rbind, result_list)

    # Ensure all waves are present for each varlabel
    all_waves <- unique(mline$wave)
    all_varlabels <- unique(mline$varlabel)

    full_grid <- expand.grid(wave = all_waves, varlabel = all_varlabels, stringsAsFactors = FALSE)

    mline <- full_grid %>%
      left_join(mline, by = c("wave", "varlabel")) %>%
      arrange(varlabel, wave)

    row.names(mline) <- NULL

    if ("2016" %in% mline$wave | "2017" %in% mline$wave) {
      mline = mline %>%
        filter(wave != "2016/17")
    }

    if ("2018" %in% mline$wave | "2019" %in% mline$wave) {
      mline = mline %>%
        filter(wave != "2018/19")
    }


  } else {

    # If keep_nr is TRUE, convert don't knows (NA(a)) and no answers (NA(b)) to
    # non-NA data (a value of 99).
    if (keep_nr) {
      data = data %>%
        mutate(!!outcome := case_when(
          na_tag(!!outcome) == "a" | na_tag(!!outcome) == "b"  ~ 99,
          TRUE ~ as.numeric(!!outcome)       # Keep other values unchanged
        ))
    }

    mline = data %>%
      drop_na(!!sym(xvar)) %>%
      group_by(varlabel = as_factor(!!sym(xvar)),
               wave = if (use_wave) as.character(as_factor(wave)) else year) %>%
      {
        if (mean) {
          summarize(.data, prop = survey_mean(!!sym(outcome),
                                          na.rm = TRUE,
                                          vartype = "ci",
                                          level = ci_level)) %>%
            mutate(proplabel = if (cfmt != "") {
              sprintf(cfmt, prop)
            } else {
              sprintf("%.1f", prop)
            })
        } else {
          summarize(.data, prop = survey_mean(between(!!sym(outcome), rec[1], rec[2]),
                                          na.rm = TRUE,
                                          vartype = "ci",
                                          level = ci_level) * 100) %>%
            mutate(proplabel = if (cfmt != "") {
              sprintf(cfmt, round(prop))
            } else {
              sprintf("%.0f%%", round(prop))
            })
        }
      } %>%
      filter(prop != 0) %>%
      rename(.data, lb = prop_low, ub = prop_upp)

  }


  # Perform pairwise t-tests for each combination of rows
  if (ttest) {
    # Estimate standard error for each row using the confidence intervals
    mline <- mline %>%
      mutate(se = (ub - lb) / (2 * 1.96))

    # Initialize an empty data frame to store t-test results
    t_test_results <- data.frame(
      test = character(),
      diff = numeric(),
      t_stat = numeric(),
      p_value = numeric(),
      stringsAsFactors = FALSE
    )

    # Perform pairwise t-tests for each combination of rows
    for (i in 1:(nrow(mline) - 1)) {
      for (j in (i + 1):nrow(mline)) {
        # Extract values for the two rows being compared
        prop1 <- mline$prop[i]
        se1 <- mline$se[i]
        prop2 <- mline$prop[j]
        se2 <- mline$se[j]

        # Calculate difference, t-statistic, and degrees of freedom
        diff <- prop1 - prop2
        t_stat <- diff / sqrt(se1^2 + se2^2)
        df <- (se1^2 + se2^2)^2 /
          ((se1^2)^2 / (nrow(mline) - 1) + (se2^2)^2 / (nrow(mline) - 1))

        # Calculate p-value
        p_value <- 2 * pt(-abs(t_stat), df)

        # Store results in a data frame
        t_test_results <- rbind(
          t_test_results,
          data.frame(
            test = paste0(
              mline$varlabel[i], mline$wave[i],
              " vs ",
              mline$varlabel[j], mline$wave[j]
            ),
            diff = round(diff, 3),
            t_stat = round(t_stat, 3),
            p_value = round(p_value, 3)
          )
        )
      }
    }

    # Add t-test results as an attribute to the dataset
    attr(mline, "t_test_results") <- t_test_results
  }


  if (filesave != "") {
    write.csv(mline, filesave, row.names = FALSE)
  }

  return(mline)
}



