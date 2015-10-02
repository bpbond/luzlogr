# Logging functions

# -----------------------------------------------------------------------------
#' Open a new logfile
#'
#' @param file Name of logfile (character or writeable \code{\link{connection}})
#' @param loglevel Minimum priority level (numeric, optional)
#' @param append Append to logfile? (logical, optional)
#' @param sink Send all console output to logfile? (logical, optional)
#' @return Invisible fully-qualified name of log file
#' @details Open a new logfile. If \code{sink} is TRUE (the default), all
#' screen output will be captured (via \code{\link{sink}}).
#' Re-opening a logfile will erase the previous output unless \code{append}
#' is TRUE.
#' @note Messages will only appear in the logfile if their \code{level} exceeds
#' the log's \code{loglevel}; this allows you to easily change the amount of
#' detail being logged.
#' @examples
#' logfile <- openlog("test")
#' printlog("message")
#' print("This will also appear in the logfile, as sink is TRUE")
#' closelog()
#' readLines(logfile)
#' @export
#' @seealso \code{\link{printlog}} \code{\link{closelog}}
openlog <- function(file, loglevel = -Inf, append = FALSE, sink = TRUE) {

  # Sanity checks
  assert_that(is.numeric(loglevel))
  assert_that(is.logical(append))
  assert_that(is.logical(sink))

  if(is.character(file)) {  # character filename
    description <- file
    closeit <- FALSE
    if(file.exists(file) & !append) {
      file.remove(file)
    }
  } else if(inherits(file, "connection")) {  # connection
    closeit <- !isOpen(file)
    if(!isOpen(file)) {
      open(file, if(append) "a" else "w")
    }
    description <- summary(file)$description
  }
  else stop("'file' must be a character string or a connection")

  # Create a new log in our internal data structure
  newlog(logfile = file, loglevel = loglevel, sink = sink, closeit = closeit)

  if(sink) {
    sink(file, split = TRUE, append = append)
  }

  printlog("Opening", description, level = Inf)
  invisible(description)
} # openlog

# -----------------------------------------------------------------------------
#' Log a message
#'
#' @param ... Expressions to be printed to the log
#' @param level Priority level (numeric, optional)
#' @param ts Print preceding timestamp? (logical, optional)
#' @param cr Print trailing newline? (logical, optional)
#' @param flag Flag this message (e.g. error or warning) (logical, optional)
#' @return Invisible success (TRUE) or failure (FALSE)
#' @details Logs a message, which consists of zero or more printable objects.
#' If the current log was opened with \code{sink} = TRUE, the default,
#' messages are printed to the screen, otherwise not. \code{flaglog} assumes
#' that the message is to be flagged, which \code{printlog} does not.
#' @note Messages will only appear in the logfile if their \code{level} exceeds
#' the log's \code{loglevel}; this allows you to easily change the amount of
#' detail being logged.
#' @examples
#' logfile <- openlog("test")
#' printlog("message")
#' printlog(1, "plus", 1, "equals", 3)
#' closelog()
#' readLines(logfile)
#'
#' logfile <- openlog("test", loglevel = 1)
#' printlog("This message will not appear", level = 0)
#' printlog("This message will appear", level = 1)
#' closelog(sessionInfo = FALSE)
#' readLines(logfile)
#' @export
#' @seealso \code{\link{openlog}} \code{\link{closelog}}
printlog <- function(..., level = 0, ts = TRUE, cr = TRUE, flag = FALSE) {

  # Sanity checks
  assert_that(is.numeric(level))
  assert_that(is.logical(ts))
  assert_that(is.logical(cr))

  args <- list(...)

  # Make sure there's an open log file available
  loglevel <- getlogdata("loglevel")
  if(is.null(loglevel)) return(FALSE)

  # Messages are only printed if their level exceeds the log's level (or an error)
  if(level >= loglevel | flag) {
    if(getlogdata("sink")) { # If capturing everything, output to screen
      file <- stdout()
    } else {  # otherwise, file
      file <- getlogdata("logfile")
    }

    # Print a special message if warning (flag) condition
    if(flag) {
      setlogdata("flags", getlogdata("flags") + 1)
      flagmsg <- "** Flagged message: **\n"
      #       if(loginfo$sink) {
      #         message(flagmsg)
      #       }
      cat(flagmsg, file = file, append = TRUE)
    }

    # Print a timestamp...
    if(ts) cat(date(), " ", file = file, append = TRUE)

    # ...and then the object(s)
    for(i in seq_along(args)) {
      x <- args[[i]]
      # simple objects are printed together on a line
      if(mode(x) %in% c("numeric", "character")) {
        cat(x, " ", file = file, append = TRUE)
      } else { # more complex; let print() handle it
        if(getlogdata("sink")) {
          print(x)
        } else {
          capture.output(x, file = file, append = TRUE)
        }
      }
    }

    if(cr) cat("\n", file = file, append = TRUE)
  }

  invisible(TRUE)
} # printlog

# -----------------------------------------------------------------------------
#' @rdname printlog
#' @export
flaglog <- function(...) printlog(..., flag = TRUE)

# -----------------------------------------------------------------------------
#' Close current logfile
#'
#' @param sessionInfo Print \code{\link{sessionInfo}} output? (logical, optional)
#' @return Number of flagged messages (numeric)
#' @details Close current logfile
#' @export
#' @seealso \code{\link{openlog}} \code{\link{printlog}}
closelog <- function(sessionInfo = TRUE) {

  # Make sure there's an open log file available to close
  logfile <- getlogdata("logfile")
  if(is.null(logfile)) return(NULL)

  if(is.character(logfile))
    description <- basename(logfile)
  else
    description <- summary(logfile)$description

  flags <- getlogdata("flags")
  printlog("Closing", description, "flags =", flags, level = Inf)

  # Remove sink, if applicable
  if(getlogdata("sink") & sink.number()) sink()

  # Append sessionInfo() to file
  if(sessionInfo) {
    cat("-------\n", file = logfile, append = TRUE)
    capture.output(sessionInfo(), file = logfile, append = TRUE)
  }

  # Close file or connection, if necessary
  if(getlogdata("closeit")) close(logfile)

  # Remove log from our internal data structure
  removelog()

  invisible(flags)
} # closelog
