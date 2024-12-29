# efbpad

A bluetooth keyboard terminal for a Kobo Clara BW.

See the [TODO.md](TODO.md).

<p align="center">
  <img alt="Wide" src="./images/efbpad_1.jpeg" width="45%">
  <img alt="Detail" src="./images/efbpad_2.jpeg" width="45%">
</p>

## Usage

 - Run `make` to produce a package.
   This requires a cross-compiling environment.
   NiLuJe's `koxtoolchain` kobo env is the path of least resistance.
 - On the Kobo, install kfmon and nickelmenu
 - Either merge the contents of `./root/mnt/onboard/` with the kobo's
   `/mnt/onboard`, or put the produced `KoboRoot.tgz` in `/mnt/onboard/.kobo`
   This will create an `efbpad` entry in nickelmenu and koreader.
 - At startup efbpad (`efbpad.sh`) will `source /mnt/onboard/.efbpad_profile` if it exists, turn on bluetooth and try and open the event device at `/dev/input/event3` to use as the keyboard.
   If no device is there, it'll wait 5 seconds after bluetooth up for the keyboard to appear.
 - efbpad shuts down and turns off bluetooth if it never finds a keyboard, if
   the keyboard disconnects or if the shell terminates.

NiLuJe has helpfully provided a package containing busybox, tmux and ssh
[here](https://www.mobileread.com/forums/showthread.php?t=254214).
As described in the link, it creates several tunnels via udev rule (then `/usr/local/stuff/bin/stuff-daemons.sh`) which should be disabled with
```
touch /mnt/onboard/niluje/usbnet/etc/NO_TELNET
touch /mnt/onboard/niluje/usbnet/etc/NO_SSH
```

For uninstallation, efbpad creates these files and directories:
 - `/mnt/onboard/.adds/efbpad`
 - `/mnt/onboard/fonts/tf`
 - `/mnt/onboard/efbpad.png` 
 - `/mnt/onboard/.adds/kfmon/config/efbpad.ini`
 - `/mnt/onboard/.adds/koreader/plugins/efbpad.koplugin`

## Project Structure
Broadly, we string together 4 components. 
An effort has been made to keep them as decoupled as possible.
 - `FBInk`: A library for eink screen drawing by NiLuJe.
 - `fbpad`: A framebuffer terminal emulator by aligrudi.
   We use a very lightly patched version of fbpad: it occasionally
   makes a call to FBInk to refresh the screen.
    - Here we follow the example of a similar project, `fbpad-eink`, which
      took a more integrated approach to refreshes and had a different
      keyboard system.
 - `kbreader`: Under proper conditions keyboards appear in linux as
   event devices. `kbreader` acts as the interpreter to translate keystrokes
   coming out of an event device into strings printed to stdout.
   This is a standalone utility.
   When you start `fbpad` it waits for chars from stdin. We get `fbpad`
   to listen to the keyboard by piping kbreader into it as so:
   `kbreader /dev/input/event3 | fbpad the_shell`.
    - `kbreader` is spiritually identical to the onscreen keyboard in
      a similar project `inkvt`, except our keyboard reader is decoupled
      from the rest of the software, our event device is not a touchscreen,
      and we use fbpad instead of a bespoke VT.
 - `efbpad.sh`: Script that does efbpad startup & shutdown.


# Fonts
`fbpad` will use fonts at `/mnt/onboard/fonts/tf/{regular,bold,italic}.tf`.
If `.efbpad_profile` sets the `FONT` env var then `/mnt/onboard/fonts/tf/${FONT}_{regular,bold,italic}.tf` will be copied to that location for use.

The included fonts were produced on the kobo as so, running from a folder containing DejaVu ttfs:
```
mkfn -h 44 -w 24 DejaVuSansMono.ttf:42 > /mnt/onboard/fonts/tf/large_regular.tf
mkfn -h 44 -w 24 DejaVuSansMono-Bold.ttf:42 > /mnt/onboard/fonts/tf/large_bold.tf
mkfn -h 44 -w 24 DejaVuSansMono-Oblique.ttf:42 > /mnt/onboard/fonts/tf/large_italic.tf
mkfn -h 36 -w 18 DejaVuSansMono.ttf:31 > /mnt/onboard/fonts/tf/small_regular.tf
mkfn -h 36 -w 18 DejaVuSansMono-Bold.ttf:31 > /mnt/onboard/fonts/tf/small_bold.tf
mkfn -h 36 -w 18 DejaVuSansMono-Oblique.ttf:31 > /mnt/onboard/fonts/tf/small_italic.tf
```
