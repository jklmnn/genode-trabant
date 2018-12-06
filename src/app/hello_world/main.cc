
#include <base/component.h>

struct Main
{
    Main(Genode::Env &)
    {
        Genode::log("HELLO WORLD!");
    }
};

void Component::construct(Genode::Env &env)
{
    static Main main(env);
}
