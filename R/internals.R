# loginfo - backend support functions
#
# Keep a clean separation between implementation of loginfo data and use

PKG.ENV <- new.env()    # environment in which to store logging info
LOGINFO <- ".loginfo"   # name of storage variable

# -----------------------------------------------------------------------------
#' Create new log
#'
#' @param logfile Name of log file
#' @param loglevel Minimum priority level (numeric, optional)
#' @param sink Send all console output to logfile? (logical, optional)
#' @details This handles internal data tracking only, not the file on disk.
#' @keywords internal
newlog <- function(logfile, loglevel, sink) {

  # Sanity checks
  assert_that(is.character(logfile))
  assert_that(is.numeric(loglevel))
  assert_that(is.logical(sink))

  # If log info already exists, close the previous file
  if(exists(LOGINFO, envir = PKG.ENV)) {
    warning("Closing previous log file")
    closelog()
  }

  loginfo <- list(logfile = logfile,
                  loglevel = loglevel,
                  sink = sink,
                  sink.number = sink.number(),
                  flags = 0)

  # Create a (hidden) variable in the package environment to store log info
  assign(LOGINFO, loginfo, envir = PKG.ENV)
}

# -----------------------------------------------------------------------------
#' Remove current log
#'
#' @details This handles internal data tracking only, not the file on disk.
#' @keywords internal
removelog <- function() {
  try(rm(list = LOGINFO, envir = PKG.ENV), silent = TRUE)
}

# -----------------------------------------------------------------------------
#' Get log data
#'
#' @param datum Name of datum to get
#' @return Value of that datum
#' @details This handles internal data tracking only, not the file on disk.
#' @keywords internal
getlogdata <- function(datum) {

  assert_that(is.character(datum))

  # Get the current log data
  if(exists(LOGINFO, envir = PKG.ENV)) {
    loginfo <- get(LOGINFO, envir = PKG.ENV)
  } else {
    warning("No log available")
    return(NULL)
  }

  switch(datum,
         logfile = loginfo$logfile,
         loglevel = loginfo$loglevel,
         sink = loginfo$sink,
         sink.number = loginfo$sink.number,
         flags = loginfo$flags,
         stop("Unknown data requested:", datum)
  )
}

# -----------------------------------------------------------------------------
#' Set log data
#'
#' @param logdata Name of datum to set
#' @param value Value
#' @details This handles internal data tracking only, not the file on disk.
#' @keywords internal
setlogdata <- function(datum, value) {

  assert_that(is.character(datum))

  # Get the current log data
  if(exists(LOGINFO, envir = PKG.ENV)) {
    loginfo <- get(LOGINFO, envir = PKG.ENV)
  } else {
    stop("No log available")
  }

  assert_that(datum %in% names(loginfo))

  # Currently we only allow changing the 'flags' value
  if(datum == "flags") {
    loginfo$flags <- value
  } else
    stop("Error: can't modify", datum)

  assign(LOGINFO, loginfo, envir = PKG.ENV)
}
