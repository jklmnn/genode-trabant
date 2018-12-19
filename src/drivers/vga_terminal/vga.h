
#ifndef _VGA_H_
#define _VGA_H_

#include <ada/exception.h>

enum {
    COLUMNS = 80,
    LINES = 1024
};

class VGA;

extern "C" {

    void vga_initialize(VGA &, Genode::uint64_t const);
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

class VGA {
    private:
        Genode::uint64_t tag;
        Genode::uint64_t screen;
        Genode::uint8_t blink;
        Genode::uint8_t background;
        Genode::uint8_t foreground;
        Genode::uint8_t reserved;
        Genode::uint32_t ascii_state;
        Genode::uint32_t offset;
        Genode::uint16_t buffer[LINES * COLUMNS];

    public:
        VGA(void *scr) :
            tag(0),
            screen(0),
            blink(0),
            background(0),
            foreground(0),
            reserved(0),
            ascii_state(0),
            offset(0),
            buffer{}
        {
            vga_initialize(*this, reinterpret_cast<Genode::uint64_t const>(scr));
        }

        void putchar(char c)
        {
            vga_putchar(*this, c);
        }

        void up()
        {
            vga_up(*this);
        }

        void down()
        {
            vga_down(*this);
        }

        void reset()
        {
            vga_reset(*this);
        }
};

#endif /* ifndef _VGA_H_ */
