% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lpr_coef.R
\name{lpr_coef}
\alias{lpr_coef}
\title{LAPOP Regression Coefficients Graph Pre-Processing}
\usage{
lpr_coef(
  svyglm_object,
  estimate = c("coef"),
  vlabs = NULL,
  omit = NULL,
  filesave = NULL,
  replace = FALSE,
  level = 95
)
}
\arguments{
\item{svyglm_object}{Survey-weighted generalised linear models. A generalised
linear model object from a complex survey design, with inverse-probability
weighting and design-based standard errors (i.e., `survey::svyglm()` object).
The svyglm function always returns 'model-robust' standard errors; the
Horvitz-Thompson-type standard errors used everywhere in the survey package
are a generalisation of the model-robust 'sandwich' estimators.}

\item{estimate}{Character. Graph either the coefficients (i.e., `coef`) or
the change in probabilities (i.e., `contrast`)}

\item{vlabs}{Character. Variable labels to be displayed in the graph produced
by lapop_coef().}

\item{omit}{Character. Do not display coefficients for these independent variables.}

\item{filesave}{Character. Path and file name with csv extension to save
the dataframe output.}

\item{replace}{Logical. Replace the dataset output if it already exists.
Default is FALSE.}

\item{level}{Numeric. Set confidence level; default is 95 percent.}
}
\value{
Returns a data frame, with data formatted for visualization by lapop_coef
}
\description{
This function creates a data frame which can then be input in lapop_coef() for
plotting regression coefficients graph using LAPOP formatting.
}
\examples{

\dontrun{dataYM<-lpr_data(dataset)}
\dontrun{svyglm_object<-survey::svyglm(formula, design, family="binomial")}
\dontrun{lapop_coef(svyglm_object, est="coef")}
\dontrun{lapop_coef(svyglm_object, est="contrast")}

}
\author{
Robert Vidigal, \email{robert.vidigal@vanderbilt.edu}
}
