# Improvements & Known Issues

  - Wishlist
    - Statusbar: battery indicator, screen orientation, exit, OSK, frontlight controls, etc
    - Practical toolset. Secure the configs in NiLuJe usbnet package or stop using it altogether. Right now I have an onboard toolchain, want emacs running.
    - Replace logo. Right now it is an old gnome-terminal logo desaturated.
    
  - efbpad.sh
    - Address MTK bt system: launch-mtkbtd.sh if not running, ask for bt on, poweroff bt on exit [link](https://github.com/koreader/koreader/issues/12739)
    - Remove mandatory dependence on NiLuJe usbnet (by default spawn /bin/sh not tmux)
    - Pick the keyboard event device by filtering instead of always trying /dev/input/event3

  - fbpad
    - Sometimes small screen updates don't draw. Lengthen efbpad eink refresh queue to 2
    - Would it perform better to refresh rectangles on the screen instead of always asking fbink for a full refresh?
    - Remove or minimize fbpad's hotkeys, multiplexing, big history buffer. External utils (tmux) do all that. 

  - kbreader
    - There is no end to how much better the interpreter could be. Different locales? Compose key? Numpad? Unicode? 

  - koreader 
    - Add capability to launch efbpad from koreader, switch between them
      - Fix efbpad's draws when started from koreader. [link](https://github.com/koreader/koreader/discussions/12935)
      - Add an efbpad menu item
