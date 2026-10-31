# Draft upstream issue (not posted)

**Lock with an external monitor that drops HPD in standby causes a black-screen
loop / "lockscreen crashed"**

Omarchy 4.0.6, Hyprland 0.56.2, aquamarine 0.15.1, amdgpu, MSI G271 on HDMI.

`plugins/lock/Service.qml` runs `omarchy-brightness-display off` five seconds
after locking, and that script does a global `dpms disable`. The monitor drops
its hotplug line when the signal stops; Hyprland logs
`drm: Connector HDMI-A-1 disconnected` then `connected`, rebuilds the lock
surfaces and the screen goes black and returns in a loop. Once, Hyprland
showed the crashed-lockscreen failsafe.

Proposed fix: have the `off` path blank only the internal panel with
`hl.dsp.dpms({ action = "disable", monitor = "<name>" })` and dim external
monitors over DDC/CI (brightness and contrast 0) instead of DPMS, restoring on
`on`. A working implementation is in `bin/omarchy-dpms-patch`.
