with System;
with Escape_Dfa;
use all type System.Address;
use all type Escape_Dfa.Escape_Mode;

package VGA
with
SPARK_Mode
is

   pragma Pure;

   type Background_Color is new Integer range 0 .. 7
     with Size => 3;
   type Foreground_Color is new Integer range 0 .. 15
     with Size => 4;

   Buffer_Size : constant Integer := 1024;
   Screen_Size : constant Integer := 25;

   type Offset_Type is new Integer range 0 .. Buffer_Size - Screen_Size;

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

   type VGA is record
      Screen      : System.Address;
      Cursor      : Cursor_Location;
      Blink       : Boolean;
      Background  : Background_Color;
      Foreground  : Foreground_Color;
      Ascii_State : Escape_Dfa.Escape_Mode;
      Offset      : Offset_Type;
      Buffer      : Screen_Buffer;
   end record;

   for VGA use
      record
         Screen at 8 range 0 .. 63;
         Cursor at 16 range 0 .. 31;
         Blink at 20 range 0 .. 7;
         Background at 21 range 0 .. 7;
         Foreground at 22 range 0 .. 7;
         Ascii_State at 24 range 0 .. 31;
         Offset at 28 range 0 .. 31;
         Buffer at 32 range 0 .. 1310719;
      end record;

   function Initialized (S : VGA) return Boolean is
     (S.Screen /= System.Null_Address)
     with
       Ghost;

   procedure Initialize (S : out VGA; A : System.Address)
     with
       Export,
       Convention => C,
       External_Name => "vga_initialize",
       Pre => A /= System.Null_Address,
       Post => Initialized (S);

   pragma Warnings (Off, "involves a tagged type which does not correspond to any C type");

   procedure Putchar (S : in out VGA; C : Character)
     with
       Export,
       Convention => C,
       External_Name => "vga_putchar",
       Pre => Initialized (S),
     Post => Initialized (S);

   procedure Up (S : in out VGA)
     with
       Export,
       Convention => C,
       External_Name => "vga_up",
       Pre => Initialized (S),
     Post => Initialized (S);

   procedure Down (S : in out VGA)
     with
       Export,
       Convention => C,
       External_Name => "vga_down",
       Pre => Initialized (S),
     Post => Initialized (S);

   procedure Reset (S : in out VGA)
     with
       Export,
       Convention => C,
       External_Name => "vga_reset",
       Pre => Initialized (S),
     Post => Initialized (S);

private

   procedure Window (S : VGA)
     with
       Pre => Initialized (S);

   procedure Scroll (S : in out VGA)
     with
       Pre => Initialized (S),
     Post => S.Cursor = 0 and Initialized (S);

end VGA;
