library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity DMEM is
-- The data memory is a byte addressble, big-endian, read/write memory with a single address port
-- It may not read and write at the same time
generic(NUM_BYTES : integer := 32);
-- NUM_BYTES is the number of bytes in the memory (small to save computation resources)
port(
     WriteData          : in  STD_LOGIC_VECTOR(31 downto 0); -- Input data
     Address            : in  STD_LOGIC_VECTOR(31 downto 0); -- Read/Write address
     MemRead            : in  STD_LOGIC; -- Indicates a read operation
     MemWrite           : in  STD_LOGIC; -- Indicates a write operation
     Clock              : in  STD_LOGIC; -- Writes are triggered by a rising edge
     ReadData           : out STD_LOGIC_VECTOR(31 downto 0); -- Output data
     --Probe ports used for testing
     -- Four 32-bit words: DMEM(0) & DMEM(4) & DMEM(8) & DMEM(12)
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
);
end DMEM;

architecture behavioral of DMEM is
   type ByteArray is array (0 to NUM_BYTES) of STD_LOGIC_VECTOR(7 downto 0); 
   signal dmemBytes:ByteArray;
begin
   process(Clock,MemRead,MemWrite,WriteData,Address) -- Run when any of these inputs change
   variable addr:integer;
   variable first:boolean := true; -- Used for initialization
   begin
      -- This part of the process initializes the memory and is only here for simulation purposes
      -- It does not correspond with actual hardware!
      if(first) then
         -- MEM(0x0) = 0x00000009 = 0b 0000 0000 0000 0000 0000 0000 0000 1001
         -- MEM(0x4) = 0x00000008 = 0b 0000 0000 0000 0000 0000 0000 0000 1000
         -- MEM(0x8) = 0x00000007 = 0b 0000 0000 0000 0000 0000 0000 0000 0111
         -- MEM(0xC) = 0x00000006 = 0b 0000 0000 0000 0000 0000 0000 0000 0110
         dmemBytes(0)   <= "00000000"; dmemBytes(1)   <= "00000000"; dmemBytes(2)   <= "00000000"; dmemBytes(3)   <= "00001001";
         dmemBytes(4)   <= "00000000"; dmemBytes(5)   <= "00000000"; dmemBytes(6)   <= "00000000"; dmemBytes(7)   <= "00001000";
         dmemBytes(8)   <= "00000000"; dmemBytes(9)   <= "00000000"; dmemBytes(10)  <= "00000000"; dmemBytes(11)  <= "00000111";
         dmemBytes(12)  <= "00000000"; dmemBytes(13)  <= "00000000"; dmemBytes(14)  <= "00000000"; dmemBytes(15)  <= "00000110";
         first := false; -- Don't initialize the next time this process runs
      end if;
      -- The 'proper' HDL starts here!
      if Clock = '1' and Clock'event and MemWrite='1' and MemRead='0' then 
         -- Write on the rising edge of the clock
         addr:=to_integer(unsigned(Address)); -- Convert the address to an integer
         -- Splice the input data into bytes and assign to the byte array
         dmemBytes(addr)   <= WriteData(31 downto 24);
         dmemBytes(addr+1) <= WriteData(23 downto 16);
         dmemBytes(addr+2) <= WriteData(15 downto 8);
         dmemBytes(addr+3) <= WriteData(7 downto 0);
      elsif MemRead='1' and MemWrite='0' then -- Reads don't need to be edge triggered
         addr:=to_integer(unsigned(Address)); -- Convert the address
         if (addr+3 < NUM_BYTES) then -- Check that the address is within the bounds of the memory
           ReadData <= dmemBytes(addr) & dmemBytes(addr+1) &
               dmemBytes(addr+2) & dmemBytes(addr+3);
         else report "Invalid DMEM addr. Attempted to read 4-bytes starting at address " &
            integer'image(addr) & " but only " & integer'image(NUM_BYTES) & " bytes are available"
            severity error;
         end if;
      end if;
   end process;
   -- Conntect the signals that will be used for testing
   DEBUG_MEM_CONTENTS <= 
      dmemBytes( 0) & dmemBytes( 1) & dmemBytes( 2) & dmemBytes( 3) & --DMEM(0)
      dmemBytes( 4) & dmemBytes( 5) & dmemBytes( 6) & dmemBytes( 7) & --DMEM(4)
      dmemBytes( 8) & dmemBytes( 9) & dmemBytes(10) & dmemBytes(11) & --DMEM(8)
      dmemBytes(12) & dmemBytes(13) & dmemBytes(14) & dmemBytes(15);  --DMEM(12)
end behavioral;
