% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/genpurpose.R
\name{starttime}
\alias{starttime}
\alias{elapsedtime}
\title{Start a timer and report the elapsed time}
\usage{
starttime()

elapsedtime(script_end = TRUE)
}
\arguments{
\item{script_end}{Logical. Default value TRUE. Only relevant for elapsedtime().
If TRUE, an end of script message is printed on the console
in addition to the elapsed time.  If FALSE, only the elapsed
time is reported.}
}
\value{
No value returned for starttime().  The elapsed time is returned using elapsedtime().
}
\description{
These two functions, `starttime()` and `elapsedtime()` work together.
Call starttime() at the beginning of a script
without any argument.  This logs the current time in global variable `.__start.time`.
Then at the end of the script or whenever a report of the elapsed time interval is
desired, call elapsed.time() to print the elapsed time on the console.
}
\details{
NOTE:  The reference to global variable `.__start.time` should be changed to using
the package NAMESPACE, since this provides the side effect of creating a global
variable.  But for now, this works fine, so this is a future improvement.
}
\section{Functions}{
\itemize{
\item \code{elapsedtime}: Report the elapsed time since starttime() was last invoked.
}}

\examples{
starttime()
Sys.sleep(0.5)
zzz <- elapsedtime()

}
