with System;
with Escape_Dfa;
use all type System.Address;
use all type Escape_Dfa.Escape_Mode;

package VGA
with
SPARK_Mode
is

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
      Screen      : System.Address := System.Null_Address;
      Cursor      : Cursor_Location := 0;
      Blink       : Boolean := False;
      Background  : Background_Color := 0;
      Foreground  : Foreground_Color := 15;
      Ascii_State : Escape_Dfa.Escape_Mode := Escape_Dfa.Normal;
      Offset      : Offset_Type := Offset_Type'Last;
      Buffer      : Screen_Buffer := (others => (others => (Blink => False,
                                                            Background => 0,
                                                            Foreground => 0,
                                                            Char       => ' ')));
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

   function Create_Screen (Scr : System.Address) return VGA
     with
       Export,
       Convention => C,
       External_Name => "vga_new_screen",
       Pre => Scr /= System.Null_Address,
       Post => Create_Screen'Result.Screen /= System.Null_Address;

   pragma Warnings (Off, "involves a tagged type which does not correspond to any C type");

   procedure Putchar (S : in out VGA; C : Character)
     with
       Export,
       Convention => C,
       External_Name => "vga_putchar";

   procedure Up (S : in out VGA)
     with
     Export,
     Convention => C,
     External_Name => "vga_up";

   procedure Down (S : in out VGA)
     with
     Export,
     Convention => C,
     External_Name => "vga_down";

   procedure Reset (S : in out VGA)
     with
       Export,
       Convention => C,
       External_Name => "vga_reset";

private

   procedure Window (S : VGA);

   procedure Scroll (S : in out VGA)
     with
       Post => S.Cursor = 0;

end VGA;
