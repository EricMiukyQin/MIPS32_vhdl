LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity IF_ID_Reg is
-- IF_ID_Reg - IF stage to ID stage
port(
     rst              : in std_logic;
     clk              : in std_logic;
     IF_DWrite        : in std_logic;
     IF_Flush         : in std_logic;
     instruction_in   : in std_logic_vector(31 downto 0);
     PC_plus4_in      : in std_logic_vector(31 downto 0);
     instruction_out  : out std_logic_vector(31 downto 0);
     PC_plus4_out     : out std_logic_vector(31 downto 0)
);
end;

architecture behave of IF_ID_Reg is
begin
   process(clk,IF_DWrite,IF_Flush,rst)
   begin
      if rst='1' then
         instruction_out <= "00000000000000000000000000000000";
         PC_plus4_out    <= "00000000000000000000000000000000";
      elsif rst='0' then
         if(IF_Flush='1' and clk'event and clk = '1') then
            instruction_out <= "00000000000000000000000000000000";
            PC_plus4_out    <= PC_plus4_in;
         elsif(IF_Flush='0' and IF_DWrite='1' and clk'event and clk = '1') then
            instruction_out <= instruction_in;
            PC_plus4_out    <= PC_plus4_in;
         end if;
      end if;
   end process;
end behave;