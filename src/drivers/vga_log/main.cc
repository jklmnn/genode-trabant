/*
 * \brief  VGA log driver that uses the framebuffer supplied by the core rom.
 * \author Johannes Kliemann
 * \date   2018-02-24
 */

#include <base/component.h>
#include <base/attached_rom_dataspace.h>
#include <dataspace/capability.h>
#include <os/static_root.h>
#include <log_session/log_session.h>
#include <base/attached_io_mem_dataspace.h>
#include <util/reconstructible.h>
#include <util/xml_node.h>
#include <util/string.h>
#include <input_session/connection.h>

#include <vga.h>

class Session_component : public Genode::Rpc_object<Genode::Log_session>
{
    private:

        Genode::Env &_env;

        struct Fb_desc
        {
            Genode::uint64_t addr;
            Genode::uint32_t width;
            Genode::uint32_t height;
            Genode::uint32_t pitch;
            Genode::uint32_t bpp;
        } _core_fb { };

        Genode::Constructible<Genode::Attached_io_mem_dataspace> _fb_mem;
        Genode::Constructible<Input::Connection> _input;
        Genode::Signal_handler<Session_component> _input_sigh;

        Genode::Constructible<VGA> _vga_screen;

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

    public:
        Session_component(Genode::Env &env, Genode::Xml_node pinfo) :
            _env(env),
            _fb_mem(),
            _input(),
            _input_sigh(env.ep(), *this, &Session_component::handle_key),
            _vga_screen()
        {
            unsigned fb_boot_type = 2;

            try {
                Genode::Xml_node fb = pinfo.sub_node("boot").sub_node("framebuffer");

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

            try{
                _input.construct(_env);
                _input->sigh(_input_sigh);
            }catch (Genode::Service_denied){
                Genode::warning("Failed to get Input session, no scrolling available.");
            }

        }

        Genode::size_t write(String const &str)
        {
            if (!(str.valid_string())){
                Genode::error("invalid string");
                return 0;
            }

            const char *c_str = str.string();
            const int len = Genode::strlen(c_str);

            for(int i = 0; i < len; i++){
                _vga_screen->putchar(c_str[i]);
            }

            return len;
        }
};

struct Main {

	Genode::Env &_env;

	Genode::Attached_rom_dataspace _pinfo {
		_env,
		"platform_info"
	};

	Session_component _log {
		_env,
		_pinfo.xml(),
	};

	Genode::Static_root<Genode::Log_session> _log_root {_env.ep().manage(_log)};

	Main(Genode::Env &env) : _env(env)
	{
		env.parent().announce(env.ep().manage(_log_root));
	}
};

void Component::construct(Genode::Env &env) {

	static Main inst(env);

}
