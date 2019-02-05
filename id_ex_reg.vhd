LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity ID_EX_Reg is
-- ID_EX_Reg - ID stage to EX stage
port(
     rst            : in std_logic;
     clk            : in std_logic;
     RegWrite_in    : in std_logic;
     MemtoReg_in    : in std_logic;
     MemRead_in     : in std_logic;
     MemWrite_in    : in std_logic;
     RegDst_in      : in std_logic;
     ALUOp_in       : in std_logic_vector(1 downto 0);
     ALUSrc_in      : in std_logic;
     RD1_in         : in std_logic_vector(31 downto 0);
     RD2_in         : in std_logic_vector(31 downto 0);
     SignExt_in     : in std_logic_vector(31 downto 0);
     Rs_in          : in std_logic_vector(4 downto 0);
     Rt_in          : in std_logic_vector(4 downto 0);
     Rd_in          : in std_logic_vector(4 downto 0);
     FP_RD1_in      : in std_logic_vector(31 downto 0);
     FP_RD2_in      : in std_logic_vector(31 downto 0);
     FP_Fd_in       : in std_logic_vector(4 downto 0);
     RegWrite_out   : out std_logic;
     MemtoReg_out   : out std_logic;
     MemRead_out    : out std_logic;
     MemWrite_out   : out std_logic;
     RegDst_out     : out std_logic;
     ALUOp_out      : out std_logic_vector(1 downto 0);
     ALUSrc_out     : out std_logic;
     RD1_out        : out std_logic_vector(31 downto 0);
     RD2_out        : out std_logic_vector(31 downto 0);
     SignExt_out    : out std_logic_vector(31 downto 0);
     Rs_out         : out std_logic_vector(4 downto 0);
     Rt_out         : out std_logic_vector(4 downto 0);
     Rd_out         : out std_logic_vector(4 downto 0);
     FP_RD1_out     : out std_logic_vector(31 downto 0);
     FP_RD2_out     : out std_logic_vector(31 downto 0);
     FP_Fd_out      : out std_logic_vector(4 downto 0)
);
end;

architecture behave of ID_EX_Reg is
begin
   process(clk,rst)
   begin
      if rst='1' then
         RegWrite_out  <= '0';
         MemtoReg_out  <= '0';
         MemRead_out   <= '0';
         MemWrite_out  <= '0';
         RegDst_out    <= '0';
         ALUOp_out     <= "00";
         ALUSrc_out    <= '0';
         RD1_out       <= "00000000000000000000000000000000";
         RD2_out       <= "00000000000000000000000000000000";
         SignExt_out   <= "00000000000000000000000000000000";
         Rs_out        <= "00000";
         Rt_out        <= "00000";
         Rd_out        <= "00000";
         FP_RD1_out    <= "00000000000000000000000000000000";
         FP_RD2_out    <= "00000000000000000000000000000000";
         FP_Fd_out     <= "00000";
      elsif rst='0' then
         if(clk'event and clk = '1') then
            RegWrite_out  <= RegWrite_in;
            MemtoReg_out  <= MemtoReg_in;
            MemRead_out   <= MemRead_in;
            MemWrite_out  <= MemWrite_in;
            RegDst_out    <= RegDst_in;
            ALUOp_out     <= ALUOp_in;
            ALUSrc_out    <= ALUSrc_in;
            RD1_out       <= RD1_in;
            RD2_out       <= RD2_in;
            SignExt_out   <= SignExt_in;
            Rs_out        <= Rs_in;
            Rt_out        <= Rt_in;
            Rd_out        <= Rd_in;
            FP_RD1_out    <= FP_RD1_in;
            FP_RD2_out    <= FP_RD2_in;
            FP_Fd_out     <= FP_Fd_in;
         end if;
      end if;
   end process;
end behave;