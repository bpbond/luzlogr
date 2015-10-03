#' Lightweight logging for R
#'
#' Logging facilities for R scripts. Very lightweight, but supports message
#' prioritization, echoing to screen (or not), timestamps, multiple open
#' logs, etc.
#'
#' @import assertthat
#' @docType package
#' @name luzlogr
NULL


DEBUG <- TRUE
msg <- function(...) if(DEBUG) message(...)
