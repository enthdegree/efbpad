#!/bin/sh 
export EFBPAD_PROFILE="/mnt/onboard/.efbpad_profile"
export EFBPAD_TMPDIR='/tmp/efbpad'
export EFBPAD_CMD="/bin/sh"
export EFBPAD_PREFIX="/mnt/onboard/.adds/efbpad"
export FBPAD_FIFO_DIR="/tmp/efbpad"
export KB_EVDEV="/dev/input/event3" # This shouldn't be hardcoded
export PATH="$EFBPAD_PREFIX/bin:$PATH"

# Set up tmpdir and logging
mkdir -p "$EFBPAD_TMPDIR"
if [ -z "$EFBPAD_SCRIPT" ]; then
  export EFBPAD_SCRIPT="$0"
  script -a "$EFBPAD_TMPDIR/efbpad.log" -c "$0"
  exit 0
fi
echo

# Source profile if it exists
if [ -f "$EFBPAD_PROFILE" ]; then
    echo "[efbpad] Profile found at $EFBPAD_PROFILE"
    source "$EFBPAD_PROFILE"
else
    echo "[efbpad] No profile found at $EFBPAD_PROFILE"
fi

# set up fbpad FIFO 
export FBPAD_FIFO="$EFBPAD_TMPDIR/fbpad_fifo"
if [ -e "$FBPAD_FIFO" ]; then
    echo "[efbpad] $FBPAD_FIFO file already exists."
    rm "$FBPAD_FIFO"
fi
mkfifo "$FBPAD_FIFO"
if [ ! -p "$FBPAD_FIFO" ]; then
    echo "[efbpad] Failed to create fifo $FBPAD_FIFO."
    unset FBPAD_FIFO
fi

# Set up LD_LIBRARY_PATH
if [ -z "$LD_LIBRARY_PATH" ]; then
    export LD_LIBRARY_PATH="$EFBPAD_PREFIX/lib"
else
    export LD_LIBRARY_PATH="$EFBPAD_PREFIX/lib:$LD_LIBRARY_PATH"
fi


# Find keyboard
echo "[efbpad] Pulling up bluetooth, finding keyboard"
dbus-send --system --print-reply --dest=com.kobo.mtk.bluedroid /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:"org.bluez.Adapter1" string:"Powered"  variant:boolean:true
for idx in $(seq 1 50); do
    if [ -c "$KB_EVDEV" ]; then
	break
    fi
    sleep 0.1
done

# If we got a keyboard, start koreader
if [ ! -c $KB_EVDEV ]; then
    >&2 echo "[efbpad] Device $KB_EVDEV not found. Doing cleanup and exit."
    RETURN_VALUE=1
fi

# Configure framebuffer
echo "[efbpad] Configuring framebuffer"
export OLD_FB_DEPTH="$(fbdepth -g)"
export OLD_FB_ROTA="$(fbdepth -o)"
fbdepth -d 32 -r 2 # on clara bw: 0,2 = landscape, 3=portrait, 1=upside down

# Start up fbpad
echo "[efbpad] Starting kbreader, fbpad"
kbreader $KB_EVDEV | fbpad $EFBPAD_CMD 

# Cleanup
echo "[efbpad] Cleaning up"
dbus-send --system --print-reply --dest=com.kobo.mtk.bluedroid /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:"org.bluez.Adapter1" string:"Powered"  variant:boolean:false
fbdepth -d "$OLD_FB_DEPTH" -r "$OLD_FB_ROTA"
rm "$FBPAD_FIFO"

echo "[efbpad] Goodbye!"
exit 0
