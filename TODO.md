# Improvements

  - Integration
    - Kobo UI sometimes draws over the terminal, sleeps and turns off bluetooth and wifi after a timeout.
    - Eliminate dependence on NiLuJe's utilities package (i.e. just compile tmux)

  - Features
    - Add a statusbar (battery, brightness, font, orietation, onscreen keyboard, etc).
      - For an onscreen keyboard several others have already done the heavy lifting. (inkvt, koreader)
    - fbpad.sh should pick the keyboard event device by filtering instead of always trying /dev/input/event3
    - Replace the logo. Right now it is an old gnome-terminal logo desaturated.

  - fbpad
    - Would it perform better to refresh rectangles on the screen instead of always asking for a full refresh?
    - Restore or remove all the hotkey/multiplexing features from fbpad.
      We already get most or all of that functionality from tmux. 

  - kbreader
    - After fbpad exits, we need to type a char for our `kbreader | fbpad` pipe to die (by SIGPIPE)
    - There is no end to how much better the interpreter could be.
      - Different locales? Compose key? Numpad? Unicode? 

The likely path forward is to change this into an extension of koreader. 
This solves the nasty integration problem and creates others:
  - Need to start up and manage the Clara BW's bluetooth from inside koreader
  - koreader's already got terminal.koplugin... 
    - Is it responsive? If so consider dropping fbpad
    - Add option to hide OSK
  - If we stay with fbpad...
    - Get fbpad to draw on a subset of the screen
    - Link to koreader's fbink lib
    - Add lua fbpad manager
    - Change glyph rendering from fbpad's obscure tinyfont format to koreader's freetype2
