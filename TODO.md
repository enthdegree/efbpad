# Improvements & Known Issues

  - General
    - Exit to nickel leaves the screen corrupted
    - Link binaries more directly instead of relying on LD_LIBRARY_PATH env var
    - A touch statusbar would be nice: battery indicator, screen orientation, exit, OSK, frontlight controls, etc
    
  - efbpad.sh
    - Pick the keyboard event device by filtering instead of always trying /dev/input/event3

  - fbpad
    - Remove or minimize fbpad's hotkeys, multiplexing, big history buffer. External utils (tmux) do all that. 

  - kbreader
    - There is no end to how much better the interpreter could be. Different locales? Compose key? Numpad? Unicode?
