% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lpr_stack.R
\name{lpr_stack}
\alias{lpr_stack}
\title{LAPOP Stacked Bar Graph Pre-Processing}
\usage{
lpr_stack(
  data,
  outcome,
  xvar = NULL,
  sort = "y",
  order = "hi-lo",
  filesave = "",
  keep_nr = FALSE
)
}
\arguments{
\item{data}{The data that should be analyzed. It requires a survey object from lpr_data() function.}

\item{outcome}{Vector of variables be plotted.}

\item{xvar}{Character. Outcome variable will be broken down by this variable. Default is NULL}

\item{sort}{Character. On what value the bars are sorted: the x or the y.
Options are "y" (default; for the value of the outcome variable), "xv" (for
the underlying values of the x variable), "xl" (for the labels of the x variable,
i.e., alphabetical).}

\item{order}{Character. How the bars should be sorted. Options are "hi-lo"
(default) or "lo-hi".}

\item{filesave}{Character. Path and file name to save the dataframe as csv.}

\item{keep_nr}{Logical. If TRUE, will convert "don't know" (missing code .a)
and "no response" (missing code .b) into valid data (value = 99) and use them
in the denominator when calculating percentages.  The default is to examine
valid responses only.  Default: FALSE.}
}
\value{
Returns a data frame, with data formatted for visualization by lapop_stack
}
\description{
This function creates dataframes which can then be input in lapop_stack() for
plotting variables categories with a stacked bar graph using LAPOP formatting.
}
\examples{

\dontrun{lpr_stack(data = gm, outcome = c("countfair1", "countfair3"))}
\dontrun{lpr_stack(data = gm, outcome = "pese1", xvar="year")}

}
\author{
Robert Vidigal, \email{robert.vidigal@vanderbilt.edu}
}
