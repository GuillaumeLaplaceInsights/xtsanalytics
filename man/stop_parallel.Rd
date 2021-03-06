% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/xtsparallel.R
\name{stop_parallel}
\alias{stop_parallel}
\title{Stops the parallel backend}
\usage{
stop_parallel(cluster)
}
\arguments{
\item{cluster}{The CPU cluster to stop}
}
\value{
Nothing is returned.
}
\description{
Stops a CPU cluster previously started using start_parallel.  The cluster
must be provided for this function to work.
}
\seealso{
start_parallel
}
