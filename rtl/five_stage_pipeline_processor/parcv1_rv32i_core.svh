//--------------------------------------------------------------------------
// parcv1_rv32i_core.sv  —  TinyRV-compatible 5-stage pipeline
// Cornell ECE4750 §4  |  Author: Geethanand Nagaraj 2025-07-25
//--------------------------------------------------------------------------
// Datapath legend  (capital stage = reg alias)
//   F: Fetch      D: Decode      X: Execute
//   M: Memory     W: Writeback
//--------------------------------------------------------------------------

module parcv1_rv32i_core
#( parameter XLEN     = 32
 , parameter REG_NUM  = 32
 , parameter RESET_PC = 32'h8000_0000
 )
( input  logic                 clk
, input  logic                 rst

// Instruction memory
, output logic [XLEN-1:0]      imem_addr
, output logic                 imem_req
, input  logic [XLEN-1:0]      imem_data
, input  logic                 imem_resp

// Data memory
, output logic [XLEN-1:0]      dmem_addr
, output logic [XLEN-1:0]      dmem_wdata
, output logic                 dmem_we
, output logic                 dmem_req
, input  logic [XLEN-1:0]      dmem_data
, input  logic                 dmem_resp
);

//------------------------------------------------------------------------
// Enumerations
//------------------------------------------------------------------------

typedef enum logic [1:0] {PC_PLUS4, PC_BR, PC_JAL, PC_JALR} pc_sel_e;

typedef enum logic [3:0] {
   ALU_ADD , ALU_SUB , ALU_AND , ALU_OR  ,
   ALU_XOR , ALU_SLT , ALU_SLTU, ALU_SLL ,
   ALU_SRL , ALU_SRA , ALU_LUI , ALU_PASS
} alu_fn_e;

typedef enum logic [1:0] {RES_ALU, RES_PC4} result_sel_e;
typedef enum logic [1:0] {WB_ALU , WB_MEM , WB_PC4} wb_sel_e;

//------------------------------------------------------------------------
// Control-bundle propagated down pipeline
//------------------------------------------------------------------------

typedef struct packed {
   pc_sel_e     pc_sel_F;     // Where next PC comes from
   logic        op1_sel_D;    // 0=reg, 1=imm
   alu_fn_e     alu_fn_X;
   result_sel_e res_sel_X;
   wb_sel_e     wb_sel_M;
   logic        rf_we_W;
   logic [4:0]  rf_waddr_W;
   logic        mem_en_M;
   logic        mem_we_M;
   logic        rs_en_D;
   logic        rt_en_D;
   logic        branch_D;
} ctrl_t;

//------------------------------------------------------------------------
// Pipeline registers / wires (minimal naming clutter)
//------------------------------------------------------------------------

logic  val_F,  val_D,  val_X,  val_M,  val_W;
logic  stall_F, stall_D, squash_F, squash_D;
ctrl_t cs_FD, cs_DX, cs_XM, cs_MW;

logic [XLEN-1:0] pc_F,  pc_D,  pc_X,  pc_M,  pc_W;
logic [31:0]     ir_FD, ir_DX, ir_XM, ir_MW;

logic [4:0]  rs_D, rt_D;
logic [XLEN-1:0] rd1_D, rd2_D;

logic [XLEN-1:0] imm_i, imm_s, imm_b, imm_u, imm_j;
logic [XLEN-1:0] op0_X, op1_X, alu_X, wb_W;
logic            br_taken_X;

//------------------------------------------------------------------------
// Register File
//------------------------------------------------------------------------

logic [XLEN-1:0] regfile [REG_NUM-1:0];

always_ff @(posedge clk)
  if (cs_MW.rf_we_W && val_W && cs_MW.rf_waddr_W!=5'd0)
    regfile[cs_MW.rf_waddr_W] <= wb_W;

assign rd1_D = (rs_D==5'd0) ? '0 : regfile[rs_D];
assign rd2_D = (rt_D==5'd0) ? '0 : regfile[rt_D];

//------------------------------------------------------------------------
// FETCH
//------------------------------------------------------------------------

always_ff @(posedge clk) begin
  if (rst) begin
      pc_F  <= RESET_PC;
      val_F <= 1'b0;
  end else if (!stall_F) begin
      unique case (cs_FD.pc_sel_F)
        PC_PLUS4: pc_F <= pc_F + 4;
        PC_BR   : pc_F <= pc_X + imm_b;      // branch targ already sign-ext<<1
        PC_JAL  : pc_F <= pc_X + imm_j;      // jal immediate from D
        PC_JALR : pc_F <= (op0_X + imm_i) & ~32'd1;
      endcase
      val_F <= 1'b1;
      if (squash_F) val_F <= 1'b0;
  end
end

assign imem_addr = pc_F;
assign imem_req  = val_F;

//------------------------------------------------------------------------
// DECODE
//------------------------------------------------------------------------

always_ff @(posedge clk) begin
  if (rst) val_D <= 1'b0;
  else if (!stall_D) begin
    ir_FD <= imem_data;
    pc_D  <= pc_F;
    cs_FD <= decode(ir_FD);
    val_D <= val_F & imem_resp;
    if (squash_D) val_D <= 1'b0;
  end
end

// Field decode
assign rs_D = ir_FD[19:15];
assign rt_D = ir_FD[24:20];

// Immediates
assign imm_i = {{20{ir_FD[31]}}, ir_FD[31:20]};
assign imm_s = {{20{ir_FD[31]}}, ir_FD[31:25], ir_FD[11:7]};
assign imm_b = {{19{ir_FD[31]}}, ir_FD[31], ir_FD[7], ir_FD[30:25],
                 ir_FD[11:8], 1'b0};
assign imm_u = {ir_FD[31:12],12'b0};
assign imm_j = {{11{ir_FD[31]}}, ir_FD[19:12], ir_FD[20],
                 ir_FD[30:21],1'b0};

//------------------------------------------------------------------------
// EXECUTE
//------------------------------------------------------------------------

always_ff @(posedge clk) begin
  if (rst) val_X <= 1'b0;
  else if (!stall_D) begin
      ir_DX <= ir_FD;
      pc_X  <= pc_D;
      cs_DX <= cs_FD;
      val_X <= val_D;
  end
end

// ---- Bypassing muxes to X stage operands -----------------------------
// (X uses previous cycle's cs_FD, so use rs_D etc.)
logic [XLEN-1:0] fwd_rs, fwd_rt;

// Forward priority: X→X (ALU), M→D, W→D
assign fwd_rs = (cs_DX.rf_we_W && cs_DX.rf_waddr_W!=0 && cs_DX.rf_waddr_W==rs_D) ? alu_X :
                (cs_XM.rf_we_W && cs_XM.rf_waddr_W!=0 && cs_XM.rf_waddr_W==rs_D) ? wb_W  :
                rd1_D;

assign fwd_rt = (cs_DX.rf_we_W && cs_DX.rf_waddr_W!=0 && cs_DX.rf_waddr_W==rt_D) ? alu_X :
                (cs_XM.rf_we_W && cs_XM.rf_waddr_W!=0 && cs_XM.rf_waddr_W==rt_D) ? wb_W  :
                rd2_D;

assign op0_X = fwd_rs;
assign op1_X = cs_FD.op1_sel_D
               ? ((cs_FD.pc_sel_F==PC_JAL) ? imm_j :
                  (cs_FD.pc_sel_F==PC_JALR) ? imm_i :
                  (cs_FD.alu_fn_X==ALU_LUI) ? imm_u : imm_i)
               : fwd_rt;

// ALU
always_comb begin
  unique case (cs_DX.alu_fn_X)
    ALU_ADD : alu_X = op0_X + op1_X;
    ALU_SUB : alu_X = op0_X - op1_X;
    ALU_AND : alu_X = op0_X & op1_X;
    ALU_OR  : alu_X = op0_X | op1_X;
    ALU_XOR : alu_X = op0_X ^ op1_X;
    ALU_SLT : alu_X = ($signed(op0_X) < $signed(op1_X));
    ALU_SLTU: alu_X = (op0_X < op1_X);
    ALU_SLL : alu_X = op0_X << op1_X[4:0];
    ALU_SRL : alu_X = op0_X >> op1_X[4:0];
    ALU_SRA : alu_X = $signed(op0_X) >>> op1_X[4:0];
    ALU_LUI : alu_X = op1_X;
    default : alu_X = op0_X;
  endcase
end

// Branch resolution
always_comb begin
  br_taken_X = 1'b0;
  if (cs_DX.branch_D && val_X) begin
    unique case (ir_DX[14:12])
      3'b000: br_taken_X = (op0_X == op1_X);                 // beq
      3'b001: br_taken_X = (op0_X != op1_X);                 // bne
      3'b100: br_taken_X = ($signed(op0_X) < $signed(op1_X));// blt
      3'b101: br_taken_X = ($signed(op0_X) >= $signed(op1_X));// bge
      3'b110: br_taken_X = (op0_X < op1_X);                  // bltu
      3'b111: br_taken_X = (op0_X >= op1_X);                 // bgeu
    endcase
  end
end

//------------------------------------------------------------------------
// MEMORY
//------------------------------------------------------------------------

always_ff @(posedge clk) begin
  if (rst) val_M <= 1'b0;
  else begin
    ir_XM <= ir_DX;
    pc_M  <= pc_X;
    cs_XM <= cs_DX;
    val_M <= val_X;
  end
end

assign dmem_addr  = alu_X;
assign dmem_wdata = fwd_rt;
assign dmem_we    = cs_XM.mem_we_M & val_M;
assign dmem_req   = cs_XM.mem_en_M & val_M;

//------------------------------------------------------------------------
// WRITEBACK
//------------------------------------------------------------------------

always_ff @(posedge clk) begin
  if (rst) val_W <= 1'b0;
  else begin
    ir_MW <= ir_XM;
    pc_W  <= pc_M;
    cs_MW <= cs_XM;
    val_W <= val_M;

    unique case (cs_XM.wb_sel_M)
      WB_ALU : wb_W <= alu_X;
      WB_MEM : wb_W <= dmem_data;
      WB_PC4 : wb_W <= pc_M + 4;
      default: wb_W <= '0;
    endcase
  end
end

//------------------------------------------------------------------------
// HAZARD LOGIC  (RAW load-use  +  control-flow squash)
//------------------------------------------------------------------------

always_comb begin
  // Load in X?
  logic load_X;
  load_X = cs_DX.mem_en_M & ~cs_DX.mem_we_M;

  stall_D = val_D & val_X & load_X & (
           (cs_DX.rf_waddr_W != 0) & (
             (cs_DX.rf_waddr_W == rs_D & cs_FD.rs_en_D) |
             (cs_DX.rf_waddr_W == rt_D & cs_FD.rt_en_D)
           )
  );
  stall_F = stall_D;

  squash_D = (val_X & cs_DX.branch_D & br_taken_X) |
             (val_D & (cs_FD.pc_sel_F==PC_JAL || cs_FD.pc_sel_F==PC_JALR));
  squash_F = squash_D;
end

//------------------------------------------------------------------------
// CONTROL DECODE  (full RV32I)
//------------------------------------------------------------------------

function automatic ctrl_t decode (input logic [31:0] ins);
  ctrl_t c;  // default 0
  c.pc_sel_F   = PC_PLUS4;
  c.op1_sel_D  = 1'b0;
  c.alu_fn_X   = ALU_ADD;
  c.res_sel_X  = RES_ALU;
  c.wb_sel_M   = WB_ALU;
  c.rf_we_W    = 1'b0;
  c.rf_waddr_W = 5'd0;
  c.mem_en_M   = 1'b0;
  c.mem_we_M   = 1'b0;
  c.rs_en_D    = 1'b0;
  c.rt_en_D    = 1'b0;
  c.branch_D   = 1'b0;

  logic [6:0] op = ins[6:0];
  logic [2:0] f3 = ins[14:12];
  logic [6:0] f7 = ins[31:25];

  unique case (op)

    // R-type
    7'b0110011: begin
      c.rf_we_W    = 1;
      c.rf_waddr_W = ins[11:7];
      c.rs_en_D    = 1;
      c.rt_en_D    = 1;
      unique case (f3)
        3'b000: c.alu_fn_X = (f7==7'b0100000)?ALU_SUB:ALU_ADD;
        3'b001: c.alu_fn_X = ALU_SLL;
        3'b010: c.alu_fn_X = ALU_SLT;
        3'b011: c.alu_fn_X = ALU_SLTU;
        3'b100: c.alu_fn_X = ALU_XOR;
        3'b101: c.alu_fn_X = (f7==7'b0100000)?ALU_SRA:ALU_SRL;
        3'b110: c.alu_fn_X = ALU_OR;
        3'b111: c.alu_fn_X = ALU_AND;
      endcase
    end

    // I-type arithmetic
    7'b0010011: begin
      c.rf_we_W    = 1;
      c.rf_waddr_W = ins[11:7];
      c.rs_en_D    = 1;
      c.op1_sel_D  = 1;
      unique case (f3)
        3'b000: c.alu_fn_X = ALU_ADD;    // addi
        3'b010: c.alu_fn_X = ALU_SLT;    // slti
        3'b011: c.alu_fn_X = ALU_SLTU;   // sltiu
        3'b100: c.alu_fn_X = ALU_XOR;    // xori
        3'b110: c.alu_fn_X = ALU_OR;     // ori
        3'b111: c.alu_fn_X = ALU_AND;    // andi
        3'b001: begin                    // slli
                   c.alu_fn_X = ALU_SLL;
                   c.op1_sel_D=1;
                 end
        3'b101: c.alu_fn_X = (ins[30])?ALU_SRA:ALU_SRL; // srli/srai
      endcase
    end

    // LUI
    7'b0110111: begin
      c.rf_we_W    = 1;
      c.rf_waddr_W = ins[11:7];
      c.op1_sel_D  = 1;
      c.alu_fn_X   = ALU_LUI;
    end

    // AUIPC
    7'b0010111: begin
      c.rf_we_W    = 1;
      c.rf_waddr_W = ins[11:7];
      c.op1_sel_D  = 1;
      c.alu_fn_X   = ALU_ADD;
    end

    // JAL
    7'b1101111: begin
      c.pc_sel_F   = PC_JAL;
      c.rf_we_W    = 1;
      c.rf_waddr_W = ins[11:7];
      c.res_sel_X  = RES_PC4;
      c.wb_sel_M   = WB_PC4;
    end

    // JALR
    7'b1100111: begin
      c.pc_sel_F   = PC_JALR;
      c.rf_we_W    = 1;
      c.rf_waddr_W = ins[11:7];
      c.rs_en_D    = 1;
      c.op1_sel_D  = 1;
      c.res_sel_X  = RES_PC4;
      c.wb_sel_M   = WB_PC4;
      c.alu_fn_X   = ALU_ADD;
    end

    // Branches
    7'b1100011: begin
      c.pc_sel_F   = PC_BR;
      c.branch_D   = 1;
      c.rs_en_D    = 1;
      c.rt_en_D    = 1;
      c.alu_fn_X   = ALU_SUB;   // compare via subtract
    end

    // Loads
    7'b0000011: begin
      c.rf_we_W    = 1;
      c.rf_waddr_W = ins[11:7];
      c.rs_en_D    = 1;
      c.op1_sel_D  = 1;
      c.alu_fn_X   = ALU_ADD;
      c.mem_en_M   = 1;
      c.wb_sel_M   = WB_MEM;
    end

    // Stores
    7'b0100011: begin
      c.rs_en_D    = 1;
      c.rt_en_D    = 1;
      c.op1_sel_D  = 1;
      c.alu_fn_X   = ALU_ADD;
      c.mem_en_M   = 1;
      c.mem_we_M   = 1;
    end

    default: ; // treat as NOP
  endcase
  return c;
endfunction

endmodule
