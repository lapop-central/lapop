######################################################

# LAPOP "Multiple-Over" Breakdown Graph Pre-Processing #

######################################################

#' LAPOP "Multiple-Over" Breakdown Graphs
#'
#' This function creates a dataframe which can then be input in lapop_mover() for
#' comparing means across values of secondary variable(s) using LAPOP formatting.
#'
#' @param data A survey object. The data that should be analyzed.
#' @param outcome Character. Outcome variable(s) of interest to be plotted across secondary
#' variable(s).
#' @param grouping_vars A character vector specifying one or more grouping variables.
#' For each variable, the function calculates the average of the outcome variable,
#' broken down by the distinct values within the grouping variable(s).
#' @param rec Numeric. The minimum and maximum values of the frst outcome variable that
#' should be included in the numerator of the percentage.  For example, if the variable
#' is on a 1-7 scale and rec is c(5, 7), the function will show the percentage who chose
#' an answer of 5, 6, 7 out of all valid answers.  Can also supply one value only,
#' to produce the percentage that chose that value out of all other values.
#' Default: c(1, 1).
#' @param rec2 Numeric. Similar to 'rec' for the second outcome. Default: c(1, 1).
#' @param rec3 Numeric.  Similar to 'rec' for the third outcome. Default: c(1, 1).
#' @param rec4 Numeric.  Similar to 'rec' for the fourth outcome. Default: c(1, 1).
#' @param ci_level Numeric. Confidence interval level for estimates.  Default: 0.95
#' @param mean Logical.  If TRUE, will produce the mean of the variable rather than
#' recoding to percentage.  Default: FALSE.
#' @param filesave Character.  Path and file name to save the dataframe as csv.
#' @param cfmt Changes the format of the numbers displayed above the bars.
#' Uses sprintf string formatting syntax. Default is whole numbers for percentages
#' and tenths place for means.
#' @param ttest Logical.  If TRUE, will conduct pairwise t-tests for difference
#' of means between all individual year-xvar levels and save them in attr(x,
#' "t_test_results"). Default: FALSE.
#' @param keep_nr Logical.  If TRUE, will convert "don't know" (missing code .a)
#' and "no response" (missing code .b) into valid data (value = 99) and use them
#' in the denominator when calculating percentages.  The default is to examine
#' valid responses only.  Default: FALSE.
#'
#'
#' @return Returns a data frame, with data formatted for visualization by lapop_mover
#'
#' @examples
#'
#' # Single Outcome
#' \dontrun{lpr_mover(data = gm23,
#'  outcome = "ing4",
#'  grouping_vars = c("q1tc_r", "edad", "edre", "wealth"),
#'  rec = c(5, 7)}
#'
#'  # Multiple Outcomes
#'  \dontrun{lpr_mover(data = gm23,
#'  outcome = "c(ing4", "pn4"),
#'  grouping_vars = c("q1tc_r", "edad", "edre", "wealth"),
#'  rec = c(5, 7), rec2 = c(1, 2)}
#'
#' # Single DV X Single IV
#' \dontrun{lpr_mover(data,
#' outcome="ing4",
#' grouping_vars="exc7new",
#' rec=c(5,7), ttest=T)}
#'
#' # Multiple DVs X Single IV
#' \dontrun{lpr_mover(data,
#' outcome=c("ing4", "pn4"),
#' grouping_vars="exc7new",
#' rec=c(5,7), rec2=c(1,2), ttest=T)}
#'
#' # Single DV X Multiple IVs
#' \dontrun{lpr_mover(data,
#' outcome="ing4",
#' grouping_vars=c("edre", "q1tc_r"),
#' rec=c(5,7), ttest=T)}
#'
#' # Multiple DVs X Multiple IVs
#' \dontrun{lpr_mover(data,
#' outcome=c("ing4", "pn4"),
#' grouping_vars=c("edre", "q1tc_r"),
#' rec=c(5,7), rec2=c(1,2), ttest=T)}
#'
#'@export
#'@import dplyr
#'@import srvyr
#'@import purrr
#'@import haven
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} && Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}

lpr_mover <- function(data,
                      outcome,
                      grouping_vars,
                      rec = list(c(1, 1)),
                      rec2 = c(1, 1),
                      rec3 = c(1, 1),
                      rec4 = c(1, 1),
                      ci_level = 0.95,
                      mean = FALSE,
                      filesave = "",
                      cfmt = "",
                      ttest = FALSE,
                      keep_nr = FALSE) {

  if (keep_nr) {
    data <- data %>%
      mutate(across(all_of(outcome), ~ case_when(
        na_tag(.data) == "a" | na_tag(.) == "b" ~ 99,
        TRUE ~ as.numeric(.data)
      )))
  }

  rec_list <- list(rec, rec2, rec3, rec4)
  rec_list <- rec_list[seq_along(outcome)] # Ensure only as many rec values as outcomes

  # Function to calculate means/proportions for a single outcome and grouping variable
  calculate_means <- function(data, outcome_var, grouping_var, rec_range, single_outcome) {
    data %>%
      drop_na(.data[[grouping_var]]) %>%
      group_by(vallabel = as_factor(.data[[grouping_var]])) %>%
      {
        if (mean) {
          summarize(.data,
                    prop = survey_mean(.data[[outcome_var]],
                                       na.rm = TRUE,
                                       vartype = "ci",
                                       level = ci_level)
          ) %>%
            mutate(proplabel = sprintf("%.1f", prop))
        } else {
          summarize(.data,
                    prop = survey_mean(between(.data[[outcome_var]], rec_range[1], rec_range[2]),
                                       na.rm = TRUE,
                                       vartype = "ci",
                                       level = ci_level) * 100
          ) %>%
            mutate(proplabel = sprintf("%.0f%%", round(prop)))
        }
      } %>%
      mutate(
        outcome = if (!is.null(attributes(data$variables[[outcome_var]])$label)) {
          attributes(data$variables[[outcome_var]])$label
        } else {
          outcome_var
        },
        varlabel = if (single_outcome) {
          if (!is.null(attributes(data$variables[[grouping_var]])$label)) {
            attributes(data$variables[[grouping_var]])$label
          } else {
            grouping_var
          }
        } else {
          paste(grouping_var, outcome_var, sep = " x ")
        },
        vallabel = as.character(vallabel)
      ) %>%
      rename(lb = prop_low, ub = prop_upp) %>%
      select(outcome, varlabel, vallabel, prop, proplabel, lb, ub)
  }

  single_outcome <- length(outcome) == 1

  # Apply function to each combination of outcome and grouping variable
  mover <- map_dfr(grouping_vars, function(gvar) {
    map2_dfr(outcome, rec_list, ~ calculate_means(data, .x, gvar, .y, single_outcome))
  })

  if (filesave != "") {
    write.csv(mover, filesave)
  }

  # Conduct pairwise t-tests if requested
  if (ttest) {
    mover <- mover %>%
      mutate(se = (ub - lb) / (2 * 1.96))

    t_test_results <- data.frame(
      outcome = character(),
      varlabel = character(),
      test = character(),
      diff = numeric(),
      ttest = numeric(),
      pval = numeric(),
      stringsAsFactors = FALSE
    )

    outcomes <- unique(mover$outcome)
    for (oc in outcomes) {
      mover_subset <- mover %>% filter(outcome == oc)

      varlabels <- unique(mover_subset$varlabel)
      for (vl in varlabels) {
        group_subset <- mover_subset %>% filter(varlabel == vl)

        for (i in 1:(nrow(group_subset) - 1)) {
          for (j in (i + 1):nrow(group_subset)) {
            prop1 <- group_subset$prop[i]
            se1 <- group_subset$se[i]
            prop2 <- group_subset$prop[j]
            se2 <- group_subset$se[j]

            diff <- prop1 - prop2
            t_stat <- diff / sqrt(se1^2 + se2^2)
            df <- (se1^2 + se2^2)^2 / ((se1^2)^2 / (nrow(data) - 1) + (se2^2)^2 / (nrow(data) - 1))

            p_value <- 2 * pt(-abs(t_stat), df)

            t_test_results <- rbind(t_test_results,
                                    data.frame(outcome = oc,
                                               varlabel = vl,
                                               test = paste(group_subset$vallabel[i], "vs", group_subset$vallabel[j]),
                                               diff = round(diff, 3),
                                               ttest = round(t_stat, 3),
                                               pval = round(p_value, 3)))
          }
        }
      }
    }

    attr(mover, "t_test_results") <- t_test_results
  }

  return(mover)
}
