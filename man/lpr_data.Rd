% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lpr_data.R
\name{lpr_data}
\alias{lpr_data}
\title{LAPOP Data Processing}
\usage{
lpr_data(data_path, wt = FALSE)
}
\arguments{
\item{data_path}{The path for a AmericasBarometer data or a an existing dataframe.}

\item{wt}{Logical.  If TRUE, use `wt` (weights only for single-country single-year data)
instead of `weight1500` (the default weights for multiple-country and multiple-year data).
Default: FALSE.}
}
\value{
Returns a svy_tbl object
}
\description{
This function takes LAPOP datasets and adds survey features such as sampling
design effects, outputting a svy_tbl object that can then be analyzed using
lpr_ wrangling commands.
}
\examples{
\dontrun{
# Single-country single-year (wt)
#' bra23w <- lpr_data(bra23, wt = TRUE)
print(bra23w)}

# Single-country  multi-year (weight1500)
\dontrun{cm23w <- lpr_data(cm23)
print(cm23w)}

#' # Multi-country  single-year (weight1500)
\dontrun{ym23w <- lpr_data(ym23)
print(ym23w)}

}
\author{
Luke Plutowski, \email{luke.plutowski@vanderbilt.edu} & Robert Vidigal, \email{robert.vidigal@vanderbilt.edu}
}
