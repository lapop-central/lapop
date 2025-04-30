#######################################

# LAPOP Multiple Cross-Country Bar Graph Pre-Processing #

#######################################

#' LAPOP Grouped Bar Graph Pre-Processing
#'
#' This function creates dataframes which can then be input in lapop_ccm for
#' comparing values for multiple variables across countries with a bar graph
#' using LAPOP formatting.
#'
#' @param data A survey object.  The data that should be analyzed.
#' @param outcome_vars Character vector.  Outcome variable(s) of interest to be plotted
#' across country (or other x variable). Max of 3 variables.
#' @param xvar Character string. Outcome variables are broken down by this variable.
#' Default: pais_lab.
#' @param rec1,rec2,rec3 Numeric. The minimum and maximum values of the outcome variable that
#' should be included in the numerator of the percentage.  For example, if the variable
#' is on a 1-7 scale and rec1 is c(5, 7), the function will show the percentage who chose
#' an answer of 5, 6, 7 out of all valid answers.  Can also supply one value only,
#' to produce the percentage that chose that value out of all other values.
#' Default: c(1, 1).
#' @param ci_level Numeric. Confidence interval level for estimates.  Default: 0.95
#' @param mean Logical.  If TRUE, will produce the mean of the variable rather than
#' rescaling to percentage.  Default: FALSE.
#' @param filesave Character.  Path and file name to save the dataframe as csv.
#' @param cfmt Character. Changes the format of the numbers displayed above the bars.
#' Uses sprintf string formatting syntax. Default is whole numbers for percentages
#' and tenths place for means.
#' @param sort Character. On what value the bars are sorted.
#' Options are "y" (default; for the value of the first outcome variable), "xv" (for
#' the underlying values of the x variable), "xl" (for the labels of the x variable,
#' i.e., alphabetical).
#' @param order Character.  How the bars should be sorted.  Options are "hi-lo"
#' (default) or "lo-hi".
#' @param ttest Logical.  If TRUE, will conduct pairwise t-tests for difference
#' of means between all outcomes vs. all x-vars and save them in attr(x,
#' "t_test_results"). Default: FALSE.
#' @param keep_nr Logical.  If TRUE, will convert "don't know" (missing code .a)
#' and "no response" (missing code .b) into valid data (value = 99) and use them
#' in the denominator when calculating percentages.  The default is to examine
#' valid responses only.  Default: FALSE.
#'
#'
#' @return Returns a data frame, with data formatted for visualization by lapop_ccm
#'
#' @examples
#'
#' \dontrun{lpr_ccm(gm23,
#' outcome_vars = c("vic1ext", "aoj11"),
#' rec1 = c(1, 1),
#' rec2 = c(3, 4),
#' ttest = TRUE)}
#'
#'@export
#'@import dplyr
#'@import srvyr
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}


lpr_ccm <- function(data,
                    outcome_vars,
                    xvar = "pais_lab",
                    rec1 = c(1, 1),
                    rec2 = c(1, 1),
                    rec3 = c(1, 1),
                    ci_level = 0.95,
                    mean = FALSE,
                    filesave = "",
                    cfmt = "",
                    sort = "y",
                    order = "hi-lo",
                    ttest = FALSE,
                    keep_nr = FALSE) {

  if (length(rec1) == 1) {
    rec1 = c(rec1, rec1)
  }
  if (length(rec2) == 1) {
    rec2 = c(rec2, rec2)
  }
  if (length(rec3) == 1) {
    rec3 = c(rec3, rec3)
  }

  # Map rec arguments to outcome variables
  rec_list <- list(rec1, rec2, rec3)
  rec_map <- purrr::map2(outcome_vars, rec_list[1:length(outcome_vars)], ~ list(var = .x, rec = .y))

  # Handle NA recoding if keep_nr is TRUE
  if (keep_nr) {
    data <- data %>%
      mutate(across(all_of(outcome_vars), ~ case_when(
        na_tag(.data) %in% c("a", "b") ~ 99,
        TRUE ~ as.numeric(.data)
      )))
  }

  # Process each outcome variable with its respective rec
  ccm <- purrr::map_dfr(rec_map, function(mapping) {
    outcome <- mapping$var
    rec <- mapping$rec

    temp <- data %>%
      drop_na(!!sym(xvar)) %>%
      group_by(pais = as_factor(!!sym(xvar))) %>%
      {
        if (mean) {
          summarize(.data,
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
          summarize(.data,
                    prop = survey_mean(between(!!sym(outcome), rec[1], rec[2]),
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
      rename(lb = prop_low, ub = prop_upp) %>%
      ungroup() %>%
      mutate(var = outcome)

    temp
  })
  # Sorting logic
  ccm = ccm %>%
    {
      if (sort == "y") {
        group_by(.data, var) %>%
          mutate(rank = rank(-prop)) %>%
          arrange(match(var, unique(var)[1]),
                  if (order == "hi-lo") rank else desc(rank)) %>%
          select(-rank)
      } else if (sort == "xl") {
          arrange(.data, if (order == "hi-lo") desc(as.character(pais)) else as.character(pais))
      } else if (sort == "xv") {
        arrange(.data, if (order == "hi-lo") desc(match(pais, levels(pais))) else match(pais, levels(pais)))
      } else {
        .
      }
    }

  # Perform pairwise t-tests if requested
  if (ttest) {
    # Estimate standard error for each row using the confidence intervals
    ccm <- ccm %>%
      mutate(se = (ub - lb) / (2 * 1.96))

    # Initialize an empty data frame to store t-test results
    t_test_results <- data.frame(test = character(),
                                 diff = numeric(),
                                 ttest = numeric(),
                                 pval = numeric(),
                                 stringsAsFactors = FALSE)

    # Perform pairwise t-tests for each combination of rows
    for(i in 1:(nrow(ccm) - 1)) {
      for(j in (i + 1):nrow(ccm)) {
        # Extract values for the two rows being compared
        # adding a comment
        prop1 <- ccm$prop[i]
        se1 <- ccm$se[i]
        prop2 <- ccm$prop[j]
        se2 <- ccm$se[j]

        # Calculate difference, t-statistic, and degrees of freedom
        diff <- prop1 - prop2
        t_stat <- diff / sqrt(se1^2 + se2^2)
        df <- (se1^2 + se2^2)^2 / ((se1^2)^2 / (nrow(data) - 1) + (se2^2)^2 / (nrow(data) - 1))

        # Calculate p-value
        p_value <- 2 * pt(-abs(t_stat), df)

        # Store results in a data frame
        t_test_results <- rbind(t_test_results,
                                data.frame(test = paste(ccm$pais[i], ccm$var[i], "vs",
                                                        ccm$pais[j], ccm$var[j]),
                                           diff = round(diff, 3),
                                           ttest = round(t_stat, 3),
                                           pval = round(p_value, 3)))
        attr(ccm, "t_test_results") <- t_test_results
      }
    }
  }


  # Save the results to a file if specified
  if (filesave != "") {
    write.csv(ccm, filesave, row.names = FALSE)
  }

  return(ccm)
}

