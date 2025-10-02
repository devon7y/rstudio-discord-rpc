#' Update Discord Rich Presence
#'
#' Checks the active editor file and updates Discord Rich Presence.
#' This function is called periodically by the later package and is not
#' intended to be called directly by the user.
#'
#' @keywords internal
update <- function() {
  # Get package environment
  env <- pkg_env()

  # Check if integration is still running
  if (is.null(env$comm_file) || !file.exists(env$comm_file)) {
    # Communication file is gone, stop the integration
    return(invisible(NULL))
  }

  # Get current active file
  current_file <- get_active_file()

  # Initialize last_file if not set
  if (is.null(env$last_file)) {
    env$last_file <- ""
  }

  # Check if file has changed
  if (current_file != env$last_file) {
    # Update last known file
    env$last_file <- current_file

    # Write to communication file
    tryCatch({
      writeLines(current_file, env$comm_file)
    }, error = function(e) {
      warning(sprintf("Discord RPC: Could not write to communication file: %s", e$message))
    })
  }

  # Schedule next update (recursive call)
  later::later(update, delay = 2)

  return(invisible(NULL))
}
