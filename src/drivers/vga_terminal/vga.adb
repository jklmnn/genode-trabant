pragma Ada_2012;

package body VGA
with
SPARK_Mode
is

   procedure Initialize (S : out VGA; A : System.Address)
   is
   begin
      if A = System.Null_Address then
         raise Program_Error;
      end if;
      S.Screen      := A;
      S.Cursor      := 0;
      S.Blink       := False;
      S.Background  := 0;
      S.Foreground  := 15;
      S.Ascii_State := Escape_Dfa.Normal;
      S.Offset      := Offset_Type'Last;
      S.Buffer      := (others => (others => (Blink => False,
                                              Background => 0,
                                              Foreground => 0,
                                              Char       => ' ')));
   end Initialize;


   procedure Putchar
     (S : in out VGA;
      C : Character)
   is
      VC : constant Symbol := (S.Blink, S.Background, S.Foreground, C);
   begin
      pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");
      if S.Cursor = 79 then
         Scroll (S);
      end if;

      S.Ascii_State := Escape_Dfa.Translate (Character'Pos (C), S.Ascii_State);

      case S.Ascii_State is
         when Escape_Dfa.Normal =>
            case Character'Pos (C) is
               when 10 =>
                  Scroll (S);
               when 32 .. 126 =>
                  S.Buffer (Buffer_Size - 1) (S.Cursor) := VC;
                  S.Cursor := S.Cursor + 1;
               when others =>
                  null;
            end case;
         when Escape_Dfa.Graphics_Mode_Text_Attributes_Off =>
            S.Blink := False;
            S.Foreground := 15;
            S.Background := 0;
         when Escape_Dfa.Graphics_Mode_Foreground_Colors_Black =>
            S.Foreground := 0;
         when Escape_Dfa.Graphics_Mode_Foreground_Colors_Red =>
            S.Foreground := 4;
         when Escape_Dfa.Graphics_Mode_Foreground_Colors_Green =>
            S.Foreground := 2;
         when Escape_Dfa.Graphics_Mode_Foreground_Colors_Yellow =>
            S.Foreground := 14;
         when Escape_Dfa.Graphics_Mode_Foreground_Colors_Blue =>
            S.Foreground := 1;
         when Escape_Dfa.Graphics_Mode_Foreground_Colors_Magenta =>
            S.Foreground := 5;
         when Escape_Dfa.Graphics_Mode_Foreground_Colors_Cyan =>
            S.Foreground := 3;
         when Escape_Dfa.Graphics_Mode_Foreground_Colors_White =>
            S.Foreground := 7;
         when others =>
            null;
      end case;
   end Putchar;

   procedure Scroll (S : in out VGA)
   is
      Empty : constant Symbol := (False, 0, 0, Character'Val (0));
   begin
      for I in 0 .. S.Buffer'Last - 1 loop
         S.Buffer (I) := S.Buffer (I + 1);
      end loop;
      S.Buffer (S.Buffer'Last) := (others => Empty);
      S.Cursor := 0;
      Window (S);
   end Scroll;

   procedure Window (S : VGA)
     with SPARK_Mode => Off
   is
      VGA_Screen : Screen
        with
          Address => S.Screen,
          Volatile,
          Effective_Writes,
          Async_Readers;
   begin
      VGA_Screen := S.Buffer (S.Buffer'First + Integer (S.Offset) ..
                                  S.Buffer'First + Integer (S.Offset) + VGA_Screen'Length - 1);
   end Window;

   procedure Up (S : in out VGA)
   is
   begin
      if S.Offset > 0 then
         S.Offset := S.Offset - 1;
      end if;
      Window (S);
   end Up;

   procedure Down (S : in out VGA)
   is
   begin
      if S.Offset < Offset_Type'Last then
         S.Offset := S.Offset + 1;
      end if;
      Window (S);
   end Down;

   procedure Reset (S : in out VGA)
   is
   begin
      S.Offset := Offset_Type'Last;
      Window (S);
   end Reset;

end VGA;
