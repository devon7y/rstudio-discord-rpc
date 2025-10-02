# RStudio Discord Rich Presence Integration

This R package integrates Discord Rich Presence with RStudio, allowing you to display the R script you are currently editing in your Discord status. It automatically updates as you switch between files, similar to the VS Code "vscord" extension.

## Features

- **Automatic Detection**: Shows the currently active file in the RStudio editor.
- **Real-Time Updates**: Status updates within seconds of switching files.
- **Silent & Efficient**: Runs in the background with minimal performance impact.
- **Easy Setup**: A one-time setup command is all that's needed.
- **Cross-Platform**: Works on Windows, macOS, and Linux.
- **RStudio Addins**: Convenient menu options to start/stop the integration.

## Installation

### Prerequisites

1. **Python 3.6+** must be installed and accessible from your system PATH
2. **Discord** desktop application must be running
3. **RStudio** (obviously!)

### Install the Package

```r
# Install from GitHub
devtools::install_github("devon7y/rstudio-discord-rpc")

# Or install locally
devtools::install("/path/to/rstudio-discord-rpc")
```

### Run Setup

After installation, run the setup command:

```r
discordrpc::setup()
```

This will:
1. Check for Python and install if needed
2. Install the `pypresence` Python library
3. Configure your `.Rprofile` to auto-start the integration

### Restart RStudio

Restart RStudio for the changes to take effect.

## Usage

Once installed and set up, the integration runs automatically. There are no further steps required. Your Discord status will show the file you are editing whenever RStudio is open.

### Manual Control

You can manually control the integration using:

```r
# Start the integration
discordrpc::start()

# Stop the integration
discordrpc::stop()

# Re-run setup
discordrpc::setup()
```

### RStudio Addins

The package also provides RStudio Addins accessible from the **Addins** menu:
- **Start Discord Rich Presence**
- **Stop Discord Rich Presence**
- **Setup Discord Rich Presence**

## How It Works

The package uses a background R process with the `later` package to periodically check the active file in the RStudio editor. When a file change is detected, it writes to a communication file that a lightweight Python script monitors. The Python script then communicates with the local Discord client via its Rich Presence API using the `pypresence` library.

This approach is necessary because R cannot directly interface with Discord's IPC socket.

## Configuration

### .Rprofile Configuration

The setup script adds the following to your `.Rprofile`:

```r
## Discord Rich Presence Integration
suppressMessages(suppressWarnings(library(discordrpc)))
suppressMessages(discordrpc::start())
## End Discord Rich Presence
```

You can manually remove these lines to disable auto-start.

## Troubleshooting

### "Python not found"
Ensure Python is installed and its location is included in your system's `PATH` environment variable.

### "pypresence not installed"
If the automatic installation fails, open a terminal or command prompt and run:
```bash
python -m pip install pypresence
# Or if you get permission errors:
python -m pip install pypresence --break-system-packages
```

### Status not updating
1. Make sure Discord is running
2. Check that you have enabled "Display current activity as a status message" in Discord's settings (User Settings > Activity Privacy)

### Integration won't start
1. Ensure both `rstudioapi` and `later` packages are installed
2. Check that the Python script exists: `system.file("python", "update_presence.py", package = "discordrpc")`
3. Try running `discordrpc::setup()` again

## Platform-Specific Notes

### Windows
- Uses `taskkill` to stop the Python process
- May show command prompt windows briefly when starting

### macOS/Linux
- Uses `pkill` to stop the Python process
- Uses `nohup` for background process execution

## Credits

Inspired by the MATLAB Discord Rich Presence plugin and VS Code Discord extensions.

## License

MIT License - see LICENSE file for details.
