library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity IMEM is
-- The instruction memory is a byte addressable, big-endian, read-only memory
-- Reads occur continuously
-- HINT: Use the provided dmem.vhd as a starting point
generic(NUM_BYTES : integer := 128);
-- NUM_BYTES is the number of bytes in the memory (small to save computation resources)
port(
     Address  : in  STD_LOGIC_VECTOR(31 downto 0); -- Address to read from
     ReadData : out STD_LOGIC_VECTOR(31 downto 0)
);
end IMEM;

architecture behave of IMEM is
   type ByteArray is array (0 to NUM_BYTES) of STD_LOGIC_VECTOR(7 downto 0); 
   signal imemBytes:ByteArray;
begin
   process(Address)
   variable addr:integer;
   variable first:boolean := true; -- Used for initialization
   begin
      -- This part of the process initializes the memory and is only here for simulation purposes
      -- It does not correspond with actual hardware!
      if(first) then
         -- IEM(0x0)  = 0b 0100 0110 0000 0010 0000 1000 1100 0000
         -- IEM(0x4)  = 0b 0000 0000 0000 0000 0000 0000 0000 0000
         -- IEM(0x8)  = 0b 0000 0000 0000 0000 0000 0000 0000 0000
         -- IEM(0xB)  = 0b 0000 0000 0000 0000 0000 0000 0000 0000
         -- IEM(0x10) = 0b 0000 0000 0000 0000 0000 0000 0000 0000
         -- IEM(0x14) = 0b 0100 0110 0000 0011 0000 0000 1000 0000
         -- IEM(0x18) = 0b 0000 0000 0000 0000 0000 0000 0000 0000
         -- IEM(0x1B) = 0b 0000 0000 0000 0000 0000 0000 0000 0000
         -- IEM(0x20) = 0b 0000 0000 0000 0000 0000 0000 0000 0000
         -- IEM(0x24) = 0b 0000 0000 0000 0000 0000 0000 0000 0000
         --       add.s $f3 $f1 $f2
         --       nop // add.s -> ID
         --       nop // add.s -> EX
         --       nop // add.s -> MEM
         --       nop // add.s -> WB
         --       add.s $f2 $f0 $f3
         --       nop // add.s -> ID
         --       nop // add.s -> EX
         --       nop // add.s -> MEM
         --       nop // add.s -> WB
         imemBytes(0)    <= "01000110"; imemBytes(1)    <= "00000010"; imemBytes(2)   <= "00001000"; imemBytes(3)   <= "11000000";
         imemBytes(4)    <= "00000000"; imemBytes(5)    <= "00000000"; imemBytes(6)   <= "00000000"; imemBytes(7)   <= "00000000";
         imemBytes(8)    <= "00000000"; imemBytes(9)    <= "00000000"; imemBytes(10)  <= "00000000"; imemBytes(11)  <= "00000000";
         imemBytes(12)   <= "00000000"; imemBytes(13)   <= "00000000"; imemBytes(14)  <= "00000000"; imemBytes(15)  <= "00000000";
         imemBytes(16)   <= "00000000"; imemBytes(17)   <= "00000000"; imemBytes(18)  <= "00000000"; imemBytes(19)  <= "00000000";
         imemBytes(20)   <= "01000110"; imemBytes(21)   <= "00000011"; imemBytes(22)  <= "00000000"; imemBytes(23)  <= "10000000";
         imemBytes(24)   <= "00000000"; imemBytes(25)   <= "00000000"; imemBytes(26)  <= "00000000"; imemBytes(27)  <= "00000000";
         imemBytes(28)   <= "00000000"; imemBytes(29)   <= "00000000"; imemBytes(30)  <= "00000000"; imemBytes(31)  <= "00000000";
         imemBytes(32)   <= "00000000"; imemBytes(33)   <= "00000000"; imemBytes(34)  <= "00000000"; imemBytes(35)  <= "00000000";
         imemBytes(36)   <= "00000000"; imemBytes(37)   <= "00000000"; imemBytes(38)  <= "00000000"; imemBytes(39)  <= "00000000";

         first := false; -- Don't initialize the next time this process runs
      end if;
      -- The 'proper' HDL starts here!
      addr:=to_integer(unsigned(Address)); -- Convert the address to an integer
      if (addr+3 < NUM_BYTES) then -- Check that the address is within the bounds of the memory
        ReadData <= imemBytes(addr) & imemBytes(addr+1) & imemBytes(addr+2) & imemBytes(addr+3);
      else report "Invalid DMEM addr. Attempted to read 4-bytes starting at address " &
         integer'image(addr) & " but only " & integer'image(NUM_BYTES) & " bytes are available"
         severity error;
      end if;
   end process;
end behave;