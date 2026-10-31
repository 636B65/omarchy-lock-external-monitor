# omarchy-lock-external-monitor

Fixes the black-screen / flicker loop (and Hyprland's "lockscreen crashed"
failsafe) when you lock an Omarchy laptop with an external monitor that drops
its hotplug line in standby (seen on an MSI G271 over HDMI, amdgpu).

## The problem

Five seconds after locking, Omarchy runs `omarchy-brightness-display off`,
which is a global `hyprctl dispatch dpms disable`. Some monitors treat the lost
signal as "unplugged": Hyprland logs `Connector HDMI-A-1 disconnected` /
`connected`, tears down and rebuilds the lock surfaces, and the screen flickers
black in a loop. Sometimes the lock client is lost and Hyprland shows its
crashed-lockscreen failsafe.

## What this does

Patches `/usr/share/omarchy/bin/omarchy-brightness-display`:

- `off`: DPMS-blanks only the built-in panel (`eDP-`, `LVDS-`, `DSI-`). External
  monitors keep their link and are set to brightness 0 and contrast 0 over
  DDC/CI (brightness 0 alone only dims; contrast 0 makes the picture black).
  The previous values are saved in `$XDG_RUNTIME_DIR/omarchy-lock-ddc/`.
- `on`: restores the saved brightness and contrast.

A pacman hook re-applies the patch after every upgrade of the `omarchy`
package. If the upstream script changed too much to patch, the hook prints
`omarchy-dpms-patch FAILED` and leaves the stock script alone.

## Install

Requires `ddcutil` and a monitor that supports DDC/CI.

```
./install.sh              # install / upgrade
./install.sh --uninstall  # restore the stock script, remove the hook
```

Why not a marketplace plugin? The blank step runs a system script from the lock
plugin, and plugins cannot replace either one, so a plugin would have to fork
the built-in lock screen. See [docs/upstream-issue.md](docs/upstream-issue.md)
for the proposed upstream fix.

## If the shell dies while locked

The external monitor stays dark until you restore it (adjust the bus and values
to your monitor; `ddcutil detect` lists buses):

```
ddcutil --bus 1 setvcp 12 70; ddcutil --bus 1 setvcp 10 100
```
