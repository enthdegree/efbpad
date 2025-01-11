# Pending Improvements & Known Issues

  - General
    - Exit to nickel leaves the screen corrupted
    - Link binaries more directly instead of relying on LD_LIBRARY_PATH env var
    - A touch statusbar would be nice: battery indicator, screen orientation, exit, OSK, frontlight controls, etc
    
  - efbpad.sh
    - Do away with `/mnt/onboard/.efbpad_profile`, rely only on `/mnt/onboard/.adds/efbpad/bin/efbpad.sh` 
    - Pick the keyboard event device by filtering instead of always trying /dev/input/event3

  - fbpad
    - Access framebuffer info through FBInk instead of vinfo/finfo 
    - Minimize fbpad functionality we get from external utils like tmux (history buffer, multiplexing)
    - M-[...] hotkey features are currently inaccessible (must `#define FBPAD_ESC`). We could read chars from a FIFO `/tmp/fbpad_$PID` in another thread to access them.

  - kbreader
    - There is no end to how much better the key interpreter could be. Different locales? Compose key? Numpad/Numlock? Unicode?
