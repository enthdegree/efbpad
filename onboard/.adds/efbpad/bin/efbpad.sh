#!/bin/sh 

export EFBPAD_INSTALL_PREFIX="/mnt/onboard/.adds/efbpad"
export PATH="$EFBPAD_INSTALL_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$EFBPAD_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH"
export KB_INPUT="/dev/input/event3" # This shouldn't be hardcoded

# Ensure bluetooth is up
if ! pgrep "mtkbtd" &> /dev/null; then
    echo "efbpad: Starting mtkbtd..."
    /usr/local/Kobo/mtkbtd-launcher.sh &
fi
dbus-send --system --print-reply --dest=com.kobo.mtk.bluedroid /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:"org.bluez.Adapter1" string:"Powered"  variant:boolean:true

# Wait 5 seconds for the keyboard to connect
for idx in $(seq 1 50); do
    if [ -c $KB_INPUT ]; then
	break
    fi
    sleep 0.1
done

# If we got a keyboard, start koreader
if [ -c $KB_INPUT ]; then
    
    # Set up screen
    export OLD_FB_DEPTH="$(fbdepth -g)"
    export OLD_FB_ROTA="$(fbdepth -o)"
    fbdepth -d 32 -r 2 # on clara bw: 0,2 = landscape, 3=portrait, 1=upside down

    #kbreader $KB_INPUT | fbpad tmux new-session -A -s main
    kbreader $KB_INPUT | fbpad /bin/sh
    dbus-send --system --print-reply --dest=com.kobo.mtk.bluedroid /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:"org.bluez.Adapter1" string:"Powered"  variant:boolean:false
    RETURN_VALUE=$?

    # Revert screen
    fbdepth -d "$OLD_FB_DEPTH" -r "$OLD_FB_ROTA"
    
else
    >&2 echo "efbpad: Device $KB_INPUT not found. Doing cleanup and exit."
    RETURN_VALUE=1
fi

exit $RETURN_VALUE
