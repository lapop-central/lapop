########################################

# LAPOP Regression Coefficients Graph Pre-Processing

########################################

#' LAPOP Regression Coefficients Graph Pre-Processing
#'
#' This function creates a data frame which can then be input in lapop_coef() for
#' plotting regression coefficients graph using LAPOP formatting.
#'
#' @param outcome Dependent variable for the svyglm regression model. (e.g., "outcome_name"). Only one variable allowed.
#' @param xvar Vector of independent variables for the svyglm regression model (e.g., "xvar1+xvar2+xvar3" and so on). Multiple variables are allowed.
#' @param model Model family object for glm. Default is linear regression (i.e., "gaussian"). For a logit model, use model="binomial"
#' @param data Survey design data from lpr_data() output.
#' @param estimate Character. Graph either the coefficients (i.e., `coef`) or the change in probabilities (i.e., `contrast`). Default is "coef."
#' @param vlabs Character. Rename variable labels to be displayed in the graph produced by lapop_coef(). For instance, vlabs=c("old_varname" = "new_varname").
#' @param omit Character. Do not display coefficients for these independent variables. Default is to display all variables included in the model. To omit any variables you need to include the raw "varname" in the omit argument.
#' @param filesave Character. Path and file name with csv extension to save the dataframe output.
#' @param replace Logical. Replace the dataset output if it already exists. Default is FALSE.
#' @param level Numeric. Set confidence level in numeric values; default is 95 percent.
#'
#' @return Returns a data frame, with data formatted for visualization by lapop_coef
#'
#' \examples{
#' ## Not run: 
#' # Example 1: Linear model
#' svyglm_linear <- survey::svyglm(
#'  fs2 ~ it1 + idio2 + edad, 
#'  data = dataLAPOP, 
#'  family = "gaussian"
#' )
#'
#' # Example 2: Logit model  
#' svyglm_logit <- survey::svyglm(
#'  fs2 ~ it1 + idio2 + edad,
#'  data = dataLAPOP,
#'  family = "binomial"
#' )
#'
#' # Example 3: Using lpr_coef
#' lpr_coef(
#'  outcome = "fs2",
#'  xvar = "it1+idio2+edad", 
#'  data = dataLAPOP,
#'  model = "binomial",
#'  est = "contrast"
#' )
#' ## End(Not run)
#' }
#'
#'@export
#'@import dplyr
#'@import srvyr
#'@import survey
#'@import marginaleffects
#'
#'@author Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}

lpr_coef <- function(
    outcome = NULL,
    xvar = NULL,
    model = "gaussian",
    data = NULL,
    estimate = c("coef"),
    vlabs = NULL,
    omit = NULL,
    filesave = NULL,
    replace = FALSE,
    level = 0.95
) {

  # Initialize an empty data.frame for output
  coef_data <- data.frame()

  # Check if any of the required inputs are NULL
  if (is.null(outcome) || is.null(xvar) || is.null(model) || is.null(data)) {
    stop("Error: One or more required inputs (outcome, xvar, model) are NULL.")
  } else {
    # Run svyglm regression from INPUTS
    formula <- as.formula(paste(paste(outcome, "~"), xvar))
    svyglm_object<-survey::svyglm(formula, design=data, family=model)
  }

  if (estimate == "") {
    stop("You need to define the type of estimate: `coef` or `contrast`")
  }

  if (estimate == "contrast") {
    # Extract predictors (excluding the dependent variable)
    predictors <- attr(svyglm_object$terms, "term.labels")
    if (length(predictors) == 0) {
      stop("No valid predictor variables found in the model.")
    }

    # Run contrasts for every single I.V. in the model
    for (Term in predictors) {
      dataset <- svyglm_object$data

      # Check the class of the variable to determine the comparison type
      # We are using the marginaleffects package for calculating contrasts
      # For factor vars we use `reference`, for numeric vars we use `minmax` type
      comparison_type <- if (is.factor(dataset[[Term]])) "reference" else "minmax"

      term_data <- tryCatch({
        term_result <- suppressWarnings(
          as.data.frame(avg_comparisons(svyglm_object, variables = setNames(list(comparison_type), Term)))
        )

        term_result <- term_result %>%
          rename(varlabel = contrast, coef = estimate,
                 ub = conf.high, lb = conf.low) %>%
          mutate(
            varterm = Term,
            varlabel = paste(Term, varlabel, sep = ": "),
            pvalue = round(p.value, 4),
            proplabel = round(coef, 2)
          )

        term_result

      }, # error handling...
      error = function(e) {
        data.frame(varterm = NA, varlabel = NA, coef = NA,
                   lb = NA, ub = NA,
                   pvalue = NA, proplabel = NA) # return all NA
      })

      coef_data <- bind_rows(coef_data, term_data)
    }

    # Omit specified independent variables from the output
    if (!is.null(omit)) {
      coef_data <- coef_data %>%
        filter(!varterm %in% omit)
    }

    # Apply custom labels for variables by checking if
    # names(vlabs) are in Terms from the model (i.e., renaming)
    if (!is.null(vlabs)) {
      coef_data <- coef_data %>%
        mutate(varlabel = ifelse(varterm %in% names(vlabs), vlabs[varterm], varlabel))
    }

    # reordering
    coef_data <- coef_data %>% select(varlabel, coef, lb, ub, pvalue, proplabel)
  } else {

    # Extract coefficients and confidence intervals (i.e., estimate="coef")

    coef_data <- summary(svyglm_object)$coefficients %>%
      as.data.frame() %>%
      mutate(Term = rownames(.)) %>%
      select(Term, everything()) %>%  # Move Term to the first column
      mutate(
        lb = as.numeric(Estimate - qt(1 - (1 - level) / 2, df = svyglm_object$df.residual) * `Std. Error`),
        ub = as.numeric(Estimate + qt(1 - (1 - level) / 2, df = svyglm_object$df.residual) * `Std. Error`),
        `Pr(>|t|)` = as.numeric(format(`Pr(>|t|)`, scientific = FALSE, digits=3)),
        pvalue = round(`Pr(>|t|)`, 3),
        proplabel = round(Estimate, digits=3)
      )

    if (!is.null(omit)) {
      coef_data <- coef_data %>%
        filter(!Term %in% omit)
    }

    # Return the processed coefficient data as a tibble
    coef_data<-coef_data %>% rename(varlabel=Term, coef=Estimate) %>%
      select(varlabel, coef, lb, ub, pvalue, proplabel)
  }

  # Save the output to a CSV file if filesave is provided
  if (!is.null(filesave)) {
    if (dir.exists(filesave)) {
      stop("You provided a directory for 'filesave'. Please provide a valid file path, including the file name.")
    }
    if (file.exists(filesave) && !replace) {
      stop("File already exists. Use `replace = TRUE` to overwrite.")
    } else {
      write.csv(coef_data, file = filesave, row.names = FALSE)
      message("File saved to ", filesave)
    }
  } else {
    message("CSV output file not created.")
  }

  return(coef_data)
}
