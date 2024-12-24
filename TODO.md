# Improvements & Known Issues

  - Features
    - A statusbar would be great (have fbpad touch a subset of the screen, battery, screen orientation, exit, OSK, frontlight controls)
    - Remove dependence on NiLuJe usbnet tmux
    - efbpad.sh should pick the keyboard event device by filtering instead of always trying /dev/input/event3
    - Replace the logo. Right now it is an old gnome-terminal logo desaturated.

  - fbpad
    - Sometimes small screen updates don't draw. Lengthen efbpad eink refresh queue to 2
    - Would it perform better to refresh rectangles on the screen instead of always asking fbink for a full refresh?
    - Patch to remove all the hotkey, multiplexing, history features. We get all that from tmux. 

  - kbreader
    - There is no end to how much better the interpreter could be.
      - Different locales? Compose key? Numpad? Unicode? 

  - koreader 
    - Add capability to launch efbpad from koreader, switch between them
      - Fix efbpad's draws when started from koreader. [link](https://github.com/koreader/koreader/discussions/12935)
      - Update efbpad.sh to MTK bt system: launch-mtkbtd.sh if not running, ask for bt on ([link]((https://github.com/koreader/koreader/issues/12739))), poweroff bt on exit
      - Add an efbpad menu item
