
# VGA LOG driver

The `vga_log_drv` component provides a LOG session and prints the output to a VGA console. This only works on seL4 and NOVA when booted via BIOS.
Since Genode 18.05 this requires the text console in GRUB to be enabled. For further information, see [genodelabs/genode#2880](https://github.com/genodelabs/genode/issues/2880).

Furthermore it can optionally use an Input session to enable scrolling with up to 1024 lines of backlog.
Scrolling keybindings:

 - UP: scroll 1 line up
 - DOWN: scroll 1 line down
 - PAGE UP: scroll 10 lines up
 - PAGE DOWN: scroll 10 lines down
 - ESC: reset scrolling to bottom

Example: [vgalog.run](https://github.com/jklmnn/genode-trabant/blob/master/run/vgalog.run)
