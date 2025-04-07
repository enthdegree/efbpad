# Pending Improvements & Known Issues

  - General
    - Exit to nickel leaves the screen corrupted
    - Link binaries more directly instead of relying on `$LD_LIBRARY_PATH`
    - A touch statusbar would be nice: battery indicator, screen orientation, exit, OSK, frontlight controls, etc
    
  - efbpad.sh
    - Pick the keyboard ``$KB_EVDEV`` by filtering instead of always trying `/dev/input/event3`

  - fbpad
    - Access framebuffer info through FBInk instead of vinfo/finfo 
    - Currently we don't properly set `TERM=fbpad-256`
    - Much fbpad functionality is redundant to tmux (history buffer, multiplexing)

  - kbreader
    - There is no end to how much better the key interpreter could be. Different locales? Compose key? Numpad/Numlock? Unicode?
