#!/bin/sh 

export EFBPAD_PROFILE="/mnt/onboard/.efbpad_profile"
export EFBPAD_CMD="/bin/sh"
export EFBPAD_INSTALL_PREFIX="/mnt/onboard/.adds/efbpad"
export KB_INPUT="/dev/input/event3" # This shouldn't be hardcoded
export PATH="$EFBPAD_INSTALL_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$EFBPAD_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH"

if [ -f "$EFBPAD_PROFILE" ]; then
    echo "[efbpad] Profile found at $EFBPAD_PROFILE"
    source "$EFBPAD_PROFILE"
else
    echo "[efbpad] No profile found at $EFBPAD_PROFILE"
fi

echo "[efbpad] Pulling up bluetooth, finding keyboard"
dbus-send --system --print-reply --dest=com.kobo.mtk.bluedroid /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:"org.bluez.Adapter1" string:"Powered"  variant:boolean:true
for idx in $(seq 1 50); do
    if [ -c "$KB_INPUT" ]; then
	break
    fi
    sleep 0.1
done

# If we got a keyboard, start koreader
if [ ! -c $KB_INPUT ]; then
    >&2 echo "[efbpad] Device $KB_INPUT not found. Doing cleanup and exit."
    RETURN_VALUE=1
fi

echo "[efbpad] Configuring framebuffer"
export OLD_FB_DEPTH="$(fbdepth -g)"
export OLD_FB_ROTA="$(fbdepth -o)"
fbdepth -d 32 -r 2 # on clara bw: 0,2 = landscape, 3=portrait, 1=upside down

echo "[efbpad] Starting kbreader, fbpad"
# This command will continue until the pipe breaks
kbreader $KB_INPUT | fbpad $EFBPAD_CMD

echo "[efbpad] Cleaning up: turning off bluetooth and resetting framebuffer"
dbus-send --system --print-reply --dest=com.kobo.mtk.bluedroid /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:"org.bluez.Adapter1" string:"Powered"  variant:boolean:false
fbdepth -d "$OLD_FB_DEPTH" -r "$OLD_FB_ROTA"
    
echo "[efbpad] Goodbye!"
exit 0
