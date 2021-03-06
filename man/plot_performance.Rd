% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/performance.R
\name{plot_performance}
\alias{plot_performance}
\title{Generate combination plots to illustrate portfolio performance}
\usage{
plot_performance(prices, type = "table", main = "Performance Summary",
  log = "y", cex = 1, tabheight = 0.6, digits = 2, labspace = 2,
  ycex = 1, ...)
}
\arguments{
\item{prices}{An xts matrix of equity curves or asset prices.}

\item{type}{Specifies the type of plot.  If "table"
then the equity curves are shown on the top portion
and a table of key performance parameters is shown
below.  If "table2", then a simple version of table is
plotted, appropriate for showing shorter periods.
If "curves" then the equity curves
are shown on the top portion and the drawdown curves
are shown on the bottom section.  Default is
"table".}

\item{main}{Title at the top of the plot page}

\item{log}{Specifies whether to use a semilog scale for the equity
curve plot.  Default is "y" specifying the y scale is logarithmic.}

\item{cex}{The scaling factor for the performance table in table mode.}

\item{tabheight}{The height of the table relative to the height of the plot, for
type = "table". Default is 0.6.}

\item{labspace}{The amount of space between the X and Y labels and the plot.
This is useful when scaling the chart for png plots and labels
can overlap the plot.  Used by title(), parameter line.}

\item{...}{Additional parameters passed through to function xtsplot.}
}
\description{
Generate combination plots to illustrate portfolio performance
}
