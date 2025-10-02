# Implementation Notes: RStudio vs MATLAB Discord Rich Presence

## Architecture Comparison

### MATLAB Implementation
- **Namespace**: `+discordrpc/` package
- **Timer System**: MATLAB's built-in `timer` object with `fixedRate` execution
- **Startup**: Modified `startup.m` in userpath
- **Exit Handling**: Modified `finish.m` for cleanup
- **Active File Detection**: `matlab.desktop.editor.getActive`
- **Process Management**: System calls with `nohup` (Unix) for Python

### RStudio Implementation
- **Package**: Standard R package structure
- **Timer System**: `later::later()` with recursive scheduling
- **Startup**: Modified `.Rprofile` in home directory
- **Exit Handling**: Automatic cleanup (no .Last needed, relies on process termination)
- **Active File Detection**: `rstudioapi::getActiveDocumentContext()$path`
- **Process Management**: Same system calls with `nohup` (Unix) / `START /B` (Windows)

## Feature Parity

| Feature | MATLAB | RStudio | Implementation |
|---------|--------|---------|----------------|
| Auto-detect active file | ✅ | ✅ | `rstudioapi::getActiveDocumentContext()` |
| Real-time updates (2s) | ✅ | ✅ | `later::later()` with 2s delay |
| Silent background | ✅ | ✅ | Same Python script approach |
| One-time setup | ✅ | ✅ | `setup()` function |
| Cross-platform | ✅ | ✅ | Platform-specific commands |
| Manual start/stop | ✅ | ✅ | `start()` / `stop()` functions |
| Auto-start on launch | ✅ | ✅ | `.Rprofile` modification |
| Python/pypresence check | ✅ | ✅ | Same verification logic |
| GUI controls | ❌ | ✅ | RStudio Addins (bonus!) |

## Key Differences

### 1. Periodic Execution
**MATLAB**: Uses built-in `timer` object
```matlab
t = timer('Period', 2, 'ExecutionMode', 'fixedRate');
t.TimerFcn = {@discordrpc.update};
```

**RStudio**: Uses `later` package with recursion
```r
update <- function() {
  # ... do work ...
  later::later(update, delay = 2)  # Reschedule self
}
```

### 2. Environment/State Storage
**MATLAB**: Stores in base workspace using `assignin()`
```matlab
assignin('base', 'discordRPCTimer', t);
assignin('base', 'discordRPCCommFile', commFilePath);
```

**RStudio**: Uses package environment
```r
pkg_env <- function() {
  if (!exists(".discordrpc_env", envir = .GlobalEnv)) {
    assign(".discordrpc_env", new.env(), envir = .GlobalEnv)
  }
  get(".discordrpc_env", envir = .GlobalEnv)
}
```

### 3. Package Structure
**MATLAB**: Namespace package (`+discordrpc`)
- Simpler, just `.m` files in a `+` prefixed directory
- No formal package system

**RStudio**: Standard R package
- Full DESCRIPTION, NAMESPACE, documentation
- Installable via devtools/CRAN-style
- Can include addins, vignettes, etc.

### 4. Additional Features in RStudio Version
1. **RStudio Addins**: Menu-driven start/stop/setup
2. **Roxygen Documentation**: Proper help files
3. **Package Management**: Install via devtools
4. **Better Dependency Handling**: Automatic installation of `rstudioapi` and `later`

## Python Script Changes

The Python script is almost identical, with only these changes:
1. Client ID: Changed from MATLAB Discord app to RStudio Discord app
2. Text: "In MATLAB" → "In RStudio"
3. Image: "matlab_logo" → "rstudio_logo"

## Setup Requirements

### MATLAB Version
1. Python 3.x in PATH
2. `pypresence` library
3. Modify `startup.m` and `finish.m`

### RStudio Version
1. Python 3.x in PATH
2. `pypresence` library
3. Modify `.Rprofile`
4. Install R packages: `rstudioapi`, `later`

## Installation Comparison

### MATLAB
```matlab
% After placing files in plugin directory
discordrpc.setup()
% Restart MATLAB
```

### RStudio
```r
# Install package
devtools::install_github("user/rstudio-discord-rpc")
# OR
devtools::install("/path/to/package")

# Run setup
discordrpc::setup()

# Restart RStudio
```

## Discord Application Setup

Both implementations require creating a Discord application:

1. Go to https://discord.com/developers/applications
2. Create new application
3. Copy Client ID
4. Update in Python script:
   - MATLAB: Line 76 in `update_presence.py`
   - RStudio: Line 77 in `inst/python/update_presence.py`
5. Upload logo image (optional):
   - "matlab_logo" for MATLAB
   - "rstudio_logo" for RStudio

## Testing Checklist

- [ ] Python detection works on all platforms
- [ ] pypresence installs correctly
- [ ] `.Rprofile` modification succeeds
- [ ] File monitoring works when switching files rapidly
- [ ] Handles no open files gracefully
- [ ] Stop function kills Python process
- [ ] Cleanup removes temp files
- [ ] Works after RStudio restart
- [ ] RStudio Addins appear in menu
- [ ] Discord status updates correctly

## Future Enhancements

Possible improvements for either implementation:
1. **Git Integration**: Show current branch in status
2. **Project Name**: Display R project or working directory
3. **File Type Icons**: Different icons for .R vs .Rmd files
4. **Idle Detection**: Show "Idle" after no activity for X minutes
5. **Custom Messages**: User-configurable status text
6. **Multiple Files**: Show count of open files
7. **Line Count**: Display lines of code in current file
