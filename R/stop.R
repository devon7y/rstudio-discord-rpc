#' Stop Discord Rich Presence Integration
#'
#' Stops the Discord Rich Presence integration and cleans up resources.
#' This function kills the background Python process and removes temporary files.
#'
#' @export
#' @examples
#' \dontrun{
#' discordrpc::stop()
#' }
stop <- function() {
  # Get package environment
  env <- pkg_env()

  # Kill Python process
  if (.Platform$OS.type == "windows") {
    # Windows: use taskkill to kill Python process running our script
    # Note: This is less precise than Unix pkill -f
    system('taskkill /F /IM python.exe /FI "WINDOWTITLE eq update_presence.py*" 2>NUL',
           ignore.stdout = TRUE, ignore.stderr = TRUE, wait = FALSE)
  } else {
    # Unix/Mac: use pkill with command line pattern matching
    system('pkill -9 -f "update_presence.py"',
           ignore.stdout = TRUE, ignore.stderr = TRUE, wait = FALSE)
  }

  # Clean up communication file
  if (!is.null(env$comm_file) && file.exists(env$comm_file)) {
    tryCatch({
      unlink(env$comm_file)
    }, error = function(e) {
      warning(sprintf("Failed to delete communication file: %s", e$message))
    })
  }

  # Clear environment variables
  env$comm_file <- NULL
  env$last_file <- NULL
  env$python_launched <- NULL

  return(invisible(NULL))
}
