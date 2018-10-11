with System;
use all type System.Address;

package VGA
with
SPARK_Mode,
  Abstract_State => (Char_State,
                     (Screen_State with External => (Effective_Writes,
                                                     Async_Readers)),
                     Buffer_State,
                     Offset_State,
                     Cursor_State)
is

   procedure Putchar (C : Character)
     with
       Global => (In_Out => (Cursor_State,
                             Char_State,
                             Screen_State,
                             Buffer_State),
                  Input  => (Offset_State)),
       Export,
       Convention => C,
       External_Name => "vga_putchar";

   procedure Up
     with
       Global => (In_Out => Offset_State,
                  Input  => Buffer_State,
                  Output => Screen_State),
     Depends => (Offset_State => Offset_State,
                 Screen_State => (Buffer_State, Offset_State)),
     Export,
     Convention => C,
     External_Name => "vga_up";

   procedure Down
     with
       Global => (In_Out => Offset_State,
                  Input  => Buffer_State,
                  Output => Screen_State),
     Depends => (Offset_State => Offset_State,
                 Screen_State => (Buffer_State, Offset_State)),
     Export,
     Convention => C,
     External_Name => "vga_down";

   procedure Reset
     with
       Global => (Input  => (Buffer_State),
                  Output => (Screen_State),
                  In_Out => (Offset_State)),
       Depends => (Offset_State => null,
                   Screen_State => Buffer_State,
                   null         => (Offset_State)),
       Export,
       Convention => C,
       External_Name => "vga_reset";

private

   type Background_Color is new Integer range 0 .. 7
     with Size => 3;
   type Foreground_Color is new Integer range 0 .. 15
     with Size => 4;

   Buffer_Size : constant Integer := 1024;
   Screen_Size : constant Integer := 25;
   type Offset is new Integer range 0 .. Buffer_Size - Screen_Size;

   type Symbol is
      record
         Blink      : Boolean;
         Background : Background_Color;
         Foreground : Foreground_Color;
         Char       : Character;
      end record with
     Size => 16;

   for Symbol use
      record
         Blink      at 1 range 7 .. 7;
         Background at 1 range 4 .. 6;
         Foreground at 1 range 0 .. 3;
         Char       at 0 range 0 .. 7;
      end record;

   type Cursor_Location is new Integer range 0 .. 79;

   type Line is array (Cursor_Location range 0 .. 79) of Symbol;
   type Buffer is array (Natural range <>) of Line;
   subtype Screen is Buffer (0 .. Screen_Size - 1);
   subtype Screen_Buffer is Buffer (0 .. Buffer_Size - 1);

   function Get_Buffer return System.Address
     with
       Import,
       Convention => C,
       External_Name => "get_buffer",
       Global => null;

   procedure Window
     with
       Global => (Input  => (Buffer_State, Offset_State),
                  Output => Screen_State),
     Depends => (Screen_State => (Buffer_State, Offset_State));

   procedure Scroll (C : out Cursor_Location)
     with Global => (Input  => (Offset_State),
                     In_Out => (Buffer_State),
                     Output => (Screen_State)),
     Depends => (C => null,
                 Buffer_State => Buffer_State,
                 Screen_State => (Buffer_State, Offset_State)),
     Post => C = 0;

end VGA;
