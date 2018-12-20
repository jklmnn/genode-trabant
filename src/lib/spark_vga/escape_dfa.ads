package Escape_Dfa
with
SPARK_Mode
is

   pragma Pure;

   type Escape_Mode is (
                        Normal,
                        Start_Escape,
                        Init_Escape,
                        Graphics_Mode,
                        Graphics_Mode_Text_Attributes,
                        Graphics_Mode_Text_Attributes_Off,
                        Graphics_Mode_Foreground_Colors,
                        Graphics_Mode_Foreground_Colors_Black,
                        Graphics_Mode_Foreground_Colors_Red,
                        Graphics_Mode_Foreground_Colors_Green,
                        Graphics_Mode_Foreground_Colors_Yellow,
                        Graphics_Mode_Foreground_Colors_Blue,
                        Graphics_Mode_Foreground_Colors_Magenta,
                        Graphics_Mode_Foreground_Colors_Cyan,
                        Graphics_Mode_Foreground_Colors_White,
                        Graphics_Mode_Background_Colors
                       );

   function Translate (
                       Input : Integer;
                       State : Escape_Mode
                      ) return Escape_Mode;

private

   type Transition is
      record
         Current_State : Escape_Mode;
         Input         : Integer;
         Next_State    : Escape_Mode;
      end record;

   type Automata is array (Integer range <>) of Transition;

   Ascii_Dfa : constant Automata := (
                                     (Normal, 27, Start_Escape),
                                     (Start_Escape, 91, Init_Escape),
                                     (Init_Escape, 48, Graphics_Mode_Text_Attributes_Off),
                                     (Init_Escape, 51, Graphics_Mode_Foreground_Colors),
                                     (Graphics_Mode_Foreground_Colors, 48, Graphics_Mode_Foreground_Colors_Black),
                                     (Graphics_Mode_Foreground_Colors, 49, Graphics_Mode_Foreground_Colors_Red),
                                     (Graphics_Mode_Foreground_Colors, 50, Graphics_Mode_Foreground_Colors_Green),
                                     (Graphics_Mode_Foreground_Colors, 51, Graphics_Mode_Foreground_Colors_Yellow),
                                     (Graphics_Mode_Foreground_Colors, 52, Graphics_Mode_Foreground_Colors_Blue),
                                     (Graphics_Mode_Foreground_Colors, 53, Graphics_Mode_Foreground_Colors_Magenta),
                                     (Graphics_Mode_Foreground_Colors, 54, Graphics_Mode_Foreground_Colors_Cyan),
                                     (Graphics_Mode_Foreground_Colors, 55, Graphics_Mode_Foreground_Colors_White),
                                     (Graphics_Mode_Foreground_Colors_Black, 109, Graphics_Mode),
                                     (Graphics_Mode_Foreground_Colors_Red, 109, Graphics_Mode),
                                     (Graphics_Mode_Foreground_Colors_Green, 109, Graphics_Mode),
                                     (Graphics_Mode_Foreground_Colors_Yellow, 109, Graphics_Mode),
                                     (Graphics_Mode_Foreground_Colors_Blue, 109, Graphics_Mode),
                                     (Graphics_Mode_Foreground_Colors_Magenta, 109, Graphics_Mode),
                                     (Graphics_Mode_Foreground_Colors_Cyan, 109, Graphics_Mode),
                                     (Graphics_Mode_Foreground_Colors_White, 109, Graphics_Mode),
                                     (Graphics_Mode_Text_Attributes_Off, 109, Graphics_Mode)
                                    );

end Escape_Dfa;
