# Improvements & Known Issues

  - General
    - Link the binaries more directly instead of relying on LD_LIBRARY_PATH env var
    - Statusbar: battery indicator, screen orientation, exit, OSK, frontlight controls, etc
    - Replace logo. Right now it is an old gnome-terminal logo desaturated.
    
  - efbpad.sh
    - Pick the keyboard event device by filtering instead of always trying /dev/input/event3

  - fbpad
    - Would it perform better to refresh rectangles on the screen instead of always asking fbink for a full refresh?
    - Remove or minimize fbpad's hotkeys, multiplexing, big history buffer. External utils (tmux) do all that. 

  - kbreader
    - There is no end to how much better the interpreter could be. Different locales? Compose key? Numpad? Unicode?
