#' Setup Discord Rich Presence Integration
#'
#' Configures the Discord Rich Presence integration for RStudio.
#' This function checks for Python and pypresence, installs pypresence if needed,
#' and adds startup code to your .Rprofile.
#'
#' @export
#' @examples
#' \dontrun{
#' discordrpc::setup()
#' }
setup <- function() {
  # --- Python Executable Check ---
  python_info <- find_python()
  if (!python_info$found) {
    warning("Python could not be automatically detected.")
    message("Please install Python 3 and ensure it is in your system PATH.")
    message("You can download Python from: https://www.python.org/downloads/")
    message("After installing Python, run setup() again.")
    return(invisible(FALSE))
  }

  python_path <- python_info$path
  message(sprintf("Found Python at: %s", python_path))

  # --- pypresence Library Check ---
  if (!check_pypresence(python_path)) {
    message("\nThe 'pypresence' library is required for Discord integration.")
    choice <- readline(prompt = "Would you like to attempt to install it now? (y/n): ")
    if (tolower(trimws(choice)) == "y") {
      if (!install_pypresence(python_path)) {
        message("Setup cannot continue until pypresence is installed.")
        return(invisible(FALSE))
      }
    } else {
      message("Please install it manually and run setup() again.")
      message(sprintf("Command: %s -m pip install pypresence", python_path))
      return(invisible(FALSE))
    }
  } else {
    message("pypresence is already installed.")
  }

  # --- .Rprofile Configuration ---
  if (!configure_rprofile()) {
    return(invisible(FALSE))
  }

  message("\n==================================================================")
  message("Setup complete! Discord Rich Presence will start automatically")
  message("the next time you open RStudio.")
  message("\nYou can also start it manually with: discordrpc::start()")
  message("And stop it with: discordrpc::stop()")
  message("==================================================================\n")

  return(invisible(TRUE))
}

#' Configure .Rprofile for Auto-Start
#'
#' Adds startup code to the user's .Rprofile
#'
#' @return Logical indicating success
#' @keywords internal
configure_rprofile <- function() {
  # Get .Rprofile path
  home <- Sys.getenv("HOME")
  if (home == "") {
    home <- path.expand("~")
  }
  rprofile_path <- file.path(home, ".Rprofile")

  # Define the lines to be added
  header <- "## Discord Rich Presence Integration"
  lib_line <- "suppressMessages(suppressWarnings(library(discordrpc)))"
  start_line <- "suppressMessages(discordrpc::start())"
  end_marker <- "## End Discord Rich Presence"

  # Check if already configured
  if (file.exists(rprofile_path)) {
    content <- readLines(rprofile_path, warn = FALSE)
    if (any(grepl("discordrpc::start\\(\\)", content))) {
      message("\n.Rprofile already configured for Discord Rich Presence.")
      return(TRUE)
    }
  }

  # Write the configuration to .Rprofile
  tryCatch({
    # Append to .Rprofile
    cat(
      sprintf("\n%s\n", header),
      sprintf("%s\n", lib_line),
      sprintf("%s\n", start_line),
      sprintf("%s\n", end_marker),
      file = rprofile_path,
      append = TRUE
    )
    message(sprintf("\nAdded startup configuration to: %s", rprofile_path))
    message("The integration will start automatically when you restart RStudio.")
    return(TRUE)
  }, error = function(e) {
    warning("Failed to write to .Rprofile file.")
    message("\nPlease add the following lines to your .Rprofile file manually:")
    message("   library(discordrpc)")
    message("   discordrpc::start()")
    message(sprintf("\nError: %s", e$message))
    return(FALSE)
  })
}
