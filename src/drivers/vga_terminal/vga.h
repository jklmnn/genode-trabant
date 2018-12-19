
#ifndef _VGA_H_
#define _VGA_H_

#include <ada/exception.h>

enum {
    COLUMNS = 80,
    LINES = 1024
};

struct VGA {
    Genode::uint64_t tag;
    Genode::uint64_t screen;
    Genode::uint8_t blink;
    Genode::uint8_t background;
    Genode::uint8_t foreground;
    Genode::uint8_t reserved;
    Genode::uint32_t ascii_state;
    Genode::uint32_t offset;
    Genode::uint8_t buffer[LINES * COLUMNS];
};

extern "C" {

    VGA vga_new_screen(Genode::uint64_t const);
    void vga_putchar(VGA &, char const);
    void vga_up(VGA &);
    void vga_down(VGA &);
    void vga_reset(VGA &);

    Genode::uint64_t system__arith_64__add_with_ovflo_check(Genode::uint64_t x, Genode::uint64_t y)
    {
        Genode::uint64_t z = x + y;
        if (z < x || z < y)
            throw Ada::Exception::Overflow_Check();
        return z;
    }
}

#endif /* ifndef _VGA_H_ */
