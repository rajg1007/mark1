
package cxl_uvm_pkg;

typedef enum {
    RDCURR, 
    RDOWN,
    RDSHARED,
    RDANY,
    RDOWNNODATA,
    ITOMWR,
    MEMWRI,
    CLFLUSH,
    CLEANEVICT,
    DIRTYEVICT,
    CLEANEVICTNODATA,
    WOWRINV,
    WOWRINVF,
    WRINV,
    CACHEFLUSHED
    
} d2h_req_opcode_t; 

typedef enum {
    RSPIHITI,
    RSPVHITV,
    RSPIHITSE,
    RSPSHITSE,
    RSPSFWDM,
    RSPIFWDM,
    RSPVFWDV

} d2h_rsp_opcode_t; 

typedef enum {
    SNPDATA,
    SNPINV,
    SNPCURR

} h2d_req_opcode_t; 

typedef enum {
    WRITEPULL,
    GO,
    GOWRITEPULL,
    EXTCMP,
    GOWRITEPULLDROP,
    FASTGO,
    FASTGOWRITEPULL,
    GOERRWRITEPULL

} h2d_rsp_opcode_t; 

typedef enum {
    MEMINV,
    MEMRD,
    MEMRDDATA,
    MEMRDFWD,
    MEMWRFWD,
    MEMINVNT
} m2s_req_opcode_t;

typedef enum {
    MEMWR,
    MEMWRPTL
} m2s_rwd_opcode_t;

typedef enum {
    CMP,
    CMPS,
    CMPE
} s2m_ndr_opcode_t;

typedef enum {
    MEMDATA
} s2m_drs_opcode_t;

typedef enum {
    METAFIELD_META0STATE,
    METAFIELD_RSVD1,
    METAFIELD_RSVD2,
    METAFIELD_NOOP
} metafield_t;

typedef enum {
    METAVALUE_INVALID,
    METAVALUE_RSVD,
    METAVALUE_ANY,
    METAVALUE_SHARED
} metavalue_t;

typedef enum {
    MEMSNP_NOOP,
    MEMSNP_SNPDATA,
    MEMSNP_SNPCUR,
    MEMSNP_SNPINV
} snptype_t;

endpackage

import cxl_uvm_pkg::*;

interface cxl_cache_d2h_req_if(input logic clk);
  logic ready;
  logic rstn;
  logic valid;
  logic [51:0] address;
  d2h_req_opcode opcode;
  logic [11:0] cqid;
  logic nt;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input address,
    input opcode,
    input cqid,
    input nt
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output address,
    output opcode,
    output cqid,
    output nt
  );

endinterface

interface cxl_cache_d2h_rsp_if(input logic clk);
  logic rstn;
  logic valid;
  d2h_rsp_opcode opcode;
  logic [11:0] uqid;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input opcode,
    input uqid
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output opcode,
    output uqid
  );

endinterface

interface cxl_cache_d2h_data_if(input logic clk);
  logic rstn;
  logic valid;
  logic [11:0] uqid;
  logic chunkvalid;
  logic bogus;
  logic poison;
  logic [63:0] be;
  logic [511:0] data;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input uqid,
    input chunkvalid,
    input bogus,
    input poison, 
    input be,
    input data
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output uqid,
    output chunkvalid,
    output bogus,
    output poison,
    output be,
    output data
  );

endinterface

interface cxl_cache_h2d_req_if(input logic clk);
  logic ready;
  logic rstn;
  logic valid;
  logic [51:0] address;
  h2d_req_opcode opcode;
  logic [11:0] uqid;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input address,
    input opcode,
    input uqid
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output address,
    output opcode,
    output uqid
  );

endinterface

interface cxl_cache_h2d_rsp_if(input logic clk);
  logic ready;
  logic rstn;
  logic valid;
  logic [51:0] address;
  h2d_rsp_opcode opcode;
  logic [11:0] rspdata;
  logic [1:0] rsppre;
  logic [11:0] cqid;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input address,
    input opcode,
    input rspdata,
    input rsppre,
    input cqid
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output address,
    output opcode,
    input rspdata,
    input rsppre,
    input cqid
  );

endinterface

interface cxl_cache_h2d_data_if(input logic clk);
  logic ready;
  logic rstn;
  logic valid;
  logic [11:0] cqid;
  logic chunkvalid;
  logic poison;
  logic goerr;
  logic [511:0] data;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input cqid,
    input chunkvalid,
    input poison,
    input goerr,
    input data
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output cqid,
    output chunkvalid,
    output poison,
    output goerr,
    output data
  );

endinterface

interface cxl_mem_m2s_req_if(input logic clk);
  logic ready;
  logic rstn;
  logic valid;
  m2s_req_opcode_t memopcode;
  metafield_t metafield;
  metavalue_t metavalue;
  snptype_t snptype;
  logic [51:0] address;
  logic [15:0] tag;
  logic [1:0] tc;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input memopcode,
    input metafield,
    input metavalue,
    input snptype,
    input address,
    input tag,
    input tc
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output memopcode,
    output metafield,
    output metavalue,
    output snptype,
    output address,
    output tag,
    output tc
  );

endinterface

interface cxl_mem_m2s_rwd_if(input logic clk);
  logic ready;
  logic rstn;
  logic valid;
  m2s_rwd_opcode_t memopcode;
  metafield_t metafield;
  metavalue_t metavalue;
  snptype_t snptype;
  logic [51:0] address;
  logic [15:0] tag;
  logic [1:0] tc;
  logic [511:0] data;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input memopcode,
    input metafield,
    input metavalue,
    input snptype,
    input address,
    input tag,
    input tc,
    input data
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output memopcode,
    output metafield,
    output metavalue,
    output snptype,
    output address,
    output tag,
    output tc,
    output data
  );

endinterface

interface cxl_mem_s2m_ndr_if(input logic clk);
  logic ready;
  logic rstn;
  logic valid;
  s2m_ndr_opcode_t opcode
  metafield_t metafield;
  metavalue_t metavalue;
  logic [15:0] tag;

endinterface

interface cxl_mem_s2m_drs_if(input logic clk);
  logic ready;
  logic rstn;
  logic valid;
  s2m_ndr_opcode_t opcode;
  metafield_t metafield;
  metavalue_t metavalue;
  logic [15:0] tag;
  logic poison;
  logic [511:0] data;

  modport dut(
    output ready,
    input rstn,
    input valid,
    input opcode,
    input metafield,
    input metavalue,
    input tag,
    input poison,
    input data
  );

  modport drvr(
    input ready,
    output rstn,
    output valid,
    output opcode,
    output metafield,
    output metavalue,
    output tag,
    output poison,
    output data
  );

endinterface

module tb_top;

  logic clk;

  //cxl_cache_d2h_req_if  d2h_req_m_if(clk);
  //cxl_cache_d2h_rsp_if  d2h_rsp_m_if(clk);
  //cxl_cache_d2h_data_if d2h_data_m_if(clk);
  cxl_cache_h2d_req_if  h2d_req_m_if(clk);
  cxl_cache_h2d_rsp_if  h2d_rsp_m_if(clk);
  cxl_cache_h2d_data_if h2d_data_m_if(clk);

  cxl_cache_d2h_req_if  d2h_req_s_if(clk);
  cxl_cache_d2h_rsp_if  d2h_rsp_s_if(clk);
  cxl_cache_d2h_data_if d2h_data_s_if(clk);
  //cxl_cache_h2d_req_if  h2d_req_s_if(clk);
  //cxl_cache_h2d_rsp_if  h2d_rsp_s_if(clk);
  //cxl_cache_h2d_data_if h2d_data_s_if(clk);

  cxl_mem_m2s_req_if  m2s_req_m_if(clk);
  cxl_mem_m2s_rwd_if  m2s_rwd_m_if(clk);
  //cxl_mem_s2m_ndr_if  s2m_ndr_m_if(clk);
  //cxl_mem_s2m_drs_if  s2m_drs_m_if(clk);

  //cxl_mem_m2s_req_if  m2s_req_s_if(clk);
  //cxl_mem_m2s_rwd_if  m2s_rwd_s_if(clk);
  cxl_mem_s2m_ndr_if  s2m_ndr_s_if(clk);
  cxl_mem_s2m_drs_if  s2m_drs_s_if(clk);

  cxl_master cxl_master_inst(
    //.d2h_req_m_if.dut(d2h_req_m_if.drvr),
    //.d2h_rsp_m_if.dut(d2h_rsp_m_if.drvr),
    //.d2h_data_m_if.dut(d2h_data_m_if.drvr),
    .h2d_req_m_if.dut(h2d_req_m_if.drvr),
    .h2d_rsp_m_if.dut(h2d_rsp_m_if.drvr),
    .h2d_data_m_if.dut(h2d_data_m_if.drvr),
    .m2s_req_m_if.dut(m2s_req_m_if.drvr),
    .m2s_rwd_m_if.dut(m2s_rwd_m_if.drvr),
    //.s2m_ndr_m_if.dut(s2m_ndr_m_if.drvr),
    //.s2m_drs_m_if.dut(s2m_drs_m_if.drvr),
  );

  cxl_device cxl_device_inst(
    .d2h_req_s_if.dut(d2h_req_s_if.drvr),
    .d2h_rsp_s_if.dut(d2h_rsp_s_if.drvr),
    .d2h_data_s_if.dut(d2h_data_s_if.drvr),
    //.h2d_req_s_if.dut(h2d_req_s_if.drvr),
    //.h2d_rsp_s_if.dut(h2d_rsp_s_if.drvr),
    //.h2d_data_s_if.dut(h2d_data_s_if.drvr)
    //.m2s_req_s_if.dut(m2s_req_s_if.drvr),
    //.m2s_rwd_s_if.dut(m2s_rwd_s_if.drvr),
    .s2m_ndr_s_if.dut(s2m_ndr_s_if.drvr),
    .s2m_drs_s_if.dut(s2m_drs_s_if.drvr),
  );

  initial begin

    clk = 0;

    fork 
        begin
          forever begin
            #5 clk = ~clk; 
          end  
        end 
    join_none 
    
    //uvm_config_db#(virtual cxl_cache_d2h_req_if)::set(null, "*", "d2h_req_m_if", d2h_req_m_if);
    //uvm_config_db#(virtual cxl_cache_d2h_rsp_if)::set(null, "*", "d2h_rsp_m_if", d2h_rsp_m_if);
    //uvm_config_db#(virtual cxl_cache_d2h_data_if)::set(null, "*", "d2h_data_m_if", d2h_data_m_if);
    uvm_config_db#(virtual cxl_cache_h2d_req_if)::set(null, "*", "h2d_req_m_if", h2d_req_m_if);
    uvm_config_db#(virtual cxl_cache_h2d_rsp_if)::set(null, "*", "h2d_rsp_m_if", h2d_rsp_m_if);
    uvm_config_db#(virtual cxl_cache_h2d_data_if)::set(null, "*", "h2d_data_m_if", h2d_data_m_if);
    uvm_config_db#(virtual cxl_mem_m2s_req_if)::set(null, "*", "m2s_req_m_if", m2s_req_m_if);
    uvm_config_db#(virtual cxl_mem_m2s_rwd_if)::set(null, "*", "m2s_rwd_m_if", m2s_rwd_m_if);
    //uvm_config_db#(virtual cxl_mem_m2s_ndr_if)::set(null, "*", "s2m_ndr_m_if", s2m_ndr_m_if);
    //uvm_config_db#(virtual cxl_mem_m2s_drs_if)::set(null, "*", "s2m_drs_m_if", s2m_drs_m_if);

    uvm_config_db#(virtual cxl_cache_d2h_req_if)::set(null, "*", "d2h_req_s_if", d2h_req_s_if);
    uvm_config_db#(virtual cxl_cache_d2h_rsp_if)::set(null, "*", "d2h_rsp_s_if", d2h_rsp_s_if);
    uvm_config_db#(virtual cxl_cache_d2h_data_if)::set(null, "*", "d2h_data_s_if", d2h_data_s_if);
    //uvm_config_db#(virtual cxl_cache_h2d_req_if)::set(null, "*", "h2d_req_s_if", h2d_req_s_if);
    //uvm_config_db#(virtual cxl_cache_h2d_rsp_if)::set(null, "*", "h2d_rsp_s_if", h2d_rsp_s_if);
    //uvm_config_db#(virtual cxl_cache_h2d_data_if)::set(null, "*", "h2d_data_s_if", h2d_data_s_if);
    //uvm_config_db#(virtual cxl_mem_m2s_req_if)::set(null, "*", "m2s_req_s_if", m2s_req_s_if);
    //uvm_config_db#(virtual cxl_mem_m2s_rwd_if)::set(null, "*", "m2s_rwd_s_if", m2s_rwd_s_if);
    uvm_config_db#(virtual cxl_mem_m2s_ndr_if)::set(null, "*", "s2m_ndr_s_if", s2m_ndr_s_if);
    uvm_config_db#(virtual cxl_mem_m2s_drs_if)::set(null, "*", "s2m_drs_s_if", s2m_drs_s_if);
    run_test();
  end

  class crdt_seq_item extends uvm_sequence_item;
    `uvm_object_utils(crdt_seq_item)
    int req_crdt;
    int rsp_crdt;
    int data_crdt;

    function new(string name = "crdt_seq_item");
      super.new(name);
    endfunction

  endclass

  class d2h_req_seq_item extends uvm_sequence_item;
    `uvm_object_utils(d2h_req_seq_item)
    rand logic valid;
    rand d2h_req_opcode_t opcode;
    rand logic [51:0] address;
    rand logic [11:0] cqid;
    rand logic nt;
    int d2h_req_crdt;

    constraint always_valid_c{
      soft valid == 1;
    }

    constraint byte_align_64B_c{
      address[5:0] == 'h0;
    }    

    function new(string name = "d2h_req_seq_item");
      super.new(name);
    endfunction

  endclass

  class d2h_rsp_seq_item extends uvm_sequence_item;
    `uvm_object_utils(d2h_rsp_seq_item)
    rand logic valid;
    rand d2h_rsp_opcode_t opcode;
    rand logic [11:0] uqid;
    int d2h_rsp_crdt;

    constraint always_valid_c{
      soft valid == 1;
    }

    function new(string name = "d2h_rsp_seq_item");
      super.new(name);
    endfunction

  endclass

  class d2h_data_seq_item extends uvm_sequence_item;
    `uvm_object_utils(d2h_data_seq_item)
    rand logic valid;
    rand logic [11:0] uqid;
    rand logic chunkvalid;
    rand logic bogus;
    rand logic poison;
    rand logic [511:0] data;
    int d2h_data_crdt;

    constraint always_valid_c{
      soft valid == 1;
    }

    constraint skip_err_c{
      soft bogus == 'h0;
      soft poison == 'h0;
    };

    constraint skip_32B_chunks_c{
      soft chunkvalid == 'h0;
    };

    function new(string name = "d2h_data_seq_item");
      super.new(name);
    endfunction

  endclass

  class h2d_req_seq_item extends uvm_sequence_item;
    `uvm_object_utils(h2d_req_seq_item)
    rand logic valid;
    rand h2d_req_opcode_t opcode;
    rand logic [51:0] address;
    rand logic [11:0] uqid;
    int h2d_req_crdt;

    constraint always_valid_c{
      soft valid == 1;
    }

    constraint byte_align_64B_c{
      address[5:0] == 'h0;
    }    

    function new(string name = "h2d_req_seq_item");
      super.new(name);
    endfunction

  endclass

  class h2d_rsp_seq_item extends uvm_sequence_item;
    `uvm_object_utils(h2d_rsp_seq_item)
    rand logic valid;
    rand h2d_rsp_opcode_t opcode;
    rand logic [11:0] rspdata;
    rand logic [1:0] rsppre;
    rand logic [11:0] cqid;
    int h2d_rsp_crdt;

    constraint always_valid_c{
      soft valid == 1;
    }

    constraint ignore_do_later_c{
      soft rspdata == 'h0;
      soft rsppre == 'h0;
    }

    function new(string name = "h2d_rsp_seq_item");
      super.new(name);
    endfunction

  endclass

  class h2d_data_seq_item extends uvm_sequence_item;
    `uvm_object_utils(h2d_data_seq_item)
    rand logic valid;
    rand logic [11:0] cqid;
    rand logic chunkvalid;
    rand logic poison;
    rand logic goerr;
    rand logic [511:0] data;
    int h2d_data_crdt;

    constraint always_valid_c{
      soft valid == 'h1;
    }

    constraint skip_err_c{
      soft poison == 'h0;
      soft goerr == 'h0
    }

    constraint skip_32B_chunks_c{
      soft chunkvalid == 'h0;
    };

    function new(string name = "h2d_data_seq_item");
      super.new(name);
    endfunction
  
  endclass

  class m2s_req_seq_item extends uvm_sequence_item;
    `uvm_object_utils(m2s_req_seq_item)
    rand logic valid;
    rand logic [51:0] address;
    rand m2s_req_opcode_t opcode;
    rand metafield_t metafield;
    rand metavalue_t metavalue;
    rand snptype_t snptype;
    rand logic [15:0] tag;
    rand logic [1:0] tc;
    int m2s_req_crdt;

    constraint always_valid_c{
      soft valid ='h1;
    }

    constraint byte_align_64B_c{
      address[5:0] == 'h0;
    }

    constraint metafield_rsvd_illegal_c{
      !metafield inside {METAFIELD_RSVD1,METAFIELD_RSVD2}
    }

    constraint metavalue_rsvd_illegal_c{
      !metavalue inside {METAVALUE_RSVD};
    }

    constraint tc_0_c{
      soft tc == 'h0;
    }    

    function new(string name = "m2s_req_seq_item");
      super.new(name);
    endfunction

  endclass

  class m2s_rwd_seq_item extends uvm_sequence_item;
    `uvm_object_utils(m2s_rwd_seq_item)
    rand logic valid;
    rand logic [51:0] address;
    rand m2s_rwd_opcode_t opcode;
    rand metafield_t metafield;
    rand metavalue_t metavalue;
    rand snptype_t snptype;
    rand logic [15:0] tag;
    rand logic [1:0] tc;
    rand logic poison;
    rand logic [511:0] data;
    int m2s_rwd_crdt;

    constraint always_valid_c{
      soft valid ='h1;
    }

    constraint byte_align_64B_c{
      address[5:0] == 'h0;
    }

    constraint metafield_rsvd_illegal_c{
      !metafield inside {METAFIELD_RSVD1,METAFIELD_RSVD2}
    }

    constraint metavalue_rsvd_illegal_c{
      !metavalue inside {METAVALUE_RSVD};
    }

    constraint tc_0_c{
      soft tc == 'h0;
    }    

    constraint skp_err_c{
      soft poison == 'h0;
    }

    function new(string name = "m2s_req_seq_item");
      super.new(name);
    endfunction

  endclass

  class s2m_ndr_seq_item extends uvm_sequence_item;
    `uvm_object_utils(s2m_ndr_seq_item)
    rand logic valid;
    rand s2m_ndr_opcode_t opcode;
    rand metafield_t metafield;
    rand metavalue_t metavalue;
    rand logic [15:0] tag;
    int s2m_ndr_crdt;

    constraint always_valid_c{
      soft valid == 'h1;
    }

    constraint illegal_ndr_opcode_c{
      opcode == 'h3;
    }

    constraint metafield_rsvd_illegal_c{
      !metafield inside {METAFIELD_RSVD1,METAFIELD_RSVD2}
    }

    constraint metavalue_rsvd_illegal_c{
      !metavalue inside {METAVALUE_RSVD};
    }

    function new(string name = "s2m_ndr_seq_item");
      super.new(name);
    endfunction

  endclass

  class s2m_drs_seq_item extends uvm_sequence_item;
    `uvm_object_utils(s2m_drs_seq_item)
    rand logic valid;
    rand s2m_drs_opcode_t opcode;
    rand metafield_t metafield;
    rand metavalue_t metavalue;
    rand logic [15:0] tag;
    rand logic poison;
    rand logic [511:0] data;
    int s2m_drs_crdt;

    constraint always_valid_c{
      soft valid == 'h1;
    }

    constraint legal_drs_opcode_c{
      opcode == 'h0;
    }

    constraint metafield_rsvd_illegal_c{
      !metafield inside {METAFIELD_RSVD1,METAFIELD_RSVD2}
    }

    constraint metavalue_rsvd_illegal_c{
      !metavalue inside {METAVALUE_RSVD};
    }

    constraint skip_err_c{
      soft poison == 'h0;
    }

    function new(string name = "s2m_drs_seq_item");
      super.new(name);
    endfunction

  endclass

  class d2h_req_sequencer extends uvm_sequencer#(d2h_req_seq_item);
    `uvm_component_utils(d2h_req_sequencer)
    int d2h_req_crdt;

    function new(string name = "d2h_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class d2h_rsp_sequencer extends uvm_sequencer#(d2h_rsp_seq_item);
    `uvm_component_utils(d2h_rsp_sequencer)
    int d2h_rsp_crdt;

    function new(string name = "d2h_rsp_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class d2h_data_sequencer extends uvm_sequencer#(d2h_data_seq_item);
    `uvm_component_utils(d2h_data_sequencer)
    int d2h_data_crdt;

    function new(string name = "d2h_data_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class h2d_req_sequencer extends uvm_sequencer#(h2d_req_seq_item);
    `uvm_component_utils(h2d_req_sequencer)
    int h2d_req_crdt;

    function new(string name = "h2d_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class h2d_rsp_sequencer extends uvm_sequencer#(h2d_rsp_seq_item);
    `uvm_component_utils(h2d_rsp_sequencer)
    int h2d_rsp_crdt;

    function new(string name = "h2d_rsp_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class h2d_data_sequencer extends uvm_sequencer#(h2d_data_seq_item);
    `uvm_component_utils(h2d_data_sequencer)
    int h2d_data_crdt;

    function new(string name = "h2d_data_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class m2s_req_sequencer extends uvm_sequencer#(m2s_req_seq_item);
    `uvm_component_utils(m2s_req_sequencer)
    int m2s_req_crdt;

    function new(string name = "m2s_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class m2s_rwd_sequencer extends uvm_sequencer#(m2s_rwd_seq_item);
    `uvm_component_utils(m2s_rwd_sequencer)
    int m2s_rwd_crdt;

    function new(string name = "m2s_rwd_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class s2m_ndr_sequencer extends uvm_sequencer#(s2m_ndr_seq_item);
    `uvm_component_utils(s2m_ndr_sequencer)
    int s2m_ndr_crdt;

    function new(string name = "s2m_ndr_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class s2m_drs_sequencer extends uvm_sequencer#(s2m_drs_seq_item);
    `uvm_component_utils(s2m_drs_sequencer)
    int s2m_drs_crdt;

    function new(string name = "s2m_drs_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class d2h_req_monitor extends uvm_monitor;
    `uvm_component_utils(d2h_req_monitor)
    uvm_analysis_port#(d2h_req_seq_item) d2h_req_port;
    virtual cxl_cache_d2h_req_if d2h_req_s_if;
    d2h_req_seq_item d2h_req_seq_item_h;

    function new(string name = "d2h_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_req_port = new("d2h_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_req_if)::get(this, "", "d2h_req_s_if", d2h_req_s_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface d2h_req_s_if"));
      end
      fork
        begin
          forever begin
            @(negedge d2h_req_s_if.clk);
            if(d2h_req_s_if.valid) begin
              d2h_req_seq_item_h = d2h_req_seq_item::type_id::create("d2h_req_seq_item_h", this);
              d2h_req_seq_item_h.valid    = d2h_req_s_if.valid;
              d2h_req_seq_item_h.opcode   = d2h_req_s_if.opcode;
              d2h_req_seq_item_h.address  = d2h_req_s_if.address;
              d2h_req_seq_item_h.cqid     = d2h_req_s_if.cqid;
              d2h_req_seq_item_h.nt       = d2h_req_s_if.nt;
              d2h_req_port.write(d2h_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask
  endclass

  class d2h_rsp_monitor extends uvm_monitor;
    `uvm_component_utils(d2h_rsp_monitor)
    uvm_analysis_port#(d2h_rsp_seq_item) d2h_rsp_port;
    virtual cxl_cache_d2h_rsp_if d2h_rsp_s_if;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;

    function new(string name = "d2h_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_rsp_port = new("d2h_rsp_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_rsp_if)::get(this, "", "d2h_rsp_s_if", d2h_rsp_s_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface d2h_rsp_s_if"));
      end
      fork
        begin
          forever begin
            @(negedge d2h_rsp_s_if.clk);
            if(d2h_rsp_s_if.valid) begin
              d2h_rsp_seq_item_h = d2h_rsp_seq_item::type_id::create("d2h_rsp_seq_item_h", this);
              d2h_rsp_seq_item_h.valid   = d2h_rsp_s_if.valid;
              d2h_rsp_seq_item_h.opcode  = d2h_rsp_s_if.opcode;
              d2h_rsp_seq_item_h.uqid    = d2h_rsp_s_if.uqid;
              d2h_rsp_port.write(d2h_rsp_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class d2h_data_monitor extends uvm_monitor;
    `uvm_component_utils(d2h_data_monitor)
    uvm_analysis_port#(d2h_data_seq_item) d2h_data_port;
    virtual cxl_cache_d2h_data_if d2h_data_s_if;
    d2h_data_seq_item d2h_data_seq_item_h;

    function new(string name = "d2h_data_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_data_port = new("d2h_data_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_data_if)::get(this, "", "d2h_data_s_if", d2h_data_s_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface d2h_data_s_if"));
      end
      fork
        begin
          forever begin
            @(negedge d2h_data_s_if.clk);
            if(d2h_data_s_if.valid) begin
              d2h_data_seq_item_h = d2h_data_seq_item::type_id::create("d2h_data_seq_item_h", this);
              d2h_data_seq_item_h.valid         = d2h_data_s_if.valid;
              d2h_data_seq_item_h.uqid          = d2h_data_s_if.uqid;
              d2h_data_seq_item_h.chunkvalid    = d2h_data_s_if.chunkvalid;
              d2h_data_seq_item_h.bogus         = d2h_data_s_if.bogus;
              d2h_data_seq_item_h.poison        = d2h_data_s_if.poison;
              d2h_data_seq_item_h.data          = d2h_data_s_if.data;
              d2h_data_port.write(d2h_data_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class h2d_req_monitor extends uvm_monitor;
    `uvm_component_utils(h2d_req_monitor)
    uvm_analysis_port#(h2d_req_seq_item) h2d_req_port;
    virtual cxl_cache_h2d_req_if h2d_req_m_if;

    function new(string name = "h2d_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_req_port = new("h2d_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_req_if)::get(this, "", "h2d_req_m_if", h2d_req_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface h2d_req_m_if"));
      end
      fork
        begin
          forever begin
            @(negedge h2d_req_m_if.clk);
            if(h2d_req_m_if.valid) begin
              h2d_req_seq_item_h = h2d_req_seq_item::type_id::create("h2d_req_seq_item_h", this);
              h2d_req_seq_item_h.valid         = h2d_req_m_if.valid;
              h2d_req_seq_item_h.opcode        = h2d_req_m_if.opcode;
              h2d_req_seq_item_h.address       = h2d_req_m_if.address;
              h2d_req_seq_item_h.uqid          = h2d_req_m_if.uqid;
              h2d_req_port.write(h2d_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass
  
  class h2d_rsp_monitor extends uvm_monitor;
    `uvm_component_utils(h2d_rsp_monitor)
    uvm_analysis_port#(h2d_rsp_seq_item) h2d_rsp_port;
    virtual cxl_cache_h2d_rsp_if h2d_rsp_m_if;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;

    function new(string name = "h2d_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_rsp_port = new("h2d_rsp_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_rsp_if)::get(this, "", "h2d_rsp_m_if", h2d_rsp_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface h2d_rsp_m_if"));
      end
      fork
        begin
          forever begin
            @(negedge h2d_rsp_m_if.clk);
            if(h2d_rsp_m_if.valid) begin
              h2d_rsp_seq_item_h = h2d_rsp_seq_item::type_id::create("h2d_rsp_seq_item_h", this);
              h2d_rsp_seq_item_h.valid         = h2d_rsp_m_if.valid;
              h2d_rsp_seq_item_h.opcode        = h2d_rsp_m_if.opcode;
              h2d_rsp_seq_item_h.rspdata       = h2d_rsp_m_if.rspdata;
              h2d_rsp_seq_item_h.rsppre        = h2d_rsp_m_if.rsppre;
              h2d_rsp_seq_item_h.cqid          = h2d_rsp_m_if.cqid;
              h2d_rsp_port.write(h2d_rsp_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class h2d_data_monitor extends uvm_monitor;
    `uvm_component_utils(h2d_data_monitor)
    uvm_analysis_port#(h2d_data_seq_item) h2d_data_port;
    virtual cxl_cache_h2d_data_if h2d_data_m_if;
    h2d_data_seq_item h2d_data_seq_item_h;

    function new(string name = "h2d_data_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_data_port = new("h2d_data_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_data_if)::get(this, "", "h2d_data_m_if", h2d_data_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface h2d_data_m_if"));
      end
      fork
        begin
          forever begin
            @(negedge h2d_data_m_if.clk);
            if(h2d_data_m_if.valid) begin
              h2d_data_seq_item_h = h2d_data_seq_item::type_id::create("h2d_data_seq_item_h", this);
              h2d_data_seq_item_h.valid         = h2d_data_m_if.valid;
              h2d_data_seq_item_h.cqid          = h2d_data_m_if.cqid;
              h2d_data_seq_item_h.chunkvalid    = h2d_data_m_if.chunkvalid;
              h2d_data_seq_item_h.poison        = h2d_data_m_if.poison;
              h2d_data_seq_item_h.goerr         = h2d_data_m_if.goerr;
              h2d_data_seq_item_h.data         = h2d_data_m_if.data;
              h2d_data_port.write(h2d_data_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class m2s_req_monitor extends uvm_monitor;
    `uvm_component_utils(m2s_req_monitor)
    uvm_analysis_port#(m2s_req_seq_item) m2s_req_port;
    virtual cxl_mem_m2s_req_if m2s_req_m_if;
    m2s_req_seq_item m2s_req_seq_item_h;

    function new(string name = "m2s_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      m2s_req_port = new("m2s_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_req_if)::get(this, "", "m2s_req_m_if", m2s_req_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface m2s_req_m_if"));
      end
      fork
        begin
          forever begin
            @(negedge m2s_req_m_if.clk);
            if(m2s_req_m_if.valid) begin
              m2s_req_seq_item_h = m2s_req_seq_item::type_id::create("m2s_req_seq_item_h", this);
              m2s_req_seq_item_h.valid         = m2s_req_m_if.valid;
              m2s_req_seq_item_h.address       = m2s_req_m_if.address;
              m2s_req_seq_item_h.opcode        = m2s_req_m_if.opcode;
              m2s_req_seq_item_h.metafield     = m2s_req_m_if.metafield;
              m2s_req_seq_item_h.metavalue     = m2s_req_m_if.metavalue;
              m2s_req_seq_item_h.snptype       = m2s_req_m_if.snptype;
              m2s_req_seq_item_h.tag           = m2s_req_m_if.tag;
              m2s_req_seq_item_h.tc            = m2s_req_m_if.tc;
              m2s_req_port.write(m2s_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class m2s_rwd_monitor extends uvm_monitor;
    `uvm_component_utils(m2s_rwd_monitor)
    uvm_analysis_port#(m2s_rwd_seq_item) m2s_rwd_port;
    virtual cxl_mem_m2s_rwd_if m2s_rwd_m_if;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;

    function new(string name = "m2s_rwd_monitor", uvm_component parent = null);
      super.new(name, parent);
      m2s_rwd_port = new("m2s_rwd_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_rwd_if)::get(this, "", "m2s_rwd_m_if", m2s_rwd_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface m2s_rwd_m_if"));
      end
      fork
        begin
          forever begin
            @(negedge m2s_rwd_m_if.clk);
            if(m2s_rwd_m_if.valid) begin
              m2s_rwd_seq_item_h = m2s_rwd_seq_item::type_id::create("m2s_rwd_seq_item_h", this);
              m2s_rwd_seq_item_h.valid         = m2s_rwd_m_if.valid;
              m2s_rwd_seq_item_h.address       = m2s_rwd_m_if.address;
              m2s_rwd_seq_item_h.opcode        = m2s_rwd_m_if.opcode;
              m2s_rwd_seq_item_h.metafield     = m2s_rwd_m_if.metafield;
              m2s_rwd_seq_item_h.metavalue     = m2s_rwd_m_if.metavalue;
              m2s_rwd_seq_item_h.snptype       = m2s_rwd_m_if.snptype;
              m2s_rwd_seq_item_h.tag           = m2s_rwd_m_if.tag;
              m2s_rwd_seq_item_h.tc            = m2s_rwd_m_if.tc;
              m2s_rwd_seq_item_h.poison        = m2s_rwd_m_if.poison;
              m2s_rwd_seq_item_h.data          = m2s_rwd_m_if.data;
              m2s_rwd_port.write(m2s_rwd_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class d2h_req_driver extends uvm_driver;
    `uvm_component_utils(d2h_req_driver)
    virtual cxl_cache_d2h_req_if d2h_req_s_if;
    d2h_req_seq_item d2h_req_seq_item_h;

    function new(string name = "d2h_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_req_if)::get(this, "", "d2h_req_s_if", d2h_req_s_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface d2h_req_s_if"));
      end
      fork
        begin
          forever begin
            seq_item_port.get_next_item(d2h_req_seq_item_h);
            @(negedge d2h_req_s_if.clk);
            d2h_req_s_if.valid    =  d2h_req_seq_item_h.valid;//    = d2h_req_s_if.valid;
            d2h_req_s_if.opcode   =  d2h_req_seq_item_h.opcode;//   = d2h_req_s_if.opcode;
            d2h_req_s_if.address  =  d2h_req_seq_item_h.address;//  = d2h_req_s_if.address;
            d2h_req_s_if.cqid     =  d2h_req_seq_item_h.cqid;//     = d2h_req_s_if.cqid;
            d2h_req_s_if.nt       =  d2h_req_seq_item_h.nt;//       = d2h_req_s_if.nt;
            seq_item_port.item_done(d2h_req_seq_item_h);
          end
        end
      join_none
    endtask
  endclass

  class d2h_rsp_driver extends uvm_driver;
    `uvm_component_utils(d2h_rsp_driver)
    virtual cxl_cache_d2h_rsp_if d2h_rsp_s_if;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;

    function new(string name = "d2h_rsp_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_rsp_if)::get(this, "", "d2h_rsp_s_if", d2h_rsp_s_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface d2h_rsp_s_if"));
      end
      fork
        begin
          forever begin
            seq_item_port.get_next_item(d2h_rsp_seq_item_h);
            @(negedge d2h_rsp_s_if.clk);
            d2h_rsp_s_if.valid  =  d2h_rsp_seq_item_h.valid;//   = d2h_rsp_s_if.valid;
            d2h_rsp_s_if.opcode =  d2h_rsp_seq_item_h.opcode;//  = d2h_rsp_s_if.opcode;
            d2h_rsp_s_if.uqid   =  d2h_rsp_seq_item_h.uqid;//    = d2h_rsp_s_if.uqid;
            seq_item_port.item_done(d2h_rsp_seq_item_h);
          end
        end
      join_none
    endtask

  endclass

  class d2h_data_driver extends uvm_driver;
    `uvm_component_utils(d2h_data_driver)
    virtual cxl_cache_d2h_data_if d2h_data_s_if;
    d2h_data_seq_item d2h_data_seq_item_h;

    function new(string name = "d2h_data_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_data_if)::get(this, "", "d2h_data_s_if", d2h_data_s_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface d2h_data_s_if"));
      end
      fork
        begin
          forever begin
            seq_item_port.get_next_item(d2h_data_seq_item_h);
            @(negedge d2h_data_s_if.clk);
            d2h_data_s_if.valid     =  d2h_data_seq_item_h.valid;//         = d2h_data_s_if.valid;
            d2h_data_s_if.uqid      =  d2h_data_seq_item_h.uqid;//          = d2h_data_s_if.uqid;
            d2h_data_s_if.chunkvalid=  d2h_data_seq_item_h.chunkvalid;//    = d2h_data_s_if.chunkvalid;
            d2h_data_s_if.bogus     =  d2h_data_seq_item_h.bogus;//         = d2h_data_s_if.bogus;
            d2h_data_s_if.poison    =  d2h_data_seq_item_h.poison;//        = d2h_data_s_if.poison;
            d2h_data_s_if.data      =  d2h_data_seq_item_h.data;//          = d2h_data_s_if.data;
            seq_item_port.item_done(d2h_data_seq_item_h);
          end
        end
      join_none
    endtask

  endclass

  class h2d_req_driver extends uvm_driver;
    `uvm_component_utils(h2d_req_driver)
    virtual cxl_cache_h2d_req_if h2d_req_m_if;

    function new(string name = "h2d_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_req_if)::get(this, "", "h2d_req_m_if", h2d_req_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface h2d_req_m_if"));
      end
      fork
        begin
          forever begin
            seq_item_port.get_next_item(h2d_req_seq_item_h);
            @(negedge h2d_req_m_if.clk);
            h2d_req_m_if.valid    =  h2d_req_seq_item_h.valid;//         = h2d_req_m_if.valid;
            h2d_req_m_if.opcode   =  h2d_req_seq_item_h.opcode;//        = h2d_req_m_if.opcode;
            h2d_req_m_if.address  =  h2d_req_seq_item_h.address;//       = h2d_req_m_if.address;
            h2d_req_m_if.uqid     =  h2d_req_seq_item_h.uqid;//          = h2d_req_m_if.uqid;
            seq_item_port.item_done(h2d_req_seq_item_h);
          end
        end
      join_none
    endtask

  endclass
  
  class h2d_rsp_driver extends uvm_driver;
    `uvm_component_utils(h2d_rsp_driver)
    virtual cxl_cache_h2d_rsp_if h2d_rsp_m_if;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;

    function new(string name = "h2d_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_rsp_if)::get(this, "", "h2d_rsp_m_if", h2d_rsp_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface h2d_rsp_m_if"));
      end
      fork
        begin
          forever begin
            seq_item_port.get_next_item(h2d_rsp_seq_item_h);
            @(negedge h2d_rsp_m_if.clk);
            h2d_rsp_m_if.valid  =  h2d_rsp_seq_item_h.valid;//         = h2d_rsp_m_if.valid;
            h2d_rsp_m_if.opcode =  h2d_rsp_seq_item_h.opcode;//        = h2d_rsp_m_if.opcode;
            h2d_rsp_m_if.rspdata=  h2d_rsp_seq_item_h.rspdata;//       = h2d_rsp_m_if.rspdata;
            h2d_rsp_m_if.rsppre =  h2d_rsp_seq_item_h.rsppre;//        = h2d_rsp_m_if.rsppre;
            h2d_rsp_m_if.cqid   =  h2d_rsp_seq_item_h.cqid;//          = h2d_rsp_m_if.cqid;
            seq_item_port.item_done(h2d_rsp_seq_item_h);
          end
        end
      join_none
    endtask

  endclass

  class h2d_data_driver extends uvm_driver;
    `uvm_component_utils(h2d_data_driver)
    virtual cxl_cache_h2d_data_if h2d_data_m_if;
    h2d_data_seq_item h2d_data_seq_item_h;

    function new(string name = "h2d_data_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_data_if)::get(this, "", "h2d_data_m_if", h2d_data_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface h2d_data_m_if"));
      end
      fork
        begin
          forever begin
            seq_item_port.get_next_item(h2d_data_seq_item_h);
            @(negedge h2d_data_m_if.clk);
            h2d_data_m_if.valid     =  h2d_data_seq_item_h.valid;//         = h2d_data_m_if.valid;
            h2d_data_m_if.cqid      =  h2d_data_seq_item_h.cqid;//          = h2d_data_m_if.cqid;
            h2d_data_m_if.chunkvalid=  h2d_data_seq_item_h.chunkvalid;//    = h2d_data_m_if.chunkvalid;
            h2d_data_m_if.poison    =  h2d_data_seq_item_h.poison;//        = h2d_data_m_if.poison;
            h2d_data_m_if.goerr     =  h2d_data_seq_item_h.goerr;//         = h2d_data_m_if.goerr;
            h2d_data_m_if.data      =  h2d_data_seq_item_h.data;//         = h2d_data_m_if.data;
            seq_item_port.item_done(h2d_data_seq_item_h);
          end
        end
      join_none
    endtask

  endclass

  class m2s_req_driver extends uvm_driver;
    `uvm_component_utils(m2s_req_driver)
    virtual cxl_mem_m2s_req_if m2s_req_m_if;
    m2s_req_seq_item m2s_req_seq_item_h;

    function new(string name = "m2s_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_req_if)::get(this, "", "m2s_req_m_if", m2s_req_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface m2s_req_m_if"));
      end
      fork
        begin
          forever begin
            seq_item_port.get_next_item(m2s_req_seq_item_h);
            @(negedge m2s_req_m_if.clk);
            m2s_req_m_if.valid    =  m2s_req_seq_item_h.valid;//         = m2s_req_m_if.valid;
            m2s_req_m_if.address  =  m2s_req_seq_item_h.address;//       = m2s_req_m_if.address;
            m2s_req_m_if.opcode   =  m2s_req_seq_item_h.opcode;//        = m2s_req_m_if.opcode;
            m2s_req_m_if.metafield=  m2s_req_seq_item_h.metafield;//     = m2s_req_m_if.metafield;
            m2s_req_m_if.metavalue=  m2s_req_seq_item_h.metavalue;//     = m2s_req_m_if.metavalue;
            m2s_req_m_if.snptype  =  m2s_req_seq_item_h.snptype;//       = m2s_req_m_if.snptype;
            m2s_req_m_if.tag      =  m2s_req_seq_item_h.tag;//           = m2s_req_m_if.tag;
            m2s_req_m_if.tc       =  m2s_req_seq_item_h.tc;//            = m2s_req_m_if.tc;
            seq_item_port.item_done(m2s_req_seq_item_h);
          end
        end
      join_none
    endtask

  endclass

  class m2s_rwd_driver extends uvm_driver;
    `uvm_component_utils(m2s_rwd_driver)
    virtual cxl_mem_m2s_rwd_if m2s_rwd_m_if;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;

    function new(string name = "m2s_rwd_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_rwd_if)::get(this, "", "m2s_rwd_m_if", m2s_rwd_m_if)) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface m2s_rwd_m_if"));
      end
      fork
        begin
          forever begin
            seq_item_port.get_next_item(m2s_rwd_seq_item_h);
            @(negedge m2s_rwd_m_if.clk);
            m2s_rwd_m_if.valid    =  m2s_rwd_seq_item_h.valid;//         = m2s_rwd_m_if.valid;
            m2s_rwd_m_if.address  =  m2s_rwd_seq_item_h.address;//       = m2s_rwd_m_if.address;
            m2s_rwd_m_if.opcode   =  m2s_rwd_seq_item_h.opcode;//        = m2s_rwd_m_if.opcode;
            m2s_rwd_m_if.metafield=  m2s_rwd_seq_item_h.metafield;//     = m2s_rwd_m_if.metafield;
            m2s_rwd_m_if.metavalue=  m2s_rwd_seq_item_h.metavalue;//     = m2s_rwd_m_if.metavalue;
            m2s_rwd_m_if.snptype  =  m2s_rwd_seq_item_h.snptype;//       = m2s_rwd_m_if.snptype;
            m2s_rwd_m_if.tag      =  m2s_rwd_seq_item_h.tag;//           = m2s_rwd_m_if.tag;
            m2s_rwd_m_if.tc       =  m2s_rwd_seq_item_h.tc;//            = m2s_rwd_m_if.tc;
            m2s_rwd_m_if.poison   =  m2s_rwd_seq_item_h.poison;//        = m2s_rwd_m_if.poison;
            m2s_rwd_m_if.data     =  m2s_rwd_seq_item_h.data;//          = m2s_rwd_m_if.data;
            seq_item_port.item_done(m2s_rwd_seq_item_h);
          end
        end
      join_none
    endtask

  endclass

  

endmodule