######################################################

# LAPOP "Dumbbell" Graph Pre-Processing #

######################################################

#' LAPOP Dumbbell Graphs
#'
#' This function creates dataframes which can then be input in lapop_dumb for
#' comparing means of a variable across countries and two waves using LAPOP formatting.

#' @param data A survey object.  The data that should be analyzed.
#' @param outcome Outcome variable(s) of interest to be plotted across countries
#' and waves, supplied as a character string or vector of strings.
#' @param xvar Character. The grouping variable to be plotted
#' along the x-axis (technically, the vertical axis for lapop_dumb). Usually
#' country (pais). Default: "pais".
#' @param over Numeric. A vector of values for "wave" that specify which two
#' waves should be included in the plot.
#' @param rec Numeric. The minimum and maximum values of the outcome variable that
#' should be included in the numerator of the percentage.  For example, if the variable
#' is on a 1-7 scale and rec is c(5, 7), the function will show the percentage who chose
#' an answer of 5, 6, 7 out of all valid answers.  Can also supply one value only,
#' to produce the percentage that chose that value out of all other values.
#' Default: c(1, 1).
#' @param ci_level Numeric. Confidence interval level for estimates.  Default: 0.95
#' @param mean Logical.  If TRUE, will produce the mean of the variable rather than
#' recoding to percentage.  Default: FALSE.
#' @param filesave Character.  Path and file name to save the dataframe as csv.
#' @param cfmt Character. Changes the format of the numbers displayed above the bars.
#' Uses sprintf string formatting syntax. Default is whole numbers for percentages
#' and tenths place for means.
#' @param sort Character. On what value the bars are sorted.
#' Options are "prop1" (for the value of the outcome variable in wave 1), "prop2"
#' (default; for the value of the outcome variable in wave 2), "xv" (for
#' the underlying values of the x variable), "xl" (for the labels of the x variable,
#' i.e., alphabetical), and "diff" (for the difference between the outcome between
#' the two waves).
#' @param order Character.  How the bars should be sorted.  Options are "hi-lo"
#' (default) or "lo-hi".
#' @param ttest Logical.  If TRUE, will conduct pairwise t-tests for difference
#' of means between all pais-wave combinations and save them in attr(x,
#' "t_test_results"). Default: FALSE.
#' @param keep_nr Logical.  If TRUE, will convert "don't know" (missing code .a)
#' and "no response" (missing code .b) into valid data (value = 99) and use them
#' in the denominator when calculating percentages.  The default is to examine
#' valid responses only.  Default: FALSE.
#'
#'
#' @return Returns a data frame, with data formatted for visualization by lapop_dumb
#'
#' @examples
#' \dontrun{
#'  # Single outcome over years
#' lpr_dumb(ym2123,
#' outcome = "ing4",
#' rec = c(5, 7),
#' over = c(2021, 2023),
#' sort = "diff",
#' ttest = TRUE)}
#'
#' # Multiple outcomes over years
#'\dontrun{lpr_dumb(ym2123,
#' outcome=c("b21", "b13", "b31", "b47a"),
#' rec=c(5,7),
#' over=c(2021, 2023))}
#'
#'@export
#'@import dplyr
#'@import tidyr
#'@import srvyr
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} && Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}

lpr_dumb <- function(data,
                     outcome,
                     xvar = "pais",
                     over,
                     rec = c(1, 1),
                     ci_level = 0.95,
                     mean = FALSE,
                     filesave = "",
                     cfmt = "",
                     sort = "prop2",
                     order = "hi-lo",
                     ttest = FALSE,
                     keep_nr = FALSE) {

  if (length(rec) == 1) rec <- c(rec, rec)

  if (length(outcome) > 1) {
    results_list <- lapply(outcome, function(out) {
      tmp <- data
      if (keep_nr) {
        tmp <- tmp %>%
          mutate(!!sym(out) := case_when(
            na_tag(!!sym(out)) %in% c("a", "b") ~ 99,
            TRUE ~ as.numeric(!!sym(out))
          ))
      }

      wave1 <- tmp %>%
        filter(wave == over[1]) %>%
        group_by(wave1 = as.character(as_factor(wave))) %>%
        {
          if (mean) {
            summarize(.,
                      prop1 = survey_mean(!!sym(out), na.rm = TRUE, vartype = "ci", level = ci_level)) %>%
              mutate(proplabel1 = if (cfmt != "") sprintf(cfmt, prop1) else sprintf("%.1f", prop1))
          } else {
            summarize(.,
                      prop1 = survey_mean(between(!!sym(out), rec[1], rec[2]), na.rm = TRUE,
                                          vartype = "ci", level = ci_level) * 100) %>%
              mutate(proplabel1 = if (cfmt != "") sprintf(cfmt, round(prop1)) else sprintf("%.0f%%", round(prop1)))
          }
        } %>%
        rename(lb1 = prop1_low, ub1 = prop1_upp)

      wave2 <- tmp %>%
        filter(wave == over[2]) %>%
        group_by(wave2 = as.character(as_factor(wave))) %>%
        {
          if (mean) {
            summarize(.,
                      prop2 = survey_mean(!!sym(out), na.rm = TRUE, vartype = "ci", level = ci_level)) %>%
              mutate(proplabel2 = if (cfmt != "") sprintf(cfmt, prop2) else sprintf("%.1f", prop2))
          } else {
            summarize(.,
                      prop2 = survey_mean(between(!!sym(out), rec[1], rec[2]), na.rm = TRUE,
                                          vartype = "ci", level = ci_level) * 100) %>%
              mutate(proplabel2 = if (cfmt != "") sprintf(cfmt, round(prop2)) else sprintf("%.0f%%", round(prop2)))
          }
        } %>%
        rename(lb2 = prop2_low, ub2 = prop2_upp)

      full <- merge(wave1, wave2, by = character(0))  # no common vars to merge
      full$pais <- attr(tmp[[out]], "label") %||% out
      return(full)
    })

    dumb <- bind_rows(results_list) %>%
      relocate(pais, wave1, prop1, proplabel1, wave2, prop2, proplabel2)

  } else {
    out <- outcome
    if (keep_nr) {
      data <- data %>%
        mutate(!!sym(out) := case_when(
          na_tag(!!sym(out)) %in% c("a", "b") ~ 99,
          TRUE ~ as.numeric(!!sym(out))
        ))
    }

    wave1 <- data %>%
      drop_na(!!sym(xvar)) %>%
      filter(wave == over[1]) %>%
      group_by(pais = as_factor(!!sym(xvar)),
               wave1 = as.character(as_factor(wave))) %>%
      {
        if (mean) {
          summarize(.,
                    prop1 = survey_mean(!!sym(out), na.rm = TRUE, vartype = "ci", level = ci_level)) %>%
            mutate(proplabel1 = if (cfmt != "") sprintf(cfmt, prop1) else sprintf("%.1f", prop1))
        } else {
          summarize(.,
                    prop1 = survey_mean(between(!!sym(out), rec[1], rec[2]), na.rm = TRUE,
                                        vartype = "ci", level = ci_level) * 100) %>%
            mutate(proplabel1 = if (cfmt != "") sprintf(cfmt, round(prop1)) else sprintf("%.0f%%", round(prop1)))
        }
      } %>%
      rename(lb1 = prop1_low, ub1 = prop1_upp)

    wave2 <- data %>%
      drop_na(!!sym(xvar)) %>%
      filter(wave == over[2]) %>%
      group_by(pais = as_factor(!!sym(xvar)),
               wave2 = as.character(as_factor(wave))) %>%
      {
        if (mean) {
          summarize(.,
                    prop2 = survey_mean(!!sym(out), na.rm = TRUE, vartype = "ci", level = ci_level)) %>%
            mutate(proplabel2 = if (cfmt != "") sprintf(cfmt, prop2) else sprintf("%.1f", prop2))
        } else {
          summarize(.,
                    prop2 = survey_mean(between(!!sym(out), rec[1], rec[2]), na.rm = TRUE,
                                        vartype = "ci", level = ci_level) * 100) %>%
            mutate(proplabel2 = if (cfmt != "") sprintf(cfmt, round(prop2)) else sprintf("%.0f%%", round(prop2)))
        }
      } %>%
      rename(lb2 = prop2_low, ub2 = prop2_upp)

    dumb <- merge(wave1, wave2, by = "pais")
  }

 dumb = dumb %>%
  {
    if (sort == "prop1") {
      if (order == "hi-lo") {
        arrange(., desc(prop1))
      } else if (order == "lo-hi") {
        arrange(., prop1)
      }
    } else if (sort == "prop2") {
      if (order == "hi-lo") {
        arrange(., desc(prop2))
      } else if (order == "lo-hi") {
        arrange(., prop2)
      }
    } else if (sort == "xv") {
      if (order == "hi-lo") {
        arrange(., desc(match(pais, levels(pais))))
      } else if (order == "lo-hi") {
        arrange(., match(pais, levels(pais)))
      }
    } else if (sort == "diff") {
      if (order == "hi-lo") {
        mutate(., diff = prop2 - prop1) %>%
          arrange(., desc(diff))
      } else if (order == "lo-hi") {
        mutate(., diff = prop2 - prop1) %>%
          arrange(., diff)
      }
    } else if (sort == "xl") {
      if (order == "hi-lo") {
        arrange(., desc(as.character(xvar)))
      } else if (order == "lo-hi") {
        arrange(., as.character(xvar))
      } else {
        .  # Return unchanged
      }
    }
  }


  if (ttest) {
    # Compute standard errors
    t_test_results <- dumb %>%
      mutate(se1 = (ub1 - lb1) / (2 * 1.96),
             se2 = (ub2 - lb2) / (2 * 1.96))

    # Initialize an empty dataframe for storing test results
    t_test_results_df <- data.frame(test = character(),
                                    diff = numeric(),
                                    ttest = numeric(),
                                    pval = numeric(),
                                    stringsAsFactors = FALSE)

    # Within-country t-tests: Compare prop1 vs. prop2 for each country
    for (i in 1:nrow(t_test_results)) {
      diff <- round(t_test_results$prop1[i] - t_test_results$prop2[i], 3)
      t_stat <- round(diff / sqrt(t_test_results$se1[i]^2 + t_test_results$se2[i]^2), 3)
      df <- (t_test_results$se1[i]^2 + t_test_results$se2[i]^2)^2 /
        ((t_test_results$se1[i]^4 / (nrow(data) - 1)) + (t_test_results$se2[i]^4 / (nrow(data) - 1)))
      p_value <- round(2 * pt(-abs(t_stat), df), 3)

      t_test_results_df <- rbind(t_test_results_df,
                                 data.frame(test = paste(t_test_results$pais[i], t_test_results$wave1[i], "vs",
                                                         t_test_results$pais[i], t_test_results$wave2[i]),
                                            diff = diff,
                                            ttest = t_stat,
                                            pval = p_value))
    }

    # Pairwise comparisons across all rows for prop1
    for (i in 1:(nrow(t_test_results) - 1)) {
      for (j in (i + 1):nrow(t_test_results)) {
        diff <- round(t_test_results$prop1[i] - t_test_results$prop1[j], 3)
        t_stat <- round(diff / sqrt(t_test_results$se1[i]^2 + t_test_results$se1[j]^2), 3)
        df <- (t_test_results$se1[i]^2 + t_test_results$se1[j]^2)^2 /
          ((t_test_results$se1[i]^4 / (nrow(data) - 1)) + (t_test_results$se1[j]^4 / (nrow(data) - 1)))
        p_value <- round(2 * pt(-abs(t_stat), df), 3)

        t_test_results_df <- rbind(t_test_results_df,
                                   data.frame(test = paste(t_test_results$pais[i], t_test_results$wave1[i], "vs",
                                                           t_test_results$pais[j], t_test_results$wave1[j]),
                                              diff = diff,
                                              ttest = t_stat,
                                              pval = p_value))
      }
    }

    # Pairwise comparisons across all rows for prop2
    for (i in 1:(nrow(t_test_results) - 1)) {
      for (j in (i + 1):nrow(t_test_results)) {
        diff <- round(t_test_results$prop2[i] - t_test_results$prop2[j], 3)
        t_stat <- round(diff / sqrt(t_test_results$se2[i]^2 + t_test_results$se2[j]^2), 3)
        df <- (t_test_results$se2[i]^2 + t_test_results$se2[j]^2)^2 /
          ((t_test_results$se2[i]^4 / (nrow(data) - 1)) + (t_test_results$se2[j]^4 / (nrow(data) - 1)))
        p_value <- round(2 * pt(-abs(t_stat), df), 3)

        t_test_results_df <- rbind(t_test_results_df,
                                   data.frame(test = paste(t_test_results$pais[i], t_test_results$wave2[i], "vs",
                                                           t_test_results$pais[j], t_test_results$wave2[j]),
                                              diff = round(diff, 3),
                                              ttest = round(t_stat, 3),
                                              pval = round(p_value, 3)))
      }
    }

    # Store the results as an attribute
    attr(dumb, "t_test_results") <- t_test_results_df
  }


  if (filesave != "") write.csv(dumb, filesave, row.names = FALSE)
  return(dumb)
}
