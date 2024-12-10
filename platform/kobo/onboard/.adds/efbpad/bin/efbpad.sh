#!/bin/sh

export EFBPAD_INSTALL_PREFIX="/mnt/onboard/.adds/efbpad"
export PATH="$EFBPAD_INSTALL_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$EFBPAD_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH"
export KB_INPUT="/dev/input/event3" # This shouldn't be hardcoded

echo 2 > "/sys/class/graphics/fb0/rotate" # Landscape
if [ -c $KB_INPUT ]; then
    kbreader $KB_INPUT | fbpad tmux new-session -A -s main
    RETURN_VALUE=$?
else
    echo "Device $KB_INPUT not found. Doing cleanup and exit."
    RETURN_VALUE=1
fi
echo 3 > "/sys/class/graphics/fb0/rotate" # Portrait

exit ${RETURN_VALUE}

