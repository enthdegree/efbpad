# kbreader
Print keyboard events from /dev/input/event## to stdout as chars.
This is not a complete handler like linux's drivers/tty/vt/keyboard.c
Rather, kbreader only handles ctrl, shift, alt, capslock.

keymap_dump.py observes (part of) the host system's key behavior
and produces an emulation in _keymap.c

