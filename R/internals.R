# loginfo - backend support functions
#
# Keep a clean separation between implementation of loginfo data and use

PKG.ENV <- new.env()    # environment in which to store logging info
LOGINFO <- ".loginfo"   # name of storage variable

# LOGINFO, above, is implemented as a list of lists.
# The first-order list operates as a stack, where the last entry holds the
# currently-active log information. Each entry, in turn, is a list of
# information about that particular log. `newlog` pushes a new entry on to
# the stack, while `closelog` pops the last one off.

# -----------------------------------------------------------------------------
#' Create new log
#'
#' @param logfile Name of log file
#' @param loglevel Minimum priority level (numeric, optional)
#' @param sink Send all console output to logfile? (logical, optional)
#' @param closeit File should be closed when log closes?
#' @details This handles internal data tracking only, not the file on disk.
#' @keywords internal
newlog <- function(logfile, loglevel, sink, closeit) {

  # Sanity checks
  assert_that(is.character(logfile) | inherits(logfile, "connection"))
  assert_that(is.numeric(loglevel))
  assert_that(is.logical(sink))
  assert_that(is.logical(closeit))

  # If log info already exists, close the previous file
  if(exists(LOGINFO, envir = PKG.ENV)) {
    warning("Closing previous log file")
    closelog()
  }

  loginfo <- list(logfile = logfile,
                  loglevel = loglevel,
                  sink = sink,
                  closeit = closeit,
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

  if(!datum %in% names(loginfo))
    stop("Unknown data requested:", datum)

  loginfo[[datum]]
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
