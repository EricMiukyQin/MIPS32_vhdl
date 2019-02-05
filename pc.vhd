LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity PC is -- 32-bit rising-edge triggered register with write-enable and asynchronous reset
-- For more information on what the PC does, see page 251 in the textbook
port(
     clk          : in  STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
     write_enable : in  STD_LOGIC; -- Only write if '1'
     rst          : in  STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
     AddressIn    : in  STD_LOGIC_VECTOR(31 downto 0); -- Next PC address
     AddressOut   : out STD_LOGIC_VECTOR(31 downto 0) -- Current PC address
);
end PC;

ARCHITECTURE behave OF PC IS
begin
   process(clk,write_enable,rst)
   begin
      if rst='1' then
         AddressOut(31 downto 0) <= (others => '0');
      elsif rst='0' then
         if clk'event AND clk = '1' AND write_enable='1' then
            AddressOut <= AddressIn;
         end if;
      end if;
   end process;
end behave;
