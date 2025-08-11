

interface parcv1_core_if#(parameter XLEN = 32)(input logic clk);

    logic               rst;

    // Instruction memory interface
    logic [XLEN-1:0]    imem_addr;
    logic               imem_req;
    logic [XLEN-1:0]    imem_data;
    logic               imem_resp;

    // Data memory interface
    logic [XLEN-1:0]    dmem_addr;
    logic [XLEN-1:0]    dmem_wdata;
    logic               dmem_we;
    logic               dmem_req;
    logic [XLEN-1:0]    dmem_data;
    logic               dmem_resp;

endinterface

module tb;
    logic clk=0;
    always #5 clk = ~clk;

    parcv1_core_if pv1inf(clk);

    parcv1_core dut (
.clk        (pv1inf.clk),
.rst        (pv1inf.rst),

// Instruction memory interface
.imem_addr  (pv1inf.imem_addr),
.imem_req   (pv1inf.imem_req),
.imem_data  (pv1inf.imem_data),
.imem_resp  (pv1inf.imem_resp),

// Data memory interface
.dmem_addr  (pv1inf.dmem_addr),
.dmem_wdata (pv1inf.dmem_wdata),
.dmem_we    (pv1inf.dmem_we),
.dmem_req   (pv1inf.dmem_req),
.dmem_data  (pv1inf.dmem_data),
.dmem_resp  (pv1inf.dmem_resp)

    );

    initial begin
        uvm_config_db #(virtual parcv1_core_if)::set(null,"*","pv1inf",pv1inf);
        run_test("stall_test");
    end


endmodule

ifndef BASE_SEQ_ITEM_SV
`define BASE_SEQ_ITEM_SV

class base_seq_item extends uvm_sequence_item;

  `uvm_object_utils(base_seq_item)

  // Number of cycles to hold reset
  rand int unsigned reset_cycles;

  // Constructor
  function new(string name = "base_seq_item");
    super.new(name);
  endfunction

  // Optional: constraints
  constraint c_reset_cycles {
    soft reset_cycles inside {[1:100]}; // Example range
  }

endclass : base_seq_item

`endif // BASE_SEQ_ITEM_SV

`ifndef RESET_SEQ_SV
`define RESET_SEQ_SV

class reset_seq extends uvm_sequence #(base_sequence_item);

  `uvm_object_utils(reset_seq)

  // Virtual interface handle
  virtual parcv1_core_if pv1inf;
  base_sequence_item req;

  // Constructor
  function new(string name = "reset_seq");
    super.new(name);
  endfunction

  // Pre-body: get the virtual interface from config DB
  virtual task pre_body();
    if (!uvm_config_db#(virtual parcv1_core_if)::get(null, "*", "pv1inf", pv1inf)) begin
      `uvm_fatal(get_type_name(), "Failed to get virtual interface from config DB")
    end
    //pre randomize if incase 
    req = base_seq_item::type_id::create("req");
  endtask

  // Main sequence body
  virtual task body();
    int rst_cycles;
    `uvm_info(get_type_name(), "Starting reset sequence", UVM_MEDIUM)
    assert(req.randomize());
    rst_cycles = req.reset_cycles;
    pv1inf.rst <= 1'b1;
    repeat (rst_cycles) @(posedge pv1inf.clk); // Hold reset for n cycles
    pv1inf.rst <= 1'b0;

    `uvm_info(get_type_name(), "Reset sequence completed", UVM_MEDIUM)
  endtask

endclass : reset_seq

`endif // RESET_SEQ_SV



`ifndef PARCV1_CORE_ENV_SV
`define PARCV1_CORE_ENV_SV

class parcv1_core_env extends uvm_env;

  `uvm_component_utils(parcv1_core_env)

  // Agent handles
  instr_agent instr_agnt;
  data_agent  data_agnt;

  // Constructor
  function new(string name = "parcv1_core_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create agents
    instr_agnt = instr_agent::type_id::create("instr_agnt", this);
    data_agnt  = data_agent::type_id::create("data_agnt", this);

  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect monitors, analysis ports, etc. if needed

  endfunction

endclass : parcv1_core_env

`endif // PARCV1_CORE_ENV_SV
