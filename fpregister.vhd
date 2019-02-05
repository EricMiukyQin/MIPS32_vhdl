library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity FP_registers is
port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (31 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;
     RD1      : out STD_LOGIC_VECTOR (31 downto 0);
     RD2      : out STD_LOGIC_VECTOR (31 downto 0);
     --Probe ports used for testing
     -- $f0 & $f1 & f2 & f3
     DEBUG_FP_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
);
end FP_registers;

architecture behave of FP_registers is
   type RegisterFile is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);  --32 registers
   signal rBytes:RegisterFile;
begin
   process(WR,WD,RegWrite,Clock)
      variable addr:integer;
      variable first:boolean := true; -- Used for initialization
   begin
      -- This part of the process initializes the memory and is only here for simulation purposes
      -- It does not correspond with actual hardware!
      if(first) then
         rBytes(0)    <= "11000000101101000000111111001011";  -- $f0 = 11000000101101000000111111001011
         rBytes(1)    <= "00111111100010010011000010011011";  -- $f1 = 00111111100010010011000010011011
         rBytes(2)    <= "00111111111100000001010100001111";  -- $f2 = 00111111111100000001010100001111
         rBytes(3)    <= "11111111111111111111111111111111";  -- $f3 = 11111111111111111111111111111111

         first := false; -- Don't initialize the next time this process runs
      end if;
      -- The 'proper' HDL starts here!
      if (Clock'event AND Clock='0' AND RegWrite='1') then
         if (to_integer(unsigned(WR))/=0) then
            rBytes(to_integer(unsigned(WR))) <= WD;
         end if;
      end if;
   end process;
   RD1 <= rBytes(to_integer(unsigned(RR1)));
   RD2 <= rBytes(to_integer(unsigned(RR2)));
   -- Conntect the signals that will be used for testing
   DEBUG_FP_REGS <= rBytes(0) & rBytes(1) & rBytes(2) & rBytes(3);      -- $f0 & $f1 & f2 & f3
end behave;