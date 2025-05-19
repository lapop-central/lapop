#######################################

# LAPOP Data Processing #

#######################################

#' LAPOP Data Processing
#'
#' This function takes LAPOP datasets and adds survey features, outputting a
#' svy_tbl object that can then be analyzed using lpr_ commands.
#'
#' @param data_path A dataframe of LAPOP survey data.
#' @param wt Logical.  If TRUE, use wt instead of weight1500.  Default: FALSE.
#'
#' @return Returns a svy_tbl object
#'
#' @examples
#'
#' \dontrun{
#' gm23 <- lpr_data("Merge 2023 LAPOP AmericasBarometer (v1.0s).dta")
#' }
#'
#'@export
#'@import srvyr
#'@import haven
#'@import dplyr
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu}

lpr_data = function(data_path,
                    wt = FALSE) {

  data <- haven::read_dta(data_path)

  country_codes <- c(
    "1" = "MX", "2" = "GT", "3" = "SV", "4" = "HN", "5" = "NI",
    "6" = "CR", "7" = "PA", "8" = "CO", "9" = "EC", "10" = "BO",
    "11" = "PE", "12" = "PY", "13" = "CL", "14" = "UY", "15" = "BR",
    "17" = "AR", "21" = "DO", "22" = "HT", "23" = "JM", "25" = "TT",
    "26" = "BZ", "27" = "SR", "28" = "BS", "30" = "GD", "40" = "US",
    "41" = "CA"
  )

  data$pais_lab <- country_codes[as.character(data$pais)]

  data <- data[!is.na(data$upm), ]

  if (wt == TRUE) {
    datas <- data %>%
      as_survey(ids = upm, strata = strata, weights = wt, nest = TRUE)
  } else {
    datas <- data %>%
      as_survey(ids = upm, strata = strata, weights = weight1500, nest = TRUE)
  }

  return(datas)
}
