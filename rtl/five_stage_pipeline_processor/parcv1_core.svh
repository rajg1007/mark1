

module parc_pipelined_top #(parameter XLEN=32, parameter REG_NUM=32) (
    input  logic         clk,
    input  logic         rst,
    // Instruction memory interface
    output logic [XLEN-1:0] imem_addr,
    output logic            imem_req,
    input  logic [XLEN-1:0] imem_data,
    input  logic            imem_resp,
    // Data memory interface
    output logic [XLEN-1:0] dmem_addr,
    output logic [XLEN-1:0] dmem_wdata,
    output logic            dmem_we,
    output logic            dmem_req,
    input  logic [XLEN-1:0] dmem_data,
    input  logic            dmem_resp
);

    //---------------- Pipeline registers & control ------------------

    typedef enum logic [1:0] {PC_PLUS4, PC_BR, PC_J, PC_JR} pc_sel_e;
    typedef enum logic [2:0]
        {ADD, SUB, AND, OR, SLT, SRA, SLL, XOR} alu_fn_e;
    typedef enum logic [1:0] {RES_ALU, RES_MUL, RES_PC4} result_sel_e;
    typedef enum logic [1:0] {WB_ALU, WB_MEM, WB_PC4} wb_sel_e;

    // --- Control info bundle (expand as needed) ---
    typedef struct packed {
        pc_sel_e     pc_sel_F;
        logic        op1_sel_D, rs_en_D, rt_en_D;
        alu_fn_e     alu_fn_X;
        result_sel_e result_sel_X;
        wb_sel_e     wb_sel_M;
        logic        rf_wen_W;
        logic [4:0]  rf_waddr_W;
        logic        mem_en_M, mem_we_M;
    } ctrl_sig;

    // Pipeline latches
    logic [XLEN-1:0] pc_F, pc_D, pc_X, pc_M, pc_W;
    logic [XLEN-1:0] ir_FD, ir_DX, ir_XM, ir_MW;
    logic [XLEN-1:0] rd1_D, rd2_D;
    logic [XLEN-1:0] op0_X, op1_X, op0_M, op1_M;
    logic [XLEN-1:0] alu_res_X, mul_res_X, dmem_out_M, wb_data_W;
    logic [XLEN-1:0] br_targ_X, j_targ_X;
    logic [4:0]      rs_D, rt_D, rd_D;
    logic [15:0]     imm16_D;
    logic [25:0]     imm26_D;
    logic            eq_X, br_taken_X;
    ctrl_sig         cs_FD, cs_DX, cs_XM, cs_MW;

    // Pipeline valid/stall/squash logic
    logic val_F, val_D, val_X, val_M, val_W;
    logic squash_F, squash_D, stall_F, stall_D, stall_X, stall_M, stall_W;

    //------------------- Fetch Stage --------------------------------

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_F   <= 32'h8000_0000;
            val_F  <= 0;
        end
        else if (!stall_F) begin
            unique case (cs_FD.pc_sel_F)
                PC_PLUS4: pc_F <= pc_F + 4;
                PC_BR   : pc_F <= br_targ_X;
                PC_J    : pc_F <= j_targ_X;
                PC_JR   : pc_F <= op0_X;
            endcase
            val_F  <= 1;
            if (squash_F)
                val_F <= 0;
        end
    end

    assign imem_addr = pc_F;
    assign imem_req  = val_F;

    //------------------- Decode Stage -------------------------------

    always_ff @(posedge clk) begin
        if (rst) begin
            val_D <= 0;
        end
        else if (!stall_D) begin
            ir_FD   <= imem_data;
            pc_D    <= pc_F;
            cs_FD   <= decode_control(imem_data);
            val_D   <= val_F & imem_resp;
            if (squash_D)
                val_D <= 0;
        end
    end

    // Instruction fields
    assign rs_D    = ir_FD[25:21];
    assign rt_D    = ir_FD[20:16];
    assign rd_D    = ir_FD[15:11];
    assign imm16_D = ir_FD[15:0];
    assign imm26_D = ir_FD[25:0];

    // Register file
    logic [XLEN-1:0] regfile [0:REG_NUM-1];
    assign rd1_D = regfile[rs_D];
    assign rd2_D = regfile[rt_D];

    // Immediate generation and jump/branch targets
    logic [XLEN-1:0] sext_D, br_off_D, br_targ_D, j_targ_D;
    assign sext_D   = {{16{imm16_D[15]}}, imm16_D};
    assign br_off_D = sext_D << 2;
    assign br_targ_D = pc_D + br_off_D;
    assign j_targ_D = {pc_D[31:28], imm26_D, 2'b00};

    //------------------- Execute Stage ------------------------------
    // Bypassing logic for op0_X/op1_X uses latest values

    // (Insert bypass muxes here; for brevity, only basic implementation)

    always_ff @(posedge clk) begin
        if (rst)
            val_X <= 0;
        else if (!stall_X) begin
            pc_X     <= pc_D;
            ir_DX    <= ir_FD;
            op0_X    <= rd1_D;
            op1_X    <= cs_FD.op1_sel_D ? sext_D : rd2_D;
            cs_DX    <= cs_FD;
            br_targ_X<= br_targ_D;
            j_targ_X <= j_targ_D;
            val_X    <= val_D;
        end
    end

    // ALU
    always_comb begin
        unique case (cs_DX.alu_fn_X)
            ADD: alu_res_X = op0_X + op1_X;
            SUB: alu_res_X = op0_X - op1_X;
            AND: alu_res_X = op0_X & op1_X;
            OR : alu_res_X = op0_X | op1_X;
            SLT: alu_res_X = $signed(op0_X) < $signed(op1_X);
            SLL: alu_res_X = op0_X << op1_X[4:0];
            SRA: alu_res_X = $signed(op0_X) >>> op1_X[4:0];
            XOR: alu_res_X = op0_X ^ op1_X;
        endcase
    end

    assign mul_res_X = op0_X * op1_X;
    assign eq_X = (op0_X == op1_X);

    assign br_taken_X = (ir_DX[31:26] == 6'b000101) && !eq_X; // BNE branch taken

    //------------------- Memory Stage -------------------------------
    always_ff @(posedge clk) begin
        if (rst)
            val_M <= 0;
        else if (!stall_M) begin
            pc_M     <= pc_X;
            ir_XM    <= ir_DX;
            cs_XM    <= cs_DX;
            val_M    <= val_X;
            op0_M    <= op0_X;
            op1_M    <= op1_X;
        end
    end

    assign dmem_addr = alu_res_X;
    assign dmem_wdata= op1_X;
    assign dmem_we   = cs_XM.mem_we_M;
    assign dmem_req  = cs_XM.mem_en_M;

    //------------------- Writeback Stage ----------------------------
    always_ff @(posedge clk) begin
        if (rst)
            val_W <= 0;
        else if (!stall_W) begin
            pc_W      <= pc_M;
            ir_MW     <= ir_XM;
            cs_MW     <= cs_XM;
            val_W     <= val_M;
            wb_data_W <= (cs_XM.wb_sel_M == WB_ALU) ? alu_res_X :
                         (cs_XM.wb_sel_M == WB_MEM) ? dmem_data :
                         (cs_XM.wb_sel_M == WB_PC4) ? (pc_X + 4) :
                         0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i=0; i<REG_NUM; i++)
                regfile[i] <= 0;
        end
        else if (cs_MW.rf_wen_W && val_W && (cs_MW.rf_waddr_W!=0))
            regfile[cs_MW.rf_waddr_W] <= wb_data_W;
    end

    //------------------ Hazard Logic: Stall & Squash -------------------
    // RAW: Stall if D reads a reg with a load in X
    always_comb begin
        logic load_X = (cs_DX.mem_en_M && !cs_DX.mem_we_M);
        stall_D = val_D && val_X && load_X &&
                  ( ((cs_DX.rf_waddr_W == rs_D) && cs_DX.rs_en_D)
                  || ((cs_DX.rf_waddr_W == rt_D) && cs_DX.rt_en_D));
        stall_F = stall_D;
        // Squash if mispredicted branch or jump
        squash_D = (val_X && br_taken_X) || 
                   (val_D && ((ir_FD[31:26]==6'b000010) || (ir_FD[31:26]==6'b000011) || // J, JAL
                              (ir_FD[31:21]==11'b00000000010)));  // JR 
        squash_F = squash_D;
    end

    //------------------ Control Signal Decode (one-hot, simple) ---------
    function ctrl_sig decode_control(logic [31:0] instr);
        ctrl_sig cs;
        cs.pc_sel_F      = PC_PLUS4;
        cs.op1_sel_D     = 1'b0;
        cs.alu_fn_X      = ADD;
        cs.result_sel_X  = RES_ALU;
        cs.wb_sel_M      = WB_ALU;
        cs.rf_wen_W      = 0;
        cs.rf_waddr_W    = 0;
        cs.mem_en_M      = 0;
        cs.mem_we_M      = 0;
        cs.rs_en_D       = 0;
        cs.rt_en_D       = 0;
        unique casez(instr[31:26])
            6'b000000: begin // R-type
                unique case (instr[5:0])
                    6'b100001: begin // addu
                        cs.rf_wen_W  = 1;
                        cs.rf_waddr_W= instr[15:11];
                        cs.rs_en_D   = 1;
                        cs.rt_en_D   = 1;
                        cs.alu_fn_X  = ADD;
                    end
                    6'b000010: begin // mul
                        cs.rf_wen_W  = 1;
                        cs.rf_waddr_W= instr[15:11];
                        cs.rs_en_D   = 1;
                        cs.rt_en_D   = 1;
                        cs.alu_fn_X  = ADD;
                        cs.result_sel_X = RES_MUL;
                    end
                    6'b001000: begin // jr
                        cs.pc_sel_F = PC_JR;
                        cs.rs_en_D = 1;
                    end
                endcase
            end
            6'b001001: begin // addiu
                cs.rf_wen_W  = 1;
                cs.rf_waddr_W= instr[20:16];
                cs.op1_sel_D = 1;
                cs.rs_en_D   = 1;
                cs.alu_fn_X  = ADD;
            end
            6'b100011: begin // lw
                cs.rf_wen_W  = 1;
                cs.rf_waddr_W= instr[20:16];
                cs.op1_sel_D = 1;
                cs.alu_fn_X  = ADD;
                cs.mem_en_M  = 1;
                cs.wb_sel_M  = WB_MEM;
                cs.rs_en_D   = 1;
            end
            6'b101011: begin // sw
                cs.rf_wen_W  = 0;
                cs.rf_waddr_W= 0;
                cs.op1_sel_D = 1;
                cs.mem_en_M  = 1;
                cs.mem_we_M  = 1;
                cs.alu_fn_X  = ADD;
                cs.rs_en_D   = 1;
                cs.rt_en_D   = 1;
            end
            6'b000100: begin // beq
                cs.pc_sel_F = PC_BR;
                cs.rs_en_D  = 1;
                cs.rt_en_D  = 1;
                cs.alu_fn_X = SUB;
            end
            6'b000101: begin // bne
                cs.pc_sel_F = PC_BR;
                cs.rs_en_D  = 1;
                cs.rt_en_D  = 1;
                cs.alu_fn_X = SUB;
            end
            6'b000010: begin // j
                cs.pc_sel_F = PC_J;
            end
            6'b000011: begin // jal
                cs.pc_sel_F = PC_J;
                cs.rf_wen_W = 1;
                cs.rf_waddr_W = 5'd31;
                cs.result_sel_X = RES_PC4;
                cs.wb_sel_M = WB_PC4;
            end
        endcase
        return cs;
    endfunction

endmodule
