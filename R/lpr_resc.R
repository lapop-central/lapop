#######################################

# LAPOP Rescale #

#######################################

#' LAPOP Rescale
#'
#' This function allows users to rescale and reorder variables.  It is designed
#' for variables of class "labelled" (used for survey datasets, like LAPOP's),
#' but the rescaling will work for numeric and factor variables as well
#'
#' @param var Vector (class "labelled" or "haven_labelled").  The original variable
#' to rescale.
#' @param min Integer. Minimum value for the new rescaled variables; default is 0.
#' @param max Integer. Maximum value for the new rescaled variables; default is 1.
#' @param reverse Logical.  Reverse code the variable before rescaling. Default: FALSE.
#' @param only_reverse Logical.  Reverse code the variable, but do not rescale. Default: FALSE.
#' @param only_flip Logical. Flip the variable coding.  Unlike "only_reverse", this will
#' exactly preserve the values of the old variable.  For example, for a variable
#' with codes 1, 2, 3, 5, 10, only_flip will code the values 10, 5, 3, 2, 1 (instead
#' of 10, 9, 8, 6, 1).  Generally, reverse should be preferred to preserve the
#' underlying scale.  Not compatible with rescale. Default: FALSE.
#' @param map Logical. If TRUE, will print a cross-tab showing the old variable
#' and the new, recoded variable.  Used to verify the new variable is coded correctly.
#' Default: FALSE.
#' @param new_varlabel Character.  Variable label for the new variable.
#' Default: old variable's label.
#' @param new_vallabels Character vector. Supply custom names for value labels. Default:
#' value labels of old variable.
#'
#' @examples
#'
#' \dontrun{cm23$aoj11r <- lpr_resc(cm23$aoj11,
#' reverse = TRUE,
#' map=TRUE)
#' }
#'
#'@export
#'@import haven
#'@import codebook
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}


lpr_resc <- function(var,
                     min = 0L,
                     max = 1L,
                     reverse = FALSE,
                     only_reverse = FALSE,
                     only_flip = FALSE,
                     map = FALSE,
                     new_varlabel = NULL,
                     new_vallabels = NULL) {

  og_var = var

  if (is.character(var)) {
    stop("Cannot rescale character variable")
  }

  # Store original levels and labels if factor or labelled
  if (inherits(var, c("haven_labelled", "labelled"))) {
    original_labels <- attr(haven::zap_missing(var), "labels")
  }

  # Store original levels and labels if factor
  if (is.factor(var)) {
    original_levels = levels(var)
    var = as.numeric(var)
  }

  if (reverse) {
    var = codebook::reverse_labelled_values(var)
  }

  if (only_reverse) {
    var = codebook::reverse_labelled_values(var)
  } else if (only_flip) {
    unique_vals <- sort(unique(var))
    flipped_vals <- rev(unique_vals)
    var <- flipped_vals[match(var, unique_vals)]

    # Reverse the labels if variable is labelled
    if (exists("original_labels")) {
      flipped_labels <- rev(original_labels)
      names(flipped_labels) <- names(original_labels)
      attr(var, "labels") <- flipped_labels
    }
  } else {
    var = (var - min(var, na.rm = TRUE)) / (max(var, na.rm = TRUE) - min(var, na.rm = TRUE)) * (max - min) + min
  }

  if (map) {
    print(table(haven::as_factor(haven::zap_missing(og_var)),
                haven::as_factor(haven::zap_missing(var))))
  }

  if (!is.null(new_varlabel)) {
    attr(var, "label") = as.character(new_varlabel)
  }

  if (!is.null(new_vallabels)) {
    names(attr(x, "labels")) <- new_vallabels
  }

  return(var)
}
