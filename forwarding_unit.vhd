LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity ForwardingUnit is
port(
     ID_EX_RegisterRs   : in  STD_LOGIC_VECTOR(4 downto 0);
     ID_EX_RegisterRt   : in  STD_LOGIC_VECTOR(4 downto 0);
     EX_MEM_RegisterRd  : in  STD_LOGIC_VECTOR(4 downto 0);
     MEM_WB_RegisterRd  : in  STD_LOGIC_VECTOR(4 downto 0);
     EX_MEM_RegWrite    : in  STD_LOGIC;
     MEM_WB_RegWrite    : in  STD_LOGIC;
     ForwardA           : out STD_LOGIC_VECTOR(1 downto 0);
     ForwardB           : out STD_LOGIC_VECTOR(1 downto 0)
);
end ForwardingUnit;

architecture behave of ForwardingUnit is
begin
   process(ID_EX_RegisterRs,ID_EX_RegisterRt,EX_MEM_RegisterRd,MEM_WB_RegisterRd,EX_MEM_RegWrite,MEM_WB_RegWrite)
   begin
   -- EX hazard
      if((EX_MEM_RegWrite='1')
          and (to_integer(unsigned(EX_MEM_RegisterRd))/=0)
          and (unsigned(EX_MEM_RegisterRd)=unsigned(ID_EX_RegisterRs))) then
            ForwardA <= "10";
   -- MEM hazard
      elsif((MEM_WB_Regwrite='1')
              and (to_integer(unsigned(MEM_WB_RegisterRd))/=0)
              and not((EX_MEM_RegWrite='1') and (to_integer(unsigned(EX_MEM_RegisterRd))/=0) and (unsigned(EX_MEM_RegisterRd)=unsigned(ID_EX_RegisterRs)))
              and (unsigned(MEM_WB_RegisterRd)=unsigned(ID_EX_RegisterRs))) then
                 ForwardA <= "01";
   -- No hazard
      else
         ForwardA <= "00";
      end if;

   -- EX hazard
      if((EX_MEM_RegWrite='1')
         and (to_integer(unsigned(EX_MEM_RegisterRd))/=0)
         and (unsigned(EX_MEM_RegisterRd)=unsigned(ID_EX_RegisterRt))) then
            ForwardB <= "10";
   -- MEM hazard
      elsif((MEM_WB_Regwrite='1')
              and (to_integer(unsigned(MEM_WB_RegisterRd))/=0)
              and not(EX_MEM_RegWrite='1' and (to_integer(unsigned(EX_MEM_RegisterRd))/=0) and (unsigned(EX_MEM_RegisterRd)=unsigned(ID_EX_RegisterRt)))
              and (unsigned(MEM_WB_RegisterRd)=unsigned(ID_EX_RegisterRt))) then
                  ForwardB <= "01";
   -- No hazard
      else
         ForwardB <= "00";
      end if;
   end process;
end behave;