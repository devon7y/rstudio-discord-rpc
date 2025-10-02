import sys
import time
from pypresence import Presence, exceptions
import os

def update_presence_loop(client_id, comm_file_path, initial_file_name):
    RPC = None
    current_file = initial_file_name
    last_mtime = 0

    try:
        RPC = Presence(client_id)
        RPC.connect()
        start_time = int(time.time()) # Initialize start_time once
        last_details_text = None
        last_state_text = None

        while True:
            try:
                # Check for updates in the communication file
                if os.path.exists(comm_file_path):
                    new_mtime = os.path.getmtime(comm_file_path)
                    if new_mtime > last_mtime:
                        with open(comm_file_path, 'r') as f:
                            updated_file = f.read().strip()
                        if updated_file != current_file:
                            current_file = updated_file
                            last_mtime = new_mtime

                # Determine current presence details
                if current_file:
                    details_text = f"Editing {os.path.basename(current_file)}"
                    state_text = "In RStudio"
                else:
                    details_text = "Idle"
                    state_text = "In RStudio"

                # Only update Discord if details have changed
                if details_text != last_details_text or state_text != last_state_text:
                    RPC.update(
                        details=details_text,
                        state=state_text,
                        start=start_time,
                        large_image="rstudio_logo",
                        large_text="RStudio"
                    )
                    last_details_text = details_text
                    last_state_text = state_text

            except exceptions.PipeClosed:
                try:
                    RPC.connect()
                    # Force update after reconnect
                    last_details_text = None
                    last_state_text = None
                except Exception as reconnect_e:
                    pass # Fail silently on reconnect errors
            except Exception as e:
                pass # Fail silently on other errors

            time.sleep(5) # Check and update every 5 seconds

    except exceptions.PipeClosed as e:
        pass # Fail silently on initial connection errors
    except Exception as e:
        pass # Fail silently on other initial setup errors
    finally:
        if RPC:
            try:
                RPC.close()
            except Exception as close_e:
                pass # Fail silently on close errors
        sys.exit(1)

if __name__ == "__main__":
    # Discord Application Client ID for RStudio
    # NOTE: You'll need to create a Discord application at https://discord.com/developers/applications
    # and replace this with your actual client ID
    client_id = "1423428454992580838"
    comm_file_path = None
    initial_file_name = ""

    if len(sys.argv) > 1:
        comm_file_path = sys.argv[1]
    if len(sys.argv) > 2:
        initial_file_name = sys.argv[2]

    if comm_file_path:
        update_presence_loop(client_id, comm_file_path, initial_file_name)
    else:
        sys.exit(1)
