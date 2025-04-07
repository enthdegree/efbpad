# efbpad

A bluetooth keyboard terminal for a Kobo Clara BW.

Relevant links:
- [A video of it in action](https://youtube.com/shorts/0Jld5KgFcXU)
- A related repo, [kobo-emacs](https://github.com/enthdegree/kobo-emacs/)
- [TODO.md](TODO.md)

<p align="center">
  <img alt="Wide" src="./images/efbpad_1.jpeg" width="45%">
  <img alt="Detail" src="./images/efbpad_2.jpeg" width="45%">
</p>

This is completely untested works-for-me-ware. Although this doesn't touch any non-user directories, you could still brick your device if you don't know what you're doing so be careful. 

## Install

Pre-built packages are available [here](https://mega.nz/folder/mU4kQa7L#9MGGHw2HltTiviuZUtqynw).

- On the Kobo, install [kfmon](https://github.com/NiLuJe/kfmon) and [nickelmenu](https://pgaskin.net/NickelMenu/) if you don't already have them.
- Merge the contents of the package with the Kobo's `/mnt/onboard` (n.b. there are files starting with `.`). Alternatively, put the tarball in `/mnt/onboard/.kobo/KoboRoot.tgz` and reboot. Either of these will create an efbpad entry in kfmon, nickelmenu and koreader's Tools menu.
  
## Usage

 - Before starting, pair your bluetooth keyboard to the Kobo through the Kobo UI.
 - While your keyboard is set to try & pair with the Kobo, run efbpad. Once the keyboard is found it will present the terminal.
 - efbpad shuts down and cleans up when the keyboard disconnects, when the shell terminates, or if it doesn't find a keyboard to use within 5 seconds of launch.

### Controlling fbpad
`fbpad` control sequences have been moved to a fifo in `/mnt/onboard/.adds/efbpad/run/fbpad_[pid]`.
For example, to reload the clrfile (fonts and colors config), try running `echo -n -e '\x05' > /mnt/onboard/.adds/efbpad/run/fbpad_[pid]`.

`fbpad` will look for fonts and colors according to the config `/mnt/onboard/.adds/efbpad/fbpad_clrfile`.
By default it will fall back to `/mnt/onboard/fonts/tf/{regular,bold,italic}.tf.`

The included fonts were produced on the kobo as so, running from a folder containing DejaVu ttfs:
```
mkfn -h 44 -w 24 DejaVuSansMono.ttf:42 > /mnt/onboard/fonts/tf/regular_large.tf
mkfn -h 44 -w 24 DejaVuSansMono-Oblique.ttf:42 > /mnt/onboard/fonts/tf/italic_large.tf
mkfn -h 44 -w 24 DejaVuSansMono-Bold.ttf:42 > /mnt/onboard/fonts/tf/bold_large.tf
mkfn -h 36 -w 18 DejaVuSansMono.ttf:31 > /mnt/onboard/fonts/tf/regular_small.tf
mkfn -h 36 -w 18 DejaVuSansMono-Oblique.ttf:31 > /mnt/onboard/fonts/tf/italic_small.tf
mkfn -h 36 -w 18 DejaVuSansMono-Bold.ttf:31 > /mnt/onboard/fonts/tf/bold_small.tf
```

### usbnet
NiLuJe has helpfully provided a package containing busybox, tmux and ssh
[here](https://www.mobileread.com/forums/showthread.php?t=254214).
As described in the link, it creates several tunnels via udev rule (then `/usr/local/stuff/bin/stuff-daemons.sh`) which should be disabled with
```
touch /mnt/onboard/niluje/usbnet/etc/NO_TELNET
touch /mnt/onboard/niluje/usbnet/etc/NO_SSH
```

### Uninstall
For uninstallation, efbpad creates these files and directories:
 - `/mnt/onboard/.adds/efbpad`
 - `/mnt/onboard/fonts/tf`
 - `/mnt/onboard/efbpad.png` 
 - `/mnt/onboard/.adds/kfmon/config/efbpad.ini`
 - `/mnt/onboard/.adds/koreader/plugins/efbpad.koplugin`

## Development 

### Build
 - Run `make` to produce an update package `KoboRoot.tgz`.
   This requires a cross-compiling environment. The path of least resistance is building and enabling the kobo env from [`koxtoolchain`](https://github.com/koreader/koxtoolchain).

### Project Structure
Broadly, we string together 4 components. 
An effort has been made to keep them as decoupled as possible.
 - [`FBInk`](https://github.com/NiLuJe/FBInk): A library for eink screen drawing by NiLuJe.
 - [`fbpad`](https://github.com/aligrudi/fbpad): A framebuffer terminal emulator by aligrudi.
   We use a very lightly patched version of fbpad: it occasionally
   makes a call to FBInk to refresh the screen.
    - Here we follow the example of a similar project, [`fbpad-eink`](https://github.com/kisonecat/fbpad-eink), which
      took a more integrated approach to refreshes and had a different
      keyboard system.
 - `kbreader` (developed here): Under proper conditions keyboards appear in linux as
   event devices. `kbreader` acts as the interpreter to translate keystrokes
   coming out of an event device into strings printed to stdout.
   This is a standalone utility.
   When you start `fbpad` it waits for chars from stdin. We get `fbpad`
   to listen to the keyboard by piping kbreader into it as so:
   `kbreader /dev/input/event3 | fbpad the_shell`.
    - `kbreader` is spiritually identical to the onscreen keyboard in
      a similar project [`inkvt`](https://github.com/llandsmeer/inkvt), except our keyboard reader is decoupled
      from the rest of the software, our event device is not a touchscreen,
      and we use fbpad instead of a bespoke VT.
 - `efbpad.sh` (developed here): Script that does efbpad startup & shutdown. At startup efbpad (`efbpad.sh`) will:
   - `source /mnt/onboard/.efbpad_profile` if it exists.
   - Turn on the Kobo's bluetooth.
   - Try and open the event device at `$KB_EVDEV` (default `"/dev/input/event3"`). If no device is there, it'll wait 5 seconds after bluetooth up for the keyboard to appear. 
