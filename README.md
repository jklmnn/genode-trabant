# genode-trabant
[Genode](https://github.com/genodelabs/genode) Trabant repository that provides a random collection of components and libraries.

## Components
 - [`vga_log_drv`](https://github.com/jklmnn/genode-trabant/tree/master/src/drivers/vga_log) Driver that provides a LOG session and uses the VGA framebuffer console
 - [`clock`](https://github.com/jklmnn/genode-trabant/tree/master/src/server/clock) RTC session proxy that keeps state to reduce accesses to the underlying RTC session

## Libraries
 - `telebot` Genode port of the [telebot](https://github.com/smartnode/telebot) Telegram bot API
