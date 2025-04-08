# efbpad

A bluetooth keyboard terminal for a Kobo Clara BW.
- [A video of it in action](https://youtube.com/shorts/0Jld5KgFcXU)
- A related repo, [kobo-emacs](https://github.com/enthdegree/kobo-emacs/)
- [TODO.md](TODO.md)

<p align="center">
  <img alt="Wide" src="./images/efbpad_1.jpeg" width="45%">
  <img alt="Detail" src="./images/efbpad_2.jpeg" width="45%">
</p>

## Install

Pre-built packages are available [here](https://mega.nz/folder/mU4kQa7L#9MGGHw2HltTiviuZUtqynw).

- On the Kobo, install [kfmon](https://github.com/NiLuJe/kfmon) and [nickelmenu](https://pgaskin.net/NickelMenu/) if you don't already have them.
- Put the .tgz package at `/mnt/onboard/.kobo/KoboRoot.tgz` and reboot. Alternatively, merge the contents of the package with the Kobo's `/mnt/onboard` (n.b. there are files starting with `.`). Either of these will create an efbpad entry in kfmon, nickelmenu and koreader's Tools menu.
  
## Usage

 - Before starting, pair your bluetooth keyboard to the Kobo through the Kobo UI.
 - While the keyboard is set to pair with the Kobo, run efbpad. Once the keyboard is found it will present the terminal.
 - efbpad shuts down when the keyboard disconnects, when the shell terminates, or when it doesn't find a keyboard within ~5 seconds of start.

### Controlling fbpad
Upstream `fbpad` reads some escaped control sequences `M-[...]`. 
For compatibility this project moves those controls to a fifo `/tmp/efbpad/fbpad_fifo`. 
In the fifo control sequences the escape char `^[` is omitted. 

`fbpad` looks for fonts and colors according to the config `/mnt/onboard/.adds/efbpad/fbpad_clrfile`.
To reload the config run `echo -n -e '\x05' > /tmp/efbpad/fbpad_fifo`.
As fallback it will use fonts `/mnt/onboard/fonts/tf/{regular,bold,italic}.tf`.

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
To uninstall delete all efbpad's files and directories:
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
Broadly, we string together 4 decoupled components. 
 - [`FBInk`](https://github.com/NiLuJe/FBInk): A library for eink screen drawing by NiLuJe.
 - [`fbpad`](https://github.com/aligrudi/fbpad): A framebuffer terminal emulator by aligrudi.
   We use a lightly patched fork of fbpad [here](https://github.com/enthdegree/fbpad). 
    - A similar project, [`fbpad-eink`](https://github.com/kisonecat/fbpad-eink), which
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
 - `efbpad.sh` (developed here): Startup & shutdown. It manages various things:
   - `source /mnt/onboard/.efbpad_profile` if it exists.
   - Bluetooth
   - Keyboard event device selection
   - fbpad fifo at `/tmp/efbpad/fbpad_fifo`
   - Logging at `/tmp/efbpad/efbpad.log`
