% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rounded_sum.R
\name{rounded_sum}
\alias{rounded_sum}
\title{Round a vector of numbers such that their sum stays.}
\usage{
rounded_sum(x, digits)
}
\arguments{
\item{x}{A numeric vector where it is desired that each number be
rounded to 'digits' digits.}

\item{digits}{The number of digits where rounding is applied.}
}
\value{
Returns a vector similar to x, except that the numbers have been
        rounded and their sum is preserved.
}
\description{
Applying the rounding function independently to a vector of numbers does
not, in general, preserve their sum.  This function ensures that the sum
is preserved after rounding.
}
\details{
It achieves this using the following algorithm:
\enumerate{
   \item{Round down to the specified number of decimal places. }
   \item{Order numbers by their remainder values.}
   \item{Increment the specified decimal place of values with k largest
         remainders, where k is the number of values that must be
         incremented to preserve their rounded sum.
   }
}
}
