LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity EX_MEM_Reg is
-- EX_MEM_Reg - EX stage to MEM stage
port(
     rst               : in std_logic;
     clk               : in std_logic;
     RegWrite_in       : in std_logic;
     MemtoReg_in       : in std_logic;
     MemRead_in        : in std_logic;
     MemWrite_in       : in std_logic;
     ALUResult_in      : in std_logic_vector(31 downto 0);
     RD2_in            : in std_logic_vector(31 downto 0);
     MUX_in            : in std_logic_vector(4 downto 0);
     FP_ALUResult_in   : in std_logic_vector(31 downto 0);
     FP_Fd_in          : in std_logic_vector(4 downto 0);
     RegWrite_out      : out std_logic;
     MemtoReg_out      : out std_logic;
     MemRead_out       : out std_logic;
     MemWrite_out      : out std_logic;
     ALUResult_out     : out std_logic_vector(31 downto 0);
     RD2_out           : out std_logic_vector(31 downto 0);
     MUX_out           : out std_logic_vector(4 downto 0);
     FP_ALUResult_out  : out std_logic_vector(31 downto 0);
     FP_Fd_out         : out std_logic_vector(4 downto 0)
);
end;

architecture behave of EX_MEM_Reg is
begin
   process(clk,rst)
   begin
      if rst='1' then
         RegWrite_out      <= '0';
         MemtoReg_out      <= '0';
         MemRead_out       <= '0';
         MemWrite_out      <= '0';
         ALUResult_out     <= "00000000000000000000000000000000";
         RD2_out           <= "00000000000000000000000000000000";
         MUX_out           <= "00000";
         FP_ALUResult_out  <= "00000000000000000000000000000000";
         FP_Fd_out         <= "00000";
      elsif rst='0' then
         if(clk'event and clk = '1') then
            RegWrite_out      <= RegWrite_in;
            MemtoReg_out      <= MemtoReg_in;
            MemRead_out       <= MemRead_in;
            MemWrite_out      <= MemWrite_in;
            ALUResult_out     <= ALUResult_in;
            RD2_out           <= RD2_in;
            MUX_out           <= MUX_in;
            FP_ALUResult_out  <= FP_ALUResult_in;
            FP_Fd_out         <= FP_Fd_in;
         end if;
      end if;
   end process;
end behave;