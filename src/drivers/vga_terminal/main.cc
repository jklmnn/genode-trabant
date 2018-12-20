/*
 * \brief  VGA log driver that uses the framebuffer supplied by the core rom.
 * \author Johannes Kliemann
 * \date   2018-02-24
 */

#include <base/component.h>
#include <base/attached_rom_dataspace.h>
#include <base/attached_io_mem_dataspace.h>
#include <util/reconstructible.h>
#include <util/xml_node.h>
#include <util/string.h>
#include <input_session/connection.h>
#include <terminal_session/connection.h>

#include <vga.h>

struct Main {

	Genode::Env &_env;

        struct Fb_desc
        {
            Genode::uint64_t addr;
            Genode::uint32_t width;
            Genode::uint32_t height;
            Genode::uint32_t pitch;
            Genode::uint32_t bpp;
        } _core_fb { };

        Terminal::Connection _terminal;

        Genode::Signal_handler<Main> _term_sigh;
        Genode::Constructible<Genode::Attached_io_mem_dataspace> _fb_mem;
        Genode::Constructible<VGA> _vga_screen;
        Genode::Attached_rom_dataspace _platform_info;
        Genode::Constructible<Input::Connection> _input;
        Genode::Signal_handler<Main> _input_sigh;

        void term_read()
        {
            char read_buffer[200];
            unsigned num_bytes = 1;
            while(num_bytes > 0){
                num_bytes = _terminal.read(read_buffer, sizeof(read_buffer));
                for(unsigned i = 0; i < num_bytes; i++){
                    _vga_screen->putchar(read_buffer[i]);
                }
            }
        }

        void handle_key()
        {
            if(_input.constructed()){
                _input->for_each_event([&] (Input::Event const &ev) {
                        ev.handle_press([&] (Input::Keycode key, Genode::Codepoint) {
                                    switch(key){
                                        case Input::KEY_ESC:    _vga_screen->reset();   break;
                                        case Input::KEY_UP:     _vga_screen->up();      break;
                                        case Input::KEY_DOWN:   _vga_screen->down();    break;
                                        case Input::KEY_PAGEUP:
                                            for(int i = 0; i < 10; i++) _vga_screen->up();
                                            break;
                                        case Input::KEY_PAGEDOWN:
                                            for(int i = 0; i < 10; i++) _vga_screen->down();
                                            break;
                                        default: break;
                                    }
                                });
                    });
            }
        }

        void initialize_vga()
        {
            unsigned fb_boot_type = 2;

            try {
                Genode::Xml_node fb = _platform_info.xml().sub_node("boot").sub_node("framebuffer");

                fb.attribute("phys").value(&_core_fb.addr);
                fb.attribute("width").value(&_core_fb.width);
                fb.attribute("height").value(&_core_fb.height);
                fb.attribute("bpp").value(&_core_fb.bpp);
                fb.attribute("pitch").value(&_core_fb.pitch);
                fb_boot_type = fb.attribute_value("type", 0U);
            } catch (...) {
                Genode::error("No boot framebuffer information available.");
                throw Genode::Service_denied();
            }

            Genode::log("VGA console with ", _core_fb.width, "x", _core_fb.height,
                    "x", _core_fb.bpp, " @ ", (void*)_core_fb.addr,
                    " type=", fb_boot_type, " pitch=", _core_fb.pitch);

            if (_core_fb.bpp != 16 || fb_boot_type != 2 ) {
                Genode::error("unsupported resolution (bpp or/and type)");
                throw Genode::Service_denied();
            }

            _fb_mem.construct(_env, _core_fb.addr, _core_fb.pitch * _core_fb.height,
                    true);

            _vga_screen.construct(_fb_mem->local_addr<void>());
            _terminal.read_avail_sigh(_term_sigh);

            try{
                _input.construct(_env);
                _input->sigh(_input_sigh);
            }catch (Genode::Service_denied){
                Genode::warning("Failed to get Input session, no scrolling available.");
            }
        }

	Main(Genode::Env &env) :
            _env(env),
            _terminal(env, "VGA"),
            _term_sigh(env.ep(), *this, &Main::term_read),
            _fb_mem(),
            _vga_screen(),
            _platform_info(env, "platform_info"),
            _input(),
            _input_sigh(env.ep(), *this, &Main::handle_key)
	{
            Genode::log("VGA terminal");
            initialize_vga();
            term_read();
	}
};

void Component::construct(Genode::Env &env) {

	static Main inst(env);

}
