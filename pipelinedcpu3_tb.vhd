LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity pipelinedcpu3_tb is
end pipelinedcpu3_tb;

architecture tb of pipelinedcpu3_tb is
   signal Clock                 : STD_LOGIC:='1';
   signal rst                   : STD_LOGIC:='1';
   signal DEBUG_IF_FLUSH        : std_logic;
   signal DEBUG_REG_EQUAL       : std_logic;
   signal DEBUG_FORWARDA        : STD_LOGIC_VECTOR(1 downto 0);         -- Forwarding control signals
   signal DEBUG_FORWARDB        : STD_LOGIC_VECTOR(1 downto 0);
   signal DEBUG_PC              : STD_LOGIC_VECTOR(31 downto 0);        -- The current address (AddressOut from the PC)
   signal DEBUG_PC_WRITE_ENABLE : STD_LOGIC;                            -- Value of PC.write_enable
   signal DEBUG_INSTRUCTION     : STD_LOGIC_VECTOR(31 downto 0);        -- The current instruction (Instruction output of IMEM)
   signal DEBUG_TMP_REGS        : STD_LOGIC_VECTOR(32*4 - 1 downto 0);  -- DEBUG ports from other components
   signal DEBUG_SAVED_REGS      : STD_LOGIC_VECTOR(32*4 - 1 downto 0);
   signal DEBUG_FP_REGS      : STD_LOGIC_VECTOR(32*4 - 1 downto 0);
   signal DEBUG_MEM_CONTENTS    : STD_LOGIC_VECTOR(32*4 - 1 downto 0);
begin
   U0 : entity work.pipelinedcpu3 port map (Clock, rst, DEBUG_IF_FLUSH, DEBUG_REG_EQUAL, DEBUG_FORWARDA, DEBUG_FORWARDB, DEBUG_PC, DEBUG_PC_WRITE_ENABLE, DEBUG_INSTRUCTION, DEBUG_TMP_REGS, DEBUG_SAVED_REGS, DEBUG_FP_REGS, DEBUG_MEM_CONTENTS);  
   process
   begin
                                wait for 50 ns;  --0-50 ns
      rst   <= '0';             wait for 20 ns;  --50-70 ns
      Clock <= '0';             wait for 30 ns;  --70-100 ns
      Clock <= '1';             wait for 50 ns;  --100-150 ns
      Clock <= '0';             wait for 50 ns;  --150-200 ns
      Clock <= '1';             wait for 50 ns;  --200-250 ns
      Clock <= '0';             wait for 50 ns;  --250-300 ns
      Clock <= '1';             wait for 50 ns;  --300-350 ns
      Clock <= '0';             wait for 50 ns;  --350-400 ns
      Clock <= '1';             wait for 50 ns;  --400-450 ns
      Clock <= '0';             wait for 50 ns;  --450-500 ns
      Clock <= '1';             wait for 50 ns;  --500-550 ns
      Clock <= '0';             wait for 50 ns;  --550-600 ns
      Clock <= '1';             wait for 50 ns;  --600-650 ns
      Clock <= '0';             wait for 50 ns;  --650-700 ns
      Clock <= '1';             wait for 50 ns;  --700-750 ns
      Clock <= '0';             wait for 50 ns;  --750-800 ns
      Clock <= '1';             wait for 50 ns;  --800-850 ns
      Clock <= '0';             wait for 50 ns;  --850-900 ns
      Clock <= '1';             wait for 50 ns;  --900-950 ns
      Clock <= '0';             wait for 50 ns;  --950-1000 ns
      report "end of tests" severity failure;
   end process;
end tb ;