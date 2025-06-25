#######################################

# LAPOP Cross-Country Bar Graph Pre-Processing #

#######################################

#' LAPOP Cross-Country Bar Graph Pre-Processing
#'
#' This function creates dataframes which can then be input in lapop_cc for
#' comparing values across countries with a bar graph using LAPOP formatting.
#'
#' @param data A survey object.  The data that should be analyzed.
#' @param outcome Outcome variable(s) of interest to be plotted across countries.
#' It can handle a single variable across countries, or multiple variables instead of multiple countries. See examples below.
#' @param xvar Grouping variable. Default: pais_lab. It can handle other variables grouping like year/wave.
#' @param rec Numeric. The minimum and maximum values of the outcome variable that
#' should be included in the numerator of the percentage.  For example, if the variable
#' is on a 1-7 scale and rec is c(5, 7), the function will show the percentage who chose
#' an answer of 5, 6, 7 out of all valid answers.  Default: c(1, 1).
#' @param rec2 Numeric. Same as rec(). Default: c(1, 1).
#' @param rec3 Numeric. Same as rec(). Default: c(1, 1).
#' @param rec4 Numeric. Same as rec(). Default: c(1, 1).
#' @param ci_level Numeric. Confidence interval level for estimates.  Default: 0.95
#' @param mean Logical.  If TRUE, will produce the mean of the variable rather than
#' rescaling to percentage.  Default: FALSE.
#' @param filesave Character.  Path and file name to save the dataframe as csv.
#' @param cfmt changes the format of the numbers displayed above the bars.
#' Uses sprintf string formatting syntax. Default is whole numbers for percentages
#' and tenths place for means.
#' @param sort Character. On what value the bars are sorted: the x or the y.
#' Options are "y" (default; for the value of the outcome variable), "xv" (for
#' the underlying values of the x variable), "xl" (for the labels of the x variable,
#' i.e., alphabetical).
#' @param order Character.  How the bars should be sorted.  Options are "hi-lo"
#' (default) or "lo-hi".
#' @param ttest Logical.  If TRUE, will conduct pairwise t-tests for difference
#' of means between all individual x levels and save them in attr(x,
#' "t_test_results"). Default: FALSE.
#' @param keep_nr Logical.  If TRUE, will convert "don't know" (missing code .a)
#' and "no response" (missing code .b) into valid data (value = 99) and use them
#' in the denominator when calculating percentages.  The default is to examine
#' valid responses only.  Default: FALSE.
#'
#'
#' @return Returns a data frame, with data formatted for visualization by lapop_cc
#'
#' @examples
#'
#' \dontrun{lpr_cc(data = cm23,
#' outcome = "ing4",
#' rec = c(5, 7),
#' xvar = "pais_lab")}
#'
#' \dontrun{lpr_cc(data = cm23,
#' outcome = c("sd2new2", "sd3new2", "sd5new2", "sd6new2"),
#' rec = c(5, 7))}
#'
#'@export
#'@import dplyr
#'@import srvyr
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} && Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}
lpr_cc <- function(data,
                   outcome,
                   xvar = "pais_lab",
                   rec = list(c(1, 1)),
                   rec2 = list(c(1, 1)),
                   rec3 = list(c(1, 1)),
                   rec4 = list(c(1, 1)),
                   ci_level = 0.95,
                   mean = FALSE,
                   filesave = "",
                   cfmt = "",
                   sort = "y",
                   order = "hi-lo",
                   ttest = FALSE,
                   keep_nr = FALSE) {

  outcome_vars <- syms(outcome)  # Convert character vector to symbols for svryr

  if (length(outcome) > 1) {
    xvar <- NULL  # Disable grouping variable when multiple outcomes are used
  }

  if (length(rec) == 2 && all(sapply(rec, is.numeric))) {
    rec <- rep(list(rec), length(outcome_vars))  # Expand rec to a list
  }

  if (length(rec) < length(outcome_vars)) {
    stop("Length of rec must match number of outcome variables.")
  }

  results_list <- list()

  for (i in seq_along(outcome_vars)) {
    curr_outcome <- outcome_vars[[i]]
    curr_rec <- rec[[i]]

    if (keep_nr) {
      data_modified <- data %>%
        mutate(!!curr_outcome := case_when(
          na_tag(!!curr_outcome) == "a" | na_tag(!!curr_outcome) == "b" ~ 99,
          TRUE ~ as.numeric(!!curr_outcome)
        ))
    } else {
      data_modified <- data
    }

    cc <- data_modified %>%
      {
        if (!is.null(xvar)) {
          # Use filter and group_by directly
          filter(., !is.na(!!sym(xvar))) %>%
            group_by(vallabel = as_factor(!!sym(xvar)))
        } else {
          mutate(., vallabel = outcome[i])  # Assign outcome name when xvar is NULL
        }
      } %>%
      group_by(vallabel) %>%  # Ensure grouping happens regardless
      {
        if (mean) { # mean=TRUE calculation
          summarize(., prop = survey_mean(!!curr_outcome, na.rm = TRUE, vartype = "ci", level = ci_level)) %>%
            mutate(proplabel = case_when(cfmt != "" ~ sprintf("%.1f", prop),
                                         TRUE ~ sprintf("%.1f", prop)))
        } else { # percentages calculation
          summarize(., prop = survey_mean(between(!!curr_outcome, curr_rec[1], curr_rec[2]),
                                          na.rm = TRUE, vartype = "ci", level = ci_level) * 100) %>%
            mutate(proplabel = case_when(cfmt != "" ~ sprintf("%.0f%%", round(prop)),
                                         TRUE ~ sprintf("%.0f%%", round(prop))))
        }
      } %>%
      filter(prop != 0) %>%
      rename(lb = prop_low, ub = prop_upp) %>%
      ungroup()

    results_list[[i]] <- cc
  }

  final_results <- bind_rows(results_list) %>%
    select(vallabel, prop, proplabel, lb, ub)  # Reorder columns

  # Reordering results if needed
  if (sort == "y") {
    if (order == "hi-lo") {
      final_results <- final_results %>% arrange(desc(prop))
    } else if (order == "lo-hi") {
      final_results <- final_results %>% arrange(prop)
    }
  }

  # Perform t-tests if ttest = TRUE
  if (ttest) {
    final_results <- final_results %>%
      mutate(se = (ub - lb) / (2 * 1.96))   # Add standard error (se) column

    t_test_results <- data.frame(test = character(), diff = numeric(),
                                 ttest = numeric(), pval = numeric(), stringsAsFactors = FALSE)
    for (i in 1:(nrow(final_results) - 1)) {
      for (j in (i + 1):nrow(final_results)) {
        prop1 <- final_results$prop[i]
        se1 <- final_results$se[i]
        prop2 <- final_results$prop[j]
        se2 <- final_results$se[j]
        diff <- prop1 - prop2
        t_stat <- diff / sqrt(se1^2 + se2^2)
        df <- (se1^2 + se2^2)^2 / ((se1^2)^2 / (nrow(data) - 1) + (se2^2)^2 / (nrow(data) - 1))
        p_value <- 2 * pt(-abs(t_stat), df)
        t_test_results <- rbind(t_test_results,
                                data.frame(test = paste(final_results$vallabel[i], "vs", final_results$vallabel[j]),
                                           diff = diff,
                                           ttest = t_stat,
                                           pval = p_value))
      }
    }

    # Attach t-test results as an attribute to final_results
    attr(final_results, "t_test_results") <- t_test_results
  }

  # Filesaving
  if (filesave != "") {
    if (!dir.exists(dirname(filesave))) {
      dir.create(dirname(filesave), recursive = TRUE)
    }
    write.csv(final_results, filesave)
  }

  # Output
  return(final_results)
}
