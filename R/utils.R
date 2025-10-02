# Utility functions for Discord RPC integration

#' Find Python Executable
#'
#' Searches for a valid Python executable on the system
#'
#' @return A list with 'path' (string) and 'found' (logical)
#' @keywords internal
find_python <- function() {
  # Try common Python commands
  python_cmds <- c("python3", "python")

  for (cmd in python_cmds) {
    path <- Sys.which(cmd)
    if (path != "") {
      return(list(path = path, found = TRUE))
    }
  }

  # Try common installation paths
  if (.Platform$OS.type == "windows") {
    common_paths <- c(
      "C:/Python39/python.exe",
      "C:/Python38/python.exe",
      "C:/Python37/python.exe",
      file.path(Sys.getenv("LOCALAPPDATA"), "Programs", "Python", "Python39", "python.exe"),
      file.path(Sys.getenv("LOCALAPPDATA"), "Programs", "Python", "Python38", "python.exe")
    )
  } else {
    common_paths <- c(
      "/usr/bin/python3",
      "/usr/local/bin/python3",
      "/opt/homebrew/bin/python3",
      "/usr/bin/python",
      "/usr/local/bin/python"
    )
  }

  for (path in common_paths) {
    if (file.exists(path)) {
      return(list(path = path, found = TRUE))
    }
  }

  return(list(path = "", found = FALSE))
}

#' Check if pypresence is Installed
#'
#' Verifies that the pypresence Python library is installed
#'
#' @param python_path Path to Python executable
#' @return Logical indicating if pypresence is installed
#' @keywords internal
check_pypresence <- function(python_path) {
  cmd <- sprintf('"%s" -m pip show pypresence', python_path)
  result <- system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
  return(result == 0)
}

#' Install pypresence Library
#'
#' Attempts to install the pypresence Python library
#'
#' @param python_path Path to Python executable
#' @return Logical indicating success
#' @keywords internal
install_pypresence <- function(python_path) {
  message("Installing pypresence...")
  cmd <- sprintf('"%s" -m pip install pypresence', python_path)
  result <- system(cmd, ignore.stdout = FALSE, ignore.stderr = FALSE)

  if (result == 0) {
    message("pypresence installed successfully.")
    return(TRUE)
  }

  # Installation failed - provide detailed instructions
  message("\n-------------------- PIP INSTALLATION FAILED --------------------")
  message("The automatic installation of the 'pypresence' library failed.")
  message("This is common on systems that protect the default Python environment.\n")
  message("------------------------- ACTION REQUIRED -------------------------")
  message("To fix this, please perform the following steps:")
  message("1. Open a new Terminal (on macOS/Linux) or Command Prompt (on Windows).")
  message("2. Copy and paste the following command into the terminal and press Enter:\n")
  message(sprintf("   %s -m pip install pypresence --break-system-packages\n", python_path))
  message("3. After the command completes successfully, return to R and run the setup again:\n")
  message("   discordrpc::setup()\n")
  message("-----------------------------------------------------------------\n")

  return(FALSE)
}

#' Get Package Environment
#'
#' Returns the package environment for storing state
#'
#' @return Environment
#' @keywords internal
pkg_env <- function() {
  if (!exists(".discordrpc_env", envir = .GlobalEnv)) {
    assign(".discordrpc_env", new.env(), envir = .GlobalEnv)
  }
  get(".discordrpc_env", envir = .GlobalEnv)
}
