#######################################

# LAPOP Data Processing #

#######################################

#' LAPOP Data Processing
#'
#' This function takes LAPOP datasets and adds survey features such as sampling
#' design effects, outputting a svy_tbl object that can then be analyzed using
#' lpr_ wrangling commands.
#'
#' @param data_path The path for a AmericasBarometer data or a an existing dataframe.
#' @param wt Logical.  If TRUE, use `wt` (weights only for single-country single-year data)
#' instead of `weight1500` (the default weights for multiple-country and multiple-year data).
#' Default: FALSE.
#'
#' @return Returns a svy_tbl object
#'
#' @examples {
#'\dontrun{
#' # Single-country single-year (wt)
#' #' bra23w <- lpr_data(bra23, wt = TRUE)
#' print(bra23w)
#'}
#' # Single-country  multi-year (weight1500)
#' cm23w <- lpr_data(cm23)
#' print(cm23w)
#'}
#'
#'#' # Multi-country  single-year (weight1500)
#' ym23w <- lpr_data(ym23, wt = TRUE)
#' print(ym23w)
#'}
#'}
#'@export
#'@import srvyr
#'@import haven
#'@import dplyr
#'
#'@author Luke Plutowski, \email{luke.plutowski@@vanderbilt.edu} & Robert Vidigal, \email{robert.vidigal@@vanderbilt.edu}

lpr_data = function (data_path, wt = FALSE)
{
  # Check if data_path is a path or a data frame
  if (is.character(data_path) && file.exists(data_path)) {
    # If it's a path, read the data
    data <- haven::read_dta(data_path)
    #data <- readstata13::read.dta13(data_path)
  } else if (is.data.frame(data_path)) {
    # If it's already a data frame, use it directly
    data <- data_path
  } else {
    stop("data_path must be a valid file path or a data frame.")
  }

  country_codes_numbers <- c(`1` = "MX", `2` = "GT", `3` = "SV", `4` = "HN",
                     `5` = "NI", `6` = "CR", `7` = "PA", `8` = "CO", `9` = "EC",
                     `10` = "BO", `11` = "PE", `12` = "PY", `13` = "CL", `14` = "UY",
                     `15` = "BR", `17` = "AR", `21` = "DO", `22` = "HT", `23` = "JM",
                     `25` = "TT", `26` = "BZ", `27` = "SR", `28` = "BS", `30` = "GD",
                     `40` = "US", `41` = "CA")

  country_codes_names <- c(
    "Mexico" = "MX", "México" = "MX",
    "Guatemala" = "GT", "El Salvador" = "SV",
    "Honduras" = "HN", "Nicaragua" = "NI",
    "Costa Rica" = "CR",
    "Panama" = "PA", "Panamá" = "PA",
    "Colombia" = "CO", "Ecuador" = "EC",
    "Bolivia" = "BO",
    "Peru" = "PE", "Perú" = "PE",
    "Paraguay" = "PY", "Chile" = "CL", "Uruguay" = "UY",
    "Brazil" = "BR", "Brasil" = "BR",
    "Argentina" = "AR",
    "Dominican Republic" = "DO", "República Dominicana" = "DO",
    "Haiti" = "HT", "Haití" = "HT",
    "Jamaica" = "JM",
    "Trinidad and Tobago" = "TT", "Trinidad y Tobago" = "TT",
    "Belize" = "BZ", "Belice" = "BZ",
    "Suriname" = "SR", "Surinam" = "SR",
    "Bahamas" = "BS", "Grenada" = "GD",
    "United States" = "US", "Estados Unidos" = "US",
    "Canada" = "CA", "Canadá" = "CA"
  )

  if (is.factor(data$pais)) {
    # Assume factor of country names
    data$pais_lab <- country_codes_names[as.character(data$pais)]
  } else {
    # Assume numeric codes
    data$pais_lab <- country_codes_numbers[as.character(data$pais)]
  }

  data <- data[!is.na(data$upm), ]

  # Check if the required weight variable is present
  if (wt == TRUE) {
    if (!"wt" %in% names(data)) stop("Weight variable 'wt' not found in dataset.")
    datas <- data %>% as_survey(ids = upm, strata = strata,
                                weights = wt, nest = TRUE)
  } else {
    if (!"weight1500" %in% names(data)) stop("Weight variable 'weight1500' not found in dataset.")
    datas <- data %>% as_survey(ids = upm, strata = strata,
                                weights = weight1500, nest = TRUE)
  }

  return(datas)
}
