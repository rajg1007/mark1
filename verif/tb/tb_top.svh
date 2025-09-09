
package cxl_uvm_pkg;

parameter GEET_CXL_ADDR_WIDTH = 52;
parameter GEET_CXL_DATA_WIDTH = 512;
parameter GEET_CXL_CACHE_CQID_WIDTH = 12;
parameter GEET_CXL_CACHE_UQID_WIDTH = 12;
parameter GEET_CXL_CACHE_RSPPRE_WIDTH = 2;
parameter GEET_CXL_CACHE_RSPDATA_WIDTH = 12;
parameter GEET_CXL_MEM_TAG_WIDTH = 16;
parameter GEET_CXL_MEM_TC_WIDTH = 16;

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

typedef enum {
  SHORT_DLY;
  MED_DLY;
  LONG_DLY;
} delay_type_t;

typedef struct {
  logic valid;
  d2h_req_opcode_t opcode;
  logic [GEET_CXL_ADDR_WIDTH-1:0] address;
  logic [GEET_CXL_CACHE_CQID_WIDTH-1:0] cqid;
  logic nt;
} d2h_req_txn_t;

typedef struct {
  logic valid;
  d2h_rsp_opcode_t opcode;
  logic [GEET_CXL_CACHE_UQID_WIDTH-1:0] uqid;
} d2h_rsp_txn_t;

typedef struct {
  logic valid;
  logic [GEET_CXL_CACHE_UQID_WIDTH-1:0] uqid;
  logic chunkvalid;
  logic bogus;
  logic poison;
  logic [GEET_CXL_DATA_WIDTH-1:0] data;
} d2h_data_txn_t;

typedef struct{
  logic [3:0] pending_data_slot;
  d2h_data_txn_t d2h_data_txn;
} d2h_data_pkt_t;

typedef struct {
  logic valid;
  h2d_req_opcode_t opcode;
  logic [GEET_CXL_ADDR_WIDTH-1:0] address;
  logic [GEET_CXL_CACHE_UQID_WIDTH-1:0] uqid;
} h2d_req_txn_t;

typedef struct {
  logic valid;
  h2d_rsp_opcode_t opcode;
  logic [11:0] rspdata;
  logic [1:0] rsppre;
  logic [GEET_CXL_CACHE_CQID_WIDTH-1:0] cqid;
} h2d_rsp_txn_t;

typedef struct {
  logic valid;
  logic [GEET_CXL_CACHE_CQID_WIDTH-1:0] cqid;
  logic chunkvalid;
  logic poison;
  logic goerr;
  logic [GEET_CXL_DATA_WIDTH-1:0] data;
} h2d_data_txn_t;

typedef struct{
  logic [3:0] pending_data_slot;
  h2d_data_txn_t h2d_data_txn;
} h2d_data_pkt_t;

typedef struct {
  logic valid;
  m2s_req_opcode_t memopcode;
  metafield_t metafield;
  metavalue_t metavalue;
  snptype_t snptype;
  logic [GEET_CXL_ADDR_WIDTH-1:0] address;
  logic [GEET_CXL_MEM_TAG_WIDTH-1:0] tag;
  logic [GEET_CXL_MEM_TC_WIDTH-1:0] tc;
} m2s_req_txn_t;

typedef struct {
  logic valid;
  m2s_rwd_opcode_t memopcode;
  metafield_tmetafield;
  metavalue_t metavalue;
  snptype_t snptype;
  logic [GEET_CXL_ADDR_WIDTH-1:0] address;
  logic [GEET_CXL_MEM_TAG_WIDTH-1:0] tag;
  logic [GEET_CXL_MEM_TC_WIDTH-1:0] tc;
  logic poison;
  logic [GEET_CXL_DATA_WIDTH-1:0] data;
} m2s_rwd_txn_t;

typedef struct{
  logic [3:0] pending_data_slot;
  m2s_rwd_txn_t m2s_rwd_txn;
} m2s_rwd_pkt_t;

typedef struct {
  logic valid;
  s2m_ndr_opcode_t opcode;
  metafield_t metafield;
  metavalue_t metavalue;
  logic [GEET_CXL_MEM_TAG_WIDTH-1:0] tag;
} s2m_ndr_txn_t;

typedef struct {
  logic valid;
  s2m_ndr_opcode_t opcode;
  metafield_t metafield;
  metavalue_t metavalue;
  logic [GEET_CXL_MEM_TAG_WIDTH-1:0] tag;
  logic poison;
  logic [GEET_CXL_DATA_WIDTH-1:0] data;
} s2m_drs_txn_t;

typedef struct{
  logic [3:0] pending_data_slot;
  s2m_drs_txn_t s2m_drs_txn;
} s2m_drs_pkt_t;

endpackage

import cxl_uvm_pkg::*;

interface cxl_cache_d2h_req_if(input logic clk);
  logic ready;
  logic rstn;
  d2h_req_txn_t d2h_req_txn;

  modport host_if_mp(
    input ready,
    input rstn,
    output d2h_req_txn
  );

  modport dev_if_mp(
    output ready,
    input rstn,
    input d2h_req_txn
  );

  modport dev_actv_drvr_mp(
    input ready,
    output rstn,
    output d2h_req_txn
  );

  modport host_pasv_drvr_mp(
    output ready,
    output rstn,
    input d2h_req_txn
  );

  modport mon(
    input ready,
    input rstn,
    input d2h_req_txn
  );

endinterface

interface cxl_cache_d2h_rsp_if(input logic clk);
  logic ready;
  logic rstn;
  d2h_rsp_txn_t d2h_rsp_txn;

  modport host_if_mp(
    input ready,
    input rstn,
    output d2h_rsp_txn
  );

  modport dev_if_mp(
    output ready,
    input rstn,
    input d2h_rsp_txn
  );

  modport dev_actv_drvr_mp(
    input ready,
    output rstn,
    output d2h_rsp_txn
  );

  modport host_pasv_drvr_mp(
    output ready,
    output rstn,
    input d2h_rsp_txn
  );

  modport mon(
    input ready,
    input rstn,
    input d2h_rsp_txn
  );

endinterface

interface cxl_cache_d2h_data_if(input logic clk);
  logic ready;
  logic rstn;
  d2h_data_txn_t d2h_data_txn;

  modport host_if_mp(
    input ready,
    input rstn,
    output d2h_data_txn
  );

  modport dev_if_mp(
    output ready,
    input rstn,
    input d2h_data_txn
  );

  modport dev_actv_drvr_mp(
    input ready,
    output rstn,
    output d2h_data_txn
  );

  modport host_pasv_drvr_mp(
    output ready,
    output rstn,
    input d2h_data_txn
  );

  modport mon(
    input ready,
    input rstn,
    input d2h_data_txn
  );

endinterface

interface cxl_cache_h2d_req_if(input logic clk);
  logic ready;
  logic rstn;
  h2d_req_txn_t h2d_req_txn;

  modport host_if_mp(
    output ready,
    input rstn,
    input h2d_req_txn
  );

  modport dev_if_mp(
    input ready,
    input rstn,
    output h2d_req_txn
  );

  modport host_actv_drvr_mp(
    input ready,
    output rstn,
    output h2d_req_txn
  );

  modport dev_pasv_drvr_mp(
    output ready,
    output rstn,
    input h2d_req_txn
  );

  modport mon(
    input ready,
    input rstn,
    input h2d_req_txn
  );

endinterface

interface cxl_cache_h2d_rsp_if(input logic clk);
  logic ready;
  logic rstn;
  h2d_rsp_txn_t h2d_rsp_txn;

  modport host_if_mp(
    output ready,
    input rstn,
    input h2d_rsp_txn
  );

  modport dev_if_mp(
    input ready,
    input rstn,
    output h2d_rsp_txn
  );

  modport host_actv_drvr_mp(
    input ready,
    output rstn,
    output h2d_rsp_txn
  );

  modport dev_pasv_drvr_mp(
    output ready,
    output rstn,
    input h2d_rsp_txn
  );

  modport mon(
    input ready,
    input rstn,
    input h2d_rsp_txn
  );

endinterface

interface cxl_cache_h2d_data_if(input logic clk);
  logic ready;
  logic rstn;
  h2d_data_txn_t h2d_data_txn;

  modport host_if_mp(
    output ready,
    input rstn,
    input h2d_data_txn
  );

  modport dev_if_mp(
    input ready,
    input rstn,
    output h2d_data_txn
  );

  modport host_actv_drvr_mp(
    input ready,
    output rstn,
    output h2d_data_txn
  );

  modport dev_pasv_drvr_mp(
    output ready,
    output rstn,
    input h2d_data_txn
  );

  modport mon(
    input ready,
    input rstn,
    input h2d_data_txn
  );

endinterface

interface cxl_mem_m2s_req_if(input logic clk);
  logic ready;
  logic rstn;
  m2s_req_txn_t m2s_req_txn;

  modport host_if_mp(
    output ready,
    input rstn,
    input m2s_req_txn
  );

  modport dev_if_mp(
    input ready,
    input rstn,
    output m2s_req_txn
  );

  modport host_actv_drvr_mp(
    input ready,
    output rstn,
    output m2s_req_txn
  );

  modport dev_pasv_drvr_mp(
    output ready,
    output rstn,
    input m2s_req_txn
  );

  modport mon(
    input ready,
    input rstn,
    input m2s_req_txn
  );

endinterface

interface cxl_mem_m2s_rwd_if(input logic clk);
  logic ready;
  logic rstn;
  m2s_rwd_txn_t m2s_rwd_txn;

  modport host_if_mp(
    output ready,
    input rstn,
    input m2s_rwd_txn
  );

  modport dev_if_mp(
    input ready,
    input rstn,
    output m2s_rwd_txn
  );

  modport host_actv_drvr_mp(
    input ready,
    output rstn,
    output m2s_rwd_txn
  );

  modport dev_actv_drvr_mp(
    output ready,
    output rstn,
    input m2s_rwd_txn
  );

  modport mon(
    input ready,
    input rstn,
    input m2s_rwd_txn
  );

endinterface

interface cxl_mem_s2m_ndr_if(input logic clk);
  logic ready;
  logic rstn;
  s2m_ndr_txn_t s2m_ndr_txn;

  modport host_if_mp(
    input ready,
    input rstn,
    output s2m_ndr_txn
  );

  modport dev_if_mp(
    output ready,
    input rstn,
    input s2m_ndr_txn
  );

  modport dev_actv_drvr_mp(
    input ready,
    output rstn,
    output s2m_ndr_txn
  );

  modport host_pasv_drvr_mp(
    output ready,
    output rstn,
    input s2m_ndr_txn
  );

  modport mon(
    input ready,
    input rstn,
    input s2m_ndr_txn
  );

endinterface

interface cxl_mem_s2m_drs_if(input logic clk);
  logic ready;
  logic rstn;
  s2m_drs_txn_t s2m_drs_txn;

  modport host_if_mp(
    input ready,
    input rstn,
    output s2m_drs_txn
  );

  modport dev_if_mp(
    output ready,
    input rstn,
    input s2m_drs_txn
  );

  modport dev_actv_drvr_mp(
    input ready,
    output rstn,
    output s2m_drs_txn
  );

  modport host_pasv_drvr_mp(
    output ready,
    output rstn,
    input s2m_drs_txn
  );

  modport mon(
    input ready,
    input rstn,
    input s2m_drs_txn
  );

endinterface

interface cxl_host_tx_dl_if(input logic dl_clk);
  logic dl_rstn;
  logic valid;
  logic [527:0] dl_data;

  modport tx_mp(
    input dl_rstn,
    output valid,
    output dl_data
  );

  modport mon(
    input dl_rstn,
    input valid,
    input dl_data
  );

endinterface

interface cxl_host_rx_dl_if(input logic dl_clk);
  logic dl_rstn;
  logic valid;
  logic [527:0] dl_data;

  modport rx_mp(
    input dl_rstn,
    input valid,
    input [527:0] dl_data
  );

  modport mon(
    input dl_rstn,
    input valid,
    input dl_data
  );

endinterface

interface cxl_dev_tx_dl_if(input logic dl_clk);
  logic dl_rstn;
  logic valid;
  logic [527:0] dl_data;

  modport tx_mp(
    input dl_rstn,
    output valid,
    output dl_data
  );

  modport mon(
    input dl_rstn,
    input valid,
    input dl_data
  );

endinterface

interface cxl_dev_rx_dl_if(input logic dl_clk);
  logic dl_rstn;
  logic valid;
  logic [527:0] dl_data;

  modport rx_mp(
    input dl_rstn,
    input valid,
    input dl_data
  );

  modport mon(
    input dl_rstn,
    input valid,
    input dl_data
  );

endinterface 

module rra#(
  parameter = NO_OF_REQ
)(
  input clk,
  input rstn,
  input [NO_OF_REQ-1:0] req,
  output [NO_OF_REQ-1:0] gnt
);

//implementation tbd

endmodule

module host_tx_path#(

)(
  input int h2d_req_occ,
  input int h2d_rsp_occ,
  input int h2d_data_occ,
  input int m2s_req_occ,
  input int m2s_rwd_occ,
  output logic h2d_req_rval,
  output logic h2d_req_drval,
  output logic h2d_req_qrval,
  output logic h2d_rsp_rval,
  output logic h2d_rsp_drval,
  output logic h2d_rsp_qrval,
  output logic h2d_data_rval,
  output logic h2d_data_drval,
  output logic h2d_data_qrval,
  output logic m2s_req_rval,
  output logic m2s_req_drval,
  output logic m2s_req_qrval,
  output logic m2s_rwd_rval,
  output logic m2s_rwd_drval,
  output logic m2s_rwd_qrval,
  input h2d_req_txn_t h2d_req_dataout,
  input h2d_req_txn_t h2d_req_ddataout,
  input h2d_req_txn_t h2d_req_qdataout,
  input h2d_rsp_txn_t h2d_rsp_dataout,
  input h2d_rsp_txn_t h2d_rsp_ddataout,
  input h2d_rsp_txn_t h2d_rsp_qdataout,
  input h2d_data_txn_t h2d_data_dataout,
  input h2d_data_txn_t h2d_data_ddataout,
  input h2d_data_txn_t h2d_data_qdataout,
  input m2s_req_txn_t m2s_req_dataout,
  input m2s_req_txn_t m2s_req_ddataout,
  input m2s_req_txn_t m2s_req_qdataout,
  input m2s_rwd_txn_t m2s_rwd_dataout,
  input m2s_rwd_txn_t m2s_rwd_ddataout,
  input m2s_rwd_txn_t m2s_rwd_qdataout,
  cxl_host_tx_dl_if.tx_mp host_tx_dl_if,
  cxl_host_rx_dl_if.rx_mp host_rx_dl_if
);
  localparam SLOT1_OFFSET = 128;
  localparam SLOT2_OFFSET = 256;
  localparam SLOT3_OFFSET = 384;
  logic [5:0] h_val;
  logic [5:0] h_req;
  logic [5:0] h_req;
  logic [5:0] h_gnt;
  logic [5:0] h_gnt_d;
  logic [5:0] g_val;
  logic [5:0] g_req;
  logic [6:0] g_gnt;
  logic [6:0] g_gnt_d;
  typedef enum {
    H_SLOT0 = 'h1,
    G_SLOT1 = 'h2,
    G_SLOT2 = 'h4,
    G_SLOT3 = 'h8
  } slot_sel_t;
  slot_sel_t slot_sel;
  slot_sel_t slot_sel_d;
  logic [2:0] holding_rdptr;
  logic [2:0] holding_wrptr;
  typedef struct {
    logic valid;
    logic [511:0] data;
  } holding_q_t;
  holding_q_t holding_q[6];

  ASSERT_ONEHOT_SLOT_SEL:assert property @(posedge clk) disable iff (!rstn) $onehot(slot_sel);

  assign h_val[0] = (h2d_req_occ > 0) && (h2d_rsp_occ > 0);
  assign h_val[1] = (h2d_data_occ > 0) && (h2d_rsp_occ > 1);
  assign h_val[2] = (h2d_req_occ > 0) && (h2d_data_occ > 0);
  assign h_val[3] = (h2d_data_occ > 3);
  assign h_val[4] = (m2s_rwd_occ > 0);
  assign h_val[5] = (m2s_req_occ > 0);
  assign g_val[1] = (h2d_rsp_occ > 3);
  assign g_val[2] = (h2d_req_occ > 0) && (h2d_data_occ > 0) && (h2d_rsp_occ > 0);
  assign g_val[3] = (h2d_data_occ > 3) && (h2d_rsp_occ > 0);
  assign g_val[4] = (m2s_req_occ > 0) && (h2d_data_occ > 0);
  assign g_val[5] = (m2s_rwd_occ > 0) && (h2d_rsp_occ > 0);

  assign h2d_req_rval   = (h_gnt[0] || h_gnt[2])? 'h1: 'h0;
  assign h2d_rsp_rval   = (h_gnt[0])? 'h1: 'h0;
  assign h2d_rsp_drval  = (h_gnt[1])? 'h1: 'h0;
  assign h2d_data_rval  = (h_gnt[1] || h_gnt[2])? 'h1: 'h0;
  assign h2d_data_drval = (h_gnt[3])? 'h1: 'h0;
  assign m2s_req_rval   = (h_gnt[5])? 'h1: 'h0;
  assign m2s_rwd_rval   = (h_gnt[4])? 'h1: 'h0;

  assign h2d_req_qrval  = (g_gnt[1])? 'h1: 'h0;
  assign h2d_req_rval   = (g_gnt[2])? 'h1: 'h0;
  assign h2d_data_rval  = (g_gnt[2] || g_gnt[4])? 'h1: 'h0;
  assign h2d_data_qrval = (g_gnt[3])? 'h1: 'h0;
  assign h2d_rsp_rval   = (g_gnt[2] || g_gnt[3] || g_gnt[5])? 'h1: 'h0;
  assign m2s_req_rval   = (g_gnt[4])? 'h1: 'h0;
  assign m2s_rwd_rval   = (g_gnt[5])? 'h1: 'h0;

  assign h_req = (slot_sel>1) ? 'h0: h_val;
  assign g_req = (slot_sel[0])? 'h0: g_val;
  //TODO: serious missing piece is if roll over cnt exceeds then packing of further data should be avoided
  //ll pkt buffer
  always@(posedge clk) begin
    if(!rstn) begin
      slot_sel <= H_SLOT0;
      slot_sel_d <= H_SLOT0;
      holding_wrptr <= 'h0;
    end else begin
      h_gnt_d <= h_gnt;
      g_gnt_d <= g_gnt;
      slot_sel_d <= slot_sel;
      case(slot_sel)
        H_SLOT0: begin
          if(h_gnt == 0) begin
            slot_sel <= H_SLOT0;
          end else begin
            slot_sel <= G_SLOT1;
          end
        end
        G_SLOT1: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT1;
          end else if(g_gnt[0]) begin
            slot_sel <= 'hX;
          end else begin
            slot_sel <= G_SLOT2;
          end
        end
        G_SLOT2: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT2;
          end else if(g_gnt[0]) begin
            slot_sel <= 'hX;
          end else begin
            slot_sel <= G_SLOT3;
          end
        end
        G_SLOT3: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT3;
          end else if(g_gnt[0]) begin
            slot_sel <= 'hX;
          end else begin
            slot_sel <= H_SLOT0;
          end
        end
        default: begin
            slot_sel <= 'hX;
        end 
      endcase
     //TODO: bug/major flaw in packing logic after data slot ends in slot0/1/2 then slots123/23/3 should not be packed currently you are just sending available pkts into these slots without header slot entry so receiver cannot decode these generic slots  
      if(!($stable(slot_sel))) begin
        case(slot_sel_d)
          H_SLOT0: begin
            case(h_gnt_d)
              'h1: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h0;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= h2d_req_dataout.valid;
                holding_q[holding_wrptr].data[35:33]    <= h2d_req_dataout.opcode;
                holding_q[holding_wrptr].data[81:36]    <= h2d_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[93:82]    <= h2d_req_dataout.uqid;
                holding_q[holding_wrptr].data[95:94]    <= 'h0;//spare bits are rsvd must be set to 0
                holding_q[holding_wrptr].data[96]       <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[100:97]   <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[112:101]  <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[114:113]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[126:115]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[127]      <= 'h0;//TBD: says sp not sure what it is must be spare 
                holding_q[holding_wrptr].valid          <= 'h0;
              end
              'h2: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h1;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[44:33]    <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[45]       <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[46]       <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[47]       <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[54:48]    <= h2d_data_dataout.
                holding_q[holding_wrptr].data[55]       <= 'h0;//spare bit always 0
                holding_q[holding_wrptr].data[56]       <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[60:57]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[72:61]    <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[74:73]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[86:75]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[87]       <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[88]       <= h2d_rsp_ddataout.valid;
                holding_q[holding_wrptr].data[92:89]    <= h2d_rsp_ddataout.opcode;
                holding_q[holding_wrptr].data[104:93]   <= h2d_rsp_ddataout.rspdata;
                holding_q[holding_wrptr].data[106:105]  <= h2d_rsp_ddataout.rsppre;
                holding_q[holding_wrptr].data[118:107]  <= h2d_rsp_ddataout.cqid;
                holding_q[holding_wrptr].data[119]      <= 'h0;
                holding_q[holding_wrptr].data[127:120]  <= 'h0;//rsvd always to 0
                holding_q[holding_wrptr].data[511:128]  <= h2d_data_dataout.data[383:0];
                holding_q[holding_wrptr].valid          <= 'h1;
                holding_q[holding_wrptr+1].data[127:0]  <= h2d_data_dataout.data[511:384];
                holding_q[holding_wrptr+1].valid        <= 'h0;
                holding_wrptr                           <= holding_wrptr + 1;
              end
              'h4: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h2;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= h2d_req_dataout.valid;
                holding_q[holding_wrptr].data[35:33]    <= h2d_req_dataout.opcode;
                holding_q[holding_wrptr].data[81:36]    <= h2d_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[93:82]    <= h2d_req_dataout.uqid;
                holding_q[holding_wrptr].data[95:94]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[96]       <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[108:97]   <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[109]      <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[110]      <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[111]      <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[118:112]  <= 'h0;//TBD: think it is typo there is no pre in d2h_data
                holding_q[holding_wrptr].data[119]      <= 'h0;// spare always 0
                holding_q[holding_wrptr].data[127:120]  <= 'h0;//rsvd always 0
                holding_q[holding_wrptr].data[511:128]  <= h2d_data_dataout.data[383:0];
                holding_q[holding_wrptr].valid          <= 'h1;
                holding_q[holding_wrptr+1].data[127:0]  <= h2d_data_dataout.data[511:384];
                holding_q[holding_wrptr+1].valid        <= 'h0;
                holding_wrptr                           <= holding_wrptr + 1;
              end
              'h8: begin
                holding_q[holding_wrptr].data[0]         <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]         <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]         <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]         <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]         <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]       <= 'h3;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]      <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]     <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]     <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]     <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]     <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]        <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[44:33]     <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[45]        <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[46]        <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[47]        <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[54:48]     <= 'h0;//TBD:says pre but I do not see any pre in h2d_data
                holding_q[holding_wrptr].data[55]        <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[56]        <= h2d_data_ddataout.valid;
                holding_q[holding_wrptr].data[68:57]     <= h2d_data_ddataout.cqid;
                holding_q[holding_wrptr].data[69]        <= h2d_data_ddataout.chunkvalid;
                holding_q[holding_wrptr].data[70]        <= h2d_data_ddataout.poison;
                holding_q[holding_wrptr].data[71]        <= h2d_data_ddataout.goerr;
                holding_q[holding_wrptr].data[78:72]     <= 'h0;//TBD: says pre but there is no pre in h2d_data
                holding_q[holding_wrptr].data[79]        <= 'h0;// spare always 0
                holding_q[holding_wrptr].data[80]        <= h2d_data_tdataout.valid;
                holding_q[holding_wrptr].data[92:81]     <= h2d_data_tdataout.cqid;
                holding_q[holding_wrptr].data[93]        <= h2d_data_tdataout.chunkvalid;
                holding_q[holding_wrptr].data[94]        <= h2d_data_tdataout.poison;
                holding_q[holding_wrptr].data[95]        <= h2d_data_tdataout.goerr;
                holding_q[holding_wrptr].data[102:96]    <= 'h0;//TBD:says pre but there is no pre in h2d_data
                holding_q[holding_wrptr].data[103]       <= 'h0;//spare bit always 0
                holding_q[holding_wrptr].data[104]       <= h2d_data_qdataout.valid;
                holding_q[holding_wrptr].data[116:105]   <= h2d_data_qdataout.cqid;
                holding_q[holding_wrptr].data[117]       <= h2d_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[118]       <= h2d_data_qdataout.poison;
                holding_q[holding_wrptr].data[119]       <= h2d_data_qdataout.goerr;
                holding_q[holding_wrptr].data[126:120]   <= 'h0;//TBD: says pre but there is no pre in h2d_data
                holding_q[holding_wrptr].data[127]       <= 'h0;
                holding_q[holding_wrptr].data[511:128]   <= h2d_data_dataout.data[383:0];
                holding_q[holding_wrptr].valid           <= 'h1;
                holding_q[holding_wrptr+1].data[127:0]   <= h2d_data_dataout.data[511:384];
                holding_q[holding_wrptr+1].data[511:384] <= h2d_data_ddataout.data[127:0];
                holding_q[holding_wrptr+1].valid         <= 'h1;
                holding_q[holding_wrptr+2].data[127:0]   <= h2d_data_ddataout.data[511:384];
                holding_q[holding_wrptr+2].data[511:384] <= h2d_data_tdataout.data[127:0];
                holding_q[holding_wrptr+2].valid         <= 'h1;
                holding_q[holding_wrptr+3].data[127:0]   <= h2d_data_tdataout.data[511:384];
                holding_q[holding_wrptr+3].data[511:384] <= h2d_data_qdataout.data[127:0];
                holding_q[holding_wrptr+3].valid         <= 'h1;
                holding_q[holding_wrptr+4].data[127:0]   <= h2d_data_qdataout.data[511:384];
                holding_q[holding_wrptr+4].valid         <= 'h0;
                holding_wrptr                            <= holding_wrptr + 4;
              end
              'h16: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h4;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= m2s_rwd_dataout.valid;
                holding_q[holding_wrptr].data[36:33]    <= m2s_rwd_dataout.memopcode;
                holding_q[holding_wrptr].data[39:37]    <= m2s_rwd_dataout.snptype;
                holding_q[holding_wrptr].data[41:40]    <= m2s_rwd_dataout.metafield;
                holding_q[holding_wrptr].data[43:42]    <= m2s_rwd_dataout.metavalue;
                holding_q[holding_wrptr].data[58:44]    <= m2s_rwd_dataout.tag;
                holding_q[holding_wrptr].data[105:59]   <= m2s_rwd_dataout.address[51:6];
                holding_q[holding_wrptr].data[106]      <= m2s_rwd_dataout.poison;
                holding_q[holding_wrptr].data[108:107]  <= m2s_rwd_dataout.tc;
                holding_q[holding_wrptr].data[118:109]  <= 'h0; //spare bit set to 0
                holding_q[holding_wrptr].data[127:119]  <= 'h0; // rsvd bits set tp 0
                holding_q[holding_wrptr].data[511:128]  <= m2s_rwd_dataout.data[383:0];
                holding_q[holding_wrptr].valid          <= 'h1;
                holding_q[holding_wrptr+1].data[127:0]  <= m2s_rwd_dataout.data[511:384];
                holding_q[holding_wrptr+1].valid        <= 'h0;
                holding_wrptr                           <= holding_wrptr + 1;
              end
              'h32: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h5;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= m2s_req_dataout.valid;
                holding_q[holding_wrptr].data[36:33]    <= m2s_req_dataout.memopcode;
                holding_q[holding_wrptr].data[39:37]    <= m2s_req_dataout.snptype;
                holding_q[holding_wrptr].data[41:40]    <= m2s_req_dataout.metafield;
                holding_q[holding_wrptr].data[43:42]    <= m2s_req_dataout.metavalue;
                holding_q[holding_wrptr].data[58:44]    <= m2s_req_dataout.tag;
                holding_q[holding_wrptr].data[106:59]   <= m2s_req_dataout.address[51:5];
                holding_q[holding_wrptr].data[108:107]  <= m2s_req_dataout.tc;
                holding_q[holding_wrptr].data[118:109]  <= 'h0; //spare bit set to 0
                holding_q[holding_wrptr].data[127:119]  <= 'h0; // rsvd bits set tp 0
                holding_q[holding_wrptr].valid          <= 'h0;
              end
              default: begin //TBD: do you want to keeep default to assign data pkt or want some other value
                holding_q[holding_wrptr].valid          <= 'h0;
              end
            endcase
          end
          G_SLOT1: begin
            case(g_gnt_d)
              'h2: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)]      <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+16):(SLOT1_OFFSET+5)]     <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+18):(SLOT1_OFFSET+17)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+30):(SLOT1_OFFSET+19)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+31)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+32)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+36):(SLOT1_OFFSET+33)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+48):(SLOT1_OFFSET+37)]    <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+50):(SLOT1_OFFSET+49)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+62):(SLOT1_OFFSET+51)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+64)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+68):(SLOT1_OFFSET+65)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+80):(SLOT1_OFFSET+69)]    <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+82):(SLOT1_OFFSET+81)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+94):(SLOT1_OFFSET+83)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+95)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+96)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+97)]   <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+112):(SLOT1_OFFSET+101)]  <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+114):(SLOT1_OFFSET+113)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+126):(SLOT1_OFFSET+115)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127)]                     <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
              'h4: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= h2d_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]      <= h2d_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+49):(SLOT1_OFFSET+4)]     <= h2d_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+61)+(SLOT1_OFFSET+50)]    <= h2d_req_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+62)]    <= 'h0; 
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+64)]                      <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+65)]    <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+77)]                      <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+78)]                      <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+79)]                      <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+86):(SLOT1_OFFSET+80)]    <= 'h0;//TBD:says pre but there is no pre in h2d_data
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+87)]                      <= 'h0;//spare always gets 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+88)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+92):(SLOT1_OFFSET+89)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+93)]   <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+106):(SLOT1_OFFSET+105)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+107)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+119)]                     <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+120)]  <= 'h0;//rsvd is 0
                holding_q[holding_wrptr].data[511:256]                                <= h2d_data_dataout.data[255:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[255:0]                                <= h2d_data_dataout.data[511:256];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h8: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+12):(SLOT1_OFFSET+1)]     <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+13)]                      <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+14)]                      <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+15)]                      <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+22):(SLOT1_OFFSET+16)]    <= 'h0;//TBD: says pre but do not have it in h2d_data
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+23)]                      <= 'h0; // spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+24)]                      <= h2d_data_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+36):(SLOT1_OFFSET+25)]    <= h2d_data_ddataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+37)]                      <= h2d_data_ddataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+38)]                      <= h2d_data_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+39)]                      <= h2d_data_ddataout.goerr;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+46):(SLOT1_OFFSET+40)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+47)]                      <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+48)]                      <= h2d_data_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+60):(SLOT1_OFFSET+49)]    <= h2d_data_tdataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+61)]                      <= h2d_data_tdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+62)]                      <= h2d_data_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63)]                      <= h2d_data_tdataout.goerr;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+70):(SLOT1_OFFSET+64)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+71)]                      <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+72)]                      <= h2d_data_qdataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+84):(SLOT1_OFFSET+73)]    <= h2d_data_qdataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+85)]                      <= h2d_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+86)]                      <= h2d_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+87)]                      <= h2d_data_qdataout.goerr;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+94):(SLOT1_OFFSET+88)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+95)]                      <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+96)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+97)]   <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+112):(SLOT1_OFFSET+101)]  <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+114):(SLOT1_OFFSET+113)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+126):(SLOT1_OFFSET+115)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127)]                     <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[511:256]                                <= h2d_data_dataout.data[255:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[255:0]                                <= h2d_data_dataout.data[511:256];
                holding_q[holding_wrptr+1].data[511:256]                              <= h2d_data_ddataout.data[255:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[255:0]                                <= h2d_data_ddataout.data[511:256];
                holding_q[holding_wrptr+2].data[511:256]                              <= h2d_data_tdataout.data[255:0];
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[255:0]                                <= h2d_data_tdataout.data[511:256];
                holding_q[holding_wrptr+3].data[511:256]                              <= h2d_data_qdataout.data[255:0];
                holding_q[holding_wrptr+3].valid                                      <= 'h1;
                holding_q[holding_wrptr+4].data[255:0]                                <= h2d_data_qataout.data[511:256];
                holding_q[holding_wrptr+4].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 4;
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= m2s_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)]      <= m2s_req_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+5)]      <= m2s_req_dataout.snptype;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+9):(SLOT1_OFFSET+8)]      <= m2s_req_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+11):(SLOT1_OFFSET+10)]    <= m2s_req_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+12)]    <= m2s_req_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+74):(SLOT1_OFFSET+28)]    <= m2s_req_dataout.address[51:5];
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+75)]    <= m2s_req_dataout.tc;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+86):(SLOT1_OFFSET+77)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+87)]                      <= 'h0; // rsvd always 0;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+88)]                      <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+89)]   <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+101)]                     <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+102)]                     <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+103)]                     <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+110):(SLOT1_OFFSET+104)]  <= 'h0;//pre is not defined in h2d_data
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+111)]                     <= 'h0;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+112)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:256]                                <= h2d_data_dataout.data[255:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[255:0]                                <= h2d_data_dataout.data[511:256];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= m2s_rwd_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)]      <= m2s_rwd_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+5)]      <= m2s_rwd_dataout.snptype;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+9):(SLOT1_OFFSET+8)]      <= m2s_rwd_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+11):(SLOT1_OFFSET+10)]    <= m2s_rwd_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+12)]    <= m2s_rwd_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+73):(SLOT1_OFFSET+28)]    <= m2s_rwd_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+74)]                      <= m2s_rwd_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+75)]    <= m2s_rwd_dataout.tc;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+86):(SLOT1_OFFSET+77)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+87)]                      <= 'h0; // rsvd always 0;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+88)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+92):(SLOT1_OFFSET+89)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+93)]   <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+106):(SLOT1_OFFSET+105)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+107)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+119)]                     <= 'h0;//spare bit always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+120)]  <= 'h0;//rsvd is always 0
                holding_q[holding_wrptr].data[511:256]                                <= m2s_rwd_dataout.data[255:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[255:0]                                <= m2s_rwd_dataout.data[511:256];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
          G_SLOT2: begin
            case(g_gnt_d)
              'h2: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)]      <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+16):(SLOT2_OFFSET+5)]     <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+18):(SLOT2_OFFSET+17)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+30):(SLOT2_OFFSET+19)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+31)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+32)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+36):(SLOT2_OFFSET+33)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+48):(SLOT2_OFFSET+37)]    <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+50):(SLOT2_OFFSET+49)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+62):(SLOT2_OFFSET+51)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+64)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+68):(SLOT2_OFFSET+65)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+80):(SLOT2_OFFSET+69)]    <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+82):(SLOT2_OFFSET+81)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+94):(SLOT2_OFFSET+83)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+95)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+96)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)]   <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)]  <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127)]                     <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
              'h4: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= h2d_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]      <= h2d_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+49):(SLOT2_OFFSET+4)]     <= h2d_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+61)+(SLOT2_OFFSET+50)]    <= h2d_req_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+62)]    <= 'h0; 
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+64)]                      <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+65)]    <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+77)]                      <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+78)]                      <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+79)]                      <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+86):(SLOT2_OFFSET+80)]    <= 'h0;//TBD:says pre but there is no pre in h2d_data
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+87)]                      <= 'h0;//spare always gets 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+88)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+92):(SLOT2_OFFSET+89)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+93)]   <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+106):(SLOT2_OFFSET+105)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+107)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+119)]                     <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+120)]  <= 'h0;//rsvd is 0
                holding_q[holding_wrptr].data[511:384]                                <= h2d_data_dataout.data[127:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[383:0]                                <= h2d_data_dataout.data[511:128];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h8: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+12):(SLOT2_OFFSET+1)]     <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+13)]                      <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+14)]                      <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+15)]                      <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+22):(SLOT2_OFFSET+16)]    <= 'h0;//TBD: says pre but do not have it in h2d_data
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+23)]                      <= 'h0; // spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+24)]                      <= h2d_data_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+36):(SLOT2_OFFSET+25)]    <= h2d_data_ddataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+37)]                      <= h2d_data_ddataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+38)]                      <= h2d_data_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+39)]                      <= h2d_data_ddataout.goerr;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+46):(SLOT2_OFFSET+40)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+47)]                      <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+48)]                      <= h2d_data_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+60):(SLOT2_OFFSET+49)]    <= h2d_data_tdataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+61)]                      <= h2d_data_tdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+62)]                      <= h2d_data_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63)]                      <= h2d_data_tdataout.goerr;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+70):(SLOT2_OFFSET+64)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+71)]                      <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+72)]                      <= h2d_data_qdataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+84):(SLOT2_OFFSET+73)]    <= h2d_data_qdataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+85)]                      <= h2d_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+86)]                      <= h2d_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+87)]                      <= h2d_data_qdataout.goerr;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+94):(SLOT2_OFFSET+88)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+95)]                      <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+96)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)]   <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)]  <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127)]                     <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[511:384]                                <= h2d_data_dataout.data[127:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[383:0]                                <= h2d_data_dataout.data[511:128];
                holding_q[holding_wrptr+1].data[511:384]                              <= h2d_data_ddataout.data[127:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[383:0]                                <= h2d_data_ddataout.data[511:128];
                holding_q[holding_wrptr+2].data[511:384]                              <= h2d_data_tdataout.data[127:0];
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[383:0]                                <= h2d_data_tdataout.data[511:128];
                holding_q[holding_wrptr+3].data[511:384]                              <= h2d_data_qdataout.data[127:0];
                holding_q[holding_wrptr+3].valid                                      <= 'h1;
                holding_q[holding_wrptr+4].data[383:0]                                <= h2d_data_qataout.data[511:128];
                holding_q[holding_wrptr+4].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 4;
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= m2s_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)]      <= m2s_req_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+5)]      <= m2s_req_dataout.snptype;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+9):(SLOT2_OFFSET+8)]      <= m2s_req_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+11):(SLOT2_OFFSET+10)]    <= m2s_req_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+12)]    <= m2s_req_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+74):(SLOT2_OFFSET+28)]    <= m2s_req_dataout.address[51:5];
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+75)]    <= m2s_req_dataout.tc;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+86):(SLOT2_OFFSET+77)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+87)]                      <= 'h0; // rsvd always 0;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+88)]                      <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+89)]   <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+101)]                     <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+102)]                     <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+103)]                     <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+110):(SLOT2_OFFSET+104)]  <= 'h0;//pre is not defined in h2d_data
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+111)]                     <= 'h0;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+112)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:384]                                <= h2d_data_dataout.data[127:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[383:0]                                <= h2d_data_dataout.data[511:128];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= m2s_rwd_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)]      <= m2s_rwd_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+5)]      <= m2s_rwd_dataout.snptype;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+9):(SLOT2_OFFSET+8)]      <= m2s_rwd_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+11):(SLOT2_OFFSET+10)]    <= m2s_rwd_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+12)]    <= m2s_rwd_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+73):(SLOT2_OFFSET+28)]    <= m2s_rwd_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+74)]                      <= m2s_rwd_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+75)]    <= m2s_rwd_dataout.tc;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+86):(SLOT2_OFFSET+77)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+87)]                      <= 'h0; // rsvd always 0;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+88)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+92):(SLOT2_OFFSET+89)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+93)]   <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+106):(SLOT2_OFFSET+105)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+107)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+119)]                     <= 'h0;//spare bit always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+120)]  <= 'h0;//rsvd is always 0
                holding_q[holding_wrptr].data[511:384]                                <= m2s_rwd_dataout.data[127:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[383:0]                                <= m2s_rwd_dataout.data[511:128];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
          G_SLOT3: begin
            case(g_gnt_d)
              'h2: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)]      <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+16):(SLOT3_OFFSET+5)]     <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+18):(SLOT3_OFFSET+17)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+30):(SLOT3_OFFSET+19)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+31)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+32)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+36):(SLOT3_OFFSET+33)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+48):(SLOT3_OFFSET+37)]    <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+50):(SLOT3_OFFSET+49)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+62):(SLOT3_OFFSET+51)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+64)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+68):(SLOT3_OFFSET+65)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+80):(SLOT3_OFFSET+69)]    <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+82):(SLOT3_OFFSET+81)]    <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+94):(SLOT3_OFFSET+83)]    <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+95)]                      <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+96)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+100):(SLOT3_OFFSET+97)]   <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+112):(SLOT3_OFFSET+101)]  <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+114):(SLOT3_OFFSET+113)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+126):(SLOT3_OFFSET+115)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127)]                     <= 'h0; // spare bits always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h4: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= h2d_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]      <= h2d_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+49):(SLOT3_OFFSET+4)]     <= h2d_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+61)+(SLOT3_OFFSET+50)]    <= h2d_req_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+62)]    <= 'h0; 
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+64)]                      <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+65)]    <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+77)]                      <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+78)]                      <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+79)]                      <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+86):(SLOT3_OFFSET+80)]    <= 'h0;//TBD:says pre but there is no pre in h2d_data
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+87)]                      <= 'h0;//spare always gets 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+88)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+92):(SLOT3_OFFSET+89)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+93)]   <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+106):(SLOT3_OFFSET+105)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+107)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+119)]                     <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+120)]  <= 'h0;//rsvd is 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[511:0]                                <= h2d_data_dataout.data[511:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 2;
              end
              'h8: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+12):(SLOT3_OFFSET+1)]     <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+13)]                      <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+14)]                      <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+15)]                      <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+22):(SLOT3_OFFSET+16)]    <= 'h0;//TBD: says pre but do not have it in h2d_data
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+23)]                      <= 'h0; // spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+24)]                      <= h2d_data_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+36):(SLOT3_OFFSET+25)]    <= h2d_data_ddataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+37)]                      <= h2d_data_ddataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+38)]                      <= h2d_data_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+39)]                      <= h2d_data_ddataout.goerr;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+46):(SLOT3_OFFSET+40)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+47)]                      <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+48)]                      <= h2d_data_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+60):(SLOT3_OFFSET+49)]    <= h2d_data_tdataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+61)]                      <= h2d_data_tdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+62)]                      <= h2d_data_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63)]                      <= h2d_data_tdataout.goerr;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+70):(SLOT3_OFFSET+64)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+71)]                      <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+72)]                      <= h2d_data_qdataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+84):(SLOT3_OFFSET+73)]    <= h2d_data_qdataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+85)]                      <= h2d_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+86)]                      <= h2d_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+87)]                      <= h2d_data_qdataout.goerr;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+94):(SLOT3_OFFSET+88)]    <= 'h0;//TBD: says pre but there is no field in h2d_data
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+95)] <= 'h0;//spare always tied to 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+96)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+100):(SLOT3_OFFSET+97)]   <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+112):(SLOT3_OFFSET+101)]  <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+114):(SLOT3_OFFSET+113)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+126):(SLOT3_OFFSET+115)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127)]                     <= 'h0;//spare always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[511:0]                                <= h2d_data_dataout.data[511:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[511:0]                                <= h2d_data_ddataout.data[511:0];
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[511:0]                                <= h2d_data_tdataout.data[511:0];
                holding_q[holding_wrptr+3].valid                                      <= 'h1;
                holding_q[holding_wrptr+4].data[511:0]                                <= h2d_data_qdataout.data[511:0];
                holding_q[holding_wrptr+4].valid                                      <= 'h1;
                holding_q[holding_wrptr+5].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 5;
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= m2s_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)]      <= m2s_req_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+5)]      <= m2s_req_dataout.snptype;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+9):(SLOT3_OFFSET+8)]      <= m2s_req_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+11):(SLOT3_OFFSET+10)]    <= m2s_req_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+12)]    <= m2s_req_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+74):(SLOT3_OFFSET+28)]    <= m2s_req_dataout.address[51:5];
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+75)]    <= m2s_req_dataout.tc;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+86):(SLOT3_OFFSET+77)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+87)]                      <= 'h0; // rsvd always 0;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+88)]                      <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+100):(SLOT3_OFFSET+89)]   <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+101)]                     <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+102)]                     <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+103)]                     <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+110):(SLOT3_OFFSET+104)]  <= 'h0;//pre is not defined in h2d_data
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+111)]                     <= 'h0;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+112)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[511:0]                                <= h2d_data_dataout.data[511:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 2;
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= m2s_rwd_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)]      <= m2s_rwd_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+5)]      <= m2s_rwd_dataout.snptype;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+9):(SLOT3_OFFSET+8)]      <= m2s_rwd_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+11):(SLOT3_OFFSET+10)]    <= m2s_rwd_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+12)]    <= m2s_rwd_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+73):(SLOT3_OFFSET+28)]    <= m2s_rwd_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+74)]                      <= m2s_rwd_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+75)]    <= m2s_rwd_dataout.tc;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+86):(SLOT3_OFFSET+77)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+87)]                      <= 'h0; // rsvd always 0;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+88)]                      <= h2d_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+92):(SLOT3_OFFSET+89)]    <= h2d_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+93)]   <= h2d_rsp_dataout.rspdata;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+106):(SLOT3_OFFSET+105)]  <= h2d_rsp_dataout.rsppre;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+107)]  <= h2d_rsp_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+119)]                     <= 'h0;//spare bit always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+120)]  <= 'h0;//rsvd is always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[511:0]                                <= m2s_rwd_dataout.data[511:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 2;
              end
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
        endcase
      end
    end
  end

  always@(host_tx_dl_if.clk) begin
    if(!host_tx_dl_if.rstn) begin
      host_tx_dl_if.valid <= 'h0;
      host_tx_dl_if.data <= 'h0;
      holding_rdptr <= 'h0;
    end else begin
      if(holding_q.valid[holding_rdptr]) begin
        host_tx_dl_if.valid <= holding_q.valid[holding_rdptr];
        host_tx_dl_if.data <= holding_q.data[holding_rdptr];
        if(holding_rdptr == 4) begin
          holding_rdptr <= 'h0;
        end else begin
          holding_rdptr <= holding_rdptr + 1;
        end
      end
   end
  end

  rra h_slot_rra_inst#(

  )(
    .clk(clk),
    .rstn(rstn),
    .req(h_req),
    .gnt(h_gnt)
  );

  rra g_slot_rra_inst#(

  )(
    .clk(clk),
    .rstn(rstn),
    .req(g_req),
    .gnt(g_gnt)
  );

endmodule

module device_tx_path#(

)(
  input int d2h_req_occ,
  input int d2h_rsp_occ,
  input int d2h_data_occ,
  input int s2m_ndr_occ,
  input int s2m_drs_occ,
  output logic d2h_req_rval,
  output logic d2h_req_drval,
  output logic d2h_req_trval,
  output logic d2h_req_qrval,
  output logic d2h_rsp_rval,
  output logic d2h_rsp_drval,
  output logic d2h_rsp_trval,
  output logic d2h_rsp_qrval,
  output logic d2h_data_rval,
  output logic d2h_data_drval,
  output logic d2h_data_trval,
  output logic d2h_data_qrval,
  output logic s2m_ndr_rval,
  output logic s2m_ndr_drval,
  output logic s2m_ndr_trval,
  output logic s2m_ndr_qrval,
  output logic s2m_drs_rval,
  output logic s2m_drs_drval,  
  output logic s2m_drs_trval,  
  output logic s2m_drs_qrval,
  input d2h_req_txn_t d2h_req_dataout,
  input d2h_req_txn_t d2h_req_ddataout,
  input d2h_req_txn_t d2h_req_tdataout,
  input d2h_req_txn_t d2h_req_qdataout,
  input d2h_rsp_txn_t d2h_rsp_dataout,
  input d2h_rsp_txn_t d2h_rsp_ddataout,
  input d2h_rsp_txn_t d2h_rsp_tdataout,
  input d2h_rsp_txn_t d2h_rsp_qdataout,
  input d2h_data_txn_t d2h_data_dataout,
  input d2h_data_txn_t d2h_data_ddataout,
  input d2h_data_txn_t d2h_data_tdataout,
  input d2h_data_txn_t d2h_data_qdataout,
  input s2m_ndr_txn_t s2m_ndr_dataout,
  input s2m_ndr_txn_t s2m_ndr_ddataout,
  input s2m_ndr_txn_t s2m_ndr_tdataout,
  input s2m_ndr_txn_t s2m_ndr_qdataout,
  input s2m_drs_txn_t s2m_drs_dataout,
  input s2m_drs_txn_t s2m_drs_ddataout,
  input s2m_drs_txn_t s2m_drs_tdataout,
  input s2m_drs_txn_t s2m_drs_qdataout,
  cxl_dev_tx_dl_if.tx_mp dev_tx_dl_if,
  cxl_dev_rx_dl_if.rx_mp dev_rx_dl_if
);

  logic [5:0] h_val;
  logic [5:0] h_req;
  logic [5:0] h_gnt;
  logic [5:0] h_gnt_d;
  logic [6:0] g_val;
  logic [6:0] g_req;
  logic [6:0] g_gnt;
  logic [6:0] g_gnt_d;
  typedef enum {
    H_SLOT0 = 'h1,
    G_SLOT1 = 'h2,
    G_SLOT2 = 'h4,
    G_SLOT3 = 'h8
  } slot_sel_t;
  slot_sel_t slot_sel;
  slot_sel_t slot_sel_d;
  logic [2:0] holding_rdptr;
  logic [2:0] holding_wrptr;
  typedef struct {
    logic valid;
    logic [511:0] data;
  } holding_q_t;
  holding_q_t holding_q[6];

  assign h_val[0] = (d2h_data_occ > 0) && (d2h_rsp_occ > 1);
  assign h_val[1] = (d2h_req_occ >0) && (d2h_data_occ > 0);
  assign h_val[2] = (d2h_data_occ > 3) && (d2h_rsp_occ > 0);
  assign h_val[3] = (s2m_drs_occ > 0) && (s2m_ndr_occ > 0);
  assign h_val[4] = (s2m_ndr_occ > 1);
  assign h_val[5] = (s2m_drs_occ > 1);
  assign g_val[1] = (d2h_req_occ > 0) && (d2h_rsp_occ > 1);
  assign g_val[2] = (d2h_req_occ > 0) && (d2h_data_occ > 0) && (d2h_rsp_occ > 0);
  assign g_val[3] = (d2h_data_occ > 4);
  assign g_val[4] = (s2m_drs_occ > 0) && (s2m_ndr_occ > 1);
  assign g_val[5] = (s2m_ndr_occ > 2);
  assign g_val[6] = (s2m_drs_occ > 2);

  ASSERT_ONEHOT_SLOT_SEL:assert property @(posedge clk) disable iff (!rstn) $onehot(slot_sel);
  
  assign h_req = (slot_sel>1)? 'h0: h_val;
  assign g_req = (slot_sel[0])? 'h0: g_val;
  //TODO: assignment of slot number is missing in the header of pkt after generic slot is selected 
  //TODO: serious missing piece is if roll over cnt exceeds then packing of further data should be avoided
  //ll pkt buffer
  always@(posedge clk) begin
    if(!rstn) begin
      slot_sel <= H_SLOT0;
      slot_sel_d <= H_SLOT0;
      holding_wrptr <= 'h0;
    end else begin
      h_gnt_d <= h_gnt;
      g_gnt_d <= g_gnt;
      slot_sel_d <= slot_sel;
      case(slot_sel)
        H_SLOT0: begin
          if(h_gnt == 0) begin
            slot_sel <= H_SLOT0;
          end else begin
            slot_sel <= G_SLOT1;
          end
        end
        G_SLOT1: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT1;
          end else if(g_gnt[0]) begin
            slot_sel <= 'hX;
          end else begin
            slot_sel <= G_SLOT2;
          end
        end
        G_SLOT2: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT2;
          end else if(g_gnt[0]) begin
            slot_sel <= 'hX;
          end else begin
            slot_sel <= G_SLOT3;
          end
        end
        G_SLOT3: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT3;
          end else if(g_gnt[0]) begin
            slot_sel <= 'hX;
          end else begin
            slot_sel <= H_SLOT0;
          end
        end
        default: begin
            slot_sel = 'hX;
        end 
      endcase
      
      if(!($stable(slot_sel))) begin
        case(slot_sel_d)
          H_SLOT0: begin
            case(h_gnt_d)
              'h1: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h0;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[44:33]    <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[45]       <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[46]       <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[47]       <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[48]       <= 'h0;//spare bit is always 0
                holding_q[holding_wrptr].data[49]       <= d2h_rsp_dataout.valid;
                holding_q[holding_wrptr].data[54:50]    <= d2h_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[66:55]    <= d2h_rsp_dataout.uqid;
                holding_q[holding_wrptr].data[68:67]    <= 'h0; //spare bit is always 0
                holding_q[holding_wrptr].data[69]       <= d2h_rsp_ddataout.valid;
                holding_q[holding_wrptr].data[74:70]    <= d2h_rsp_ddataout.opcode;
                holding_q[holding_wrptr].data[86:75]    <= d2h_rsp_ddataout.uqid;
                holding_q[holding_wrptr].data[88:87]    <= 'h0;//spare bit always 0
                holding_q[holding_wrptr].data[89]       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[92:90]    <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[94:93]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[96:95]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[112:97]   <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[116:113]  <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[127:117]  <= 'h0;//rsvd always 0
                holding_q[holding_wrptr].data[511:128]  <= d2h_data_dataout.data[383:0];
                holding_q[holding_wrptr].valid          <= 'h1;
                holding_wrptr                           <= holding_wrptr + 1;
                holding_q[holding_wrptr+1].data[127:0]  <= d2h_data_dataout.data[511:384];
                holding_q[holding_wrptr+1].valid        <= 'h0;
              end
              'h2: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h1;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= d2h_req_dataout.valid;
                holding_q[holding_wrptr].data[37:33]    <= d2h_req_dataout.opcode;
                holding_q[holding_wrptr].data[49:38]    <= d2h_req_dataout.cqid;
                holding_q[holding_wrptr].data[50]       <= d2h_req_dataout.nt;
                holding_q[holding_wrptr].data[57:51]    <= 'h0;//spare always is 0
                holding_q[holding_wrptr].data[103:58]   <= d2h_req_dataout.address;
                holding_q[holding_wrptr].data[110:104]  <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[111]      <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[123:112]  <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[124]      <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[125]      <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[126]      <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[127]      <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[511:128]  <= d2h_data_dataout.data[383:0];
                holding_q[holding_wrptr].valid          <= 'h1;
                holding_wrptr                           <= holding_wrptr + 1;
                holding_q[holding_wrptr+1].data[127:0]  <= d2h_data_dataout.data[511:384];
                holding_q[holding_wrptr+1].valid        <= 'h0;
              end
              'h4: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h2;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[44:33]    <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[45]       <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[46]       <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[47]       <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[48]       <= 'h0;//spare bit is always 0
                holding_q[holding_wrptr].data[49]       <= d2h_data_ddataout.valid;
                holding_q[holding_wrptr].data[61:50]    <= d2h_data_ddataout.uqid;
                holding_q[holding_wrptr].data[62]       <= d2h_data_ddataout.chunkvalid;
                holding_q[holding_wrptr].data[63]       <= d2h_data_ddataout.bogus;
                holding_q[holding_wrptr].data[64]       <= d2h_data_ddataout.poison;
                holding_q[holding_wrptr].data[65]       <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[66]       <= d2h_data_tdataout.valid;
                holding_q[holding_wrptr].data[78:67]    <= d2h_data_tdataout.uqid;
                holding_q[holding_wrptr].data[79]       <= d2h_data_tdataout.chunkvalid;
                holding_q[holding_wrptr].data[80]       <= d2h_data_tdataout.bogus;
                holding_q[holding_wrptr].data[81]       <= d2h_data_tdataout.poison;
                holding_q[holding_wrptr].data[82]       <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[83]       <= d2h_data_qdataout.valid;
                holding_q[holding_wrptr].data[95:84]    <= d2h_data_qdataout.uqid;
                holding_q[holding_wrptr].data[96]       <= d2h_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[97]       <= d2h_data_qdataout.bogus;
                holding_q[holding_wrptr].data[98]       <= d2h_data_qdataout.poison;
                holding_q[holding_wrptr].data[99]       <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[100]      <= d2h_rsp_dataout.valid;
                holding_q[holding_wrptr].data[105:101]  <= d2h_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[117:106]  <= d2h_rsp_dataout.uqid;
                holding_q[holding_wrptr].data[119:118]  <= 'h0; //spare bits always 0
                holding_q[holding_wrptr].data[127:120]  <= 'h0;//rsvd bits always 0
                holding_q[holding_wrptr].data[511:128]  <= d2h_data_dataout.data[383:0];
                holding_q[holding_wrptr].valid          <= 'h1;
                holding_wrptr                           <= holding_wrptr + 4;
                holding_q[holding_wrptr+1].data[127:0]  <= d2h_data_dataout.data[511:384];
                holding_q[holding_wrptr+1].data[511:128]<= d2h_data_ddataout.data[383:0];
                holding_q[holding_wrptr+1].valid        <= 'h1;
                holding_q[holding_wrptr+2].data[127:0]  <= d2h_data_ddataout.data[511:384];
                holding_q[holding_wrptr+2].data[511:128]<= d2h_data_tdataout.data[383:0];
                holding_q[holding_wrptr+2].valid        <= 'h1;
                holding_q[holding_wrptr+3].data[127:0]  <= d2h_data_tdataout.data[511:384];
                holding_q[holding_wrptr+3].data[511:128]<= d2h_data_qdataout.data[383:0];
                holding_q[holding_wrptr+3].valid        <= 'h1;
                holding_q[holding_wrptr+4].data[127:0]  <= d2h_data_qdataout.data[511:384];
                holding_q[holding_wrptr+4].valid        <= 'h0;
              end
              'h8: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h3;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[35:33]    <= s2m_drs_dataout.memopcode;
                holding_q[holding_wrptr].data[37:36]    <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[39:38]    <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[55:40]    <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[56]       <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[71:57]    <= 'h0;// spare bits always 0
                holding_q[holding_wrptr].data[72]       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[75:73]    <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[77:76]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[79:78]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[95:80]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[99:96]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[127:100]  <= 'h0;//rsvd bits always 0
                holding_q[holding_wrptr].data[511:128]  <= s2m_drs_dataout.data[383:0];
                holding_q[holding_wrptr].valid          <= 'h1;
                holding_wrptr                           <= holding_wrptr + 1;
                holding_q[holding_wrptr+1].data[127:0]  <= s2m_drs_dataout.data[511:384];
                holding_q[holding_wrptr+1].valid        <= 'h0;
              end
              'h16: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h4;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[35:33]    <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[37:36]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[39:38]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[55:40]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[59:56]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[60]       <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[63:61]    <= s2m_ndr_ddataout.memopcode;
                holding_q[holding_wrptr].data[65:64]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[67:66]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[83:68]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[87:84]    <= 'h0;//spare are always 0
                holding_q[holding_wrptr].data[127:88]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid          <= 'h0;
              end
              'h32: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= 'h0;//TBD: logic for crdt ack to be added later
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h5;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[35:33]    <= s2m_drs_dataout.memopcode;
                holding_q[holding_wrptr].data[37:36]    <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[39:38]    <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[55:40]    <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[56]       <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[71:57]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[72]       <= s2m_drs_ddataout.valid;
                holding_q[holding_wrptr].data[75:73]    <= s2m_drs_ddataout.memopcode;
                holding_q[holding_wrptr].data[77:76]    <= s2m_drs_ddataout.metafield;
                holding_q[holding_wrptr].data[79:78]    <= s2m_drs_ddataout.metavalue;
                holding_q[holding_wrptr].data[95:80]    <= s2m_drs_ddataout.tag;
                holding_q[holding_wrptr].data[96]       <= s2m_drs_ddataout.poison;
                holding_q[holding_wrptr].data[111:97]   <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[127:112]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:128]  <= s2m_drs_dataout.data[383:0];
                holding_q[holding_wrptr].valid          <= 'h1;
                holding_q[holding_wrptr+1].data[127:0]  <= s2m_drs_dataout.data[511:384];
                holding_q[holding_wrptr+1].data[511:128]<= s2m_drs_ddataout.data[383:0];
                holding_q[holding_wrptr+1].valid        <= 'h1;
                holding_wrptr                           <= holding_wrptr + 2;
                holding_q[holding_wrptr+2].valid        <= 'h0;
                holding_q[holding_wrptr+2].data[127:0]  <= s2m_drs_ddataout.data[511:384];
              end
              default: begin
                holding_q[holding_wrptr].valid          <= 'h0;
              end
            endcase
          end
          G_SLOT1: begin
            case(g_gnt_d)
              'h2: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= d2h_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+1)]      <= d2h_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+17):(SLOT1_OFFSET+6)]     <= d2h_req_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+18)]                      <= d2h_req_dataout.nt;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+25):(SLOT1_OFFSET+19)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+26)]    <= d2h_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+78):(SLOT1_OFFSET+72)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+79)]                      <= d2h_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+84):(SLOT1_OFFSET+80)]    <= d2h_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+96):(SLOT1_OFFSET+85)]    <= d2h_rsp_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+98):(SLOT1_OFFSET+97)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+99)]                      <= d2h_rsp_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+100)]  <= d2h_rsp_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+116):(SLOT1_OFFSET+105)]  <= d2h_rsp_ddataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+117)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+119)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
              'h4: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= d2h_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+1)]      <= d2h_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+17):(SLOT1_OFFSET+6)]     <= d2h_req_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+18)]                      <= d2h_req_dataout.nt;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+25):(SLOT1_OFFSET+19)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+26)]    <= d2h_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+78):(SLOT1_OFFSET+72)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+79)]                      <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+91):(SLOT1_OFFSET+80)]    <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+92)]                      <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+93)]                      <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+94)]                      <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+95)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+96)]                      <= d2h_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+101):(SLOT1_OFFSET+97)]   <= d2h_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+113):(SLOT1_OFFSET+102)]  <= d2h_rsp_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+115):(SLOT1_OFFSET+114)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+116)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:256]                                <= d2h_data_dataout.data[255:0]
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_wrptr                                                         <= holding_wrptr + 1;
                holding_q[holding_wrptr].data[255:0]                                  <= d2h_data_dataout.data[511:256]
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end  
              'h8: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+12):(SLOT1_OFFSET+1)]     <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+13)]                      <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+14)]                      <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+15)]                      <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+16)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+17)]                      <= d2h_data_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+29):(SLOT1_OFFSET+18)]    <= d2h_data_ddataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+30)]                      <= d2h_data_ddataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+31)]                      <= d2h_data_ddataout.bogus;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+32)]                      <= d2h_data_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+33)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+34)]                      <= d2h_data_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+46):(SLOT1_OFFSET+35)]    <= d2h_data_tdataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+47)]                      <= d2h_data_tdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+48)]                      <= d2h_data_tdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+49)]                      <= d2h_data_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+50)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+51)]                      <= d2h_data_qdataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+52)]    <= d2h_data_qdataout,uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+64)]                      <= d2h_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+65)]                      <= d2h_data_qdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+66)]                      <= d2h_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+67)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+68)]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:256]                                <= d2h_data_dataout.data[255:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[255:0]                                <= d2h_data_dataout.data[511:256];
                holding_q[holding_wrptr+1].data[511:256]                              <= d2h_data_ddataout.data[255:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[255:0]                                <= d2h_data_ddataout.data[511:256];
                holding_q[holding_wrptr+2].data[511:256]                              <= d2h_data_tdataout.data[255:0];
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[255:0]                                <= d2h_data_tdataout.data[511:256];
                holding_q[holding_wrptr+3].data[511:256]                              <= d2h_data_qdataout.data[255:0];
                holding_q[holding_wrptr+3].valid                                      <= 'h1;
                holding_q[holding_wrptr+4].data[255:0]                                <= d2h_data_qataout.data[511:256];
                holding_q[holding_wrptr+4].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 4;
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]      <= s2m_drs_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]      <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+39):(SLOT1_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+40)]                      <= s2m_ndr_dataout.valid; 
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+43):(SLOT1_OFFSET+41)]    <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+45):(SLOT1_OFFSET+44)]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+47):(SLOT1_OFFSET+46)]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+48)]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+67):(SLOT1_OFFSET+64)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+68)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+69)]    <= s2m_ndr_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+73):(SLOT1_OFFSET+72)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+75):(SLOT1_OFFSET+74)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+91):(SLOT1_OFFSET+76)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+95):(SLOT1_OFFSET+92)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+96)]   <= 'h0;
                holding_q[holding_wrptr].data[511:256]                                <= s2m_drs_dataout.data[255:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[255:0]                                <= s2m_drs_dataout.data[511:256];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]      <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]      <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]      <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)]     <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+24)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+28)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+31):(SLOT1_OFFSET+29)]    <= s2m_ndr_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+33):(SLOT1_OFFSET+32)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+35):(SLOT1_OFFSET+34)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+51):(SLOT1_OFFSET+36)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+55):(SLOT1_OFFSET+52)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+56)]                      <= s2m_ndr_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+59):(SLOT1_OFFSET+57)]    <= s2m_ndr_tdataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+61):(SLOT1_OFFSET+60)]    <= s2m_ndr_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+62)]    <= s2m_ndr_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+79):(SLOT1_OFFSET+64)]    <= s2m_ndr_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+83):(SLOT1_OFFSET+80)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+84)]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
              'h64: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]      <= s2m_drs_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]      <=  s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+39):(SLOT1_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+40)]                      <= s2m_drs_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+43):(SLOT1_OFFSET+41)]    <= s2m_drs_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+45):(SLOT1_OFFSET+44)]    <= s2m_drs_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+47):(SLOT1_OFFSET+46)]    <= s2m_drs_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+48)]    <= s2m_drs_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+64)]                      <= s2m_drs_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+79):(SLOT1_OFFSET+65)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+80)] <= s2m_drs_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+83):(SLOT1_OFFSET+81)]    <= s2m_drs_tdataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+85):(SLOT1_OFFSET+84)]    <= s2m_drs_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+87):(SLOT1_OFFSET+86)]    <= s2m_drs_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+103):(SLOT1_OFFSET+88)]   <= s2m_drs_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+104)]                     <= s2m_drs_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+119):(SLOT1_OFFSET+105)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+120)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:256]                                <= s2m_drs_dataout.data[255:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[255:0]                                <= s2m_drs_dataout.data[511:256];
                holding_q[holding_wrptr+1].data[511:256]                              <= s2m_drs_ddataout.data[255:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[255:0]                                <= s2m_drs_ddataout.data[511:256];
                holding_q[holding_wrptr+2].data[511:256]                              <= s2m_drs_tdataout.data[255:0];
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[255:0]                                <= s2m_drs_tdataout.data[511:256];
                holding_q[holding_wrptr+3].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 3;
              end          
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
          G_SLOT2: begin
            case(g_gnt_d)    
              'h2: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= d2h_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+1)]      <= d2h_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+17):(SLOT2_OFFSET+6)]     <= d2h_req_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+18)]                      <= d2h_req_dataout.nt;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+25):(SLOT2_OFFSET+19)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+26)]    <= d2h_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+78):(SLOT2_OFFSET+72)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+79)]                      <= d2h_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+84):(SLOT2_OFFSET+80)]    <= d2h_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+96):(SLOT2_OFFSET+85)]    <= d2h_rsp_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+98):(SLOT2_OFFSET+97)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+99)]                      <= d2h_rsp_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+100)]  <= d2h_rsp_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+116):(SLOT2_OFFSET+105)]  <= d2h_rsp_ddataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+117)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+119)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
              'h4: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= d2h_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+1)]      <= d2h_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+17):(SLOT2_OFFSET+6)]     <= d2h_req_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+18)]                      <= d2h_req_dataout.nt;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+25):(SLOT2_OFFSET+19)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+26)]    <= d2h_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+78):(SLOT2_OFFSET+72)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+79)]                      <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+91):(SLOT2_OFFSET+80)]    <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+92)]                      <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+93)]                      <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+94)]                      <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+95)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+96)]                      <= d2h_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+101):(SLOT2_OFFSET+97)]   <= d2h_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+113):(SLOT2_OFFSET+102)]  <= d2h_rsp_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+115):(SLOT2_OFFSET+114)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+116)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:384]                                <= d2h_data_dataout.data[127:0]
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_wrptr                                                         <= holding_wrptr + 1;
                holding_q[holding_wrptr+1].data[383:0]                                <= d2h_data_dataout.data[511:128]
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
              end  
              'h8: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+12):(SLOT2_OFFSET+1)]     <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+13)]                      <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+14)]                      <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+15)]                      <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+16)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+17)]                      <= d2h_data_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+29):(SLOT2_OFFSET+18)]    <= d2h_data_ddataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+30)]                      <= d2h_data_ddataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+31)]                      <= d2h_data_ddataout.bogus;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+32)]                      <= d2h_data_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+33)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+34)]                      <= d2h_data_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+46):(SLOT2_OFFSET+35)]    <= d2h_data_tdataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+47)]                      <= d2h_data_tdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+48)]                      <= d2h_data_tdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+49)]                      <= d2h_data_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+50)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+51)]                      <= d2h_data_qdataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+52)]    <= d2h_data_qdataout,uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+64)]                      <= d2h_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+65)]                      <= d2h_data_qdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+66)]                      <= d2h_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+67)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+68)]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:384]                                <= d2h_data_dataout.data[127:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[383:0]                                <= d2h_data_dataout.[511:128];
                holding_q[holding_wrptr+1].data[511:384]                              <= d2h_data_ddataout.data[127:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[383:0]                                <= d2h_data_ddataout.[511:128];
                holding_q[holding_wrptr+2].data[511:384]                              <= d2h_data_tdataout.data[127:0];
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[383:0]                                <= d2h_data_tdataout.[511:128];
                holding_q[holding_wrptr+3].data[511:384]                              <= d2h_data_qdataout.data[127:0];
                holding_q[holding_wrptr+3].valid                                      <= 'h1;
                holding_q[holding_wrptr+4].data[383:0]                                <= d2h_data_qdataout.[511:128];
                holding_q[holding_wrptr+4].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 4;
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]      <= s2m_drs_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]      <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+39):(SLOT2_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+40)]                      <= s2m_ndr_dataout.valid; 
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+43):(SLOT2_OFFSET+41)]    <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+45):(SLOT2_OFFSET+44)]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+47):(SLOT2_OFFSET+46)]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+48)]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+67):(SLOT2_OFFSET+64)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+68)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+69)]    <= s2m_ndr_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+73):(SLOT2_OFFSET+72)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+75):(SLOT2_OFFSET+74)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+91):(SLOT2_OFFSET+76)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+95):(SLOT2_OFFSET+92)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+96)]   <= 'h0;
                holding_q[holding_wrptr].data[511:384]                                <= s2m_drs_dataout.data[127:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[383:0]                                <= s2m_drs_dataout.data[511:128];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]      <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]      <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]      <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)]     <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+24)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+28)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+31):(SLOT2_OFFSET+29)]    <= s2m_ndr_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+33):(SLOT2_OFFSET+32)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+35):(SLOT2_OFFSET+34)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+51):(SLOT2_OFFSET+36)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+55):(SLOT2_OFFSET+52)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+56)]                      <= s2m_ndr_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+59):(SLOT2_OFFSET+57)]    <= s2m_ndr_tdataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+61):(SLOT2_OFFSET+60)]    <= s2m_ndr_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+62)]    <= s2m_ndr_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+79):(SLOT2_OFFSET+64)]    <= s2m_ndr_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+83):(SLOT2_OFFSET+80)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+84)]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
              'h64: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]      <= s2m_drs_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]      <=  s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+39):(SLOT2_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+40)]                      <= s2m_drs_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+43):(SLOT2_OFFSET+41)]    <= s2m_drs_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+45):(SLOT2_OFFSET+44)]    <= s2m_drs_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+47):(SLOT2_OFFSET+46)]    <= s2m_drs_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+48)]    <= s2m_drs_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+64)]                      <= s2m_drs_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+79):(SLOT2_OFFSET+65)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+80)] <= s2m_drs_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+83):(SLOT2_OFFSET+81)]    <= s2m_drs_tdataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+85):(SLOT2_OFFSET+84)]    <= s2m_drs_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+87):(SLOT2_OFFSET+86)]    <= s2m_drs_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+103):(SLOT2_OFFSET+88)]   <= s2m_drs_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+104)]                     <= s2m_drs_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+119):(SLOT2_OFFSET+105)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+120)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].data[511:384]                                <= s2m_drs_dataout.data[127:0];
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[383:0]                                <= s2m_drs_dataout.data[511:128];
                holding_q[holding_wrptr+1].data[511:384]                              <= s2m_drs_ddataout.data[127:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[383:0]                                <= s2m_drs_ddataout.data[511:128];
                holding_q[holding_wrptr+2].data[511:384]                              <= s2m_drs_tdataout.data[127:0];
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[383:0]                                <= s2m_drs_tdataout.data[511:128];
                holding_q[holding_wrptr+3].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 3;
              end   
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
          G_SLOT3: begin
            case(g_gnt_d)
              'h2: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= d2h_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+1)]      <= d2h_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+17):(SLOT3_OFFSET+6)]     <= d2h_req_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+18)]                      <= d2h_req_dataout.nt;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+25):(SLOT3_OFFSET+19)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+26)]    <= d2h_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+78):(SLOT3_OFFSET+72)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+79)]                      <= d2h_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+84):(SLOT3_OFFSET+80)]    <= d2h_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+96):(SLOT3_OFFSET+85)]    <= d2h_rsp_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+98):(SLOT3_OFFSET+97)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+99)]                      <= d2h_rsp_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+100)]  <= d2h_rsp_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+116):(SLOT3_OFFSET+105)]  <= d2h_rsp_ddataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+117)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+119)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h4: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= d2h_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+1)]      <= d2h_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+17):(SLOT3_OFFSET+6)]     <= d2h_req_dataout.cqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+18)]                      <= d2h_req_dataout.nt;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+25):(SLOT3_OFFSET+19)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+26)]    <= d2h_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+78):(SLOT3_OFFSET+72)]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+79)]                      <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+91):(SLOT3_OFFSET+80)]    <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+92)]                      <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+93)]                      <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+94)]                      <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+95)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+96)]                      <= d2h_rsp_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+101):(SLOT3_OFFSET+97)]   <= d2h_rsp_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+113):(SLOT3_OFFSET+102)]  <= d2h_rsp_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+115):(SLOT3_OFFSET+114)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+116)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[511:0]                                <= d2h_data_dataout.data[511:0]
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_wrptr                                                         <= holding_wrptr + 2;
                holding_q[holding_wrptr+2].valid                                      <= 'h0;
              end  
              'h8: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= d2h_data_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+12):(SLOT3_OFFSET+1)]     <= d2h_data_dataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+13)]                      <= d2h_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+14)]                      <= d2h_data_dataout.bogus;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+15)]                      <= d2h_data_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+16)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+17)]                      <= d2h_data_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+29):(SLOT3_OFFSET+18)]    <= d2h_data_ddataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+30)]                      <= d2h_data_ddataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+31)]                      <= d2h_data_ddataout.bogus;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+32)]                      <= d2h_data_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+33)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+34)]                      <= d2h_data_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+46):(SLOT3_OFFSET+35)]    <= d2h_data_tdataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+47)]                      <= d2h_data_tdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+48)]                      <= d2h_data_tdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+49)]                      <= d2h_data_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+50)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+51)]                      <= d2h_data_qdataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+52)]    <= d2h_data_qdataout,uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+64)]                      <= d2h_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+65)]                      <= d2h_data_qdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+66)]                      <= d2h_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+67)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+68)]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[511:0]                                <= d2h_data_dataout.data;
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[511:0]                                <= d2h_data_ddataout.data;
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[511:0]                                <= d2h_data_tdataout.data;
                holding_q[holding_wrptr+3].valid                                      <= 'h1;
                holding_q[holding_wrptr+4].data[511:0]                                <= d2h_data_qdataout.data;
                holding_q[holding_wrptr+4].valid                                      <= 'h1;
                //holding_q[holding_wrptr+5].valid                                      <= 'h0;
                //holding_wrptr                                                         <= holding_wrptr + 5;
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]      <= s2m_drs_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]      <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+39):(SLOT3_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+40)]                      <= s2m_ndr_dataout.valid; 
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+43):(SLOT3_OFFSET+41)]    <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+45):(SLOT3_OFFSET+44)]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+47):(SLOT3_OFFSET+46)]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+48)]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+67):(SLOT3_OFFSET+64)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+68)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+69)]    <= s2m_ndr_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+73):(SLOT3_OFFSET+72)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+75):(SLOT3_OFFSET+74)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+91):(SLOT3_OFFSET+76)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+95):(SLOT3_OFFSET+92)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+96)]   <= 'h0;
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[511:0]                                <= s2m_drs_dataout.data[511:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 2;
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]      <= s2m_ndr_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]      <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]      <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)]     <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+24)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+28)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+31):(SLOT3_OFFSET+29)]    <= s2m_ndr_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+33):(SLOT3_OFFSET+32)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+35):(SLOT3_OFFSET+34)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+51):(SLOT3_OFFSET+36)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+55):(SLOT3_OFFSET+52)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+56)]                      <= s2m_ndr_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+59):(SLOT3_OFFSET+57)]    <= s2m_ndr_tdataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+61):(SLOT3_OFFSET+60)]    <= s2m_ndr_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+62)]    <= s2m_ndr_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+79):(SLOT3_OFFSET+64)]    <= s2m_ndr_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+83):(SLOT3_OFFSET+80)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+84)]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_wrptr                                                         <= holding_wrptr + 1;
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
              end
              'h64: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]      <= s2m_drs_dataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]      <=  s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+39):(SLOT3_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+40)]                      <= s2m_drs_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+43):(SLOT3_OFFSET+41)]    <= s2m_drs_ddataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+45):(SLOT3_OFFSET+44)]    <= s2m_drs_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+47):(SLOT3_OFFSET+46)]    <= s2m_drs_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+48)]    <= s2m_drs_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+64)]                      <= s2m_drs_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+79):(SLOT3_OFFSET+65)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+80)] <= s2m_drs_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+83):(SLOT3_OFFSET+81)]    <= s2m_drs_tdataout.memopcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+85):(SLOT3_OFFSET+84)]    <= s2m_drs_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+87):(SLOT3_OFFSET+86)]    <= s2m_drs_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+103):(SLOT3_OFFSET+88)]   <= s2m_drs_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+104)]                     <= s2m_drs_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+119):(SLOT3_OFFSET+105)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+120)]  <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h1;
                holding_q[holding_wrptr+1].data[511:0]                                <= s2m_drs_dataout.data[511:0];
                holding_q[holding_wrptr+1].valid                                      <= 'h1;
                holding_q[holding_wrptr+2].data[511:0]                                <= s2m_drs_ddataout.data[511:0];
                holding_q[holding_wrptr+2].valid                                      <= 'h1;
                holding_q[holding_wrptr+3].data[511:0]                                <= s2m_drs_tdataout.data[511:0];
                holding_q[holding_wrptr+3].valid                                      <= 'h1;
                holding_wrptr                                                         <= holding_wrptr + 4;
                holding_q[holding_wrptr+4].valid                                      <= 'h0;
              end   
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
        endcase
      end
    end
  end

  always@(dev_tx_dl_if.clk) begin
    if(!dev_tx_dl_if.rstn) begin
      dev_tx_dl_if.valid <= 'h0;
      dev_tx_dl_if.data <= 'h0;
      holding_rdptr <= 'h0;
    end else begin
      if(holding_q.valid[holding_rdptr]) begin
        dev_tx_dl_if.valid <= holding_q.valid[holding_rdptr];
        dev_tx_dl_if.data <= holding_q.data[holding_rdptr];
        if(holding_rdptr == 4) begin
          holding_rdptr <= 'h0;
        end else begin
          holding_rdptr <= holding_rdptr + 1;
        end
      end
    end
  end

  rra h_slot_rra_inst#(

  )(
    .clk(clk),
    .rstn(rstn),
    .req(h_req),
    .gnt(h_gnt)
  );

  rra g_slot_rra_inst#(

  )(
    .clk(clk),
    .rstn(rstn),
    .req(g_req),
    .gnt(g_gnt)
  );

endmodule

module cxl_lrsm_rrsm(
  input logic clk,
  input logic rstn,
  input logic crc_pass,
  input logic crc_fail,
  input logic retryable_flit,
  input logic non_retryable_flit,
  input logic retry_req_rcvd,
  input logic phy_rst,
  input logic phy_reinit,
  output logic phy_link_rst,
  output logic retry_req_snt,
  input logic phy_link_up,
  input logic [7:0] retry_ack_num_retry,
  input logic retry_ack_empty_bit,
  input logic retry_ack_rcvd,
  output logic retry_ack_snt
);
  
  typedef enum {
  	RETRY_LOCAL_NORMAL,
    RETRY_LLRREQ,
    RETRY_PHY_REINIT,
    RETRY_LOCAL_IDLE,
    RETRY_ABORT
  } l_states_t;
  l_states_t l_states;
  
  typedef enum {
    RETRY_REMOTE_NORMAL,
    RETRY_LLRACK
  } r_states_t;
  r_states_t r_states;
  
  logic [7:0] local_num_free_buf;
  logic [7:0] local_eseq_num;
  logic [7:0] local_num_ack;
  logic [3:0] local_num_retry;
  logic [3:0] local_num_phy_reinit;
  logic [11:0] ack_timer;
  
  //lrsm
  always@(posedge clk) begin
    if(!rstn) begin
      l_states <= RETRY_LOCAL_NORMAL;
      local_num_free_buf <= {8{1'b1}};
      local_num_ack <= 'h0;
      local_eseq_num <= 'h0;
      local_num_retry <= 'h0;
      local_num_phy_reinit <= 'h0;
  	  phy_link_rst <= 'h0;    
      retry_req_snt <= 'h0;
    end else begin
      case(l_states)
		RETRY_LOCAL_NORMAL: begin
          if(crc_pass && retryable_flit) begin 
        	l_states <= RETRY_LOCAL_NORMAL;
            local_num_free_buf <= local_num_free_buf + 1;
            local_num_ack <= local_num_ack + 1;
            local_eseq_num <= local_eseq_num + 1;
            local_num_retry <= 'h0;
            local_num_phy_reinit <= 'h0;
          end else if(crc_pass && non_retryable_flit) begin
        	l_states <= RETRY_LOCAL_NORMAL;
          end else if(crc_fail && non_retryable_flit) begin
            l_states <= RETRY_LLRREQ;
          end else if(phy_rst || phy_reinit) begin
            l_states <= RETRY_PHY_REINIT;
          end
        end
        RETRY_LLRREQ: begin
          if((local_num_retry == 'hf) && (local_num_phy_reinit == 'hf)) begin
            l_states <= RETRY_ABORT;
          end else if((local_num_retry == 'hf) && (local_num_phy_reinit < 'hf)) begin
            l_states <= RETRY_PHY_REINIT;
            local_num_phy_reinit <= local_num_phy_reinit + 1;
            phy_link_rst <= 'h1;
          end else if((local_num_retry < 'hf) && (!retry_req_snt)) begin
            l_states <= RETRY_LLRREQ;
          end else if((local_num_retry < 'hf) && retry_req_snt) begin
            l_states <= RETRY_LOCAL_IDLE;
            local_num_retry <= local_num_retry + 1;
          end else if(crc_fail) begin
            l_states <= RETRY_LLRREQ;
          end else if(phy_rst || phy_reinit) begin
            l_states <= RETRY_PHY_REINIT;
          end
        end
        RETRY_PHY_REINIT: begin
          if(phy_link_up) begin
            l_states <= RETRY_LLRREQ;
            local_num_retry <= 'h0;
          end
        end
        RETRY_LOCAL_IDLE: begin
          if(retry_ack_rcvd && (retry_ack_num_retry == local_num_retry)) begin
            l_states <= RETRY_LOCAL_NORMAL;
            ack_timer <='h0;
            if(retry_ack_empty_bit) begin
              local_num_retry <= 'h0;
              local_num_phy_retry <= 'h0;
            end
          end else if(retry_ack_rcvd && (retry_ack_num_retry != local_num_retry)) begin
            l_states <= RETRY_LOCAL_IDLE;
            ack_timer <= ack_timer + 1;
          end else if(ack_timer == 'hfff) begin
            l_states <= RETRY_LLRREQ;
            ack_timer <='h0;
          end else if(phy_rst || phy_reinit) begin
            l_states <= RETRY_PHY_REINIT;
          end else begin
            l_states <= RETRY_LOCAL_IDLE;
            ack_timer <= ack_timer + 1;
          end
        end
        RETRY_ABORT: begin
          l_states <= RETRY_ABORT;
        end
        default: begin
          l_states <= 'hx;
        end
      endcase	
    end
  end

  //rrsm
  always@(posedge clk) begin
    if(!rstn) begin
      retry_ack_snt <= 'h0;
    end else begin
      case(r_states)
      RETRY_REMOTE_NORMAL: begin
        if(crc_pass && !retry_req_rcvd) begin
          r_states <= RETRY_REMOTE_NORMAL;
        end else if(crc_pass && retry_req_rcvd) begin
          r_states <= RETRY_LLRACK;
        end
      end
      RETRY_LLRACK: begin
        if((!retry_ack_snt) && (!phy_rst) && (!phy_reinit)) begin
          r_states <= RETRY_LLRACK;
        end else if(retry_ack_snt || phy_rst || phy_reinit) begin
          r_states <= RETRY_REMOTE_NORMAL
        end
      end
      default: begin
        r_states <= 'hx;
      end
      endcase
    end
  end
  
  //retry req/ack snt logic tbd
  
endmodule

module c2c_checker#(

)(
  output logic crc_pass,
  output logic c2c_fail,
  cxl_host_rx_dl_if.rx_mp host_rx_dl_if
);



endmodule

module host_rx_path #(

)(
  cxl_host_rx_dl_if.rx_mp host_rx_dl_if,
  output logic retry_ack_snt,
  output logic retry_req_snt,
  output logic phy_link_rst,
  input logic phy_rst,
  input logic phy_reinit,
  input logic phy_link_up
  output d2h_req_txn_t d2h_req_pkt,
  output d2h_rsp_txn_t d2h_rsp_pkt,
  output d2h_data_pkt_t d2h_data_pkt,
  output s2m_ndr_txn_t s2m_ndr_pkt,
  output s2m_drs_pkt_t s2m_drs_pkt
);

  typedef enum {
    RETRY_NOFRAME,
    RETRY_FRAME1,
    RETRY_FRAME2,
    RETRY_FRAME3,
    RETRY_FRAME4,
    RETRY_FRAME5
  } retry_frame_states_t;
  retry_frame_states_t retry_frame_states;
  logic crc_pass;
  logic crc_fail;
  logic retryable_flit;
  logic non_retryable_flit;
  logic retry_req_rcvd;
  logic retry_req_snt;
  logic [7:0] retry_ack_num_retry;
  logic retry_ack_empty_bit;
  logic retry_ack_rcvd;
  logic retry_ack_snt;
  cxl_host_rx_dl_if.rx_mp host_rx_dl_if_d;//assuming crc checker takes 1 cycle to tell crc pass or fail
  logic retry_frame_detect;
  logic retry_req_detect;
  logic retry_ack_detect;
  logic retry_idle_detect;
  logic data_slot[5];
  logic data_slot_d[5];
  d2h_data_pkt_t d2h_data_pkt_d[4];
  s2m_drs_pkt_t s2m_drs_pkt_d[3];
  logic [1:0] d2h_req_ptr;
  logic [1:0] d2h_rsp_ptr;
  logic [1:0] d2h_data_ptr;
  logic [1:0] s2m_ndr_ptr;
  logic [1:0] s2m_drs_ptr;

  function void header0(
    input logic [511:0] data, 
    output d2h_data_pkt_t d2h_data_pkt, 
    output d2h_rsp_txn_t d2h_rsp_txn[2], 
    output s2m_ndr_txn_t s2m_ndr_txn
  );

    d2h_data_pkt.pending_data_slot          = 'hf;
    d2h_data_pkt.d2h_data_txn.valid         = data[32];
    d2h_data_pkt.d2h_data_txn.uqid          = data[44:33];
    d2h_data_pkt.d2h_data_txn.chunkvalid    = data[45];
    d2h_data_pkt.d2h_data_txn.bogus         = data[46];
    d2h_data_pkt.d2h_data_txn.poison        = data[47];
    d2h_rsp_txn[0].valid                    = data[49];
    d2h_rsp_txn[0].opcode                   = data[54:50];
    d2h_rsp_txn[0].uqid                     = data[66:55];
    d2h_rsp_txn[1].valid                    = data[69];
    d2h_rsp_txn[1].opcode                   = data[74:70];
    d2h_rsp_txn[1].uqid                     = data[86:75];
    s2m_ndr_txn.valid                       = data[89];
    s2m_ndr_txn.memopcode                   = data[92:90];
    s2m_ndr_txn.metafield                   = data[94:93];
    s2m_ndr_txn.metavalue                   = data[96:95];
    s2m_ndr_txn.tag                         = data[112:97];

  endfunction

  function void header1(
    input logic [511:0] data, 
    output d2h_req_txn_t d2h_req_txn, 
    output d2h_data_pkt_t d2h_data_pkt
  );

    d2h_req_txn.valid                     = data[32];
    d2h_req_txn.opcode                    = data[37:33];
    d2h_req_txn.cqid                      = data[49:38];
    d2h_req_txn.nt                        = data[50];
    d2h_req_txn.address                   = data[103:58];
    d2h_data_pkt.pending_data_slot        = 'hf;
    d2h_data_pkt.d2h_data_txn.valid       = data[111];
    d2h_data_pkt.d2h_data_txn.uqid        = data[123:112];
    d2h_data_pkt.d2h_data_txn.chunkvalid  = data[124];
    d2h_data_pkt.d2h_data_txn.bogus       = data[125];
    d2h_data_pkt.d2h_data_txn.poison      = data[126];

  endfunction

  function void header2(
    input logic [511:0] data, 
    output d2h_data_pkt_t d2h_data_pkt[4], 
    output d2h_rsp_txn_t d2h_rsp_txn
  );

    d2h_data_pkt[0].pending_data_slot        = 'hf;
    d2h_data_pkt[0].d2h_data_txn.valid       = data[32];
    d2h_data_pkt[0].d2h_data_txn.uqid        = data[44:33];
    d2h_data_pkt[0].d2h_data_txn.chunkvalid  = data[45];
    d2h_data_pkt[0].d2h_data_txn.bogus       = data[46];
    d2h_data_pkt[0].d2h_data_txn.poison      = data[47];
    d2h_data_pkt[1].pending_data_slot        = 'hf
    d2h_data_pkt[1].d2h_data_txn.valid       = data[49];
    d2h_data_pkt[1].d2h_data_txn.uqid        = data[61:50];
    d2h_data_pkt[1].d2h_data_txn.chunkvalid  = data[62];
    d2h_data_pkt[1].d2h_data_txn.bogus       = data[63];
    d2h_data_pkt[1].d2h_data_txn.poison      = data[64];
    d2h_data_pkt[2].pending_data_slot        = 'hf
    d2h_data_pkt[2].d2h_data_txn.valid       = data[66];
    d2h_data_pkt[2].d2h_data_txn.uqid        = data[78:67];
    d2h_data_pkt[2].d2h_data_txn.chunkvalid  = data[79];
    d2h_data_pkt[2].d2h_data_txn.bogus       = data[80];
    d2h_data_pkt[2].d2h_data_txn.poison      = data[81];
    d2h_data_pkt[3].pending_data_slot        = 'hf
    d2h_data_pkt[3].d2h_data_txn.valid       = data[83];
    d2h_data_pkt[3].d2h_data_txn.uqid        = data[95:84];
    d2h_data_pkt[3].d2h_data_txn.chunkvalid  = data[96];
    d2h_data_pkt[3].d2h_data_txn.bogus       = data[97];
    d2h_data_pkt[3].d2h_data_txn.poison      = data[98];
    d2h_rsp_txn.valid                        = data[100];
    d2h_rsp_txn.opcode                       = data[105:101];
    d2h_rsp_txn.uqid                         = data[117:106];

  endfunction

  function void header3(
    input logic [511:0] data, 
    output s2m_drs_pkt_t s2m_drs_pkt, 
    output s2m_ndr_txn_t s2m_ndr_txn
  );

    s2m_drs_pkt.pending_data_slot        = 'hf;
    s2m_drs_pkt.s2m_drs_txn.valid        = data[32];
    s2m_drs_pkt.s2m_drs_txn.memopcode    = data[35:33];
    s2m_drs_pkt.s2m_drs_txn.metafield    = data[37:36];
    s2m_drs_pkt.s2m_drs_txn.metavalue    = data[39:38];
    s2m_drs_pkt.s2m_drs_txn.tag          = data[55:40];
    s2m_drs_pkt.s2m_drs_txn.poison       = data[56];
    s2m_ndr_txn.valid                    = data[72];
    s2m_ndr_txn.memopcode                = data[75:73];
    s2m_ndr_txn.metafield                = data[77:76];
    s2m_ndr_txn.metavalue                = data[79:78];
    s2m_ndr_txn.tag                      = data[95:80];

  endfunction

  function void header4(
    input logic [511:0] data, 
    output s2m_ndr_txn_t s2m_ndr_txn[2]
  );

    s2m_ndr_txn[0].valid        = data[32];
    s2m_ndr_txn[0].memopcode    = data[35:33];
    s2m_ndr_txn[0].metafield    = data[37:36];
    s2m_ndr_txn[0].metavalue    = data[39:38];
    s2m_ndr_txn[0].tag          = data[55:40];
    s2m_ndr_txn[1].valid        = data[60];
    s2m_ndr_txn[1].memopcode    = data[63:61];
    s2m_ndr_txn[1].metafield    = data[65:64];
    s2m_ndr_txn[1].metavalue    = data[67:66];
    s2m_ndr_txn[1].tag          = data[83:68];

  endfunction

  function void header5(
    input logic [511:0] data, 
    output s2m_drs_pkt_t s2m_drs_pkt[2]
  );

    s2m_drs_pkt[0].pending_data_slot        = 'hf;
    s2m_drs_pkt[0].s2m_drs_txn.valid        = data[32];
    s2m_drs_pkt[0].s2m_drs_txn.memopcode    = data[35:33];
    s2m_drs_pkt[0].s2m_drs_txn.metafield    = data[37:36];
    s2m_drs_pkt[0].s2m_drs_txn.metavalue    = data[39:38];
    s2m_drs_pkt[0].s2m_drs_txn.tag          = data[55:40];
    s2m_drs_pkt[0].s2m_drs_txn.poison       = data[56];
    s2m_drs_pkt[1].pending_data_slot        = 'hf;
    s2m_drs_pkt[1].s2m_drs_txn.valid        = data[72];
    s2m_drs_pkt[1].s2m_drs_txn.memopcode    = data[75:73];
    s2m_drs_pkt[1].s2m_drs_txn.metafield    = data[77:76];
    s2m_drs_pkt[1].s2m_drs_txn.metavalue    = data[79:78];
    s2m_drs_pkt[1].s2m_drs_txn.tag          = data[95:80];
    s2m_drs_pkt[1].s2m_drs_txn.poison       = data[96];

  endfunction

  function void generic0(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    inout d2h_req_pkt_t d2h_data_pkt[4],
    inout s2m_drs_pkt_t s2m_drs_pkt[4]
  );
    
    if(s2m_drs_pkt[0].pending_data_slot == 'hf) begin
      if(slot_sel == 1) begin
        s2m_drs_pkt[0].s2m_drs_txn.data[SLOT3_OFFSET-1:0] = data[SLOT3_OFFSET-1:0]; 
        s2m_drs_pkt[0].pending_data_slot = 'h8;
      end else if(slot_sel == 2) begin
        s2m_drs_pkt[0].s2m_drs_txn.data[SLOT2_OFFSET-1:0] = data[SLOT2_OFFSET-1:0]; 
        s2m_drs_pkt[0].pending_data_slot = 'hc;
      end else if(slot_sel == 3) begin
        s2m_drs_pkt[0].s2m_drs_txn.data[SLOT1_OFFSET-1:0] = data[SLOT1_OFFSET-1:0]; 
        s2m_drs_pkt[0].pending_data_slot = 'he;
      end else if(slot_sel == 0) begin
        s2m_drs_pkt[0].s2m_drs_txn.data = data; 
        s2m_drs_pkt[0].pending_data_slot = 'h0;
      end 
    end else if(s2m_drs_pkt[0].pending_data_slot == 'he) begin
      s2m_drs_pkt[0].s2m_drs_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]; 
      s2m_drs_pkt[0].pending_data_slot = 'h0;
      if(s2m_drs_pkt[1].pending_data_slot != 0) begin
        s2m_drs_pkt[1].s2m_drs_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
        s2m_drs_pkt[1].pending_data_slot = 'he;
      end
    end else if(s2m_drs_pkt[0].pending_data_slot == 'hc) begin
      s2m_drs_pkt[0].s2m_drs_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]; 
      s2m_drs_pkt[0].pending_data_slot = 'h0;
      if(s2m_drs_pkt[1].pending_data_slot != 0) begin
        s2m_drs_pkt[1].s2m_drs_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
        s2m_drs_pkt[1].pending_data_slot = 'hc;
      end
    end else if(s2m_drs_pkt[0].pending_data_slot == 'h8) begin
      s2m_drs_pkt[0].s2m_drs_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]; 
      s2m_drs_pkt[0].pending_data_slot = 'h0;
      if(s2m_drs_pkt[1].pending_data_slot != 0) begin
        s2m_drs_pkt[1].s2m_drs_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
        s2m_drs_pkt[1].pending_data_slot = 'h8;
      end
    end else begin
      if(s2m_drs_pkt[1].pending_data_slot == 'hf) begin
        s2m_drs_pkt[1].s2m_drs_txn.data = data;
        s2m_drs_pkt[1].pending_data_slot = 'h0;
      end else if(s2m_drs_pkt[1].pending_data_slot == 'he) begin
        s2m_drs_pkt[1].s2m_drs_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
        s2m_drs_pkt[1].pending_data_slot = 'h0;
        if(s2m_drs_pkt[2].pending_data_slot != 'h0) begin
          s2m_drs_pkt[2].s2m_drs_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
          s2m_drs_pkt[2].pending_data_slot = 'he;
        end
      end else if(s2m_drs_pkt[1].pending_data_slot == 'hc) begin
        s2m_drs_pkt[1].s2m_drs_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
        s2m_drs_pkt[1].pending_data_slot = 'h0;
        if(s2m_drs_pkt[2].pending_data_slot != 'h0) begin
          s2m_drs_pkt[2].s2m_drs_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
          s2m_drs_pkt[2].pending_data_slot = 'hc;
        end
      end else if(s2m_drs_pkt[1].pending_data_slot == 'h8) begin
        s2m_drs_pkt[1].s2m_drs_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
        s2m_drs_pkt[1].pending_data_slot = 'h0;
        if(s2m_drs_pkt[2].pending_data_slot != 'h0) begin
          s2m_drs_pkt[2].s2m_drs_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
          s2m_drs_pkt[2].pending_data_slot = 'h8;
        end
      end else begin
        if(s2m_drs_pkt[2].pending_data_slot == 'hf) begin
          s2m_drs_pkt[2].s2m_drs_txn.data = data;
          s2m_drs_pkt[2].pending_data_slot = 'h0;
        end else if(s2m_drs_pkt[2].pending_data_slot == 'he) begin
          s2m_drs_pkt[2].s2m_drs_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]
          s2m_drs_pkt[2].pending_data_slot = 'h0;
          if(s2m_drs_pkt[3].pending_data_slot != 'h0) begin
            s2m_drs_pkt[3].s2m_drs_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
            s2m_drs_pkt[3].pending_data_slot = 'he;
          end
        end else if(s2m_drs_pkt[2].pending_data_slot == 'hc) begin
          s2m_drs_pkt[2].s2m_drs_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]
          s2m_drs_pkt[2].pending_data_slot = 'h0;
          if(s2m_drs_pkt[3].pending_data_slot != 'h0) begin
            s2m_drs_pkt[3].s2m_drs_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
            s2m_drs_pkt[3].pending_data_slot = 'hc;
          end
        end else if(s2m_drs_pkt[2].pending_data_slot == 'h8) begin
          s2m_drs_pkt[2].s2m_drs_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]
          s2m_drs_pkt[2].pending_data_slot = 'h0;
          //TODO: next gen upgrade if s2m drs max size increases to 4
          /*if(s2m_drs_pkt[3].pending_data_slot != 'h0) begin
            s2m_drs_pkt[3].s2m_drs_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
            s2m_drs_pkt[3].pending_data_slot = 'h8;
          end*/
        end else begin
          //TODO: next gen upgrade if s2m drs max size increases to 4
          /*if(s2m_drs_pkt[3].pending_data_slot == 'hf) begin
            s2m_drs_pkt[3].s2m_drs_txn.data = data;
            s2m_drs_pkt[3].pending_data_slot = 'h0;
          end else if(s2m_drs_pkt[3].pending_data_slot == 'he) begin
            s2m_drs_pkt[3].s2m_drs_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
            s2m_drs_pkt[3].pending_data_slot = 'h0;
          end else if(s2m_drs_pkt[3].pending_data_slot == 'hc) begin
            s2m_drs_pkt[3].s2m_drs_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
            s2m_drs_pkt[3].pending_data_slot = 'h0;
          end else if(s2m_drs_pkt[3].pending_data_slot == 'h8) begin
            s2m_drs_pkt[3].s2m_drs_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
            s2m_drs_pkt[3].pending_data_slot = 'h0;
          end else begin
            
          end*/
        end
      end
    end

    if(d2h_data_pkt[0].pending_data_slot == 'hf) begin
      if(slot_sel == 1) begin
        d2h_data_pkt[0].d2h_data_txn.data[SLOT3_OFFSET-1:0] = data[SLOT3_OFFSET-1:0]; 
        d2h_data_pkt[0].pending_data_slot = 'h8;
      end else if(slot_sel == 2) begin
        d2h_data_pkt[0].d2h_data_txn.data[SLOT2_OFFSET-1:0] = data[SLOT2_OFFSET-1:0]; 
        d2h_data_pkt[0].pending_data_slot = 'hc;
      end else if(slot_sel == 3) begin
        d2h_data_pkt[0].d2h_data_txn.data[SLOT1_OFFSET-1:0] = data[SLOT1_OFFSET-1:0]; 
        d2h_data_pkt[0].pending_data_slot = 'he;
      end else if(slot_sel == 0) begin
        d2h_data_pkt[0].d2h_data_txn.data = data; 
        d2h_data_pkt[0].pending_data_slot = 'h0;
      end 
    end else if(d2h_data_pkt[0].pending_data_slot == 'he) begin
      d2h_data_pkt[0].d2h_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]; 
      d2h_data_pkt[0].pending_data_slot = 'h0;
      if(d2h_data_pkt[1].pending_data_slot != 0) begin
        d2h_data_pkt[1].d2h_data_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
        d2h_data_pkt[1].pending_data_slot = 'he;
      end
    end else if(d2h_data_pkt[0].pending_data_slot == 'hc) begin
      d2h_data_pkt[0].d2h_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]; 
      d2h_data_pkt[0].pending_data_slot = 'h0;
      if(d2h_data_pkt[1].pending_data_slot != 0) begin
        d2h_data_pkt[1].d2h_data_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
        d2h_data_pkt[1].pending_data_slot = 'hc;
      end
    end else if(d2h_data_pkt[0].pending_data_slot == 'h8) begin
      d2h_data_pkt[0].d2h_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]; 
      d2h_data_pkt[0].pending_data_slot = 'h0;
      if(d2h_data_pkt[1].pending_data_slot != 0) begin
        d2h_data_pkt[1].d2h_data_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
        d2h_data_pkt[1].pending_data_slot = 'h8;
      end
    end else begin
      if(d2h_data_pkt[1].pending_data_slot == 'hf) begin
        d2h_data_pkt[1].d2h_data_txn.data = data;
        d2h_data_pkt[1].pending_data_slot = 'h0;
      end else if(d2h_data_pkt[1].pending_data_slot == 'he) begin
        d2h_data_pkt[1].d2h_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
        d2h_data_pkt[1].pending_data_slot = 'h0;
        if(d2h_data_pkt[2].pending_data_slot != 'h0) begin
          d2h_data_pkt[2].d2h_data_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
          d2h_data_pkt[2].pending_data_slot = 'he;
        end
      end else if(d2h_data_pkt[1].pending_data_slot == 'hc) begin
        d2h_data_pkt[1].d2h_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
        d2h_data_pkt[1].pending_data_slot = 'h0;
        if(d2h_data_pkt[2].pending_data_slot != 'h0) begin
          d2h_data_pkt[2].d2h_data_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
          d2h_data_pkt[2].pending_data_slot = 'hc;
        end
      end else if(d2h_data_pkt[1].pending_data_slot == 'h8) begin
        d2h_data_pkt[1].d2h_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
        d2h_data_pkt[1].pending_data_slot = 'h0;
        if(d2h_data_pkt[2].pending_data_slot != 'h0) begin
          d2h_data_pkt[2].d2h_data_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
          d2h_data_pkt[2].pending_data_slot = 'h8;
        end
      end else begin
        if(d2h_data_pkt[2].pending_data_slot == 'hf) begin
          d2h_data_pkt[2].d2h_data_txn.data = data;
          d2h_data_pkt[2].pending_data_slot = 'h0;
        end else if(d2h_data_pkt[2].pending_data_slot == 'he) begin
          d2h_data_pkt[2].d2h_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]
          d2h_data_pkt[2].pending_data_slot = 'h0;
          if(d2h_data_pkt[3].pending_data_slot != 'h0) begin
            d2h_data_pkt[3].d2h_data_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
            d2h_data_pkt[3].pending_data_slot = 'he;
          end
        end else if(d2h_data_pkt[2].pending_data_slot == 'hc) begin
          d2h_data_pkt[2].d2h_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]
          d2h_data_pkt[2].pending_data_slot = 'h0;
          if(d2h_data_pkt[3].pending_data_slot != 'h0) begin
            d2h_data_pkt[3].d2h_data_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
            d2h_data_pkt[3].pending_data_slot = 'hc;
          end
        end else if(d2h_data_pkt[2].pending_data_slot == 'h8) begin
          d2h_data_pkt[2].d2h_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]
          d2h_data_pkt[2].pending_data_slot = 'h0;
          if(d2h_data_pkt[3].pending_data_slot != 'h0) begin
            d2h_data_pkt[3].d2h_data_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
            d2h_data_pkt[3].pending_data_slot = 'h8;
          end
        end else begin
          if(d2h_data_pkt[3].pending_data_slot == 'hf) begin
            d2h_data_pkt[3].d2h_data_txn.data = data;
            d2h_data_pkt[3].pending_data_slot = 'h0;
          end else if(d2h_data_pkt[3].pending_data_slot == 'he) begin
            d2h_data_pkt[3].d2h_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
            d2h_data_pkt[3].pending_data_slot = 'h0;
          end else if(d2h_data_pkt[3].pending_data_slot == 'hc) begin
            d2h_data_pkt[3].d2h_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
            d2h_data_pkt[3].pending_data_slot = 'h0;
          end else if(d2h_data_pkt[3].pending_data_slot == 'h8) begin
            d2h_data_pkt[3].d2h_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
            d2h_data_pkt[3].pending_data_slot = 'h0;
          end else begin
            
          end
        end
      end
    end
    
  endfunction
  
  function void generic1(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output d2h_req_txn_t d2h_req_txn,
    output d2h_rsp_txn_t d2h_rsp_txn[2]
  );

    if(slot_sel == 'h1) begin
      d2h_req_txn.valid        = data[(SLOT1_OFFSET+0)];
      d2h_req_txn.opcode       = data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+1)];
      d2h_req_txn.cqid         = data[(SLOT1_OFFSET+17):(SLOT1_OFFSET+6)];
      d2h_req_txn.nt           = data[(SLOT1_OFFSET+18)];
      d2h_req_txn.address      = data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+26)];
      d2h_rsp_txn[0].valid     = data[(SLOT1_OFFSET+79)];
      d2h_rsp_txn[0].opcode    = data[(SLOT1_OFFSET+84):(SLOT1_OFFSET+80)];
      d2h_rsp_txn[0].uqid      = data[(SLOT1_OFFSET+96):(SLOT1_OFFSET+85)];
      d2h_rsp_txn[1].valid     = data[(SLOT1_OFFSET+99)];
      d2h_rsp_txn[1].opcode    = data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+100)];
      d2h_rsp_txn[1].uqid      = data[(SLOT1_OFFSET+116):(SLOT1_OFFSET+105)];
    end else if(slot_sel == 'h2) begin
      d2h_req_txn.valid        = data[(SLOT2_OFFSET+0)];
      d2h_req_txn.opcode       = data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+1)];
      d2h_req_txn.cqid         = data[(SLOT2_OFFSET+17):(SLOT2_OFFSET+6)];
      d2h_req_txn.nt           = data[(SLOT2_OFFSET+18)];
      d2h_req_txn.address      = data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+26)];
      d2h_rsp_txn[0].valid     = data[(SLOT2_OFFSET+79)];
      d2h_rsp_txn[0].opcode    = data[(SLOT2_OFFSET+84):(SLOT2_OFFSET+80)];
      d2h_rsp_txn[0].uqid      = data[(SLOT2_OFFSET+96):(SLOT2_OFFSET+85)];
      d2h_rsp_txn[1].valid     = data[(SLOT2_OFFSET+99)];
      d2h_rsp_txn[1].opcode    = data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+100)];
      d2h_rsp_txn[1].uqid      = data[(SLOT2_OFFSET+116):(SLOT2_OFFSET+105)];
    end else if(slot_sel == 'h3) begin
      d2h_req_txn.valid        = data[(SLOT3_OFFSET+0)];
      d2h_req_txn.opcode       = data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+1)];
      d2h_req_txn.cqid         = data[(SLOT3_OFFSET+17):(SLOT3_OFFSET+6)];
      d2h_req_txn.nt           = data[(SLOT3_OFFSET+18)];
      d2h_req_txn.address      = data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+26)];
      d2h_rsp_txn[0].valid     = data[(SLOT3_OFFSET+79)];
      d2h_rsp_txn[0].opcode    = data[(SLOT3_OFFSET+84):(SLOT3_OFFSET+80)];
      d2h_rsp_txn[0].uqid      = data[(SLOT3_OFFSET+96):(SLOT3_OFFSET+85)];
      d2h_rsp_txn[1].valid     = data[(SLOT3_OFFSET+99)];
      d2h_rsp_txn[1].opcode    = data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+100)];
      d2h_rsp_txn[1].uqid      = data[(SLOT3_OFFSET+116):(SLOT3_OFFSET+105)];
    end else begin
      d2h_req_txn.valid = 'hX;
      d2h_rsp_txn[0].valid = 'hX;
      d2h_rsp_txn[1].valid = 'hX;
    end

  endfunction

  function void generic2(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output d2h_req_txn_t d2h_req_txn,
    output d2h_data_pkt_t d2h_data_pkt,
    output d2h_rsp_txn_t d2h_rsp_txn
  );

    if(slot_sel == 'h1) begin
      d2h_req_txn.valid                    = data[(SLOT1_OFFSET+0)];
      d2h_req_txn.opcode                   = data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+1)];
      d2h_req_txn.cqid                     = data[(SLOT1_OFFSET+17):(SLOT1_OFFSET+6)];
      d2h_req_txn.nt                       = data[(SLOT1_OFFSET+18)];
      d2h_req_txn.address                  = data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+26)];
      d2h_data_pkt.pending_data_slot       = 'hf;
      d2h_data_pkt.d2h_data_txn.valid      = data[(SLOT1_OFFSET+79)];
      d2h_data_pkt.d2h_data_txn.uqid       = data[(SLOT1_OFFSET+91):(SLOT1_OFFSET+80)];
      d2h_data_pkt.d2h_data_txn.chunkvalid = data[(SLOT1_OFFSET+92)];
      d2h_data_pkt.d2h_data_txn.bogus      = data[(SLOT1_OFFSET+93)];
      d2h_data_pkt.d2h_data_txn.poison     = data[(SLOT1_OFFSET+94)];
      d2h_rsp_txn.valid                    = data[(SLOT1_OFFSET+96)];
      d2h_rsp_txn.opcode                   = data[(SLOT1_OFFSET+101):(SLOT1_OFFSET+97)];
      d2h_rsp_txn.uqid                     = data[(SLOT1_OFFSET+113):(SLOT1_OFFSET+102)];
    end else if(slot_sel == 'h2) begin
      d2h_req_txn.valid                    = data[(SLOT2_OFFSET+0)];
      d2h_req_txn.opcode                   = data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+1)];
      d2h_req_txn.cqid                     = data[(SLOT2_OFFSET+17):(SLOT2_OFFSET+6)];
      d2h_req_txn.nt                       = data[(SLOT2_OFFSET+18)];
      d2h_req_txn.address                  = data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+26)];
      d2h_data_pkt.pending_data_slot       = 'hf;
      d2h_data_pkt.d2h_data_txn.valid      = data[(SLOT2_OFFSET+79)];
      d2h_data_pkt.d2h_data_txn.uqid       = data[(SLOT2_OFFSET+91):(SLOT2_OFFSET+80)];
      d2h_data_pkt.d2h_data_txn.chunkvalid = data[(SLOT2_OFFSET+92)];
      d2h_data_pkt.d2h_data_txn.bogus      = data[(SLOT2_OFFSET+93)];
      d2h_data_pkt.d2h_data_txn.poison     = data[(SLOT2_OFFSET+94)];
      d2h_rsp_txn.valid                    = data[(SLOT2_OFFSET+96)];
      d2h_rsp_txn.opcode                   = data[(SLOT2_OFFSET+101):(SLOT2_OFFSET+97)];
      d2h_rsp_txn.uqid                     = data[(SLOT2_OFFSET+113):(SLOT2_OFFSET+102)];
    end else if(slot_sel == 'h3) begin
      d2h_req_txn.valid                    = data[(SLOT3_OFFSET+0)];
      d2h_req_txn.opcode                   = data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+1)];
      d2h_req_txn.cqid                     = data[(SLOT3_OFFSET+17):(SLOT3_OFFSET+6)];
      d2h_req_txn.nt                       = data[(SLOT3_OFFSET+18)];
      d2h_req_txn.address                  = data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+26)];
      d2h_data_pkt.pending_data_slot       = 'hf;
      d2h_data_pkt.d2h_data_txn.valid      = data[(SLOT3_OFFSET+79)];
      d2h_data_pkt.d2h_data_txn.uqid       = data[(SLOT3_OFFSET+91):(SLOT3_OFFSET+80)];
      d2h_data_pkt.d2h_data_txn.chunkvalid = data[(SLOT3_OFFSET+92)];
      d2h_data_pkt.d2h_data_txn.bogus      = data[(SLOT3_OFFSET+93)];
      d2h_data_pkt.d2h_data_txn.poison     = data[(SLOT3_OFFSET+94)];
      d2h_rsp_txn.valid                    = data[(SLOT3_OFFSET+96)];
      d2h_rsp_txn.opcode                   = data[(SLOT3_OFFSET+101):(SLOT3_OFFSET+97)];
      d2h_rsp_txn.uqid                     = data[(SLOT3_OFFSET+113):(SLOT3_OFFSET+102)];
    end else begin
      d2h_req_txn.valid = 'hX;
      d2h_data_pkt.d2h_data_txn.valid = 'hX;
      d2h_rsp_txn.valid = 'hX;
    end

  endfunction

  function void generic3(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output d2h_data_pkt_t d2h_data_pkt[4]
  );

    if(slot_sel == 'h1) begin      
      d2h_data_pkt[0].pending_data_slot         = 'hf;
      d2h_data_pkt[0].d2h_data_txn.valid        = data[(SLOT1_OFFSET+0)];
      d2h_data_pkt[0].d2h_data_txn.uqid         = data[(SLOT1_OFFSET+12):(SLOT1_OFFSET+1)];
      d2h_data_pkt[0].d2h_data_txn.chunkvalid   = data[(SLOT1_OFFSET+13)];
      d2h_data_pkt[0].d2h_data_txn.bogus        = data[(SLOT1_OFFSET+14)];
      d2h_data_pkt[0].d2h_data_txn.poison       = data[(SLOT1_OFFSET+15)];
      d2h_data_pkt[1].pending_data_slot         = 'hf;
      d2h_data_pkt[1].d2h_data_txn.valid        = data[(SLOT1_OFFSET+17)];
      d2h_data_pkt[1].d2h_data_txn.uqid         = data[(SLOT1_OFFSET+29):(SLOT1_OFFSET+18)];
      d2h_data_pkt[1].d2h_data_txn.chunkvalid   = data[(SLOT1_OFFSET+30)];
      d2h_data_pkt[1].d2h_data_txn.bogus        = data[(SLOT1_OFFSET+31)];
      d2h_data_pkt[1].d2h_data_txn.poison       = data[(SLOT1_OFFSET+32)];
      d2h_data_pkt[2].pending_data_slot         = 'hf;
      d2h_data_pkt[2].d2h_data_txn.valid        = data[(SLOT1_OFFSET+34)];
      d2h_data_pkt[2].d2h_data_txn.uqid         = data[(SLOT1_OFFSET+46):(SLOT1_OFFSET+35)];
      d2h_data_pkt[2].d2h_data_txn.chunkvalid   = data[(SLOT1_OFFSET+47)];
      d2h_data_pkt[2].d2h_data_txn.bogus        = data[(SLOT1_OFFSET+48)];
      d2h_data_pkt[2].d2h_data_txn.poison       = data[(SLOT1_OFFSET+49)];
      d2h_data_pkt[3].pending_data_slot         = 'hf;
      d2h_data_pkt[3].d2h_data_txn.valid        = data[(SLOT1_OFFSET+51)];
      d2h_data_pkt[3].d2h_data_txn.uqid         = data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+52)];
      d2h_data_pkt[3].d2h_data_txn.chunkvalid   = data[(SLOT1_OFFSET+64)];
      d2h_data_pkt[3].d2h_data_txn.bogus        = data[(SLOT1_OFFSET+65)];
      d2h_data_pkt[3].d2h_data_txn.poison       = data[(SLOT1_OFFSET+66)];
    end else if(slot_sel == 'h2) begin
      d2h_data_pkt[0].pending_data_slot         = 'hf;
      d2h_data_pkt[0].d2h_data_txn.valid        = data[(SLOT2_OFFSET+0)];
      d2h_data_pkt[0].d2h_data_txn.uqid         = data[(SLOT2_OFFSET+12):(SLOT2_OFFSET+1)];
      d2h_data_pkt[0].d2h_data_txn.chunkvalid   = data[(SLOT2_OFFSET+13)];
      d2h_data_pkt[0].d2h_data_txn.bogus        = data[(SLOT2_OFFSET+14)];
      d2h_data_pkt[0].d2h_data_txn.poison       = data[(SLOT2_OFFSET+15)];
      d2h_data_pkt[1].pending_data_slot         = 'hf;
      d2h_data_pkt[1].d2h_data_txn.valid        = data[(SLOT2_OFFSET+17)];
      d2h_data_pkt[1].d2h_data_txn.uqid         = data[(SLOT2_OFFSET+29):(SLOT2_OFFSET+18)];
      d2h_data_pkt[1].d2h_data_txn.chunkvalid   = data[(SLOT2_OFFSET+30)];
      d2h_data_pkt[1].d2h_data_txn.bogus        = data[(SLOT2_OFFSET+31)];
      d2h_data_pkt[1].d2h_data_txn.poison       = data[(SLOT2_OFFSET+32)];
      d2h_data_pkt[2].pending_data_slot         = 'hf;
      d2h_data_pkt[2].d2h_data_txn.valid        = data[(SLOT2_OFFSET+34)];
      d2h_data_pkt[2].d2h_data_txn.uqid         = data[(SLOT2_OFFSET+46):(SLOT2_OFFSET+35)];
      d2h_data_pkt[2].d2h_data_txn.chunkvalid   = data[(SLOT2_OFFSET+47)];
      d2h_data_pkt[2].d2h_data_txn.bogus        = data[(SLOT2_OFFSET+48)];
      d2h_data_pkt[2].d2h_data_txn.poison       = data[(SLOT2_OFFSET+49)];
      d2h_data_pkt[3].pending_data_slot         = 'hf;
      d2h_data_pkt[3].d2h_data_txn.valid        = data[(SLOT2_OFFSET+51)];
      d2h_data_pkt[3].d2h_data_txn.uqid         = data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+52)];
      d2h_data_pkt[3].d2h_data_txn.chunkvalid   = data[(SLOT2_OFFSET+64)];
      d2h_data_pkt[3].d2h_data_txn.bogus        = data[(SLOT2_OFFSET+65)];
      d2h_data_pkt[3].d2h_data_txn.poison       = data[(SLOT2_OFFSET+66)];
    end else if(slot_sel == 'h3) begin
      d2h_data_pkt[0].pending_data_slot         = 'hf;
      d2h_data_pkt[0].d2h_data_txn.valid        = data[(SLOT3_OFFSET+0)];
      d2h_data_pkt[0].d2h_data_txn.uqid         = data[(SLOT3_OFFSET+12):(SLOT3_OFFSET+1)];
      d2h_data_pkt[0].d2h_data_txn.chunkvalid   = data[(SLOT3_OFFSET+13)];
      d2h_data_pkt[0].d2h_data_txn.bogus        = data[(SLOT3_OFFSET+14)];
      d2h_data_pkt[0].d2h_data_txn.poison       = data[(SLOT3_OFFSET+15)];
      d2h_data_pkt[1].pending_data_slot         = 'hf;
      d2h_data_pkt[1].d2h_data_txn.valid        = data[(SLOT3_OFFSET+17)];
      d2h_data_pkt[1].d2h_data_txn.uqid         = data[(SLOT3_OFFSET+29):(SLOT3_OFFSET+18)];
      d2h_data_pkt[1].d2h_data_txn.chunkvalid   = data[(SLOT3_OFFSET+30)];
      d2h_data_pkt[1].d2h_data_txn.bogus        = data[(SLOT3_OFFSET+31)];
      d2h_data_pkt[1].d2h_data_txn.poison       = data[(SLOT3_OFFSET+32)];
      d2h_data_pkt[2].pending_data_slot         = 'hf;
      d2h_data_pkt[2].d2h_data_txn.valid        = data[(SLOT3_OFFSET+34)];
      d2h_data_pkt[2].d2h_data_txn.uqid         = data[(SLOT3_OFFSET+46):(SLOT3_OFFSET+35)];
      d2h_data_pkt[2].d2h_data_txn.chunkvalid   = data[(SLOT3_OFFSET+47)];
      d2h_data_pkt[2].d2h_data_txn.bogus        = data[(SLOT3_OFFSET+48)];
      d2h_data_pkt[2].d2h_data_txn.poison       = data[(SLOT3_OFFSET+49)];
      d2h_data_pkt[3].pending_data_slot         = 'hf;
      d2h_data_pkt[3].d2h_data_txn.valid        = data[(SLOT3_OFFSET+51)];
      d2h_data_pkt[3].d2h_data_txn.uqid         = data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+52)];
      d2h_data_pkt[3].d2h_data_txn.chunkvalid   = data[(SLOT3_OFFSET+64)];
      d2h_data_pkt[3].d2h_data_txn.bogus        = data[(SLOT3_OFFSET+65)];
      d2h_data_pkt[3].d2h_data_txn.poison       = data[(SLOT3_OFFSET+66)];
    end else begin
      d2h_data_pkt[0].d2h_data_txn.valid = 'hX;
      d2h_data_pkt[1].d2h_data_txn.valid = 'hX;
      d2h_data_pkt[2].d2h_data_txn.valid = 'hX;
      d2h_data_pkt[3].d2h_data_txn.valid = 'hX;
    end

  endfunction

  function void generic4(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output s2m_drs_pkt_t s2m_drs_pkt,
    output s2m_ndr_txn_t s2m_ndr_txn[2]
  );

    if(slot_sel == 'h1) begin
      s2m_drs_pkt.pending_data_slot     = 'hf;
      s2m_drs_pkt.s2m_drs_txn.valid     = data[(SLOT1_OFFSET+0)];
      s2m_drs_pkt.s2m_drs_txn.memopcode = data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)];
      s2m_drs_pkt.s2m_drs_txn.metafield = data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)];
      s2m_drs_pkt.s2m_drs_txn.metavalue = data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)];
      s2m_drs_pkt.s2m_drs_txn.tag       = data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)];
      s2m_drs_pkt.s2m_drs_txn.poison    = data[(SLOT1_OFFSET+24)];
      s2m_ndr_txn[0].valid              = data[(SLOT1_OFFSET+40)];
      s2m_ndr_txn[0].memopcode          = data[(SLOT1_OFFSET+43):(SLOT1_OFFSET+41)];
      s2m_ndr_txn[0].metafield          = data[(SLOT1_OFFSET+45):(SLOT1_OFFSET+44)];
      s2m_ndr_txn[0].metavalue          = data[(SLOT1_OFFSET+47):(SLOT1_OFFSET+46)];
      s2m_ndr_txn[0].tag                = data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+48)];
      s2m_ndr_txn[1].valid              = data[(SLOT1_OFFSET+68)];
      s2m_ndr_txn[1].memopcode          = data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+69)];
      s2m_ndr_txn[1].metafield          = data[(SLOT1_OFFSET+73):(SLOT1_OFFSET+72)];
      s2m_ndr_txn[1].metavalue          = data[(SLOT1_OFFSET+75):(SLOT1_OFFSET+74)];
      s2m_ndr_txn[1].tag                = data[(SLOT1_OFFSET+91):(SLOT1_OFFSET+76)];
    end else if(slot_sel == 'h2) begin
      s2m_drs_pkt.pending_data_slot     = 'hf;
      s2m_drs_pkt.s2m_drs_txn.valid     = data[(SLOT2_OFFSET+0)];
      s2m_drs_pkt.s2m_drs_txn.memopcode = data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)];
      s2m_drs_pkt.s2m_drs_txn.metafield = data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)];
      s2m_drs_pkt.s2m_drs_txn.metavalue = data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)];
      s2m_drs_pkt.s2m_drs_txn.tag       = data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)];
      s2m_drs_pkt.s2m_drs_txn.poison    = data[(SLOT2_OFFSET+24)];
      s2m_ndr_txn[0].valid              = data[(SLOT2_OFFSET+40)];
      s2m_ndr_txn[0].memopcode          = data[(SLOT2_OFFSET+43):(SLOT2_OFFSET+41)];
      s2m_ndr_txn[0].metafield          = data[(SLOT2_OFFSET+45):(SLOT2_OFFSET+44)];
      s2m_ndr_txn[0].metavalue          = data[(SLOT2_OFFSET+47):(SLOT2_OFFSET+46)];
      s2m_ndr_txn[0].tag                = data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+48)];
      s2m_ndr_txn[1].valid              = data[(SLOT2_OFFSET+68)];
      s2m_ndr_txn[1].memopcode          = data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+69)];
      s2m_ndr_txn[1].metafield          = data[(SLOT2_OFFSET+73):(SLOT2_OFFSET+72)];
      s2m_ndr_txn[1].metavalue          = data[(SLOT2_OFFSET+75):(SLOT2_OFFSET+74)];
      s2m_ndr_txn[1].tag                = data[(SLOT2_OFFSET+91):(SLOT2_OFFSET+76)];
    end else if(slot_sel == 'h3) begin
      s2m_drs_pkt.pending_data_slot     = 'hf;
      s2m_drs_pkt.s2m_drs_txn.valid     = data[(SLOT3_OFFSET+0)];
      s2m_drs_pkt.s2m_drs_txn.memopcode = data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)];
      s2m_drs_pkt.s2m_drs_txn.metafield = data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)];
      s2m_drs_pkt.s2m_drs_txn.metavalue = data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)];
      s2m_drs_pkt.s2m_drs_txn.tag       = data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)];
      s2m_drs_pkt.s2m_drs_txn.poison    = data[(SLOT3_OFFSET+24)];
      s2m_ndr_txn[0].valid              = data[(SLOT3_OFFSET+40)];
      s2m_ndr_txn[0].memopcode          = data[(SLOT3_OFFSET+43):(SLOT3_OFFSET+41)];
      s2m_ndr_txn[0].metafield          = data[(SLOT3_OFFSET+45):(SLOT3_OFFSET+44)];
      s2m_ndr_txn[0].metavalue          = data[(SLOT3_OFFSET+47):(SLOT3_OFFSET+46)];
      s2m_ndr_txn[0].tag                = data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+48)];
      s2m_ndr_txn[1].valid              = data[(SLOT3_OFFSET+68)];
      s2m_ndr_txn[1].memopcode          = data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+69)];
      s2m_ndr_txn[1].metafield          = data[(SLOT3_OFFSET+73):(SLOT3_OFFSET+72)];
      s2m_ndr_txn[1].metavalue          = data[(SLOT3_OFFSET+75):(SLOT3_OFFSET+74)];
      s2m_ndr_txn[1].tag                = data[(SLOT3_OFFSET+91):(SLOT3_OFFSET+76)];
    end else begin
      s2m_drs_pkt.s2m_drs_txn.valid = 'hX;
      s2m_ndr_txn[0].valid = 'hX;
      s2m_ndr_txn[1].valid = 'hX;
    end

  endfunction

  function void generic5(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output s2m_ndr_txn_t s2m_ndr_txn[3]
  );

    if(slot_sel == 'h1) begin
      s2m_ndr_txn[0].valid        = data[(SLOT1_OFFSET+0)];
      s2m_ndr_txn[0].memopcode    = data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)];
      s2m_ndr_txn[0].metafield    = data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)];
      s2m_ndr_txn[0].metavalue    = data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)];
      s2m_ndr_txn[0].tag          = data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)];
      s2m_ndr_txn[1].valid        = data[(SLOT1_OFFSET+28)];
      s2m_ndr_txn[1].memopcode    = data[(SLOT1_OFFSET+31):(SLOT1_OFFSET+29)];
      s2m_ndr_txn[1].metafield    = data[(SLOT1_OFFSET+33):(SLOT1_OFFSET+32)];
      s2m_ndr_txn[1].metavalue    = data[(SLOT1_OFFSET+35):(SLOT1_OFFSET+34)];
      s2m_ndr_txn[1].tag          = data[(SLOT1_OFFSET+51):(SLOT1_OFFSET+36)];
      s2m_ndr_txn[2].valid        = data[(SLOT1_OFFSET+56)];
      s2m_ndr_txn[2].memopcode    = data[(SLOT1_OFFSET+59):(SLOT1_OFFSET+57)];
      s2m_ndr_txn[2].metafield    = data[(SLOT1_OFFSET+61):(SLOT1_OFFSET+60)];
      s2m_ndr_txn[2].metavalue    = data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+62)];
      s2m_ndr_txn[2].tag          = data[(SLOT1_OFFSET+79):(SLOT1_OFFSET+64)];
    end else if(slot_sel == 'h2) begin
      s2m_ndr_txn[0].valid        = data[(SLOT2_OFFSET+0)];
      s2m_ndr_txn[0].memopcode    = data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)];
      s2m_ndr_txn[0].metafield    = data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)];
      s2m_ndr_txn[0].metavalue    = data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)];
      s2m_ndr_txn[0].tag          = data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)];
      s2m_ndr_txn[1].valid        = data[(SLOT2_OFFSET+28)];
      s2m_ndr_txn[1].memopcode    = data[(SLOT2_OFFSET+31):(SLOT2_OFFSET+29)];
      s2m_ndr_txn[1].metafield    = data[(SLOT2_OFFSET+33):(SLOT2_OFFSET+32)];
      s2m_ndr_txn[1].metavalue    = data[(SLOT2_OFFSET+35):(SLOT2_OFFSET+34)];
      s2m_ndr_txn[1].tag          = data[(SLOT2_OFFSET+51):(SLOT2_OFFSET+36)];
      s2m_ndr_txn[2].valid        = data[(SLOT2_OFFSET+56)];
      s2m_ndr_txn[2].memopcode    = data[(SLOT2_OFFSET+59):(SLOT2_OFFSET+57)];
      s2m_ndr_txn[2].metafield    = data[(SLOT2_OFFSET+61):(SLOT2_OFFSET+60)];
      s2m_ndr_txn[2].metavalue    = data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+62)];
      s2m_ndr_txn[2].tag          = data[(SLOT2_OFFSET+79):(SLOT2_OFFSET+64)];
    end else if(slot_sel == 'h3) begin
      s2m_ndr_txn[0].valid        = data[(SLOT3_OFFSET+0)];
      s2m_ndr_txn[0].memopcode    = data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)];
      s2m_ndr_txn[0].metafield    = data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)];
      s2m_ndr_txn[0].metavalue    = data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)];
      s2m_ndr_txn[0].tag          = data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)];
      s2m_ndr_txn[1].valid        = data[(SLOT3_OFFSET+28)];
      s2m_ndr_txn[1].memopcode    = data[(SLOT3_OFFSET+31):(SLOT3_OFFSET+29)];
      s2m_ndr_txn[1].metafield    = data[(SLOT3_OFFSET+33):(SLOT3_OFFSET+32)];
      s2m_ndr_txn[1].metavalue    = data[(SLOT3_OFFSET+35):(SLOT3_OFFSET+34)];
      s2m_ndr_txn[1].tag          = data[(SLOT3_OFFSET+51):(SLOT3_OFFSET+36)];
      s2m_ndr_txn[2].valid        = data[(SLOT3_OFFSET+56)];
      s2m_ndr_txn[2].memopcode    = data[(SLOT3_OFFSET+59):(SLOT3_OFFSET+57)];
      s2m_ndr_txn[2].metafield    = data[(SLOT3_OFFSET+61):(SLOT3_OFFSET+60)];
      s2m_ndr_txn[2].metavalue    = data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+62)];
      s2m_ndr_txn[2].tag          = data[(SLOT3_OFFSET+79):(SLOT3_OFFSET+64)];
    end else begin
      s2m_ndr_txn[0].valid        = 'hX;
      s2m_ndr_txn[1].valid        = 'hX;
      s2m_ndr_txn[2].valid        = 'hX;
    end

  endfunction

  function void generic6(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output s2m_drs_pkt_t s2m_drs_pkt[3]
  );

    if(slot_sel == 'h1) begin
      s2m_drs_pkt[0].pending_data_slot        = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid        = data[(SLOT1_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.memopcode    = data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)];
      s2m_drs_pkt[0].s2m_drs_txn.metafield    = data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)];
      s2m_drs_pkt[0].s2m_drs_txn.metavalue    = data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)];
      s2m_drs_pkt[0].s2m_drs_txn.tag          = data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison       = data[(SLOT1_OFFSET+24)];
      s2m_drs_pkt[1].pending_data_slot        = 'hf;
      s2m_drs_pkt[1].s2m_drs_txn.valid        = data[(SLOT1_OFFSET+40)];
      s2m_drs_pkt[1].s2m_drs_txn.memopcode    = data[(SLOT1_OFFSET+43):(SLOT1_OFFSET+41)];
      s2m_drs_pkt[1].s2m_drs_txn.metafield    = data[(SLOT1_OFFSET+45):(SLOT1_OFFSET+44)];
      s2m_drs_pkt[1].s2m_drs_txn.metavalue    = data[(SLOT1_OFFSET+47):(SLOT1_OFFSET+46)];
      s2m_drs_pkt[1].s2m_drs_txn.tag          = data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+48)];
      s2m_drs_pkt[1].s2m_drs_txn.poison       = data[(SLOT1_OFFSET+64)];
      s2m_drs_pkt[2].pending_data_slot        = 'hf;
      s2m_drs_pkt[2].s2m_drs_txn.valid        = data[(SLOT1_OFFSET+80)];
      s2m_drs_pkt[2].s2m_drs_txn.memopcode    = data[(SLOT1_OFFSET+83):(SLOT1_OFFSET+81)];
      s2m_drs_pkt[2].s2m_drs_txn.metafield    = data[(SLOT1_OFFSET+85):(SLOT1_OFFSET+84)];
      s2m_drs_pkt[2].s2m_drs_txn.metavalue    = data[(SLOT1_OFFSET+87):(SLOT1_OFFSET+86)];
      s2m_drs_pkt[2].s2m_drs_txn.tag          = data[(SLOT1_OFFSET+103):(SLOT1_OFFSET+88)];
      s2m_drs_pkt[2].s2m_drs_txn.poison       = data[(SLOT1_OFFSET+104)];
    end else if(slot_sel == 'h2) begin
      s2m_drs_pkt[0].pending_data_slot        = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid        = data[(SLOT2_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.memopcode    = data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)];
      s2m_drs_pkt[0].s2m_drs_txn.metafield    = data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)];
      s2m_drs_pkt[0].s2m_drs_txn.metavalue    = data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)];
      s2m_drs_pkt[0].s2m_drs_txn.tag          = data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison       = data[(SLOT2_OFFSET+24)];
      s2m_drs_pkt[1].pending_data_slot        = 'hf;
      s2m_drs_pkt[1].s2m_drs_txn.valid        = data[(SLOT2_OFFSET+40)];
      s2m_drs_pkt[1].s2m_drs_txn.memopcode    = data[(SLOT2_OFFSET+43):(SLOT2_OFFSET+41)];
      s2m_drs_pkt[1].s2m_drs_txn.metafield    = data[(SLOT2_OFFSET+45):(SLOT2_OFFSET+44)];
      s2m_drs_pkt[1].s2m_drs_txn.metavalue    = data[(SLOT2_OFFSET+47):(SLOT2_OFFSET+46)];
      s2m_drs_pkt[1].s2m_drs_txn.tag          = data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+48)];
      s2m_drs_pkt[1].s2m_drs_txn.poison       = data[(SLOT2_OFFSET+64)];
      s2m_drs_pkt[2].pending_data_slot        = 'hf;
      s2m_drs_pkt[2].s2m_drs_txn.valid        = data[(SLOT2_OFFSET+80)];
      s2m_drs_pkt[2].s2m_drs_txn.memopcode    = data[(SLOT2_OFFSET+83):(SLOT2_OFFSET+81)];
      s2m_drs_pkt[2].s2m_drs_txn.metafield    = data[(SLOT2_OFFSET+85):(SLOT2_OFFSET+84)];
      s2m_drs_pkt[2].s2m_drs_txn.metavalue    = data[(SLOT2_OFFSET+87):(SLOT2_OFFSET+86)];
      s2m_drs_pkt[2].s2m_drs_txn.tag          = data[(SLOT2_OFFSET+103):(SLOT2_OFFSET+88)];
      s2m_drs_pkt[2].s2m_drs_txn.poison       = data[(SLOT2_OFFSET+104)];
    end else if(slot_sel == 'h3) begin
      s2m_drs_pkt[0].pending_data_slot        = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid        = data[(SLOT3_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.memopcode    = data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)];
      s2m_drs_pkt[0].s2m_drs_txn.metafield    = data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)];
      s2m_drs_pkt[0].s2m_drs_txn.metavalue    = data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)];
      s2m_drs_pkt[0].s2m_drs_txn.tag          = data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison       = data[(SLOT3_OFFSET+24)];
      s2m_drs_pkt[1].pending_data_slot        = 'hf;
      s2m_drs_pkt[1].s2m_drs_txn.valid        = data[(SLOT3_OFFSET+40)];
      s2m_drs_pkt[1].s2m_drs_txn.memopcode    = data[(SLOT3_OFFSET+43):(SLOT3_OFFSET+41)];
      s2m_drs_pkt[1].s2m_drs_txn.metafield    = data[(SLOT3_OFFSET+45):(SLOT3_OFFSET+44)];
      s2m_drs_pkt[1].s2m_drs_txn.metavalue    = data[(SLOT3_OFFSET+47):(SLOT3_OFFSET+46)];
      s2m_drs_pkt[1].s2m_drs_txn.tag          = data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+48)];
      s2m_drs_pkt[1].s2m_drs_txn.poison       = data[(SLOT3_OFFSET+64)];
      s2m_drs_pkt[2].pending_data_slot        = 'hf;
      s2m_drs_pkt[2].s2m_drs_txn.valid        = data[(SLOT3_OFFSET+80)];
      s2m_drs_pkt[2].s2m_drs_txn.memopcode    = data[(SLOT3_OFFSET+83):(SLOT3_OFFSET+81)];
      s2m_drs_pkt[2].s2m_drs_txn.metafield    = data[(SLOT3_OFFSET+85):(SLOT3_OFFSET+84)];
      s2m_drs_pkt[2].s2m_drs_txn.metavalue    = data[(SLOT3_OFFSET+87):(SLOT3_OFFSET+86)];
      s2m_drs_pkt[2].s2m_drs_txn.tag          = data[(SLOT3_OFFSET+103):(SLOT3_OFFSET+88)];
      s2m_drs_pkt[2].s2m_drs_txn.poison       = data[(SLOT3_OFFSET+104)];
    end else begin
      s2m_drs_pkt[0].s2m_drs_txn.valid = 'hX;
      s2m_drs_pkt[1].s2m_drs_txn.valid = 'hX;
      s2m_drs_pkt[2].s2m_drs_txn.valid = 'hX;
    end

  endfunction

  always@(posedge host_rx_dl_if.clk) begin
    if(!host_rx_dl_if.rstn) begin
      //TODO: not sure if this foreach will initialize for all indeces
      foreach(data_slot[i]) data_slot[i] <= 'h0;
      foreach(data_slot_d[i]) data_slot_d[i] <= 'h0;
    end else begin
      if(host_rx_dl_if_d.valid && retryable_flit) begin
        data_slot[0] <= data_slot[1]; 
        data_slot[1] <= data_slot[2]; 
        data_slot[2] <= data_slot[3]; 
        data_slot[3] <= data_slot[4]; 
        data_slot[4] <= 'h0;
      end
      data_slot_d[0] <= data_slot[0];
      data_slot_d[1] <= data_slot[1];
      data_slot_d[2] <= data_slot[2];
      data_slot_d[3] <= data_slot[3];
      data_slot_d[4] <= data_slot[4];
      d2h_data_pkt_d[0].pending_data_slot <= d2h_data_pkt[0].pending_data_slot;
      d2h_data_pkt_d[1].pending_data_slot <= d2h_data_pkt[1].pending_data_slot;
      d2h_data_pkt_d[2].pending_data_slot <= d2h_data_pkt[2].pending_data_slot;
      d2h_data_pkt_d[3].pending_data_slot <= d2h_data_pkt[3].pending_data_slot;
      s2m_drs_pkt_d[0].pending_data_slot  <= s2m_drs_pkt[0].pending_data_slot;
      s2m_drs_pkt_d[1].pending_data_slot  <= s2m_drs_pkt[1].pending_data_slot;
      s2m_drs_pkt_d[2].pending_data_slot  <= s2m_drs_pkt[2].pending_data_slot;
    end
  end

  //TODO: put the packing logic restrictions in the arbiter logic itself so here I do not need to worry why I am getting illegal pkts we can have assertions to catch the max sub pkts that can be packed
  //TODO: put asserts to catch if there any illegal values on Hslots or Gslots otherwise bellow logic will be very hard to debug
  always_comb begin
    if(host_rx_dl_if_d.valid && retryable_flit &&
        (!data_slot_d[0][3] || 
          ((data_slot_d[0] == 'hf) && 
            ((d2h_data_pkt_d[0].pending_data_slot == 0) && (s2m_drs_pkt_d[0].pending_data_slot == 0)) &&
            ((d2h_data_pkt_d[1].pending_data_slot == 0) && (s2m_drs_pkt_d[1].pending_data_slot == 0)) &&
            ((d2h_data_pkt_d[2].pending_data_slot == 0) && (s2m_drs_pkt_d[2].pending_data_slot == 0)) &&
            ((d2h_data_pkt_d[3].pending_data_slot == 0))
          )
        )
      ) begin 
      if(host_rx_dl_if_d.data[7:5] == 'h4) begin
        data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;//need to add what happens when slot 1 is g slot
        if((host_rx_dl_if_d.data[10:8] == 'h1) || (host_rx_dl_if_d.data[10:8] == 'h5)) begin
          data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
          if((host_rx_dl_if_d.data[13:11] == 'h1) || (host_rx_dl_if_d.data[13:11] == 'h5)) begin
            data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            if((host_rx_dl_if_d.data[16:14] == 'h1) || (host_rx_dl_if_d.data[16:14] == 'h5)) begin
              data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            end else if((host_rx_dl_if_d.data[16:14] == 'h2) || (host_rx_dl_if_d.data[16:14] == 'h4)) begin  
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            end else if(host_rx_dl_if_d.data[16:14] == 'h6) begin  
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h0;
            end else begin
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'hf;
            end
          end else if((host_rx_dl_if_d.data[10:8] == 'h2) || (host_rx_dl_if_d.data[10:8] == 'h4)) begin  
            data_slot[0] = 'h8; data_slot[1] = 'h7; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
          end else if(host_rx_dl_if_d.data[10:8] == 'h6) begin  
            data_slot[0] = 'h8; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'h7; data_slot[4] = 'h0;
          end else begin
            data_slot[0] = 'h8; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h7;
          end
        end else if((host_rx_dl_if_d.data[10:8] == 'h2) || (host_rx_dl_if_d.data[10:8] == 'h4)) begin  
          data_slot[0] = 'hc; data_slot[1] = 'h3; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
        end else if(host_rx_dl_if_d.data[10:8] == 'h6) begin  
          data_slot[0] = 'hc; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'h3; data_slot[4] = 'h0;
        end else begin
          data_slot[0] = 'hc; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h3;
        end
      end else if((host_rx_dl_if_d.data[7:5] == 'h0) || (host_rx_dl_if_d.data[7:5] == 'h1) || (host_rx_dl_if_d.data[7:5] == 'h3)) begin
        data_slot[0] = 'he; data_slot[1] = 'h1; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
      end else if(host_rx_dl_if_d.data[7:5] == 'h5) begin
        data_slot[0] = 'he; data_slot[1] = 'hf; data_slot[2] = 'h1; data_slot[3] = 'h0; data_slot[4] = 'h0;
      end else begin
        data_slot[0] = 'he; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h1;
      end
    //end else if(host_rx_dl_if_d.valid && data_slot_d[0][0] /*&& data_slot_d[0][1] && data_slot_d[0][2] && data_slot_d[0][3]*/) begin
      //data_slot[0] = data_slot[1]; data_slot[1] = data_slot[2]; data_slot[3] = data_slot[4]; data_slot[4] = 'h0;
    end
  
    if(host_rx_dl_if_d.valid && retryable_flit) begin
      if(!data_slot[0][0]) begin
        d2h_req_ptr = 'h0;
        d2h_rsp_ptr = 'h0;
        d2h_data_ptr = 'h0;
        s2m_ndr_ptr = 'h0;
        s2m_drs_ptr = 'h0;
        case(host_rx_dl_if_d.data[7:5])
          'h0: begin
            header0(host_rx_dl_if_d.data, d2h_data_pkt, d2h_data_ptr, d2h_rsp_pkt[2], d2h_rsp_ptr, s2m_ndr_pkt, s2m_ndr_ptr);
            d2h_data_ptr = d2h_data_ptr + 1;
            d2h_rsp_ptr = d2h_rsp_ptr + 2;
            s2m_ndr_ptr = s2m_ndr_ptr + 1; 
          end
          'h1: begin
            header1(host_rx_dl_if_d.data, d2h_req_pkt, d2h_req_ptr, d2h_data_pkt, d2h_data_ptr);
            d2h_req_ptr = d2h_req_ptr + 1;
            d2h_data_ptr = d2h_data_ptr + 1;
          end
          'h2: begin
            header2(host_rx_dl_if_d.data, d2h_data_pkt[4], d2h_data_ptr, d2h_rsp_pkt, d2h_rsp_ptr);
            d2h_data_ptr = d2h_data_ptr + 4;
            d2h_rsp_ptr = d2h_rsp_ptr + 1;
          end
          'h3: begin
            header3(host_rx_dl_if_d.data, s2m_drs_pkt, s2m_drs_ptr, s2m_ndr_pkt, s2m_ndr_ptr);
            s2m_drs_ptr = s2m_drs_ptr + 1;
            s2m_ndr_ptr = s2m_ndr_ptr + 1;
          end
          'h4: begin
            header4(host_rx_dl_if_d.data, s2m_ndr_pkt[2], s2m_ndr_ptr);
            s2m_ndr_ptr = s2m_ndr_ptr + 2;
          end
          'h5: begin
            header5(host_rx_dl_if_d.data, s2m_drs_pkt[2], s2m_drs_ptr);
            s2m_drs_ptr = s2m_drs_ptr + 2;
          end
          default: begin

          end
        endcase
        case(host_rx_dl_if_d.data[10:8])
          'h0: begin
            generic0('h1, host_rx_dl_if_d.data, d2h_data_pkt[4], d2h_data_ptr, s2m_drs_pkt[4], s2m_drs_ptr);
            //d2h_data_ptr = d2h_data_ptr + 4;
            //s2m_drs_ptr = s2m_drs_ptr + 1;
          end
          'h1: begin
            generic1('h1, host_rx_dl_if_d.data, d2h_req_pkt, d2h_req_ptr, d2h_rsp_pkt[2], d2h_rsp_ptr);
            d2h_req_ptr = d2h_req_ptr + 1;
            d2h_rsp_ptr = d2h_rsp_ptr + 2;
          end
          'h2: begin
            generic2('h1, host_rx_dl_if_d.data, d2h_req_pkt, d2h_req_ptr, d2h_data_pkt, d2h_data_ptr, d2h_rsp_pkt, d2h_rsp_ptr);
            d2h_req_ptr = d2h_req_ptr + 1;
            d2h_data_ptr = d2h_data_ptr + 1;
            d2h_rsp_ptr = d2h_rsp_ptr + 1;
          end
          'h3: begin
            generic3('h1, host_rx_dl_if_d.data, d2h_data_pkt[4], d2h_data_ptr);
            d2h_data_ptr = d2h_data_ptr + 4;
          end
          'h4: begin
            generic4('h1, host_rx_dl_if_d.data, s2m_drs_pkt, s2m_drs_ptr, s2m_ndr_pkt[2], s2m_ndr_ptr);
            s2m_drs_ptr = s2m_drs_ptr + 1;
            s2m_ndr_ptr = s2m_ndr_ptr + 2;
          end
          'h5: begin
            generic5('h1, host_rx_dl_if_d.data, s2m_ndr_pkt[3], s2m_ndr_ptr);
            s2m_ndr_ptr = s2m_ndr_ptr + 3;
          end
          'h6: begin
            generic6('h1, host_rx_dl_if_d.data, s2m_drs_pkt[3], s2m_drs_ptr);
            s2m_drs_ptr = s2m_drs_ptr + 3;
          end
          default: begin
          
          end
        endcase
        case(host_rx_dl_if_d.data[13:11])
          'h0: begin
            generic0('h2, host_rx_dl_if_d.data, d2h_data_pkt[4], d2h_data_ptr, s2m_drs_pkt[4], s2m_drs_ptr);
            //d2h_data_ptr = d2h_data_ptr + 4;
            //s2m_drs_ptr = s2m_drs_ptr + 1;
          end
          'h1: begin
            generic1('h2, host_rx_dl_if_d.data, d2h_req_pkt, d2h_req_ptr, d2h_rsp_pkt[2], d2h_rsp_ptr);
            d2h_req_ptr = d2h_req_ptr + 1;
            d2h_rsp_ptr = d2h_rsp_ptr + 2;
          end
          'h2: begin
            generic2('h2, host_rx_dl_if_d.data, d2h_req_pkt, d2h_req_ptr, d2h_data_pkt, d2h_data_ptr, d2h_rsp_pkt, d2h_rsp_ptr);
            d2h_req_ptr = d2h_req_ptr + 1;
            d2h_data_ptr = d2h_data_ptr + 1;
            d2h_rsp_ptr = d2h_rsp_ptr + 1;
          end
          'h3: begin
            generic3('h2, host_rx_dl_if_d.data, d2h_data_pkt[4], d2h_data_ptr);
            d2h_data_ptr = d2h_data_ptr + 4;
          end
          'h4: begin
            generic4('h2, host_rx_dl_if_d.data, s2m_drs_pkt, s2m_drs_ptr, s2m_ndr_pkt[2], s2m_ndr_ptr);
            s2m_drs_ptr = s2m_drs_ptr + 1;
            s2m_ndr_ptr = s2m_ndr_ptr + 2;
          end
          'h5: begin
            generic5('h2, host_rx_dl_if_d.data, s2m_ndr_pkt[3], s2m_ndr_ptr);
            s2m_ndr_ptr = s2m_ndr_ptr + 3;
          end
          'h6: begin
            generic6('h2, host_rx_dl_if_d.data, s2m_drs_pkt[3], s2m_drs_ptr);
            s2m_drs_ptr = s2m_drs_ptr + 3;
          end
          default: begin
          
          end
        endcase
        case(host_rx_dl_if_d.data[16:14])
          'h0: begin
            generic0('h3, host_rx_dl_if_d.data, d2h_data_pkt[4], d2h_data_ptr, s2m_drs_pkt[4], s2m_drs_ptr);
            //d2h_data_ptr = d2h_data_ptr + 4;
            //s2m_drs_ptr = s2m_drs_ptr + 1;
          end
          'h1: begin
            generic1('h3, host_rx_dl_if_d.data, d2h_req_pkt, d2h_req_ptr, d2h_rsp_pkt[2], d2h_rsp_ptr);
            d2h_req_ptr = d2h_req_ptr + 1;
            d2h_rsp_ptr = d2h_rsp_ptr + 2;
          end
          'h2: begin
            generic2('h3, host_rx_dl_if_d.data, d2h_req_pkt, d2h_req_ptr, d2h_data_pkt, d2h_data_ptr, d2h_rsp_pkt, d2h_rsp_ptr);
            d2h_req_ptr = d2h_req_ptr + 1;
            d2h_data_ptr = d2h_data_ptr + 1;
            d2h_rsp_ptr = d2h_rsp_ptr + 1;
          end
          'h3: begin
            generic3('h3, host_rx_dl_if_d.data, d2h_data_pkt[4], d2h_data_ptr);
            d2h_data_ptr = d2h_data_ptr + 4;
          end
          'h4: begin
            generic4('h3, host_rx_dl_if_d.data, s2m_drs_pkt, s2m_drs_ptr, s2m_ndr_pkt[2], s2m_ndr_ptr);
            s2m_drs_ptr = s2m_drs_ptr + 1;
            s2m_ndr_ptr = s2m_ndr_ptr + 2;
          end
          'h5: begin
            generic5('h3, host_rx_dl_if_d.data, s2m_ndr_pkt[3], s2m_ndr_ptr);
            s2m_ndr_ptr = s2m_ndr_ptr + 3;
          end
          'h6: begin
            generic6('h3, host_rx_dl_if_d.data, s2m_drs_pkt[3], s2m_drs_ptr);
            s2m_drs_ptr = s2m_drs_ptr + 3;
          end
          default: begin
          
          end
        endcase
      end else if(data_slot[0][0]) begin
        generic0('h0, host_rx_dl_if_d.data, d2h_data_pkt[4], d2h_data_ptr, s2m_drs_pkt[4], s2m_drs_ptr);
        //d2h_data_ptr = d2h_data_ptr + 4;
        //s2m_drs_ptr = s2m_drs_ptr + 4;
      end
    end
  end

  cxl_lrsm_rrsm cxl_lrsm_rrsm_inst#(

  )(
    .clk(host_rx_dl_if.clk),
    .rstn(host_rx_dl_if.rstn),
    .*
  );

  crc_checker c2c_checker_inst#(

  )(
    .*
  );

  assign retry_frame_detect = (host_rx_dl_if_d.data[39:36] == 'h3) && (host_rx_dl_if_d.data[35:32] = 'h1) && (host_rx_dl_if_d.data[0] == 'h1) && (crc_pass) && (!crc_fail);
  assign retry_idle_detect = (host_rx_dl_if_d.data[39:36] == 'h0) && (host_rx_dl_if_d.data[35:32] = 'h1) && (host_rx_dl_if_d.data[0] == 'h1) && (crc_pass) && (!crc_fail);
  assign retry_req_detect = (host_rx_dl_if_d.data[39:36] == 'h1) && (host_rx_dl_if_d.data[35:32] = 'h1) && (host_rx_dl_if_d.data[0] == 'h1) && (crc_pass) && (!crc_fail);
  assign retry_ack_detect = (host_rx_dl_if_d.data[39:36] == 'h2) && (host_rx_dl_if_d.data[35:32] = 'h1) && (host_rx_dl_if_d.data[0] == 'h1) && (crc_pass) && (!crc_fail);
  assign non_retryable_flit = (retry_frame_idle) || (retry_frame_detect) || (retry_req_detect) || (retry_ack_detect);
  assign retryable_flit = (!retry_frame_idle) && (!retry_frame_detect) && (!retry_req_detect) && (!retry_ack_detect);
  //TODO: serious mistake I am assuming only one side of the link can have error at a time

  always@(posedge host_rx_dl_if.clk) begin
    if(!host_rx_dl_if.rstn) begin
      host_rx_dl_if_d.valid <= 'h0;
      host_rx_dl_if_d.data <= 'h0;
    end else begin
      host_rx_dl_if_d.valid <= host_rx_dl_if.valid;
      host_rx_dl_if_d.data <= host_rx_dl_if.data;
      if(host_rx_dl_if_d.valid) begin
        case(retry_frame_states) 
        RETRY_NOFRAME: begin
          retry_req_rcvd <= 'h0;
          retry_ack_rcvd <= 'h0;
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME1;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME1: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME2;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME2: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME3;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME3: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME4;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME4: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME5;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME5: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME5;
          end else if(retry_req_detect) begin
            retry_frame_states <= RETRY_NOFRAME;
            retry_req_rcvd <= 'h1;
            retry_frame_states <= RETRY_NOFRAME;
          end else if(retry_ack_detect) begin
            retry_ack_rcvd <= 'h1;
            retry_ack_empty_bit <= host_rx_dl_if_d.data[64];
            retry_ack_num_retry <= host_rx_dl_if_d.data[71:67];
            retry_frame_states <= RETRY_NOFRAME;
          end else begin
            retry_req_rcvd <= 'h0;
            retry_ack_rcvd <= 'h0;
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        default: begin
            retry_frame_states <= 'hX;
        end
        endcase
      end
    end
  end

endmodule

module device_rx_path #(

)(
  cxl_dev_rx_dl_if.rx_mp dev_rx_dl_if,
  output logic retry_ack_snt,
  output logic retry_req_snt,
  output logic phy_link_rst,
  input logic phy_rst,
  input logic phy_reinit,
  input logic phy_link_up,
  output h2d_req_txn_t h2d_req_pkt[2],
  output h2d_rsp_txn_t h2d_rsp_pkt[4],
  output h2d_data_txn_t h2d_data_pkt[4],
  output m2s_req_txn_t m2s_req_pkt[2],
  output m2s_rwd_txn_t m2s_rwd_pkt
);

  typedef enum {
    RETRY_NOFRAME,
    RETRY_FRAME1,
    RETRY_FRAME2,
    RETRY_FRAME3,
    RETRY_FRAME4,
    RETRY_FRAME5
  } retry_frame_states_t;
  retry_frame_states_t retry_frame_states;
  logic crc_pass;
  logic crc_fail;
  logic retryable_flit;
  logic non_retryable_flit;
  logic retry_req_rcvd;
  logic retry_req_snt;
  logic [7:0] retry_ack_num_retry;
  logic retry_ack_empty_bit;
  logic retry_ack_rcvd;
  logic retry_ack_snt;
  cxl_dev_rx_dl_if.rx_mp dev_rx_dl_if_d;//assuming crc checker takes 1 cycle to tell crc pass or fail
  logic retry_frame_detect;
  logic retry_req_detect;
  logic retry_ack_detect;
  logic retry_idle_detect;
  logic data_slot[5];
  logic data_slot_d[5];
  h2d_data_pkt_t h2d_data_pkt_d[4];
  m2s_rwd_txn_t m2s_rwd_pkt_d;
  logic [1:0] h2d_req_ptr;
  logic [1:0] h2d_rsp_ptr;
  logic [1:0] h2d_data_ptr;
  logic [1:0] m2s_req_ptr;
  logic [1:0] m2s_rwd_ptr;

  function void header0(
    input logic [511:0] data,
    output h2d_req_txn_t h2d_req_txn,
    output h2d_rsp_txn_t h2d_rsp_txn
  );
    h2d_req_txn.valid        = data[32];
    h2d_req_txn.opcode       = data[35:33];
    h2d_req_txn.address      = data[81:36];
    h2d_req_txn.uqid         = data[93:82];
    h2d_rsp_txn.valid        = data[96];
    h2d_rsp_txn.opcode       = data[100:97];
    h2d_rsp_txn.rspdata      = data[112:101];
    h2d_rsp_txn.rsppre       = data[114:113];
    h2d_rsp_txn.cqid         = data[126:115];
  endfunction

  function void header1(
    input logic [511:0] data,
    output h2d_data_pkt_t h2d_data_pkt,
    output h2d_rsp_txn_t h2d_rsp_txn[2]
  );
    h2d_data_pkt.pending_data_slot        = 'hf;
    h2d_data_pkt.h2d_data_txn.valid       = data[32];
    h2d_data_pkt.h2d_data_txn.cqid        = data[44:33];
    h2d_data_pkt.h2d_data_txn.chunkvalid  = data[45];
    h2d_data_pkt.h2d_data_txn.poison      = data[46];
    h2d_data_pkt.h2d_data_txn.goerr       = data[47];
    h2d_rsp_txn[0].valid                  = data[56];
    h2d_rsp_txn[0].opcode                 = data[60:57];
    h2d_rsp_txn[0].rspdata                = data[72:61];
    h2d_rsp_txn[0].rsppre                 = data[74:73];
    h2d_rsp_txn[0].cqid                   = data[86:75];
    h2d_rsp_txn[1].valid                  = data[88];
    h2d_rsp_txn[1].opcode                 = data[92:89];
    h2d_rsp_txn[1].rspdata                = data[104:93];
    h2d_rsp_txn[1].rsppre                 = data[106:105];
    h2d_rsp_txn[1].cqid                   = data[118:107];

  endfunction

  function void header2(
    input logic [511:0] data,
    output h2d_req_txn_t h2d_req_txn,
    output h2d_data_pkt_t h2d_data_pkt
  );
    h2d_req_txn.valid                     = data[32];
    h2d_req_txn.opcode                    = data[35:33];
    h2d_req_txn.address                   = data[81:36];
    h2d_req_txn.uqid                      = data[93:82];
    h2d_data_pkt.h2d_data_txn.valid       = data[96];
    h2d_data_pkt.h2d_data_txn.cqid        = data[108:97];
    h2d_data_pkt.h2d_data_txn.chunkvalid  = data[109];
    h2d_data_pkt.h2d_data_txn.poison      = data[110];
    h2d_data_pkt.h2d_data_txn.goerr       = data[111];
  endfunction

  function void header3(
    input logic [511:0] data,
    output h2d_data_pkt_t h2d_data_pkt[4]
  );

    h2d_data_pkt[0].pending_data_slot        = 'hf;
    h2d_data_pkt[0].h2d_data_txn.valid       = data[32];
    h2d_data_pkt[0].h2d_data_txn.cqid        = data[44:33];
    h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[45];
    h2d_data_pkt[0].h2d_data_txn.poison      = data[46];
    h2d_data_pkt[0].h2d_data_txn.goerr       = data[47];
    h2d_data_pkt[1].pending_data_slot        = 'hf;
    h2d_data_pkt[1].h2d_data_txn.valid       = data[56];
    h2d_data_pkt[1].h2d_data_txn.cqid        = data[68:57];
    h2d_data_pkt[1].h2d_data_txn.chunkvalid  = data[69];
    h2d_data_pkt[1].h2d_data_txn.poison      = data[70];
    h2d_data_pkt[1].h2d_data_txn.goerr       = data[71];
    h2d_data_pkt[2].pending_data_slot        = 'hf;
    h2d_data_pkt[2].h2d_data_txn.valid       = data[80];
    h2d_data_pkt[2].h2d_data_txn.cqid        = data[92:81];
    h2d_data_pkt[2].h2d_data_txn.chunkvalid  = data[93];
    h2d_data_pkt[2].h2d_data_txn.poison      = data[94];
    h2d_data_pkt[2].h2d_data_txn.goerr       = data[95];
    h2d_data_pkt[3].pending_data_slot        = 'hf;
    h2d_data_pkt[3].h2d_data_txn.valid       = data[104];
    h2d_data_pkt[3].h2d_data_txn.cqid        = data[116:105];
    h2d_data_pkt[3].h2d_data_txn.chunkvalid  = data[117];
    h2d_data_pkt[3].h2d_data_txn.poison      = data[118];
    h2d_data_pkt[3].h2d_data_txn.goerr       = data[119];
    
  endfunction

  function void header4(
    input logic [511:0] data,
    output m2s_rwd_pkt_t m2s_rwd_pkt
  );
    m2s_rwd_pkt.pending_data_slot        = 'hf;
    m2s_rwd_pkt.m2s_rwd_txn.valid        = data[32];
    m2s_rwd_pkt.m2s_rwd_txn.memopcode    = data[36:33];
    m2s_rwd_pkt.m2s_rwd_txn.snptype      = data[39:37];
    m2s_rwd_pkt.m2s_rwd_txn.metafield    = data[41:40];
    m2s_rwd_pkt.m2s_rwd_txn.metavalue    = data[43:42];
    m2s_rwd_pkt.m2s_rwd_txn.tag          = data[58:44];
    m2s_rwd_pkt.m2s_rwd_txn.address      = data[105:59];
    m2s_rwd_pkt.m2s_rwd_txn.poison       = data[106];
    m2s_rwd_pkt.m2s_rwd_txn.tc           = data[108:107];

  endfunction

  function void header5(
    input logic [511:0] data,
    output m2s_req_txn_t m2s_req_txn
  );
    m2s_req_txn.valid        = data[32];
    m2s_req_txn.memopcode    = data[36:33];
    m2s_req_txn.snptype      = data[39:37];
    m2s_req_txn.metafield    = data[41:40];
    m2s_req_txn.metavalue    = data[43:42];
    m2s_req_txn.tag          = data[58:44];
    m2s_req_txn.address      = data[106:59];
    m2s_req_txn.tc           = data[108:107];
  endfunction

  function void generic0(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    inout h2d_data_pkt_t h2d_data_pkt[4],
    inout m2s_rwd_pkt_t m2s_rwd_pkt
  );
    if(m2s_rwd_pkt[0].pending_data_slot == 'hf) begin
      if(slot_sel == 1) begin
        m2s_rwd_pkt[0].m2s_rwd_txn.data[SLOT3_OFFSET-1:0] = data[SLOT3_OFFSET-1:0]; 
        m2s_rwd_pkt[0].pending_data_slot = 'h8;
      end else if(slot_sel == 2) begin
        m2s_rwd_pkt[0].m2s_rwd_txn.data[SLOT2_OFFSET-1:0] = data[SLOT2_OFFSET-1:0]; 
        m2s_rwd_pkt[0].pending_data_slot = 'hc;
      end else if(slot_sel == 3) begin
        m2s_rwd_pkt[0].m2s_rwd_txn.data[SLOT1_OFFSET-1:0] = data[SLOT1_OFFSET-1:0]; 
        m2s_rwd_pkt[0].pending_data_slot = 'he;
      end else if(slot_sel == 0) begin
        m2s_rwd_pkt[0].m2s_rwd_txn.data = data; 
        m2s_rwd_pkt[0].pending_data_slot = 'h0;
      end 
    end else if(m2s_rwd_pkt[0].pending_data_slot == 'he) begin
      m2s_rwd_pkt[0].m2s_rwd_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]; 
      m2s_rwd_pkt[0].pending_data_slot = 'h0;
      /*TODO: next gen upgrade logic
      if(m2s_rwd_pkt[1].pending_data_slot != 0) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
        m2s_rwd_pkt[1].pending_data_slot = 'he;
      end*/
    end else if(m2s_rwd_pkt[0].pending_data_slot == 'hc) begin
      m2s_rwd_pkt[0].m2s_rwd_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]; 
      m2s_rwd_pkt[0].pending_data_slot = 'h0;
      //TODO:maybe for future gen where size of rwd is > 1
      /*if(m2s_rwd_pkt[1].pending_data_slot != 0) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
        m2s_rwd_pkt[1].pending_data_slot = 'hc;
      end*/
    end else if(m2s_rwd_pkt[0].pending_data_slot == 'h8) begin
      m2s_rwd_pkt[0].m2s_rwd_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]; 
      m2s_rwd_pkt[0].pending_data_slot = 'h0;
      //TODO:maybe for future gen where size of rwd is > 1
      /*if(m2s_rwd_pkt[1].pending_data_slot != 0) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
        m2s_rwd_pkt[1].pending_data_slot = 'h8;
      end*/
    end else begin
      //TODO:maybe for future gen where size of rwd is > 1
      /*if(m2s_rwd_pkt[1].pending_data_slot == 'hf) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data = data;
        m2s_rwd_pkt[1].pending_data_slot = 'h0;
      end else if(m2s_rwd_pkt[1].pending_data_slot == 'he) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
        m2s_rwd_pkt[1].pending_data_slot = 'h0;
        if(m2s_rwd_pkt[2].pending_data_slot != 'h0) begin
          m2s_rwd_pkt[2].m2s_rwd_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
          m2s_rwd_pkt[2].pending_data_slot = 'he;
        end
      end else if(m2s_rwd_pkt[1].pending_data_slot == 'hc) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
        m2s_rwd_pkt[1].pending_data_slot = 'h0;
        if(m2s_rwd_pkt[2].pending_data_slot != 'h0) begin
          m2s_rwd_pkt[2].m2s_rwd_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
          m2s_rwd_pkt[2].pending_data_slot = 'hc;
        end
      end else if(m2s_rwd_pkt[1].pending_data_slot == 'h8) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
        m2s_rwd_pkt[1].pending_data_slot = 'h0;
        if(m2s_rwd_pkt[2].pending_data_slot != 'h0) begin
          m2s_rwd_pkt[2].m2s_rwd_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
          m2s_rwd_pkt[2].pending_data_slot = 'h8;
        end
      end else begin
        if(m2s_rwd_pkt[2].pending_data_slot == 'hf) begin
          m2s_rwd_pkt[2].m2s_rwd_txn.data = data;
          m2s_rwd_pkt[2].pending_data_slot = 'h0;
        end else if(m2s_rwd_pkt[2].pending_data_slot == 'he) begin
          m2s_rwd_pkt[2].m2s_rwd_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]
          m2s_rwd_pkt[2].pending_data_slot = 'h0;
          if(m2s_rwd_pkt[3].pending_data_slot != 'h0) begin
            m2s_rwd_pkt[3].m2s_rwd_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
            m2s_rwd_pkt[3].pending_data_slot = 'he;
          end
        end else if(m2s_rwd_pkt[2].pending_data_slot == 'hc) begin
          m2s_rwd_pkt[2].m2s_rwd_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]
          m2s_rwd_pkt[2].pending_data_slot = 'h0;
          if(m2s_rwd_pkt[3].pending_data_slot != 'h0) begin
            m2s_rwd_pkt[3].m2s_rwd_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
            m2s_rwd_pkt[3].pending_data_slot = 'hc;
          end
        end else if(m2s_rwd_pkt[2].pending_data_slot == 'h8) begin
          m2s_rwd_pkt[2].m2s_rwd_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]
          m2s_rwd_pkt[2].pending_data_slot = 'h0;
          if(m2s_rwd_pkt[3].pending_data_slot != 'h0) begin
            m2s_rwd_pkt[3].m2s_rwd_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
            m2s_rwd_pkt[3].pending_data_slot = 'h8;
          end
        end else begin
          if(m2s_rwd_pkt[3].pending_data_slot == 'hf) begin
            m2s_rwd_pkt[3].m2s_rwd_txn.data = data;
            m2s_rwd_pkt[3].pending_data_slot = 'h0;
          end else if(m2s_rwd_pkt[3].pending_data_slot == 'he) begin
            m2s_rwd_pkt[3].m2s_rwd_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
            m2s_rwd_pkt[3].pending_data_slot = 'h0;
          end else if(m2s_rwd_pkt[3].pending_data_slot == 'hc) begin
            m2s_rwd_pkt[3].m2s_rwd_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
            m2s_rwd_pkt[3].pending_data_slot = 'h0;
          end else if(m2s_rwd_pkt[3].pending_data_slot == 'h8) begin
            m2s_rwd_pkt[3].m2s_rwd_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
            m2s_rwd_pkt[3].pending_data_slot = 'h0;
          end else begin
            
          end
        end
      end*/
    end

    if(h2d_data_pkt[0].pending_data_slot == 'hf) begin
      if(slot_sel == 1) begin
        h2d_data_pkt[0].h2d_data_txn.data[SLOT3_OFFSET-1:0] = data[SLOT3_OFFSET-1:0]; 
        h2d_data_pkt[0].pending_data_slot = 'h8;
      end else if(slot_sel == 2) begin
        h2d_data_pkt[0].h2d_data_txn.data[SLOT2_OFFSET-1:0] = data[SLOT2_OFFSET-1:0]; 
        h2d_data_pkt[0].pending_data_slot = 'hc;
      end else if(slot_sel == 3) begin
        h2d_data_pkt[0].h2d_data_txn.data[SLOT1_OFFSET-1:0] = data[SLOT1_OFFSET-1:0]; 
        h2d_data_pkt[0].pending_data_slot = 'he;
      end else if(slot_sel == 0) begin
        h2d_data_pkt[0].h2d_data_txn.data = data; 
        h2d_data_pkt[0].pending_data_slot = 'h0;
      end 
    end else if(h2d_data_pkt[0].pending_data_slot == 'he) begin
      h2d_data_pkt[0].h2d_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]; 
      h2d_data_pkt[0].pending_data_slot = 'h0;
      if(h2d_data_pkt[1].pending_data_slot != 0) begin
        h2d_data_pkt[1].h2d_data_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
        h2d_data_pkt[1].pending_data_slot = 'he;
      end
    end else if(h2d_data_pkt[0].pending_data_slot == 'hc) begin
      h2d_data_pkt[0].h2d_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]; 
      h2d_data_pkt[0].pending_data_slot = 'h0;
      if(h2d_data_pkt[1].pending_data_slot != 0) begin
        h2d_data_pkt[1].h2d_data_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
        h2d_data_pkt[1].pending_data_slot = 'hc;
      end
    end else if(h2d_data_pkt[0].pending_data_slot == 'h8) begin
      h2d_data_pkt[0].h2d_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]; 
      h2d_data_pkt[0].pending_data_slot = 'h0;
      if(h2d_data_pkt[1].pending_data_slot != 0) begin
        h2d_data_pkt[1].h2d_data_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
        h2d_data_pkt[1].pending_data_slot = 'h8;
      end
    end else begin
      if(h2d_data_pkt[1].pending_data_slot == 'hf) begin
        h2d_data_pkt[1].h2d_data_txn.data = data;
        h2d_data_pkt[1].pending_data_slot = 'h0;
      end else if(h2d_data_pkt[1].pending_data_slot == 'he) begin
        h2d_data_pkt[1].h2d_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
        h2d_data_pkt[1].pending_data_slot = 'h0;
        if(h2d_data_pkt[2].pending_data_slot != 'h0) begin
          h2d_data_pkt[2].h2d_data_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
          h2d_data_pkt[2].pending_data_slot = 'he;
        end
      end else if(h2d_data_pkt[1].pending_data_slot == 'hc) begin
        h2d_data_pkt[1].h2d_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
        h2d_data_pkt[1].pending_data_slot = 'h0;
        if(h2d_data_pkt[2].pending_data_slot != 'h0) begin
          h2d_data_pkt[2].h2d_data_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
          h2d_data_pkt[2].pending_data_slot = 'hc;
        end
      end else if(h2d_data_pkt[1].pending_data_slot == 'h8) begin
        h2d_data_pkt[1].h2d_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
        h2d_data_pkt[1].pending_data_slot = 'h0;
        if(h2d_data_pkt[2].pending_data_slot != 'h0) begin
          h2d_data_pkt[2].h2d_data_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
          h2d_data_pkt[2].pending_data_slot = 'h8;
        end
      end else begin
        if(h2d_data_pkt[2].pending_data_slot == 'hf) begin
          h2d_data_pkt[2].h2d_data_txn.data = data;
          h2d_data_pkt[2].pending_data_slot = 'h0;
        end else if(h2d_data_pkt[2].pending_data_slot == 'he) begin
          h2d_data_pkt[2].h2d_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]
          h2d_data_pkt[2].pending_data_slot = 'h0;
          if(h2d_data_pkt[3].pending_data_slot != 'h0) begin
            h2d_data_pkt[3].h2d_data_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
            h2d_data_pkt[3].pending_data_slot = 'he;
          end
        end else if(h2d_data_pkt[2].pending_data_slot == 'hc) begin
          h2d_data_pkt[2].h2d_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]
          h2d_data_pkt[2].pending_data_slot = 'h0;
          if(h2d_data_pkt[3].pending_data_slot != 'h0) begin
            h2d_data_pkt[3].h2d_data_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
            h2d_data_pkt[3].pending_data_slot = 'hc;
          end
        end else if(h2d_data_pkt[2].pending_data_slot == 'h8) begin
          h2d_data_pkt[2].h2d_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]
          h2d_data_pkt[2].pending_data_slot = 'h0;
          if(h2d_data_pkt[3].pending_data_slot != 'h0) begin
            h2d_data_pkt[3].h2d_data_txn.data[SLOT3_OFFSET-1:0] = data[511:SLOT1_OFFSET];
            h2d_data_pkt[3].pending_data_slot = 'h8;
          end
        end else begin
          if(h2d_data_pkt[3].pending_data_slot == 'hf) begin
            h2d_data_pkt[3].h2d_data_txn.data = data;
            h2d_data_pkt[3].pending_data_slot = 'h0;
          end else if(h2d_data_pkt[3].pending_data_slot == 'he) begin
            h2d_data_pkt[3].h2d_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
            h2d_data_pkt[3].pending_data_slot = 'h0;
          end else if(h2d_data_pkt[3].pending_data_slot == 'hc) begin
            h2d_data_pkt[3].h2d_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
            h2d_data_pkt[3].pending_data_slot = 'h0;
          end else if(h2d_data_pkt[3].pending_data_slot == 'h8) begin
            h2d_data_pkt[3].h2d_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
            h2d_data_pkt[3].pending_data_slot = 'h0;
          end else begin
            
          end
        end
      end
    end

  endfunction

  function void generic1(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output h2d_rsp_txn_t h2d_rsp_txn[4]
  );

    if(slot_sel == 'h1) begin
      h2d_rsp_txn[0].valid        = data[(SLOT1_OFFSET+0)];
      h2d_rsp_txn[0].opcode       = data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)];
      h2d_rsp_txn[0].rspdata      = data[(SLOT1_OFFSET+16):(SLOT1_OFFSET+5)];
      h2d_rsp_txn[0].rsppre       = data[(SLOT1_OFFSET+18):(SLOT1_OFFSET+17)];
      h2d_rsp_txn[0].cqid         = data[(SLOT1_OFFSET+30):(SLOT1_OFFSET+19)];
      h2d_rsp_txn[1].valid        = data[(SLOT1_OFFSET+32)];
      h2d_rsp_txn[1].opcode       = data[(SLOT1_OFFSET+36):(SLOT1_OFFSET+33)];
      h2d_rsp_txn[1].rspdata      = data[(SLOT1_OFFSET+48):(SLOT1_OFFSET+37)];
      h2d_rsp_txn[1].rsppre       = data[(SLOT1_OFFSET+50):(SLOT1_OFFSET+49)];
      h2d_rsp_txn[1].cqid         = data[(SLOT1_OFFSET+62):(SLOT1_OFFSET+51)];
      h2d_rsp_txn[2].valid        = data[(SLOT1_OFFSET+64)];
      h2d_rsp_txn[2].opcode       = data[(SLOT1_OFFSET+68):(SLOT1_OFFSET+65)];
      h2d_rsp_txn[2].rspdata      = data[(SLOT1_OFFSET+80):(SLOT1_OFFSET+69)];
      h2d_rsp_txn[2].rsppre       = data[(SLOT1_OFFSET+82):(SLOT1_OFFSET+81)];
      h2d_rsp_txn[2].cqid         = data[(SLOT1_OFFSET+94):(SLOT1_OFFSET+83)];
      h2d_rsp_txn[3].valid        = data[(SLOT1_OFFSET+96)];
      h2d_rsp_txn[3].opcode       = data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+97)];
      h2d_rsp_txn[3].rspdata      = data[(SLOT1_OFFSET+112):(SLOT1_OFFSET+101)];
      h2d_rsp_txn[3].rsppre       = data[(SLOT1_OFFSET+114):(SLOT1_OFFSET+113)];
      h2d_rsp_txn[3].cqid         = data[(SLOT1_OFFSET+126):(SLOT1_OFFSET+115)];
    end else if(slot_sel == 'h2) begin
      h2d_rsp_txn[0].valid        = data[(SLOT2_OFFSET+0)];
      h2d_rsp_txn[0].opcode       = data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)];
      h2d_rsp_txn[0].rspdata      = data[(SLOT2_OFFSET+16):(SLOT2_OFFSET+5)];
      h2d_rsp_txn[0].rsppre       = data[(SLOT2_OFFSET+18):(SLOT2_OFFSET+17)];
      h2d_rsp_txn[0].cqid         = data[(SLOT2_OFFSET+30):(SLOT2_OFFSET+19)];
      h2d_rsp_txn[1].valid        = data[(SLOT2_OFFSET+32)];
      h2d_rsp_txn[1].opcode       = data[(SLOT2_OFFSET+36):(SLOT2_OFFSET+33)];
      h2d_rsp_txn[1].rspdata      = data[(SLOT2_OFFSET+48):(SLOT2_OFFSET+37)];
      h2d_rsp_txn[1].rsppre       = data[(SLOT2_OFFSET+50):(SLOT2_OFFSET+49)];
      h2d_rsp_txn[1].cqid         = data[(SLOT2_OFFSET+62):(SLOT2_OFFSET+51)];
      h2d_rsp_txn[2].valid        = data[(SLOT2_OFFSET+64)];
      h2d_rsp_txn[2].opcode       = data[(SLOT2_OFFSET+68):(SLOT2_OFFSET+65)];
      h2d_rsp_txn[2].rspdata      = data[(SLOT2_OFFSET+80):(SLOT2_OFFSET+69)];
      h2d_rsp_txn[2].rsppre       = data[(SLOT2_OFFSET+82):(SLOT2_OFFSET+81)];
      h2d_rsp_txn[2].cqid         = data[(SLOT2_OFFSET+94):(SLOT2_OFFSET+83)];
      h2d_rsp_txn[3].valid        = data[(SLOT2_OFFSET+96)];
      h2d_rsp_txn[3].opcode       = data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)];
      h2d_rsp_txn[3].rspdata      = data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)];
      h2d_rsp_txn[3].rsppre       = data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)];
      h2d_rsp_txn[3].cqid         = data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)];
    end else if(slot_sel == 'h3) begin
      h2d_rsp_txn[0].valid        = data[(SLOT3_OFFSET+0)];
      h2d_rsp_txn[0].opcode       = data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)];
      h2d_rsp_txn[0].rspdata      = data[(SLOT3_OFFSET+16):(SLOT3_OFFSET+5)];
      h2d_rsp_txn[0].rsppre       = data[(SLOT3_OFFSET+18):(SLOT3_OFFSET+17)];
      h2d_rsp_txn[0].cqid         = data[(SLOT3_OFFSET+30):(SLOT3_OFFSET+19)];
      h2d_rsp_txn[1].valid        = data[(SLOT3_OFFSET+32)];
      h2d_rsp_txn[1].opcode       = data[(SLOT3_OFFSET+36):(SLOT3_OFFSET+33)];
      h2d_rsp_txn[1].rspdata      = data[(SLOT3_OFFSET+48):(SLOT3_OFFSET+37)];
      h2d_rsp_txn[1].rsppre       = data[(SLOT3_OFFSET+50):(SLOT3_OFFSET+49)];
      h2d_rsp_txn[1].cqid         = data[(SLOT3_OFFSET+62):(SLOT3_OFFSET+51)];
      h2d_rsp_txn[2].valid        = data[(SLOT3_OFFSET+64)];
      h2d_rsp_txn[2].opcode       = data[(SLOT3_OFFSET+68):(SLOT3_OFFSET+65)];
      h2d_rsp_txn[2].rspdata      = data[(SLOT3_OFFSET+80):(SLOT3_OFFSET+69)];
      h2d_rsp_txn[2].rsppre       = data[(SLOT3_OFFSET+82):(SLOT3_OFFSET+81)];
      h2d_rsp_txn[2].cqid         = data[(SLOT3_OFFSET+94):(SLOT3_OFFSET+83)];
      h2d_rsp_txn[3].valid        = data[(SLOT3_OFFSET+96)];
      h2d_rsp_txn[3].opcode       = data[(SLOT3_OFFSET+100):(SLOT3_OFFSET+97)];
      h2d_rsp_txn[3].rspdata      = data[(SLOT3_OFFSET+112):(SLOT3_OFFSET+101)];
      h2d_rsp_txn[3].rsppre       = data[(SLOT3_OFFSET+114):(SLOT3_OFFSET+113)];
      h2d_rsp_txn[3].cqid         = data[(SLOT3_OFFSET+126):(SLOT3_OFFSET+115)];    
    end else begin
      h2d_rsp_txn[0].valid = 'hX;
      h2d_rsp_txn[1].valid = 'hX;
      h2d_rsp_txn[2].valid = 'hX;
      h2d_rsp_txn[3].valid = 'hX;
    end

  endfunction

  function void generic2(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output h2d_req_txn_t h2d_req_txn,
    output h2d_data_pkt_t h2d_data_pkt,
    output h2d_rsp_txn_t h2d_rsp_txn
  );

    if(slot_sel == 'h1) begin
      h2d_req_txn.valid                     = data[(SLOT1_OFFSET+0)];
      h2d_req_txn.opcode                    = data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)];
      h2d_req_txn.address                   = data[(SLOT1_OFFSET+49):(SLOT1_OFFSET+4)];
      h2d_req_txn.uqid                      = data[(SLOT1_OFFSET+61)+(SLOT1_OFFSET+50)];
      h2d_data_pkt.pending_data_slot        = 'hf;
      h2d_data_pkt.h2d_data_txn.valid       = data[(SLOT1_OFFSET+64)];
      h2d_data_pkt.h2d_data_txn.cqid        = data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+65)];
      h2d_data_pkt.h2d_data_txn.chunkvalid  = data[(SLOT1_OFFSET+77)];
      h2d_data_pkt.h2d_data_txn.poison      = data[(SLOT1_OFFSET+78)];
      h2d_data_pkt.h2d_data_txn.goerr       = data[(SLOT1_OFFSET+79)];
      h2d_rsp_txn.valid                     = data[(SLOT1_OFFSET+88)];
      h2d_rsp_txn.opcode                    = data[(SLOT1_OFFSET+92):(SLOT1_OFFSET+89)];
      h2d_rsp_txn.rspdata                   = data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+93)];
      h2d_rsp_txn.rsppre                    = data[(SLOT1_OFFSET+106):(SLOT1_OFFSET+105)];
      h2d_rsp_txn.cqid                      = data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+107)];
    end else if(slot_sel == 'h2) begin
      h2d_req_txn.valid                     = data[(SLOT2_OFFSET+0)];
      h2d_req_txn.opcode                    = data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)];
      h2d_req_txn.address                   = data[(SLOT2_OFFSET+49):(SLOT2_OFFSET+4)];
      h2d_req_txn.uqid                      = data[(SLOT2_OFFSET+61)+(SLOT2_OFFSET+50)];
      h2d_data_pkt.pending_data_slot        = 'hf;
      h2d_data_pkt.h2d_data_txn.valid       = data[(SLOT2_OFFSET+64)];
      h2d_data_pkt.h2d_data_txn.cqid        = data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+65)];
      h2d_data_pkt.h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+77)];
      h2d_data_pkt.h2d_data_txn.poison      = data[(SLOT2_OFFSET+78)];
      h2d_data_pkt.h2d_data_txn.goerr       = data[(SLOT2_OFFSET+79)];
      h2d_rsp_txn.valid                     = data[(SLOT2_OFFSET+88)];
      h2d_rsp_txn.opcode                    = data[(SLOT2_OFFSET+92):(SLOT2_OFFSET+89)];
      h2d_rsp_txn.rspdata                   = data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+93)];
      h2d_rsp_txn.rsppre                    = data[(SLOT2_OFFSET+106):(SLOT2_OFFSET+105)];
      h2d_rsp_txn.cqid                      = data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+107)];
    end else if(slot_sel == 'h3) begin
      h2d_req_txn.valid                     = data[(SLOT3_OFFSET+0)];
      h2d_req_txn.opcode                    = data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)];
      h2d_req_txn.address                   = data[(SLOT3_OFFSET+49):(SLOT3_OFFSET+4)];
      h2d_req_txn.uqid                      = data[(SLOT3_OFFSET+61)+(SLOT3_OFFSET+50)];
      h2d_data_pkt.pending_data_slot        = 'hf;
      h2d_data_pkt.h2d_data_txn.valid       = data[(SLOT3_OFFSET+64)];
      h2d_data_pkt.h2d_data_txn.cqid        = data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+65)];
      h2d_data_pkt.h2d_data_txn.chunkvalid  = data[(SLOT3_OFFSET+77)];
      h2d_data_pkt.h2d_data_txn.poison      = data[(SLOT3_OFFSET+78)];
      h2d_data_pkt.h2d_data_txn.goerr       = data[(SLOT3_OFFSET+79)];
      h2d_rsp_txn.valid                     = data[(SLOT3_OFFSET+88)];
      h2d_rsp_txn.opcode                    = data[(SLOT3_OFFSET+92):(SLOT3_OFFSET+89)];
      h2d_rsp_txn.rspdata                   = data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+93)];
      h2d_rsp_txn.rsppre                    = data[(SLOT3_OFFSET+106):(SLOT3_OFFSET+105)];
      h2d_rsp_txn.cqid                      = data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+107)]; 
    end else begin
      h2d_req_txn.valid = 'hX;
      h2d_data_pkt.h2d_data_txn.valid = 'hX;
      h2d_rsp_txn.valid = 'hX;
    end

  endfunction

  function void generic3(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output h2d_data_pkt_t h2d_data_pkt[4],
    output h2d_rsp_txn_t h2d_rsp_txn
  );

    if(slot_sel == 'h1) begin
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT1_OFFSET+0)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT1_OFFSET+12):(SLOT1_OFFSET+1)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT1_OFFSET+13)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT1_OFFSET+14)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT1_OFFSET+15)];
      h2d_data_pkt[1].pending_data_slot        = 'hf;
      h2d_data_pkt[1].h2d_data_txn.valid       = data[(SLOT1_OFFSET+24)];
      h2d_data_pkt[1].h2d_data_txn.cqid        = data[(SLOT1_OFFSET+36):(SLOT1_OFFSET+25)];
      h2d_data_pkt[1].h2d_data_txn.chunkvalid  = data[(SLOT1_OFFSET+37)];
      h2d_data_pkt[1].h2d_data_txn.poison      = data[(SLOT1_OFFSET+38)];
      h2d_data_pkt[1].h2d_data_txn.goerr       = data[(SLOT1_OFFSET+39)];
      h2d_data_pkt[2].pending_data_slot        = 'hf;
      h2d_data_pkt[2].h2d_data_txn.valid       = data[(SLOT1_OFFSET+48)];
      h2d_data_pkt[2].h2d_data_txn.cqid        = data[(SLOT1_OFFSET+60):(SLOT1_OFFSET+49)];
      h2d_data_pkt[2].h2d_data_txn.chunkvalid  = data[(SLOT1_OFFSET+61)];
      h2d_data_pkt[2].h2d_data_txn.poison      = data[(SLOT1_OFFSET+62)];
      h2d_data_pkt[2].h2d_data_txn.goerr       = data[(SLOT1_OFFSET+63)];
      h2d_data_pkt[3].pending_data_slot        = 'hf;
      h2d_data_pkt[3].h2d_data_txn.valid       = data[(SLOT1_OFFSET+72)];
      h2d_data_pkt[3].h2d_data_txn.cqid        = data[(SLOT1_OFFSET+84):(SLOT1_OFFSET+73)];
      h2d_data_pkt[3].h2d_data_txn.chunkvalid  = data[(SLOT1_OFFSET+85)];
      h2d_data_pkt[3].h2d_data_txn.poison      = data[(SLOT1_OFFSET+86)];
      h2d_data_pkt[3].h2d_data_txn.goerr       = data[(SLOT1_OFFSET+87)];
      h2d_rsp_txn.valid                        = data[(SLOT1_OFFSET+96)];
      h2d_rsp_txn.opcode                       = data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+97)];
      h2d_rsp_txn.rspdata                      = data[(SLOT1_OFFSET+112):(SLOT1_OFFSET+101)];
      h2d_rsp_txn.rsppre                       = data[(SLOT1_OFFSET+114):(SLOT1_OFFSET+113)];
      h2d_rsp_txn.cqid                         = data[(SLOT1_OFFSET+126):(SLOT1_OFFSET+115)];
    end else if(slot_sel == 'h2) begin
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT2_OFFSET+0)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+12):(SLOT2_OFFSET+1)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+13)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT2_OFFSET+14)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+15)];
      h2d_data_pkt[1].pending_data_slot        = 'hf;
      h2d_data_pkt[1].h2d_data_txn.valid       = data[(SLOT2_OFFSET+24)];
      h2d_data_pkt[1].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+36):(SLOT2_OFFSET+25)];
      h2d_data_pkt[1].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+37)];
      h2d_data_pkt[1].h2d_data_txn.poison      = data[(SLOT2_OFFSET+38)];
      h2d_data_pkt[1].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+39)];
      h2d_data_pkt[2].pending_data_slot        = 'hf;
      h2d_data_pkt[2].h2d_data_txn.valid       = data[(SLOT2_OFFSET+48)];
      h2d_data_pkt[2].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+60):(SLOT2_OFFSET+49)];
      h2d_data_pkt[2].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+61)];
      h2d_data_pkt[2].h2d_data_txn.poison      = data[(SLOT2_OFFSET+62)];
      h2d_data_pkt[2].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+63)];
      h2d_data_pkt[3].pending_data_slot        = 'hf;
      h2d_data_pkt[3].h2d_data_txn.valid       = data[(SLOT2_OFFSET+72)];
      h2d_data_pkt[3].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+84):(SLOT2_OFFSET+73)];
      h2d_data_pkt[3].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+85)];
      h2d_data_pkt[3].h2d_data_txn.poison      = data[(SLOT2_OFFSET+86)];
      h2d_data_pkt[3].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+87)];
      h2d_rsp_txn.valid                        = data[(SLOT2_OFFSET+96)];
      h2d_rsp_txn.opcode                       = data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)];
      h2d_rsp_txn.rspdata                      = data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)];
      h2d_rsp_txn.rsppre                       = data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)];
      h2d_rsp_txn.cqid                         = data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)];    
    end else if(slot_sel == 'h3) begin
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT2_OFFSET+0)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+12):(SLOT2_OFFSET+1)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+13)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT2_OFFSET+14)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+15)];
      h2d_data_pkt[1].pending_data_slot        = 'hf;
      h2d_data_pkt[1].h2d_data_txn.valid       = data[(SLOT2_OFFSET+24)];
      h2d_data_pkt[1].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+36):(SLOT2_OFFSET+25)];
      h2d_data_pkt[1].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+37)];
      h2d_data_pkt[1].h2d_data_txn.poison      = data[(SLOT2_OFFSET+38)];
      h2d_data_pkt[1].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+39)];
      h2d_data_pkt[2].pending_data_slot        = 'hf;
      h2d_data_pkt[2].h2d_data_txn.valid       = data[(SLOT2_OFFSET+48)];
      h2d_data_pkt[2].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+60):(SLOT2_OFFSET+49)];
      h2d_data_pkt[2].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+61)];
      h2d_data_pkt[2].h2d_data_txn.poison      = data[(SLOT2_OFFSET+62)];
      h2d_data_pkt[2].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+63)];
      h2d_data_pkt[3].pending_data_slot        = 'hf;
      h2d_data_pkt[3].h2d_data_txn.valid       = data[(SLOT2_OFFSET+72)];
      h2d_data_pkt[3].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+84):(SLOT2_OFFSET+73)];
      h2d_data_pkt[3].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+85)];
      h2d_data_pkt[3].h2d_data_txn.poison      = data[(SLOT2_OFFSET+86)];
      h2d_data_pkt[3].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+87)];
      h2d_rsp_txn.valid                        = data[(SLOT2_OFFSET+96)];
      h2d_rsp_txn.opcode                       = data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)];
      h2d_rsp_txn.rspdata                      = data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)];
      h2d_rsp_txn.rsppre                       = data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)];
      h2d_rsp_txn.cqid                         = data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)];   
    end else begin
      h2d_data_pkt[0].h2d_data_txn.valid = 'hX;
      h2d_data_pkt[1].h2d_data_txn.valid = 'hX;
      h2d_data_pkt[2].h2d_data_txn.valid = 'hX;
      h2d_data_pkt[3].h2d_data_txn.valid = 'hX;
      h2d_rsp_txn.valid                  = 'hX;
    end

  endfunction
  
  function void generic4(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output m2s_req_txn_t m2s_req_txn,
    output h2d_data_pkt_t h2d_data_pkt
  );

    if(slot_sel == 'h1) begin
      m2s_req_txn.valid                     = data[(SLOT1_OFFSET+0)];
      m2s_req_txn.memopcode                 = data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)];
      m2s_req_txn.snptype                   = data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+5)];
      m2s_req_txn.metafield                 = data[(SLOT1_OFFSET+9):(SLOT1_OFFSET+8)];
      m2s_req_txn.metavalue                 = data[(SLOT1_OFFSET+11):(SLOT1_OFFSET+10)];
      m2s_req_txn.tag                       = data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+12)];
      m2s_req_txn.address                   = data[(SLOT1_OFFSET+74):(SLOT1_OFFSET+28)];
      m2s_req_txn.tc                        = data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+75)];
      h2d_data_pkt.pending_data_slot        = 'hf;
      h2d_data_pkt.h2d_data_txn.valid       = data[(SLOT1_OFFSET+88)];
      h2d_data_pkt.h2d_data_txn.cqid        = data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+89)];
      h2d_data_pkt.h2d_data_txn.chunkvalid  = data[(SLOT1_OFFSET+101)];
      h2d_data_pkt.h2d_data_txn.poison      = data[(SLOT1_OFFSET+102)];
      h2d_data_pkt.h2d_data_txn.goerr       = data[(SLOT1_OFFSET+103)];
    end else if(slot_sel == 'h2) begin
      m2s_req_txn.valid                     = data[(SLOT2_OFFSET+0)];
      m2s_req_txn.memopcode                 = data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)];
      m2s_req_txn.snptype                   = data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+5)];
      m2s_req_txn.metafield                 = data[(SLOT2_OFFSET+9):(SLOT2_OFFSET+8)];
      m2s_req_txn.metavalue                 = data[(SLOT2_OFFSET+11):(SLOT2_OFFSET+10)];
      m2s_req_txn.tag                       = data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+12)];
      m2s_req_txn.address                   = data[(SLOT2_OFFSET+74):(SLOT2_OFFSET+28)];
      m2s_req_txn.tc                        = data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+75)];
      h2d_data_pkt.pending_data_slot        = 'hf;
      h2d_data_pkt.h2d_data_txn.valid       = data[(SLOT2_OFFSET+88)];
      h2d_data_pkt.h2d_data_txn.cqid        = data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+89)];
      h2d_data_pkt.h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+101)];
      h2d_data_pkt.h2d_data_txn.poison      = data[(SLOT2_OFFSET+102)];
      h2d_data_pkt.h2d_data_txn.goerr       = data[(SLOT2_OFFSET+103)];
    end else if(slot_sel == 'h3) begin
      m2s_req_txn.valid                     = data[(SLOT3_OFFSET+0)];
      m2s_req_txn.memopcode                 = data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)];
      m2s_req_txn.snptype                   = data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+5)];
      m2s_req_txn.metafield                 = data[(SLOT3_OFFSET+9):(SLOT3_OFFSET+8)];
      m2s_req_txn.metavalue                 = data[(SLOT3_OFFSET+11):(SLOT3_OFFSET+10)];
      m2s_req_txn.tag                       = data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+12)];
      m2s_req_txn.address                   = data[(SLOT3_OFFSET+74):(SLOT3_OFFSET+28)];
      m2s_req_txn.tc                        = data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+75)];
      h2d_data_pkt.pending_data_slot        = 'hf;
      h2d_data_pkt.h2d_data_txn.valid       = data[(SLOT3_OFFSET+88)];
      h2d_data_pkt.h2d_data_txn.cqid        = data[(SLOT3_OFFSET+100):(SLOT3_OFFSET+89)];
      h2d_data_pkt.h2d_data_txn.chunkvalid  = data[(SLOT3_OFFSET+101)];
      h2d_data_pkt.h2d_data_txn.poison      = data[(SLOT3_OFFSET+102)];
      h2d_data_pkt.h2d_data_txn.goerr       = data[(SLOT3_OFFSET+103)];
    end else begin
      m2s_req_txn.valid = 'hX;
      h2d_data_pkt.h2d_data_txn.valid = 'hX;
    end

  endfunction
  
  function void generic5(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    output m2s_rwd_pkt_t m2s_rwd_pkt,
    output h2d_rsp_txn_t h2d_rsp_txn
  );

    if(slot_sel == 'h1) begin
      m2s_rwd_pkt.pending_data_slot        = 'hf;
      m2s_rwd_pkt.m2s_rwd_txn.valid        = data[(SLOT1_OFFSET+0)];
      m2s_rwd_pkt.m2s_rwd_txn.memopcode    = data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)];
      m2s_rwd_pkt.m2s_rwd_txn.snptype      = data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+5)];
      m2s_rwd_pkt.m2s_rwd_txn.metafield    = data[(SLOT1_OFFSET+9):(SLOT1_OFFSET+8)];
      m2s_rwd_pkt.m2s_rwd_txn.metavalue    = data[(SLOT1_OFFSET+11):(SLOT1_OFFSET+10)];
      m2s_rwd_pkt.m2s_rwd_txn.tag          = data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+12)];
      m2s_rwd_pkt.m2s_rwd_txn.address      = data[(SLOT1_OFFSET+73):(SLOT1_OFFSET+28)];
      m2s_rwd_pkt.m2s_rwd_txn.poison       = data[(SLOT1_OFFSET+74)];
      m2s_rwd_pkt.m2s_rwd_txn.tc           = data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+75)];
      h2d_rsp_txn.valid                    = data[(SLOT1_OFFSET+88)];
      h2d_rsp_txn.opcode                   = data[(SLOT1_OFFSET+92):(SLOT1_OFFSET+89)];
      h2d_rsp_txn.rspdata                  = data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+93)];
      h2d_rsp_txn.rsppre                   = data[(SLOT1_OFFSET+106):(SLOT1_OFFSET+105)];
      h2d_rsp_txn.cqid                     = data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+107)];
    end else if(slot_sel == 'h2) begin
      m2s_rwd_pkt.pending_data_slot        = 'hf;
      m2s_rwd_pkt.m2s_rwd_txn.valid        = data[(SLOT2_OFFSET+0)];
      m2s_rwd_pkt.m2s_rwd_txn.memopcode    = data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)];
      m2s_rwd_pkt.m2s_rwd_txn.snptype      = data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+5)];
      m2s_rwd_pkt.m2s_rwd_txn.metafield    = data[(SLOT2_OFFSET+9):(SLOT2_OFFSET+8)];
      m2s_rwd_pkt.m2s_rwd_txn.metavalue    = data[(SLOT2_OFFSET+11):(SLOT2_OFFSET+10)];
      m2s_rwd_pkt.m2s_rwd_txn.tag          = data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+12)];
      m2s_rwd_pkt.m2s_rwd_txn.address      = data[(SLOT2_OFFSET+73):(SLOT2_OFFSET+28)];
      m2s_rwd_pkt.m2s_rwd_txn.poison       = data[(SLOT2_OFFSET+74)];
      m2s_rwd_pkt.m2s_rwd_txn.tc           = data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+75)];
      h2d_rsp_txn.valid                    = data[(SLOT2_OFFSET+88)];
      h2d_rsp_txn.opcode                   = data[(SLOT2_OFFSET+92):(SLOT2_OFFSET+89)];
      h2d_rsp_txn.rspdata                  = data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+93)];
      h2d_rsp_txn.rsppre                   = data[(SLOT2_OFFSET+106):(SLOT2_OFFSET+105)];
      h2d_rsp_txn.cqid                     = data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+107)];
    end else if(slot_sel == 'h3) begin
      m2s_rwd_pkt.pending_data_slot        = 'hf;
      m2s_rwd_pkt.m2s_rwd_txn.valid        = data[(SLOT3_OFFSET+0)];
      m2s_rwd_pkt.m2s_rwd_txn.memopcode    = data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)];
      m2s_rwd_pkt.m2s_rwd_txn.snptype      = data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+5)];
      m2s_rwd_pkt.m2s_rwd_txn.metafield    = data[(SLOT3_OFFSET+9):(SLOT3_OFFSET+8)];
      m2s_rwd_pkt.m2s_rwd_txn.metavalue    = data[(SLOT3_OFFSET+11):(SLOT3_OFFSET+10)];
      m2s_rwd_pkt.m2s_rwd_txn.tag          = data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+12)];
      m2s_rwd_pkt.m2s_rwd_txn.address      = data[(SLOT3_OFFSET+73):(SLOT3_OFFSET+28)];
      m2s_rwd_pkt.m2s_rwd_txn.poison       = data[(SLOT3_OFFSET+74)];
      m2s_rwd_pkt.m2s_rwd_txn.tc           = data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+75)];
      h2d_rsp_txn.valid                    = data[(SLOT3_OFFSET+88)];
      h2d_rsp_txn.opcode                   = data[(SLOT3_OFFSET+92):(SLOT3_OFFSET+89)];
      h2d_rsp_txn.rspdata                  = data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+93)];
      h2d_rsp_txn.rsppre                   = data[(SLOT3_OFFSET+106):(SLOT3_OFFSET+105)];
      h2d_rsp_txn.cqid                     = data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+107)]; 
    end else begin
      m2s_rwd_pkt.m2s_rwd_txn.valid = 'hX;
      h2d_rsp_txn.valid = 'hX;
    end

  endfunction

  always@(posedge dev_rx_dl_if.clk) begin
    if(!dev_rx_dl_if.rstn) begin
      //TODO: not sure if this foreach will initialize for all indeces
      foreach(data_slot[i]) data_slot[i] <= 'h0;
      foreach(data_slot_d[i]) data_slot_d[i] <= 'h0;
    end else begin
      if(dev_rx_dl_if_d.valid && retryable_flit) begin
        data_slot[0] <= data_slot[1];
        data_slot[1] <= data_slot[2];
        data_slot[2] <= data_slot[3];
        data_slot[3] <= data_slot[4];
        data_slot[4] <= 'h0;
      end
      data_slot_d[0] <= data_slot[0];
      data_slot_d[1] <= data_slot[1];
      data_slot_d[2] <= data_slot[2];
      data_slot_d[3] <= data_slot[3];
      data_slot_d[4] <= data_slot[4];
      m2s_rwd_pkt_d.pending_data_slot     <= m2s_rwd_pkt.pending_data_slot;
      h2d_data_pkt_d[0].pending_data_slot <= h2d_data_pkt[0].pending_data_slot;
      h2d_data_pkt_d[1].pending_data_slot <= h2d_data_pkt[1].pending_data_slot;
      h2d_data_pkt_d[2].pending_data_slot <= h2d_data_pkt[2].pending_data_slot;
      h2d_data_pkt_d[3].pending_data_slot <= h2d_data_pkt[3].pending_data_slot;
    end
  end
  
  //TODO: put the packing logic restrictions in the arbiter logic itself so here I do not need to worry why I am getting illegal pkts we can have assertions to catch the max sub pkts that can be packed
  //TODO: put asserts to catch if there any illegal values on Hslots or Gslots otherwise bellow logic will be very hard to debug
  always_comb begin
    if(dev_rx_dl_if_d.valid && retryable_flit && 
        (!data_slot_d[0][3] || 
          ((data_slot_d[0] == 'hf) && 
            (
              (h2d_data_pkt_d[0].pending_data_slot == 'h0) &&
              (h2d_data_pkt_d[1].pending_data_slot == 'h0) &&
              (h2d_data_pkt_d[2].pending_data_slot == 'h0) &&
              (h2d_data_pkt_d[3].pending_data_slot == 'h0) &&
              (m2s_rwd_pkt_d.pending_data_slot == 'h0)
            )
          )
        )
      ) begin 
      if(dev_rx_dl_if_d.data[7:5] == 'h4) begin
        data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;//need to add what happens when slot 1 is g slot
        if((dev_rx_dl_if_d.data[10:8] == 'h1) || (dev_rx_dl_if_d.data[10:8] == 'h5)) begin
          data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
          if((dev_rx_dl_if_d.data[13:11] == 'h1) || (dev_rx_dl_if_d.data[13:11] == 'h5)) begin
            data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            if((dev_rx_dl_if_d.data[16:14] == 'h1) || (dev_rx_dl_if_d.data[16:14] == 'h5)) begin
              data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            end else if((dev_rx_dl_if_d.data[16:14] == 'h2) || (dev_rx_dl_if_d.data[16:14] == 'h4)) begin  
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            end else if(dev_rx_dl_if_d.data[16:14] == 'h6) begin  
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h0;
            end else begin
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'hf;
            end
          end else if((dev_rx_dl_if_d.data[10:8] == 'h2) || (dev_rx_dl_if_d.data[10:8] == 'h4)) begin  
            data_slot[0] = 'h8; data_slot[1] = 'h7; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
          end else if(dev_rx_dl_if_d.data[10:8] == 'h6) begin  
            data_slot[0] = 'h8; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'h7; data_slot[4] = 'h0;
          end else begin
            data_slot[0] = 'h8; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h7;
          end
        end else if((dev_rx_dl_if_d.data[10:8] == 'h2) || (dev_rx_dl_if_d.data[10:8] == 'h4)) begin  
          data_slot[0] = 'hc; data_slot[1] = 'h3; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
        end else if(dev_rx_dl_if_d.data[10:8] == 'h6) begin  
          data_slot[0] = 'hc; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'h3; data_slot[4] = 'h0;
        end else begin
          data_slot[0] = 'hc; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h3;
        end
      end else if((dev_rx_dl_if_d.data[7:5] == 'h0) || (dev_rx_dl_if_d.data[7:5] == 'h1) || (dev_rx_dl_if_d.data[7:5] == 'h3)) begin
        data_slot[0] = 'he; data_slot[1] = 'h1; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
      end else if(dev_rx_dl_if_d.data[7:5] == 'h5) begin
        data_slot[0] = 'he; data_slot[1] = 'hf; data_slot[2] = 'h1; data_slot[3] = 'h0; data_slot[4] = 'h0;
      end else begin
        data_slot[0] = 'he; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h1;
      end
    //end else if(dev_rx_dl_if_d.valid && data_slot_d[0][0] /*&& data_slot_d[0][1] && data_slot_d[0][2] && data_slot_d[0][3]*/) begin
      //data_slot[0] = data_slot[1]; data_slot[1] = data_slot[2]; data_slot[3] = data_slot[4]; data_slot[4] = 'h0;
    end
    
    if(dev_rx_dl_if_d.valid && retryable_flit) begin
      if(!data_slot[0][0]) begin
        case(dev_rx_dl_if_d.data[7:5])
          'h0: begin
            header0(dev_rx_dl_if_d.data, h2d_req_pkt, h2d_req_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            h2d_req_ptr = h2d_req_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          'h1: begin
            header1(dev_rx_dl_if_d.data, h2d_data_pkt, h2d_data_ptr, h2d_rsp_pkt[2], h2d_rsp_ptr);
            h2d_data_ptr = h2d_data_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 2;
          end
          'h2: begin
            header2(dev_rx_dl_if_d.data, h2d_req_pkt, h2d_req_ptr, h2d_data_pkt, h2d_data_ptr);
            h2d_req_ptr = h2d_req_ptr + 1;
            h2d_data_ptr = h2d_data_ptr + 1;
          end
          'h3: begin
            header3(dev_rx_dl_if_d.data, h2d_data_pkt[4], h2d_data_ptr);
            h2d_data_ptr = h2d_data_ptr + 4;
          end
          'h4: begin
            header4(dev_rx_dl_if_d.data, m2s_rwd_pkt, m2s_rwd_ptr);
            m2s_rwd_ptr = m2s_rwd_ptr + 1;
          end
          'h5: begin
            header5(dev_rx_dl_if_d.data, m2s_req_pkt, m2s_req_ptr);
            m2s_req_ptr = m2s_req_ptr + 1;
          end
          default: begin

          end
        endcase
        case(dev_rx_dl_if_d.data[10:8])
          'h0: begin
            generic0('h1, dev_rx_dl_if_d.data, h2d_data_pkt[4], h2d_data_ptr, m2s_rwd_pkt, m2s_rwd_ptr);
            //h2d_data_ptr = h2d_data_ptr + 4;
            //m2s_rwd_ptr = m2s_rwd_ptr + 1;
          end
          'h1: begin
            generic1('h1, dev_rx_dl_if_d.data, h2d_rsp_pkt[4], h2d_rsp_ptr);
            h2d_rsp_ptr = h2d_rsp_ptr + 4;
          end
          'h2: begin
            generic2('h1, dev_rx_dl_if_d.data, h2d_req_pkt, h2d_req_ptr, h2d_data_pkt, h2d_data_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            h2d_req_ptr = h2d_req_ptr + 1;
            h2d_data_ptr = h2d_data_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          'h3: begin
            generic3('h1, dev_rx_dl_if_d.data, h2d_data_pkt[4], h2d_data_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            h2d_data_ptr = h2d_data_ptr + 4;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          'h4: begin
            generic4('h1, dev_rx_dl_if_d.data, m2s_req_pkt, m2s_req_ptr, h2d_data_pkt, h2d_data_ptr);
            m2s_req_ptr = m2s_req_ptr + 1;
            h2d_data_ptr = h2d_data_ptr + 1;
          end
          'h5: begin
            generic5('h1, dev_rx_dl_if_d.data, m2s_rwd_pkt, m2s_rwd_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            m2s_rwd_ptr = m2s_rwd_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          default: begin
          
          end
        endcase
        case(dev_rx_dl_if_d.data[13:11])
          'h0: begin
            generic0('h2, dev_rx_dl_if_d.data, h2d_data_pkt[4], h2d_data_ptr, m2s_rwd_pkt, m2s_rwd_ptr);
            //h2d_data_ptr = h2d_data_ptr + 4;
            //m2s_rwd_ptr = m2s_rwd_ptr + 1;
          end
          'h1: begin
            generic1('h2, dev_rx_dl_if_d.data, h2d_rsp_pkt[4], h2d_rsp_ptr);
            h2d_rsp_ptr = h2d_rsp_ptr + 4;
          end
          'h2: begin
            generic2('h2, dev_rx_dl_if_d.data, h2d_req_pkt, h2d_req_ptr, h2d_data_pkt, h2d_data_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            h2d_req_ptr = h2d_req_ptr + 1;
            h2d_data_ptr = h2d_data_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          'h3: begin
            generic3('h2, dev_rx_dl_if_d.data, h2d_data_pkt[4], h2d_data_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            h2d_data_ptr = h2d_data_ptr + 4;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          'h4: begin
            generic4('h2, dev_rx_dl_if_d.data, m2s_req_pkt, m2s_req_ptr, h2d_data_pkt, h2d_data_ptr);
            m2s_req_ptr = m2s_req_ptr + 1;
            h2d_data_ptr = h2d_data_ptr + 1;
          end
          'h5: begin
            generic5('h2, dev_rx_dl_if_d.data, m2s_rwd_pkt, m2s_rwd_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            m2s_rwd_ptr = m2s_rwd_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          default: begin
          
          end
        endcase
        case(dev_rx_dl_if_d.data[16:14])
          'h0: begin
            generic0('h3, dev_rx_dl_if_d.data, h2d_data_pkt[4], h2d_data_ptr, m2s_rwd_pkt, m2s_rwd_ptr);
            //h2d_data_ptr = h2d_data_ptr + 4;
            //m2s_rwd_ptr = m2s_rwd_ptr + 1;
          end
          'h1: begin
            generic1('h3, dev_rx_dl_if_d.data, h2d_rsp_pkt[4], h2d_rsp_ptr);
            h2d_rsp_ptr = h2d_rsp_ptr + 4;
          end
          'h2: begin
            generic2('h3, dev_rx_dl_if_d.data, h2d_req_pkt, h2d_req_ptr, h2d_data_pkt, h2d_data_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            h2d_req_ptr = h2d_req_ptr + 1;
            h2d_data_ptr = h2d_data_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          'h3: begin
            generic3('h3, dev_rx_dl_if_d.data, h2d_data_pkt[4], h2d_data_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            h2d_data_ptr = h2d_data_ptr + 4;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          'h4: begin
            generic4('h3, dev_rx_dl_if_d.data, m2s_req_pkt, m2s_req_ptr, h2d_data_pkt, h2d_data_ptr);
            m2s_req_ptr = m2s_req_ptr + 1;
            h2d_data_ptr = h2d_data_ptr + 1;
          end
          'h5: begin
            generic5('h3, dev_rx_dl_if_d.data, m2s_rwd_pkt, m2s_rwd_ptr, h2d_rsp_pkt, h2d_rsp_ptr);
            m2s_rwd_ptr = m2s_rwd_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          default: begin
          
          end
        endcase
      end else if(data_slot[0][0]) begin
          generic0('h0, dev_rx_dl_if_d.data, h2d_data_pkt[4], m2s_rwd_pkt);
      end
    end
  end 

  cxl_lrsm_rrsm cxl_lrsm_rrsm_inst#(

  )(
    .clk(dev_rx_dl_if.clk),
    .rstn(dev_rx_dl_if.rstn),
    .*
  );

  crc_checker c2c_checker_inst#(

  )(
    .*
  );

  assign retry_frame_detect = (dev_rx_dl_if_d.data[39:36] == 'h3) && (dev_rx_dl_if_d.data[35:32] = 'h1) && (dev_rx_dl_if_d.data[0] == 'h1) && (crc_pass) && (!crc_fail);
  assign retry_idle_detect = (dev_rx_dl_if_d.data[39:36] == 'h0) && (dev_rx_dl_if_d.data[35:32] = 'h1) && (dev_rx_dl_if_d.data[0] == 'h1) && (crc_pass) && (!crc_fail);
  assign retry_req_detect = (dev_rx_dl_if_d.data[39:36] == 'h1) && (dev_rx_dl_if_d.data[35:32] = 'h1) && (dev_rx_dl_if_d.data[0] == 'h1) && (crc_pass) && (!crc_fail);
  assign retry_ack_detect = (dev_rx_dl_if_d.data[39:36] == 'h2) && (dev_rx_dl_if_d.data[35:32] = 'h1) && (dev_rx_dl_if_d.data[0] == 'h1) && (crc_pass) && (!crc_fail);
  assign non_retryable_flit = (retry_frame_idle) || (retry_frame_detect) || (retry_req_detect) || (retry_ack_detect);
  assign retryable_flit = (!retry_frame_idle) && (!retry_frame_detect) && (!retry_req_detect) && (!retry_ack_detect);
  //TODO: serious mistake I am assuming only one side of the link can have error at a time
  
  always@(posedge dev_rx_dl_if.clk) begin
    if(!dev_rx_dl_if.rstn) begin
      dev_rx_dl_if_d.valid <= 'h0;
      dev_rx_dl_if_d.data <= 'h0;
    end else begin
      dev_rx_dl_if_d.valid <= dev_rx_dl_if.valid;
      dev_rx_dl_if_d.data <= dev_rx_dl_if.data;
      if(dev_rx_dl_if_d.valid) begin
        case(retry_frame_states) 
        RETRY_NOFRAME: begin
          retry_req_rcvd <= 'h0;
          retry_ack_rcvd <= 'h0;
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME0;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME1: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME1;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME2: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME2;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME3: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME3;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME4: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME4;
          end else begin
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        RETRY_FRAME5: begin
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME5;
          end else if(retry_req_detect) begin
            retry_frame_states <= RETRY_NOFRAME;
            retry_req_rcvd <= 'h1;
            retry_frame_states <= RETRY_NOFRAME;
          end else if(retry_ack_detect) begin
            retry_ack_rcvd <= 'h1;
            retry_ack_empty_bit <= dev_rx_dl_if_d.data[64];
            retry_ack_num_retry <= dev_rx_dl_if_d.data[71:67];
            retry_frame_states <= RETRY_NOFRAME;
          end else begin
            retry_req_rcvd <= 'h0;
            retry_ack_rcvd <= 'h0;
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        default: begin
            retry_frame_states <= 'hX;
        end
        endcase
      end
    end
  end

endmodule

module replay_buffer#(
  parameter REPLAY_BUFFER_SIZE = 256,
  parameter REPLAY_BUFFER_WIDTH = 512
)(
  cxl_host_tx_dl_if.mon replay_inbuff_if,
  cxl_host_tx_dl_if.tx_mp replay_outbuff_if,
  input logic ack,
  input logic nack,
  input logic fullack
  output logic replay_buff_overflow,
  output logic replay_buff_undrflow,
  output logic [$clog2(REPLAY_BUFFER_SIZE)-1:0] numfreebuf
);
  localparam REPLAY_BUFF_IDX_WIDTH = $clog2(REPLAY_BUFFER_SIZE);
  typedef struct{
    logic valid;
    logic [REPLAY_BUFFER_WIDTH-1:0] data;
  } replay_buff_t;
  replay_buff_t replay_buff[REPLAY_BUFFER_SIZE];  
  logic [REPLAY_BUFFER_IDX_WIDTH:0] replay_wrptr;
  logic [REPLAY_BUFFER_IDX_WIDTH:0] replay_rdptr;
  logic [REPLAY_BUFFER_IDX_WIDTH-1:0] replay_cnt;  

  always@(replay_inbuff_if.clk) begin
    if(!replay_inbuff_if.rstn) begin
      replay_outbuff_if.valid <= 'h0;
      replay_outbuff_if.data  <= 'h0;
      replay_wrptr            <= 'h0;
      replay_rdptr            <= 'h0;
    end else begin
      if(replay_inbuff_if.valid) begin
        replay_buff[replay_wrptr].valid   <= replay_inbuff_if.valid;
        replay_buff[replay_wrptr].data    <= replay_inbuff_if.data;
        replay_wrptr                      <= replay_wrptr + 1;
      end 
      if(ack) begin
        replay_buff[replay_rdptr].valid   <= 'h0;
        replay_buff[replay_rdptr+1].valid <= 'h0;
        replay_buff[replay_rdptr+2].valid <= 'h0;
        replay_buff[replay_rdptr+3].valid <= 'h0;
        replay_buff[replay_rdptr+4].valid <= 'h0;
        replay_buff[replay_rdptr+5].valid <= 'h0;
        replay_buff[replay_rdptr+6].valid <= 'h0;
        replay_buff[replay_rdptr+7].valid <= 'h0;
        replay_rdptr                      <= replay_rdptr + 8;
      end
      if(replay_wrptr == replay_rdptr) begin
        replay_buff_empty <='h1;
      end else begin
        replay_buff_empty <='h0;
      end
      if((replay_wrptr[REPLAY_BUFF_IDX_WIDTH] != replay_rdptr[REPLAY_BUFF_IDX_WIDTH]) && (replay_wrptr[REPLAY_BUFF_IDX_WIDTH-1:0] == replay_rdptr[REPLAY_BUFF_IDX_WIDTH-1:0])) begin
        replay_buff_full <= 'h1;
      end else begin
        replay_buff_full <= 'h0;
      end
      if(nack) begin

      end
      if(replay_buff_empty && (!($stable(replay_rdptr)))) begin
        replay_buff_undrflow <= 'h1;
      end else begin
        replay_buff_undrflow <= 'h0;
      end
      if(replay_buff_empty && (!($stable(replay_rdptr)))) begin
        replay_buff_overflow <= 'h1;
      end else begin
        replay_buff_overflow <= 'h0;
      end
    end
  end

  assign numfreebuf = replay_wrptr - replay_rdptr;

endmodule

module buffer#(
  parameter DEPTH = 256,
  parameter ADDR_WIDTH = $clog2(DEPTH),
  type FIFO_DATA_TYPE = int
 )(
	  input logic clk,
  	input logic rstn,
  	input logic rval,
  	input logic drval,
  	input logic trval,
  	input logic qrval,
  	input logic wval,
    input FIFO_DATA_TYPE datain,
    output FIFO_DATA_TYPE dataout,
    output FIFO_DATA_TYPE ddataout,
    output FIFO_DATA_TYPE tdataout,
    output FIFO_DATA_TYPE qdataout,
  	output logic [ADDR_WIDTH-1:0] eseq,
  	output logic [ADDR_WIDTH:0] wptr,
  	output logic empty,
  	output logic full,
  	output logic undrflw,
  	output logic ovrflw,
  	output logic near_full,
  	output logic [ADDR_WIDTH-1:0] occupancy
  );
  
  logic FIFO_DATA_TYPE fifo_h[DEPTH];
  logic [ADDR_WIDTH:0] rdptr;
  logic [ADDR_WIDTH:0] wrptr;
 
  assign wptr = wrptr;
  
 	always@(posedge clk) begin
    if(!rstn) begin
     	rdptr <= 0;
     	wrptr <= 0;
     	dataout <= 0;
     	empty <= 0;
     	full <= 0;
     	ovrflw <= 'h0;
     	undrflw <= 'h0;
     	eseq <= 'h0;
    end else begin
     	if(rval || wval) begin
        if(wval && !full) begin
         	fifo_h[wrptr] <= datain;
         	wrptr <= wrptr + 1;
         	eseq <= eseq + 1;
        end else if(((rval && (!empty)) || (drval && (occupancy>1)) || (trval && (occupancy>2)) || (qrval && (occupancy>3)))) begin
          case({qrval,trval,drval,rval})
            4'b0001: begin
              rdptr <= rdptr + 1;
         	    dataout <= fifo_h[rdptr];
            end
            4'b0010: begin
              rdptr <= rdptr + 2;
         	    dataout <= fifo_h[rdptr];
         	    ddataout <= fifo_h[rdptr+1];
            end
            4'b0100: begin
              rdptr <= rdptr + 3;
         	    dataout <= fifo_h[rdptr];
         	    ddataout <= fifo_h[rdptr+1];
         	    tdataout <= fifo_h[rdptr+2];
            end
            4'b1000: begin
              rdptr <= rdptr + 4;
         	    dataout <= fifo_h[rdptr];
         	    ddataout <= fifo_h[rdptr+1];
         	    tdataout <= fifo_h[rdptr+2];
         	    qdataout <= fifo_h[rdptr+3];
            end
            default: begin
              rdptr <= 'hX;
            end
          endcase
        end
       	occupancy <= ('d256 - (wrptr - rdptr));
        if(rdptr == wrptr) begin
         	empty <= 'h1;
        end else begin 
         	empty <= 'h0;
        end
        if((rdptr[8] != wrptr[8]) && (rdptr[7:0] == wrptr[7:0])) begin
         	full <= 'h1;
        end else begin
         	full <= 'h0;
        end
        if((empty && rval) || ((occupancy<2) && drval) || ((occupancy<3) && trval) || ((occupancy<4) && qrval)) begin
         	undrflw <= 'h1;
        end else begin
         	undrflw <= 'h0;
        end
        if((full == 'h1) && wval) begin
         	ovrflw <= 'h1;
        end else begin
         	ovrflw <= 'h0;
        end
     	end
    end
 	end
  
endmodule

module cxl_host
   #(
  
   ) (
    cxl_cache_d2h_req_if.host_if_mp host_d2h_req_if,
    cxl_cache_d2h_rsp_if.host_if_mp host_d2h_rsp_if,
    cxl_cache_d2h_data_if.host_if_mp host_d2h_data_if,
    cxl_cache_h2d_req_if.host_if_mp host_h2d_req_if,
    cxl_cache_h2d_rsp_if.host_if_mp host_h2d_rsp_if,
    cxl_cache_h2d_data_if.host_if_mp host_h2d_data_if,
    cxl_mem_m2s_req_if.host_if_mp host_m2s_req_if,
    cxl_mem_m2s_rwd_if.host_if_mp host_m2s_rwd_if,
    cxl_mem_s2m_ndr_if.host_if_mp host_s2m_ndr_if,
    cxl_mem_s2m_drs_if.host_if_mp host_s2m_drs_if,
    cxl_host_tx_dl_if.tx_mp host_tx_dl_if,
    cxl_host_rx_dl_if.rx_mp host_rx_dl_if
);

  logic h2d_req_occ;
  logic h2d_rsp_occ;
  logic h2d_data_occ;
  logic m2s_req_occ;
  logic m2s_rwd_occ;
  logic h2d_req_rval;
  logic h2d_req_drval;
  logic h2d_req_qrval;
  logic h2d_rsp_rval;
  logic h2d_rsp_drval;
  logic h2d_rsp_qrval;
  logic h2d_data_rval;
  logic h2d_data_drval;
  logic h2d_data_qrval;
  logic m2s_req_rval;
  logic m2s_req_drval;
  logic m2s_req_qrval;
  logic m2s_rwd_rval;
  logic m2s_rwd_drval;
  logic m2s_rwd_qrval;
  h2d_req_txn_t h2d_req_dataout;
  h2d_req_txn_t h2d_req_ddataout;
  h2d_req_txn_t h2d_req_qdataout;
  h2d_rsp_txn_t h2d_rsp_dataout;
  h2d_rsp_txn_t h2d_rsp_ddataout;
  h2d_rsp_txn_t h2d_rsp_qdataout;
  h2d_data_txn_t h2d_data_dataout;
  h2d_data_txn_t h2d_data_ddataout;
  h2d_data_txn_t h2d_data_qdataout;
  m2s_req_txn_t m2s_req_dataout;
  m2s_req_txn_t m2s_req_ddataout;
  m2s_req_txn_t m2s_req_qdataout;
  m2s_rwd_txn_t m2s_rwd_dataout;
  m2s_rwd_txn_t m2s_rwd_ddataout;
  m2s_rwd_txn_t m2s_rwd_qdataout;


  buffer d2h_req_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = d2h_req_txn_t
  )(
	  .clk(host_d2h_req_if.clk),
  	.rstn(host_d2h_req_if.rstn),
  	.rval(host_d2h_req_if.ready),
  	.wval,
    .datain,
    .dataout(host_d2h_req_if.d2h_req_txn),
  	.eseq,
  	.wptr,
  	.empty(!host_d2h_req_if.d2h_req_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer d2h_rsp_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = d2h_rsp_txn_t
  )(
	  .clk(host_d2h_rsp_if.clk),
  	.rstn(host_d2h_rsp_if.rstn),
  	.rval(host_d2h_rsp_if.ready),
  	.wval,
    .datain,
    .dataout(host_d2h_rsp_if.d2h_rsp_txn),
  	.eseq,
  	.wptr,
  	.empty(!host_d2h_rsp_if.d2h_rsp_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer d2h_data_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = d2h_data_txn_t
  )(
	  .clk(host_d2h_data_if.clk),
  	.rstn(host_d2h_data_if.rstn),
  	.rval(host_d2h_data_if.ready),
  	.wval,
    .datain,
    .dataout(host_d2h_data_if.d2h_data_txn),
  	.eseq,
  	.wptr,
  	.empty(!host_d2h_data_if.d2h_data_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer s2m_ndr_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = s2m_ndr_txn_t
  )(
	  .clk(host_s2m_ndr_if.clk),
  	.rstn(host_s2m_ndr_if.rstn),
  	.rval(host_s2m_ndr_if.ready),
  	.wval,
    .datain,
    .dataout(host_s2m_ndr_if.s2m_ndr_txn),
  	.eseq,
  	.wptr,
  	.empty(!host_s2m_ndr_if.s2m_ndr_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer s2m_drs_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = s2m_drs_txn_t
  )(
	  .clk(host_s2m_drs_if.clk),
  	.rstn(host_s2m_drs_if.rstn),
  	.rval(host_s2m_drs_if.ready),
  	.wval,
    .datain,
    .dataout(host_s2m_drs_if.s2m_drs_txn),
  	.eseq,
  	.wptr,
  	.empty(!host_s2m_drs_if.s2m_drs_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer m2s_req_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = m2s_req_txn_t
  )(
	  .clk(host_m2s_req_if.clk),
  	.rstn(host_m2s_req_if.rstn),
  	.rval(m2s_req_rval),
  	.drval(m2s_req_drval),
  	.qrval(m2s_req_qrval),
  	.wval(host_m2s_req_if.m2s_req_txn.valid),
    .datain(host_m2s_req_if.m2s_req_txn),
    .dataout(m2s_req_dataout),
    .ddataout(m2s_req_ddataout),
    .qdataout(m2s_req_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(!host_m2s_req_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(m2s_req_occ)
  );

  buffer m2s_rwd_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = m2s_rwd_txn_t
  )(
	  .clk(host_m2s_rwd_if.clk),
  	.rstn(host_m2s_rwd_if.rstn),
  	.rval(m2s_rwd_rval),
  	.drval(m2s_rwd_drval),
  	.qrval(m2s_rwd_qrval),
  	.wval(host_m2s_rwd_if.m2s_rwd_txn.valid),
    .datain(host_m2s_rwd_if.m2s_rwd_txn),
    .dataout(m2s_rwd_dataout),
    .dataout(m2s_rwd_ddataout),
    .dataout(m2s_rwd_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(!host_m2s_rwd_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(m2s_rwd_occ)
  );

  buffer h2d_req_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = h2d_req_txn_t
  )(
	  .clk(host_h2d_req_if.clk),
  	.rstn(host_h2d_req_if.rstn),
  	.rval(h2d_req_rval),
  	.drval(h2d_req_drval),
  	.qrval(h2d_req_qrval),
  	.wval(host_h2d_req_if.h2d_req_txn.valid),
    .datain(host_h2d_req_if.h2d_req_txn),
    .dataout(h2d_req_dataout),
    .dataout(h2d_req_ddataout),
    .dataout(h2d_req_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(!host_h2d_req_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_req_occ)
  );

  buffer h2d_rsp_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = h2d_rsp_txn_t
  )(
	  .clk(host_h2d_rsp_if.clk),
  	.rstn(host_h2d_rsp_if.rstn),
  	.rval(h2d_rsp_rval),
  	.drval(h2d_rsp_drval),
  	.qrval(h2d_rsp_qrval),
  	.wval(host_h2d_rsp_if.h2d_rsp_txn.valid),
    .datain(host_h2d_rsp_if.h2d_rsp_txn),
    .dataout(h2d_rsp_dataout),
    .ddataout(h2d_rsp_ddataout),
    .qdataout(h2d_rsp_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(!host_h2d_rsp_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_rsp_occ)
  );

  buffer h2d_data_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = h2d_data_txn_t
  )(
	  .clk(host_h2d_data_if.clk),
  	.rstn(host_h2d_data_if.rstn),
  	.rval(h2d_data_rval),
  	.drval(h2d_data_drval),
  	.qrval(h2d_data_qrval),
  	.wval(host_h2d_data_if.h2d_data_txn.valid),
    .datain(host_h2d_data_if.h2d_data_txn),
    .dataout(h2d_data_dataout),
    .ddataout(h2d_data_ddataout),
    .ddataout(h2d_data_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(!host_h2d_data_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_data_occ)
  );

  host_tx_path host_tx_path_inst#(

  )(
    .*
  );

  host_rx_path host_rx_path_inst#(

  )(
    .*
  );

  replay_buffer replay_buffer_inst#(

  )(
    .*
  );

endmodule

module cxl_device
   #(
  
   ) (
    dev_d2h_req_if.dev_if_mp dev_d2h_req_if,
    dev_d2h_rsp_if.dev_if_mp dev_d2h_rsp_if,
    dev_d2h_data_if.dev_if_mp dev_d2h_data_if,
    dev_h2d_req_if.dev_if_mp dev_h2d_req_if,
    dev_h2d_rsp_if.dev_if_mp dev_h2d_rsp_if,
    dev_h2d_data_if.dev_if_mp dev_h2d_data_if,
    dev_m2s_req_if.dev_if_mp dev_m2s_req_if,
    dev_m2s_rwd_if.dev_if_mp dev_m2s_rwd_if,
    dev_s2m_ndr_if.dev_if_mp dev_s2m_ndr_if,
    dev_s2m_drs_if.dev_if_mp dev_s2m_drs_if,
    cxl_dev_tx_dl_if.tx_mp dev_tx_dl_if,
    cxl_dev_rx_dl_if.rx_mp dev_rx_dl_if
);

  logic d2h_req_occ;
  logic d2h_rsp_occ;
  logic d2h_data_occ;
  logic s2m_req_occ;
  logic s2m_rwd_occ;
  logic d2h_req_rval;
  logic d2h_req_drval;
  logic d2h_req_trval;
  logic d2h_req_qrval;
  logic d2h_rsp_rval;
  logic d2h_rsp_drval;
  logic d2h_rsp_trval;
  logic d2h_rsp_qrval;
  logic d2h_data_rval;
  logic d2h_data_drval;
  logic d2h_data_trval;
  logic d2h_data_qrval;
  logic s2m_ndr_rval;
  logic s2m_ndr_drval;
  logic s2m_ndr_trval;
  logic s2m_ndr_qrval;
  logic s2m_drs_rval;
  logic s2m_drs_drval;
  logic s2m_drs_trval;
  logic s2m_drs_qrval;
  d2h_req_txn_t d2h_req_dataout;
  d2h_req_txn_t d2h_req_ddataout;
  d2h_req_txn_t d2h_req_tdataout;
  d2h_req_txn_t d2h_req_qdataout;
  d2h_rsp_txn_t d2h_rsp_dataout;
  d2h_rsp_txn_t d2h_rsp_ddataout;
  d2h_rsp_txn_t d2h_rsp_tdataout;
  d2h_rsp_txn_t d2h_rsp_qdataout;
  d2h_data_txn_t d2h_data_dataout;
  d2h_data_txn_t d2h_data_ddataout;
  d2h_data_txn_t d2h_data_tdataout;
  d2h_data_txn_t d2h_data_qdataout;
  s2m_ndr_txn_t s2m_ndr_dataout;
  s2m_ndr_txn_t s2m_ndr_ddataout;
  s2m_ndr_txn_t s2m_ndr_tdataout;
  s2m_ndr_txn_t s2m_ndr_qdataout;
  s2m_drs_txn_t s2m_drs_dataout;
  s2m_drs_txn_t s2m_drs_ddataout;
  s2m_drs_txn_t s2m_drs_tdataout;
  s2m_drs_txn_t s2m_drs_qdataout;

  buffer d2h_req_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = d2h_req_txn_t
  )(
	  .clk(dev_d2h_req_if.clk),
  	.rstn(dev_d2h_req_if.rstn),
  	.rval(d2h_req_rval),
  	.drval(d2h_req_drval),
  	.trval(d2h_req_trval),
  	.qrval(d2h_req_qrval),
  	.wval(dev_d2h_req_if.d2h_req_txn.valid),
    .datain(dev_d2h_req_if.d2h_req_txn),
    .dataout(d2h_req_dataout),
    .ddataout(d2h_req_ddataout),
    .tdataout(d2h_req_tdataout),
    .qdataout(d2h_req_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
  	.full(!dev_d2h_req_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(d2h_req_occ)
  );

  buffer d2h_rsp_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = d2h_rsp_txn_t
  )(
	  .clk(dev_d2h_rsp_if.clk),
  	.rstn(dev_d2h_rsp_if.rstn),
  	.rval(d2h_rsp_rval),
  	.drval(d2h_rsp_drval),
  	.trval(d2h_rsp_trval),
  	.qrval(d2h_rsp_qrval),
  	.wval(dev_d2h_rsp_if.d2h_rsp_txn.valid),
    .datain(dev_d2h_rsp_if.d2h_rsp_txn),
    .dataout(d2h_rsp_dataout),
    .ddataout(d2h_rsp_ddataout),
    .tdataout(d2h_rsp_tdataout),
    .qdataout(d2h_rsp_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
  	.full(!dev_d2h_rsp_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer d2h_data_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = d2h_data_txn_t
  )(
	  .clk(dev_d2h_data_if.clk),
  	.rstn(dev_d2h_data_if.rstn),
  	.rval(d2h_data_rval),
  	.drval(d2h_data_drval),
  	.trval(d2h_data_trval),
  	.qrval(d2h_data_qrval),
  	.wval(dev_d2h_data_if.d2h_data_txn.valid),
    .datain(dev_d2h_data_if.d2h_data_txn),
    .dataout(d2h_data_dataout),
    .ddataout(d2h_data_ddataout),
    .tdataout(d2h_data_tdataout),
    .qdataout(d2h_data_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
  	.full(!dev_d2h_data_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(d2h_data_occ)
  );

  buffer s2m_ndr_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = s2m_ndr_txn_t
  )(
	  .clk(dev_s2m_ndr_if.clk),
  	.rstn(dev_s2m_ndr_if.rstn),
  	.rval(s2m_ndr_rval),
  	.drval(s2m_ndr_drval),
  	.trval(s2m_ndr_trval),
  	.qrval(s2m_ndr_qrval),
  	.wval(dev_s2m_ndr_if.s2m_ndr_txn.valid),
    .datain(dev_s2m_ndr_if.s2m_ndr_txn),
    .dataout(s2m_ndr_dataout),
    .ddataout(s2m_ndr_ddataout),
    .tdataout(s2m_ndr_tdataout),
    .qdataout(s2m_ndr_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
  	.full(!dev_s2m_ndr_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(s2m_ndr_occ)
  );

  buffer s2m_drs_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = s2m_drs_txn_t
  )(
	  .clk(dev_s2m_drs_if.clk),
  	.rstn(dev_s2m_drs_if.rstn),
  	.rval(s2m_drs_rval),
  	.drval(s2m_drs_drval),
  	.trval(s2m_drs_trval),
  	.qrval(s2m_drs_qrval),
  	.wval(dev_s2m_drs_if.s2m_drs_txn.valid),
    .datain(dev_s2m_drs_if.s2m_drs_txn),
    .dataout(s2m_drs_dataout),
    .ddataout(s2m_drs_ddataout),
    .tdataout(s2m_drs_tdataout),
    .qdataout(s2m_drs_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
  	.full(!dev_s2m_drs_if.ready),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(s2m_drs_occ)
  );

  buffer m2s_req_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = m2s_req_txn_t
  )(
	  .clk(dev_m2s_req_if.clk),
  	.rstn(dev_m2s_req_if.rstn),
  	.rval(dev_m2s_req_if.ready),
  	.wval,
    .datain,
    .dataout(dev_m2s_req_if.m2s_req_txn),
  	.eseq,
  	.wptr,
  	.empty(!dev_m2s_req_if.m2s_req_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer m2s_rwd_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = m2s_rwd_txn_t
  )(
	  .clk(dev_m2s_rwd_if.clk),
  	.rstn(dev_m2s_rwd_if.rstn),
  	.rval(dev_m2s_rwd_if.ready),
  	.wval,
    .datain,
    .dataout(dev_m2s_rwd_if.m2s_rwd_txn),
  	.eseq,
  	.wptr,
  	.empty(!dev_m2s_rwd_if.m2s_rwd_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer h2d_req_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = h2d_req_txn_t
  )(
	  .clk(dev_h2d_req_if.clk),
  	.rstn(dev_h2d_req_if.rstn),
  	.rval(dev_h2d_req_if.ready),
  	.wval,
    .datain,
    .dataout(dev_h2d_req_if.h2d_req_txn),
  	.eseq,
  	.wptr,
  	.empty(!dev_h2d_req_if.h2d_req_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer h2d_rsp_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = h2d_rsp_txn_t
  )(
	  .clk(dev_h2d_rsp_if.clk),
  	.rstn(dev_h2d_rsp_if.rstn),
  	.rval(dev_h2d_rsp_if.ready),
  	.wval,
    .datain,
    .dataout(dev_h2d_rsp_if.h2d_rsp_txn),
  	.eseq,
  	.wptr,
  	.empty(!dev_h2d_rsp_if.h2d_rsp_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  buffer h2d_data_fifo_inst#(
    DEPTH = 32,
    ADDR_WIDTH = 5,
    type FIFO_DATA_TYPE = h2d_data_txn_t
  )(
	  .clk(dev_h2d_data_if.clk),
  	.rstn(dev_h2d_data_if.rstn),
  	.rval(dev_h2d_data_if.ready),
  	.wval,
    .datain,
    .dataout(dev_h2d_data_if.h2d_data_txn),
  	.eseq,
  	.wptr,
  	.empty(!dev_h2d_data_if.h2d_data_txn.valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy
  );

  device_tx_path device_tx_path_inst#(

  )(
    .*
  );

  device_rx_path device_rx_path_inst#(

  )(
    .*
  );

  replay_buffer replay_buffer_inst#(

  )(
    .*
  );

endmodule

module tb_top;

  logic clk;

  cxl_cache_d2h_req_if  host_d2h_req_if(clk);
  cxl_cache_d2h_rsp_if  host_d2h_rsp_if(clk);
  cxl_cache_d2h_data_if host_d2h_data_if(clk);
  cxl_cache_h2d_req_if  host_h2d_req_if(clk);
  cxl_cache_h2d_rsp_if  host_h2d_rsp_if(clk);
  cxl_cache_h2d_data_if host_h2d_data_if(clk);

  cxl_cache_d2h_req_if  dev_d2h_req_if(clk);
  cxl_cache_d2h_rsp_if  dev_d2h_rsp_if(clk);
  cxl_cache_d2h_data_if dev_d2h_data_if(clk);
  cxl_cache_h2d_req_if  dev_h2d_req_if(clk);
  cxl_cache_h2d_rsp_if  dev_h2d_rsp_if(clk);
  cxl_cache_h2d_data_if dev_h2d_data_if(clk);

  cxl_mem_m2s_req_if  host_m2s_req_if(clk);
  cxl_mem_m2s_rwd_if  host_m2s_rwd_if(clk);
  cxl_mem_s2m_ndr_if  host_s2m_ndr_if(clk);
  cxl_mem_s2m_drs_if  host_s2m_drs_if(clk);

  cxl_mem_m2s_req_if  dev_m2s_req_if(clk);
  cxl_mem_m2s_rwd_if  dev_m2s_rwd_if(clk);
  cxl_mem_s2m_ndr_if  dev_s2m_ndr_if(clk);
  cxl_mem_s2m_drs_if  dev_s2m_drs_if(clk);

  cxl_host cxl_host_inst#(

  )(
    .*
  );

  cxl_device cxl_device_inst#(

  )(
    .*
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
    
    uvm_config_db#(virtual cxl_cache_d2h_req_if)::set(null, "*", "host_d2h_req_if", host_d2h_req_if);
    uvm_config_db#(virtual cxl_cache_d2h_rsp_if)::set(null, "*", "host_d2h_rsp_if", host_d2h_rsp_if);
    uvm_config_db#(virtual cxl_cache_d2h_data_if)::set(null, "*", "host_d2h_data_if", host_d2h_data_if);
    uvm_config_db#(virtual cxl_cache_h2d_req_if)::set(null, "*", "host_h2d_req_if", host_h2d_req_if);
    uvm_config_db#(virtual cxl_cache_h2d_rsp_if)::set(null, "*", "host_h2d_rsp_if", host_h2d_rsp_if);
    uvm_config_db#(virtual cxl_cache_h2d_data_if)::set(null, "*", "host_h2d_data_if", host_h2d_data_if);
    uvm_config_db#(virtual cxl_mem_m2s_req_if)::set(null, "*", "host_m2s_req_if", host_m2s_req_if);
    uvm_config_db#(virtual cxl_mem_m2s_rwd_if)::set(null, "*", "host_m2s_rwd_if", host_m2s_rwd_if);
    uvm_config_db#(virtual cxl_mem_m2s_ndr_if)::set(null, "*", "host_s2m_ndr_if", host_s2m_ndr_if);
    uvm_config_db#(virtual cxl_mem_m2s_drs_if)::set(null, "*", "host_s2m_drs_if", host_s2m_drs_if);

    uvm_config_db#(virtual cxl_cache_d2h_req_if)::set(null, "*", "dev_d2h_req_if", dev_d2h_req_if);
    uvm_config_db#(virtual cxl_cache_d2h_rsp_if)::set(null, "*", "dev_d2h_rsp_if", dev_d2h_rsp_if);
    uvm_config_db#(virtual cxl_cache_d2h_data_if)::set(null, "*", "dev_d2h_data_if", dev_d2h_data_if);
    uvm_config_db#(virtual cxl_cache_h2d_req_if)::set(null, "*", "dev_h2d_req_if", dev_h2d_req_if);
    uvm_config_db#(virtual cxl_cache_h2d_rsp_if)::set(null, "*", "dev_h2d_rsp_if", dev_h2d_rsp_if);
    uvm_config_db#(virtual cxl_cache_h2d_data_if)::set(null, "*", "dev_h2d_data_if", dev_h2d_data_if);
    uvm_config_db#(virtual cxl_mem_m2s_req_if)::set(null, "*", "dev_m2s_req_if", dev_m2s_req_if);
    uvm_config_db#(virtual cxl_mem_m2s_rwd_if)::set(null, "*", "dev_m2s_rwd_if", dev_m2s_rwd_if);
    uvm_config_db#(virtual cxl_mem_m2s_ndr_if)::set(null, "*", "dev_s2m_ndr_if", dev_s2m_ndr_if);
    uvm_config_db#(virtual cxl_mem_m2s_drs_if)::set(null, "*", "dev_s2m_drs_if", dev_s2m_drs_if);
    run_test("cxl_base_test");
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

  class cxl_base_txn_seq_item extends uvm_sequence_item;
    `uvm_object_utils_begin(cxl_base_txn_seq_item)
      `uvm_field_int(delay_value, UVM_NOCOMPARE)
      `uvm_field_int(delay_set, UVM_NOCOMPARE)
      `uvm_field_enum(delay_type_t,delay_type, UVM_NOCOMPARE)
    `uvm_object_utils_end
    rand int delay_value;
    rand logic delay_set;
    rand delay_type_t delay_type;
    
    constraint delay_c{
      soft delay_set inside {'h0};
      if(delay_set){
        (delay_type_t == SHORT_DLY) -> delay_value inside {[1:10]};
        (delay_type_t == MED_DLY)   -> delay_value inside {[10:100]};
        (delay_type_t == LONG_DLY)  -> delay_value inside {[100:1000]};
      } else {
        delay_value inside {'h0};
      }
      solve delay_set before delay_type_t;
      solve delay_type_t before delay_value;
    }

    function new(string name = "cxl_base_txn_seq_item");
      super.new(name);
    endfunction

  endclass 
  
  //can justify not using struct for fields as a txn because in future if you want 
  //different uvm_field types you cannot assign it using struct alone 
  class d2h_req_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(d2h_req_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(d2h_req_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_int(cqid, UVM_DEFAULT)
      `uvm_field_int(nt, UVM_DEFAULT)
      `uvm_field_int(d2h_req_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

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

  class d2h_rsp_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(d2h_rsp_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(d2h_rsp_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_int(uqid, UVM_DEFAULT)
      `uvm_field_int(d2h_rsp_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

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

  class d2h_data_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(d2h_data_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(uqid, UVM_DEFAULT)
      `uvm_field_int(chunkvalid, UVM_DEFAULT)
      `uvm_field_int(bogus, UVM_DEFAULT)
      `uvm_field_int(poison, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
    `uvm_object_utils_end

    rand logic valid;
    rand logic [11:0] uqid;
    rand logic chunkvalid;
    rand logic bogus;
    rand logic poison;
    rand logic [511:0] data;

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

  class h2d_req_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(h2d_req_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(h2d_req_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_int(uqid, UVM_DEFAULT)
      `uvm_field_int(h2d_req_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

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

  class h2d_rsp_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(h2d_rsp_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(h2d_rsp_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_int(rspdata, UVM_DEFAULT)
      `uvm_field_int(rsppre, UVM_DEFAULT)
      `uvm_field_int(cqid, UVM_DEFAULT)
      `uvm_field_int(h2d_rsp_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end
    
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

  class h2d_data_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(h2d_data_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(cqid, UVM_DEFAULT)
      `uvm_field_int(chunkvalid, UVM_DEFAULT)
      `uvm_field_int(poison, UVM_DEFAULT)
      `uvm_field_int(goerr, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
      `uvm_field_int(h2d_data_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

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

  class m2s_req_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(m2s_req_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_enum(m2s_req_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_enum(metafield_t, metafield, UVM_DEFAULT)
      `uvm_field_enum(metavalue_t, metavalue, UVM_DEFAULT)
      `uvm_field_enum(snptype_t, snptype, UVM_DEFAULT)
      `uvm_field_int(tag, UVM_DEFAULT)
      `uvm_field_int(tc, UVM_DEFAULT)
      `uvm_field_int(m2s_req_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

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

  class m2s_rwd_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(m2s_rwd_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_enum(m2s_rwd_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_enum(metafield_t, metafield, UVM_DEFAULT)
      `uvm_field_enum(metavalue_t, metavalue, UVM_DEFAULT)
      `uvm_field_enum(snptype_t, snptype, UVM_DEFAULT)
      `uvm_field_int(tag, UVM_DEFAULT)
      `uvm_field_int(tc, UVM_DEFAULT)
      `uvm_field_int(poison, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
      `uvm_field_int(m2s_rwd_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

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

  class s2m_ndr_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(s2m_ndr_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(s2m_ndr_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_enum(metafield_t, metafield, UVM_DEFAULT)
      `uvm_field_enum(metavalue_t, metavalue, UVM_DEFAULT)
      `uvm_field_int(tag, UVM_DEFAULT)
      `uvm_field_int(s2m_ndr_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

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

  class s2m_drs_seq_item extends cxl_base_txn_seq_item;
    `uvm_object_utils_begin(s2m_drs_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(s2m_drs_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_enum(metafield_t, metafield, UVM_DEFAULT)
      `uvm_field_enum(metavalue_t, metavalue, UVM_DEFAULT)
      `uvm_field_int(tag, UVM_DEFAULT)
      `uvm_field_int(poison, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
      `uvm_field_int(s2m_drs_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

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


  class cxl_base_sequencer extends uvm_sequencer#(cxl_base_txn_seq_item);
    `uvm_component_utils(cxl_base_sequencer)

    function new(string name = "cxl_base_sequencer", uvm_component parent = null );
      super.new(name, parent);
    endfunction

  endclass

  class host_d2h_req_sequencer extends cxl_base_sequencer#(d2h_req_seq_item);
    `uvm_component_utils(host_d2h_req_sequencer);
    uvm_tlm_analysis_fifo host_d2h_req_fifo;

    function new(string name = "host_d2h_req_sequencer");
      super.new(name);
      host_d2h_req_fifo = new("host_d2h_req_fifo",   this);
    endfunction

  endclass

  class host_d2h_rsp_sequencer extends cxl_base_sequencer#(d2h_rsp_seq_item);
    `uvm_component_utils(host_d2h_rsp_sequencer);
    uvm_tlm_analysis_fifo host_d2h_rsp_fifo;

    function new(string name = "host_d2h_rsp_sequencer");
      super.new(name);
      host_d2h_rsp_fifo = new("host_d2h_rsp_fifo",   this);
    endfunction

  endclass

  class host_d2h_data_sequencer extends cxl_base_sequencer#(d2h_data_seq_item);
    `uvm_component_utils(host_d2h_data_sequencer);
    uvm_tlm_analysis_fifo host_d2h_data_fifo;

    function new(string name = "host_d2h_data_sequencer");
      super.new(name);
      host_d2h_data_fifo = new("host_d2h_data_fifo",   this);
    endfunction

  endclass

  class dev_h2d_req_sequencer extends cxl_base_sequencer#(h2d_req_seq_item);
    `uvm_component_utils(dev_h2d_req_sequencer);
    uvm_tlm_analysis_fifo dev_h2d_req_fifo;

    function new(string name = "dev_h2d_req_sequencer");
      super.new(name);
      dev_h2d_req_fifo = new("dev_h2d_req_fifo",   this);
    endfunction

  endclass

  class dev_h2d_rsp_sequencer extends cxl_base_sequencer#(h2d_rsp_seq_item);
    `uvm_component_utils(dev_h2d_rsp_sequencer);
    uvm_tlm_analysis_fifo dev_h2d_req_fifo;

    function new(string name = "dev_h2d_rsp_sequencer");
      super.new(name);
      dev_h2d_rsp_fifo = new("dev_h2d_rsp_fifo",   this);
    endfunction

  endclass

  class dev_h2d_data_sequencer extends cxl_base_sequencer#(h2d_data_seq_item);
    `uvm_component_utils(dev_h2d_data_sequencer);
    uvm_tlm_analysis_fifo dev_h2d_data_fifo;

    function new(string name = "dev_h2d_data_sequencer");
      super.new(name);
      dev_h2d_data_fifo = new("dev_h2d_data_fifo",   this);
    endfunction

  endclass

  class dev_m2s_req_sequencer extends cxl_base_sequencer#(m2s_req_seq_item);
    `uvm_component_utils(dev_m2s_req_sequencer);
    uvm_tlm_analysis_fifo dev_m2s_req_fifo;

    function new(string name = "dev_m2s_req_sequencer");
      super.new(name);
      dev_m2s_req_fifo = new("dev_m2s_req_fifo",   this);
    endfunction

  endclass

  class dev_m2s_rwd_sequencer extends cxl_base_sequencer#(m2s_rwd_seq_item);
    `uvm_component_utils(dev_m2s_rwd_sequencer);
    uvm_tlm_analysis_fifo dev_m2s_rwd_fifo;

    function new(string name = "dev_m2s_rwd_sequencer");
      super.new(name);
      dev_m2s_rwd_fifo = new("dev_m2s_rwd_fifo",   this);
    endfunction

  endclass

  class host_s2m_ndr_sequencer extends cxl_base_sequencer#(s2m_ndr_seq_item);
    `uvm_component_utils(host_s2m_ndr_sequencer);
    uvm_tlm_analysis_fifo host_s2m_ndr_fifo;

    function new(string name = "host_s2m_ndr_sequencer");
      super.new(name);
      host_s2m_ndr_fifo = new("host_s2m_ndr_fifo",   this);
    endfunction

  endclass

  class host_s2m_drs_sequencer extends cxl_base_sequencer#(s2m_drs_seq_item);
    `uvm_component_utils(host_s2m_drs_sequencer);
    uvm_tlm_analysis_fifo host_s2m_drs_fifo;

    function new(string name = "host_s2m_drs_sequencer");
      super.new(name);
      host_s2m_drs_fifo = new("host_s2m_drs_fifo",   this);
    endfunction

  endclass

  class dev_d2h_req_sequencer extends cxl_base_sequencer#(d2h_req_seq_item);
    `uvm_component_utils(dev_d2h_req_sequencer)
    
    int d2h_req_crdt;
    d2h_req_seq_item d2h_req_seq_item_h;
    d2h_req_seq_item d2h_req_seq_item_exp_h;
    d2h_req_seq_item d2h_req_seq_item_act_h;
    d2h_req_seq_item drv_mon_txn[$];
    d2h_req_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo dev_d2h_req_fifo;

    function new(string name = "dev_d2h_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_d2h_req_fifo    = new("dev_d2h_req_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            d2h_req_seq_item_h = last_req();
            inflight_txn.push_back(d2h_req_seq_item_h);
            drv_mon_txn.push_back(d2h_req_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!dev_d2h_req_fifo.is_empty);
            d2h_req_seq_item_act_h = dev_d2h_req_fifo.get_ap();
            d2h_req_seq_item_exp_h = drv_mon_txn.pop_front();
            if(d2h_req_seq_item_act_h.compare(d2h_req_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none
    endtask 

  endclass

  class dev_d2h_rsp_sequencer extends cxl_base_sequencer#(d2h_rsp_seq_item);
    `uvm_component_utils(dev_d2h_rsp_sequencer)
    
    int d2h_rsp_crdt;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;
    d2h_rsp_seq_item d2h_rsp_seq_item_exp_h;
    d2h_rsp_seq_item d2h_rsp_seq_item_act_h;
    d2h_rsp_seq_item drv_mon_txn[$];
    d2h_rsp_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo dev_d2h_rsp_fifo;

    function new(string name = "dev_d2h_rsp_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_d2h_rsp_fifo    = new("dev_d2h_rsp_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            d2h_rsp_seq_item_h = last_req();
            inflight_txn.push_back(d2h_rsp_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!dev_d2h_rsp_fifo.is_empty);
            d2h_rsp_seq_item_act_h = dev_d2h_rsp_fifo.get_ap();
            d2h_rsp_seq_item_exp_h = drv_mon_txn.pop_front();
            if(d2h_rsp_seq_item_act_h.compare(d2h_rsp_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none
    endtask 

  endclass

  class dev_d2h_data_sequencer extends cxl_base_sequencer#(d2h_data_seq_item);
    `uvm_component_utils(dev_d2h_data_sequencer)
    
    int d2h_data_crdt;
    d2h_data_seq_item d2h_data_seq_item_h;
    d2h_data_seq_item d2h_data_seq_item_exp_h;
    d2h_data_seq_item d2h_data_seq_item_act_h;
    d2h_data_seq_item drv_mon_txn[$];
    d2h_data_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo dev_d2h_data_fifo;

    function new(string name = "dev_d2h_data_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_d2h_data_fifo    = new("dev_d2h_data_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            d2h_data_seq_item_h = last_req();
            inflight_txn.push_back(d2h_data_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!dev_d2h_data_fifo.is_empty);
            d2h_data_seq_item_act_h = dev_d2h_data_fifo.get_ap();
            d2h_data_seq_item_exp_h = drv_mon_txn.pop_front();
            if(d2h_data_seq_item_act_h.compare(d2h_data_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none
    endtask 

  endclass

  class host_h2d_req_sequencer extends cxl_base_sequencer#(h2d_req_seq_item);
    `uvm_component_utils(host_h2d_req_sequencer)
    
    int h2d_req_crdt;
    h2d_req_seq_item h2d_req_seq_item_h;
    h2d_req_seq_item h2d_req_seq_item_exp_h;
    h2d_req_seq_item h2d_req_seq_item_act_h;
    h2d_req_seq_item drv_mon_txn[$];
    h2d_req_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo host_h2d_req_fifo;

    function new(string name = "host_h2d_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_h2d_req_fifo    = new("host_h2d_req_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            h2d_req_seq_item_h = last_req();
            inflight_txn.push_back(h2d_req_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!host_h2d_req_fifo.is_empty);
            h2d_req_seq_item_act_h = host_h2d_req_fifo.get_ap();
            h2d_req_seq_item_exp_h = drv_mon_txn.pop_front();
            if(h2d_req_seq_item_act_h.compare(h2d_req_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none
    endtask 

  endclass

  class host_h2d_rsp_sequencer extends cxl_base_sequencer#(h2d_rsp_seq_item);
    `uvm_component_utils(host_h2d_rsp_sequencer)
    
    int h2d_rsp_crdt;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;
    h2d_rsp_seq_item h2d_rsp_seq_item_exp_h;
    h2d_rsp_seq_item h2d_rsp_seq_item_act_h;
    h2d_rsp_seq_item drv_mon_txn[$];
    h2d_rsp_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo host_h2d_rsp_fifo;

    function new(string name = "host_h2d_rsp_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_h2d_rsp_fifo    = new("host_h2d_rsp_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            h2d_rsp_seq_item_h = last_req();
            inflight_txn.push_back(h2d_rsp_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!host_h2d_rsp_fifo.is_empty);
            h2d_rsp_seq_item_act_h = host_h2d_rsp_fifo.get_ap();
            h2d_rsp_seq_item_exp_h = drv_mon_txn.pop_front();
            if(h2d_rsp_seq_item_act_h.compare(h2d_rsp_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end  
        end
      join_none
    endtask 

  endclass

  class host_h2d_data_sequencer extends cxl_base_sequencer#(h2d_data_seq_item);
    `uvm_component_utils(host_h2d_data_sequencer)
    
    int h2d_data_crdt;
    h2d_data_seq_item h2d_data_seq_item_h;
    h2d_data_seq_item h2d_data_seq_item_exp_h;
    h2d_data_seq_item h2d_data_seq_item_act_h;
    h2d_data_seq_item drv_mon_txn[$];
    h2d_data_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo host_h2d_data_fifo;

    function new(string name = "host_h2d_data_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_h2d_data_fifo    = new("host_h2d_data_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            h2d_data_seq_item_h = last_req();
            inflight_txn.push_back(h2d_data_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!host_h2d_data_fifo.is_empty);
            h2d_data_seq_item_act_h = host_h2d_data_fifo.get_ap();
            h2d_data_seq_item_exp_h = drv_mon_txn.pop_front();
            if(h2d_data_seq_item_act_h.compare(h2d_data_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none
    endtask 

  endclass

  class host_m2s_req_sequencer extends cxl_base_sequencer#(m2s_req_seq_item);
    `uvm_component_utils(host_m2s_req_sequencer)
    
    int m2s_req_crdt;
    m2s_req_seq_item m2s_req_seq_item_h;
    m2s_req_seq_item m2s_req_seq_item_exp_h;
    m2s_req_seq_item m2s_req_seq_item_act_h;
    m2s_req_seq_item drv_mon_txn[$];
    m2s_req_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo host_m2s_req_fifo;

    function new(string name = "host_m2s_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_m2s_req_fifo    = new("host_m2s_req_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            m2s_req_seq_item_h = last_req();
            inflight_txn.push_back(m2s_req_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!host_m2s_req_fifo.is_empty);
            m2s_req_seq_item_act_h = host_m2s_req_fifo.get_ap();
            m2s_req_seq_item_exp_h = drv_mon_txn.pop_front();
            if(m2s_req_seq_item_act_h.compare(m2s_req_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          
          end
        end
      join_none
    endtask 

  endclass

  class host_m2s_rwd_sequencer extends cxl_base_sequencer#(m2s_rwd_seq_item);
    `uvm_component_utils(host_m2s_rwd_sequencer)
    
    int m2s_rwd_crdt;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;
    m2s_rwd_seq_item m2s_rwd_seq_item_exp_h;
    m2s_rwd_seq_item m2s_rwd_seq_item_act_h;
    m2s_rwd_seq_item drv_mon_txn[$];
    m2s_rwd_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo host_m2s_rwd_fifo;

    function new(string name = "host_m2s_rwd_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_m2s_rwd_fifo    = new("host_m2s_rwd_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            m2s_rwd_seq_item_h = last_req();
            inflight_txn.push_back(m2s_rwd_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!host_m2s_rwd_fifo.is_empty);
            m2s_rwd_seq_item_act_h = host_m2s_rwd_fifo.get_ap();
            m2s_rwd_seq_item_exp_h = drv_mon_txn.pop_front();
            if(m2s_rwd_seq_item_act_h.compare(m2s_rwd_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none
    endtask 

  endclass

  class dev_s2m_ndr_sequencer extends cxl_base_sequencer#(s2m_ndr_seq_item);
    `uvm_component_utils(dev_s2m_ndr_sequencer)
    
    int s2m_ndr_crdt;
    s2m_ndr_seq_item s2m_ndr_seq_item_h;
    s2m_ndr_seq_item s2m_ndr_seq_item_exp_h;
    s2m_ndr_seq_item s2m_ndr_seq_item_act_h;
    s2m_ndr_seq_item drv_mon_txn[$];
    s2m_ndr_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo dev_s2m_ndr_fifo;

    function new(string name = "dev_s2m_ndr_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_s2m_ndr_fifo    = new("dev_s2m_ndr_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            s2m_ndr_seq_item_h = last_req();
            inflight_txn.push_back(s2m_ndr_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!dev_s2m_ndr_fifo.is_empty);
            s2m_ndr_seq_item_act_h = dev_s2m_ndr_fifo.get_ap();
            s2m_ndr_seq_item_exp_h = drv_mon_txn.pop_front();
            if(s2m_ndr_seq_item_act_h.compare(s2m_ndr_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none
    endtask 

  endclass

  class dev_s2m_drs_sequencer extends cxl_base_sequencer#(s2m_drs_seq_item);
    `uvm_component_utils(dev_s2m_drs_sequencer)
    
    int s2m_drs_crdt;
    s2m_drs_seq_item s2m_drs_seq_item_h;
    s2m_drs_seq_item s2m_drs_seq_item_exp_h;
    s2m_drs_seq_item s2m_drs_seq_item_act_h;
    s2m_drs_seq_item drv_mon_txn[$];
    s2m_drs_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo dev_s2m_drs_fifo;

    function new(string name = "dev_s2m_drs_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_s2m_drs_fifo    = new("dev_s2m_drs_fifo",   this);
    endfunction

    virtual task void run_phase(uvm_phase);
      super.run_phase(phase);
      fork 
        begin
          forever begin
            wait_for_item_done();
            s2m_drs_seq_item_h = last_req();
            inflight_txn.push_back(s2m_drs_seq_item_h.address);
          end
        end
        begin
          forever begin
            wait(!dev_s2m_drs_fifo.is_empty);
            s2m_drs_seq_item_act_h = dev_s2m_drs_fifo.get_ap();
            s2m_drs_seq_item_exp_h = drv_mon_txn.pop_front();
            if(s2m_drs_seq_item_act_h.compare(s2m_drs_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end   
        end
        join_none
    endtask 

  endclass

  class dev_d2h_req_monitor extends uvm_monitor;
    `uvm_component_utils(dev_d2h_req_monitor)
    
    uvm_analysis_port#(d2h_req_seq_item) d2h_req_port;
    virtual cxl_cache_d2h_req_if.mon dev_d2h_req_if;
    d2h_req_seq_item d2h_req_seq_item_h;

    function new(string name = "dev_d2h_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_req_port = new("d2h_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_req_if)::get(this, "", "dev_d2h_req_if", dev_d2h_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_req_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_d2h_req_if.clk);
            if(dev_d2h_req_if.d2h_req_txn.valid && dev_d2h_req_if.ready) begin
              d2h_req_seq_item_h = d2h_req_seq_item::type_id::create("d2h_req_seq_item_h", this);
              d2h_req_seq_item_h.valid    = dev_d2h_req_if.d2h_req_txn.valid;
              d2h_req_seq_item_h.opcode   = dev_d2h_req_if.d2h_req_txn.opcode;
              d2h_req_seq_item_h.address  = dev_d2h_req_if.d2h_req_txn.address;
              d2h_req_seq_item_h.cqid     = dev_d2h_req_if.d2h_req_txn.cqid;
              d2h_req_seq_item_h.nt       = dev_d2h_req_if.d2h_req_txn.nt;
              d2h_req_port.write(d2h_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask
  endclass

  class dev_d2h_rsp_monitor extends uvm_monitor;
    `uvm_component_utils(dev_d2h_rsp_monitor)
    
    uvm_analysis_port#(d2h_rsp_seq_item) d2h_rsp_port;
    virtual cxl_cache_d2h_rsp_if.mon dev_d2h_rsp_if;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;

    function new(string name = "dev_d2h_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_rsp_port = new("d2h_rsp_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_rsp_if)::get(this, "", "dev_d2h_rsp_if", dev_d2h_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_rsp_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_d2h_rsp_if.clk);
            if(dev_d2h_rsp_if.d2h_rsp_txn.valid && dev_d2h_rsp_if.ready) begin
              d2h_rsp_seq_item_h = d2h_rsp_seq_item::type_id::create("d2h_rsp_seq_item_h", this);
              d2h_rsp_seq_item_h.valid   = dev_d2h_rsp_if.d2h_rsp_txn.valid;
              d2h_rsp_seq_item_h.opcode  = dev_d2h_rsp_if.d2h_rsp_txn.opcode;
              d2h_rsp_seq_item_h.uqid    = dev_d2h_rsp_if.d2h_rsp_txn.uqid;
              d2h_rsp_port.write(d2h_rsp_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class dev_d2h_data_monitor extends uvm_monitor;
    `uvm_component_utils(dev_d2h_data_monitor)
    
    uvm_analysis_port#(d2h_data_seq_item) d2h_data_port;
    virtual cxl_cache_d2h_data_if.mon dev_d2h_data_if;
    d2h_data_seq_item d2h_data_seq_item_h;

    function new(string name = "dev_d2h_data_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_data_port = new("d2h_data_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_data_if)::get(this, "", "dev_d2h_data_if", dev_d2h_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_data_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_d2h_data_if.clk);
            if(dev_d2h_data_if.d2h_data_txn.valid && dev_d2h_data_if.ready) begin
              d2h_data_seq_item_h = d2h_data_seq_item::type_id::create("d2h_data_seq_item_h", this);
              d2h_data_seq_item_h.valid         = dev_d2h_data_if.d2h_data_txn.valid;
              d2h_data_seq_item_h.uqid          = dev_d2h_data_if.d2h_data_txn.uqid;
              d2h_data_seq_item_h.chunkvalid    = dev_d2h_data_if.d2h_data_txn.chunkvalid;
              d2h_data_seq_item_h.bogus         = dev_d2h_data_if.d2h_data_txn.bogus;
              d2h_data_seq_item_h.poison        = dev_d2h_data_if.d2h_data_txn.poison;
              d2h_data_seq_item_h.data          = dev_d2h_data_if.d2h_data_txn.data;
              d2h_data_port.write(d2h_data_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_h2d_req_monitor extends uvm_monitor;
    `uvm_component_utils(host_h2d_req_monitor)
    
    uvm_analysis_port#(h2d_req_seq_item) h2d_req_port;
    virtual cxl_cache_h2d_req_if.mon host_h2d_req_if;

    function new(string name = "host_h2d_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_req_port = new("h2d_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_req_if)::get(this, "", "host_h2d_req_if", host_h2d_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_req_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_h2d_req_if.clk);
            if(host_h2d_req_if.h2d_req_txn.valid && host_h2d_req_if.ready) begin
              h2d_req_seq_item_h = h2d_req_seq_item::type_id::create("h2d_req_seq_item_h", this);
              h2d_req_seq_item_h.valid         = host_h2d_req_if.h2d_req_txn.valid;
              h2d_req_seq_item_h.opcode        = host_h2d_req_if.h2d_req_txn.opcode;
              h2d_req_seq_item_h.address       = host_h2d_req_if.h2d_req_txn.address;
              h2d_req_seq_item_h.uqid          = host_h2d_req_if.h2d_req_txn.uqid;
              h2d_req_port.write(h2d_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass
  
  class host_h2d_rsp_monitor extends uvm_monitor;
    `uvm_component_utils(host_h2d_rsp_monitor)
    
    uvm_analysis_port#(h2d_rsp_seq_item) h2d_rsp_port;
    virtual cxl_cache_h2d_rsp_if.mon host_h2d_rsp_if;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;

    function new(string name = "host_h2d_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_rsp_port = new("h2d_rsp_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_rsp_if)::get(this, "", "host_h2d_rsp_if", host_h2d_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_rsp_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_h2d_rsp_if.clk);
            if(host_h2d_rsp_if.h2d_rsp_txn.valid && host_h2d_rsp_if.ready) begin
              h2d_rsp_seq_item_h = h2d_rsp_seq_item::type_id::create("h2d_rsp_seq_item_h", this);
              h2d_rsp_seq_item_h.valid         = host_h2d_rsp_if.h2d_rsp_txn.valid;
              h2d_rsp_seq_item_h.opcode        = host_h2d_rsp_if.h2d_rsp_txn.opcode;
              h2d_rsp_seq_item_h.rspdata       = host_h2d_rsp_if.h2d_rsp_txn.rspdata;
              h2d_rsp_seq_item_h.rsppre        = host_h2d_rsp_if.h2d_rsp_txn.rsppre;
              h2d_rsp_seq_item_h.cqid          = host_h2d_rsp_if.h2d_rsp_txn.cqid;
              h2d_rsp_port.write(h2d_rsp_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_h2d_data_monitor extends uvm_monitor;
    `uvm_component_utils(host_h2d_data_monitor)
    
    uvm_analysis_port#(h2d_data_seq_item) h2d_data_port;
    virtual cxl_cache_h2d_data_if.mon host_h2d_data_if;
    h2d_data_seq_item h2d_data_seq_item_h;

    function new(string name = "host_h2d_data_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_data_port = new("h2d_data_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_data_if)::get(this, "", "host_h2d_data_if", host_h2d_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_data_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_h2d_data_if.clk);
            if(host_h2d_data_if.h2d_data_txn.valid && host_h2d_data_if.ready) begin
              h2d_data_seq_item_h = h2d_data_seq_item::type_id::create("h2d_data_seq_item_h", this);
              h2d_data_seq_item_h.valid         = host_h2d_data_if.h2d_data_txn.valid;
              h2d_data_seq_item_h.cqid          = host_h2d_data_if.h2d_data_txn.cqid;
              h2d_data_seq_item_h.chunkvalid    = host_h2d_data_if.h2d_data_txn.chunkvalid;
              h2d_data_seq_item_h.poison        = host_h2d_data_if.h2d_data_txn.poison;
              h2d_data_seq_item_h.goerr         = host_h2d_data_if.h2d_data_txn.goerr;
              h2d_data_seq_item_h.data          = host_h2d_data_if.h2d_data_txn.data;
              h2d_data_port.write(h2d_data_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_m2s_req_monitor extends uvm_monitor;
    `uvm_component_utils(host_m2s_req_monitor)
    
    uvm_analysis_port#(m2s_req_seq_item) m2s_req_port;
    virtual cxl_mem_m2s_req_if.mon host_m2s_req_if;
    m2s_req_seq_item m2s_req_seq_item_h;

    function new(string name = "host_m2s_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      m2s_req_port = new("m2s_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_req_if)::get(this, "", "host_m2s_req_if", host_m2s_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_m2s_req_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_m2s_req_if.clk);
            if(host_m2s_req_if.m2s_req_txn.valid && host_m2s_req_if.ready) begin
              m2s_req_seq_item_h = m2s_req_seq_item::type_id::create("m2s_req_seq_item_h", this);
              m2s_req_seq_item_h.valid         = host_m2s_req_if.m2s_req_txn.valid;
              m2s_req_seq_item_h.address       = host_m2s_req_if.m2s_req_txn.address;
              m2s_req_seq_item_h.opcode        = host_m2s_req_if.m2s_req_txn.opcode;
              m2s_req_seq_item_h.metafield     = host_m2s_req_if.m2s_req_txn.metafield;
              m2s_req_seq_item_h.metavalue     = host_m2s_req_if.m2s_req_txn.metavalue;
              m2s_req_seq_item_h.snptype       = host_m2s_req_if.m2s_req_txn.snptype;
              m2s_req_seq_item_h.tag           = host_m2s_req_if.m2s_req_txn.tag;
              m2s_req_seq_item_h.tc            = host_m2s_req_if.m2s_req_txn.tc;
              m2s_req_port.write(m2s_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_m2s_rwd_monitor extends uvm_monitor;
    `uvm_component_utils(host_m2s_rwd_monitor)
    
    uvm_analysis_port#(m2s_rwd_seq_item) m2s_rwd_port;
    virtual cxl_mem_m2s_rwd_if.mon host_m2s_rwd_if;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;

    function new(string name = "host_m2s_rwd_monitor", uvm_component parent = null);
      super.new(name, parent);
      m2s_rwd_port = new("m2s_rwd_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_rwd_if)::get(this, "", "host_m2s_rwd_if", host_m2s_rwd_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_m2s_rwd_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_m2s_rwd_if.clk);
            if(host_m2s_rwd_if.m2s_rwd_txn.valid && host_m2s_rwd_if.ready) begin
              m2s_rwd_seq_item_h = m2s_rwd_seq_item::type_id::create("m2s_rwd_seq_item_h", this);
              m2s_rwd_seq_item_h.valid         = host_m2s_rwd_if.m2s_rwd_txn.valid;
              m2s_rwd_seq_item_h.address       = host_m2s_rwd_if.m2s_rwd_txn.address;
              m2s_rwd_seq_item_h.opcode        = host_m2s_rwd_if.m2s_rwd_txn.opcode;
              m2s_rwd_seq_item_h.metafield     = host_m2s_rwd_if.m2s_rwd_txn.metafield;
              m2s_rwd_seq_item_h.metavalue     = host_m2s_rwd_if.m2s_rwd_txn.metavalue;
              m2s_rwd_seq_item_h.snptype       = host_m2s_rwd_if.m2s_rwd_txn.snptype;
              m2s_rwd_seq_item_h.tag           = host_m2s_rwd_if.m2s_rwd_txn.tag;
              m2s_rwd_seq_item_h.tc            = host_m2s_rwd_if.m2s_rwd_txn.tc;
              m2s_rwd_seq_item_h.poison        = host_m2s_rwd_if.m2s_rwd_txn.poison;
              m2s_rwd_seq_item_h.data          = host_m2s_rwd_if.m2s_rwd_txn.data;
              m2s_rwd_port.write(m2s_rwd_seq_item_h);
            end  
          end
        end
      join_none
    endtask
  
  endclass

  class dev_s2m_ndr_monitor extends uvm_monitor;
    `uvm_component_utils(dev_s2m_ndr_monitor)
    
    uvm_analysis_port#(s2m_ndr_seq_item) s2m_ndr_port;
    virtual cxl_mem_s2m_ndr_if.mon dev_s2m_ndr_if;
    s2m_ndr_seq_item s2m_ndr_seq_item_h;

    function new(string name = "dev_s2m_ndr_monitor", uvm_component parent = null);
      super.new(name, parent);
      s2m_ndr_port = new("s2m_ndr_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_s2m_ndr_if)::get(this, "", "dev_s2m_ndr_if", dev_s2m_ndr_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_s2m_ndr_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_s2m_ndr_if.clk);
            if(dev_s2m_ndr_if.s2m_ndr_txn.valid && dev_s2m_ndr_if.ready) begin
              s2m_ndr_seq_item_h = s2m_ndr_seq_item::type_id::create("s2m_ndr_seq_item_h", this);
              s2m_ndr_seq_item_h.valid         = dev_s2m_ndr_if.s2m_ndr_txn.valid;
              s2m_ndr_seq_item_h.opcode        = dev_s2m_ndr_if.s2m_ndr_txn.opcode;
              s2m_ndr_seq_item_h.metafield     = dev_s2m_ndr_if.s2m_ndr_txn.metafield;
              s2m_ndr_seq_item_h.metavalue     = dev_s2m_ndr_if.s2m_ndr_txn.metavalue;
              s2m_ndr_seq_item_h.tag           = dev_s2m_ndr_if.s2m_ndr_txn.tag;
              s2m_ndr_port.write(s2m_ndr_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class dev_s2m_drs_monitor extends uvm_monitor;
    `uvm_component_utils(dev_s2m_drs_monitor)
    
    uvm_analysis_port#(s2m_drs_seq_item) s2m_drs_port;
    virtual cxl_mem_s2m_drs_if.mon dev_s2m_drs_if;
    s2m_drs_seq_item s2m_drs_seq_item_h;

    function new(string name = "dev_s2m_drs_monitor", uvm_component parent = null);
      super.new(name, parent);
      s2m_drs_port = new("s2m_drs_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_s2m_drs_if)::get(this, "", "dev_s2m_drs_if", dev_s2m_drs_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_s2m_drs_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_s2m_drs_if.clk);
            if(dev_s2m_drs_if.s2m_drs_txn.valid && dev_s2m_drs_if.ready) begin
              s2m_drs_seq_item_h = s2m_drs_seq_item::type_id::create("s2m_drs_seq_item_h", this);
              s2m_drs_seq_item_h.valid         = dev_s2m_drs_if.s2m_drs_txn.valid;
              s2m_drs_seq_item_h.opcode        = dev_s2m_drs_if.s2m_drs_txn.opcode;
              s2m_drs_seq_item_h.metafield     = dev_s2m_drs_if.s2m_drs_txn.metafield;
              s2m_drs_seq_item_h.metavalue     = dev_s2m_drs_if.s2m_drs_txn.metavalue;
              s2m_drs_seq_item_h.tag           = dev_s2m_drs_if.s2m_drs_txn.tag;
              s2m_drs_seq_item_h.poison        = dev_s2m_drs_if.s2m_drs_txn.poison;
              s2m_drs_seq_item_h.data          = dev_s2m_drs_if.s2m_drs_txn.data;
              s2m_drs_port.write(s2m_drs_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_d2h_req_monitor extends uvm_monitor;
    `uvm_component_utils(host_d2h_req_monitor)
    
    uvm_analysis_port#(d2h_req_seq_item) d2h_req_port;
    virtual cxl_cache_d2h_req_if.mon host_d2h_req_if;
    d2h_req_seq_item d2h_req_seq_item_h;

    function new(string name = "host_d2h_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_req_port = new("d2h_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_req_if)::get(this, "", "host_d2h_req_if", host_d2h_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_req_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_d2h_req_if.clk);
            if(host_d2h_req_if.d2h_req_txn.valid && host_d2h_req_if.ready) begin
              d2h_req_seq_item_h = d2h_req_seq_item::type_id::create("d2h_req_seq_item_h", this);
              d2h_req_seq_item_h.valid    = host_d2h_req_if.d2h_req_txn.valid;
              d2h_req_seq_item_h.opcode   = host_d2h_req_if.d2h_req_txn.opcode;
              d2h_req_seq_item_h.address  = host_d2h_req_if.d2h_req_txn.address;
              d2h_req_seq_item_h.cqid     = host_d2h_req_if.d2h_req_txn.cqid;
              d2h_req_seq_item_h.nt       = host_d2h_req_if.d2h_req_txn.nt;
              d2h_req_port.write(d2h_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask
  endclass

  class host_d2h_rsp_monitor extends uvm_monitor;
    `uvm_component_utils(host_d2h_rsp_monitor)
    
    uvm_analysis_port#(d2h_rsp_seq_item) d2h_rsp_port;
    virtual cxl_cache_d2h_rsp_if.mon host_d2h_rsp_if;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;

    function new(string name = "host_d2h_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_rsp_port = new("d2h_rsp_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_rsp_if)::get(this, "", "host_d2h_rsp_if", host_d2h_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_rsp_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_d2h_rsp_if.clk);
            if(host_d2h_rsp_if.d2h_rsp_txn.valid && host_d2h_rsp_if.ready) begin
              d2h_rsp_seq_item_h = d2h_rsp_seq_item::type_id::create("d2h_rsp_seq_item_h", this);
              d2h_rsp_seq_item_h.valid   = host_d2h_rsp_if.d2h_rsp_txn.valid;
              d2h_rsp_seq_item_h.opcode  = host_d2h_rsp_if.d2h_rsp_txn.opcode;
              d2h_rsp_seq_item_h.uqid    = host_d2h_rsp_if.d2h_rsp_txn.uqid;
              d2h_rsp_port.write(d2h_rsp_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_d2h_data_monitor extends uvm_monitor;
    `uvm_component_utils(host_d2h_data_monitor)
    
    uvm_analysis_port#(d2h_data_seq_item) d2h_data_port;
    virtual cxl_cache_d2h_data_if.mon host_d2h_data_if;
    d2h_data_seq_item d2h_data_seq_item_h;

    function new(string name = "host_d2h_data_monitor", uvm_component parent = null);
      super.new(name, parent);
      d2h_data_port = new("d2h_data_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_data_if)::get(this, "", "host_d2h_data_if", host_d2h_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_data_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_d2h_data_if.clk);
            if(host_d2h_data_if.d2h_data_txn.valid && host_d2h_data_if.ready) begin
              d2h_data_seq_item_h = d2h_data_seq_item::type_id::create("d2h_data_seq_item_h", this);
              d2h_data_seq_item_h.valid         = host_d2h_data_if.d2h_data_txn.valid;
              d2h_data_seq_item_h.uqid          = host_d2h_data_if.d2h_data_txn.uqid;
              d2h_data_seq_item_h.chunkvalid    = host_d2h_data_if.d2h_data_txn.chunkvalid;
              d2h_data_seq_item_h.bogus         = host_d2h_data_if.d2h_data_txn.bogus;
              d2h_data_seq_item_h.poison        = host_d2h_data_if.d2h_data_txn.poison;
              d2h_data_seq_item_h.data          = host_d2h_data_if.d2h_data_txn.data;
              d2h_data_port.write(d2h_data_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class dev_h2d_req_monitor extends uvm_monitor;
    `uvm_component_utils(dev_h2d_req_monitor)
    
    uvm_analysis_port#(h2d_req_seq_item) h2d_req_port;
    virtual cxl_cache_h2d_req_if.mon dev_h2d_req_if;

    function new(string name = "dev_h2d_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_req_port = new("h2d_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_req_if)::get(this, "", "dev_h2d_req_if", dev_h2d_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_req_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_h2d_req_if.clk);
            if(dev_h2d_req_if.h2d_req_txn.valid && dev_h2d_req_if.ready) begin
              h2d_req_seq_item_h = h2d_req_seq_item::type_id::create("h2d_req_seq_item_h", this);
              h2d_req_seq_item_h.valid         = dev_h2d_req_if.h2d_req_txn.valid;
              h2d_req_seq_item_h.opcode        = dev_h2d_req_if.h2d_req_txn.opcode;
              h2d_req_seq_item_h.address       = dev_h2d_req_if.h2d_req_txn.address;
              h2d_req_seq_item_h.uqid          = dev_h2d_req_if.h2d_req_txn.uqid;
              h2d_req_port.write(h2d_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass
  
  class dev_h2d_rsp_monitor extends uvm_monitor;
    `uvm_component_utils(dev_h2d_rsp_monitor)
    
    uvm_analysis_port#(h2d_rsp_seq_item) h2d_rsp_port;
    virtual cxl_cache_h2d_rsp_if.mon dev_h2d_rsp_if;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;

    function new(string name = "dev_h2d_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_rsp_port = new("h2d_rsp_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_rsp_if)::get(this, "", "dev_h2d_rsp_if", dev_h2d_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_rsp_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_h2d_rsp_if.clk);
            if(dev_h2d_rsp_if.h2d_rsp_txn.valid && dev_h2d_rsp_if.ready) begin
              h2d_rsp_seq_item_h = h2d_rsp_seq_item::type_id::create("h2d_rsp_seq_item_h", this);
              h2d_rsp_seq_item_h.valid         = dev_h2d_rsp_if.h2d_rsp_txn.valid;
              h2d_rsp_seq_item_h.opcode        = dev_h2d_rsp_if.h2d_rsp_txn.opcode;
              h2d_rsp_seq_item_h.rspdata       = dev_h2d_rsp_if.h2d_rsp_txn.rspdata;
              h2d_rsp_seq_item_h.rsppre        = dev_h2d_rsp_if.h2d_rsp_txn.rsppre;
              h2d_rsp_seq_item_h.cqid          = dev_h2d_rsp_if.h2d_rsp_txn.cqid;
              h2d_rsp_port.write(h2d_rsp_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class dev_h2d_data_monitor extends uvm_monitor;
    `uvm_component_utils(dev_h2d_data_monitor)
    
    uvm_analysis_port#(h2d_data_seq_item) h2d_data_port;
    virtual cxl_cache_h2d_data_if.mon dev_h2d_data_if;
    h2d_data_seq_item h2d_data_seq_item_h;

    function new(string name = "dev_h2d_data_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_data_port = new("h2d_data_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_data_if)::get(this, "", "dev_h2d_data_if", dev_h2d_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_data_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_h2d_data_if.clk);
            if(dev_h2d_data_if.h2d_data_txn.valid && dev_h2d_data_if.ready) begin
              h2d_data_seq_item_h = h2d_data_seq_item::type_id::create("h2d_data_seq_item_h", this);
              h2d_data_seq_item_h.valid         = dev_h2d_data_if.h2d_data_txn.valid;
              h2d_data_seq_item_h.cqid          = dev_h2d_data_if.h2d_data_txn.cqid;
              h2d_data_seq_item_h.chunkvalid    = dev_h2d_data_if.h2d_data_txn.chunkvalid;
              h2d_data_seq_item_h.poison        = dev_h2d_data_if.h2d_data_txn.poison;
              h2d_data_seq_item_h.goerr         = dev_h2d_data_if.h2d_data_txn.goerr;
              h2d_data_seq_item_h.data          = dev_h2d_data_if.h2d_data_txn.data;
              h2d_data_port.write(h2d_data_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class dev_m2s_req_monitor extends uvm_monitor;
    `uvm_component_utils(dev_m2s_req_monitor)
    
    uvm_analysis_port#(m2s_req_seq_item) m2s_req_port;
    virtual cxl_mem_m2s_req_if.mon dev_m2s_req_if;
    m2s_req_seq_item m2s_req_seq_item_h;

    function new(string name = "dev_m2s_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      m2s_req_port = new("m2s_req_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_req_if)::get(this, "", "dev_m2s_req_if", dev_m2s_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_m2s_req_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_m2s_req_if.clk);
            if(dev_m2s_req_if.m2s_req_txn.valid && dev_m2s_req_if.ready) begin
              m2s_req_seq_item_h = m2s_req_seq_item::type_id::create("m2s_req_seq_item_h", this);
              m2s_req_seq_item_h.valid         = dev_m2s_req_if.m2s_req_txn.valid;
              m2s_req_seq_item_h.address       = dev_m2s_req_if.m2s_req_txn.address;
              m2s_req_seq_item_h.opcode        = dev_m2s_req_if.m2s_req_txn.opcode;
              m2s_req_seq_item_h.metafield     = dev_m2s_req_if.m2s_req_txn.metafield;
              m2s_req_seq_item_h.metavalue     = dev_m2s_req_if.m2s_req_txn.metavalue;
              m2s_req_seq_item_h.snptype       = dev_m2s_req_if.m2s_req_txn.snptype;
              m2s_req_seq_item_h.tag           = dev_m2s_req_if.m2s_req_txn.tag;
              m2s_req_seq_item_h.tc            = dev_m2s_req_if.m2s_req_txn.tc;
              m2s_req_port.write(m2s_req_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class dev_m2s_rwd_monitor extends uvm_monitor;
    `uvm_component_utils(dev_m2s_rwd_monitor)
    
    uvm_analysis_port#(m2s_rwd_seq_item) m2s_rwd_port;
    virtual cxl_mem_m2s_rwd_if.mon dev_m2s_rwd_if;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;

    function new(string name = "dev_m2s_rwd_monitor", uvm_component parent = null);
      super.new(name, parent);
      m2s_rwd_port = new("m2s_rwd_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_rwd_if)::get(this, "", "dev_m2s_rwd_if", dev_m2s_rwd_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_m2s_rwd_if"));
      end
      fork
        begin
          forever begin
            @(posedge dev_m2s_rwd_if.clk);
            if(dev_m2s_rwd_if.m2s_rwd_txn.valid && dev_m2s_rwd_if.ready) begin
              m2s_rwd_seq_item_h = m2s_rwd_seq_item::type_id::create("m2s_rwd_seq_item_h", this);
              m2s_rwd_seq_item_h.valid         = dev_m2s_rwd_if.m2s_rwd_txn.valid;
              m2s_rwd_seq_item_h.address       = dev_m2s_rwd_if.m2s_rwd_txn.address;
              m2s_rwd_seq_item_h.opcode        = dev_m2s_rwd_if.m2s_rwd_txn.opcode;
              m2s_rwd_seq_item_h.metafield     = dev_m2s_rwd_if.m2s_rwd_txn.metafield;
              m2s_rwd_seq_item_h.metavalue     = dev_m2s_rwd_if.m2s_rwd_txn.metavalue;
              m2s_rwd_seq_item_h.snptype       = dev_m2s_rwd_if.m2s_rwd_txn.snptype;
              m2s_rwd_seq_item_h.tag           = dev_m2s_rwd_if.m2s_rwd_txn.tag;
              m2s_rwd_seq_item_h.tc            = dev_m2s_rwd_if.m2s_rwd_txn.tc;
              m2s_rwd_seq_item_h.poison        = dev_m2s_rwd_if.m2s_rwd_txn.poison;
              m2s_rwd_seq_item_h.data          = dev_m2s_rwd_if.m2s_rwd_txn.data;
              m2s_rwd_port.write(m2s_rwd_seq_item_h);
            end  
          end
        end
      join_none
    endtask
  
  endclass

  class host_s2m_ndr_monitor extends uvm_monitor;
    `uvm_component_utils(host_s2m_ndr_monitor)
    
    uvm_analysis_port#(s2m_ndr_seq_item) s2m_ndr_port;
    virtual cxl_mem_s2m_ndr_if.mon host_s2m_ndr_if;
    s2m_ndr_seq_item s2m_ndr_seq_item_h;

    function new(string name = "host_s2m_ndr_monitor", uvm_component parent = null);
      super.new(name, parent);
      s2m_ndr_port = new("s2m_ndr_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_s2m_ndr_if)::get(this, "", "host_s2m_ndr_if", host_s2m_ndr_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_s2m_ndr_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_s2m_ndr_if.clk);
            if(host_s2m_ndr_if.s2m_ndr_txn.valid && host_s2m_ndr_if.ready) begin
              s2m_ndr_seq_item_h = s2m_ndr_seq_item::type_id::create("s2m_ndr_seq_item_h", this);
              s2m_ndr_seq_item_h.valid         = host_s2m_ndr_if.s2m_ndr_txn.valid;
              s2m_ndr_seq_item_h.opcode        = host_s2m_ndr_if.s2m_ndr_txn.opcode;
              s2m_ndr_seq_item_h.metafield     = host_s2m_ndr_if.s2m_ndr_txn.metafield;
              s2m_ndr_seq_item_h.metavalue     = host_s2m_ndr_if.s2m_ndr_txn.metavalue;
              s2m_ndr_seq_item_h.tag           = host_s2m_ndr_if.s2m_ndr_txn.tag;
              s2m_ndr_port.write(s2m_ndr_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_s2m_drs_monitor extends uvm_monitor;
    `uvm_component_utils(host_s2m_drs_monitor)
    
    uvm_analysis_port#(s2m_drs_seq_item) s2m_drs_port;
    virtual cxl_mem_s2m_drs_if.mon host_s2m_drs_if;
    s2m_drs_seq_item s2m_drs_seq_item_h;

    function new(string name = "host_s2m_drs_monitor", uvm_component parent = null);
      super.new(name, parent);
      s2m_drs_port = new("s2m_drs_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      if(!(uvm_config_db#(cxl_mem_s2m_drs_if)::get(this, "", "host_s2m_drs_if", host_s2m_drs_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_s2m_drs_if"));
      end
      fork
        begin
          forever begin
            @(posedge host_s2m_drs_if.clk);
            if(host_s2m_drs_if.s2m_drs_txn.valid && host_s2m_drs_if.ready) begin
              s2m_drs_seq_item_h = s2m_drs_seq_item::type_id::create("s2m_drs_seq_item_h", this);
              s2m_drs_seq_item_h.valid         = host_s2m_drs_if.s2m_drs_txn.valid;
              s2m_drs_seq_item_h.opcode        = host_s2m_drs_if.s2m_drs_txn.opcode;
              s2m_drs_seq_item_h.metafield     = host_s2m_drs_if.s2m_drs_txn.metafield;
              s2m_drs_seq_item_h.metavalue     = host_s2m_drs_if.s2m_drs_txn.metavalue;
              s2m_drs_seq_item_h.tag           = host_s2m_drs_if.s2m_drs_txn.tag;
              s2m_drs_seq_item_h.poison        = host_s2m_drs_if.s2m_drs_txn.poison;
              s2m_drs_seq_item_h.data          = host_s2m_drs_if.s2m_drs_txn.data;
              s2m_drs_port.write(s2m_drs_seq_item_h);
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_d2h_req_driver extends uvm_driver;
    `uvm_component_utils(host_d2h_req_driver)
    
    virtual cxl_cache_d2h_req_if.host_pasv_drvr_mp host_d2h_req_if;
    d2h_req_seq_item d2h_req_seq_item_h;

    function new(string name = "host_d2h_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_req_if)::get(this, "", "host_d2h_req_if", host_d2h_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_req_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(d2h_req_seq_item_h);  
        if(d2h_req_seq_item_h.delay_set) begin
          repeat(d2h_req_seq_item_h.delay_value) @(negedge host_d2h_req_if.clk);
        end
        @(negedge host_d2h_req_if.clk);
        host_d2h_req_if.ready <= 'h1;
        do begin
          @(negedge host_d2h_req_if.clk);
        end while(!host_d2h_req_if.d2h_req_txn.valid);
        host_d2h_req_if.ready <= 'h0;
        seq_item_port.item_done(d2h_req_seq_item_h);
      end
    endtask

  endclass

  class host_d2h_rsp_driver extends uvm_driver;
    `uvm_component_utils(host_d2h_rsp_driver)
    
    virtual cxl_cache_d2h_rsp_if.host_pasv_drvr_mp host_d2h_rsp_if;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;

    function new(string name = "host_d2h_rsp_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_rsp_if)::get(this, "", "host_d2h_rsp_if", host_d2h_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_rsp_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(d2h_rsp_seq_item_h);  
        if(d2h_rsp_seq_item_h.delay_set) begin
          repeat(d2h_rsp_seq_item_h.delay_value) @(negedge host_d2h_rsp_if.clk);
        end
        @(negedge host_d2h_rsp_if.clk);
        host_d2h_rsp_if.ready <= 'h1;
        do begin
          @(negedge host_d2h_rsp_if.clk);
        end while(!host_d2h_rsp_if.d2h_rsp_txn.valid);
        host_d2h_rsp_if.ready <= 'h0;
        seq_item_port.item_done(d2h_rsp_seq_item_h);
      end
    endtask

  endclass

  class host_d2h_data_driver extends uvm_driver;
    `uvm_component_utils(host_d2h_data_driver)
    
    virtual cxl_cache_d2h_data_if.host_pasv_drvr_mp host_d2h_data_if;
    d2h_data_seq_item d2h_data_seq_item_h;

    function new(string name = "host_d2h_data_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_data_if)::get(this, "", "host_d2h_data_if", host_d2h_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_data_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(d2h_data_seq_item_h);  
        if(d2h_data_seq_item_h.delay_set) begin
          repeat(d2h_data_seq_item_h.delay_value) @(negedge host_d2h_data_if.clk);
        end
        @(negedge host_d2h_data_if.clk);
        host_d2h_data_if.ready <= 'h1;
        do begin
          @(negedge host_d2h_data_if.clk);
        end while(!host_d2h_data_if.d2h_data_txn.valid);
        host_d2h_data_if.ready <= 'h0;
        seq_item_port.item_done(d2h_data_seq_item_h);
      end
    endtask

  endclass

  class host_s2m_ndr_driver extends uvm_driver;
    `uvm_component_utils(host_s2m_ndr_driver)
    
    virtual cxl_mem_s2m_ndr_if.host_pasv_drvr_mp host_s2m_ndr_if;
    s2m_ndr_seq_item s2m_ndr_seq_item_h;

    function new(string name = "host_s2m_ndr_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase)
      if(!(uvm_config_db#(cxl_mem_s2m_ndr_if)::get(this, "", "host_s2m_ndr_if", host_s2m_ndr_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_s2m_ndr_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(s2m_ndr_seq_item_h);  
        if(s2m_ndr_seq_item_h.delay_set) begin
          repeat(s2m_ndr_seq_item_h.delay_value) @(negedge host_s2m_ndr_if.clk);
        end
        @(negedge host_s2m_ndr_if.clk);
        host_s2m_ndr_if.ready <= 'h1;
        do begin
          @(negedge host_s2m_ndr_if.clk);
        end while(!host_s2m_ndr_if.s2m_ndr_txn.valid);
        host_s2m_ndr_if.ready <= 'h0;
        seq_item_port.item_done(s2m_ndr_seq_item_h);
      end
    endtask

  endclass

  class host_s2m_drs_driver extends uvm_driver;
    `uvm_component_utils(host_s2m_drs_driver)
    
    virtual cxl_mem_s2m_drs_if.host_pasv_drvr_mp host_s2m_drs_if;
    s2m_drs_seq_item s2m_drs_seq_item_h;

    function new(string name = "host_s2m_drs_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_host_s2m_drs_if)::get(this, "", "host_s2m_drs_if", host_s2m_drs_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_s2m_drs_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(s2m_drs_seq_item_h);  
        if(s2m_drs_seq_item_h.delay_set) begin
          repeat(s2m_drs_seq_item_h.delay_value) @(negedge host_s2m_drs_if.clk);
        end
        @(negedge host_s2m_drs_if.clk);
        host_s2m_drs_if.ready <= 'h1;
        do begin
          @(negedge host_s2m_drs_if.clk);
        end while(!host_s2m_drs_if.s2m_drs_txn.valid);
        host_s2m_drs_if.ready <= 'h0;
        seq_item_port.item_done(s2m_drs_seq_item_h);
      end
    endtask

  endclass

  class dev_h2d_req_driver extends uvm_driver;
    `uvm_component_utils(dev_h2d_req_driver)
    
    virtual cxl_cache_h2d_req_if.dev_pasv_drvr_mp dev_h2d_req_if;
    h2d_req_seq_item h2d_req_seq_item_h;

    function new(string name = "dev_h2d_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_req_if)::get(this, "", "dev_h2d_req_if", dev_h2d_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_req_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(h2d_req_seq_item_h);  
        if(h2d_req_seq_item_h.delay_set) begin
          repeat(h2d_req_seq_item_h.delay_value) @(negedge dev_h2d_req_if.clk);
        end
        @(negedge dev_h2d_req_if.clk);
        dev_h2d_req_if.ready <= 'h1;
        do begin
          @(negedge dev_h2d_req_if.clk);
        end while(!dev_h2d_req_if.h2d_req_txn.valid);
        dev_h2d_req_if.ready <= 'h0;
        seq_item_port.item_done(h2d_req_seq_item_h);
      end
    endtask

  endclass

  class dev_h2d_rsp_driver extends uvm_driver;
    `uvm_component_utils(dev_h2d_rsp_driver)
    
    virtual cxl_cache_h2d_rsp_if.dev_pasv_drvr_mp dev_h2d_rsp_if;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;

    function new(string name = "dev_h2d_rsp_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_rsp_if)::get(this, "", "dev_h2d_rsp_if", dev_h2d_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_rsp_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(h2d_rsp_seq_item_h);  
        if(h2d_rsp_seq_item_h.delay_set) begin
          repeat(h2d_rsp_seq_item_h.delay_value) @(negedge dev_h2d_rsp_if.clk);
        end
        @(negedge dev_h2d_rsp_if.clk);
        dev_h2d_rsp_if.ready <= 'h1;
        do begin
          @(negedge dev_h2d_rsp_if.clk);
        end while(!dev_h2d_rsp_if.h2d_rsp_txn.valid);
        dev_h2d_rsp_if.ready <= 'h0;
        seq_item_port.item_done(h2d_rsp_seq_item_h);
      end
    endtask

  endclass

  class dev_h2d_data_driver extends uvm_driver;
    `uvm_component_utils(dev_h2d_data_driver)
    
    virtual cxl_cache_h2d_data_if.dev_pasv_drvr_mp dev_h2d_data_if;
    h2d_data_seq_item h2d_data_seq_item_h;

    function new(string name = "dev_h2d_data_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_req_if)::get(this, "", "dev_h2d_data_if", dev_h2d_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_data_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(h2d_data_seq_item_h);  
        if(h2d_data_seq_item_h.delay_set) begin
          repeat(h2d_data_seq_item_h.delay_value) @(negedge dev_h2d_data_if.clk);
        end
        @(negedge dev_h2d_data_if.clk);
        dev_h2d_data_if.ready <= 'h1;
        do begin
          @(negedge dev_h2d_data_if.clk);
        end while(!dev_h2d_data_if.h2d_data_txn.valid);
        dev_h2d_data_if.ready <= 'h0;
        seq_item_port.item_done(h2d_data_seq_item_h);
      end
    endtask

  endclass

  class dev_m2s_req_driver extends uvm_driver;
    `uvm_component_utils(dev_m2s_req_driver)
    
    virtual cxl_mem_m2s_req_if.dev_pasv_drvr_mp dev_m2s_req_if;
    m2s_req_seq_item m2s_req_seq_item_h;

    function new(string name = "dev_m2s_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_req_if)::get(this, "", "dev_m2s_req_if", dev_m2s_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_m2s_req_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(m2s_req_seq_item_h);  
        if(m2s_req_seq_item_h.delay_set) begin
          repeat(m2s_req_seq_item_h.delay_value) @(negedge dev_m2s_req_if.clk);
        end
        @(negedge dev_m2s_req_if.clk);
        dev_m2s_req_if.ready <= 'h1;
        do begin
          @(negedge dev_m2s_req_if.clk);
        end while(!dev_m2s_req_if.m2s_req_txn.valid);
        dev_m2s_req_if.ready <= 'h0;
        seq_item_port.item_done(m2s_req_seq_item_h);
      end
    endtask

  endclass

  class dev_m2s_rwd_driver extends uvm_driver;
    `uvm_component_utils(dev_m2s_rwd_driver)
    
    virtual cxl_mem_m2s_rwd_if.dev_pasv_drvr_mp dev_m2s_rwd_if;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;

    function new(string name = "dev_m2s_rwd_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_req_if)::get(this, "", "dev_m2s_rwd_if", dev_m2s_rwd_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_m2s_rwd_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(m2s_rwd_seq_item_h);  
        if(m2s_rwd_seq_item_h.delay_set) begin
          repeat(m2s_rwd_seq_item_h.delay_value) @(negedge dev_m2s_rwd_if.clk);
        end
        @(negedge dev_m2s_rwd_if.clk);
        dev_m2s_rwd_if.ready <= 'h1;
        do begin
          @(negedge dev_m2s_rwd_if.clk);
        end while(!dev_m2s_rwd_if.m2s_rwd_txn.valid);
        dev_m2s_rwd_if.ready <= 'h0;
        seq_item_port.item_done(m2s_rwd_seq_item_h);
      end
    endtask

  endclass

  class dev_d2h_req_driver extends uvm_driver;
    `uvm_component_utils(dev_d2h_req_driver)
    
    virtual cxl_cache_d2h_req_if.dev_actv_drvr_mp dev_d2h_req_if;
    d2h_req_seq_item d2h_req_seq_item_h;

    function new(string name = "dev_d2h_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      if(!(uvm_config_db#(cxl_cache_d2h_req_if)::get(this, "", "dev_d2h_req_if", dev_d2h_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_req_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(d2h_req_seq_item_h);
        if(d2h_req_seq_item_h.delay_set) begin
          repeat(d2h_req_seq_item_h.delay_value) @(negedge dev_d2h_req_if.clk);
        end
        dev_d2h_req_if.d2h_req_txn.valid    <=  d2h_req_seq_item_h.valid;
        dev_d2h_req_if.d2h_req_txn.opcode   <=  d2h_req_seq_item_h.opcode;
        dev_d2h_req_if.d2h_req_txn.address  <=  d2h_req_seq_item_h.address;
        dev_d2h_req_if.d2h_req_txn.cqid     <=  d2h_req_seq_item_h.cqid;
        dev_d2h_req_if.d2h_req_txn.nt       <=  d2h_req_seq_item_h.nt;
        do begin
          @(negedge dev_d2h_req_if.clk);
        end while(!dev_d2h_req_if.ready);
        dev_d2h_req_if.d2h_req_txn.valid <= 'h0;
        seq_item_port.item_done(d2h_req_seq_item_h);
      end
    endtask
  endclass

  class dev_d2h_rsp_driver extends uvm_driver;
    `uvm_component_utils(dev_d2h_rsp_driver)
    
    virtual cxl_cache_d2h_rsp_if.dev_actv_drvr_mp dev_d2h_rsp_if;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;

    function new(string name = "dev_d2h_rsp_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      if(!(uvm_config_db#(cxl_cache_d2h_rsp_if)::get(this, "", "dev_d2h_rsp_if", dev_d2h_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_rsp_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(d2h_rsp_seq_item_h);
        if(d2h_rsp_seq_item_h.delay_set) begin
          repeat(d2h_rsp_seq_item_h.delay_value) @(negedge dev_d2h_rsp_if.clk);
        end
        dev_d2h_rsp_if.d2h_rsp_txn.valid  <=  d2h_rsp_seq_item_h.valid;
        dev_d2h_rsp_if.d2h_rsp_txn.opcode <=  d2h_rsp_seq_item_h.opcode;
        dev_d2h_rsp_if.d2h_rsp_txn.uqid   <=  d2h_rsp_seq_item_h.uqid;
        do begin
          @(negedge dev_d2h_rsp_if.clk);
        end while(!dev_d2h_rsp_if.ready);
        dev_d2h_rsp_if.d2h_rsp_txn.valid <= 'h0;
        seq_item_port.item_done(d2h_rsp_seq_item_h);
      end
    endtask

  endclass

  class dev_d2h_data_driver extends uvm_driver;
    `uvm_component_utils(dev_d2h_data_driver)
    virtual cxl_cache_d2h_data_if.dev_actv_drvr_mp dev_d2h_data_if;
    d2h_data_seq_item d2h_data_seq_item_h;

    function new(string name = "dev_d2h_data_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_d2h_data_if)::get(this, "", "dev_d2h_data_if", dev_d2h_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_data_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(d2h_data_seq_item_h);
        if(d2h_data_seq_item_h.delay_set) begin
          repeat(d2h_data_seq_item_h.delay_value) @(negedge dev_d2h_data_if.clk);
        end
        dev_d2h_data_if.d2h_data_txn.valid     <=  d2h_data_seq_item_h.valid;
        dev_d2h_data_if.d2h_data_txn.uqid      <=  d2h_data_seq_item_h.uqid;
        dev_d2h_data_if.d2h_data_txn.chunkvalid<=  d2h_data_seq_item_h.chunkvalid;
        dev_d2h_data_if.d2h_data_txn.bogus     <=  d2h_data_seq_item_h.bogus;
        dev_d2h_data_if.d2h_data_txn.poison    <=  d2h_data_seq_item_h.poison;
        dev_d2h_data_if.d2h_data_txn.data      <=  d2h_data_seq_item_h.data;
        do begin
          @(negedge dev_d2h_data_if.clk);
        end while(!dev_d2h_data_if.ready);
        dev_d2h_data_if.d2h_data_txn.valid <= 'h0;
        seq_item_port.item_done(d2h_data_seq_item_h);
      end
    endtask

  endclass

  class host_h2d_req_driver extends uvm_driver;
    `uvm_component_utils(host_h2d_req_driver)
    virtual cxl_cache_h2d_req_if.host_actv_drvr_mp host_h2d_req_if;

    function new(string name = "host_h2d_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_req_if)::get(this, "", "host_h2d_req_if", host_h2d_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_req_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(h2d_req_seq_item_h);
        if(h2d_req_seq_item_h.delay_set) begin
          repeat(h2d_req_seq_item_h.delay_value) @(negedge host_h2d_req_if.clk);
        end
        host_h2d_req_if.h2d_req_txn.valid    <=  h2d_req_seq_item_h.valid;
        host_h2d_req_if.h2d_req_txn.opcode   <=  h2d_req_seq_item_h.opcode;
        host_h2d_req_if.h2d_req_txn.address  <=  h2d_req_seq_item_h.address;
        host_h2d_req_if.h2d_req_txn.uqid     <=  h2d_req_seq_item_h.uqid;
        do begin
          @(negedge host_h2d_req_if.clk);
        end while(!host_h2d_req_if.ready);
        host_h2d_req_if.h2d_req_txn.valid <= 'h0;
        seq_item_port.item_done(h2d_req_seq_item_h);
      end
    endtask

  endclass
  
  class host_h2d_rsp_driver extends uvm_driver;
    `uvm_component_utils(host_h2d_rsp_driver)
    virtual cxl_cache_h2d_rsp_if.host_actv_drvr_mp host_h2d_rsp_if;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;

    function new(string name = "host_h2d_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_rsp_if)::get(this, "", "host_h2d_rsp_if", host_h2d_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_rsp_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(h2d_rsp_seq_item_h);
        if(h2d_rsp_seq_item_h.delay_set) begin
          repeat(h2d_rsp_seq_item_h.delay_value) @(negedge host_h2d_rsp_if.clk);
        end
        host_h2d_rsp_if.h2d_rsp_txn.valid  <=  h2d_rsp_seq_item_h.valid;
        host_h2d_rsp_if.h2d_rsp_txn.opcode <=  h2d_rsp_seq_item_h.opcode;
        host_h2d_rsp_if.h2d_rsp_txn.rspdata<=  h2d_rsp_seq_item_h.rspdata;
        host_h2d_rsp_if.h2d_rsp_txn.rsppre <=  h2d_rsp_seq_item_h.rsppre;
        host_h2d_rsp_if.h2d_rsp_txn.cqid   <=  h2d_rsp_seq_item_h.cqid;
        do begin
          @(negedge host_h2d_rsp_if.clk);
        end while(!host_h2d_rsp_if.ready);
        host_h2d_rsp_if.h2d_rsp_txn.valid <= 'h0;
        seq_item_port.item_done(h2d_rsp_seq_item_h);
      end
    endtask

  endclass

  class host_h2d_data_driver extends uvm_driver;
    `uvm_component_utils(host_h2d_data_driver)
    virtual cxl_cache_h2d_data_if.host_actv_drvr_mp host_h2d_data_if;
    h2d_data_seq_item h2d_data_seq_item_h;

    function new(string name = "host_h2d_data_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_cache_h2d_data_if)::get(this, "", "host_h2d_data_if", host_h2d_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_data_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        seq_item_port.get_next_item(h2d_data_seq_item_h);
        if(h2d_data_seq_item_h.delay_set) begin
          repeat(h2d_data_seq_item_h.delay_value) @(negedge host_h2d_data_if.clk);
        end
        host_h2d_data_if.h2d_data_txn.valid     <=  h2d_data_seq_item_h.valid;
        host_h2d_data_if.h2d_data_txn.cqid      <=  h2d_data_seq_item_h.cqid;
        host_h2d_data_if.h2d_data_txn.chunkvalid<=  h2d_data_seq_item_h.chunkvalid;
        host_h2d_data_if.h2d_data_txn.poison    <=  h2d_data_seq_item_h.poison;
        host_h2d_data_if.h2d_data_txn.goerr     <=  h2d_data_seq_item_h.goerr;
        host_h2d_data_if.h2d_data_txn.data      <=  h2d_data_seq_item_h.data;
        do begin
          @(negedge host_h2d_data_if.clk);
        end while(!host_h2d_data_if.ready);
        host_h2d_data_if.h2d_data_txn.valid <= 'h0;
        seq_item_port.item_done(h2d_data_seq_item_h);
      end
    endtask

  endclass

  class host_m2s_req_driver extends uvm_driver;
    `uvm_component_utils(host_m2s_req_driver)
    virtual cxl_mem_m2s_req_if.host_actv_drvr_mp host_m2s_req_if;
    m2s_req_seq_item m2s_req_seq_item_h;

    function new(string name = "host_m2s_req_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_req_if)::get(this, "", "host_m2s_req_if", host_m2s_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_m2s_req_if"));
      end
    endfunction 

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin  
        seq_item_port.get_next_item(m2s_req_seq_item_h);
        if(m2s_req_seq_item_h.delay_set) begin
          repeat(m2s_req_seq_item_h.delay_value) @(negedge host_m2s_req_if.clk);
        end
        host_m2s_req_if.m2s_req_txn.valid    <=  m2s_req_seq_item_h.valid;
        host_m2s_req_if.m2s_req_txn.address  <=  m2s_req_seq_item_h.address;
        host_m2s_req_if.m2s_req_txn.opcode   <=  m2s_req_seq_item_h.opcode;
        host_m2s_req_if.m2s_req_txn.metafield<=  m2s_req_seq_item_h.metafield;
        host_m2s_req_if.m2s_req_txn.metavalue<=  m2s_req_seq_item_h.metavalue;
        host_m2s_req_if.m2s_req_txn.snptype  <=  m2s_req_seq_item_h.snptype;
        host_m2s_req_if.m2s_req_txn.tag      <=  m2s_req_seq_item_h.tag;
        host_m2s_req_if.m2s_req_txn.tc       <=  m2s_req_seq_item_h.tc;
        do begin
          @(negedge host_m2s_req_if.clk);
        end while(!host_m2s_req_if.ready);
        host_m2s_req_if.m2s_req_txn.valid <= 'h0;
        seq_item_port.item_done(m2s_req_seq_item_h);
      end
    endtask

  endclass

  class host_m2s_rwd_driver extends uvm_driver;
    `uvm_component_utils(host_m2s_rwd_driver)
    virtual cxl_mem_m2s_rwd_if.host_actv_drvr_mp host_m2s_rwd_if;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;

    function new(string name = "host_m2s_rwd_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_mem_m2s_rwd_if)::get(this, "", "host_m2s_rwd_if", host_m2s_rwd_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_m2s_rwd_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin  
        seq_item_port.get_next_item(m2s_rwd_seq_item_h);
        if(m2s_rwd_seq_item_h.delay_set) begin
          repeat(m2s_rwd_seq_item_h.delay_value) @(negedge host_m2s_rwd_if.clk);
        end
        host_m2s_rwd_if.m2s_rwd_txn.valid    <=  m2s_rwd_seq_item_h.valid;
        host_m2s_rwd_if.m2s_rwd_txn.address  <=  m2s_rwd_seq_item_h.address;
        host_m2s_rwd_if.m2s_rwd_txn.opcode   <=  m2s_rwd_seq_item_h.opcode;
        host_m2s_rwd_if.m2s_rwd_txn.metafield<=  m2s_rwd_seq_item_h.metafield;
        host_m2s_rwd_if.m2s_rwd_txn.metavalue<=  m2s_rwd_seq_item_h.metavalue;
        host_m2s_rwd_if.m2s_rwd_txn.snptype  <=  m2s_rwd_seq_item_h.snptype;
        host_m2s_rwd_if.m2s_rwd_txn.tag      <=  m2s_rwd_seq_item_h.tag;
        host_m2s_rwd_if.m2s_rwd_txn.tc       <=  m2s_rwd_seq_item_h.tc;
        host_m2s_rwd_if.m2s_rwd_txn.poison   <=  m2s_rwd_seq_item_h.poison;
        host_m2s_rwd_if.m2s_rwd_txn.data     <=  m2s_rwd_seq_item_h.data;
        do begin
          @(negedge host_m2s_rwd_if.clk);
        end while(!host_m2s_rwd_if.ready);
        host_m2s_rwd_if.m2s_rwd_txn.valid <= 'h0;
        seq_item_port.item_done(m2s_rwd_seq_item_h);
      end
    endtask

  endclass

  class dev_s2m_ndr_driver extends uvm_driver;
    `uvm_component_utils(dev_s2m_ndr_driver)
    virtual cxl_mem_m2s_rwd_if.dev_actv_drvr_mp dev_s2m_ndr_if;
    s2m_ndr_seq_item s2m_ndr_seq_item_h;

    function new(string name = "dev_s2m_ndr_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_mem_s2m_ndr_if)::get(this, "", "dev_s2m_ndr_if", dev_s2m_ndr_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_s2m_ndr_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin  
        seq_item_port.get_next_item(s2m_ndr_seq_item_h);
        if(s2m_ndr_seq_item_h.delay_set) begin
          repeat(s2m_ndr_seq_item_h.delay_value) @(negedge dev_s2m_ndr_if.clk);
        end
        dev_s2m_ndr_if.s2m_ndr_txn.valid    <=  s2m_ndr_seq_item_h.valid;
        dev_s2m_ndr_if.s2m_ndr_txn.opcode   <=  s2m_ndr_seq_item_h.opcode;
        dev_s2m_ndr_if.s2m_ndr_txn.metafield<=  s2m_ndr_seq_item_h.metafield;
        dev_s2m_ndr_if.s2m_ndr_txn.metavalue<=  s2m_ndr_seq_item_h.metavalue;
        dev_s2m_ndr_if.s2m_ndr_txn.tag      <=  s2m_ndr_seq_item_h.tag;
        do begin
          @(negedge dev_s2m_ndr_if.clk);
        end while(!dev_s2m_ndr_if.ready);
        dev_s2m_ndr_if.s2m_ndr_txn.valid <= 'h0;
        seq_item_port.item_done(s2m_ndr_seq_item_h);
      end
    endtask

  endclass

  class dev_s2m_drs_driver extends uvm_driver;
    `uvm_component_utils(dev_s2m_drs_driver)
    virtual cxl_mem_s2m_drs_if.dev_actv_drvr_mp dev_s2m_drs_if;
    s2m_drs_seq_item s2m_drs_seq_item_h;

    function new(string name = "dev_s2m_drs_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!(uvm_config_db#(cxl_mem_s2m_drs_if)::get(this, "", "dev_s2m_drs_if", dev_s2m_drs_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_s2m_drs_if"));
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin  
        seq_item_port.get_next_item(s2m_drs_seq_item_h);
        if(s2m_drs_seq_item_h.delay_set) begin
          repeat(s2m_drs_seq_item_h.delay_value) @(negedge dev_s2m_drs_if.clk);
        end
        dev_s2m_drs_if.s2m_drs_txn.valid    <=  s2m_drs_seq_item_h.valid;
        dev_s2m_drs_if.s2m_drs_txn.opcode   <=  s2m_drs_seq_item_h.opcode;
        dev_s2m_drs_if.s2m_drs_txn.metafield<=  s2m_drs_seq_item_h.metafield;
        dev_s2m_drs_if.s2m_drs_txn.metavalue<=  s2m_drs_seq_item_h.metavalue;
        dev_s2m_drs_if.s2m_drs_txn.tag      <=  s2m_drs_seq_item_h.tag;
        dev_s2m_drs_if.s2m_drs_txn.poison   <=  s2m_drs_seq_item_h.poison;
        dev_s2m_drs_if.s2m_drs_txn.data     <=  s2m_drs_seq_item_h.data;
        do begin
          @(negedge dev_s2m_drs_if.clk);
        end while(!dev_s2m_drs_if.ready);
        dev_s2m_drs_if.s2m_drs_txn.valid <= 'h0;
        seq_item_port.item_done(s2m_drs_seq_item_h);
      end
    endtask

  endclass

  class dev_d2h_req_agent extends uvm_agent;
    `uvm_component_utils(dev_d2h_req_agent)
    dev_d2h_req_driver dev_d2h_req_driver_h;
    dev_d2h_req_monitor dev_d2h_req_monitor_h;
    dev_d2h_req_sequencer dev_d2h_req_sequencer_h;

    function new(string name = "dev_d2h_req_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_req_sequencer_h = dev_d2h_req_sequencer::type_id::create("dev_d2h_req_sequencer_h", this);
        dev_d2h_req_driver_h = dev_d2h_req_driver::type_id::create("dev_d2h_req_driver_h", this);
      end
      dev_d2h_req_monitor_h = dev_d2h_req_monitor::type_id::create("dev_d2h_req_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_req_driver_h.seq_item_port.connect(dev_d2h_req_sequencer_h.seq_item_export);
        dev_d2h_req_monitor_h.d2h_req_port.connect(dev_d2h_req_sequencer_h.dev_d2h_req_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class dev_d2h_rsp_agent extends uvm_agent;
    `uvm_component_utils(dev_d2h_rsp_agent)
    dev_d2h_rsp_driver dev_d2h_rsp_driver_h;
    dev_d2h_rsp_monitor dev_d2h_rsp_monitor_h;
    dev_d2h_rsp_sequencer dev_d2h_rsp_sequencer_h;

    function new(string name = "dev_d2h_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_rsp_sequencer_h = dev_d2h_rsp_sequencer::type_id::create("dev_d2h_rsp_sequencer_h", this);
        dev_d2h_rsp_driver_h = dev_d2h_rsp_driver::type_id::create("dev_d2h_rsp_driver_h", this);
      end
      dev_d2h_rsp_monitor_h = dev_d2h_rsp_monitor::type_id::create("dev_d2h_rsp_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_rsp_driver_h.seq_item_port.connect(dev_d2h_rsp_sequencer_h.seq_item_export);
        dev_d2h_rsp_monitor_h.d2h_rsp_port.connect(dev_d2h_rsp_sequencer_h.dev_d2h_rsp_fifo.analysis_export);
      end
    endfunction

  endclass

  class dev_d2h_data_agent extends uvm_agent;
    `uvm_component_utils(dev_d2h_data_agent)
    dev_d2h_data_driver dev_d2h_data_driver_h;
    dev_d2h_data_monitor dev_d2h_data_monitor_h;
    dev_d2h_data_sequencer dev_d2h_data_sequencer_h;

    function new(string name = "dev_d2h_data_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_data_sequencer_h = dev_d2h_data_sequencer::type_id::create("dev_d2h_data_sequencer_h", this);
        dev_d2h_data_driver_h = dev_d2h_data_driver::type_id::create("dev_d2h_data_driver_h", this);
      end
      dev_d2h_data_monitor_h = dev_d2h_data_monitor::type_id::create("dev_d2h_data_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_data_driver_h.seq_item_port.connect(dev_d2h_data_sequencer_h.seq_item_export);
        dev_d2h_data_monitor_h.d2h_data_port.connect(dev_d2h_data_sequencer_h.dev_d2h_data_fifo.analysis_export);
      end
    endfunction

  endclass

  class host_h2d_req_agent extends uvm_agent;
    `uvm_component_utils(host_h2d_req_agent)
    host_h2d_req_driver host_h2d_req_driver_h;
    host_h2d_req_monitor host_h2d_req_monitor_h;
    host_h2d_req_sequencer host_h2d_req_sequencer_h;

    function new(string name = "host_h2d_req_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_h2d_req_sequencer_h = host_h2d_req_sequencer::type_id::create("host_h2d_req_sequencer_h", this);
        host_h2d_req_driver_h = host_h2d_req_driver::type_id::create("host_h2d_req_driver_h", this);
      end
      host_h2d_req_monitor_h = host_h2d_req_monitor::type_id::create("host_h2d_req_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_h2d_req_driver_h.seq_item_port.connect(host_h2d_req_sequencer_h.seq_item_export);
        host_h2d_req_monitor_h.h2d_req_port.connect(host_h2d_req_sequencer_h.host_h2d_req_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class host_h2d_rsp_agent extends uvm_agent;
    `uvm_component_utils(host_h2d_rsp_agent)
    host_h2d_rsp_driver host_h2d_rsp_driver_h;
    host_h2d_rsp_monitor host_h2d_rsp_monitor_h;
    host_h2d_rsp_sequencer host_h2d_rsp_sequencer_h;

    function new(string name = "host_h2d_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_h2d_rsp_sequencer_h = host_h2d_rsp_sequencer::type_id::create("host_h2d_rsp_sequencer_h", this);
        host_h2d_rsp_driver_h = host_h2d_rsp_driver::type_id::create("host_h2d_rsp_driver_h", this);
      end
      host_h2d_rsp_monitor_h = host_h2d_rsp_monitor::type_id::create("host_h2d_rsp_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_h2d_rsp_driver_h.seq_item_port.connect(host_h2d_rsp_sequencer_h.seq_item_export);
        host_h2d_rsp_monitor_h.h2d_rsp_port.connect(host_h2d_rsp_sequencer_h.host_h2d_rsp_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class host_h2d_data_agent extends uvm_agent;
    `uvm_component_utils(host_h2d_data_agent)
    host_h2d_data_driver host_h2d_data_driver_h;
    host_h2d_data_monitor host_h2d_data_monitor_h;
    host_h2d_data_sequencer host_h2d_data_sequencer_h;

    function new(string name = "host_h2d_data_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_h2d_data_sequencer_h = host_h2d_data_sequencer::type_id::create("host_h2d_data_sequencer_h", this);
        host_h2d_data_driver_h = host_h2d_data_driver::type_id::create("host_h2d_data_driver_h", this);
      end
      host_h2d_data_monitor_h = host_h2d_data_monitor::type_id::create("host_h2d_data_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_h2d_data_driver_h.seq_item_port.connect(host_h2d_data_sequencer_h.seq_item_export);
        host_h2d_data_monitor_h.h2d_data_port.connect(host_h2d_data_sequencer_h.host_h2d_data_fifo.analysis_export);
      end
    endfunction

  endclass
 
  class host_m2s_req_agent extends uvm_agent;
    `uvm_component_utils(host_m2s_req_agent)
    host_m2s_req_driver host_m2s_req_driver_h;
    host_m2s_req_monitor host_m2s_req_monitor_h;
    host_m2s_req_sequencer host_m2s_req_sequencer_h;

    function new(string name = "host_m2s_req_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_m2s_req_sequencer_h = host_m2s_req_sequencer::type_id::create("host_m2s_req_sequencer_h", this);
        host_m2s_req_driver_h = host_m2s_req_driver::type_id::create("host_m2s_req_driver_h", this);
      end
      host_m2s_req_monitor_h = host_m2s_req_monitor::type_id::create("host_m2s_req_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_m2s_req_driver_h.seq_item_port.connect(host_m2s_req_sequencer_h.seq_item_export);
        host_m2s_req_monitor_h.m2s_req_port.connect(host_m2s_req_sequencer_h.host_m2s_req_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class host_m2s_rwd_agent extends uvm_agent;
    `uvm_component_utils(host_m2s_rwd_agent)
    host_m2s_rwd_driver host_m2s_rwd_driver_h;
    host_m2s_rwd_monitor host_m2s_rwd_monitor_h;
    host_m2s_rwd_sequencer host_m2s_rwd_sequencer_h;

    function new(string name = "host_m2s_rwd_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_m2s_rwd_sequencer_h = host_m2s_rwd_sequencer::type_id::create("host_m2s_rwd_sequencer_h", this);
        host_m2s_rwd_driver_h = host_m2s_rwd_driver::type_id::create("host_m2s_rwd_driver_h", this);
      end
      host_m2s_rwd_monitor_h = host_m2s_rwd_monitor::type_id::create("host_m2s_rwd_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_m2s_rwd_driver_h.seq_item_port.connect(host_m2s_rwd_sequencer_h.seq_item_export);
        host_m2s_rwd_monitor_h.m2s_rwd_port.connect(host_m2s_rwd_sequencer_h.host_m2s_rwd_fifo.analysis_export);
      end
    endfunction

  endclass

  class dev_s2m_ndr_agent extends uvm_agent;
    `uvm_component_utils(dev_s2m_ndr_agent)
    dev_s2m_ndr_driver dev_s2m_ndr_driver_h;
    dev_s2m_ndr_monitor dev_s2m_ndr_monitor_h;
    dev_s2m_ndr_sequencer dev_s2m_ndr_sequencer_h;

    function new(string name = "dev_s2m_ndr_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_s2m_ndr_sequencer_h = dev_s2m_ndr_sequencer::type_id::create("dev_s2m_ndr_sequencer_h", this);
        dev_s2m_ndr_driver_h = dev_s2m_ndr_driver::type_id::create("dev_s2m_ndr_driver_h", this);
      end
      dev_s2m_ndr_monitor_h = dev_s2m_ndr_monitor::type_id::create("dev_s2m_ndr_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_s2m_ndr_driver_h.seq_item_port.connect(dev_s2m_ndr_sequencer_h.seq_item_export);
        dev_s2m_ndr_monitor_h.s2m_ndr_port.connect(dev_s2m_ndr_sequencer_h.dev_s2m_ndr_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class dev_s2m_drs_agent extends uvm_agent;
    `uvm_component_utils(dev_s2m_drs_agent)
    dev_s2m_drs_driver dev_s2m_drs_driver_h;
    dev_s2m_drs_monitor dev_s2m_drs_monitor_h;
    dev_s2m_drs_sequencer dev_s2m_drs_sequencer_h;

    function new(string name = "dev_s2m_drs_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_s2m_drs_sequencer_h = dev_s2m_drs_sequencer::type_id::create("dev_s2m_drs_sequencer_h", this);
        dev_s2m_drs_driver_h = dev_s2m_drs_driver::type_id::create("dev_s2m_drs_driver_h", this);
      end
      dev_s2m_drs_monitor_h = dev_s2m_drs_monitor::type_id::create("dev_s2m_drs_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_s2m_drs_driver_h.seq_item_port.connect(dev_s2m_drs_sequencer_h.seq_item_export);
        dev_s2m_drs_monitor_h.s2m_drs_port.connect(dev_s2m_drs_sequencer_h.dev_s2m_drs_fifo.analysis_export);
      end
    endfunction

  endclass

  class host_d2h_req_agent extends uvm_agent;
    `uvm_component_utils(host_d2h_req_agent)
    host_d2h_req_driver host_d2h_req_driver_h;
    host_d2h_req_monitor host_d2h_req_monitor_h;
    host_d2h_req_sequencer host_d2h_req_sequencer_h;

    function new(string name = "host_d2h_req_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_d2h_req_sequencer_h = host_d2h_req_sequencer::type_id::create("host_d2h_req_sequencer_h", this);
        host_d2h_req_driver_h = host_d2h_req_driver::type_id::create("host_d2h_req_driver_h", this);
      end
      host_d2h_req_monitor_h = host_d2h_req_monitor::type_id::create("host_d2h_req_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_d2h_req_driver_h.seq_item_port.connect(host_d2h_req_sequencer_h.seq_item_export);
        host_d2h_req_monitor_h.d2h_req_port.connect(host_d2h_req_sequencer_h.host_d2h_req_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class host_d2h_rsp_agent extends uvm_agent;
    `uvm_component_utils(host_d2h_rsp_agent)
    host_d2h_rsp_driver host_d2h_rsp_driver_h;
    host_d2h_rsp_monitor host_d2h_rsp_monitor_h;
    host_d2h_rsp_sequencer host_d2h_rsp_sequencer_h;

    function new(string name = "host_d2h_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_d2h_rsp_sequencer_h = host_d2h_rsp_sequencer::type_id::create("host_d2h_rsp_sequencer_h", this);
        host_d2h_rsp_driver_h = host_d2h_rsp_driver::type_id::create("host_d2h_rsp_driver_h", this);
      end
      host_d2h_rsp_monitor_h = host_d2h_rsp_monitor::type_id::create("host_d2h_rsp_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_d2h_rsp_driver_h.seq_item_port.connect(d2h_rsp_sequencer_h.seq_item_export);
        host_d2h_rsp_monitor_h.d2h_rsp_port.connect(host_d2h_rsp_sequencer_h.host_d2h_rsp_fifo.analysis_export);
      end
    endfunction

  endclass

  class host_d2h_data_agent extends uvm_agent;
    `uvm_component_utils(host_d2h_data_agent)
    host_d2h_data_driver host_d2h_data_driver_h;
    host_d2h_data_monitor host_d2h_data_monitor_h;
    host_d2h_data_sequencer host_d2h_data_sequencer_h;

    function new(string name = "host_d2h_data_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_d2h_data_sequencer_h = host_d2h_data_sequencer::type_id::create("host_d2h_data_sequencer_h", this);
        host_d2h_data_driver_h = host_d2h_data_driver::type_id::create("host_d2h_data_driver_h", this);
      end
      host_d2h_data_monitor_h = host_d2h_data_monitor::type_id::create("host_d2h_data_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_d2h_data_driver_h.seq_item_port.connect(host_d2h_data_sequencer_h.seq_item_export);
        host_d2h_data_monitor_h.d2h_data_port.connect(host_d2h_data_sequencer_h.host_d2h_data_fifo.analysis_export);
      end
    endfunction

  endclass

  class dev_h2d_req_agent extends uvm_agent;
    `uvm_component_utils(dev_h2d_req_agent)
    dev_h2d_req_driver dev_h2d_req_driver_h;
    dev_h2d_req_monitor dev_h2d_req_monitor_h;
    dev_h2d_req_sequencer dev_h2d_req_sequencer_h;

    function new(string name = "dev_h2d_req_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_req_sequencer_h = dev_h2d_req_sequencer::type_id::create("dev_h2d_req_sequencer_h", this);
        dev_h2d_req_driver_h = dev_h2d_req_driver::type_id::create("dev_h2d_req_driver_h", this);
      end
      dev_h2d_req_monitor_h = dev_h2d_req_monitor::type_id::create("dev_h2d_req_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_req_driver_h.seq_item_port.connect(h2d_req_sequencer_h.seq_item_export);
        dev_h2d_req_monitor_h.h2d_req_port.connect(dev_h2d_req_sequencer_h.dev_h2d_req_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class dev_h2d_rsp_agent extends uvm_agent;
    `uvm_component_utils(dev_h2d_rsp_agent)
    host_h2d_rsp_driver dev_h2d_rsp_driver_h;
    host_h2d_rsp_monitor dev_h2d_rsp_monitor_h;
    dev_h2d_rsp_sequencer dev_h2d_rsp_sequencer_h;

    function new(string name = "dev_h2d_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_rsp_sequencer_h = dev_h2d_rsp_sequencer::type_id::create("dev_h2d_rsp_sequencer_h", this);
        dev_h2d_rsp_driver_h = dev_h2d_rsp_driver::type_id::create("dev_h2d_rsp_driver_h", this);
      end
      dev_h2d_rsp_monitor_h = dev_h2d_rsp_monitor::type_id::create("dev_h2d_rsp_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_rsp_driver_h.seq_item_port.connect(dev_h2d_rsp_sequencer_h.seq_item_export);
        dev_h2d_rsp_monitor_h.h2d_rsp_port.connect(dev_h2d_rsp_sequencer_h.dev_h2d_rsp_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class dev_h2d_data_agent extends uvm_agent;
    `uvm_component_utils(host_h2d_data_agent)
    dev_h2d_data_driver dev_h2d_data_driver_h;
    dev_h2d_data_monitor dev_h2d_data_monitor_h;
    dev_h2d_data_sequencer dev_h2d_data_sequencer_h;

    function new(string name = "dev_h2d_data_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_data_sequencer_h = dev_h2d_data_sequencer::type_id::create("dev_h2d_data_sequencer_h", this);
        dev_h2d_data_driver_h = dev_h2d_data_driver::type_id::create("dev_h2d_data_driver_h", this);
      end
      dev_h2d_data_monitor_h = dev_h2d_data_monitor::type_id::create("dev_h2d_data_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_data_driver_h.seq_item_port.connect(dev_h2d_data_sequencer_h.seq_item_export);
        dev_h2d_data_monitor_h.h2d_data_port.connect(dev_h2d_data_sequencer_h.dev_h2d_data_fifo.analysis_export);
      end
    endfunction

  endclass
 
  class dev_m2s_req_agent extends uvm_agent;
    `uvm_component_utils(dev_m2s_req_agent)
    dev_m2s_req_driver dev_m2s_req_driver_h;
    dev_m2s_req_monitor dev_m2s_req_monitor_h;
    dev_m2s_req_sequencer dev_m2s_req_sequencer_h;

    function new(string name = "dev_m2s_req_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_m2s_req_sequencer_h = dev_m2s_req_sequencer::type_id::create("dev_m2s_req_sequencer_h", this);
        dev_m2s_req_driver_h = dev_m2s_req_driver::type_id::create("dev_m2s_req_driver_h", this);
      end
      dev_m2s_req_monitor_h = dev_m2s_req_monitor::type_id::create("dev_m2s_req_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_m2s_req_driver_h.seq_item_port.connect(dev_m2s_req_sequencer_h.seq_item_export);
        dev_m2s_req_monitor_h.m2s_req_port.connect(dev_m2s_req_sequencer_h.dev_m2s_req_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class dev_m2s_rwd_agent extends uvm_agent;
    `uvm_component_utils(dev_m2s_rwd_agent)
    dev_m2s_rwd_driver dev_m2s_rwd_driver_h;
    dev_m2s_rwd_monitor dev_m2s_rwd_monitor_h;
    dev_m2s_rwd_sequencer dev_m2s_rwd_sequencer_h;

    function new(string name = "dev_m2s_rwd_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_m2s_rwd_sequencer_h = dev_m2s_rwd_sequencer::type_id::create("dev_m2s_rwd_sequencer_h", this);
        dev_m2s_rwd_driver_h = dev_m2s_rwd_driver::type_id::create("dev_m2s_rwd_driver_h", this);
      end
      dev_m2s_rwd_monitor_h = dev_m2s_rwd_monitor::type_id::create("dev_m2s_rwd_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        dev_m2s_rwd_driver_h.seq_item_port.connect(dev_m2s_rwd_sequencer_h.seq_item_export);
        dev_m2s_rwd_monitor_h.m2s_rwd_port.connect(dev_m2s_rwd_sequencer_h.dev_m2s_rwd_fifo.analysis_export);
      end
    endfunction

  endclass

  class host_s2m_ndr_agent extends uvm_agent;
    `uvm_component_utils(host_s2m_ndr_agent)
    host_s2m_ndr_driver host_s2m_ndr_driver_h;
    host_s2m_ndr_monitor host_s2m_ndr_monitor_h;
    host_s2m_ndr_sequencer host_s2m_ndr_sequencer_h;

    function new(string name = "host_s2m_ndr_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_s2m_ndr_sequencer_h = host_s2m_ndr_sequencer::type_id::create("host_s2m_ndr_sequencer_h", this);
        host_s2m_ndr_driver_h = host_s2m_ndr_driver::type_id::create("host_s2m_ndr_driver_h", this);
      end
      host_s2m_ndr_monitor_h = host_s2m_ndr_monitor::type_id::create("host_s2m_ndr_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_s2m_ndr_driver_h.seq_item_port.connect(host_s2m_ndr_sequencer_h.seq_item_export);
        host_s2m_ndr_monitor_h.s2m_ndr_port.connect(host_s2m_ndr_sequencer_h.host_s2m_ndr_fifo.analysis_export);
      end
    endfunction

  endclass
  
  class host_s2m_drs_agent extends uvm_agent;
    `uvm_component_utils(host_s2m_drs_agent)
    host_s2m_drs_driver host_s2m_drs_driver_h;
    host_s2m_drs_monitor host_s2m_drs_monitor_h;
    host_s2m_drs_sequencer host_s2m_drs_sequencer_h;

    function new(string name = "host_s2m_drs_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_s2m_drs_sequencer_h = host_s2m_drs_sequencer::type_id::create("host_s2m_drs_sequencer_h", this);
        host_s2m_drs_driver_h = host_s2m_drs_driver::type_id::create("host_s2m_drs_driver_h", this);
      end
      host_s2m_drs_monitor_h = host_s2m_drs_monitor::type_id::create("host_s2m_drs_monitor_h", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(is_active == UVM_ACTIVE) begin
        host_s2m_drs_driver_h.seq_item_port.connect(host_s2m_drs_sequencer_h.seq_item_export);
        host_s2m_drs_monitor_h.s2m_drs_port.connect(host_s2m_drs_sequencer_h.host_s2m_drs_fifo.analysis_export);
      end
    endfunction

  endclass

  class cxl_cm_vsequencer extends uvm_sequencer;
    `uvm_component_utils(cxl_cm_vsequencer)
    host_d2h_req_sequencer      host_d2h_req_seqr;
    host_d2h_rsp_sequencer      host_d2h_rsp_seqr;
    host_d2h_data_sequencer     host_d2h_data_seqr;
    host_h2d_req_sequencer      host_h2d_req_seqr;
    host_h2d_rsp_sequencer      host_h2d_rsp_seqr;
    host_h2d_data_sequencer     host_h2d_data_seqr;
    host_m2s_req_sequencer      host_m2s_req_seqr;
    host_m2s_rsp_sequencer      host_m2s_rsp_seqr;
    host_s2m_ndr_sequencer      host_s2m_ndr_seqr;
    host_s2m_drs_sequencer      host_s2m_drs_seqr;
    dev_d2h_req_sequencer       dev_d2h_req_seqr;
    dev_d2h_rsp_sequencer       dev_d2h_rsp_seqr;
    dev_d2h_data_sequencer      dev_d2h_data_seqr;
    dev_h2d_req_sequencer       dev_h2d_req_seqr;
    dev_h2d_rsp_sequencer       dev_h2d_rsp_seqr;
    dev_h2d_data_sequencer      dev_h2d_data_seqr;
    dev_m2s_req_sequencer       dev_m2s_req_seqr;
    dev_m2s_rsp_sequencer       dev_m2s_rsp_seqr;
    dev_s2m_ndr_sequencer       dev_s2m_ndr_seqr;
    dev_s2m_drs_sequencer       dev_s2m_drs_seqr;

    function new(string name = "cxl_cm_vsequencer", uvm_component = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      dev_d2h_req_seqr    = dev_d2h_req_sequencer::type_id::create("dev_d2h_req_seqr", this);
      dev_d2h_rsp_seqr    = dev_d2h_rsp_sequencer::type_id::create("dev_d2h_rsp_seqr", this);
      dev_d2h_data_seqr   = dev_d2h_data_sequencer::type_id::create("dev_d2h_data_seqr", this);
      dev_h2d_req_seqr    = dev_h2d_req_sequencer::type_id::create("dev_h2d_req_seqr", this);
      dev_h2d_rsp_seqr    = dev_h2d_rsp_sequencer::type_id::create("dev_h2d_rsp_seqr", this);
      dev_h2d_data_seqr   = dev_h2d_data_sequencer::type_id::create("dev_h2d_data_seqr", this);
      dev_m2s_req_seqr    = dev_m2s_req_sequencer::type_id::create("dev_m2s_req_seqr", this);
      dev_m2s_rwd_seqr    = dev_m2s_rwd_sequencer::type_id::create("dev_m2s_rwd_seqr", this);
      dev_s2m_ndr_seqr    = dev_s2m_ndr_sequencer::type_id::create("dev_s2m_ndr_seqr", this);
      dev_s2m_drs_seqr    = dev_s2m_drs_sequencer::type_id::create("dev_s2m_drs_seqr", this);
      host_d2h_req_seqr   = host_d2h_req_sequencer::type_id::create("host_d2h_req_seqr", this);
      host_d2h_rsp_seqr   = host_d2h_rsp_sequencer::type_id::create("host_d2h_rsp_seqr", this);
      host_d2h_data_seqr  = host_d2h_data_sequencer::type_id::create("host_d2h_data_seqr", this);
      host_h2d_req_seqr   = host_h2d_req_sequencer::type_id::create("host_h2d_req_seqr", this);
      host_h2d_rsp_seqr   = host_h2d_rsp_sequencer::type_id::create("host_h2d_rsp_seqr", this);
      host_h2d_data_seqr  = host_h2d_data_sequencer::type_id::create("host_h2d_data_seqr", this);
      host_m2s_req_seqr   = host_m2s_req_sequencer::type_id::create("host_m2s_req_seqr", this);
      host_m2s_rwd_seqr   = host_m2s_rwd_sequencer::type_id::create("host_m2s_rwd_seqr", this);
      host_s2m_ndr_seqr   = host_s2m_ndr_sequencer::type_id::create("host_s2m_ndr_seqr", this);
      host_s2m_drs_seqr   = host_s2m_drs_sequencer::type_id::create("host_s2m_drs_seqr", this);
    endfunction

  endclass

  class cxl_cm_env extends uvm_env;
    `uvm_component_utils(cxl_cm_env)
    dev_d2h_req_agent       dev_d2h_req_agent_h;
    dev_d2h_rsp_agent       dev_d2h_rsp_agent_h;
    dev_d2h_data_agent      dev_d2h_data_agent_h;
    host_h2d_req_agent      host_h2d_req_agent_h;
    host_h2d_rsp_agent      host_h2d_rsp_agent_h;
    host_h2d_data_agent     host_h2d_data_agent_h;
    host_m2s_req_agent      host_m2s_req_agent_h;
    host_m2s_rwd_agent      host_m2s_rwd_agent_h;
    dev_s2m_ndr_agent       dev_s2m_ndr_agent_h;
    dev_s2m_drs_agent       dev_s2m_drs_agent_h;
    host_d2h_req_agent      host_d2h_req_agent_h;
    host_d2h_rsp_agent      host_d2h_rsp_agent_h;
    host_d2h_data_agent     host_d2h_data_agent_h;
    dev_h2d_req_agent       dev_h2d_req_agent_h;
    dev_h2d_rsp_agent       dev_h2d_rsp_agent_h;
    dev_h2d_data_agent      dev_h2d_data_agent_h;
    dev_m2s_req_agent       dev_m2s_req_agent_h;
    dev_m2s_rwd_agent       dev_m2s_rwd_agent_h;
    host_s2m_ndr_agent      host_s2m_ndr_agent_h;
    host_s2m_drs_agent      host_s2m_drs_agent_h;
    cxl_cm_vsequencer       cxl_cm_vseqr;

    function new(string name = "cxl_cm_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      host_d2h_req_agent_h  = host_d2h_req_agent::type_id::create("host_d2h_req_agent_h", this);
      host_d2h_rsp_agent_h  = host_d2h_rsp_agent::type_id::create("host_d2h_rsp_agent_h", this);
      host_d2h_data_agent_h = host_d2h_data_agent::type_id::create("host_d2h_data_agent_h", this);
      dev_h2d_req_agent_h   = dev_h2d_req_agent::type_id::create("dev_h2d_req_agent_h", this);
      dev_h2d_rsp_agent_h   = dev_h2d_rsp_agent::type_id::create("dev_h2d_rsp_agent_h", this);
      dev_h2d_data_agent_h  = dev_h2d_data_agent::type_id::create("dev_h2d_data_agent_h", this);
      dev_m2s_req_agent_h   = dev_m2s_req_agent::type_id::create("dev_m2s_req_agent_h", this);
      dev_m2s_rwd_agent_h   = dev_m2s_rwd_agent::type_id::create("dev_m2s_rwd_agent_h", this);
      host_s2m_ndr_agent_h  = host_s2m_ndr_agent::type_id::create("host_s2m_ndr_agent_h", this);
      host_s2m_drs_agent_h  = host_s2m_drs_agent::type_id::create("host_s2m_drs_agent_h", this);
      dev_d2h_req_agent_h   = dev_d2h_req_agent::type_id::create("dev_d2h_req_agent_h", this);
      dev_d2h_rsp_agent_h   = dev_d2h_rsp_agent::type_id::create("dev_d2h_rsp_agent_h", this);
      dev_d2h_data_agent_h  = dev_d2h_data_agent::type_id::create("dev_d2h_data_agent_h", this);
      host_h2d_req_agent_h  = host_h2d_req_agent::type_id::create("host_h2d_req_agent_h", this);
      host_h2d_rsp_agent_h  = host_h2d_rsp_agent::type_id::create("host_h2d_rsp_agent_h", this);
      host_h2d_data_agent_h = host_h2d_data_agent::type_id::create("host_h2d_data_agent_h", this);
      host_m2s_req_agent_h  = host_m2s_req_agent::type_id::create("host_m2s_req_agent_h", this);
      host_m2s_rwd_agent_h  = host_m2s_rwd_agent::type_id::create("host_m2s_rwd_agent_h", this);
      dev_s2m_ndr_agent_h   = dev_s2m_ndr_agent::type_id::create("dev_s2m_ndr_agent_h", this);
      dev_s2m_drs_agent_h   = dev_s2m_drs_agent::type_id::create("dev_s2m_drs_agent_h", this);
      cxl_cm_vseqr          = cxl_cm_vsequencer::type_id::create("cxl_cm_vseqr", this);
    endfunction 

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(dev_d2h_req_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_d2h_req_seqr   = dev_d2h_req_agent_h.dev_d2h_req_sequencer_h;
      end
      if(dev_d2h_rsp_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_d2h_rsp_seqr   = dev_d2h_rsp_agent_h.d2h_rsp_sequencer_h;
      end
      if(dev_d2h_data_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_d2h_data_seqr  = dev_d2h_data_agent_h.d2h_data_sequencer_h;
      end
      if(host_h2d_req_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_h2d_req_seqr   = host_h2d_req_agent_h.h2d_req_sequencer_h;
      end
      if(host_h2d_rsp_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_h2d_rsp_seqr   = host_h2d_rsp_agent_h.h2d_rsp_sequencer_h;
      end
      if(host_h2d_data_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_h2d_data_seqr  = host_h2d_data_agent_h.h2d_data_sequencer_h;
      end
      if(host_m2s_req_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_m2s_req_seqr   = host_m2s_req_agent_h.m2s_req_sequencer_h;
      end
      if(host_m2s_rwd_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_m2s_rwd_seqr   = host_m2s_rwd_agent_h.m2s_rwd_sequencer_h;
      end
      if(dev_s2m_ndr_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_s2m_ndr_seqr   = dev_s2m_ndr_agent_h.s2m_ndr_sequencer_h;
      end
      if(dev_s2m_drs_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_s2m_drs_seqr   = dev_s2m_drs_agent_h.s2m_drs_sequencer_h;
      end
      if(host_d2h_req_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_d2h_req_seqr   = host_d2h_req_agent_h.d2h_req_sequencer_h;
      end
      if(host_d2h_rsp_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr._host_d2h_rsp_seqr   = host_d2h_rsp_agent_h.d2h_rsp_sequencer_h;
      end
      if(host_d2h_data_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_d2h_data_seqr  = host_d2h_data_agent_h.d2h_data_sequencer_h;
      end
      if(dev_h2d_req_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_h2d_req_seqr   = dev_h2d_req_agent_h.h2d_req_sequencer_h;
      end
      if(dev_h2d_rsp_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_h2d_rsp_seqr   = dev_h2d_rsp_agent_h.h2d_rsp_sequencer_h;
      end
      if(dev_h2d_data_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_h2d_data_seqr  = dev_h2d_data_agent_h.h2d_data_sequencer_h;
      end
      if(dev_m2s_req_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_m2s_req_seqr   = dev_m2s_req_agent_h.m2s_req_sequencer_h;
      end
      if(dev_m2s_rwd_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.dev_m2s_rwd_seqr   = dev_m2s_rwd_agent_h.m2s_rwd_sequencer_h;
      end
      if(host_s2m_ndr_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_s2m_ndr_seqr   = host_s2m_ndr_agent_h.s2m_ndr_sequencer_h;
      end
      if(host_s2m_drs_agent_h.is_active == UVM_ACTIVE) begin
        cxl_cm_vseqr.host_s2m_drs_seqr   = host_s2m_drs_agent_h.s2m_drs_sequencer_h;
      end
    endfunction

  endclass

  class cxl_base_txn_seq extends uvm_sequence;
    `uvm_object_utils(cxl_base_txn_seq)
    rand num_trans;
    rand cxl_base_txn_seq_item cxl_base_txn_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      cxl_base_txn_seq_item.size == num_trans;
      solve num_trans before cxl_base_txn_seq_item_h;
    }

    function new(string name = "cxl_base_txn_seq");
      super.new(name);
    endfunction

    task body();
      foreach(cxl_base_txn_seq_item_h[i]) begin
        `uvm_do(cxl_base_txn_seq_item_h[i]);
      end 
    endtask

  endclass

  class dev_d2h_req_seq extends uvm_sequence;
    `uvm_object_utils(dev_d2h_req_seq)
    rand int num_trans;
    rand d2h_req_seq_item d2h_req_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      d2h_req_seq_item_h.size == num_trans;
      solve num_trans before d2h_req_seq_item_h;
    }

    function new(string name = "dev_d2h_req_seq");
      super.new(name);
    endfunction

    task body();
      foreach(d2h_req_seq_item_h[i]) begin
        `uvm_do(d2h_req_seq_item_h[i]);
      end
    endtask

  endclass

  class dev_d2h_rsp_seq extends uvm_sequence;
    `uvm_object_utils(dev_d2h_rsp_seq)
    rand int num_trans;
    rand d2h_rsp_seq_item d2h_rsp_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      d2h_rsp_seq_item_h.size == num_trans;
      solve num_trans before d2h_rsp_seq_item_h;
    }

    function new(string name = "dev_d2h_rsp_seq");
      super.new(name);
    endfunction

    task body();
      foreach(d2h_rsp_seq_item_h[i]) begin
        `uvm_do(d2h_rsp_seq_item_h[i]);
      end
    endtask

  endclass

  class dev_d2h_data_seq extends uvm_sequence;
    `uvm_object_utils(dev_d2h_data_seq)
    rand int num_trans;
    rand d2h_data_seq_item d2h_data_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      d2h_data_seq_item_h.size == num_trans;
      solve num_trans before d2h_data_seq_item_h;
    }

    function new(string name = "dev_d2h_data_seq");
      super.new(name);
    endfunction

    task body();
      foreach(d2h_data_seq_item_h[i]) begin
        `uvm_do(d2h_data_seq_item_h[i]);
      end
    endtask

  endclass

  class host_h2d_req_seq extends uvm_sequence;
    `uvm_object_utils(host_h2d_req_seq)
    rand int num_trans;
    rand h2d_req_seq_item h2d_req_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      h2d_req_seq_item_h.size == num_trans;
      solve num_trans before h2d_req_seq_item_h;
    }

    function new(string name = "host_h2d_req_seq");
      super.new(name);
    endfunction

    task body();
      foreach(h2d_req_seq_item_h[i]) begin
        `uvm_do(h2d_req_seq_item_h[i]);
      end
    endtask

  endclass

  class host_h2d_rsp_seq extends uvm_sequence;
    `uvm_object_utils(host_h2d_rsp_seq)
    rand int num_trans;
    rand h2d_rsp_seq_item h2d_rsp_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      h2d_rsp_seq_item_h.size == num_trans;
      solve num_trans before h2d_rsp_seq_item_h;
    }

    function new(string name = "host_h2d_rsp_seq");
      super.new(name);
    endfunction

    task body();
      foreach(h2d_rsp_seq_item_h[i]) begin
        `uvm_do(h2d_rsp_seq_item_h[i]);
      end
    endtask

  endclass

  class host_h2d_data_seq extends uvm_sequence;
    `uvm_object_utils(host_h2d_data_seq)
    rand int num_trans;
    rand h2d_data_seq_item h2d_data_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      h2d_data_seq_item_h.size == num_trans;
      solve num_trans before h2d_data_seq_item_h;
    }

    function new(string name = "host_h2d_data_seq");
      super.new(name);
    endfunction

    task body();
      foreach(h2d_data_seq_item_h[i]) begin
        `uvm_do(h2d_data_seq_item_h[i]);
      end
    endtask

  endclass

  class host_m2s_req_seq extends uvm_sequence;
    `uvm_object_utils(host_m2s_req_seq)
    rand int num_trans;
    rand m2s_req_seq_item m2s_req_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      m2s_req_seq_item_h.size == num_trans;
      solve num_trans before m2s_req_seq_item_h;
    }

    function new(string name = "host_m2s_req_seq");
      super.new(name);
    endfunction

    task body();
      foreach(m2s_req_seq_item_h[i]) begin
        `uvm_do(m2s_req_seq_item_h[i]);
      end
    endtask

  endclass

  class host_m2s_rwd_seq extends uvm_sequence;
    `uvm_object_utils(host_m2s_rwd_seq)
    rand int num_trans;
    rand m2s_rwd_seq_item m2s_rwd_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      m2s_rwd_seq_item_h.size == num_trans;
      solve num_trans before m2s_rwd_seq_item_h;
    }

    function new(string name = "host_m2s_rwd_seq");
      super.new(name);
    endfunction

    task body();
      foreach(m2s_rwd_seq_item_h[i]) begin
        `uvm_do(m2s_rwd_seq_item_h[i]);
      end
    endtask

  endclass

  class dev_s2m_ndr_seq extends uvm_sequence;
    `uvm_object_utils(dev_s2m_ndr_seq)
    rand int num_trans;
    rand s2m_ndr_seq_item s2m_ndr_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      s2m_ndr_seq_item_h.size == num_trans;
      solve num_trans before s2m_ndr_seq_item_h;
    }

    function new(string name = "dev_s2m_ndr_seq");
      super.new(name);
    endfunction

    task body();
      foreach(s2m_ndr_seq_item_h[i]) begin
        `uvm_do(s2m_ndr_seq_item_h[i]);
      end
    endtask

  endclass

  class dev_s2m_drs_seq extends uvm_sequence;
    `uvm_object_utils(dev_s2m_drs_seq)
    rand int num_trans;
    rand s2m_drs_seq_item s2m_drs_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      s2m_drs_seq_item_h.size == num_trans;
      solve num_trans before s2m_drs_seq_item_h;
    }

    function new(string name = "dev_s2m_drs_seq");
      super.new(name);
    endfunction

    task body();
      foreach(s2m_drs_seq_item_h[i]) begin
        `uvm_do(s2m_drs_seq_item_h[i]);
      end
    endtask

  endclass

  class cxl_vseq extends uvm_sequence;
    `uvm_object_utils(cxl_vseq)
    `uvm_declare_p_sequencer(cxl_cm_vsequencer)
    dev_d2h_req_seq   dev_d2h_req_seq_h;
    dev_d2h_rsp_seq   dev_d2h_rsp_seq_h;
    dev_d2h_data_seq  dev_d2h_data_seq_h;
    host_h2d_req_seq  host_h2d_req_seq_h;
    host_h2d_rsp_seq  host_h2d_rsp_seq_h;
    host_h2d_data_seq host_h2d_data_seq_h;
    host_m2s_req_seq  host_m2s_req_seq_h;
    host_m2s_rwd_seq  host_m2s_rwd_seq_h;
    dev_s2m_ndr_seq   dev_s2m_ndr_seq_h;
    dev_s2m_drs_seq   dev_s2m_drs_seq_h;
    cxl_base_txn_seq  host_d2h_req_txn_seq_h;
    cxl_base_txn_seq  host_d2h_rsp_txn_seq_h;
    cxl_base_txn_seq  host_d2h_data_txn_seq_h;
    cxl_base_txn_seq  dev_h2d_req_txn_seq_h;
    cxl_base_txn_seq  dev_h2d_rsp_txn_seq_h;
    cxl_base_txn_seq  dev_h2d_data_txn_seq_h;
    cxl_base_txn_seq  dev_m2s_req_txn_seq_h;
    cxl_base_txn_seq  dev_m2s_rwd_txn_seq_h;
    cxl_base_txn_seq  dev_s2m_ndr_txn_seq_h;
    cxl_base_txn_seq  dev_s2m_drs_txn_seq_h;

    function new(string name = "cxl_vseq");
      super.new(name);
    endfunction

    task body();
      fork 
        begin
          `uvm_do_on(dev_d2h_req_seq_h, p_sequencer.dev_d2h_req_seqr);
        end
        begin
          `uvm_do_on(dev_d2h_rsp_seq_h, p_sequencer.dev_d2h_rsp_seqr);
        end
        begin
          `uvm_do_on(dev_d2h_data_seq_h, p_sequencer.dev_d2h_data_seqr);
        end
        begin
          `uvm_do_on(host_h2d_req_seq_h, p_sequencer.host_h2d_req_seqr);
        end
        begin
          `uvm_do_on(host_h2d_rsp_seq_h, p_sequencer.host_h2d_rsp_seqr);
        end
        begin
          `uvm_do_on(host_h2d_data_seq_h, p_sequencer.host_h2d_data_seqr);
        end
        begin
          `uvm_do_on(host_m2s_req_seq_h, p_sequencer.host_m2s_req_seqr);
        end
        begin
          `uvm_do_on(host_m2s_rwd_seq_h, p_sequencer.host_m2s_rwd_seqr);
        end
        begin
          `uvm_do_on(dev_s2m_ndr_seq_h, p_sequencer.dev_s2m_ndr_seqr);
        end
        begin
          `uvm_do_on(dev_s2m_drs_seq_h, p_sequencer.dev_s2m_drs_seqr);
        end
        begin
          `uvm_do_on(host_d2h_req_seq_h, p_sequencer.host_d2h_req_seqr);
        end
        begin
          `uvm_do_on(host_d2h_rsp_seq_h, p_sequencer.host_d2h_rsp_seqr);
        end
        begin
          `uvm_do_on(host_d2h_data_seq_h, p_sequencer.host_d2h_data_seqr);
        end
        begin
          `uvm_do_on(dev_h2d_req_seq_h, p_sequencer.dev_h2d_req_seqr);
        end
        begin
          `uvm_do_on(dev_h2d_rsp_seq_h, p_sequencer.dev_h2d_rsp_seqr);
        end
        begin
          `uvm_do_on(dev_h2d_data_seq_h, p_sequencer.dev_h2d_data_seqr);
        end
        begin
          `uvm_do_on(dev_m2s_req_seq_h, p_sequencer.dev_m2s_req_seqr);
        end
        begin
          `uvm_do_on(dev_m2s_rwd_seq_h, p_sequencer.dev_m2s_rwd_seqr);
        end
        begin
          `uvm_do_on(host_s2m_drs_seq_h, p_sequencer.host_s2m_drs_seqr);
        end
        begin
          `uvm_do_on(host_s2m_ndr_seq_h, p_sequencer.host_s2m_ndr_seqr);
        end
      join;
    endtask

  endclass

  class cxl_base_test extends uvm_test;
    `uvm_component_utils(cxl_base_test)
    cxl_cm_env cxl_cm_env_h;
    cxl_vseq cxl_vseq_h;

    function new(string name = cxl_base_test, uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cxl_cm_env_h = cxl_cm_env::type_id::create("cxl_cm_env_h", this);
    endfunction     

    virtual task void run_phase(uvm_phase phase);
      super.run_phase(phase);
      cxl_vseq_h = cxl_vseq::type_id::create("cxl_vseq_h", this);
      cxl_vseq_h.start(cxl_cm_env_h.cxl_cm_vseqr);
    endtask

  endclass

endmodule