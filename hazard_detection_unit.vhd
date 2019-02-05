LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity HazardDetectionUnit is
port(
     IF_ID_RegisterRs   : in  STD_LOGIC_VECTOR(4 downto 0);
     IF_ID_RegisterRt   : in  STD_LOGIC_VECTOR(4 downto 0);
     ID_EX_RegisterRt   : in  STD_LOGIC_VECTOR(4 downto 0);
     ID_EX_MemRead      : in  STD_LOGIC;
     PCWrite            : out STD_LOGIC;
     IF_DWrite          : out STD_LOGIC;
     MuxControl         : out STD_LOGIC
);
end HazardDetectionUnit;

architecture behave of HazardDetectionUnit is
begin
  -- notice MuxControl
   process(IF_ID_RegisterRs,IF_ID_RegisterRt,ID_EX_RegisterRt,ID_EX_MemRead)
   begin
      if((ID_EX_MemRead='1')
         and ((unsigned(ID_EX_RegisterRt)=unsigned(IF_ID_RegisterRs)) or  (unsigned(ID_EX_RegisterRt)=unsigned(IF_ID_RegisterRt)))) then
            PCWrite    <= '0';
            IF_DWrite  <= '0';
            MuxControl <= '1'; -- stall
      else
            PCWrite    <= '1';
            IF_DWrite  <= '1';
            MuxControl <= '0';
      end if;
   end process;
end behave;