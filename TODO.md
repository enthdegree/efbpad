# Improvements & Known Issues

  - Wishlist
    - Statusbar: battery indicator, screen orientation, exit, OSK, frontlight controls, etc
    - Practical toolset. Secure the configs in NiLuJe usbnet package or stop using it altogether. Right now I have an onboard toolchain, want emacs running.
    - Replace logo. Right now it is an old gnome-terminal logo desaturated.
    
  - efbpad.sh
    - Pick the keyboard event device by filtering instead of always trying /dev/input/event3

  - fbpad
    - Would it perform better to refresh rectangles on the screen instead of always asking fbink for a full refresh?
    - Remove or minimize fbpad's hotkeys, multiplexing, big history buffer. External utils (tmux) do all that. 

  - kbreader
    - There is no end to how much better the interpreter could be. Different locales? Compose key? Numpad? Unicode?

  - koreader
    - efbpad.koplugin: when fbpad exits we should redraw the gui