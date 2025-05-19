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
#' @param use_cat Logical. If TRUE, will show the percentages of category values
#' of a single variable; otherwise will show percentages of the range of values
#' from rec(). Default FALSE.
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
#' @examples {
#'
#' Single Variable
#'#' \dontrun{lpr_mline(gm,
#' outcome = "ing4",
#' rec = c(5, 7),
#' use_wave = FALSE)}
#'
#' Multiple Variables
#' \dontrun{lpr_mline(gm,
#' outcome = c("b10a", "b13", "b18", "b21"),
#' rec = c(5, 7),
#' rec2 = c(1, 2),
#' rec3 = c(5, 7),
#' rec4 = c(1, 1),
#' use_wave = TRUE)}
#'
#' Binary Single Variable by Category
#' \dontrun{lpr_mline(gm,
#' outcome = "jc1",
#' use_cat = TRUE,
#' use_wave = TRUE)}
#'
#' Recode Categorical Variable (max 4-categories)
#' \dontrun{lpr_mline(gm,
#' outcome = "a4n",
#' rec = c(1,4),
#' use_cat = TRUE,
#' use_wave = TRUE)
#' }
#'}
#'@export
#'@import dplyr
#'@import srvyr
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} & Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}
lpr_mline <- function(data,
                      outcome,
                      rec = c(1, 1),
                      rec2 = c(1, 1),
                      rec3 = c(1, 1),
                      rec4 = c(1, 1),
                      xvar,
                      use_wave = FALSE,
                      use_cat = FALSE,
                      ci_level = 0.95,
                      mean = FALSE,
                      filesave = "",
                      cfmt = "",
                      ttest = FALSE,
                      keep_nr = FALSE) {

  # 1. Input validation
  if (!all(outcome %in% names(data$variables))) {
    missing_vars <- setdiff(outcome, names(data$variables))
    stop(paste("Variable(s) not found in data:", paste(missing_vars, collapse = ", ")))
  }

  if (length(rec) == 1) rec <- c(rec, rec)
  if (length(rec2) == 1) rec2 <- c(rec2, rec2)
  if (length(rec3) == 1) rec3 <- c(rec3, rec3)
  if (length(rec4) == 1) rec4 <- c(rec4, rec4)

  # 2. Store variable labels for all outcomes
  var_labels <- sapply(outcome, function(x) {
    lbl <- attr(data$variables[[x]], "label")
    if (is.null(lbl)) x else lbl
  })

  # 3. Handle categorical case
  if (use_cat) {
    if (length(outcome) > 1) stop("When use_cat=TRUE, only one outcome variable should be provided")

    # Get value labels for categories
    val_labels <- attr(data$variables[[outcome]], "labels")

    # Get categories from rec range or data
    categories <- if (!identical(rec, c(1,1))) {
      rec[1]:rec[2]
    } else {
      sort(unique(na.omit(data$variables[[outcome]])))
    }

    if (!keep_nr) categories <- categories[categories != 99]
    if (length(categories) > 4) stop("Variable has more than 4 categories. Consider recoding.")

    # Create rec_list based on categories
    rec_list <- lapply(categories, function(x) c(x, x))
    outcome_rep <- rep(outcome, length(categories))
    rec <- rec_list[[1]]
    if (length(rec_list) > 1) rec2 <- rec_list[[2]]
    if (length(rec_list) > 2) rec3 <- rec_list[[3]]
    if (length(rec_list) > 3) rec4 <- rec_list[[4]]
  }

  # 4. Process data
  if (length(outcome) > 1 || use_cat) {
    rec_list <- if (use_cat) list(rec, rec2, rec3, rec4)[1:length(categories)]
else list(rec, rec2, rec3, rec4)[1:length(outcome)]

result_list <- lapply(seq_along(if (use_cat) categories else outcome), function(i) {
  temp <- lpr_ts(data = data,
                 outcome = if (use_cat) outcome else outcome[i],
                 rec = rec_list[[i]],
                 use_wave = use_wave,
                 mean = mean,
                 cfmt = cfmt,
                 keep_nr = keep_nr)

  if (use_cat) {
    temp$category <- categories[i]
  } else {
    temp$varlabel <- var_labels[i]
  }
  temp
})

mline <- bind_rows(result_list)

# Handle waves
if (nrow(mline) > 0) {
  all_waves <- unique(mline$wave)
  join_by <- if (use_cat) c("wave", "category") else c("wave", "varlabel")

  full_grid <- expand.grid(
    wave = all_waves,
    if (use_cat) unique(mline$category) else unique(mline$varlabel),
    stringsAsFactors = FALSE
  )
  names(full_grid)[2] <- if (use_cat) "category" else "varlabel"

  mline <- full_grid %>%
    left_join(mline, by = join_by) %>%
    arrange(if (use_cat) category else varlabel, wave)

  # Filter combined waves
  if (any(c("2016","2017") %in% mline$wave)) mline <- filter(mline, wave != "2016/17")
  if (any(c("2018","2019") %in% mline$wave)) mline <- filter(mline, wave != "2018/19")
}

# Apply category labels if use_cat
if (use_cat && exists("val_labels")) {
  mline <- mline %>%
    mutate(varlabel = ifelse(
      category %in% val_labels,
      names(val_labels)[match(category, val_labels)],
      as.character(category)
    ))
}

} else {
  # Single outcome case
  if (keep_nr) {
    data <- data %>%
      mutate(!!outcome := case_when(
        na_tag(!!outcome) == "a" | na_tag(!!outcome) == "b" ~ 99,
        TRUE ~ as.numeric(!!outcome)
      ))
  }

  mline <- data %>%
    drop_na(!!sym(xvar)) %>%
    group_by(varlabel = as_factor(!!sym(xvar)),
             wave = if (use_wave) as.character(as_factor(wave)) else year) %>%
    {
      if (mean) {
        summarize(., prop = survey_mean(!!sym(outcome),
                                        na.rm = TRUE,
                                        vartype = "ci",
                                        level = ci_level)) %>%
          mutate(proplabel = sprintf(if (cfmt != "") cfmt else "%.1f", prop))
      } else {
        summarize(., prop = survey_mean(between(!!sym(outcome), rec[1], rec[2]),
                                        na.rm = TRUE,
                                        vartype = "ci",
                                        level = ci_level) * 100) %>%
          mutate(proplabel = sprintf(if (cfmt != "") cfmt else "%.0f%%", round(prop)))
      }
    } %>%
    filter(prop != 0) %>%
    rename(lb = prop_low, ub = prop_upp)
}

  # 5. T-tests if requested
  if (ttest && nrow(mline) > 1) {
    mline <- mline %>%
      mutate(se = (ub - lb) / (2 * 1.96))

    t_test_results <- combn(1:nrow(mline), 2, function(pair) {
      i <- pair[1]; j <- pair[2]
      diff <- mline$prop[i] - mline$prop[j]
      se_diff <- sqrt(mline$se[i]^2 + mline$se[j]^2)
      t_stat <- diff/se_diff
      df <- (mline$se[i]^2 + mline$se[j]^2)^2 /
        ((mline$se[i]^4 + mline$se[j]^4)/(nrow(mline)-1))
      p_value <- 2 * pt(-abs(t_stat), df)

      data.frame(
        test = paste(mline$varlabel[i], mline$wave[i], "vs",
                     mline$varlabel[j], mline$wave[j]),
        diff = round(diff, 3),
        t_stat = round(t_stat, 3),
        p_value = round(p_value, 3),
        stringsAsFactors = FALSE
      )
    }, simplify = FALSE) %>% bind_rows()

    attr(mline, "t_test_results") <- t_test_results
  }

  # 6. Save if requested
  if (filesave != "") {
    write.csv(mline, filesave, row.names = FALSE)
  }

  return(mline)
  }
