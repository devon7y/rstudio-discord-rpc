#' Start Discord Rich Presence Integration
#'
#' Initializes the Discord Rich Presence integration for RStudio.
#' This function starts a periodic monitoring process that updates your Discord
#' status based on the currently active file in RStudio.
#'
#' @export
#' @examples
#' \dontrun{
#' discordrpc::start()
#' }
start <- function() {
  # Check if rstudioapi is available
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    message("Discord RPC: rstudioapi package is required. Installing...")
    utils::install.packages("rstudioapi")
  }

  # Check if later is available
  if (!requireNamespace("later", quietly = TRUE)) {
    message("Discord RPC: later package is required. Installing...")
    utils::install.packages("later")
  }

  # Stop any existing integration
  stop()

  # Get Python executable path
  python_info <- find_python()
  if (!python_info$found) {
    warning("Discord RPC: Python executable not found. Please run discordrpc::setup().")
    return(invisible(FALSE))
  }
  python_path <- python_info$path

  # Get Python script path
  script_path <- system.file("python", "update_presence.py", package = "discordrpc")
  if (script_path == "" || !file.exists(script_path)) {
    warning("Discord RPC: Python script not found. Package may not be installed correctly.")
    return(invisible(FALSE))
  }

  # Create communication file in temp directory
  comm_file <- file.path(tempdir(), sprintf("rstudio_discord_rpc_comm_%s.txt",
                                            format(Sys.time(), "%Y%m%d%H%M%S%OS3")))

  # Store in package environment
  env <- pkg_env()
  env$comm_file <- comm_file
  env$last_file <- ""

  # Get initial active file
  current_file <- get_active_file()

  # Write initial file to communication file
  tryCatch({
    writeLines(current_file, comm_file)
  }, error = function(e) {
    warning(sprintf("Discord RPC: Could not write to communication file: %s", e$message))
    return(invisible(FALSE))
  })

  # Launch Python script in background
  if (.Platform$OS.type == "windows") {
    # Windows: use START /B for background execution
    cmd <- sprintf('START /B "" "%s" "%s" "%s" "%s" > NUL 2>&1',
                   python_path, script_path, comm_file, current_file)
    shell(cmd, wait = FALSE, intern = FALSE)
  } else {
    # Unix/Mac: use nohup for background execution
    cmd <- sprintf('nohup "%s" "%s" "%s" "%s" > /dev/null 2>&1 &',
                   python_path, script_path, comm_file, current_file)
    system(cmd)
  }

  # Store Python process info for cleanup
  env$python_launched <- TRUE

  # Schedule first update using later package
  later::later(update, delay = 2)

  message("Discord Rich Presence integration started.")
  return(invisible(TRUE))
}

#' Get Active File from RStudio
#'
#' Retrieves the path of the currently active file in RStudio
#'
#' @return Character string with file path, or empty string if no file is active
#' @keywords internal
get_active_file <- function() {
  tryCatch({
    if (rstudioapi::isAvailable()) {
      ctx <- rstudioapi::getActiveDocumentContext()
      if (!is.null(ctx) && !is.null(ctx$path) && ctx$path != "") {
        return(ctx$path)
      }
    }
    return("")
  }, error = function(e) {
    return("")
  })
}
