LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity PipelinedCPU3 is
port(
     clk :in std_logic;
     rst :in std_logic;
     --Probe ports used for testing
     DEBUG_IF_FLUSH : out std_logic;
     DEBUG_REG_EQUAL : out std_logic;
     -- Forwarding control signals
     DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
     DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
     --The current address (AddressOut from the PC)
     DEBUG_PC : out std_logic_vector(31 downto 0);
     --Value of PC.write_enable
     DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
     --The current instruction (Instruction output of IMEM)
     DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
     --DEBUG ports from other components
     DEBUG_TMP_REGS : out std_logic_vector(32*4 - 1 downto 0);
     DEBUG_SAVED_REGS : out std_logic_vector(32*4 - 1 downto 0);
     DEBUG_FP_REGS : out std_logic_vector(32*4 - 1 downto 0);
     DEBUG_MEM_CONTENTS : out std_logic_vector(32*4 - 1 downto 0)
);
end PipelinedCPU3;

architecture behave of PipelinedCPU3 is
   ------------------- PC-------------------
   signal PC_Write_Enable      : std_logic;
   signal PC_AddressIn         : std_logic_vector(31 downto 0);
   signal PC_AddressOut        : std_logic_vector(31 downto 0);
   ------------------- IMEM-----------------
   signal IMEM_DataOut         : std_logic_vector(31 downto 0);
   ---------------- IF/ID Reg---------------
   signal IF_DWrite            : std_logic;
   signal IF_Flush             : std_logic;
   signal IF_ID_PCPlus4_in     : std_logic_vector(31 downto 0);
   signal IF_ID_PCPlus4_out    : std_logic_vector(31 downto 0);
   signal IF_ID_Instr_out      : std_logic_vector(31 downto 0);
   ------------------- REG------------------
   signal REG_WR               : std_logic_vector(4 downto 0);
   signal REG_WD               : std_logic_vector(31 downto 0);
   signal RegWrite             : std_logic;
   signal REG_RD1              : std_logic_vector(31 downto 0);
   signal REG_RD2              : std_logic_vector(31 downto 0);
   signal sDEBUG_TMP_REGS      : std_logic_vector(32*4 - 1 downto 0);
   signal sDEBUG_SAVED_REGS    : std_logic_vector(32*4 - 1 downto 0);
   ----------------- FP_REG-----------------
   signal FP_REG_WR            : std_logic_vector(4 downto 0);
   signal FP_REG_WD            : std_logic_vector(31 downto 0);
   signal FP_REG_RD1           : std_logic_vector(31 downto 0);
   signal FP_REG_RD2           : std_logic_vector(31 downto 0);
   signal sDEBUG_FP_REGS       : std_logic_vector(32*4 - 1 downto 0);
   ----------------- COMPARE ----------------
   signal Compare_out          : std_logic;
   ---------------- ID/EX Reg----------------
   signal ID_EX_RegWrite_in    : std_logic;
   signal ID_EX_MemtoReg_in    : std_logic;
   signal ID_EX_MemRead_in     : std_logic;
   signal ID_EX_MemWrite_in    : std_logic;
   signal ID_EX_RegDst_in      : std_logic;
   signal ID_EX_ALUOp_in       : std_logic_vector(1 downto 0);
   signal ID_EX_ALUSrc_in      : std_logic;
   signal ID_EX_SignEt_in      : std_logic_vector(31 downto 0);
   signal ID_EX_RegWrite_out   : std_logic;
   signal ID_EX_MemtoReg_out   : std_logic;
   signal ID_EX_MemRead_out    : std_logic;
   signal ID_EX_MemWrite_out   : std_logic;
   signal RegDst               : std_logic;
   signal ALUOp                : std_logic_vector(1 downto 0);
   signal ALUSrc               : std_logic;
   signal ID_EX_RD1_out        : std_logic_vector(31 downto 0);
   signal ID_EX_RD2_out        : std_logic_vector(31 downto 0);
   signal ID_EX_SignEt_out     : std_logic_vector(31 downto 0);
   signal ID_EX_Rs_out         : std_logic_vector(4 downto 0);
   signal ID_EX_Rt_out         : std_logic_vector(4 downto 0);
   signal ID_EX_Rd_out         : std_logic_vector(4 downto 0);
   signal ID_EX_FP_RD1_out     : std_logic_vector(31 downto 0);
   signal ID_EX_FP_RD2_out     : std_logic_vector(31 downto 0);
   signal ID_EX_FP_Fd_out      : std_logic_vector(4 downto 0);
   ------------------- ALU-------------------
   signal ALU_In1              : std_logic_vector(31 downto 0);
   signal ALU_In2              : std_logic_vector(31 downto 0);
   signal ALU_Operation        : std_logic_vector(3 downto 0);
   signal ALU_Result           : std_logic_vector(31 downto 0);
   signal ALU_Zero             : std_logic;                     -- no use
   signal ALU_Overflow         : std_logic;
   ----------------- FP_ALU------------------
   signal FP_ALU_Result        : std_logic_vector(31 downto 0);
   signal FP_ALU_Overflow      : std_logic;
   ---------------- EX/MEM Reg---------------
   signal EX_MEM_MUX_in        : std_logic_vector(4 downto 0);
   signal EX_MEM_RegWrite_out  : std_logic;
   signal EX_MEM_MemtoReg_out  : std_logic;
   signal MemRead              : std_logic;
   signal MemWrite             : std_logic;
   signal EX_MEM_ALUResult_out : std_logic_vector(31 downto 0);
   signal EX_MEM_nMUX_out      : std_logic_vector(31 downto 0);
   signal EX_MEM_MUX_out       : std_logic_vector(4 downto 0);
   signal EX_MEM_FP_ALUResult_out : std_logic_vector(31 downto 0);
   signal EX_MEM_FP_Fd_out     : std_logic_vector(4 downto 0);
   ------------------- DMEM------------------
   signal MEM_ReadData         : std_logic_vector(31 downto 0);
   signal sDEBUG_MEM_CONTENTS  : std_logic_vector(32*4 - 1 downto 0);
   ---------------- MEM/WB Reg---------------
   signal MemtoReg             : std_logic;
   signal MEM_WB_ReadData_out  : std_logic_vector(31 downto 0);
   signal MEM_WB_ALUResult_out : std_logic_vector(31 downto 0);
   -----------Hazard Detection Unit----------
   signal MuxControl           : std_logic;
   --------------Forwarding Unit-------------
   signal ForWardA             : std_logic_vector(1 downto 0);
   signal ForWardB             : std_logic_vector(1 downto 0);
   --------------- CPUControl----------------
   signal RegDst_control_out   : std_logic;
   signal Branch               : std_logic;
   signal MemRead_control_out  : std_logic;
   signal MemtoReg_control_out : std_logic;
   signal MemWrite_control_out : std_logic;
   signal ALUSrc_control_out   : std_logic;
   signal RegWrite_control_out : std_logic;
   signal Jump                 : std_logic;
   signal ALUOp_control_out    : std_logic_vector(1 downto 0);
   -------------- ALUControl ----------------
   -------------- SignExtend ----------------
   --------------- ShiftLeft2 ---------------
   signal SL2_ADD_out          : std_logic_vector(31 downto 0);
   -------------- ShiftLeft2_26 -------------
   signal SL2_PC_out           : std_logic_vector(27 downto 0);
   ------------------- ADD ------------------
   signal ID_ADD_out           : std_logic_vector(31 downto 0);
   ------------------ AND2 ------------------
   signal PCSrc                : std_logic;
   ------------------ MUX11 -----------------
   signal MUX11_in1            : std_logic_vector(31 downto 0);
   ------------------ MUX12 -----------------
   signal MUX12_out            : std_logic_vector(31 downto 0);
   ------------------ MUX21 -----------------
   ------------------ MUX22 -----------------
   ------------------ MUX31 -----------------
   ------------------ nMUX11 ----------------
   signal nMUX11_in            : std_logic_vector(7 downto 0);
   signal nMUX11_out           : std_logic_vector(7 downto 0);
   ------------------ nMUX22 ----------------
   ------------------ nMUX32 ----------------
   signal nMUX32_out           : std_logic_vector(31 downto 0);

begin
   ID_EX_RegWrite_in <= nMUX11_out(2);
   ID_EX_MemtoReg_in <= nMUX11_out(5);
   ID_EX_MemRead_in  <= nMUX11_out(6);
   ID_EX_MemWrite_in <= nMUX11_out(4);
   ID_EX_RegDst_in   <= nMUX11_out(7);
   ID_EX_ALUOp_in    <= (nMUX11_out(1),nMUX11_out(0));
   ID_EX_ALUSrc_in   <= nMUX11_out(3);
   MUX11_in1         <= IF_ID_PCPlus4_in(31 downto 28) & SL2_PC_out;
   nMUX11_in         <= (RegDst_control_out, MemRead_control_out, MemtoReg_control_out, MemWrite_control_out,
                         ALUSrc_control_out, RegWrite_control_out, ALUOp_control_out(1), ALUOp_control_out(0)); 
   uPC          : entity work.PC port map            (clk, PC_Write_Enable, rst, PC_AddressIn, PC_AddressOut);
   uIMEM        : entity work.IMEM port map          (PC_AddressOut, IMEM_DataOut);
   uIF_ID_REG   : entity work.if_id_reg port map     (rst, clk, IF_DWrite, IF_Flush, IMEM_DataOut, IF_ID_PCPlus4_in, IF_ID_Instr_out, IF_ID_PCPlus4_out);
   uREG         : entity work.registers port map     (IF_ID_Instr_out(25 downto 21), IF_ID_Instr_out(20 downto 16), REG_WR, REG_WD, RegWrite, clk, REG_RD1,
                                                      REG_RD2, sDEBUG_TMP_REGS, sDEBUG_SAVED_REGS);
   uFP_REG      : entity work.FP_registers port map  (IF_ID_Instr_out(15 downto 11), IF_ID_Instr_out(20 downto 16), FP_REG_WR, FP_REG_WD, RegWrite, clk, FP_REG_RD1,
                                                      FP_REG_RD2, sDEBUG_FP_REGS);
   uCOMPARE     : entity work.COMPARE port map       (REG_RD1, REG_RD2, Compare_out);
   uID_EX_REG   : entity work.id_ex_reg port map     (rst, clk, ID_EX_RegWrite_in, ID_EX_MemtoReg_in, ID_EX_MemRead_in, ID_EX_MemWrite_in, ID_EX_RegDst_in, ID_EX_ALUOp_in,
                                                      ID_EX_ALUSrc_in, REG_RD1, REG_RD2, ID_EX_SignEt_in, IF_ID_Instr_out(25 downto 21), IF_ID_Instr_out(20 downto 16),
                                                      IF_ID_Instr_out(15 downto 11), FP_REG_RD1, FP_REG_RD2, IF_ID_Instr_out(10 downto 6), ID_EX_RegWrite_out, ID_EX_MemtoReg_out, ID_EX_MemRead_out, ID_EX_MemWrite_out, RegDst,
                                                      ALUOp, ALUSrc, ID_EX_RD1_out, ID_EX_RD2_out, ID_EX_SignEt_out, ID_EX_Rs_out, ID_EX_Rt_out, ID_EX_Rd_out, ID_EX_FP_RD1_out, ID_EX_FP_RD2_out, ID_EX_FP_Fd_out);
   uALU         : entity work.ALU port map           (ALU_In1, ALU_In2, ALU_Operation, ALU_Result, ALU_Zero, ALU_Overflow);
   uFP_ALU      : entity work.FP_ALU port map        (ID_EX_FP_RD1_out, ID_EX_FP_RD2_out, ALU_Operation, FP_ALU_Result, FP_ALU_Overflow);
   uEX_MEM_REG  : entity work.ex_mem_reg port map    (rst, clk, ID_EX_RegWrite_out, ID_EX_MemtoReg_out, ID_EX_MemRead_out, ID_EX_MemWrite_out, ALU_Result, nMUX32_out,
                                                      EX_MEM_MUX_in, FP_ALU_Result, ID_EX_FP_Fd_out, EX_MEM_RegWrite_out, EX_MEM_MemtoReg_out, MemRead, MemWrite, EX_MEM_ALUResult_out, EX_MEM_nMUX_out, EX_MEM_MUX_out, EX_MEM_FP_ALUResult_out, EX_MEM_FP_Fd_out);
   uDMEM        : entity work.DMEM port map          (EX_MEM_nMUX_out, EX_MEM_ALUResult_out, MemRead, MemWrite, clk, MEM_ReadData, sDEBUG_MEM_CONTENTS);
   uMEM_WB_REG  : entity work.mem_wb_reg port map    (rst, clk, EX_MEM_RegWrite_out, EX_MEM_MemtoReg_out, MEM_ReadData, EX_MEM_ALUResult_out, EX_MEM_MUX_out, EX_MEM_FP_ALUResult_out, EX_MEM_FP_Fd_out,
                                                      RegWrite, MemtoReg, MEM_WB_ReadData_out, MEM_WB_ALUResult_out, REG_WR, FP_REG_WD, FP_REG_WR);
   uCPUControl  : entity work.CPUControl port map    (IF_ID_Instr_out(31 downto 26), RegDst_control_out, Branch, MemRead_control_out, MemtoReg_control_out,
                                                      MemWrite_control_out, ALUSrc_control_out, RegWrite_control_out, Jump, ALUOp_control_out);
   uALUControl  : entity work.ALUControl port map    (ALUOp, ID_EX_SignEt_out(5 downto 0), ALU_Operation);
   uSignEt      : entity work.SignExtend port map    (IF_ID_Instr_out(15 downto 0), ID_EX_SignEt_in);
   uPC_ADD      : entity work.ADD port map           (PC_AddressOut, "00000000000000000000000000000100", IF_ID_PCPlus4_in);
   uID_ADD      : entity work.ADD port map           (IF_ID_PCPlus4_out, SL2_ADD_out, ID_ADD_out);
   uID_SL2      : entity work.ShiftLeft2 port map    (ID_EX_SignEt_in, SL2_ADD_out);
   uJUMP_SL2    : entity work.ShiftLeft2_26 port map (IF_ID_Instr_out(25 downto 0), SL2_PC_out);
   uAND2        : entity work.AND2 port map          (Branch, Compare_out, PCSrc);
   uOR2         : entity work.OR2 port map           (Jump, PCSrc, IF_Flush);
   uMUX11       : entity work.MUX32 port map         (MUX12_out, MUX11_in1, Jump, PC_AddressIn);
   uMUX12       : entity work.MUX32 port map         (IF_ID_PCPlus4_in, ID_ADD_out, PcSrc, MUX12_out);
   uMUX21       : entity work.MUX32 port map         (nMUX32_out, ID_EX_SignEt_out, ALUSrc, ALU_In2);
   uMUX22       : entity work.MUX32 port map         (MEM_WB_ALUResult_out, MEM_WB_ReadData_out, MemtoReg, REG_WD);
   uMUX31       : entity work.MUX5 port map          (ID_EX_Rt_out, ID_EX_Rd_out, RegDst, EX_MEM_MUX_in);
   unMUX11      : entity work.MUX8 port map          (nMUX11_in, "00000000", MuxControl, nMUX11_out);
   unMUX22      : entity work.MUX32_3 port map       (ID_EX_RD1_out, REG_WD, EX_MEM_ALUResult_out, ForwardA, ALU_In1);
   unMUX32      : entity work.MUX32_3 port map       (ID_EX_RD2_out, REG_WD, EX_MEM_ALUResult_out, ForwardB, nMUX32_out);
   uForwardingUnit      : entity work.ForwardingUnit      port map (ID_EX_Rs_out, ID_EX_Rt_out, EX_MEM_MUX_out, REG_WR, EX_MEM_RegWrite_out, RegWrite, ForWardA, ForWardB);
   uHazardDetectionUnit : entity work.HazardDetectionUnit port map (IF_ID_Instr_out(25 downto 21), IF_ID_Instr_out(20 downto 16), ID_EX_Rt_out, ID_EX_MemRead_out, PC_Write_Enable, IF_DWrite, MuxControl);

   DEBUG_IF_FLUSH        <= IF_Flush;
   DEBUG_REG_EQUAL       <= Compare_out;
   DEBUG_FORWARDA        <= ForwardA;
   DEBUG_FORWARDB        <= ForwardB;
   DEBUG_PC              <= PC_AddressOut;
   DEBUG_PC_WRITE_ENABLE <= PC_Write_Enable;
   DEBUG_INSTRUCTION     <= IMEM_DataOut;
   DEBUG_TMP_REGS        <= sDEBUG_TMP_REGS;
   DEBUG_SAVED_REGS      <= sDEBUG_SAVED_REGS;
   DEBUG_FP_REGS         <= sDEBUG_FP_REGS;
   DEBUG_MEM_CONTENTS    <= sDEBUG_MEM_CONTENTS;
end behave;