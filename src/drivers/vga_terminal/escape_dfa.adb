package body Escape_Dfa
with
SPARK_Mode
is

   ---------------
   -- Translate --
   ---------------

   function Translate (
                       Input : Integer;
                       State : Escape_Mode
                      ) return Escape_Mode
   is
      Target_State : Escape_Mode := Normal;
   begin
      pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");
      for S in Ascii_Dfa'Range loop
         if Ascii_Dfa (S).Current_State = State then
            if Ascii_Dfa (S).Input = Input then
               Target_State := Ascii_Dfa (S).Next_State;
            end if;
         end if;
      end loop;
      return Target_State;
   end Translate;

end Escape_Dfa;
