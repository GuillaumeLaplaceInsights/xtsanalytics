####################################################################################
#
#  make_features2.R
#  ----------------
#
#  1) add help text
#  2) Define the new syntax for simplicity
#
###########
#  NOTE:
###########
# make_transform and tailratiofcn have been deleted from this file to
# ensure there is no duplication with make_features file.
#
#########################################################################
#
#  Use the comma to specify a lag or lead
#
#  TODO:  Format to generate higher moment features, such as returns squared.
#  That format should also have a way to average the higher moments using
#  ema or sma.
#
#  IDEA:  rets2 for squared returns, rets3 for cubed, etc.
#  use ! to pipe.  rets2!sma10 is EMA(rets2, 10)
#  Keep underscore for divisions
#
# example:  To implement
# rets    <- ROC(asset, type = "discrete")
# retsq   <- rets^2
#
# rets2ema   <- TTR::EMA(rets2, 10)
# rets2smalt <- TTR::SMA(rets2, 50)
#
# rets2roc <- rets2ema / rets2smalt
#
# DO the following:
#
# rets2..ema10_rets2..sma50 is the same as ret2roc above
#
# #
####################################################################################
#
# FUNCTION make_features2
#
#' Generates a list of features from a universe of assets
#'
#' MODIFICATIONS July 2017
#'  - Removed the -1 adjustement to the division operation (_) to ensure
#'    the division has not bias.
#'  - Therefore, need to implement the addition / subtraction operations
#'  - use + and - for operators, but these get lost when cbinding matrices.
#'  - therefore modify xtsbind to ensure hard colnames binding to keep + and -
#'
#' Generates a list of xts matrices, where each matrix in the list corresponds
#' to one feature. The specified universe of asset should be an xts matrix
#' of daily prices.
#'
#' If one of the feature corresponds to a target variable (y in a a machine
#' learning model), then specifying its name using the `target` argument will
#' automatically rename it to column y and place it as the first item
#' in the returned list.  This is useful to build the feature matrix used
#' by machine learning models using function \code{\link{make_featuremat}}.
#'
#' Some features are calculated from the daily prices whereas others
#' are calculated from daily returns. Features calculated from prices include:
#' \itemize{
#'    \item \strong{sma} which uses the TTR::SMA function
#'    \item \strong{ema} which uses the TTR::EMA function
#'    \item \strong{mom} which uses the TTR::ROC function
#' }
#' To reduce high frequency noise, the prices used
#' for these may be averaged a priori using either an sma or ema function,
#' specified using the `smooth` argument.
#'
#' In addition, some features are calculated from daily returns.  Features
#' calculated from returns include:
#' \itemize{
#'    \item \strong{sd} which uses the stats::sd function
#'    \item \strong{rets2} calculates the square of daily returns \strong{NOT IMPLEMENTED}
#'    \item \strong{rets3} calculates the cube of daily returns \strong{NOT IMPLEMENTED}
#' }
#' If the feature is specified in argument `smooth`, then the returns used to
#' compute that feature is first smoothed using either an ema or sma filter.
#' See argument `smooth` for details.
#'
#' It is also possible to smooth a feature \strong{after} its computation.
#' This has the effect of reducing high frequency noise while allowing high
#' frequency anomalies to carry through in the raw calculation of the feature.
#' If such post-processing on a feature is desired, then a post-processing tag
#' is appended to the feature tag. See below for format.
#'
#' \subsection{Basic feature format}{
#'    The format for specifying features and any postprocessing, if desired,
#'    is as follows:  \strong{<feature><parameter><post-processing>}, where:
#'    \itemize{
#'       \item \strong{feature} is the name of the feature as described above,
#'       \item \strong{parameter} is a number indicated the rolling window size in days,
#'       \item \strong{post-processing} is an optional smoothing filter argument.
#'       It must be enclosed in parenthesis to be valid. The filter specifications is
#'       either an \strong{ema} or \strong{sma} followed by the filter period in days.
#'    }
#'
#'    For example, \strong{"sd5(sma10)"} means to first take the 5 day rolling standard
#'    deviation, then smooth the results using a 10 day sma filter.
#'
#'
#' }
#'
#' \subsection{Complex features}{
#'     Compounded features can also be created by multiplying and dividing basic
#'     features.  This is achieved by using the dot to multiply two features, and
#'     the underscore to divide two features.
#'
#'     Formating examples:
#'     \itemize{
#'        \item \strong{"sd5.mom10"} is equivalent to: sd5 * mom10.
#'        \item \strong{"mom5.sd5(ema5)_sd5(sma21)} is equivalent to:
#'        mom5 * ema(sd5, 5) / sma(sd5, 21)
#'     }
#'
#' }
#'
#'
#' @param prices    An xts matrix of daily asset prices, where each asset is a column, and
#'                  each matrix entry is the asset price information from which the
#'                  set of features will be computed.
#'
#' @param features  A character vector string naming the features to be calculated.
#'                  See Details for the valid format.
#'
#' @param smooth    A named list that specifies whether the prices should be
#'                  smoothed (filtered) before calculating the named simple feature.
#'                  This is useful because certain features are sensitive to high
#'                  frequency noise. A simple feature that is part of a compounded
#'                  feature can also be specified for smoothing, even if it does
#'                  not appear as a stand alone simple feature in the features vector.
#'                  Unless a feature is explicitly named in argument `smooth`, then
#'                  no filtering is applied to that feature.
#'                  The format of the list is as follows:
#'                  \itemize{
#'                     \item \strong{feature_name} = \emph{"filter"}, where
#'                     \strong{feature_name} is the name of the feature (without quotes)
#'                     and "filter" is the character string
#'                     specifying how to filter the price series.  Two filtering methods
#'                     are valid:  sma and ema.  The number of periods must also be
#'                     specified.  For example, "sma10" means a 10 day sma filter.
#'                     }
#'
#' @param on        Specifies whether the computed features should be sampled at endpoints in
#'                  the time series using function endpoints.  Default is on = "days",
#'                  which has no effect on the daily series.  Other typical values could
#'                  be "weeks", "months", "quarters" or "years".  NOTE:  THIS DOES NOT
#'                  WORK YET, EXCEPT FOR DAILY SERIES on = "days"
#'
#' @param target    The feature name that will be used as the target for an ML
#'                  model.  It is computed like any other feature, except that
#'                  is it placed as the first item in the list returned, and renamed to 'y'.
#'                  Default is NA, which means no target is specified.
#'
#' @param by_symbol Specifies the format of the features returned.  If TRUE, then a
#'                  list of symbols, each containing an xts of the features for that symbol
#'                  is returned.  If FALSE, then the opposite is returned - that is,
#'                  a list of features, with each containing an xts of symbols.
#'
#' @return A list containing as many xts matrices as there are features
#'         specified by the features argument and, optionally, the target
#'         argument. Each matrix has the same number
#'         of rows and columns as argument 'prices' (corresponding to each asset).
#'         Each list item is named according to the features name (except for the target
#'         feature, if specified, which is renamed to `y`).
#'
#' @seealso \code{\link{make_featuremat}}
#'
#' @export
#-------------------------------------------------------------------------------------
make_features2 <- function(prices, features, smooth = NA, on = "days", target = NA,
                           by_symbol = FALSE) {

#
#   #################
#   prices = xts_gspc
#   features = c("mom126_sd63") #, "sd63")
#   smooth = NA
#   on = "days"
#   target = NA
#   by_symbol = TRUE     # return a list by symbols instead of by features
#
#   ##################

  # If a target feature is specified, append it to features up front.
  if(!is.na(target)) {
    features <- c(target, features)
  }

  # Feature names using returns instead of prices
  featname_rets <- c("sd", "kurt", "skew", "rets", "retsq", "emar", "smar", "sdup", "sddn",
                     "sdnaup", "sdnadn", "tailratio")

  # Parse for separators for compounded features: the dot and underscore
  separators  <- "\\.|_"
  featlist    <- strsplit(features, separators)
  oplist      <- stringr::str_extract_all(features, separators)

  # extract the unique features to calculate next
  featunique  <- unique(unlist(featlist))

  allprices  <- prices

  # add smoothed price columns as specified by some features
  if(!is.na(smooth)[1]) {
    smooth_names <- unique(unlist(smooth))
    for(i in smooth_names) {
      smooth_prices <- make_transform(prices, i, addname = TRUE)
      allprices     <- cbind(allprices, smooth_prices)
    }
  }

  # calculate daily returns for features that need returns
  allrets      <- TTR::ROC(allprices, n = 1, type = "discrete")

  #-------------------------------------------------------------------
  # Loop to compute each feature from the proper smoothed price
  #-------------------------------------------------------------------
  assetnames <- colnames(prices)
  lfn        <- list()
  for(feat in featunique) {

    if(is.na(smooth)[1]) cnames <- assetnames else
      if(is.null(smooth[[feat]])) cnames <- assetnames else
        cnames     <- paste0(assetnames, "_", smooth[[feat]])

    # Determine whether to pass returns or prices as argument to make_transform
    featname   <- stringr::str_extract(feat, "[[:alpha:]]+")
    if(featname %in% featname_rets)
      data_sub <- allrets[, cnames] else
      data_sub <- allprices[, cnames]

    x   <- make_transform(data_sub, feat, addname = FALSE)
    x   <- x[endpoints(x, on = on), ]
    lfn[[feat]] <- x   # assign feature to the list

  }

  #----------------------------------------------------------------
  # Make the compounded features by looping over each feature (i)
  # and then looping over each operation (k) if there is one.
  #----------------------------------------------------------------
  for(i in 1:length(oplist)) {
    if(length(oplist[[i]]) != 0) {
      # We have a compounded feature to build
      # initialize x (the accumulator) to the first feature in list
      x   <- lfn[[featlist[[i]][1]]]
      for(k in 1:length(oplist[[i]])) {
        y <- lfn[[featlist[[i]][k + 1]]]
        x <- switch(oplist[[i]][k],
                    "." = x * y,
                    "_" = x / y,
                    stop("make_features:  invalid operation."))
      }
      # x contains the compounded feature so assign it to lfn
      lfn[[features[i]]] <- x
    }
  }

  # Return only the relevant features in lfn, ordered (item 1 as target) if !NA

  retlfn <- lfn[features]
  if(!is.na(target)) {
    # change the name to y for the first item
    lnames        <- names(retlfn)
    lnames[1]     <- "y"
    names(retlfn) <- lnames

   }


  #---------------------------------------------------------
  # If by_symbol is TRUE, then extract feature set for
  # each symbol of interest to return a list of symbols
  # instead of the default list of features
  #---------------------------------------------------------
  if(by_symbol) {
    featnames <- names(retlfn)
    symnames  <- colnames(retlfn[[1]])
    xlist     <- list()
    for(i in symnames) {
      x1           <- lapply(retlfn, function(x) x[, i])
      x2           <- do.call(cbind, x1)
      colnames(x2) <- featnames
      xlist[[i]]   <- x2
    }

    retlfn <- xlist
  }


  return(retlfn)

}

#########################################
# Temporary filler for make_transform2
#' @export
make_transform2 <- function(foo) {
  sprint("hello")
}
