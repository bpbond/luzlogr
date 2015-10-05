#' Lightweight logging for R
#'
#' This package provides flexible but lightweight logging facilities for R scripts.
#' Supports priority levels for logs and messages, flagging messages,
#' capturing script output, switching logs, and logging to files or connections.
#'
#' @import assertthat
#' @docType package
#' @name luzlogr
NULL


DEBUG <- FALSE
msg <- function(...) if(DEBUG) message(...)
