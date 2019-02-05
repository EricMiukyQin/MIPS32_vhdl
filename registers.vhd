library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity registers is
-- This component is described in the textbook, starting on page 2.52
-- The indices of each of the registers can be found on the MIPS reference page at the front of the
--    textbook
-- Keep in mind that register 0(zero) has a constant value of 0 and cannot be overwritten

-- This should only write on the negative edge of Clock when RegWrite is asserted.
-- Reads should be purely combinatorial, i.e. they don't depend on Clock
-- HINT: Use the provided dmem.vhd as a starting point
port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (31 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;
     RD1      : out STD_LOGIC_VECTOR (31 downto 0);
     RD2      : out STD_LOGIC_VECTOR (31 downto 0);
     --Probe ports used for testing
     -- $t0 & $t1 & t2 & t3
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0);
     -- $s0 & $s1 & s2 & s3
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
);
end registers;

architecture behave of registers is
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
         rBytes(0)    <= "00000000000000000000000000000000";  -- $zero: RIGISTERS(0x0)  = 0
         rBytes(8)    <= "00000000000000000000000000000001";  -- $t0: RIGISTERS(0x8)    = 1
         rBytes(9)    <= "00000000000000000000000000000010";  -- $t1: RIGISTERS(0x9)    = 2
         rBytes(10)   <= "00000000000000000000000000000100";  -- $t2: RIGISTERS(0xa)    = 4
         rBytes(11)   <= "00000000000000000000000000001000";  -- $t3: RIGISTERS(0xb)    = 8
         rBytes(16)   <= "00000000000000000000000000000001";  -- $s0: RIGISTERS(0x10)   = 1
         rBytes(17)   <= "00000000000000000000000000000010";  -- $s1: RIGISTERS(0x11)   = 2
         rBytes(18)   <= "10001011101011011111000000001101";  -- $s2: RIGISTERS(0x12)   = 2343432205
         rBytes(19)   <= "10001011101011011111000000001101";  -- $s3: RIGISTERS(0x13)   = 2343432205

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
   DEBUG_TMP_REGS <= rBytes(8) & rBytes(9) & rBytes(10) & rBytes(11);      -- $t0 & $t1 & t2 & t3
   DEBUG_SAVED_REGS <= rBytes(16) & rBytes(17) & rBytes(18) & rBytes(19);  -- $s0 & $s1 & s2 & s3
end behave;