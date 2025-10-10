//TODO: do you want to incorporate memwr from fig40/38?
//TODO: do you want to incorporate bias flip flows? do you want bias table and assign mem regions specifying device mem and host mem?
//TODO: add monitor checks if rsp is GO then MESI rspdata should be as per encoded this is missing check
//TODO: (no need of this) - best way to find out if the uqid is a wrinv then save it in psequencer and refer to it through uqid and send that response that support needs to be added you can just rspd to go I/err just through this opcode you need to know if it is a write so we can send back the wr rsp
//TODO: CXLv2.0 spec pg num 623 how do you relate to drs and ndr such as for memrddata rows, currently missing, need to add logic to relate these 
//TODO: add static assertions to check legal combinations of m2s req/rwd opcode  snp and meta in the monitors itself
//TODO: (fixed) - responder seq bug it is only doing req rsp it is not doing rsp rsp like wr pull should cause a copy uqid txn then send it back to h2d device path that is missing??
//TODO: (done/pending/lowpri - lrsm/rrssm integration pending - low priority for now) connection of ack to retry buffer and entry of tx pkt and lrsmrrsm integration to be done
//TODO: (TBD/lowpri) next focus on 32B size pkt logic 
//TODO: bug in the design crc placement needs fix in tx and rx
`include "uvm_macros.svh"
import uvm_pkg::*;

package geet_cxl_datatypes_uvm_pkg;

parameter GEET_CXL_ADDR_WIDTH = 52;
parameter GEET_CXL_DATA_WIDTH = 512;
parameter GEET_CXL_CACHE_CQID_WIDTH = 12;
parameter GEET_CXL_CACHE_UQID_WIDTH = 12;
parameter GEET_CXL_CACHE_RSPPRE_WIDTH = 2;
parameter GEET_CXL_CACHE_RSPDATA_WIDTH = 12;
parameter GEET_CXL_MEM_TAG_WIDTH = 16;
parameter GEET_CXL_MEM_TC_WIDTH = 16;

typedef enum {
  GEET_CXL_CACHE_OPCODE_RDCURR, 
  GEET_CXL_CACHE_OPCODE_RDOWN,
  GEET_CXL_CACHE_OPCODE_RDSHARED,
  GEET_CXL_CACHE_OPCODE_RDANY,
  GEET_CXL_CACHE_OPCODE_RDOWNNODATA,
  GEET_CXL_CACHE_OPCODE_ITOMWR,
  GEET_CXL_CACHE_OPCODE_MEMWRI,
  GEET_CXL_CACHE_OPCODE_CLFLUSH,
  GEET_CXL_CACHE_OPCODE_CLEANEVICT,
  GEET_CXL_CACHE_OPCODE_DIRTYEVICT,
  GEET_CXL_CACHE_OPCODE_CLEANEVICTNODATA,
  GEET_CXL_CACHE_OPCODE_WOWRINV,
  GEET_CXL_CACHE_OPCODE_WOWRINVF,
  GEET_CXL_CACHE_OPCODE_WRINV,
  GEET_CXL_CACHE_OPCODE_CACHEFLUSHED    
} d2h_req_opcode_t; 

typedef enum {
  GEET_CXL_CACHE_OPCODE_RSPIHITI,
  GEET_CXL_CACHE_OPCODE_RSPVHITV,
  GEET_CXL_CACHE_OPCODE_RSPIHITSE,
  GEET_CXL_CACHE_OPCODE_RSPSHITSE,
  GEET_CXL_CACHE_OPCODE_RSPSFWDM,
  GEET_CXL_CACHE_OPCODE_RSPIFWDM,
  GEET_CXL_CACHE_OPCODE_RSPVFWDV
} d2h_rsp_opcode_t; 

typedef enum {
  GEET_CXL_CACHE_OPCODE_SNPDATA,
  GEET_CXL_CACHE_OPCODE_SNPINV,
  GEET_CXL_CACHE_OPCODE_SNPCURR
} h2d_req_opcode_t; 

typedef enum {
  GEET_CXL_CACHE_MESI_I   = 'h3,
  GEET_CXL_CACHE_MESI_S   = 'h1,
  GEET_CXL_CACHE_MESI_E   = 'h2,
  GEET_CXL_CACHE_MESI_M   = 'h6,
  GEET_CXL_CACHE_MESI_ERR = 'h4
} h2d_rsp_data_opcode_t; 

typedef enum {
  GEET_CXL_CACHE_OPCODE_WRITEPULL,
  GEET_CXL_CACHE_OPCODE_GO,
  GEET_CXL_CACHE_OPCODE_GOWRITEPULL,
  GEET_CXL_CACHE_OPCODE_EXTCMP,
  GEET_CXL_CACHE_OPCODE_GOWRPULLDROP,
  GEET_CXL_CACHE_OPCODE_FASTGO,
  GEET_CXL_CACHE_OPCODE_FASTGOWRPULL,
  GEET_CXL_CACHE_OPCODE_GOERRWRPULL
} h2d_rsp_opcode_t; 

typedef enum {
  GEET_CXL_MEM_OPCODE_MEMINV,
  GEET_CXL_MEM_OPCODE_MEMRD,
  GEET_CXL_MEM_OPCODE_MEMRDDATA,
  GEET_CXL_MEM_OPCODE_MEMRDFWD,
  GEET_CXL_MEM_OPCODE_MEMWRFWD,
  GEET_CXL_MEM_OPCODE_MEMINVNT
} m2s_req_opcode_t;

typedef enum {
  GEET_CXL_MEM_OPCODE_MEMWR,
  GEET_CXL_MEM_OPCODE_MEMWRPTL
} m2s_rwd_opcode_t;

typedef enum {
  GEET_CXL_MEM_OPCODE_CMP,
  GEET_CXL_MEM_OPCODE_CMPS,
  GEET_CXL_MEM_OPCODE_CMPE
} s2m_ndr_opcode_t;

typedef enum {
  GEET_CXL_MEM_OPCODE_MEMDATA
} s2m_drs_opcode_t;

typedef enum {
  GEET_CXL_MEM_MF_METAFIELD_META0STATE,
  GEET_CXL_MEM_MF_METAFIELD_RSVD1,
  GEET_CXL_MEM_MF_METAFIELD_RSVD2,
  GEET_CXL_MEM_MF_METAFIELD_NOOP
} metafield_t;

typedef enum {
  GEET_CXL_MEM_MV_METAVALUE_INVALID,
  GEET_CXL_MEM_MV_METAVALUE_RSVD,
  GEET_CXL_MEM_MV_METAVALUE_ANY,
  GEET_CXL_MEM_MV_METAVALUE_SHARED
} metavalue_t;

typedef enum {
  GEET_CXL_MEM_SNPTYP_MEMSNPNOOP,
  GEET_CXL_MEM_SNPTYP_MEMSNPDATA,
  GEET_CXL_MEM_SNPTYP_MEMSNPCUR,
  GEET_CXL_MEM_SNPTYP_MEMSNPINV
} snptype_t;

typedef enum {
  GEET_CXL_SHORT_DLY,
  GEET_CXL_MED_DLY,
  GEET_CXL_LONG_DLY
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
  h2d_rsp_data_opcode_t rspdata;
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
  metafield_t metafield;
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
  s2m_drs_opcode_t opcode;
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

typedef enum {
  GEET_CXL_HDM_H,
  GEET_CXL_HDM_D
} cxl_hdm_t;

typedef enum {
  GEET_CXL_TYPE_1,
  GEET_CXL_TYPE_2,
  GEET_CXL_TYPE_3
} cxl_type_t;

endpackage

import geet_cxl_datatypes_uvm_pkg::*;

interface cxl_cache_d2h_req_if(input logic clk);
  logic ready;
  logic rstn;
  d2h_req_txn_t d2h_req_txn;

  modport host_if_mp(
    input clk,
    input ready,
    input rstn,
    output d2h_req_txn
  );

  modport dev_if_mp(
    input clk,
    output ready,
    input rstn,
    input d2h_req_txn
  );

  modport dev_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output d2h_req_txn
  );

  modport host_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input d2h_req_txn
  );

  modport mon(
    input clk,
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
    input clk,
    input ready,
    input rstn,
    output d2h_rsp_txn
  );

  modport dev_if_mp(
    input clk,
    output ready,
    input rstn,
    input d2h_rsp_txn
  );

  modport dev_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output d2h_rsp_txn
  );

  modport host_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input d2h_rsp_txn
  );

  modport mon(
    input clk,
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
    input clk,
    input ready,
    input rstn,
    output d2h_data_txn
  );

  modport dev_if_mp(
    input clk,
    output ready,
    input rstn,
    input d2h_data_txn
  );

  modport dev_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output d2h_data_txn
  );

  modport host_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input d2h_data_txn
  );

  modport mon(
    input clk,
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
    input clk,
    output ready,
    input rstn,
    input h2d_req_txn
  );

  modport dev_if_mp(
    input clk,
    input ready,
    input rstn,
    output h2d_req_txn
  );

  modport host_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output h2d_req_txn
  );

  modport dev_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input h2d_req_txn
  );

  modport mon(
    input clk,
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
    input clk,
    output ready,
    input rstn,
    input h2d_rsp_txn
  );

  modport dev_if_mp(
    input clk,
    input ready,
    input rstn,
    output h2d_rsp_txn
  );

  modport host_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output h2d_rsp_txn
  );

  modport dev_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input h2d_rsp_txn
  );

  modport mon(
    input clk,
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
    input clk,
    output ready,
    input rstn,
    input h2d_data_txn
  );

  modport dev_if_mp(
    input clk,
    input ready,
    input rstn,
    output h2d_data_txn
  );

  modport host_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output h2d_data_txn
  );

  modport dev_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input h2d_data_txn
  );

  modport mon(
    input clk,
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
    input clk,
    output ready,
    input rstn,
    input m2s_req_txn
  );

  modport dev_if_mp(
    input clk,
    input ready,
    input rstn,
    output m2s_req_txn
  );

  modport host_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output m2s_req_txn
  );

  modport dev_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input m2s_req_txn
  );

  modport mon(
    input clk,
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
    input clk,
    output ready,
    input rstn,
    input m2s_rwd_txn
  );

  modport dev_if_mp(
    input clk,
    input ready,
    input rstn,
    output m2s_rwd_txn
  );

  modport host_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output m2s_rwd_txn
  );

  modport dev_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input m2s_rwd_txn
  );

  modport mon(
    input clk,
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
    input clk,
    input ready,
    input rstn,
    output s2m_ndr_txn
  );

  modport dev_if_mp(
    input clk,
    output ready,
    input rstn,
    input s2m_ndr_txn
  );

  modport dev_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output s2m_ndr_txn
  );

  modport host_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input s2m_ndr_txn
  );

  modport mon(
    input clk,
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
    input clk,
    input ready,
    input rstn,
    output s2m_drs_txn
  );

  modport dev_if_mp(
    input clk,
    output ready,
    input rstn,
    input s2m_drs_txn
  );

  modport dev_actv_drvr_mp(
    input clk,
    input ready,
    output rstn,
    output s2m_drs_txn
  );

  modport host_pasv_drvr_mp(
    input clk,
    output ready,
    output rstn,
    input s2m_drs_txn
  );

  modport mon(
    input clk,
    input ready,
    input rstn,
    input s2m_drs_txn
  );

endinterface

interface cxl_host_tx_dl_if(input logic clk);
  logic rstn;
  logic valid;
  logic [527:0] data;

  modport tx_mp(
    input clk,
    input rstn,
    output valid,
    output data
  );

  modport mon(
    input clk,
    input rstn,
    input valid,
    input data
  );

endinterface

interface cxl_host_rx_dl_if(input logic clk);
  logic rstn;
  logic valid;
  logic [527:0] data;

  modport rx_mp(
    input clk,
    input rstn,
    input valid,
    input data
  );

  modport mon(
    input clk,
    input rstn,
    input valid,
    input data
  );

endinterface

interface cxl_dev_tx_dl_if(input logic clk);
  logic rstn;
  logic valid;
  logic [527:0] data;

  modport tx_mp(
    input clk,
    input rstn,
    output valid,
    output data
  );

  modport mon(
    input clk,
    input rstn,
    input valid,
    input data
  );

endinterface

interface cxl_dev_rx_dl_if(input logic clk);
  logic rstn;
  logic valid;
  logic [527:0] data;

  modport rx_mp(
    input clk,
    input rstn,
    input valid,
    input data
  );

  modport mon(
    input clk,
    input rstn,
    input valid,
    input data
  );

endinterface 

module rra#(
  parameter NO_OF_REQ = 7
)(
  input clk,
  input rstn,
  input logic [NO_OF_REQ-1:0] req,
  output logic [NO_OF_REQ-1:0] gnt
);

logic [NO_OF_REQ-1:0] hdr;
typedef enum {
  IDLE,
  GNT0,
  GNT1,
  GNT2,
  GNT3,
  GNT4,
  GNT5,
  GNT6
} rra_state_t;
rra_state_t st;

//implementation tbd
always@(posedge clk) begin
  if(!rstn) begin
    gnt <= 'h0;
    hdr <= 'h1;
  end else begin
    if(req == 'h0) begin
      gnt <= 'h0;
      hdr <= hdr;
    end else if((req[0]) && (hdr[0])) begin
      gnt <= 'h1;
      casez(req)
        7'b0000000: hdr <= hdr;
        7'b0000001: hdr <= 'h1;
        7'b?????11: hdr <= 'h2;
        7'b????101: hdr <= 'h4;
        7'b???1001: hdr <= 'h8;
        7'b??10001: hdr <= 'h10;
        7'b?100001: hdr <= 'h20;
        7'b1000001: hdr <= 'h40;
        7'b?????10: hdr <= 'h2;
        7'b????100: hdr <= 'h4;
        7'b???1000: hdr <= 'h8;
        7'b??10000: hdr <= 'h10;
        7'b?100000: hdr <= 'h20;
        7'b1000000: hdr <= 'h40;
        default: hdr <= 'hX;
      endcase
    end else if((req[1]) && (hdr[1])) begin
      gnt <= 'h2;
      casez({req[0], req[6:1]})
        7'b0000000: hdr <= hdr;
        7'b0000001: hdr <= 'h1;
        7'b?????11: hdr <= 'h2;
        7'b????101: hdr <= 'h4;
        7'b???1001: hdr <= 'h8;
        7'b??10001: hdr <= 'h10;
        7'b?100001: hdr <= 'h20;
        7'b1000001: hdr <= 'h40;
        7'b?????10: hdr <= 'h2;
        7'b????100: hdr <= 'h4;
        7'b???1000: hdr <= 'h8;
        7'b??10000: hdr <= 'h10;
        7'b?100000: hdr <= 'h20;
        7'b1000000: hdr <= 'h40;
        default: hdr <= 'hX;
      endcase
    end else if((req[2]) && (hdr[2])) begin
      gnt <= 'h4;
      casez({req[1:0], req[6:2]})
        7'b0000000: hdr <= hdr;
        7'b0000001: hdr <= 'h1;
        7'b?????11: hdr <= 'h2;
        7'b????101: hdr <= 'h4;
        7'b???1001: hdr <= 'h8;
        7'b??10001: hdr <= 'h10;
        7'b?100001: hdr <= 'h20;
        7'b1000001: hdr <= 'h40;
        7'b?????10: hdr <= 'h2;
        7'b????100: hdr <= 'h4;
        7'b???1000: hdr <= 'h8;
        7'b??10000: hdr <= 'h10;
        7'b?100000: hdr <= 'h20;
        7'b1000000: hdr <= 'h40;
        default: hdr <= 'hX;
      endcase
    end else if((req[3]) && (hdr[3])) begin
      gnt <= 'h8;
      casez({req[2:0], req[6:3]})
        7'b0000000: hdr <= hdr;
        7'b0000001: hdr <= 'h1;
        7'b?????11: hdr <= 'h2;
        7'b????101: hdr <= 'h4;
        7'b???1001: hdr <= 'h8;
        7'b??10001: hdr <= 'h10;
        7'b?100001: hdr <= 'h20;
        7'b1000001: hdr <= 'h40;
        7'b?????10: hdr <= 'h2;
        7'b????100: hdr <= 'h4;
        7'b???1000: hdr <= 'h8;
        7'b??10000: hdr <= 'h10;
        7'b?100000: hdr <= 'h20;
        7'b1000000: hdr <= 'h40;
        default: hdr <= 'hX;
      endcase
    end else if((req[4]) && (hdr[4])) begin
      gnt <= 'h10;
      casez({req[3:0], req[6:4]})
        7'b0000000: hdr <= hdr;
        7'b0000001: hdr <= 'h1;
        7'b?????11: hdr <= 'h2;
        7'b????101: hdr <= 'h4;
        7'b???1001: hdr <= 'h8;
        7'b??10001: hdr <= 'h10;
        7'b?100001: hdr <= 'h20;
        7'b1000001: hdr <= 'h40;
        7'b?????10: hdr <= 'h2;
        7'b????100: hdr <= 'h4;
        7'b???1000: hdr <= 'h8;
        7'b??10000: hdr <= 'h10;
        7'b?100000: hdr <= 'h20;
        7'b1000000: hdr <= 'h40;
        default: hdr <= 'hX;
      endcase
    end else if((req[5]) && (hdr[5])) begin
      gnt <= 'h20;
      casez({req[4:0], req[6:5]})
        7'b0000000: hdr <= hdr;
        7'b0000001: hdr <= 'h1;
        7'b?????11: hdr <= 'h2;
        7'b????101: hdr <= 'h4;
        7'b???1001: hdr <= 'h8;
        7'b??10001: hdr <= 'h10;
        7'b?100001: hdr <= 'h20;
        7'b1000001: hdr <= 'h40;
        7'b?????10: hdr <= 'h2;
        7'b????100: hdr <= 'h4;
        7'b???1000: hdr <= 'h8;
        7'b??10000: hdr <= 'h10;
        7'b?100000: hdr <= 'h20;
        7'b1000000: hdr <= 'h40;
        default: hdr <= 'hX;
      endcase
    end else if((req[6]) && (hdr[6])) begin
      gnt <= 'h40;
      casez({req[5:0], req[6]})
        7'b0000000: hdr <= hdr;
        7'b0000001: hdr <= 'h1;
        7'b?????11: hdr <= 'h2;
        7'b????101: hdr <= 'h4;
        7'b???1001: hdr <= 'h8;
        7'b??10001: hdr <= 'h10;
        7'b?100001: hdr <= 'h20;
        7'b1000001: hdr <= 'h40;
        7'b?????10: hdr <= 'h2;
        7'b????100: hdr <= 'h4;
        7'b???1000: hdr <= 'h8;
        7'b??10000: hdr <= 'h10;
        7'b?100000: hdr <= 'h20;
        7'b1000000: hdr <= 'h40;
        default: hdr <= 'hX;
      endcase
    end
  end
end

endmodule

module host_tx_path#(
  parameter BUFFER_DEPTH = 32,
  parameter BUFFER_ADDR_WIDTH = 5

)(
  input logic init_done,
  input logic ack,
  input logic ack_ret_val,
  input logic [7:0] ack_ret,
  input logic [BUFFER_ADDR_WIDTH-1:0] d2h_req_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] d2h_rsp_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] d2h_data_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] s2m_ndr_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] s2m_drs_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] h2d_req_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] h2d_rsp_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] h2d_data_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] m2s_req_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] m2s_rwd_occ,
  input logic [BUFFER_ADDR_WIDTH:0] d2h_req_wptr,
  input logic [BUFFER_ADDR_WIDTH:0] d2h_rsp_wptr,
  input logic [BUFFER_ADDR_WIDTH:0] d2h_data_wptr,
  input logic [BUFFER_ADDR_WIDTH:0] s2m_ndr_wptr,
  input logic [BUFFER_ADDR_WIDTH:0] s2m_drs_wptr,
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
  input h2d_req_txn_t h2d_req_tdataout,
  input h2d_req_txn_t h2d_req_qdataout,
  input h2d_rsp_txn_t h2d_rsp_dataout,
  input h2d_rsp_txn_t h2d_rsp_ddataout,
  input h2d_rsp_txn_t h2d_rsp_tdataout,
  input h2d_rsp_txn_t h2d_rsp_qdataout,
  input h2d_data_txn_t h2d_data_dataout,
  input h2d_data_txn_t h2d_data_ddataout,
  input h2d_data_txn_t h2d_data_tdataout,
  input h2d_data_txn_t h2d_data_qdataout,
  input m2s_req_txn_t m2s_req_dataout,
  input m2s_req_txn_t m2s_req_ddataout,
  input m2s_req_txn_t m2s_req_tdataout,
  input m2s_req_txn_t m2s_req_qdataout,
  input m2s_rwd_txn_t m2s_rwd_dataout,
  input m2s_rwd_txn_t m2s_rwd_ddataout,
  input m2s_rwd_txn_t m2s_rwd_tdataout,
  input m2s_rwd_txn_t m2s_rwd_qdataout,
  cxl_host_tx_dl_if.tx_mp host_tx_dl_if,
  cxl_host_rx_dl_if.rx_mp host_rx_dl_if
);

  localparam SLOT1_OFFSET = 128;
  localparam SLOT2_OFFSET = 256;
  localparam SLOT3_OFFSET = 384;
  logic [5:0] h_val;
  logic [5:0] h_req;
  logic [5:0] h_gnt;
  logic [5:0] h_gnt_d;
  logic [5:0] g_val;
  logic [5:0] g_req;
  logic [5:0] g_gnt;
  logic [5:0] g_gnt_d;
  typedef enum {
    XSLOT = 'h0,
    H_SLOT0 = 'h1,
    G_SLOT1 = 'h2,
    G_SLOT2 = 'h4,
    G_SLOT3 = 'h8
  } slot_sel_t;
  slot_sel_t slot_sel;
  slot_sel_t slot_sel_d;
  logic [7:0] holding_rdptr;
  logic [7:0] holding_wrptr;
  typedef struct {
    logic valid;
    logic [511:0] data;
  } holding_q_t;
  holding_q_t holding_q[256];
  logic lru;
  int d2h_req_outstanding_credits;
  int d2h_req_consumed_credits;
  int d2h_req_occ_d;
  int d2h_rsp_outstanding_credits;
  int d2h_rsp_consumed_credits;
  int d2h_rsp_occ_d;
  int d2h_data_outstanding_credits;
  int d2h_data_consumed_credits;
  int d2h_data_occ_d;
  int s2m_ndr_outstanding_credits;
  int s2m_ndr_consumed_credits;
  int s2m_ndr_occ_d;
  int s2m_drs_outstanding_credits;
  int s2m_drs_consumed_credits;
  int s2m_drs_occ_d;
  typedef struct{
    bit pending;
    int credit_to_be_sent;
  } crdt_tbs_t;
  crdt_tbs_t d2h_req_crdt_tbs[4];
  crdt_tbs_t d2h_rsp_crdt_tbs[4];
  crdt_tbs_t d2h_data_crdt_tbs[4];
  crdt_tbs_t s2m_ndr_crdt_tbs[4];
  crdt_tbs_t s2m_drs_crdt_tbs[4];
  logic [2:0] d2h_req_crdt_send;
  logic [2:0] d2h_rsp_crdt_send;
  logic [2:0] d2h_data_crdt_send;
  logic [2:0] s2m_ndr_crdt_send;
  logic [2:0] s2m_drs_crdt_send;
  int ack_cnt_tbs;//ack count to be sent 
  int ack_cnt_snt;//current ack count sent 
  logic insert_ack;
  logic [3:0] data_slot[5];
  logic [3:0] data_slot_d[5];
  logic host_tx_dl_if_pre_valid;
  logic [15:0] host_tx_dl_if_pre_crc;
  logic [511:0] host_tx_dl_if_pre_data;
  virtual cxl_host_tx_dl_if host_tx_dl_if_d;
  //IMP INFO:consider s2m ndr as rsp credits and s2m drs as data credits

  ASSERT_ONEHOT_SLOT_SEL:assert property (@(posedge host_tx_dl_if.clk) disable iff (!host_tx_dl_if.rstn) $onehot(slot_sel));

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

  assign h2d_req_rval   = (h_gnt[0] || h_gnt[2] || g_gnt[2])? 'h1: 'h0;
  assign h2d_rsp_rval   = (h_gnt[0] || g_gnt[2] || g_gnt[3] || g_gnt[5])? 'h1: 'h0;
  assign h2d_rsp_drval  = (h_gnt[1])? 'h1: 'h0;
  assign h2d_data_rval  = (h_gnt[1] || h_gnt[2] || g_gnt[2] || g_gnt[4])? 'h1: 'h0;
  assign h2d_data_drval = (h_gnt[3])? 'h1: 'h0;
  assign m2s_req_rval   = (h_gnt[5] || g_gnt[4])? 'h1: 'h0;
  assign m2s_rwd_rval   = (h_gnt[4] || g_gnt[5])? 'h1: 'h0;
  assign h2d_req_qrval  = (g_gnt[1])? 'h1: 'h0;
  assign h2d_data_qrval = (g_gnt[3])? 'h1: 'h0;

  assign h_req = ((slot_sel>1) || (data_slot[0] == 'hf)) ? 'h0: h_val;
  assign g_req = ((slot_sel[0]) || ((data_slot[0] == 'hf) || (data_slot[0] == 'he)))? 'h0: g_val;

  assign insert_ack = (((ack_cnt_tbs - ack_cnt_snt) > 16) || init_done)? 1'h1: 1'h0;

  always_comb begin
    d2h_req_outstanding_credits   = (d2h_req_occ_d  > d2h_req_occ ) ? (d2h_req_occ_d  - d2h_req_occ   ) : 'h0;
    d2h_rsp_outstanding_credits   = (d2h_rsp_occ_d  > d2h_rsp_occ ) ? (d2h_rsp_occ_d  - d2h_rsp_occ   ) : 'h0;
    d2h_data_outstanding_credits  = (d2h_data_occ_d > d2h_data_occ) ? (d2h_data_occ_d - d2h_data_occ  ) : 'h0;
    s2m_ndr_outstanding_credits   = (s2m_ndr_occ_d  > s2m_ndr_occ ) ? (s2m_ndr_occ_d  - s2m_ndr_occ   ) : 'h0;
    s2m_drs_outstanding_credits   = (s2m_drs_occ_d  > s2m_drs_occ ) ? (s2m_drs_occ_d  - s2m_drs_occ   ) : 'h0;
    d2h_req_consumed_credits      = (d2h_req_occ_d  < d2h_req_occ ) ? (d2h_req_occ    - d2h_req_occ_d ) : 'h0;
    d2h_rsp_consumed_credits      = (d2h_rsp_occ_d  < d2h_rsp_occ ) ? (d2h_rsp_occ    - d2h_rsp_occ_d ) : 'h0;
    d2h_data_consumed_credits     = (d2h_data_occ_d < d2h_data_occ) ? (d2h_data_occ   - d2h_data_occ_d) : 'h0;
    s2m_ndr_consumed_credits      = (s2m_ndr_occ_d  < s2m_ndr_occ ) ? (s2m_ndr_occ    - s2m_ndr_occ_d ) : 'h0;
    s2m_drs_consumed_credits      = (s2m_drs_occ_d  < s2m_drs_occ ) ? (s2m_drs_occ    - s2m_drs_occ_d ) : 'h0;
   
    if(d2h_req_crdt_tbs[3].pending) begin
      if(d2h_req_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        d2h_req_crdt_send = 'h7;
      end else if(d2h_req_crdt_tbs[3].credit_to_be_sent > 'd32) begin
        d2h_req_crdt_send = 'h6;
      end else if(d2h_req_crdt_tbs[3].credit_to_be_sent > 'd16) begin
        d2h_req_crdt_send = 'h5;
      end else if(d2h_req_crdt_tbs[3].credit_to_be_sent > 'd8) begin
        d2h_req_crdt_send = 'h4;
      end else if(d2h_req_crdt_tbs[3].credit_to_be_sent > 'd4) begin
        d2h_req_crdt_send = 'h3;
      end else if(d2h_req_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        d2h_req_crdt_send = 'h2;
      end else if(d2h_req_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        d2h_req_crdt_send = 'h1;
      end else begin
        if(d2h_req_crdt_tbs[2].pending) begin
          if(d2h_req_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            d2h_req_crdt_send = 'h7;
          end else if(d2h_req_crdt_tbs[2].credit_to_be_sent > 'd32) begin
            d2h_req_crdt_send = 'h6;
          end else if(d2h_req_crdt_tbs[2].credit_to_be_sent > 'd16) begin
            d2h_req_crdt_send = 'h5;
          end else if(d2h_req_crdt_tbs[2].credit_to_be_sent > 'd8) begin
            d2h_req_crdt_send = 'h4;
          end else if(d2h_req_crdt_tbs[2].credit_to_be_sent > 'd4) begin
            d2h_req_crdt_send = 'h3;
          end else if(d2h_req_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            d2h_req_crdt_send = 'h2;
          end else if(d2h_req_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            d2h_req_crdt_send = 'h1;
          end else begin
            if(d2h_req_crdt_tbs[1].pending) begin
              if(d2h_req_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                d2h_req_crdt_send = 'h7;
              end else if(d2h_req_crdt_tbs[1].credit_to_be_sent > 'd32) begin
                d2h_req_crdt_send = 'h6;
              end else if(d2h_req_crdt_tbs[1].credit_to_be_sent > 'd16) begin
               d2h_req_crdt_send = 'h5;
              end else if(d2h_req_crdt_tbs[1].credit_to_be_sent > 'd8) begin
                d2h_req_crdt_send = 'h4;
              end else if(d2h_req_crdt_tbs[1].credit_to_be_sent >'d4) begin
                d2h_req_crdt_send = 'h3;
              end else if(d2h_req_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                d2h_req_crdt_send = 'h2;
              end else if(d2h_req_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                d2h_req_crdt_send = 'h1;
              end else begin
                if(d2h_req_crdt_tbs[0].pending) begin
                  if(d2h_req_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    d2h_req_crdt_send = 'h7;
                  end else if(d2h_req_crdt_tbs[2].credit_to_be_sent > 'd32) begin
                    d2h_req_crdt_send = 'h6;
                  end else if(d2h_req_crdt_tbs[2].credit_to_be_sent > 'd16) begin
                    d2h_req_crdt_send = 'h5;
                  end else if(d2h_req_crdt_tbs[2].credit_to_be_sent > 'd8) begin
                    d2h_req_crdt_send = 'h4;
                  end else if(d2h_req_crdt_tbs[2].credit_to_be_sent > 'd4) begin
                    d2h_req_crdt_send = 'h3;
                  end else if(d2h_req_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    d2h_req_crdt_send = 'h2;
                  end else if(d2h_req_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    d2h_req_crdt_send = 'h1;
                  end else begin
                    d2h_req_crdt_send = 'h0;
                  end
                end else begin
                  d2h_req_crdt_send = 'h0;
                end
              end
            end else begin
              d2h_req_crdt_send = 'h0;
            end
          end
        end else begin
          d2h_req_crdt_send = 'h0;
        end
      end 
    end else begin
      d2h_req_crdt_send = 'h0;
    end

    if(d2h_rsp_crdt_tbs[3].pending) begin
      if(d2h_rsp_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        d2h_rsp_crdt_send = 'h7;
      end else if(d2h_rsp_crdt_tbs[3].credit_to_be_sent > 'd32) begin
        d2h_rsp_crdt_send = 'h6;
      end else if(d2h_rsp_crdt_tbs[3].credit_to_be_sent > 'd16) begin
        d2h_rsp_crdt_send = 'h5;
      end else if(d2h_rsp_crdt_tbs[3].credit_to_be_sent > 'd8) begin
        d2h_rsp_crdt_send = 'h4;
      end else if(d2h_rsp_crdt_tbs[3].credit_to_be_sent > 'd4) begin
        d2h_rsp_crdt_send = 'h3;
      end else if(d2h_rsp_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        d2h_rsp_crdt_send = 'h2;
      end else if(d2h_rsp_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        d2h_rsp_crdt_send = 'h1;
      end else begin
        if(d2h_rsp_crdt_tbs[2].pending) begin
          if(d2h_rsp_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            d2h_rsp_crdt_send = 'h7;
          end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd32) begin
            d2h_rsp_crdt_send = 'h6;
          end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd16) begin
            d2h_rsp_crdt_send = 'h5;
          end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd8) begin
            d2h_rsp_crdt_send = 'h4;
          end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd4) begin
            d2h_rsp_crdt_send = 'h3;
          end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            d2h_rsp_crdt_send = 'h2;
          end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            d2h_rsp_crdt_send = 'h1;
          end else begin
            if(d2h_rsp_crdt_tbs[1].pending) begin
              if(d2h_rsp_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                d2h_rsp_crdt_send = 'h7;
              end else if(d2h_rsp_crdt_tbs[1].credit_to_be_sent > 'd32) begin
                d2h_rsp_crdt_send = 'h6;
              end else if(d2h_rsp_crdt_tbs[1].credit_to_be_sent > 'd16) begin
               d2h_rsp_crdt_send = 'h5;
              end else if(d2h_rsp_crdt_tbs[1].credit_to_be_sent > 'd8) begin
                d2h_rsp_crdt_send = 'h4;
              end else if(d2h_rsp_crdt_tbs[1].credit_to_be_sent > 'd4) begin
                d2h_rsp_crdt_send = 'h3;
              end else if(d2h_rsp_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                d2h_rsp_crdt_send = 'h2;
              end else if(d2h_rsp_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                d2h_rsp_crdt_send = 'h1;
              end else begin
                if(d2h_rsp_crdt_tbs[0].pending) begin
                  if(d2h_rsp_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    d2h_rsp_crdt_send = 'h7;
                  end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd32) begin
                    d2h_rsp_crdt_send = 'h6;
                  end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd16) begin
                    d2h_rsp_crdt_send = 'h5;
                  end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd8) begin
                    d2h_rsp_crdt_send = 'h4;
                  end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd4) begin
                    d2h_rsp_crdt_send = 'h3;
                  end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    d2h_rsp_crdt_send = 'h2;
                  end else if(d2h_rsp_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    d2h_rsp_crdt_send = 'h1;
                  end else begin
                    d2h_rsp_crdt_send = 'h0;
                  end
                end else begin
                  d2h_rsp_crdt_send = 'h0;
                end
              end
            end else begin
              d2h_rsp_crdt_send = 'h0;
            end
          end
        end else begin
          d2h_rsp_crdt_send = 'h0;
        end
      end 
    end else begin
      d2h_rsp_crdt_send = 'h0;
    end

    if(d2h_data_crdt_tbs[3].pending) begin
      if(d2h_data_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        d2h_data_crdt_send = 'h7;
      end else if(d2h_data_crdt_tbs[3].credit_to_be_sent > 'd32) begin
        d2h_data_crdt_send = 'h6;
      end else if(d2h_data_crdt_tbs[3].credit_to_be_sent > 'd16) begin
        d2h_data_crdt_send = 'h5;
      end else if(d2h_data_crdt_tbs[3].credit_to_be_sent > 'd8) begin
        d2h_data_crdt_send = 'h4;
      end else if(d2h_data_crdt_tbs[3].credit_to_be_sent > 'd4) begin
        d2h_data_crdt_send = 'h3;
      end else if(d2h_data_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        d2h_data_crdt_send = 'h2;
      end else if(d2h_data_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        d2h_data_crdt_send = 'h1;
      end else begin
        if(d2h_data_crdt_tbs[2].pending) begin
          if(d2h_data_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            d2h_data_crdt_send = 'h7;
          end else if(d2h_data_crdt_tbs[2].credit_to_be_sent > 'd32) begin
            d2h_data_crdt_send = 'h6;
          end else if(d2h_data_crdt_tbs[2].credit_to_be_sent > 'd16) begin
            d2h_data_crdt_send = 'h5;
          end else if(d2h_data_crdt_tbs[2].credit_to_be_sent > 'd8) begin
            d2h_data_crdt_send = 'h4;
          end else if(d2h_data_crdt_tbs[2].credit_to_be_sent > 'd4) begin
            d2h_data_crdt_send = 'h3;
          end else if(d2h_data_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            d2h_data_crdt_send = 'h2;
          end else if(d2h_data_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            d2h_data_crdt_send = 'h1;
          end else begin
            if(d2h_data_crdt_tbs[1].pending) begin
              if(d2h_data_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                d2h_data_crdt_send = 'h7;
              end else if(d2h_data_crdt_tbs[1].credit_to_be_sent > 'd32) begin
                d2h_data_crdt_send = 'h6;
              end else if(d2h_data_crdt_tbs[1].credit_to_be_sent > 'd16) begin
               d2h_data_crdt_send = 'h5;
              end else if(d2h_data_crdt_tbs[1].credit_to_be_sent > 'd8) begin
                d2h_data_crdt_send = 'h4;
              end else if(d2h_data_crdt_tbs[1].credit_to_be_sent > 'd4) begin
                d2h_data_crdt_send = 'h3;
              end else if(d2h_data_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                d2h_data_crdt_send = 'h2;
              end else if(d2h_data_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                d2h_data_crdt_send = 'h1;
              end else begin
                if(d2h_data_crdt_tbs[0].pending) begin
                  if(d2h_data_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    d2h_data_crdt_send = 'h7;
                  end else if(d2h_data_crdt_tbs[2].credit_to_be_sent > 'd32) begin
                    d2h_data_crdt_send = 'h6;
                  end else if(d2h_data_crdt_tbs[2].credit_to_be_sent > 'd16) begin
                    d2h_data_crdt_send = 'h5;
                  end else if(d2h_data_crdt_tbs[2].credit_to_be_sent > 'd8) begin
                    d2h_data_crdt_send = 'h4;
                  end else if(d2h_data_crdt_tbs[2].credit_to_be_sent > 'd4) begin
                    d2h_data_crdt_send = 'h3;
                  end else if(d2h_data_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    d2h_data_crdt_send = 'h2;
                  end else if(d2h_data_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    d2h_data_crdt_send = 'h1;
                  end else begin
                    d2h_data_crdt_send = 'h0;
                  end
                end else begin
                  d2h_data_crdt_send = 'h0;
                end
              end
            end else begin
              d2h_data_crdt_send = 'h0;
            end
          end
        end else begin
          d2h_data_crdt_send = 'h0;
        end
      end 
    end else begin
      d2h_data_crdt_send = 'h0;
    end
 
    if(s2m_ndr_crdt_tbs[3].pending) begin
      if(s2m_ndr_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        s2m_ndr_crdt_send = 'h7;
      end else if(s2m_ndr_crdt_tbs[3].credit_to_be_sent > 'd32) begin
        s2m_ndr_crdt_send = 'h6;
      end else if(s2m_ndr_crdt_tbs[3].credit_to_be_sent > 'd16) begin
        s2m_ndr_crdt_send = 'h5;
      end else if(s2m_ndr_crdt_tbs[3].credit_to_be_sent > 'd8) begin
        s2m_ndr_crdt_send = 'h4;
      end else if(s2m_ndr_crdt_tbs[3].credit_to_be_sent > 'd4) begin
        s2m_ndr_crdt_send = 'h3;
      end else if(s2m_ndr_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        s2m_ndr_crdt_send = 'h2;
      end else if(s2m_ndr_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        s2m_ndr_crdt_send = 'h1;
      end else begin
        if(s2m_ndr_crdt_tbs[2].pending) begin
          if(s2m_ndr_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            s2m_ndr_crdt_send = 'h7;
          end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd32) begin
            s2m_ndr_crdt_send = 'h6;
          end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd16) begin
            s2m_ndr_crdt_send = 'h5;
          end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd8) begin
            s2m_ndr_crdt_send = 'h4;
          end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd4) begin
            s2m_ndr_crdt_send = 'h3;
          end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            s2m_ndr_crdt_send = 'h2;
          end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            s2m_ndr_crdt_send = 'h1;
          end else begin
            if(s2m_ndr_crdt_tbs[1].pending) begin
              if(s2m_ndr_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                s2m_ndr_crdt_send = 'h7;
              end else if(s2m_ndr_crdt_tbs[1].credit_to_be_sent > 'd32) begin
                s2m_ndr_crdt_send = 'h6;
              end else if(s2m_ndr_crdt_tbs[1].credit_to_be_sent > 'd16) begin
               s2m_ndr_crdt_send = 'h5;
              end else if(s2m_ndr_crdt_tbs[1].credit_to_be_sent > 'd8) begin
                s2m_ndr_crdt_send = 'h4;
              end else if(s2m_ndr_crdt_tbs[1].credit_to_be_sent > 'd4) begin
                s2m_ndr_crdt_send = 'h3;
              end else if(s2m_ndr_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                s2m_ndr_crdt_send = 'h2;
              end else if(s2m_ndr_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                s2m_ndr_crdt_send = 'h1;
              end else begin
                if(s2m_ndr_crdt_tbs[0].pending) begin
                  if(s2m_ndr_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    s2m_ndr_crdt_send = 'h7;
                  end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd32) begin
                    s2m_ndr_crdt_send = 'h6;
                  end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd16) begin
                    s2m_ndr_crdt_send = 'h5;
                  end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd8) begin
                    s2m_ndr_crdt_send = 'h4;
                  end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd4) begin
                    s2m_ndr_crdt_send = 'h3;
                  end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    s2m_ndr_crdt_send = 'h2;
                  end else if(s2m_ndr_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    s2m_ndr_crdt_send = 'h1;
                  end else begin
                    s2m_ndr_crdt_send = 'h0;
                  end
                end else begin
                  s2m_ndr_crdt_send = 'h0;
                end
              end
            end else begin
              s2m_ndr_crdt_send = 'h0;
            end
          end
        end else begin
          s2m_ndr_crdt_send = 'h0;
        end
      end 
    end else begin
      s2m_ndr_crdt_send = 'h0;
    end

    if(s2m_drs_crdt_tbs[3].pending) begin
      if(s2m_drs_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        s2m_drs_crdt_send = 'h7;
      end else if(s2m_drs_crdt_tbs[3].credit_to_be_sent > 'd32) begin
        s2m_drs_crdt_send = 'h6;
      end else if(s2m_drs_crdt_tbs[3].credit_to_be_sent > 'd16) begin
        s2m_drs_crdt_send = 'h5;
      end else if(s2m_drs_crdt_tbs[3].credit_to_be_sent > 'd8) begin
        s2m_drs_crdt_send = 'h4;
      end else if(s2m_drs_crdt_tbs[3].credit_to_be_sent > 'd4) begin
        s2m_drs_crdt_send = 'h3;
      end else if(s2m_drs_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        s2m_drs_crdt_send = 'h2;
      end else if(s2m_drs_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        s2m_drs_crdt_send = 'h1;
      end else begin
        if(s2m_drs_crdt_tbs[2].pending) begin
          if(s2m_drs_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            s2m_drs_crdt_send = 'h7;
          end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd32) begin
            s2m_drs_crdt_send = 'h6;
          end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd16) begin
            s2m_drs_crdt_send = 'h5;
          end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd8) begin
            s2m_drs_crdt_send = 'h4;
          end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd4) begin
            s2m_drs_crdt_send = 'h3;
          end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            s2m_drs_crdt_send = 'h2;
          end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            s2m_drs_crdt_send = 'h1;
          end else begin
            if(s2m_drs_crdt_tbs[1].pending) begin
              if(s2m_drs_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                s2m_drs_crdt_send = 'h7;
              end else if(s2m_drs_crdt_tbs[1].credit_to_be_sent > 'd32) begin
                s2m_drs_crdt_send = 'h6;
              end else if(s2m_drs_crdt_tbs[1].credit_to_be_sent > 'd16) begin
               s2m_drs_crdt_send = 'h5;
              end else if(s2m_drs_crdt_tbs[1].credit_to_be_sent > 'd8) begin
                s2m_drs_crdt_send = 'h4;
              end else if(s2m_drs_crdt_tbs[1].credit_to_be_sent > 'd4) begin
                s2m_drs_crdt_send = 'h3;
              end else if(s2m_drs_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                s2m_drs_crdt_send = 'h2;
              end else if(s2m_drs_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                s2m_drs_crdt_send = 'h1;
              end else begin
                if(s2m_drs_crdt_tbs[0].pending) begin
                  if(s2m_drs_crdt_tbs[0].credit_to_be_sent == 'd64) begin
                    s2m_drs_crdt_send = 'h7;
                  end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd32) begin
                    s2m_drs_crdt_send = 'h6;
                  end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd16) begin
                    s2m_drs_crdt_send = 'h5;
                  end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd8) begin
                    s2m_drs_crdt_send = 'h4;
                  end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd4) begin
                    s2m_drs_crdt_send = 'h3;
                  end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    s2m_drs_crdt_send = 'h2;
                  end else if(s2m_drs_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    s2m_drs_crdt_send = 'h1;
                  end else begin
                    s2m_drs_crdt_send = 'h0;
                  end
                end else begin
                  s2m_drs_crdt_send = 'h0;
                end
              end
            end else begin
              s2m_drs_crdt_send = 'h0;
            end
          end
        end else begin
          s2m_drs_crdt_send = 'h0;
        end
      end 
    end else begin
      s2m_drs_crdt_send = 'h0;
    end

/*    d2h_req_crdt_send             = (d2h_req_crdt_tbs[3].pending)? (d2h_req_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (d2h_req_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (d2h_req_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (d2h_req_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (d2h_req_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (d2h_req_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (d2h_req_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_req_crdt_tbs[2].pending)? (d2h_req_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (d2h_req_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (d2h_req_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (d2h_req_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (d2h_req_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (d2h_req_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (d2h_req_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_req_crdt_tbs[1].pending)? (d2h_req_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (d2h_req_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (d2h_req_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (d2h_req_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (d2h_req_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (d2h_req_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (d2h_req_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_req_crdt_tbs[0].pending)? (d2h_req_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (d2h_req_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (d2h_req_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (d2h_req_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (d2h_req_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (d2h_req_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (d2h_req_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
    d2h_rsp_crdt_send             = (d2h_rsp_crdt_tbs[3].pending)? (d2h_rsp_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (d2h_rsp_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (d2h_rsp_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (d2h_rsp_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (d2h_rsp_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (d2h_rsp_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (d2h_rsp_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_rsp_crdt_tbs[2].pending)? (d2h_rsp_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (d2h_rsp_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (d2h_rsp_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (d2h_rsp_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_rsp_crdt_tbs[1].pending)? (d2h_rsp_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (d2h_rsp_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (d2h_rsp_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (d2h_rsp_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (d2h_rsp_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (d2h_rsp_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (d2h_rsp_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_rsp_crdt_tbs[0].pending)? (d2h_rsp_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (d2h_rsp_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (d2h_rsp_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (d2h_rsp_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (d2h_rsp_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (d2h_rsp_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (d2h_rsp_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
    d2h_data_crdt_send             = (d2h_data_crdt_tbs[3].pending)? (d2h_data_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (d2h_data_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (d2h_data_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (d2h_data_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (d2h_data_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (d2h_data_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (d2h_data_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_data_crdt_tbs[2].pending)? (d2h_data_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (d2h_data_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (d2h_data_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (d2h_data_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (d2h_data_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (d2h_data_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (d2h_data_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_data_crdt_tbs[1].pending)? (d2h_data_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (d2h_data_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (d2h_data_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (d2h_data_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (d2h_data_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (d2h_data_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (d2h_data_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (d2h_data_crdt_tbs[0].pending)? (d2h_data_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (d2h_data_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (d2h_data_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (d2h_data_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (d2h_data_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (d2h_data_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (d2h_data_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
    s2m_ndr_crdt_send             = (s2m_ndr_crdt_tbs[3].pending)? (s2m_ndr_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (s2m_ndr_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (s2m_ndr_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (s2m_ndr_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (s2m_ndr_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (s2m_ndr_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (s2m_ndr_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (s2m_ndr_crdt_tbs[2].pending)? (s2m_ndr_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (s2m_ndr_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (s2m_ndr_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (s2m_ndr_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (s2m_ndr_crdt_tbs[1].pending)? (s2m_ndr_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (s2m_ndr_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (s2m_ndr_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (s2m_ndr_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (s2m_ndr_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (s2m_ndr_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (s2m_ndr_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (s2m_ndr_crdt_tbs[0].pending)? (s2m_ndr_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (s2m_ndr_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (s2m_ndr_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (s2m_ndr_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (s2m_ndr_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (s2m_ndr_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (s2m_ndr_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
    s2m_drs_crdt_send             = (s2m_drs_crdt_tbs[3].pending)? (s2m_drs_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (s2m_drs_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (s2m_drs_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (s2m_drs_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (s2m_drs_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (s2m_drs_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (s2m_drs_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (s2m_drs_crdt_tbs[2].pending)? (s2m_drs_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (s2m_drs_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (s2m_drs_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (s2m_drs_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (s2m_drs_crdt_tbs[1].pending)? (s2m_drs_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (s2m_drs_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (s2m_drs_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (s2m_drs_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (s2m_drs_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (s2m_drs_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (s2m_drs_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (s2m_drs_crdt_tbs[0].pending)? (s2m_drs_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (s2m_drs_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (s2m_drs_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (s2m_drs_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (s2m_drs_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (s2m_drs_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (s2m_drs_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
*/  
  end

  always@(posedge host_tx_dl_if.clk) begin
    if(!host_tx_dl_if.rstn) begin
      lru <= 'h0;
      d2h_req_occ_d   <= 'd0;
      d2h_rsp_occ_d   <= 'd0;
      d2h_data_occ_d  <= 'd0;
      s2m_ndr_occ_d   <= 'd0;
      s2m_drs_occ_d   <= 'd0;
      d2h_req_crdt_tbs[0].pending <= 'h1;
      d2h_req_crdt_tbs[1].pending <= 'h1;
      d2h_req_crdt_tbs[2].pending <= 'h1;
      d2h_req_crdt_tbs[3].pending <= 'h1;
      d2h_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
      d2h_req_crdt_tbs[1].credit_to_be_sent <= 'd64;
      d2h_req_crdt_tbs[2].credit_to_be_sent <= 'd64;
      d2h_req_crdt_tbs[3].credit_to_be_sent <= 'd64;
    end else begin 
      d2h_req_occ_d   <= d2h_req_occ;
      d2h_rsp_occ_d   <= d2h_rsp_occ;
      d2h_data_occ_d  <= d2h_data_occ;
      s2m_ndr_occ_d   <= s2m_ndr_occ;
      s2m_drs_occ_d   <= s2m_drs_occ;
      if((d2h_req_crdt_tbs[0].credit_to_be_sent + d2h_req_outstanding_credits) <= 'd64) begin
        d2h_req_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0)) begin
          d2h_req_crdt_tbs[0].credit_to_be_sent <= d2h_req_crdt_tbs[0].credit_to_be_sent + d2h_req_outstanding_credits - ((d2h_req_crdt_send == 'h7)? 'd64: (d2h_req_crdt_send == 'h6)? 'h32: (d2h_req_crdt_send == 'h5)? 'h16: (d2h_req_crdt_send == 'h4)? 'h8: (d2h_req_crdt_send == 'h3)? 'h4: d2h_req_crdt_send);
        end else begin
          d2h_req_crdt_tbs[0].credit_to_be_sent <= d2h_req_crdt_tbs[0].credit_to_be_sent + d2h_req_outstanding_credits;
        end
      end else if(((d2h_req_crdt_tbs[0].credit_to_be_sent + d2h_req_outstanding_credits) > 'd64) && ((d2h_req_crdt_tbs[1].credit_to_be_sent + d2h_req_outstanding_credits) <= 'd64)) begin
        d2h_req_crdt_tbs[0].pending <= 'h1;
        d2h_req_crdt_tbs[1].pending <= 'h1;
        d2h_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0)) begin
          d2h_req_crdt_tbs[0].credit_to_be_sent <= d2h_req_crdt_tbs[0].credit_to_be_sent + d2h_req_outstanding_credits - ((d2h_req_crdt_send == 'h7)? 'd64: (d2h_req_crdt_send == 'h6)? 'h32: (d2h_req_crdt_send == 'h5)? 'h16: (d2h_req_crdt_send == 'h4)? 'h8: (d2h_req_crdt_send == 'h3)? 'h4: d2h_req_crdt_send);
        end else begin
          d2h_req_crdt_tbs[1].credit_to_be_sent <= d2h_req_crdt_tbs[1].credit_to_be_sent + d2h_req_outstanding_credits;
        end
      end else if(((d2h_req_crdt_tbs[1].credit_to_be_sent + d2h_req_outstanding_credits) > 'd64) && ((d2h_req_crdt_tbs[2].credit_to_be_sent + d2h_req_outstanding_credits) <= 'd64)) begin
        d2h_req_crdt_tbs[0].pending <= 'h1;
        d2h_req_crdt_tbs[1].pending <= 'h1;
        d2h_req_crdt_tbs[2].pending <= 'h1;
        d2h_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        d2h_req_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0)) begin
          d2h_req_crdt_tbs[0].credit_to_be_sent <= d2h_req_crdt_tbs[0].credit_to_be_sent + d2h_req_outstanding_credits - ((d2h_req_crdt_send == 'h7)? 'd64: (d2h_req_crdt_send == 'h6)? 'h32: (d2h_req_crdt_send == 'h5)? 'h16: (d2h_req_crdt_send == 'h4)? 'h8: (d2h_req_crdt_send == 'h3)? 'h4: d2h_req_crdt_send);
        end else begin
          d2h_req_crdt_tbs[2].credit_to_be_sent <= d2h_req_crdt_tbs[2].credit_to_be_sent + d2h_req_outstanding_credits;
        end
      end else if(((d2h_req_crdt_tbs[2].credit_to_be_sent + d2h_req_outstanding_credits) > 'd64) && ((d2h_req_crdt_tbs[3].credit_to_be_sent + d2h_req_outstanding_credits) <= 'd64)) begin
        d2h_req_crdt_tbs[0].pending <= 'h1;
        d2h_req_crdt_tbs[1].pending <= 'h1;
        d2h_req_crdt_tbs[2].pending <= 'h1;
        d2h_req_crdt_tbs[3].pending <= 'h1;
        d2h_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        d2h_req_crdt_tbs[1].credit_to_be_sent <= 'd64;
        d2h_req_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0)) begin
          d2h_req_crdt_tbs[0].credit_to_be_sent <= d2h_req_crdt_tbs[0].credit_to_be_sent + d2h_req_outstanding_credits - ((d2h_req_crdt_send == 'h7)? 'd64: (d2h_req_crdt_send == 'h6)? 'h32: (d2h_req_crdt_send == 'h5)? 'h16: (d2h_req_crdt_send == 'h4)? 'h8: (d2h_req_crdt_send == 'h3)? 'h4: d2h_req_crdt_send);
        end else begin
          d2h_req_crdt_tbs[3].credit_to_be_sent <= d2h_req_crdt_tbs[3].credit_to_be_sent + d2h_req_outstanding_credits;
        end
      end
      if((d2h_rsp_crdt_tbs[0].credit_to_be_sent + d2h_rsp_outstanding_credits) <= 'd64) begin
        d2h_rsp_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((s2m_ndr_crdt_send > 0) && (lru == 0)) || (s2m_ndr_crdt_send == 0))) begin
          d2h_rsp_crdt_tbs[0].credit_to_be_sent <= d2h_rsp_crdt_tbs[0].credit_to_be_sent + d2h_rsp_outstanding_credits - ((d2h_rsp_crdt_send == 'h7)? 'd64: (d2h_rsp_crdt_send == 'h6)? 'h32: (d2h_rsp_crdt_send == 'h5)? 'h16: (d2h_rsp_crdt_send == 'h4)? 'h8: (d2h_rsp_crdt_send == 'h3)? 'h4: d2h_rsp_crdt_send);
          if(s2m_ndr_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          d2h_rsp_crdt_tbs[0].credit_to_be_sent <= d2h_rsp_crdt_tbs[0].credit_to_be_sent + d2h_rsp_outstanding_credits;
        end
      end else if(((d2h_rsp_crdt_tbs[0].credit_to_be_sent + d2h_rsp_outstanding_credits) > 'd64) && ((d2h_rsp_crdt_tbs[1].credit_to_be_sent + d2h_rsp_outstanding_credits) <= 'd64)) begin
        d2h_rsp_crdt_tbs[0].pending <= 'h1;
        d2h_rsp_crdt_tbs[1].pending <= 'h1;
        d2h_rsp_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((s2m_ndr_crdt_send > 0) && (lru == 0)) || (s2m_ndr_crdt_send == 0))) begin
          d2h_rsp_crdt_tbs[0].credit_to_be_sent <= d2h_rsp_crdt_tbs[0].credit_to_be_sent + d2h_rsp_outstanding_credits - ((d2h_rsp_crdt_send == 'h7)? 'd64: (d2h_rsp_crdt_send == 'h6)? 'h32: (d2h_rsp_crdt_send == 'h5)? 'h16: (d2h_rsp_crdt_send == 'h4)? 'h8: (d2h_rsp_crdt_send == 'h3)? 'h4: d2h_rsp_crdt_send);
          if(s2m_ndr_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          d2h_rsp_crdt_tbs[1].credit_to_be_sent <= d2h_rsp_crdt_tbs[1].credit_to_be_sent + d2h_rsp_outstanding_credits;
        end
      end else if(((d2h_rsp_crdt_tbs[1].credit_to_be_sent + d2h_rsp_outstanding_credits) > 'd64) && ((d2h_rsp_crdt_tbs[2].credit_to_be_sent + d2h_rsp_outstanding_credits) <= 'd64)) begin
        d2h_rsp_crdt_tbs[0].pending <= 'h1;
        d2h_rsp_crdt_tbs[1].pending <= 'h1;
        d2h_rsp_crdt_tbs[2].pending <= 'h1;
        d2h_rsp_crdt_tbs[0].credit_to_be_sent <= 'd64;
        d2h_rsp_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((s2m_ndr_crdt_send > 0) && (lru == 0)) || (s2m_ndr_crdt_send == 0))) begin
          d2h_rsp_crdt_tbs[0].credit_to_be_sent <= d2h_rsp_crdt_tbs[0].credit_to_be_sent + d2h_rsp_outstanding_credits - ((d2h_rsp_crdt_send == 'h7)? 'd64: (d2h_rsp_crdt_send == 'h6)? 'h32: (d2h_rsp_crdt_send == 'h5)? 'h16: (d2h_rsp_crdt_send == 'h4)? 'h8: (d2h_rsp_crdt_send == 'h3)? 'h4: d2h_rsp_crdt_send);
          if(s2m_ndr_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          d2h_rsp_crdt_tbs[2].credit_to_be_sent <= d2h_rsp_crdt_tbs[2].credit_to_be_sent + d2h_rsp_outstanding_credits;
        end
      end else if(((d2h_rsp_crdt_tbs[2].credit_to_be_sent + d2h_rsp_outstanding_credits) > 'd64) && ((d2h_rsp_crdt_tbs[3].credit_to_be_sent + d2h_rsp_outstanding_credits) <= 'd64)) begin
        d2h_rsp_crdt_tbs[0].pending <= 'h1;
        d2h_rsp_crdt_tbs[1].pending <= 'h1;
        d2h_rsp_crdt_tbs[2].pending <= 'h1;
        d2h_rsp_crdt_tbs[3].pending <= 'h1;
        d2h_rsp_crdt_tbs[0].credit_to_be_sent <= 'd64;
        d2h_rsp_crdt_tbs[1].credit_to_be_sent <= 'd64;
        d2h_rsp_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((s2m_ndr_crdt_send > 0) && (lru == 0)) || (s2m_ndr_crdt_send == 0))) begin
          d2h_rsp_crdt_tbs[0].credit_to_be_sent <= d2h_rsp_crdt_tbs[0].credit_to_be_sent + d2h_rsp_outstanding_credits - ((d2h_rsp_crdt_send == 'h7)? 'd64: (d2h_rsp_crdt_send == 'h6)? 'h32: (d2h_rsp_crdt_send == 'h5)? 'h16: (d2h_rsp_crdt_send == 'h4)? 'h8: (d2h_rsp_crdt_send == 'h3)? 'h4: d2h_rsp_crdt_send);
          if(s2m_ndr_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          d2h_rsp_crdt_tbs[3].credit_to_be_sent <= d2h_rsp_crdt_tbs[3].credit_to_be_sent + d2h_rsp_outstanding_credits;
        end
      end
      if((d2h_data_crdt_tbs[0].credit_to_be_sent + d2h_data_outstanding_credits) <= 'd64) begin
        d2h_data_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((s2m_drs_crdt_send > 0) && (lru == 0)) || (s2m_drs_crdt_send == 0))) begin
          d2h_data_crdt_tbs[0].credit_to_be_sent <= d2h_data_crdt_tbs[0].credit_to_be_sent + d2h_data_outstanding_credits - ((d2h_data_crdt_send == 'h7)? 'd64: (d2h_data_crdt_send == 'h6)? 'h32: (d2h_data_crdt_send == 'h5)? 'h16: (d2h_data_crdt_send == 'h4)? 'h8: (d2h_data_crdt_send == 'h3)? 'h4: d2h_data_crdt_send);
          if(s2m_drs_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          d2h_data_crdt_tbs[0].credit_to_be_sent <= d2h_data_crdt_tbs[0].credit_to_be_sent + d2h_data_outstanding_credits;
        end
      end else if(((d2h_data_crdt_tbs[0].credit_to_be_sent + d2h_data_outstanding_credits) > 'd64) && ((d2h_data_crdt_tbs[1].credit_to_be_sent + d2h_data_outstanding_credits) <= 'd64)) begin
        d2h_data_crdt_tbs[0].pending <= 'h1;
        d2h_data_crdt_tbs[1].pending <= 'h1;
        d2h_data_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((s2m_drs_crdt_send > 0) && (lru == 0)) || (s2m_drs_crdt_send == 0))) begin
          d2h_data_crdt_tbs[0].credit_to_be_sent <= d2h_data_crdt_tbs[0].credit_to_be_sent + d2h_data_outstanding_credits - ((d2h_data_crdt_send == 'h7)? 'd64: (d2h_data_crdt_send == 'h6)? 'h32: (d2h_data_crdt_send == 'h5)? 'h16: (d2h_data_crdt_send == 'h4)? 'h8: (d2h_data_crdt_send == 'h3)? 'h4: d2h_data_crdt_send);
          if(s2m_drs_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          d2h_data_crdt_tbs[1].credit_to_be_sent <= d2h_data_crdt_tbs[1].credit_to_be_sent + d2h_data_outstanding_credits;
        end
      end else if(((d2h_data_crdt_tbs[1].credit_to_be_sent + d2h_data_outstanding_credits) > 'd64) && ((d2h_data_crdt_tbs[2].credit_to_be_sent + d2h_data_outstanding_credits) <= 'd64)) begin
        d2h_data_crdt_tbs[0].pending <= 'h1;
        d2h_data_crdt_tbs[1].pending <= 'h1;
        d2h_data_crdt_tbs[2].pending <= 'h1;
        d2h_data_crdt_tbs[0].credit_to_be_sent <= 'd64;
        d2h_data_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((s2m_drs_crdt_send > 0) && (lru == 0)) || (s2m_drs_crdt_send == 0))) begin
          d2h_data_crdt_tbs[0].credit_to_be_sent <= d2h_data_crdt_tbs[0].credit_to_be_sent + d2h_data_outstanding_credits - ((d2h_data_crdt_send == 'h7)? 'd64: (d2h_data_crdt_send == 'h6)? 'h32: (d2h_data_crdt_send == 'h5)? 'h16: (d2h_data_crdt_send == 'h4)? 'h8: (d2h_data_crdt_send == 'h3)? 'h4: d2h_data_crdt_send);
          if(s2m_drs_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          d2h_data_crdt_tbs[2].credit_to_be_sent <= d2h_data_crdt_tbs[2].credit_to_be_sent + d2h_data_outstanding_credits;
        end
      end else if(((d2h_data_crdt_tbs[2].credit_to_be_sent + d2h_data_outstanding_credits) > 'd64) && ((d2h_data_crdt_tbs[3].credit_to_be_sent + d2h_data_outstanding_credits) <= 'd64)) begin
        d2h_data_crdt_tbs[0].pending <= 'h1;
        d2h_data_crdt_tbs[1].pending <= 'h1;
        d2h_data_crdt_tbs[2].pending <= 'h1;
        d2h_data_crdt_tbs[3].pending <= 'h1;
        d2h_data_crdt_tbs[0].credit_to_be_sent <= 'd64;
        d2h_data_crdt_tbs[1].credit_to_be_sent <= 'd64;
        d2h_data_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((s2m_drs_crdt_send > 0) && (lru == 0)) || (s2m_drs_crdt_send == 0))) begin
          d2h_data_crdt_tbs[0].credit_to_be_sent <= d2h_data_crdt_tbs[0].credit_to_be_sent + d2h_data_outstanding_credits - ((d2h_data_crdt_send == 'h7)? 'd64: (d2h_data_crdt_send == 'h6)? 'h32: (d2h_data_crdt_send == 'h5)? 'h16: (d2h_data_crdt_send == 'h4)? 'h8: (d2h_data_crdt_send == 'h3)? 'h4: d2h_data_crdt_send);
          if(s2m_drs_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          d2h_data_crdt_tbs[3].credit_to_be_sent <= d2h_data_crdt_tbs[3].credit_to_be_sent + d2h_data_outstanding_credits;
        end
      end
      if((s2m_ndr_crdt_tbs[0].credit_to_be_sent + s2m_ndr_outstanding_credits) <= 'd64) begin
        s2m_ndr_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((d2h_rsp_crdt_send > 0) && (lru == 1)) || (d2h_rsp_crdt_send == 0))) begin
          s2m_ndr_crdt_tbs[0].credit_to_be_sent <= s2m_ndr_crdt_tbs[0].credit_to_be_sent + s2m_ndr_outstanding_credits - ((s2m_ndr_crdt_send == 'h7)? 'd64: (s2m_ndr_crdt_send == 'h6)? 'h32: (s2m_ndr_crdt_send == 'h5)? 'h16: (s2m_ndr_crdt_send == 'h4)? 'h8: (s2m_ndr_crdt_send == 'h3)? 'h4: s2m_ndr_crdt_send);
          if(d2h_rsp_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          s2m_ndr_crdt_tbs[0].credit_to_be_sent <= s2m_ndr_crdt_tbs[0].credit_to_be_sent + s2m_ndr_outstanding_credits;
        end
      end else if(((s2m_ndr_crdt_tbs[0].credit_to_be_sent + s2m_ndr_outstanding_credits) > 'd64) && ((s2m_ndr_crdt_tbs[1].credit_to_be_sent + s2m_ndr_outstanding_credits) <= 'd64)) begin
        s2m_ndr_crdt_tbs[0].pending <= 'h1;
        s2m_ndr_crdt_tbs[1].pending <= 'h1;
        s2m_ndr_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((d2h_rsp_crdt_send > 0) && (lru == 1)) || (d2h_rsp_crdt_send == 0))) begin
          s2m_ndr_crdt_tbs[0].credit_to_be_sent <= s2m_ndr_crdt_tbs[0].credit_to_be_sent + s2m_ndr_outstanding_credits - ((s2m_ndr_crdt_send == 'h7)? 'd64: (s2m_ndr_crdt_send == 'h6)? 'h32: (s2m_ndr_crdt_send == 'h5)? 'h16: (s2m_ndr_crdt_send == 'h4)? 'h8: (s2m_ndr_crdt_send == 'h3)? 'h4: s2m_ndr_crdt_send);
          if(d2h_rsp_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          s2m_ndr_crdt_tbs[1].credit_to_be_sent <= s2m_ndr_crdt_tbs[1].credit_to_be_sent + s2m_ndr_outstanding_credits;
        end
      end else if(((s2m_ndr_crdt_tbs[1].credit_to_be_sent + s2m_ndr_outstanding_credits) > 'd64) && ((s2m_ndr_crdt_tbs[2].credit_to_be_sent + s2m_ndr_outstanding_credits) <= 'd64)) begin
        s2m_ndr_crdt_tbs[0].pending <= 'h1;
        s2m_ndr_crdt_tbs[1].pending <= 'h1;
        s2m_ndr_crdt_tbs[2].pending <= 'h1;
        s2m_ndr_crdt_tbs[0].credit_to_be_sent <= 'd64;
        s2m_ndr_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((d2h_rsp_crdt_send > 0) && (lru == 1)) || (d2h_rsp_crdt_send == 0))) begin
          s2m_ndr_crdt_tbs[0].credit_to_be_sent <= s2m_ndr_crdt_tbs[0].credit_to_be_sent + s2m_ndr_outstanding_credits - ((s2m_ndr_crdt_send == 'h7)? 'd64: (s2m_ndr_crdt_send == 'h6)? 'h32: (s2m_ndr_crdt_send == 'h5)? 'h16: (s2m_ndr_crdt_send == 'h4)? 'h8: (s2m_ndr_crdt_send == 'h3)? 'h4: s2m_ndr_crdt_send);
          if(d2h_rsp_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          s2m_ndr_crdt_tbs[2].credit_to_be_sent <= s2m_ndr_crdt_tbs[2].credit_to_be_sent + s2m_ndr_outstanding_credits;
        end
      end else if(((s2m_ndr_crdt_tbs[2].credit_to_be_sent + s2m_ndr_outstanding_credits) > 'd64) && ((s2m_ndr_crdt_tbs[3].credit_to_be_sent + s2m_ndr_outstanding_credits) <= 'd64)) begin
        s2m_ndr_crdt_tbs[0].pending <= 'h1;
        s2m_ndr_crdt_tbs[1].pending <= 'h1;
        s2m_ndr_crdt_tbs[2].pending <= 'h1;
        s2m_ndr_crdt_tbs[3].pending <= 'h1;
        s2m_ndr_crdt_tbs[0].credit_to_be_sent <= 'd64;
        s2m_ndr_crdt_tbs[1].credit_to_be_sent <= 'd64;
        s2m_ndr_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((d2h_rsp_crdt_send > 0) && (lru == 1)) || (d2h_rsp_crdt_send == 0))) begin
          s2m_ndr_crdt_tbs[0].credit_to_be_sent <= s2m_ndr_crdt_tbs[0].credit_to_be_sent + s2m_ndr_outstanding_credits - ((s2m_ndr_crdt_send == 'h7)? 'd64: (s2m_ndr_crdt_send == 'h6)? 'h32: (s2m_ndr_crdt_send == 'h5)? 'h16: (s2m_ndr_crdt_send == 'h4)? 'h8: (s2m_ndr_crdt_send == 'h3)? 'h4: s2m_ndr_crdt_send);
          if(d2h_rsp_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          s2m_ndr_crdt_tbs[3].credit_to_be_sent <= s2m_ndr_crdt_tbs[3].credit_to_be_sent + s2m_ndr_outstanding_credits;
        end
      end
      if((s2m_drs_crdt_tbs[0].credit_to_be_sent + s2m_drs_outstanding_credits) <= 'd64) begin
        s2m_drs_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((d2h_data_crdt_send > 0) && (lru == 1)) || (d2h_data_crdt_send == 0))) begin
          s2m_drs_crdt_tbs[0].credit_to_be_sent <= s2m_drs_crdt_tbs[0].credit_to_be_sent + s2m_drs_outstanding_credits - ((s2m_drs_crdt_send == 'h7)? 'd64: (s2m_drs_crdt_send == 'h6)? 'h32: (s2m_drs_crdt_send == 'h5)? 'h16: (s2m_drs_crdt_send == 'h4)? 'h8: (s2m_drs_crdt_send == 'h3)? 'h4: s2m_drs_crdt_send);
          if(d2h_data_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          s2m_drs_crdt_tbs[0].credit_to_be_sent <= s2m_drs_crdt_tbs[0].credit_to_be_sent + s2m_drs_outstanding_credits;
        end
      end else if(((s2m_drs_crdt_tbs[0].credit_to_be_sent + s2m_drs_outstanding_credits) > 'd64) && ((s2m_drs_crdt_tbs[1].credit_to_be_sent + s2m_drs_outstanding_credits) <= 'd64)) begin
        s2m_drs_crdt_tbs[0].pending <= 'h1;
        s2m_drs_crdt_tbs[1].pending <= 'h1;
        s2m_drs_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((d2h_data_crdt_send > 0) && (lru == 1)) || (d2h_data_crdt_send == 0))) begin
          s2m_drs_crdt_tbs[0].credit_to_be_sent <= s2m_drs_crdt_tbs[0].credit_to_be_sent + s2m_drs_outstanding_credits - ((s2m_drs_crdt_send == 'h7)? 'd64: (s2m_drs_crdt_send == 'h6)? 'h32: (s2m_drs_crdt_send == 'h5)? 'h16: (s2m_drs_crdt_send == 'h4)? 'h8: (s2m_drs_crdt_send == 'h3)? 'h4: s2m_drs_crdt_send);
          if(d2h_data_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          s2m_drs_crdt_tbs[1].credit_to_be_sent <= s2m_drs_crdt_tbs[1].credit_to_be_sent + s2m_drs_outstanding_credits;
        end
      end else if(((s2m_drs_crdt_tbs[1].credit_to_be_sent + s2m_drs_outstanding_credits) > 'd64) && ((s2m_drs_crdt_tbs[2].credit_to_be_sent + s2m_drs_outstanding_credits) <= 'd64)) begin
        s2m_drs_crdt_tbs[0].pending <= 'h1;
        s2m_drs_crdt_tbs[1].pending <= 'h1;
        s2m_drs_crdt_tbs[2].pending <= 'h1;
        s2m_drs_crdt_tbs[0].credit_to_be_sent <= 'd64;
        s2m_drs_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((d2h_data_crdt_send > 0) && (lru == 1)) || (d2h_data_crdt_send == 0))) begin
          s2m_drs_crdt_tbs[0].credit_to_be_sent <= s2m_drs_crdt_tbs[0].credit_to_be_sent + s2m_drs_outstanding_credits - ((s2m_drs_crdt_send == 'h7)? 'd64: (s2m_drs_crdt_send == 'h6)? 'h32: (s2m_drs_crdt_send == 'h5)? 'h16: (s2m_drs_crdt_send == 'h4)? 'h8: (s2m_drs_crdt_send == 'h3)? 'h4: s2m_drs_crdt_send);
          if(d2h_data_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          s2m_drs_crdt_tbs[2].credit_to_be_sent <= s2m_drs_crdt_tbs[2].credit_to_be_sent + s2m_drs_outstanding_credits;
        end
      end else if(((s2m_drs_crdt_tbs[2].credit_to_be_sent + s2m_drs_outstanding_credits) > 'd64) && ((s2m_drs_crdt_tbs[3].credit_to_be_sent + s2m_drs_outstanding_credits) <= 'd64)) begin
        s2m_drs_crdt_tbs[0].pending <= 'h1;
        s2m_drs_crdt_tbs[1].pending <= 'h1;
        s2m_drs_crdt_tbs[2].pending <= 'h1;
        s2m_drs_crdt_tbs[3].pending <= 'h1;
        s2m_drs_crdt_tbs[0].credit_to_be_sent <= 'd64;
        s2m_drs_crdt_tbs[1].credit_to_be_sent <= 'd64;
        s2m_drs_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((d2h_data_crdt_send > 0) && (lru == 1)) || (d2h_data_crdt_send == 0))) begin
          s2m_drs_crdt_tbs[0].credit_to_be_sent <= s2m_drs_crdt_tbs[0].credit_to_be_sent + s2m_drs_outstanding_credits - ((s2m_drs_crdt_send == 'h7)? 'd64: (s2m_drs_crdt_send == 'h6)? 'h32: (s2m_drs_crdt_send == 'h5)? 'h16: (s2m_drs_crdt_send == 'h4)? 'h8: (s2m_drs_crdt_send == 'h3)? 'h4: s2m_drs_crdt_send);
          if(d2h_data_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          s2m_drs_crdt_tbs[3].credit_to_be_sent <= s2m_drs_crdt_tbs[3].credit_to_be_sent + s2m_drs_outstanding_credits;
        end
      end
    end
  end

  //TODO: serious missing piece is if roll over cnt exceeds then packing of further data should be avoided
  //ll pkt buffer
  always@(posedge host_tx_dl_if.clk) begin
    if(!host_tx_dl_if.rstn) begin
      slot_sel <= H_SLOT0;
      slot_sel_d <= H_SLOT0;
      holding_wrptr <= 'h0;
      data_slot_d[0] <= 'h0;
      data_slot_d[1] <= 'h0;
      data_slot_d[2] <= 'h0;
      data_slot_d[3] <= 'h0;
      data_slot_d[4] <= 'h0;
    end else begin
      h_gnt_d <= h_gnt;
      g_gnt_d <= g_gnt;
      slot_sel_d <= slot_sel;
      data_slot_d[0] <= data_slot[0];
      data_slot_d[1] <= data_slot[1];
      data_slot_d[2] <= data_slot[2];
      data_slot_d[3] <= data_slot[3];
      data_slot_d[4] <= data_slot[4];
      if(data_slot[1] == 'hf) begin
        data_slot[0] <= data_slot[1];
        data_slot[1] <= data_slot[2];
        data_slot[2] <= data_slot[3];
        data_slot[3] <= data_slot[4];
        data_slot[4] <= 'h0;
      end
      case(slot_sel)
        H_SLOT0: begin
          if(h_gnt == 0) begin
            slot_sel <= H_SLOT0;
          end else begin
            if((h_gnt[0]) || (h_gnt[5])) begin
              if((data_slot[0] == 'h0) /*|| (data_slot[0] == 'hf)*/) begin //TODO: I doubt you would get data_slot as 'hf
                slot_sel <= G_SLOT1;
              end else if(data_slot[0] == 'h2) begin
                slot_sel <= G_SLOT2;
              end else if(data_slot[0] == 'h6) begin
                slot_sel <= G_SLOT3;
              end else if(data_slot[0] == 'he) begin
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
              end
            end else if(h_gnt[1] || h_gnt[2] || h_gnt[4]) begin
              slot_sel <= H_SLOT0;
              if((data_slot[0] == 'h0) /*|| (data_slot[0] == 'hf)*/) begin //TODO: I doubt you would get data_slot as 'hf
                data_slot[0] <= 'he; data_slot[1] <= 'h2; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'h2) begin
                data_slot[0] <= 'he; data_slot[1] <= 'h6; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'h6) begin
                data_slot[0] <= 'he; data_slot[1] <= 'he; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'he) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else begin
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(h_gnt[3]) begin
              slot_sel <= H_SLOT0;
              if((data_slot[0] == 'h0) /*|| (data_slot[0] == 'hf)*/) begin //TODO: I doubt you would get data_slot as 'hf
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'h2;
              end else if(data_slot[0] == 'h2) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'h6;
              end else if(data_slot[0] == 'h6) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'he;
              end else if(data_slot[0] == 'he) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'hf;
              end else begin
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end
          end
        end
        G_SLOT1: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT1;
          end else if(g_gnt[0]) begin
            slot_sel <= XSLOT;
          end else begin
            if((g_gnt[1])) begin
              if(data_slot[0] == 'h0) begin
                slot_sel <= G_SLOT2;
              end else begin
                slot_sel <= XSLOT;
              end
            end else if((g_gnt[2]) || (g_gnt[4]) || (g_gnt[5])) begin
              if(data_slot[0] == 'h0) begin
                slot_sel <= H_SLOT0;
                data_slot[0] <= 'hc; data_slot[1] <= 'h6; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else begin
                slot_sel <= XSLOT;
              end
            end else if(g_gnt[3]) begin
              if(data_slot[0] == 'h0) begin
                slot_sel <= H_SLOT0;
                data_slot[0] <= 'hc; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'h6;
              end else begin
                slot_sel <= XSLOT;
              end
            end
          end
        end
        G_SLOT2: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT2;
          end else if(g_gnt[0]) begin
            slot_sel <= XSLOT;
          end else begin
            if((g_gnt[1])) begin
              if((data_slot[0] == 'h0) || (data_slot[0] == 'h2)) begin
                slot_sel <= G_SLOT3;
              end else begin
                slot_sel <= XSLOT;
              end
            end else if((g_gnt[2]) || (g_gnt[4]) || (g_gnt[5])) begin
              if((data_slot[0] == 'h0) || (data_slot[0] == 'h2)) begin
                slot_sel <= H_SLOT0;
                data_slot[0] <= ((data_slot[0] == 'h2)? 'ha: 'h8); data_slot[1] <= 'he; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else begin
                slot_sel <= XSLOT;
              end
            end else if(g_gnt[3]) begin
              if((data_slot[0] == 'h0) || (data_slot[0] == 'h2)) begin
                slot_sel <= H_SLOT0;
                data_slot[0] <=  ((data_slot[0] == 'h2)? 'ha: 'h8); data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'he;
              end else begin
                slot_sel <= XSLOT;
              end
            end
          end
        end
        G_SLOT3: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT3;
          end else if(g_gnt[0]) begin
            slot_sel <= XSLOT;
          end else begin
            if((g_gnt[1])) begin
              if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
              end
            end else if((g_gnt[2]) || (g_gnt[4]) || (g_gnt[5])) begin
              if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                slot_sel <= H_SLOT0;
            /*data_slot[0] <= 'h6;*/ data_slot[1] <= 'hf; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else begin
                slot_sel <= XSLOT;
              end
            end else if(g_gnt[3]) begin
              if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                slot_sel <= H_SLOT0;
            /*data_slot[0] <= 'h6;*/ data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'hf;
              end else begin
                slot_sel <= XSLOT;
              end
            end
          end
        end
        default: begin
            slot_sel <= XSLOT;
        end 
      endcase
     //TODO: bug/major flaw in packing logic after data slot ends in slot0/1/2 then slots123/23/3 should not be packed currently you are just sending available pkts into these slots without header slot entry so receiver cannot decode these generic slots  
      if(slot_sel_d != slot_sel) begin
        case(slot_sel)
          H_SLOT0: begin
            case(h_gnt)
              'h1: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= ((ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0);//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h0;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (lru))? ({1'h1, s2m_ndr_crdt_send[2:0]}): ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (!lru))? ({1'h0, d2h_rsp_crdt_send[2:0]}): (s2m_ndr_crdt_send > 0)? ({1'h1, s2m_ndr_crdt_send[2:0]}): (d2h_rsp_crdt_send > 0)? ({1'h0, d2h_rsp_crdt_send[2:0]}): 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= d2h_req_crdt_send;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (lru))? ({1'h1, s2m_drs_crdt_send[2:0]}): ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (!lru))? ({1'h0, d2h_data_crdt_send[2:0]}): (s2m_drs_crdt_send > 0)? ({1'h1, s2m_drs_crdt_send[2:0]}): (d2h_data_crdt_send > 0)? ({1'h0, d2h_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
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
                if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid        <= 'h1;
                  holding_wrptr                         <= holding_wrptr + 1;
                end else begin
                  holding_q[holding_wrptr].valid        <= 'h0;
                end
              end
              'h2: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= ((ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0);//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h1;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (lru))? ({1'h1, s2m_ndr_crdt_send[2:0]}): ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (!lru))? ({1'h0, d2h_rsp_crdt_send[2:0]}): (s2m_ndr_crdt_send > 0)? ({1'h1, s2m_ndr_crdt_send[2:0]}): (d2h_rsp_crdt_send > 0)? ({1'h0, d2h_rsp_crdt_send[2:0]}): 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= d2h_req_crdt_send;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (lru))? ({1'h1, s2m_drs_crdt_send[2:0]}): ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (!lru))? ({1'h0, d2h_data_crdt_send[2:0]}): (s2m_drs_crdt_send > 0)? ({1'h1, s2m_drs_crdt_send[2:0]}): (d2h_data_crdt_send > 0)? ({1'h0, d2h_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[32]       <= h2d_data_dataout.valid;
                holding_q[holding_wrptr].data[44:33]    <= h2d_data_dataout.cqid;
                holding_q[holding_wrptr].data[45]       <= h2d_data_dataout.chunkvalid;
                holding_q[holding_wrptr].data[46]       <= h2d_data_dataout.poison;
                holding_q[holding_wrptr].data[47]       <= h2d_data_dataout.goerr;
                holding_q[holding_wrptr].data[54:48]    <= 'h0;//TBD:says pre but I do not see any pre in h2d_data
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
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:128]  <= h2d_data_dataout.data[383:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[255:128]<= h2d_data_dataout.data[511:384];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]  <= h2d_data_dataout.data[255:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[383:128]<= h2d_data_dataout.data[511:256];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]  <= h2d_data_dataout.data[127:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:128]<= h2d_data_dataout.data[511:128];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]  <= h2d_data_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end
              end
              'h4: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= ((ack_cnt_snt)? 'h1: 'h0);//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h2;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (lru))? ({1'h1, s2m_ndr_crdt_send[2:0]}): ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (!lru))? ({1'h0, d2h_rsp_crdt_send[2:0]}): (s2m_ndr_crdt_send > 0)? ({1'h1, s2m_ndr_crdt_send[2:0]}): (d2h_rsp_crdt_send > 0)? ({1'h0, d2h_rsp_crdt_send[2:0]}): 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= d2h_req_crdt_send;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (lru))? ({1'h1, s2m_drs_crdt_send[2:0]}): ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (!lru))? ({1'h0, d2h_data_crdt_send[2:0]}): (s2m_drs_crdt_send > 0)? ({1'h1, s2m_drs_crdt_send[2:0]}): (d2h_data_crdt_send > 0)? ({1'h0, d2h_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
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
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:128]  <= h2d_data_dataout.data[383:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[255:128]<= h2d_data_dataout.data[511:384];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]  <= h2d_data_dataout.data[255:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[383:128]<= h2d_data_dataout.data[511:256];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]  <= h2d_data_dataout.data[127:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:128]<= h2d_data_dataout.data[511:128];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]  <= h2d_data_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end
              end
              'h8: begin
                holding_q[holding_wrptr].data[0]         <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]         <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]         <= ((ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0);//TBD: logic for crdt ack to be added later
                ack_cnt_snt                              <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]         <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]         <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]       <= 'h3;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]      <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]     <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]     <= ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (lru))? ({1'h1, s2m_ndr_crdt_send[2:0]}): ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (!lru))? ({1'h0, d2h_rsp_crdt_send[2:0]}): (s2m_ndr_crdt_send > 0)? ({1'h1, s2m_ndr_crdt_send[2:0]}): (d2h_rsp_crdt_send > 0)? ({1'h0, d2h_rsp_crdt_send[2:0]}): 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]     <= d2h_req_crdt_send;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]     <= ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (lru))? ({1'h1, s2m_drs_crdt_send[2:0]}): ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (!lru))? ({1'h0, d2h_data_crdt_send[2:0]}): (s2m_drs_crdt_send > 0)? ({1'h1, s2m_drs_crdt_send[2:0]}): (d2h_data_crdt_send > 0)? ({1'h0, d2h_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
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
                if(data_slot[0] == 'h0) begin
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
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]   <= h2d_data_dataout.data[255:0];
                  holding_q[holding_wrptr].valid           <= 'h1;
                  holding_q[holding_wrptr+1].data[255:0]   <= h2d_data_dataout.data[511:256];
                  holding_q[holding_wrptr+1].data[511:256] <= h2d_data_ddataout.data[255:0];
                  holding_q[holding_wrptr+1].valid         <= 'h1;
                  holding_q[holding_wrptr+2].data[255:0]   <= h2d_data_ddataout.data[511:256];
                  holding_q[holding_wrptr+2].data[511:256] <= h2d_data_tdataout.data[255:0];
                  holding_q[holding_wrptr+2].valid         <= 'h1;
                  holding_q[holding_wrptr+3].data[255:0]   <= h2d_data_tdataout.data[511:256];
                  holding_q[holding_wrptr+3].data[511:256] <= h2d_data_qdataout.data[255:0];
                  holding_q[holding_wrptr+3].valid         <= 'h1;
                  holding_q[holding_wrptr+4].data[255:128]   <= h2d_data_qdataout.data[511:256];
                  holding_q[holding_wrptr+4].valid         <= 'h0;
                  holding_wrptr                            <= holding_wrptr + 4;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]   <= h2d_data_dataout.data[127:0];
                  holding_q[holding_wrptr].valid           <= 'h1;
                  holding_q[holding_wrptr+1].data[383:0]   <= h2d_data_dataout.data[511:128];
                  holding_q[holding_wrptr+1].data[511:384] <= h2d_data_ddataout.data[127:0];
                  holding_q[holding_wrptr+1].valid         <= 'h1;
                  holding_q[holding_wrptr+2].data[383:0]   <= h2d_data_ddataout.data[511:128];
                  holding_q[holding_wrptr+2].data[511:384] <= h2d_data_tdataout.data[127:0];
                  holding_q[holding_wrptr+2].valid         <= 'h1;
                  holding_q[holding_wrptr+3].data[383:0]   <= h2d_data_tdataout.data[511:128];
                  holding_q[holding_wrptr+3].data[511:384] <= h2d_data_qdataout.data[127:0];
                  holding_q[holding_wrptr+3].valid         <= 'h1;
                  holding_q[holding_wrptr+4].data[511:128]   <= h2d_data_qdataout.data[511:128];
                  holding_q[holding_wrptr+4].valid         <= 'h0;
                  holding_wrptr                            <= holding_wrptr + 4;
                end else if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid           <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]   <= h2d_data_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid         <= 'h1;
                  holding_q[holding_wrptr+2].data[511:0]   <= h2d_data_ddataout.data[511:0];
                  holding_q[holding_wrptr+2].valid         <= 'h1;
                  holding_q[holding_wrptr+3].data[511:0]   <= h2d_data_tdataout.data[511:0];
                  holding_q[holding_wrptr+3].valid         <= 'h1;
                  holding_q[holding_wrptr+4].data[511:0]   <= h2d_data_qdataout.data[511:0];
                  holding_q[holding_wrptr+4].valid         <= 'h1;
                  holding_wrptr                            <= holding_wrptr + 5;
                  holding_q[holding_wrptr+5].valid         <= 'h0;
                end
              end
              'h16: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= (ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0;//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h4;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (lru))? ({1'h1, s2m_ndr_crdt_send[2:0]}): ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (!lru))? ({1'h0, d2h_rsp_crdt_send[2:0]}): (s2m_ndr_crdt_send > 0)? ({1'h1, s2m_ndr_crdt_send[2:0]}): (d2h_rsp_crdt_send > 0)? ({1'h0, d2h_rsp_crdt_send[2:0]}): 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= d2h_req_crdt_send;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (lru))? ({1'h1, s2m_drs_crdt_send[2:0]}): ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (!lru))? ({1'h0, d2h_data_crdt_send[2:0]}): (s2m_drs_crdt_send > 0)? ({1'h1, s2m_drs_crdt_send[2:0]}): (d2h_data_crdt_send > 0)? ({1'h0, d2h_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
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
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:128]  <= m2s_rwd_dataout.data[383:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[127:0]  <= m2s_rwd_dataout.data[511:384];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]  <= m2s_rwd_dataout.data[255:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[255:0]  <= m2s_rwd_dataout.data[511:256];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]  <= m2s_rwd_dataout.data[127:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:128]<= m2s_rwd_dataout.data[511:128];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 1;
                end else if(data_slot[0] =='he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]  <= m2s_rwd_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end
              end
              'h32: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= (ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0;//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h5;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (lru))? ({1'h1, s2m_ndr_crdt_send[2:0]}): ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (!lru))? ({1'h0, d2h_rsp_crdt_send[2:0]}): (s2m_ndr_crdt_send > 0)? ({1'h1, s2m_ndr_crdt_send[2:0]}): (d2h_rsp_crdt_send > 0)? ({1'h0, d2h_rsp_crdt_send[2:0]}): 'h0;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= d2h_req_crdt_send;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (lru))? ({1'h1, s2m_drs_crdt_send[2:0]}): ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (!lru))? ({1'h0, d2h_data_crdt_send[2:0]}): (s2m_drs_crdt_send > 0)? ({1'h1, s2m_drs_crdt_send[2:0]}): (d2h_data_crdt_send > 0)? ({1'h0, d2h_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
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
                if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else begin
                  holding_q[holding_wrptr].valid          <= 'h0;
                end
              end
              default: begin //TBD: do you want to keeep default to assign data pkt or want some other value
                holding_q[holding_wrptr].valid          <= 'h0;
              end
            endcase
          end
          G_SLOT1: begin
            case(g_gnt)
              'h2: begin
                holding_q[holding_wrptr].data[10:8]                                   <= 'h1;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr].data[10:8]                                   <= 'h2;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr+1].data[383:128]                              <= h2d_data_dataout.data[511:256];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h8: begin
                holding_q[holding_wrptr].data[10:8]                                   <= 'h3;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr+4].data[383:128]                              <= h2d_data_qdataout.data[511:256];
                holding_q[holding_wrptr+4].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 4;
              end
              'h16: begin
                holding_q[holding_wrptr].data[10:8]     <= 'h4;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr+1].data[383:128]                              <= h2d_data_dataout.data[511:256];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h32: begin
                holding_q[holding_wrptr].data[10:8]     <= 'h5;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr+1].data[383:128]                              <= m2s_rwd_dataout.data[511:256];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
          G_SLOT2: begin
            case(g_gnt)
              'h2: begin
                holding_q[holding_wrptr].data[13:11]    <= 'h1;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr].data[13:11]    <= 'h2;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= h2d_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]      <= h2d_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+49):(SLOT2_OFFSET+4)]     <= h2d_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+61):(SLOT2_OFFSET+50)]    <= h2d_req_dataout.uqid;
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
                holding_q[holding_wrptr+1].data[511:128]                              <= h2d_data_dataout.data[511:128];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h8: begin
                holding_q[holding_wrptr].data[13:11]    <= 'h3;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr+4].data[511:128]                              <= h2d_data_qdataout.data[511:128];
                holding_q[holding_wrptr+4].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 4;
              end
              'h16: begin
                holding_q[holding_wrptr].data[13:11]    <= 'h4;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr+1].data[511:128]                              <= h2d_data_dataout.data[511:128];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              'h32: begin
                holding_q[holding_wrptr].data[13:11]    <= 'h5;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr+1].data[511:128]                              <= m2s_rwd_dataout.data[511:128];
                holding_q[holding_wrptr+1].valid                                      <= 'h0;
                holding_wrptr                                                         <= holding_wrptr + 1;
              end
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
          G_SLOT3: begin
            case(g_gnt)
              'h2: begin
                holding_q[holding_wrptr].data[16:14]    <= 'h1;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr].data[16:14]    <= 'h2;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= h2d_req_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]      <= h2d_req_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+49):(SLOT3_OFFSET+4)]     <= h2d_req_dataout.address[51:6];
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+61):(SLOT3_OFFSET+50)]    <= h2d_req_dataout.uqid;
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
                holding_q[holding_wrptr].data[16:14]    <= 'h3;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr].data[16:14]    <= 'h4;//this field will be reupdated after g slot is selected
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
                holding_q[holding_wrptr].data[16:14]    <= 'h5;//this field will be reupdated after g slot is selected
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
      host_tx_dl_if_pre_valid <= 'h0;
      host_tx_dl_if_pre_data <= 'h0;
      host_tx_dl_if.valid <= 'h0;
      host_tx_dl_if_d.valid <= 'h0;
      host_tx_dl_if.data <= 'h0;
      host_tx_dl_if_d.data <= 'h0;
      holding_rdptr <= 'h0;
      ack_cnt_tbs <= 'h0;
      ack_cnt_snt <= 'h0;
    end else begin
      host_tx_dl_if_d <= host_tx_dl_if;
      host_tx_dl_if.valid <= host_tx_dl_if_pre_valid;
      host_tx_dl_if.data <= {host_tx_dl_if_pre_data[511:0], host_tx_dl_if_pre_crc[15:0]};
      if(ack) begin
        ack_cnt_tbs <= ack_cnt_tbs + 1;
      end
      if(holding_q[holding_rdptr].valid) begin
        host_tx_dl_if_pre_valid <= holding_q[holding_rdptr].valid;
        host_tx_dl_if_pre_data <= holding_q[holding_rdptr].data;
        holding_rdptr <= holding_rdptr + 1;
      end else begin//TODO: this is wrong this is operating on a different clock and I am unsure need to analyze more if there is any cdc issues
        if((host_tx_dl_if_d.rstn == 'h1) && (host_tx_dl_if.rstn == 'h0)) begin
          host_tx_dl_if_pre_valid          <= 'h1;
          host_tx_dl_if_pre_data[35:32]    <= 'b1100;
          host_tx_dl_if_pre_data[39:36]    <= 'b1000;
          host_tx_dl_if_pre_data[67:64]    <= 'h1;
        end
        if(insert_ack) begin
          host_tx_dl_if_pre_valid          <= 'h1;
          host_tx_dl_if_pre_data[0]        <= 'h1;//protocol flit encoding is 0 & for control type is 1
          host_tx_dl_if_pre_data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
          host_tx_dl_if_pre_data[2]        <= 'h1;//TBD: logic for crdt ack to be added later
          host_tx_dl_if_pre_data[3]        <= 'h0;//non data header so 0
          host_tx_dl_if_pre_data[4]        <= 'h0;//non data header so 0
          host_tx_dl_if_pre_data[7:5]      <= 'h0;//slot0 fmt is H0 so 0
          host_tx_dl_if_pre_data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
          host_tx_dl_if_pre_data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
          host_tx_dl_if_pre_data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
          host_tx_dl_if_pre_data[19:17]    <= 'h0;//reserved must be 0
          host_tx_dl_if_pre_data[23:20]    <= ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (lru))? ({1'h1, s2m_ndr_crdt_send[2:0]}): ((d2h_rsp_crdt_send > 0) && (s2m_ndr_crdt_send > 0) && (!lru))? ({1'h0, d2h_rsp_crdt_send[2:0]}): (s2m_ndr_crdt_send > 0)? ({1'h1, s2m_ndr_crdt_send[2:0]}): (d2h_rsp_crdt_send > 0)? ({1'h0, d2h_rsp_crdt_send[2:0]}): 'h0;//TBD: rsp crdt logic for crdt to be added later
          host_tx_dl_if_pre_data[27:24]    <= d2h_req_crdt_send;//TBD: req crdt logic for crdt to be added later
          host_tx_dl_if_pre_data[31:28]    <= ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (lru))? ({1'h1, s2m_drs_crdt_send[2:0]}): ((d2h_data_crdt_send > 0) && (s2m_drs_crdt_send > 0) && (!lru))? ({1'h0, d2h_data_crdt_send[2:0]}): (s2m_drs_crdt_send > 0)? ({1'h1, s2m_drs_crdt_send[2:0]}): (d2h_data_crdt_send > 0)? ({1'h0, d2h_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
          host_tx_dl_if_pre_data[35:32]    <= 4'b0000;
          host_tx_dl_if_pre_data[39:36]    <= 4'b0001;
          host_tx_dl_if_pre_data[63:40]    <= 'h0;
          host_tx_dl_if_pre_data[71:64]    <= ({ack_cnt_tbs[7:4], 1'b0, ack_cnt_tbs[2:0]});
          ack_cnt_snt                      <= ack_cnt_tbs;
        end else begin
          host_tx_dl_if_pre_valid          <= 'h0;
        end
      end
   end
  end

  crc_gen crc_gen_inst(
    .data(host_tx_dl_if_pre_data),
    .crc(host_tx_dl_if_pre_crc)
  );
/*
  buffer #(
    .DEPTH(256),
    .ADDR_WIDTH(8),
    .FIFO_DATA_TYPE(holding_q_t)
  ) llrb (
	  .clk(host_tx_dl_if.clk),
  	.rstn(host_tx_dl_if.rstn),
  	.rval(ack_ret_val),
    .ack_cnt(ack_ret),
  	.wval(host_tx_dl_if.valid),
    .datain(host_tx_dl_if.data),
  	.eseq,
  	.wptr()
  );
*/
  rra #(
   .NO_OF_REQ(6)
  ) h_slot_rra_inst (
    .clk(clk),
    .rstn(rstn),
    .req(h_req),
    .gnt(h_gnt)
  );

  rra #( 
   .NO_OF_REQ(6)
  ) g_slot_rra_inst (
    .clk(clk),
    .rstn(rstn),
    .req(g_req),
    .gnt(g_gnt)
  );

endmodule

module device_tx_path#(
  parameter BUFFER_DEPTH = 32,
  parameter BUFFER_ADDR_WIDTH = 5
)(
  input logic init_done,
  input logic ack,
  input logic ack_ret_val,
  input logic [7:0] ack_ret,
  input logic [BUFFER_ADDR_WIDTH-1:0] d2h_req_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] d2h_rsp_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] d2h_data_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] s2m_ndr_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] s2m_drs_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] h2d_req_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] h2d_rsp_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] h2d_data_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] m2s_req_occ,
  input logic [BUFFER_ADDR_WIDTH-1:0] m2s_rwd_occ,
  input logic [BUFFER_ADDR_WIDTH:0] h2d_req_wptr,
  input logic [BUFFER_ADDR_WIDTH:0] h2d_rsp_wptr,
  input logic [BUFFER_ADDR_WIDTH:0] h2d_data_wptr,
  input logic [BUFFER_ADDR_WIDTH:0] m2s_req_wptr,
  input logic [BUFFER_ADDR_WIDTH:0] m2s_rwd_wptr,
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
  localparam SLOT1_OFFSET = 128;
  localparam SLOT2_OFFSET = 256;
  localparam SLOT3_OFFSET = 384;
  logic [5:0] h_val;
  logic [5:0] h_req;
  logic [5:0] h_gnt;
  logic [5:0] h_gnt_d;
  logic [6:0] g_val;
  logic [6:0] g_req;
  logic [6:0] g_gnt;
  logic [6:0] g_gnt_d;
  typedef enum {
    XSLOT = 'h0,
    H_SLOT0 = 'h1,
    G_SLOT1 = 'h2,
    G_SLOT2 = 'h4,
    G_SLOT3 = 'h8
  } slot_sel_t;
  slot_sel_t slot_sel;
  slot_sel_t slot_sel_d;
  logic [7:0] holding_rdptr;
  logic [7:0] holding_wrptr;
  typedef struct {
    logic valid;
    logic [511:0] data;
  } holding_q_t;
  holding_q_t holding_q[256];
  logic lru;
  int h2d_req_outstanding_credits;
  int h2d_req_consumed_credits;
  int h2d_req_occ_d;
  int h2d_rsp_outstanding_credits;
  int h2d_rsp_consumed_credits;
  int h2d_rsp_occ_d;
  int h2d_data_outstanding_credits;
  int h2d_data_consumed_credits;
  int h2d_data_occ_d;
  int m2s_req_outstanding_credits;
  int m2s_req_consumed_credits;
  int m2s_req_occ_d;
  int m2s_rwd_outstanding_credits;
  int m2s_rwd_consumed_credits;
  int m2s_rwd_occ_d;
  typedef struct{
    bit pending;
    int credit_to_be_sent;
  } crdt_tbs_t;
  crdt_tbs_t h2d_req_crdt_tbs[4];
  crdt_tbs_t h2d_rsp_crdt_tbs[4];
  crdt_tbs_t h2d_data_crdt_tbs[4];
  crdt_tbs_t m2s_req_crdt_tbs[4];
  crdt_tbs_t m2s_rwd_crdt_tbs[4];
  logic [2:0] h2d_req_crdt_send;
  logic [2:0] h2d_rsp_crdt_send;
  logic [2:0] h2d_data_crdt_send;
  logic [2:0] m2s_req_crdt_send;
  logic [2:0] m2s_rwd_crdt_send;
  int ack_cnt_tbs;//ack count to be sent
  int ack_cnt_snt;//current ack count sent
  logic insert_ack;
  logic [3:0] data_slot[5];
  logic [3:0] data_slot_d[5];
  logic dev_tx_dl_if_pre_valid;
  logic [15:0] dev_tx_dl_if_pre_crc;
  logic [511:0] dev_tx_dl_if_pre_data;
  virtual cxl_dev_tx_dl_if dev_tx_dl_if_d;
//IMP INFO: consider m2s req as rsp credits and m2s rwd as data credits

  ASSERT_DEVSIDE_ONEHOT_SLOT_SEL: assert property (@(posedge dev_tx_dl_if.clk) disable iff (!dev_tx_dl_if.rstn) $onehot(slot_sel));

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

  assign d2h_data_rval  = (h_gnt[0] || h_gnt[1] || h_gnt[2] || g_gnt[2] || g_gnt[3])? 'h1: 'h0;
  assign d2h_rsp_rval   = (h_gnt[0] || h_gnt[2] || g_gnt[2])?                         'h1: 'h0;
  assign s2m_ndr_rval   = (h_gnt[0] || h_gnt[3] || h_gnt[4] || g_gnt[4] || g_gnt[5])? 'h1: 'h0;
  assign d2h_req_rval   = (h_gnt[1] || g_gnt[2])?                                     'h1: 'h0;
  assign d2h_data_drval = (h_gnt[2] || g_gnt[3])?                                     'h1: 'h0;
  assign d2h_data_trval = (h_gnt[2] || g_gnt[3])?                                     'h1: 'h0;
  assign d2h_data_qrval = (h_gnt[2] || g_gnt[3])?                                     'h1: 'h0;
  assign s2m_drs_rval   = (h_gnt[3] || h_gnt[5] || g_gnt[4] || g_gnt[6])?             'h1: 'h0;
  assign s2m_ndr_drval  = (h_gnt[4] || g_gnt[4] || g_gnt[5])?                         'h1: 'h0;
  assign s2m_drs_drval  = (h_gnt[5] || g_gnt[6])?                                     'h1: 'h0;
  assign s2m_ndr_trval  = (g_gnt[5])?                                                 'h1: 'h0;
  assign s2m_drs_trval  = (g_gnt[6])?                                                 'h1: 'h0;

  assign h_req = ((slot_sel>1) || (data_slot[0] == 'hf))? 'h0: h_val;
  assign g_req = ((slot_sel[0]) || (data_slot[0] == 'hf))? 'h0: g_val;
 
  assign insert_ack = (((ack_cnt_tbs - ack_cnt_snt) > 16) || init_done)? 1'h1: 1'h0;
  
  always_comb begin
    h2d_req_outstanding_credits   = (h2d_req_occ_d  > h2d_req_occ ) ? (h2d_req_occ_d  - h2d_req_occ   ) : 'h0;
    h2d_rsp_outstanding_credits   = (h2d_rsp_occ_d  > h2d_rsp_occ ) ? (h2d_rsp_occ_d  - h2d_rsp_occ   ) : 'h0;
    h2d_data_outstanding_credits  = (h2d_data_occ_d > h2d_data_occ) ? (h2d_data_occ_d - h2d_data_occ  ) : 'h0;
    m2s_req_outstanding_credits   = (m2s_req_occ_d  > m2s_req_occ ) ? (m2s_req_occ_d  - m2s_req_occ   ) : 'h0;
    m2s_rwd_outstanding_credits   = (m2s_rwd_occ_d  > m2s_rwd_occ ) ? (m2s_rwd_occ_d  - m2s_rwd_occ   ) : 'h0;
    h2d_req_consumed_credits      = (h2d_req_occ_d  < h2d_req_occ ) ? (h2d_req_occ    - h2d_req_occ_d ) : 'h0;
    h2d_rsp_consumed_credits      = (h2d_rsp_occ_d  < h2d_rsp_occ ) ? (h2d_rsp_occ    - h2d_rsp_occ_d ) : 'h0;
    h2d_data_consumed_credits     = (h2d_data_occ_d < h2d_data_occ) ? (h2d_data_occ   - h2d_data_occ_d) : 'h0;
    m2s_req_consumed_credits      = (m2s_req_occ_d  < m2s_req_occ ) ? (m2s_req_occ    - m2s_req_occ_d ) : 'h0;
    m2s_rwd_consumed_credits      = (m2s_rwd_occ_d  < m2s_rwd_occ ) ? (m2s_rwd_occ    - m2s_rwd_occ_d ) : 'h0;
  
    if(h2d_data_crdt_tbs[3].pending) begin
      if(h2d_data_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        h2d_data_crdt_send = 'h7;
      end else if(h2d_data_crdt_tbs[3].credit_to_be_sent >= 'd32) begin
        h2d_data_crdt_send = 'h6;
      end else if(h2d_data_crdt_tbs[3].credit_to_be_sent >= 'd16) begin
        h2d_data_crdt_send = 'h5;
      end else if(h2d_data_crdt_tbs[3].credit_to_be_sent >= 'd8) begin
        h2d_data_crdt_send = 'h4;
      end else if(h2d_data_crdt_tbs[3].credit_to_be_sent >= 'd4) begin
        h2d_data_crdt_send = 'h3;
      end else if(h2d_data_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        h2d_data_crdt_send = 'h2;
      end else if(h2d_data_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        h2d_data_crdt_send = 'h1;
      end else begin
        if(h2d_data_crdt_tbs[2].pending) begin
          if(h2d_data_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            h2d_data_crdt_send = 'h7;
          end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
            h2d_data_crdt_send = 'h6;
          end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
            h2d_data_crdt_send = 'h5;
          end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
            h2d_data_crdt_send = 'h4;
          end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
            h2d_data_crdt_send = 'h3;
          end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            h2d_data_crdt_send = 'h2;
          end else if(h2d_data_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            h2d_data_crdt_send = 'h1;
          end else begin
            if(h2d_data_crdt_tbs[1].pending) begin
              if(h2d_data_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                h2d_data_crdt_send = 'h7;
              end else if(h2d_data_crdt_tbs[1].credit_to_be_sent >= 'd32) begin
                h2d_data_crdt_send = 'h6;
              end else if(h2d_data_crdt_tbs[1].credit_to_be_sent >= 'd16) begin
               h2d_data_crdt_send = 'h5;
              end else if(h2d_data_crdt_tbs[1].credit_to_be_sent >= 'd8) begin
                h2d_data_crdt_send = 'h4;
              end else if(h2d_data_crdt_tbs[1].credit_to_be_sent >= 'd4) begin
                h2d_data_crdt_send = 'h3;
              end else if(h2d_data_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                h2d_data_crdt_send = 'h2;
              end else if(h2d_data_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                h2d_data_crdt_send = 'h1;
              end else begin
                if(h2d_data_crdt_tbs[0].pending) begin
                  if(h2d_data_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    h2d_data_crdt_send = 'h7;
                  end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
                    h2d_data_crdt_send = 'h6;
                  end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
                    h2d_data_crdt_send = 'h5;
                  end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
                    h2d_data_crdt_send = 'h4;
                  end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
                    h2d_data_crdt_send = 'h3;
                  end else if(h2d_data_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    h2d_data_crdt_send = 'h2;
                  end else if(h2d_data_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    h2d_data_crdt_send = 'h1;
                  end else begin
                    h2d_data_crdt_send = 'h0;
                  end
                end else begin
                  h2d_data_crdt_send = 'h0;
                end
              end
            end else begin
              h2d_data_crdt_send = 'h0;
            end
          end
        end else begin
          h2d_data_crdt_send = 'h0;
        end
      end 
    end else begin
      h2d_data_crdt_send = 'h0;
    end

    if(h2d_rsp_crdt_tbs[3].pending) begin
      if(h2d_rsp_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        h2d_rsp_crdt_send = 'h7;
      end else if(h2d_rsp_crdt_tbs[3].credit_to_be_sent >= 'd32) begin
        h2d_rsp_crdt_send = 'h6;
      end else if(h2d_rsp_crdt_tbs[3].credit_to_be_sent >= 'd16) begin
        h2d_rsp_crdt_send = 'h5;
      end else if(h2d_rsp_crdt_tbs[3].credit_to_be_sent >= 'd8) begin
        h2d_rsp_crdt_send = 'h4;
      end else if(h2d_rsp_crdt_tbs[3].credit_to_be_sent >= 'd4) begin
        h2d_rsp_crdt_send = 'h3;
      end else if(h2d_rsp_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        h2d_rsp_crdt_send = 'h2;
      end else if(h2d_rsp_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        h2d_rsp_crdt_send = 'h1;
      end else begin
        if(h2d_rsp_crdt_tbs[2].pending) begin
          if(h2d_rsp_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            h2d_rsp_crdt_send = 'h7;
          end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
            h2d_rsp_crdt_send = 'h6;
          end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
            h2d_rsp_crdt_send = 'h5;
          end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
            h2d_rsp_crdt_send = 'h4;
          end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
            h2d_rsp_crdt_send = 'h3;
          end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            h2d_rsp_crdt_send = 'h2;
          end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            h2d_rsp_crdt_send = 'h1;
          end else begin
            if(h2d_rsp_crdt_tbs[1].pending) begin
              if(h2d_rsp_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                h2d_rsp_crdt_send = 'h7;
              end else if(h2d_rsp_crdt_tbs[1].credit_to_be_sent >= 'd32) begin
                h2d_rsp_crdt_send = 'h6;
              end else if(h2d_rsp_crdt_tbs[1].credit_to_be_sent >= 'd16) begin
               h2d_rsp_crdt_send = 'h5;
              end else if(h2d_rsp_crdt_tbs[1].credit_to_be_sent >= 'd8) begin
                h2d_rsp_crdt_send = 'h4;
              end else if(h2d_rsp_crdt_tbs[1].credit_to_be_sent >= 'd4) begin
                h2d_rsp_crdt_send = 'h3;
              end else if(h2d_rsp_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                h2d_rsp_crdt_send = 'h2;
              end else if(h2d_rsp_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                h2d_rsp_crdt_send = 'h1;
              end else begin
                if(h2d_rsp_crdt_tbs[0].pending) begin
                  if(h2d_rsp_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    h2d_rsp_crdt_send = 'h7;
                  end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
                    h2d_rsp_crdt_send = 'h6;
                  end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
                    h2d_rsp_crdt_send = 'h5;
                  end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
                    h2d_rsp_crdt_send = 'h4;
                  end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
                    h2d_rsp_crdt_send = 'h3;
                  end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    h2d_rsp_crdt_send = 'h2;
                  end else if(h2d_rsp_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    h2d_rsp_crdt_send = 'h1;
                  end else begin
                    h2d_rsp_crdt_send = 'h0;
                  end
                end else begin
                  h2d_rsp_crdt_send = 'h0;
                end
              end
            end else begin
              h2d_rsp_crdt_send = 'h0;
            end
          end
        end else begin
          h2d_rsp_crdt_send = 'h0;
        end
      end 
    end else begin
      h2d_rsp_crdt_send = 'h0;
    end

    if(h2d_req_crdt_tbs[3].pending) begin
      if(h2d_req_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        h2d_req_crdt_send = 'h7;
      end else if(h2d_req_crdt_tbs[3].credit_to_be_sent >= 'd32) begin
        h2d_req_crdt_send = 'h6;
      end else if(h2d_req_crdt_tbs[3].credit_to_be_sent >= 'd16) begin
        h2d_req_crdt_send = 'h5;
      end else if(h2d_req_crdt_tbs[3].credit_to_be_sent >= 'd8) begin
        h2d_req_crdt_send = 'h4;
      end else if(h2d_req_crdt_tbs[3].credit_to_be_sent >= 'd4) begin
        h2d_req_crdt_send = 'h3;
      end else if(h2d_req_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        h2d_req_crdt_send = 'h2;
      end else if(h2d_req_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        h2d_req_crdt_send = 'h1;
      end else begin
        if(h2d_req_crdt_tbs[2].pending) begin
          if(h2d_req_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            h2d_req_crdt_send = 'h7;
          end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
            h2d_req_crdt_send = 'h6;
          end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
            h2d_req_crdt_send = 'h5;
          end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
            h2d_req_crdt_send = 'h4;
          end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
            h2d_req_crdt_send = 'h3;
          end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            h2d_req_crdt_send = 'h2;
          end else if(h2d_req_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            h2d_req_crdt_send = 'h1;
          end else begin
            if(h2d_req_crdt_tbs[1].pending) begin
              if(h2d_req_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                h2d_req_crdt_send = 'h7;
              end else if(h2d_req_crdt_tbs[1].credit_to_be_sent >= 'd32) begin
                h2d_req_crdt_send = 'h6;
              end else if(h2d_req_crdt_tbs[1].credit_to_be_sent >= 'd16) begin
               h2d_req_crdt_send = 'h5;
              end else if(h2d_req_crdt_tbs[1].credit_to_be_sent >= 'd8) begin
                h2d_req_crdt_send = 'h4;
              end else if(h2d_req_crdt_tbs[1].credit_to_be_sent >= 'd4) begin
                h2d_req_crdt_send = 'h3;
              end else if(h2d_req_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                h2d_req_crdt_send = 'h2;
              end else if(h2d_req_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                h2d_req_crdt_send = 'h1;
              end else begin
                if(h2d_req_crdt_tbs[0].pending) begin
                  if(h2d_req_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    h2d_req_crdt_send = 'h7;
                  end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
                    h2d_req_crdt_send = 'h6;
                  end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
                    h2d_req_crdt_send = 'h5;
                  end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
                    h2d_req_crdt_send = 'h4;
                  end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
                    h2d_req_crdt_send = 'h3;
                  end else if(h2d_req_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    h2d_req_crdt_send = 'h2;
                  end else if(h2d_req_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    h2d_req_crdt_send = 'h1;
                  end else begin
                    h2d_req_crdt_send = 'h0;
                  end
                end else begin
                  h2d_req_crdt_send = 'h0;
                end
              end
            end else begin
              h2d_req_crdt_send = 'h0;
            end
          end
        end else begin
          h2d_req_crdt_send = 'h0;
        end
      end 
    end else begin
      h2d_req_crdt_send = 'h0;
    end

    if(m2s_req_crdt_tbs[3].pending) begin
      if(m2s_req_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        m2s_req_crdt_send = 'h7;
      end else if(m2s_req_crdt_tbs[3].credit_to_be_sent >= 'd32) begin
        m2s_req_crdt_send = 'h6;
      end else if(m2s_req_crdt_tbs[3].credit_to_be_sent >= 'd16) begin
        m2s_req_crdt_send = 'h5;
      end else if(m2s_req_crdt_tbs[3].credit_to_be_sent >= 'd8) begin
        m2s_req_crdt_send = 'h4;
      end else if(m2s_req_crdt_tbs[3].credit_to_be_sent >= 'd4) begin
        m2s_req_crdt_send = 'h3;
      end else if(m2s_req_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        m2s_req_crdt_send = 'h2;
      end else if(m2s_req_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        m2s_req_crdt_send = 'h1;
      end else begin
        if(m2s_req_crdt_tbs[2].pending) begin
          if(m2s_req_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            m2s_req_crdt_send = 'h7;
          end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
            m2s_req_crdt_send = 'h6;
          end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
            m2s_req_crdt_send = 'h5;
          end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
            m2s_req_crdt_send = 'h4;
          end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
            m2s_req_crdt_send = 'h3;
          end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            m2s_req_crdt_send = 'h2;
          end else if(m2s_req_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            m2s_req_crdt_send = 'h1;
          end else begin
            if(m2s_req_crdt_tbs[1].pending) begin
              if(m2s_req_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                m2s_req_crdt_send = 'h7;
              end else if(m2s_req_crdt_tbs[1].credit_to_be_sent >= 'd32) begin
                m2s_req_crdt_send = 'h6;
              end else if(m2s_req_crdt_tbs[1].credit_to_be_sent >= 'd16) begin
               m2s_req_crdt_send = 'h5;
              end else if(m2s_req_crdt_tbs[1].credit_to_be_sent >= 'd8) begin
                m2s_req_crdt_send = 'h4;
              end else if(m2s_req_crdt_tbs[1].credit_to_be_sent >= 'd4) begin
                m2s_req_crdt_send = 'h3;
              end else if(m2s_req_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                m2s_req_crdt_send = 'h2;
              end else if(m2s_req_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                m2s_req_crdt_send = 'h1;
              end else begin
                if(m2s_req_crdt_tbs[0].pending) begin
                  if(m2s_req_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    m2s_req_crdt_send = 'h7;
                  end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
                    m2s_req_crdt_send = 'h6;
                  end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
                    m2s_req_crdt_send = 'h5;
                  end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
                    m2s_req_crdt_send = 'h4;
                  end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
                    m2s_req_crdt_send = 'h3;
                  end else if(m2s_req_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    m2s_req_crdt_send = 'h2;
                  end else if(m2s_req_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    m2s_req_crdt_send = 'h1;
                  end else begin
                    m2s_req_crdt_send = 'h0;
                  end
                end else begin
                  m2s_req_crdt_send = 'h0;
                end
              end
            end else begin
              m2s_req_crdt_send = 'h0;
            end
          end
        end else begin
          m2s_req_crdt_send = 'h0;
        end
      end 
    end else begin
      m2s_req_crdt_send = 'h0;
    end
 
    if(m2s_rwd_crdt_tbs[3].pending) begin
      if(m2s_rwd_crdt_tbs[3].credit_to_be_sent == 'd64) begin
        m2s_rwd_crdt_send = 'h7;
      end else if(m2s_rwd_crdt_tbs[3].credit_to_be_sent >= 'd32) begin
        m2s_rwd_crdt_send = 'h6;
      end else if(m2s_rwd_crdt_tbs[3].credit_to_be_sent >= 'd16) begin
        m2s_rwd_crdt_send = 'h5;
      end else if(m2s_rwd_crdt_tbs[3].credit_to_be_sent >= 'd8) begin
        m2s_rwd_crdt_send = 'h4;
      end else if(m2s_rwd_crdt_tbs[3].credit_to_be_sent >= 'd4) begin
        m2s_rwd_crdt_send = 'h3;
      end else if(m2s_rwd_crdt_tbs[3].credit_to_be_sent >= 'd2) begin
        m2s_rwd_crdt_send = 'h2;
      end else if(m2s_rwd_crdt_tbs[3].credit_to_be_sent == 'd1) begin
        m2s_rwd_crdt_send = 'h1;
      end else begin
        if(m2s_rwd_crdt_tbs[2].pending) begin
          if(m2s_rwd_crdt_tbs[2].credit_to_be_sent == 'd64) begin
            m2s_rwd_crdt_send = 'h7;
          end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
            m2s_rwd_crdt_send = 'h6;
          end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
            m2s_rwd_crdt_send = 'h5;
          end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
            m2s_rwd_crdt_send = 'h4;
          end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
            m2s_rwd_crdt_send = 'h3;
          end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
            m2s_rwd_crdt_send = 'h2;
          end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent == 'd1) begin
            m2s_rwd_crdt_send = 'h1;
          end else begin
            if(m2s_rwd_crdt_tbs[1].pending) begin
              if(m2s_rwd_crdt_tbs[1].credit_to_be_sent == 'd64) begin
                m2s_rwd_crdt_send = 'h7;
              end else if(m2s_rwd_crdt_tbs[1].credit_to_be_sent >= 'd32) begin
                m2s_rwd_crdt_send = 'h6;
              end else if(m2s_rwd_crdt_tbs[1].credit_to_be_sent >= 'd16) begin
               m2s_rwd_crdt_send = 'h5;
              end else if(m2s_rwd_crdt_tbs[1].credit_to_be_sent >= 'd8) begin
                m2s_rwd_crdt_send = 'h4;
              end else if(m2s_rwd_crdt_tbs[1].credit_to_be_sent >= 'd4) begin
                m2s_rwd_crdt_send = 'h3;
              end else if(m2s_rwd_crdt_tbs[1].credit_to_be_sent >= 'd2) begin
                m2s_rwd_crdt_send = 'h2;
              end else if(m2s_rwd_crdt_tbs[1].credit_to_be_sent == 'd1) begin
                m2s_rwd_crdt_send = 'h1;
              end else begin
                if(m2s_rwd_crdt_tbs[0].pending) begin
                  if(m2s_rwd_crdt_tbs[2].credit_to_be_sent == 'd64) begin
                    m2s_rwd_crdt_send = 'h7;
                  end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd32) begin
                    m2s_rwd_crdt_send = 'h6;
                  end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd16) begin
                    m2s_rwd_crdt_send = 'h5;
                  end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd8) begin
                    m2s_rwd_crdt_send = 'h4;
                  end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd4) begin
                    m2s_rwd_crdt_send = 'h3;
                  end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent >= 'd2) begin
                    m2s_rwd_crdt_send = 'h2;
                  end else if(m2s_rwd_crdt_tbs[2].credit_to_be_sent == 'd1) begin
                    m2s_rwd_crdt_send = 'h1;
                  end else begin
                    m2s_rwd_crdt_send = 'h0;
                  end
                end else begin
                  m2s_rwd_crdt_send = 'h0;
                end
              end
            end else begin
              m2s_rwd_crdt_send = 'h0;
            end
          end
        end else begin
          m2s_rwd_crdt_send = 'h0;
        end
      end 
    end else begin
      m2s_rwd_crdt_send = 'h0;
    end

/*
    h2d_req_crdt_send             = (h2d_req_crdt_tbs[3].pending)? (h2d_req_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (h2d_req_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (h2d_req_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (h2d_req_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (h2d_req_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (h2d_req_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (h2d_req_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_req_crdt_tbs[2].pending)? (h2d_req_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (h2d_req_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (h2d_req_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (h2d_req_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (h2d_req_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (h2d_req_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (h2d_req_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_req_crdt_tbs[1].pending)? (h2d_req_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (h2d_req_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (h2d_req_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (h2d_req_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (h2d_req_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (h2d_req_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (h2d_req_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_req_crdt_tbs[0].pending)? (h2d_req_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (h2d_req_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (h2d_req_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (h2d_req_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (h2d_req_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (h2d_req_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (h2d_req_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
    h2d_rsp_crdt_send             = (h2d_rsp_crdt_tbs[3].pending)? (h2d_rsp_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (h2d_rsp_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (h2d_rsp_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (h2d_rsp_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (h2d_rsp_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (h2d_rsp_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (h2d_rsp_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_rsp_crdt_tbs[2].pending)? (h2d_rsp_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (h2d_rsp_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (h2d_rsp_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (h2d_rsp_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (h2d_rsp_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (h2d_rsp_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (h2d_rsp_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_rsp_crdt_tbs[1].pending)? (h2d_rsp_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (h2d_rsp_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (h2d_rsp_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (h2d_rsp_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (h2d_rsp_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (h2d_rsp_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (h2d_rsp_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_rsp_crdt_tbs[0].pending)? (h2d_rsp_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (h2d_rsp_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (h2d_rsp_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (h2d_rsp_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (h2d_rsp_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (h2d_rsp_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (h2d_rsp_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
    h2d_data_crdt_send             = (h2d_data_crdt_tbs[3].pending)? (h2d_data_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (h2d_data_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (h2d_data_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (h2d_data_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (h2d_data_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (h2d_data_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (h2d_data_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_data_crdt_tbs[2].pending)? (h2d_data_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (h2d_data_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (h2d_data_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (h2d_data_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (h2d_data_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (h2d_data_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (h2d_data_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_data_crdt_tbs[1].pending)? (h2d_data_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (h2d_data_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (h2d_data_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (h2d_data_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (h2d_data_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (h2d_data_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (h2d_data_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (h2d_data_crdt_tbs[0].pending)? (h2d_data_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (h2d_data_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (h2d_data_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (h2d_data_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (h2d_data_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (h2d_data_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (h2d_data_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
    m2s_req_crdt_send             = (m2s_req_crdt_tbs[3].pending)? (m2s_req_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (m2s_req_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (m2s_req_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (m2s_req_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (m2s_req_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (m2s_req_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (m2s_req_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (m2s_req_crdt_tbs[2].pending)? (m2s_req_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (m2s_req_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (m2s_req_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (m2s_req_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (m2s_req_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (m2s_req_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (m2s_req_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (m2s_req_crdt_tbs[1].pending)? (m2s_req_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (m2s_req_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (m2s_req_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (m2s_req_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (m2s_req_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (m2s_req_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (m2s_req_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (m2s_req_crdt_tbs[0].pending)? (m2s_req_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (m2s_req_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (m2s_req_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (m2s_req_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (m2s_req_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (m2s_req_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (m2s_req_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
    m2s_rwd_crdt_send             = (m2s_rwd_crdt_tbs[3].pending)? (m2s_rwd_crdt_tbs[3].credit_to_be_sent == 'd64)? 'h7: (m2s_rwd_crdt_tbs[3].credit_to_be_sent > 'd32)? 'h6: (m2s_rwd_crdt_tbs[3].credit_to_be_sent > 'd16)? 'h5 : (m2s_rwd_crdt_tbs[3].credit_to_be_sent > 'd8)? 'h4: (m2s_rwd_crdt_tbs[3].credit_to_be_sent > 'd4)? 'd3: (m2s_rwd_crdt_tbs[3].credit_to_be_sent == 'd2)? 'h2: (m2s_rwd_crdt_tbs[3].credit_to_be_sent == 'd1)? 'h1:
                                  : (m2s_rwd_crdt_tbs[2].pending)? (m2s_rwd_crdt_tbs[2].credit_to_be_sent == 'd64)? 'h7: (m2s_rwd_crdt_tbs[2].credit_to_be_sent > 'd32)? 'h6: (m2s_rwd_crdt_tbs[2].credit_to_be_sent > 'd16)? 'h5 : (m2s_rwd_crdt_tbs[2].credit_to_be_sent > 'd8)? 'h4: (m2s_rwd_crdt_tbs[2].credit_to_be_sent > 'd4)? 'd3: (m2s_rwd_crdt_tbs[2].credit_to_be_sent == 'd2)? 'h2: (m2s_rwd_crdt_tbs[2].credit_to_be_sent == 'd1)? 'h1:
                                  : (m2s_rwd_crdt_tbs[1].pending)? (m2s_rwd_crdt_tbs[1].credit_to_be_sent == 'd64)? 'h7: (m2s_rwd_crdt_tbs[1].credit_to_be_sent > 'd32)? 'h6: (m2s_rwd_crdt_tbs[1].credit_to_be_sent > 'd16)? 'h5 : (m2s_rwd_crdt_tbs[1].credit_to_be_sent > 'd8)? 'h4: (m2s_rwd_crdt_tbs[1].credit_to_be_sent > 'd4)? 'd3: (m2s_rwd_crdt_tbs[1].credit_to_be_sent == 'd2)? 'h2: (m2s_rwd_crdt_tbs[1].credit_to_be_sent == 'd1)? 'h1:
                                  : (m2s_rwd_crdt_tbs[0].pending)? (m2s_rwd_crdt_tbs[0].credit_to_be_sent == 'd64)? 'h7: (m2s_rwd_crdt_tbs[0].credit_to_be_sent > 'd32)? 'h6: (m2s_rwd_crdt_tbs[0].credit_to_be_sent > 'd16)? 'h5 : (m2s_rwd_crdt_tbs[0].credit_to_be_sent > 'd8)? 'h4: (m2s_rwd_crdt_tbs[0].credit_to_be_sent > 'd4)? 'd3: (m2s_rwd_crdt_tbs[0].credit_to_be_sent == 'd2)? 'h2: (m2s_rwd_crdt_tbs[0].credit_to_be_sent == 'd1)? 'h1:
                                  : 'h0;
*/
  end

  always@(posedge dev_tx_dl_if.clk) begin
    if(!dev_tx_dl_if.rstn) begin
      lru <= 'h0;
      h2d_req_occ_d   <= 'd0;
      h2d_rsp_occ_d   <= 'd0;
      h2d_data_occ_d  <= 'd0;
      m2s_req_occ_d   <= 'd0;
      m2s_rwd_occ_d   <= 'd0;
      h2d_req_crdt_tbs[0].pending <= 'h1;
      h2d_req_crdt_tbs[1].pending <= 'h1;
      h2d_req_crdt_tbs[2].pending <= 'h1;
      h2d_req_crdt_tbs[3].pending <= 'h1;
      h2d_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
      h2d_req_crdt_tbs[1].credit_to_be_sent <= 'd64;
      h2d_req_crdt_tbs[2].credit_to_be_sent <= 'd64;
      h2d_req_crdt_tbs[3].credit_to_be_sent <= 'd64;
    end else begin 
      h2d_req_occ_d   <= h2d_req_occ;
      h2d_rsp_occ_d   <= h2d_rsp_occ;
      h2d_data_occ_d  <= h2d_data_occ;
      m2s_req_occ_d   <= m2s_req_occ;
      m2s_rwd_occ_d   <= m2s_rwd_occ;
      if((h2d_req_crdt_tbs[0].credit_to_be_sent + h2d_req_outstanding_credits) <= 'd64) begin
        h2d_req_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0)) begin
          h2d_req_crdt_tbs[0].credit_to_be_sent <= h2d_req_crdt_tbs[0].credit_to_be_sent + h2d_req_outstanding_credits - ((h2d_req_crdt_send == 'h7)? 'd64: (h2d_req_crdt_send == 'h6)? 'h32: (h2d_req_crdt_send == 'h5)? 'h16: (h2d_req_crdt_send == 'h4)? 'h8: (h2d_req_crdt_send == 'h3)? 'h4: h2d_req_crdt_send);
        end else begin
          h2d_req_crdt_tbs[0].credit_to_be_sent <= h2d_req_crdt_tbs[0].credit_to_be_sent + h2d_req_outstanding_credits;
        end
      end else if(((h2d_req_crdt_tbs[0].credit_to_be_sent + h2d_req_outstanding_credits) > 'd64) && ((h2d_req_crdt_tbs[1].credit_to_be_sent + h2d_req_outstanding_credits) <= 'd64)) begin
        h2d_req_crdt_tbs[0].pending <= 'h1;
        h2d_req_crdt_tbs[1].pending <= 'h1;
        h2d_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0)) begin
          h2d_req_crdt_tbs[0].credit_to_be_sent <= h2d_req_crdt_tbs[0].credit_to_be_sent + h2d_req_outstanding_credits - ((h2d_req_crdt_send == 'h7)? 'd64: (h2d_req_crdt_send == 'h6)? 'h32: (h2d_req_crdt_send == 'h5)? 'h16: (h2d_req_crdt_send == 'h4)? 'h8: (h2d_req_crdt_send == 'h3)? 'h4: h2d_req_crdt_send);
        end else begin
          h2d_req_crdt_tbs[1].credit_to_be_sent <= h2d_req_crdt_tbs[1].credit_to_be_sent + h2d_req_outstanding_credits;
        end
      end else if(((h2d_req_crdt_tbs[1].credit_to_be_sent + h2d_req_outstanding_credits) > 'd64) && ((h2d_req_crdt_tbs[2].credit_to_be_sent + h2d_req_outstanding_credits) <= 'd64)) begin
        h2d_req_crdt_tbs[0].pending <= 'h1;
        h2d_req_crdt_tbs[1].pending <= 'h1;
        h2d_req_crdt_tbs[2].pending <= 'h1;
        h2d_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        h2d_req_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0)) begin
          h2d_req_crdt_tbs[0].credit_to_be_sent <= h2d_req_crdt_tbs[0].credit_to_be_sent + h2d_req_outstanding_credits - ((h2d_req_crdt_send == 'h7)? 'd64: (h2d_req_crdt_send == 'h6)? 'h32: (h2d_req_crdt_send == 'h5)? 'h16: (h2d_req_crdt_send == 'h4)? 'h8: (h2d_req_crdt_send == 'h3)? 'h4: h2d_req_crdt_send);
        end else begin
          h2d_req_crdt_tbs[2].credit_to_be_sent <= h2d_req_crdt_tbs[2].credit_to_be_sent + h2d_req_outstanding_credits;
        end
      end else if(((h2d_req_crdt_tbs[2].credit_to_be_sent + h2d_req_outstanding_credits) > 'd64) && ((h2d_req_crdt_tbs[3].credit_to_be_sent + h2d_req_outstanding_credits) <= 'd64)) begin
        h2d_req_crdt_tbs[0].pending <= 'h1;
        h2d_req_crdt_tbs[1].pending <= 'h1;
        h2d_req_crdt_tbs[2].pending <= 'h1;
        h2d_req_crdt_tbs[3].pending <= 'h1;
        h2d_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        h2d_req_crdt_tbs[1].credit_to_be_sent <= 'd64;
        h2d_req_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0)) begin
          h2d_req_crdt_tbs[0].credit_to_be_sent <= h2d_req_crdt_tbs[0].credit_to_be_sent + h2d_req_outstanding_credits - ((h2d_req_crdt_send == 'h7)? 'd64: (h2d_req_crdt_send == 'h6)? 'h32: (h2d_req_crdt_send == 'h5)? 'h16: (h2d_req_crdt_send == 'h4)? 'h8: (h2d_req_crdt_send == 'h3)? 'h4: h2d_req_crdt_send);
        end else begin
          h2d_req_crdt_tbs[3].credit_to_be_sent <= h2d_req_crdt_tbs[3].credit_to_be_sent + h2d_req_outstanding_credits;
        end
      end
      if((h2d_rsp_crdt_tbs[0].credit_to_be_sent + h2d_rsp_outstanding_credits) <= 'd64) begin
        h2d_rsp_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((m2s_req_crdt_send > 0) && (lru == 0)) || (m2s_req_crdt_send == 0))) begin
          h2d_rsp_crdt_tbs[0].credit_to_be_sent <= h2d_rsp_crdt_tbs[0].credit_to_be_sent + h2d_rsp_outstanding_credits - ((h2d_rsp_crdt_send == 'h7)? 'd64: (h2d_rsp_crdt_send == 'h6)? 'h32: (h2d_rsp_crdt_send == 'h5)? 'h16: (h2d_rsp_crdt_send == 'h4)? 'h8: (h2d_rsp_crdt_send == 'h3)? 'h4: h2d_rsp_crdt_send);
          if(m2s_req_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          h2d_rsp_crdt_tbs[0].credit_to_be_sent <= h2d_rsp_crdt_tbs[0].credit_to_be_sent + h2d_rsp_outstanding_credits;
        end
      end else if(((h2d_rsp_crdt_tbs[0].credit_to_be_sent + h2d_rsp_outstanding_credits) > 'd64) && ((h2d_rsp_crdt_tbs[1].credit_to_be_sent + h2d_rsp_outstanding_credits) <= 'd64)) begin
        h2d_rsp_crdt_tbs[0].pending <= 'h1;
        h2d_rsp_crdt_tbs[1].pending <= 'h1;
        h2d_rsp_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((m2s_req_crdt_send > 0) && (lru == 0)) || (m2s_req_crdt_send == 0))) begin
          h2d_rsp_crdt_tbs[0].credit_to_be_sent <= h2d_rsp_crdt_tbs[0].credit_to_be_sent + h2d_rsp_outstanding_credits - ((h2d_rsp_crdt_send == 'h7)? 'd64: (h2d_rsp_crdt_send == 'h6)? 'h32: (h2d_rsp_crdt_send == 'h5)? 'h16: (h2d_rsp_crdt_send == 'h4)? 'h8: (h2d_rsp_crdt_send == 'h3)? 'h4: h2d_rsp_crdt_send);
          if(m2s_req_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          h2d_rsp_crdt_tbs[1].credit_to_be_sent <= h2d_rsp_crdt_tbs[1].credit_to_be_sent + h2d_rsp_outstanding_credits;
        end
      end else if(((h2d_rsp_crdt_tbs[1].credit_to_be_sent + h2d_rsp_outstanding_credits) > 'd64) && ((h2d_rsp_crdt_tbs[2].credit_to_be_sent + h2d_rsp_outstanding_credits) <= 'd64)) begin
        h2d_rsp_crdt_tbs[0].pending <= 'h1;
        h2d_rsp_crdt_tbs[1].pending <= 'h1;
        h2d_rsp_crdt_tbs[2].pending <= 'h1;
        h2d_rsp_crdt_tbs[0].credit_to_be_sent <= 'd64;
        h2d_rsp_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((m2s_req_crdt_send > 0) && (lru == 0)) || (m2s_req_crdt_send == 0))) begin
          h2d_rsp_crdt_tbs[0].credit_to_be_sent <= h2d_rsp_crdt_tbs[0].credit_to_be_sent + h2d_rsp_outstanding_credits - ((h2d_rsp_crdt_send == 'h7)? 'd64: (h2d_rsp_crdt_send == 'h6)? 'h32: (h2d_rsp_crdt_send == 'h5)? 'h16: (h2d_rsp_crdt_send == 'h4)? 'h8: (h2d_rsp_crdt_send == 'h3)? 'h4: h2d_rsp_crdt_send);
          if(m2s_req_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          h2d_rsp_crdt_tbs[2].credit_to_be_sent <= h2d_rsp_crdt_tbs[2].credit_to_be_sent + h2d_rsp_outstanding_credits;
        end
      end else if(((h2d_rsp_crdt_tbs[2].credit_to_be_sent + h2d_rsp_outstanding_credits) > 'd64) && ((h2d_rsp_crdt_tbs[3].credit_to_be_sent + h2d_rsp_outstanding_credits) <= 'd64)) begin
        h2d_rsp_crdt_tbs[0].pending <= 'h1;
        h2d_rsp_crdt_tbs[1].pending <= 'h1;
        h2d_rsp_crdt_tbs[2].pending <= 'h1;
        h2d_rsp_crdt_tbs[3].pending <= 'h1;
        h2d_rsp_crdt_tbs[0].credit_to_be_sent <= 'd64;
        h2d_rsp_crdt_tbs[1].credit_to_be_sent <= 'd64;
        h2d_rsp_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((m2s_req_crdt_send > 0) && (lru == 0)) || (m2s_req_crdt_send == 0))) begin
          h2d_rsp_crdt_tbs[0].credit_to_be_sent <= h2d_rsp_crdt_tbs[0].credit_to_be_sent + h2d_rsp_outstanding_credits - ((h2d_rsp_crdt_send == 'h7)? 'd64: (h2d_rsp_crdt_send == 'h6)? 'h32: (h2d_rsp_crdt_send == 'h5)? 'h16: (h2d_rsp_crdt_send == 'h4)? 'h8: (h2d_rsp_crdt_send == 'h3)? 'h4: h2d_rsp_crdt_send);
          if(m2s_req_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          h2d_rsp_crdt_tbs[3].credit_to_be_sent <= h2d_rsp_crdt_tbs[3].credit_to_be_sent + h2d_rsp_outstanding_credits;
        end
      end
      if((h2d_data_crdt_tbs[0].credit_to_be_sent + h2d_data_outstanding_credits) <= 'd64) begin
        h2d_data_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((m2s_rwd_crdt_send > 0) && (lru == 0)) || (m2s_rwd_crdt_send == 0))) begin
          h2d_data_crdt_tbs[0].credit_to_be_sent <= h2d_data_crdt_tbs[0].credit_to_be_sent + h2d_data_outstanding_credits - ((h2d_data_crdt_send == 'h7)? 'd64: (h2d_data_crdt_send == 'h6)? 'h32: (h2d_data_crdt_send == 'h5)? 'h16: (h2d_data_crdt_send == 'h4)? 'h8: (h2d_data_crdt_send == 'h3)? 'h4: h2d_data_crdt_send);
          if(m2s_rwd_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          h2d_data_crdt_tbs[0].credit_to_be_sent <= h2d_data_crdt_tbs[0].credit_to_be_sent + h2d_data_outstanding_credits;
        end
      end else if(((h2d_data_crdt_tbs[0].credit_to_be_sent + h2d_data_outstanding_credits) > 'd64) && ((h2d_data_crdt_tbs[1].credit_to_be_sent + h2d_data_outstanding_credits) <= 'd64)) begin
        h2d_data_crdt_tbs[0].pending <= 'h1;
        h2d_data_crdt_tbs[1].pending <= 'h1;
        h2d_data_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((m2s_rwd_crdt_send > 0) && (lru == 0)) || (m2s_rwd_crdt_send == 0))) begin
          h2d_data_crdt_tbs[0].credit_to_be_sent <= h2d_data_crdt_tbs[0].credit_to_be_sent + h2d_data_outstanding_credits - ((h2d_data_crdt_send == 'h7)? 'd64: (h2d_data_crdt_send == 'h6)? 'h32: (h2d_data_crdt_send == 'h5)? 'h16: (h2d_data_crdt_send == 'h4)? 'h8: (h2d_data_crdt_send == 'h3)? 'h4: h2d_data_crdt_send);
          if(m2s_rwd_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          h2d_data_crdt_tbs[1].credit_to_be_sent <= h2d_data_crdt_tbs[1].credit_to_be_sent + h2d_data_outstanding_credits;
        end
      end else if(((h2d_data_crdt_tbs[1].credit_to_be_sent + h2d_data_outstanding_credits) > 'd64) && ((h2d_data_crdt_tbs[2].credit_to_be_sent + h2d_data_outstanding_credits) <= 'd64)) begin
        h2d_data_crdt_tbs[0].pending <= 'h1;
        h2d_data_crdt_tbs[1].pending <= 'h1;
        h2d_data_crdt_tbs[2].pending <= 'h1;
        h2d_data_crdt_tbs[0].credit_to_be_sent <= 'd64;
        h2d_data_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((m2s_rwd_crdt_send > 0) && (lru == 0)) || (m2s_rwd_crdt_send == 0))) begin
          h2d_data_crdt_tbs[0].credit_to_be_sent <= h2d_data_crdt_tbs[0].credit_to_be_sent + h2d_data_outstanding_credits - ((h2d_data_crdt_send == 'h7)? 'd64: (h2d_data_crdt_send == 'h6)? 'h32: (h2d_data_crdt_send == 'h5)? 'h16: (h2d_data_crdt_send == 'h4)? 'h8: (h2d_data_crdt_send == 'h3)? 'h4: h2d_data_crdt_send);
          if(m2s_rwd_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          h2d_data_crdt_tbs[2].credit_to_be_sent <= h2d_data_crdt_tbs[2].credit_to_be_sent + h2d_data_outstanding_credits;
        end
      end else if(((h2d_data_crdt_tbs[2].credit_to_be_sent + h2d_data_outstanding_credits) > 'd64) && ((h2d_data_crdt_tbs[3].credit_to_be_sent + h2d_data_outstanding_credits) <= 'd64)) begin
        h2d_data_crdt_tbs[0].pending <= 'h1;
        h2d_data_crdt_tbs[1].pending <= 'h1;
        h2d_data_crdt_tbs[2].pending <= 'h1;
        h2d_data_crdt_tbs[3].pending <= 'h1;
        h2d_data_crdt_tbs[0].credit_to_be_sent <= 'd64;
        h2d_data_crdt_tbs[1].credit_to_be_sent <= 'd64;
        h2d_data_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((m2s_rwd_crdt_send > 0) && (lru == 0)) || (m2s_rwd_crdt_send == 0))) begin
          h2d_data_crdt_tbs[0].credit_to_be_sent <= h2d_data_crdt_tbs[0].credit_to_be_sent + h2d_data_outstanding_credits - ((h2d_data_crdt_send == 'h7)? 'd64: (h2d_data_crdt_send == 'h6)? 'h32: (h2d_data_crdt_send == 'h5)? 'h16: (h2d_data_crdt_send == 'h4)? 'h8: (h2d_data_crdt_send == 'h3)? 'h4: h2d_data_crdt_send);
          if(m2s_rwd_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          h2d_data_crdt_tbs[3].credit_to_be_sent <= h2d_data_crdt_tbs[3].credit_to_be_sent + h2d_data_outstanding_credits;
        end
      end
      if((m2s_req_crdt_tbs[0].credit_to_be_sent + m2s_req_outstanding_credits) <= 'd64) begin
        m2s_req_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((h2d_rsp_crdt_send > 0) && (lru == 1)) || (h2d_rsp_crdt_send == 0))) begin
          m2s_req_crdt_tbs[0].credit_to_be_sent <= m2s_req_crdt_tbs[0].credit_to_be_sent + m2s_req_outstanding_credits - ((m2s_req_crdt_send == 'h7)? 'd64: (m2s_req_crdt_send == 'h6)? 'h32: (m2s_req_crdt_send == 'h5)? 'h16: (m2s_req_crdt_send == 'h4)? 'h8: (m2s_req_crdt_send == 'h3)? 'h4: m2s_req_crdt_send);
          if(h2d_rsp_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          m2s_req_crdt_tbs[0].credit_to_be_sent <= m2s_req_crdt_tbs[0].credit_to_be_sent + m2s_req_outstanding_credits;
        end
      end else if(((m2s_req_crdt_tbs[0].credit_to_be_sent + m2s_req_outstanding_credits) > 'd64) && ((m2s_req_crdt_tbs[1].credit_to_be_sent + m2s_req_outstanding_credits) <= 'd64)) begin
        m2s_req_crdt_tbs[0].pending <= 'h1;
        m2s_req_crdt_tbs[1].pending <= 'h1;
        m2s_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((h2d_rsp_crdt_send > 0) && (lru == 1)) || (h2d_rsp_crdt_send == 0))) begin
          m2s_req_crdt_tbs[0].credit_to_be_sent <= m2s_req_crdt_tbs[0].credit_to_be_sent + m2s_req_outstanding_credits - ((m2s_req_crdt_send == 'h7)? 'd64: (m2s_req_crdt_send == 'h6)? 'h32: (m2s_req_crdt_send == 'h5)? 'h16: (m2s_req_crdt_send == 'h4)? 'h8: (m2s_req_crdt_send == 'h3)? 'h4: m2s_req_crdt_send);
          if(h2d_rsp_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          m2s_req_crdt_tbs[1].credit_to_be_sent <= m2s_req_crdt_tbs[1].credit_to_be_sent + m2s_req_outstanding_credits;
        end
      end else if(((m2s_req_crdt_tbs[1].credit_to_be_sent + m2s_req_outstanding_credits) > 'd64) && ((m2s_req_crdt_tbs[2].credit_to_be_sent + m2s_req_outstanding_credits) <= 'd64)) begin
        m2s_req_crdt_tbs[0].pending <= 'h1;
        m2s_req_crdt_tbs[1].pending <= 'h1;
        m2s_req_crdt_tbs[2].pending <= 'h1;
        m2s_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        m2s_req_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((h2d_rsp_crdt_send > 0) && (lru == 1)) || (h2d_rsp_crdt_send == 0))) begin
          m2s_req_crdt_tbs[0].credit_to_be_sent <= m2s_req_crdt_tbs[0].credit_to_be_sent + m2s_req_outstanding_credits - ((m2s_req_crdt_send == 'h7)? 'd64: (m2s_req_crdt_send == 'h6)? 'h32: (m2s_req_crdt_send == 'h5)? 'h16: (m2s_req_crdt_send == 'h4)? 'h8: (m2s_req_crdt_send == 'h3)? 'h4: m2s_req_crdt_send);
          if(h2d_rsp_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          m2s_req_crdt_tbs[2].credit_to_be_sent <= m2s_req_crdt_tbs[2].credit_to_be_sent + m2s_req_outstanding_credits;
        end
      end else if(((m2s_req_crdt_tbs[2].credit_to_be_sent + m2s_req_outstanding_credits) > 'd64) && ((m2s_req_crdt_tbs[3].credit_to_be_sent + m2s_req_outstanding_credits) <= 'd64)) begin
        m2s_req_crdt_tbs[0].pending <= 'h1;
        m2s_req_crdt_tbs[1].pending <= 'h1;
        m2s_req_crdt_tbs[2].pending <= 'h1;
        m2s_req_crdt_tbs[3].pending <= 'h1;
        m2s_req_crdt_tbs[0].credit_to_be_sent <= 'd64;
        m2s_req_crdt_tbs[1].credit_to_be_sent <= 'd64;
        m2s_req_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((h2d_rsp_crdt_send > 0) && (lru == 1)) || (h2d_rsp_crdt_send == 0))) begin
          m2s_req_crdt_tbs[0].credit_to_be_sent <= m2s_req_crdt_tbs[0].credit_to_be_sent + m2s_req_outstanding_credits - ((m2s_req_crdt_send == 'h7)? 'd64: (m2s_req_crdt_send == 'h6)? 'h32: (m2s_req_crdt_send == 'h5)? 'h16: (m2s_req_crdt_send == 'h4)? 'h8: (m2s_req_crdt_send == 'h3)? 'h4: m2s_req_crdt_send);
          if(h2d_rsp_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          m2s_req_crdt_tbs[3].credit_to_be_sent <= m2s_req_crdt_tbs[3].credit_to_be_sent + m2s_req_outstanding_credits;
        end
      end
      if((m2s_rwd_crdt_tbs[0].credit_to_be_sent + m2s_rwd_outstanding_credits) <= 'd64) begin
        m2s_rwd_crdt_tbs[0].pending <= 'h1;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((h2d_data_crdt_send > 0) && (lru == 1)) || (h2d_data_crdt_send == 0))) begin
          m2s_rwd_crdt_tbs[0].credit_to_be_sent <= m2s_rwd_crdt_tbs[0].credit_to_be_sent + m2s_rwd_outstanding_credits - ((m2s_rwd_crdt_send == 'h7)? 'd64: (m2s_rwd_crdt_send == 'h6)? 'h32: (m2s_rwd_crdt_send == 'h5)? 'h16: (m2s_rwd_crdt_send == 'h4)? 'h8: (m2s_rwd_crdt_send == 'h3)? 'h4: m2s_rwd_crdt_send);
          if(h2d_data_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          m2s_rwd_crdt_tbs[0].credit_to_be_sent <= m2s_rwd_crdt_tbs[0].credit_to_be_sent + m2s_rwd_outstanding_credits;
        end
      end else if(((m2s_rwd_crdt_tbs[0].credit_to_be_sent + m2s_rwd_outstanding_credits) > 'd64) && ((m2s_rwd_crdt_tbs[1].credit_to_be_sent + m2s_rwd_outstanding_credits) <= 'd64)) begin
        m2s_rwd_crdt_tbs[0].pending <= 'h1;
        m2s_rwd_crdt_tbs[1].pending <= 'h1;
        m2s_rwd_crdt_tbs[0].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((h2d_data_crdt_send > 0) && (lru == 1)) || (h2d_data_crdt_send == 0))) begin
          m2s_rwd_crdt_tbs[0].credit_to_be_sent <= m2s_rwd_crdt_tbs[0].credit_to_be_sent + m2s_rwd_outstanding_credits - ((m2s_rwd_crdt_send == 'h7)? 'd64: (m2s_rwd_crdt_send == 'h6)? 'h32: (m2s_rwd_crdt_send == 'h5)? 'h16: (m2s_rwd_crdt_send == 'h4)? 'h8: (m2s_rwd_crdt_send == 'h3)? 'h4: m2s_rwd_crdt_send);
          if(h2d_data_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          m2s_rwd_crdt_tbs[1].credit_to_be_sent <= m2s_rwd_crdt_tbs[1].credit_to_be_sent + m2s_rwd_outstanding_credits;
        end
      end else if(((m2s_rwd_crdt_tbs[1].credit_to_be_sent + m2s_rwd_outstanding_credits) > 'd64) && ((m2s_rwd_crdt_tbs[2].credit_to_be_sent + m2s_rwd_outstanding_credits) <= 'd64)) begin
        m2s_rwd_crdt_tbs[0].pending <= 'h1;
        m2s_rwd_crdt_tbs[1].pending <= 'h1;
        m2s_rwd_crdt_tbs[2].pending <= 'h1;
        m2s_rwd_crdt_tbs[0].credit_to_be_sent <= 'd64;
        m2s_rwd_crdt_tbs[1].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((h2d_data_crdt_send > 0) && (lru == 1)) || (h2d_data_crdt_send == 0))) begin
          m2s_rwd_crdt_tbs[0].credit_to_be_sent <= m2s_rwd_crdt_tbs[0].credit_to_be_sent + m2s_rwd_outstanding_credits - ((m2s_rwd_crdt_send == 'h7)? 'd64: (m2s_rwd_crdt_send == 'h6)? 'h32: (m2s_rwd_crdt_send == 'h5)? 'h16: (m2s_rwd_crdt_send == 'h4)? 'h8: (m2s_rwd_crdt_send == 'h3)? 'h4: m2s_rwd_crdt_send);
          if(h2d_data_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          m2s_rwd_crdt_tbs[2].credit_to_be_sent <= m2s_rwd_crdt_tbs[2].credit_to_be_sent + m2s_rwd_outstanding_credits;
        end
      end else if(((m2s_rwd_crdt_tbs[2].credit_to_be_sent + m2s_rwd_outstanding_credits) > 'd64) && ((m2s_rwd_crdt_tbs[3].credit_to_be_sent + m2s_rwd_outstanding_credits) <= 'd64)) begin
        m2s_rwd_crdt_tbs[0].pending <= 'h1;
        m2s_rwd_crdt_tbs[1].pending <= 'h1;
        m2s_rwd_crdt_tbs[2].pending <= 'h1;
        m2s_rwd_crdt_tbs[3].pending <= 'h1;
        m2s_rwd_crdt_tbs[0].credit_to_be_sent <= 'd64;
        m2s_rwd_crdt_tbs[1].credit_to_be_sent <= 'd64;
        m2s_rwd_crdt_tbs[2].credit_to_be_sent <= 'd64;
        if((slot_sel_d != slot_sel) && (slot_sel_d == H_SLOT0) && (((h2d_data_crdt_send > 0) && (lru == 1)) || (h2d_data_crdt_send == 0))) begin
          m2s_rwd_crdt_tbs[0].credit_to_be_sent <= m2s_rwd_crdt_tbs[0].credit_to_be_sent + m2s_rwd_outstanding_credits - ((m2s_rwd_crdt_send == 'h7)? 'd64: (m2s_rwd_crdt_send == 'h6)? 'h32: (m2s_rwd_crdt_send == 'h5)? 'h16: (m2s_rwd_crdt_send == 'h4)? 'h8: (m2s_rwd_crdt_send == 'h3)? 'h4: m2s_rwd_crdt_send);
          if(h2d_data_crdt_send > 0) begin
            lru <= ~lru;
          end
        end else begin
          m2s_rwd_crdt_tbs[3].credit_to_be_sent <= m2s_rwd_crdt_tbs[3].credit_to_be_sent + m2s_rwd_outstanding_credits;
        end
      end
    end
  end

  //TODO: assignment of slot number is missing in the header of pkt after generic slot is selected 
  //TODO: serious missing piece is if roll over cnt exceeds then packing of further data should be avoided
  //ll pkt buffer
  always@(posedge dev_tx_dl_if.clk) begin
    if(!dev_tx_dl_if.rstn) begin
      slot_sel <= H_SLOT0;
      slot_sel_d <= H_SLOT0;
      holding_wrptr <= 'h0;
      data_slot[0] <= 'h0;
      data_slot[1] <= 'h0;
      data_slot[2] <= 'h0;
      data_slot[3] <= 'h0;
      data_slot[4] <= 'h0;
      data_slot_d[0] <= 'h0;
      data_slot_d[1] <= 'h0;
      data_slot_d[2] <= 'h0;
      data_slot_d[3] <= 'h0;
      data_slot_d[4] <= 'h0;
    end else begin
      h_gnt_d <= h_gnt;
      g_gnt_d <= g_gnt;
      slot_sel_d <= slot_sel;
      data_slot_d[0] <= data_slot[0];
      data_slot_d[1] <= data_slot[1];
      data_slot_d[2] <= data_slot[2];
      data_slot_d[3] <= data_slot[3];
      data_slot_d[4] <= data_slot[4];
      if(data_slot[1] == 'hf) begin
        data_slot[0] <= data_slot[1];
        data_slot[1] <= data_slot[2];
        data_slot[2] <= data_slot[3];
        data_slot[3] <= data_slot[4];
        data_slot[4] <= 'h0;
      end
      case(slot_sel)
        H_SLOT0: begin
          if(h_gnt == 0) begin
            slot_sel <= H_SLOT0;
          end else begin
            if(h_gnt[4]) begin
              if(data_slot[0] == 'h0) begin
                slot_sel <= G_SLOT1;
              end else if(data_slot[0] == 'h2) begin
                slot_sel <= G_SLOT2;
              end else if(data_slot[0] == 'h6) begin
                slot_sel <= G_SLOT3;
              end else if(data_slot[0] == 'he) begin
                slot_sel <= H_SLOT0;
              end
            end else if(h_gnt[0] || h_gnt[1] || h_gnt[3]) begin
              slot_sel <= H_SLOT0;
              if(data_slot[0] == 'h0) begin
                data_slot[0] <= 'he; data_slot[1] <= 'h2; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'h2) begin
                data_slot[0] <= 'he; data_slot[1] <= 'h6; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'h6) begin
                data_slot[0] <= 'he; data_slot[1] <= 'he; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'he) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else begin
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(h_gnt[5]) begin
              slot_sel <= H_SLOT0;
              if(data_slot[0] == 'h0) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'h2; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'h2) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'h6; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'h6) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'he; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else if(data_slot[0] == 'he) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else begin
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(h_gnt[2]) begin
              slot_sel <= H_SLOT0;
              if(data_slot[0] == 'h0) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'h2;
              end else if(data_slot[0] == 'h2) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'h6;
              end else if(data_slot[0] == 'h6) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'he;
              end else if(data_slot[0] == 'he) begin
                data_slot[0] <= 'he; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'hf;
              end else begin
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end
          end
        end
        G_SLOT1: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT1;
          end else if(g_gnt[0]) begin
            slot_sel <= XSLOT;
          end else begin
            if(g_gnt[1] || g_gnt[5]) begin
              if(data_slot[0] == 'h0) begin
                slot_sel <= G_SLOT2;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[2] || g_gnt[4]) begin
              if(data_slot[0] == 'h0) begin
                slot_sel <= G_SLOT2;
                data_slot[0] <= 'hc; data_slot[1] <= 'h6; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[6]) begin
              if(data_slot[0] == 'h0) begin
                slot_sel <= G_SLOT2;
                data_slot[0] <= 'hc; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'h6; data_slot[4] <= 'h0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[3]) begin
              if(data_slot[0] == 'h0) begin
                slot_sel <= G_SLOT2;
                data_slot[0] <= 'hc; data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'h6;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else begin
              slot_sel <= XSLOT;
            end
          end
        end
        G_SLOT2: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT2;
          end else if(g_gnt[0]) begin
            slot_sel <= XSLOT;
          end else begin
            if(g_gnt[1] || g_gnt[5]) begin
              if(data_slot[0] == 'h0 || (data_slot[0] == 'h2)) begin
                slot_sel <= G_SLOT3;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[2] || g_gnt[4]) begin
              if(data_slot[0] == 'h0 || (data_slot[0] == 'h2)) begin
                data_slot[0] <= ((data_slot[0] == 'h2)?'ha: 'h8); data_slot[1] <= 'he; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[6]) begin
              if(data_slot[0] == 'h0 || (data_slot[0] == 'h2)) begin
                data_slot[0] <= ((data_slot[0] == 'h2)?'ha: 'h8); data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'he; data_slot[4] <= 'h0;
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[3]) begin
              if(data_slot[0] == 'h0 || (data_slot[0] == 'h2)) begin
                data_slot[0] <= ((data_slot[0] == 'h2)?'ha: 'h8); data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'he;
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else begin
              slot_sel <= XSLOT;
            end
          end
        end
        G_SLOT3: begin
          if(g_gnt == 0) begin
            slot_sel <= G_SLOT3;
          end else if(g_gnt[0]) begin
            slot_sel <= XSLOT;
          end else begin
            if(g_gnt[1] || g_gnt[5]) begin
              if(data_slot[0] == 'h0 || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[2] || g_gnt[4]) begin
              if(data_slot[0] == 'h0 || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
              /*data_slot[0] <=  ;*/ data_slot[1] <= 'hf; data_slot[2] <= 'h0; data_slot[3] <= 'h0; data_slot[4] <= 'h0;
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[6]) begin
              if(data_slot[0] == 'h0 || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
              /*data_slot[0] <=  ;*/ data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'h0;
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else if(g_gnt[3]) begin
              if(data_slot[0] == 'h0 || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
              /*data_slot[0] <=  ;*/ data_slot[1] <= 'hf; data_slot[2] <= 'hf; data_slot[3] <= 'hf; data_slot[4] <= 'hf;
                slot_sel <= H_SLOT0;
              end else begin
                slot_sel <= XSLOT;
                data_slot[0] <= 'hX; data_slot[1] <= 'hX; data_slot[2] <= 'hX; data_slot[3] <= 'hX; data_slot[4] <= 'hX;
              end
            end else begin
              slot_sel <= XSLOT;
            end
          end
        end
        default: begin
            slot_sel = XSLOT;
        end 
      endcase
      
      if(slot_sel_d != slot_sel) begin
        case(slot_sel)
          H_SLOT0: begin
            case(h_gnt)
              'h1: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= (ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0;//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h0;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= h2d_rsp_crdt_send;
                holding_q[holding_wrptr].data[27:24]    <= ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (lru))? ({1'h1, m2s_req_crdt_send[2:0]}): ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (!lru))? ({1'h0, h2d_req_crdt_send[2:0]}): (m2s_req_crdt_send > 0)? ({1'h1, m2s_req_crdt_send[2:0]}): (h2d_req_crdt_send > 0)? ({1'h0, h2d_req_crdt_send[2:0]}): 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (lru))? ({1'h1, m2s_rwd_crdt_send[2:0]}): ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (!lru))? ({1'h0, h2d_data_crdt_send[2:0]}): (m2s_rwd_crdt_send > 0)? ({1'h1, m2s_rwd_crdt_send[2:0]}): (h2d_data_crdt_send > 0)? ({1'h0, h2d_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
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
                holding_q[holding_wrptr].data[92:90]    <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[94:93]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[96:95]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[112:97]   <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[116:113]  <= 'h0;//spare always 0
                holding_q[holding_wrptr].data[127:117]  <= 'h0;//rsvd always 0
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:128]  <= d2h_data_dataout.data[383:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[255:128]<= d2h_data_dataout.data[511:384];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]  <= d2h_data_dataout.data[255:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[383:128]<= d2h_data_dataout.data[511:256];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]  <= d2h_data_dataout.data[127:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[511:128]<= d2h_data_dataout.data[511:128];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]  <= d2h_data_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end
              end
              'h2: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= (ack_cnt_tbs > ack_cnt_snt)? 'h1 : 'h0;//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h1;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= h2d_rsp_crdt_send;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (lru))? ({1'h1, m2s_req_crdt_send[2:0]}): ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (!lru))? ({1'h0, h2d_req_crdt_send[2:0]}): (m2s_req_crdt_send > 0)? ({1'h1, m2s_req_crdt_send[2:0]}): (h2d_req_crdt_send > 0)? ({1'h0, h2d_req_crdt_send[2:0]}): 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (lru))? ({1'h1, m2s_rwd_crdt_send[2:0]}): ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (!lru))? ({1'h0, h2d_data_crdt_send[2:0]}): (m2s_rwd_crdt_send > 0)? ({1'h1, m2s_rwd_crdt_send[2:0]}): (h2d_data_crdt_send > 0)? ({1'h0, h2d_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
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
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:128]  <= d2h_data_dataout.data[383:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[255:128]  <= d2h_data_dataout.data[511:384];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]  <= d2h_data_dataout.data[255:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[383:128]<= d2h_data_dataout.data[511:256];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]  <= d2h_data_dataout.data[127:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[511:128]<= d2h_data_dataout.data[511:128];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]  <= d2h_data_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end
              end
              'h4: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= (ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0;//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h2;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= h2d_rsp_crdt_send;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (lru))? ({1'h1, m2s_req_crdt_send[2:0]}): ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (!lru))? ({1'h0, h2d_req_crdt_send[2:0]}): (m2s_req_crdt_send > 0)? ({1'h1, m2s_req_crdt_send[2:0]}): (h2d_req_crdt_send > 0)? ({1'h0, h2d_req_crdt_send[2:0]}): 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (lru))? ({1'h1, m2s_rwd_crdt_send[2:0]}): ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (!lru))? ({1'h0, h2d_data_crdt_send[2:0]}): (m2s_rwd_crdt_send > 0)? ({1'h1, m2s_rwd_crdt_send[2:0]}): (h2d_data_crdt_send > 0)? ({1'h0, h2d_data_crdt_send[2:0]}): 'h0;
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
                if(data_slot[0] == 'h0) begin
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
                  holding_q[holding_wrptr+4].data[255:128]  <= d2h_data_qdataout.data[511:384];
                  holding_q[holding_wrptr+4].valid        <= 'h0;
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]  <= d2h_data_dataout.data[255:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[255:0]  <= d2h_data_dataout.data[511:256];
                  holding_q[holding_wrptr+1].data[511:256]<= d2h_data_ddataout.data[255:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_q[holding_wrptr+2].data[255:0]  <= d2h_data_ddataout.data[511:256];
                  holding_q[holding_wrptr+2].data[511:256]<= d2h_data_tdataout.data[255:0];
                  holding_q[holding_wrptr+2].valid        <= 'h1;
                  holding_q[holding_wrptr+3].data[255:0]  <= d2h_data_tdataout.data[511:256];
                  holding_q[holding_wrptr+3].data[511:256]<= d2h_data_qdataout.data[255:0];
                  holding_q[holding_wrptr+3].valid        <= 'h1;
                  holding_q[holding_wrptr+4].data[383:128]  <= d2h_data_qdataout.data[511:256];
                  holding_q[holding_wrptr+4].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 4;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]  <= d2h_data_dataout.data[127:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[383:0]  <= d2h_data_dataout.data[511:128];
                  holding_q[holding_wrptr+1].data[511:384]<= d2h_data_ddataout.data[127:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_q[holding_wrptr+2].data[383:0]  <= d2h_data_ddataout.data[511:128];
                  holding_q[holding_wrptr+2].data[511:384]<= d2h_data_tdataout.data[127:0];
                  holding_q[holding_wrptr+2].valid        <= 'h1;
                  holding_q[holding_wrptr+3].data[383:0]  <= d2h_data_tdataout.data[511:128];
                  holding_q[holding_wrptr+3].data[511:384]<= d2h_data_qdataout.data[127:0];
                  holding_q[holding_wrptr+3].valid        <= 'h1;
                  holding_q[holding_wrptr+4].data[511:0]  <= d2h_data_qdataout.data[511:128];
                  holding_q[holding_wrptr+4].valid        <= 'h0;
                  holding_wrptr                           <= holding_wrptr + 4;
                end else if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]  <= d2h_data_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_q[holding_wrptr+2].data[511:0]  <= d2h_data_ddataout.data[511:0];
                  holding_q[holding_wrptr+2].valid        <= 'h1;
                  holding_q[holding_wrptr+3].data[511:0]  <= d2h_data_tdataout.data[511:0];
                  holding_q[holding_wrptr+3].valid        <= 'h1;
                  holding_q[holding_wrptr+4].data[511:0]  <= d2h_data_qdataout.data[511:0];
                  holding_wrptr                           <= holding_wrptr + 5;
                  holding_q[holding_wrptr+5].valid        <= 'h0;
                end
              end
              'h8: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= (ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0;//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h3;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= h2d_rsp_crdt_send;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (lru))? ({1'h1, m2s_req_crdt_send[2:0]}): ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (!lru))? ({1'h0, h2d_req_crdt_send[2:0]}): (m2s_req_crdt_send > 0)? ({1'h1, m2s_req_crdt_send[2:0]}): (h2d_req_crdt_send > 0)? ({1'h0, h2d_req_crdt_send[2:0]}): 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (lru))? ({1'h1, m2s_rwd_crdt_send[2:0]}): ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (!lru))? ({1'h0, h2d_data_crdt_send[2:0]}): (m2s_rwd_crdt_send > 0)? ({1'h1, m2s_rwd_crdt_send[2:0]}): (h2d_data_crdt_send > 0)? ({1'h0, h2d_data_crdt_send[2:0]}): 'h0;
                holding_q[holding_wrptr].data[32]       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[35:33]    <= s2m_drs_dataout.opcode;
                holding_q[holding_wrptr].data[37:36]    <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[39:38]    <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[55:40]    <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[56]       <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[71:57]    <= 'h0;// spare bits always 0
                holding_q[holding_wrptr].data[72]       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[75:73]    <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[77:76]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[79:78]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[95:80]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[99:96]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[127:100]  <= 'h0;//rsvd bits always 0
                if(data_slot[0]) begin
                  holding_q[holding_wrptr].data[511:128]  <= s2m_drs_dataout.data[383:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[127:0]  <= s2m_drs_dataout.data[511:384];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]  <= s2m_drs_dataout.data[255:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[383:128]<= s2m_drs_dataout.data[511:256];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]  <= s2m_drs_dataout.data[127:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[511:128]<= s2m_drs_dataout.data[511:128];
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]  <= s2m_drs_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end
              end
              'h16: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= (ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0;//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h4;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= h2d_rsp_crdt_send;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (lru))? ({1'h1, m2s_req_crdt_send[2:0]}): ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (!lru))? ({1'h0, h2d_req_crdt_send[2:0]}): (m2s_req_crdt_send > 0)? ({1'h1, m2s_req_crdt_send[2:0]}): (h2d_req_crdt_send > 0)? ({1'h0, h2d_req_crdt_send[2:0]}): 'h0;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (lru))? ({1'h1, m2s_rwd_crdt_send[2:0]}): ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (!lru))? ({1'h0, h2d_data_crdt_send[2:0]}): (m2s_rwd_crdt_send > 0)? ({1'h1, m2s_rwd_crdt_send[2:0]}): (h2d_data_crdt_send > 0)? ({1'h0, h2d_data_crdt_send[2:0]}): 'h0;
                holding_q[holding_wrptr].data[32]       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[35:33]    <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[37:36]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[39:38]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[55:40]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[59:56]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[60]       <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[63:61]    <= s2m_ndr_ddataout.opcode;
                holding_q[holding_wrptr].data[65:64]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[67:66]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[83:68]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[87:84]    <= 'h0;//spare are always 0
                holding_q[holding_wrptr].data[127:88]   <= 'h0;//rsvd bits are always 0
                if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].valid        <= 'h0;
                end else begin
                  holding_q[holding_wrptr].valid          <= 'h0;
                end
              end
              'h32: begin
                holding_q[holding_wrptr].data[0]        <= 'h0;//protocol flit encoding is 0 & for control type is 1
                holding_q[holding_wrptr].data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
                holding_q[holding_wrptr].data[2]        <= (ack_cnt_tbs > ack_cnt_snt)? 'h1: 'h0;//TBD: logic for crdt ack to be added later
                ack_cnt_snt                             <= ((ack_cnt_tbs > ack_cnt_snt)? (ack_cnt_snt + 1) : ack_cnt_snt);
                holding_q[holding_wrptr].data[3]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[4]        <= 'h0;//non data header so 0
                holding_q[holding_wrptr].data[7:5]      <= 'h5;//slot0 fmt is H0 so 0
                holding_q[holding_wrptr].data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
                holding_q[holding_wrptr].data[19:17]    <= 'h0;//reserved must be 0
                holding_q[holding_wrptr].data[23:20]    <= h2d_rsp_crdt_send;//TBD: rsp crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[27:24]    <= ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (lru))? ({1'h1, m2s_req_crdt_send[2:0]}): ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (!lru))? ({1'h0, h2d_req_crdt_send[2:0]}): (m2s_req_crdt_send > 0)? ({1'h1, m2s_req_crdt_send[2:0]}): (h2d_req_crdt_send > 0)? ({1'h0, h2d_req_crdt_send[2:0]}): 'h0;;//TBD: req crdt logic for crdt to be added later
                holding_q[holding_wrptr].data[31:28]    <= ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (lru))? ({1'h1, m2s_rwd_crdt_send[2:0]}): ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (!lru))? ({1'h0, h2d_data_crdt_send[2:0]}): (m2s_rwd_crdt_send > 0)? ({1'h1, m2s_rwd_crdt_send[2:0]}): (h2d_data_crdt_send > 0)? ({1'h0, h2d_data_crdt_send[2:0]}): 'h0;
                holding_q[holding_wrptr].data[32]       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[35:33]    <= s2m_drs_dataout.opcode;
                holding_q[holding_wrptr].data[37:36]    <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[39:38]    <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[55:40]    <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[56]       <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[71:57]    <= 'h0;//spare bits always 0
                holding_q[holding_wrptr].data[72]       <= s2m_drs_ddataout.valid;
                holding_q[holding_wrptr].data[75:73]    <= s2m_drs_ddataout.opcode;
                holding_q[holding_wrptr].data[77:76]    <= s2m_drs_ddataout.metafield;
                holding_q[holding_wrptr].data[79:78]    <= s2m_drs_ddataout.metavalue;
                holding_q[holding_wrptr].data[95:80]    <= s2m_drs_ddataout.tag;
                holding_q[holding_wrptr].data[96]       <= s2m_drs_ddataout.poison;
                holding_q[holding_wrptr].data[111:97]   <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[127:112]  <= 'h0;//rsvd bits are always 0
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:128]  <= s2m_drs_dataout.data[383:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[127:0]  <= s2m_drs_dataout.data[511:384];
                  holding_q[holding_wrptr+1].data[511:128]<= s2m_drs_ddataout.data[383:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_q[holding_wrptr+2].data[127:0]  <= s2m_drs_ddataout.data[511:384];
                  holding_wrptr                           <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end else if(data_slot[0] == 'h2) begin
                  holding_q[holding_wrptr].data[511:256]  <= s2m_drs_dataout.data[255:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[255:0]  <= s2m_drs_dataout.data[511:256];
                  holding_q[holding_wrptr+1].data[511:256]<= s2m_drs_ddataout.data[255:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_q[holding_wrptr+2].data[383:128]<= s2m_drs_ddataout.data[511:256];
                  holding_wrptr                           <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end else if(data_slot[0] == 'h6) begin
                  holding_q[holding_wrptr].data[511:384]  <= s2m_drs_dataout.data[127:0];
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[383:0]  <= s2m_drs_dataout.data[511:128];
                  holding_q[holding_wrptr+1].data[511:384]<= s2m_drs_ddataout.data[127:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_q[holding_wrptr+2].data[511:128]<= s2m_drs_ddataout.data[511:128];
                  holding_wrptr                           <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid        <= 'h0;
                end else if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid          <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]  <= s2m_drs_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid        <= 'h1;
                  holding_q[holding_wrptr+2].data[511:0]  <= s2m_drs_ddataout.data[511:0];
                  holding_q[holding_wrptr+2].valid        <= 'h1;
                  holding_wrptr                           <= holding_wrptr + 3;
                  holding_q[holding_wrptr+3].valid        <= 'h0;
                end
              end
              default: begin
                holding_q[holding_wrptr].valid          <= 'h0;
              end
            endcase
          end
          G_SLOT1: begin
            case(g_gnt)
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
                if(data_slot[0] == 'he) begin
                  holding_q[holding_wrptr].valid                                        <= 'h0;
                end else begin
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_wrptr                                                         <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].valid                                      <= 'h1;
                end
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
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:256]                                <= d2h_data_dataout.data[255:0];
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_wrptr                                                         <= holding_wrptr + 1;
                  holding_q[holding_wrptr].data[383:128]                                <= d2h_data_dataout.data[511:256];
                  holding_q[holding_wrptr].valid                                        <= 'h0;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
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
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+52)]    <= d2h_data_qdataout.uqid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+64)]                      <= d2h_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+65)]                      <= d2h_data_qdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+66)]                      <= d2h_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+67)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+68)]   <= 'h0;//rsvd bits are always 0
                if(data_slot[0] == 'h0) begin
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
                  holding_q[holding_wrptr+4].data[383:128]                              <= d2h_data_qdataout.data[511:256];
                  holding_q[holding_wrptr+4].valid                                      <= 'h0;
                  holding_wrptr                                                         <= holding_wrptr + 4;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]      <= s2m_drs_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]      <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+39):(SLOT1_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+40)]                      <= s2m_ndr_dataout.valid; 
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+43):(SLOT1_OFFSET+41)]    <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+45):(SLOT1_OFFSET+44)]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+47):(SLOT1_OFFSET+46)]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+48)]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+67):(SLOT1_OFFSET+64)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+68)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+69)]    <= s2m_ndr_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+73):(SLOT1_OFFSET+72)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+75):(SLOT1_OFFSET+74)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+91):(SLOT1_OFFSET+76)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+95):(SLOT1_OFFSET+92)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+96)]   <= 'h0;
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:256]                                <= s2m_drs_dataout.data[255:0];
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[383:128]                              <= s2m_drs_dataout.data[511:256];
                  holding_q[holding_wrptr+1].valid                                      <= 'h0;
                  holding_wrptr                                                         <= holding_wrptr + 1;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]      <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]      <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]      <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)]     <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+24)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+28)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+31):(SLOT1_OFFSET+29)]    <= s2m_ndr_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+33):(SLOT1_OFFSET+32)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+35):(SLOT1_OFFSET+34)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+51):(SLOT1_OFFSET+36)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+55):(SLOT1_OFFSET+52)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+56)]                      <= s2m_ndr_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+59):(SLOT1_OFFSET+57)]    <= s2m_ndr_tdataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+61):(SLOT1_OFFSET+60)]    <= s2m_ndr_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+62)]    <= s2m_ndr_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+79):(SLOT1_OFFSET+64)]    <= s2m_ndr_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+83):(SLOT1_OFFSET+80)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+84)]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
              'h64: begin
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]      <= s2m_drs_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]      <=  s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+39):(SLOT1_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+40)]                      <= s2m_drs_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+43):(SLOT1_OFFSET+41)]    <= s2m_drs_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+45):(SLOT1_OFFSET+44)]    <= s2m_drs_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+47):(SLOT1_OFFSET+46)]    <= s2m_drs_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+48)]    <= s2m_drs_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+64)]                      <= s2m_drs_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+79):(SLOT1_OFFSET+65)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+80)] <= s2m_drs_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+83):(SLOT1_OFFSET+81)]    <= s2m_drs_tdataout.opcode;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+85):(SLOT1_OFFSET+84)]    <= s2m_drs_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+87):(SLOT1_OFFSET+86)]    <= s2m_drs_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+103):(SLOT1_OFFSET+88)]   <= s2m_drs_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+104)]                     <= s2m_drs_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+119):(SLOT1_OFFSET+105)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT1_OFFSET+127):(SLOT1_OFFSET+120)]  <= 'h0;//rsvd bits are always 0
                if(data_slot[0] == 'h0) begin
                  holding_q[holding_wrptr].data[511:256]                                <= s2m_drs_dataout.data[255:0];
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[255:0]                                <= s2m_drs_dataout.data[511:256];
                  holding_q[holding_wrptr+1].data[511:256]                              <= s2m_drs_ddataout.data[255:0];
                  holding_q[holding_wrptr+1].valid                                      <= 'h1;
                  holding_q[holding_wrptr+2].data[255:0]                                <= s2m_drs_ddataout.data[511:256];
                  holding_q[holding_wrptr+2].data[511:256]                              <= s2m_drs_tdataout.data[255:0];
                  holding_q[holding_wrptr+2].valid                                      <= 'h1;
                  holding_q[holding_wrptr+3].data[383:128]                              <= s2m_drs_tdataout.data[511:256];
                  holding_q[holding_wrptr+3].valid                                      <= 'h0;
                  holding_wrptr                                                         <= holding_wrptr + 3;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
              end          
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
          G_SLOT2: begin
            case(g_gnt)    
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
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2)) begin
                  holding_q[holding_wrptr].data[511:384]                                <= d2h_data_dataout.data[127:0];
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_wrptr                                                         <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].data[511:128]                              <= d2h_data_dataout.data[511:128];
                  holding_q[holding_wrptr+1].valid                                      <= 'h0;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
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
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+52)]    <= d2h_data_qdataout.uqid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+64)]                      <= d2h_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+65)]                      <= d2h_data_qdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+66)]                      <= d2h_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+67)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+68)]   <= 'h0;//rsvd bits are always 0
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2)) begin
                  holding_q[holding_wrptr].data[511:384]                                <= d2h_data_dataout.data[127:0];
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[383:0]                                <= d2h_data_dataout.data[511:128];
                  holding_q[holding_wrptr+1].data[511:384]                              <= d2h_data_ddataout.data[127:0];
                  holding_q[holding_wrptr+1].valid                                      <= 'h1;
                  holding_q[holding_wrptr+2].data[383:0]                                <= d2h_data_ddataout.data[511:128];
                  holding_q[holding_wrptr+2].data[511:384]                              <= d2h_data_tdataout.data[127:0];
                  holding_q[holding_wrptr+2].valid                                      <= 'h1;
                  holding_q[holding_wrptr+3].data[383:0]                                <= d2h_data_tdataout.data[511:128];
                  holding_q[holding_wrptr+3].data[511:384]                              <= d2h_data_qdataout.data[127:0];
                  holding_q[holding_wrptr+3].valid                                      <= 'h1;
                  holding_q[holding_wrptr+4].data[511:128]                              <= d2h_data_qdataout.data[511:128];
                  holding_q[holding_wrptr+4].valid                                      <= 'h0;
                  holding_wrptr                                                         <= holding_wrptr + 4;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end 
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]      <= s2m_drs_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]      <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+39):(SLOT2_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+40)]                      <= s2m_ndr_dataout.valid; 
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+43):(SLOT2_OFFSET+41)]    <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+45):(SLOT2_OFFSET+44)]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+47):(SLOT2_OFFSET+46)]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+48)]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+67):(SLOT2_OFFSET+64)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+68)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+69)]    <= s2m_ndr_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+73):(SLOT2_OFFSET+72)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+75):(SLOT2_OFFSET+74)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+91):(SLOT2_OFFSET+76)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+95):(SLOT2_OFFSET+92)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+96)]   <= 'h0;
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2)) begin
                  holding_q[holding_wrptr].data[511:384]                                <= s2m_drs_dataout.data[127:0];
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[383:0]                                <= s2m_drs_dataout.data[511:128];
                  holding_q[holding_wrptr+1].valid                                      <= 'h0;
                  holding_wrptr                                                         <= holding_wrptr + 1;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]      <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]      <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]      <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)]     <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+24)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+28)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+31):(SLOT2_OFFSET+29)]    <= s2m_ndr_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+33):(SLOT2_OFFSET+32)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+35):(SLOT2_OFFSET+34)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+51):(SLOT2_OFFSET+36)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+55):(SLOT2_OFFSET+52)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+56)]                      <= s2m_ndr_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+59):(SLOT2_OFFSET+57)]    <= s2m_ndr_tdataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+61):(SLOT2_OFFSET+60)]    <= s2m_ndr_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+62)]    <= s2m_ndr_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+79):(SLOT2_OFFSET+64)]    <= s2m_ndr_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+83):(SLOT2_OFFSET+80)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+84)]   <= 'h0;//rsvd bits are always 0
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
              'h64: begin
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]      <= s2m_drs_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]      <=  s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+39):(SLOT2_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+40)]                      <= s2m_drs_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+43):(SLOT2_OFFSET+41)]    <= s2m_drs_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+45):(SLOT2_OFFSET+44)]    <= s2m_drs_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+47):(SLOT2_OFFSET+46)]    <= s2m_drs_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+48)]    <= s2m_drs_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+64)]                      <= s2m_drs_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+79):(SLOT2_OFFSET+65)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+80)] <= s2m_drs_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+83):(SLOT2_OFFSET+81)]    <= s2m_drs_tdataout.opcode;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+85):(SLOT2_OFFSET+84)]    <= s2m_drs_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+87):(SLOT2_OFFSET+86)]    <= s2m_drs_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+103):(SLOT2_OFFSET+88)]   <= s2m_drs_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+104)]                     <= s2m_drs_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+119):(SLOT2_OFFSET+105)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT2_OFFSET+127):(SLOT2_OFFSET+120)]  <= 'h0;//rsvd bits are always 0
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2)) begin
                  holding_q[holding_wrptr].data[511:384]                                <= s2m_drs_dataout.data[127:0];
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[383:0]                                <= s2m_drs_dataout.data[511:128];
                  holding_q[holding_wrptr+1].data[511:384]                              <= s2m_drs_ddataout.data[127:0];
                  holding_q[holding_wrptr+1].valid                                      <= 'h1;
                  holding_q[holding_wrptr+2].data[383:0]                                <= s2m_drs_ddataout.data[511:128];
                  holding_q[holding_wrptr+2].data[511:384]                              <= s2m_drs_tdataout.data[127:0];
                  holding_q[holding_wrptr+2].valid                                      <= 'h1;
                  holding_q[holding_wrptr+3].data[511:128]                              <= s2m_drs_tdataout.data[511:128];
                  holding_q[holding_wrptr+3].valid                                      <= 'h0;
                  holding_wrptr                                                         <= holding_wrptr + 3;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
              end   
              default: begin
                holding_q[holding_wrptr].valid                                        <= 'h0;
              end
            endcase
          end
          G_SLOT3: begin
            case(g_gnt)
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
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                  holding_wrptr                                                         <= holding_wrptr + 1;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
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
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]                                <= d2h_data_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid                                      <= 'h1;
                  holding_wrptr                                                         <= holding_wrptr + 2;
                  holding_q[holding_wrptr+2].valid                                      <= 'h0;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
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
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+52)]    <= d2h_data_qdataout.uqid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+64)]                      <= d2h_data_qdataout.chunkvalid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+65)]                      <= d2h_data_qdataout.bogus;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+66)]                      <= d2h_data_qdataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+67)]                      <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+68)]   <= 'h0;//rsvd bits are always 0
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]                                <= d2h_data_dataout.data;
                  holding_q[holding_wrptr+1].valid                                      <= 'h1;
                  holding_q[holding_wrptr+2].data[511:0]                                <= d2h_data_ddataout.data;
                  holding_q[holding_wrptr+2].valid                                      <= 'h1;
                  holding_q[holding_wrptr+3].data[511:0]                                <= d2h_data_tdataout.data;
                  holding_q[holding_wrptr+3].valid                                      <= 'h1;
                  holding_q[holding_wrptr+4].data[511:0]                                <= d2h_data_qdataout.data;
                  holding_q[holding_wrptr+4].valid                                      <= 'h1;
                  holding_q[holding_wrptr+5].valid                                      <= 'h0;
                  holding_wrptr                                                         <= holding_wrptr + 5;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
              end
              'h16: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]      <= s2m_drs_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]      <= s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+39):(SLOT3_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+40)]                      <= s2m_ndr_dataout.valid; 
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+43):(SLOT3_OFFSET+41)]    <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+45):(SLOT3_OFFSET+44)]    <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+47):(SLOT3_OFFSET+46)]    <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+48)]    <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+67):(SLOT3_OFFSET+64)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+68)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+69)]    <= s2m_ndr_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+73):(SLOT3_OFFSET+72)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+75):(SLOT3_OFFSET+74)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+91):(SLOT3_OFFSET+76)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+95):(SLOT3_OFFSET+92)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+96)]   <= 'h0;
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]                                <= s2m_drs_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid                                      <= 'h1;
                  holding_q[holding_wrptr+2].valid                                      <= 'h0;
                  holding_wrptr                                                         <= holding_wrptr + 2;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end  
              end
              'h32: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= s2m_ndr_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]      <= s2m_ndr_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]      <= s2m_ndr_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]      <= s2m_ndr_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)]     <= s2m_ndr_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+24)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+28)]                      <= s2m_ndr_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+31):(SLOT3_OFFSET+29)]    <= s2m_ndr_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+33):(SLOT3_OFFSET+32)]    <= s2m_ndr_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+35):(SLOT3_OFFSET+34)]    <= s2m_ndr_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+51):(SLOT3_OFFSET+36)]    <= s2m_ndr_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+55):(SLOT3_OFFSET+52)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+56)]                      <= s2m_ndr_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+59):(SLOT3_OFFSET+57)]    <= s2m_ndr_tdataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+61):(SLOT3_OFFSET+60)]    <= s2m_ndr_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+62)]    <= s2m_ndr_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+79):(SLOT3_OFFSET+64)]    <= s2m_ndr_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+83):(SLOT3_OFFSET+80)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+84)]   <= 'h0;//rsvd bits are always 0
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_wrptr                                                         <= holding_wrptr + 1;
                  holding_q[holding_wrptr+1].valid                                      <= 'h0;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
              end
              'h64: begin
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+0)]                       <= s2m_drs_dataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]      <= s2m_drs_dataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]      <=  s2m_drs_dataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]      <= s2m_drs_dataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)]     <= s2m_drs_dataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+24)]                      <= s2m_drs_dataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+39):(SLOT3_OFFSET+25)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+40)]                      <= s2m_drs_ddataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+43):(SLOT3_OFFSET+41)]    <= s2m_drs_ddataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+45):(SLOT3_OFFSET+44)]    <= s2m_drs_ddataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+47):(SLOT3_OFFSET+46)]    <= s2m_drs_ddataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+48)]    <= s2m_drs_ddataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+64)]                      <= s2m_drs_ddataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+79):(SLOT3_OFFSET+65)]    <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+80)] <= s2m_drs_tdataout.valid;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+83):(SLOT3_OFFSET+81)]    <= s2m_drs_tdataout.opcode;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+85):(SLOT3_OFFSET+84)]    <= s2m_drs_tdataout.metafield;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+87):(SLOT3_OFFSET+86)]    <= s2m_drs_tdataout.metavalue;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+103):(SLOT3_OFFSET+88)]   <= s2m_drs_tdataout.tag;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+104)]                     <= s2m_drs_tdataout.poison;
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+119):(SLOT3_OFFSET+105)]  <= 'h0;//spare bits are always 0
                holding_q[holding_wrptr].data[(SLOT3_OFFSET+127):(SLOT3_OFFSET+120)]  <= 'h0;//rsvd bits are always 0
                if((data_slot[0] == 'h0) || (data_slot[0] == 'h2) || (data_slot[0] == 'h6)) begin
                  holding_q[holding_wrptr].valid                                        <= 'h1;
                  holding_q[holding_wrptr+1].data[511:0]                                <= s2m_drs_dataout.data[511:0];
                  holding_q[holding_wrptr+1].valid                                      <= 'h1;
                  holding_q[holding_wrptr+2].data[511:0]                                <= s2m_drs_ddataout.data[511:0];
                  holding_q[holding_wrptr+2].valid                                      <= 'h1;
                  holding_q[holding_wrptr+3].data[511:0]                                <= s2m_drs_tdataout.data[511:0];
                  holding_q[holding_wrptr+3].valid                                      <= 'h1;
                  holding_wrptr                                                         <= holding_wrptr + 4;
                  holding_q[holding_wrptr+4].valid                                      <= 'h0;
                end else begin
                  holding_wrptr                                                         <= 'hX;
                end
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
      dev_tx_dl_if_pre_valid <= 'h0;
      dev_tx_dl_if_pre_data <= 'h0;
      dev_tx_dl_if.valid <= 'h0;
      dev_tx_dl_if_d.valid <= 'h0;
      dev_tx_dl_if.data <= 'h0;
      dev_tx_dl_if_d.data <= 'h0;
      holding_rdptr <= 'h0;
      ack_cnt_tbs <= 'h0;
      ack_cnt_snt <= 'h0;
    end else begin
      dev_tx_dl_if_d <= dev_tx_dl_if;
      dev_tx_dl_if.valid <= dev_tx_dl_if_pre_valid;
      dev_tx_dl_if.data <= {dev_tx_dl_if_pre_data[511:0], dev_tx_dl_if_pre_crc[15:0]};
      if(ack) begin
        ack_cnt_tbs <= ack_cnt_tbs + 1;
      end
      if(holding_q[holding_rdptr].valid) begin
        dev_tx_dl_if_pre_valid <= holding_q[holding_rdptr].valid;
        dev_tx_dl_if_pre_data <= holding_q[holding_rdptr].data;
        holding_rdptr <= holding_rdptr + 1;
      end else begin
        if((dev_tx_dl_if_d.rstn == 'h1) && (dev_tx_dl_if.rstn == 'h0)) begin
          dev_tx_dl_if_pre_valid          <= 'h1;
          dev_tx_dl_if_pre_data[35:32]    <= 'b1100;
          dev_tx_dl_if_pre_data[39:36]    <= 'b1000;
          dev_tx_dl_if_pre_data[67:64]    <= 'h1;
        end
        if(insert_ack) begin
          dev_tx_dl_if_pre_valid          <= 'h1;
          dev_tx_dl_if_pre_data[0]        <= 'h1;//protocol flit encoding is 0 & for control type is 1
          dev_tx_dl_if_pre_data[1]        <= 'h0;//reserved must be 0 otherwise will be flagged as error on the other side
          dev_tx_dl_if_pre_data[2]        <= ack_cnt_tbs[3];//TBD: logic for crdt ack to be added later
          dev_tx_dl_if_pre_data[3]        <= 'h0;//non data header so 0
          dev_tx_dl_if_pre_data[4]        <= 'h0;//non data header so 0
          dev_tx_dl_if_pre_data[7:5]      <= 'h0;//slot0 fmt is H0 so 0
          dev_tx_dl_if_pre_data[10:8]     <= 'h0;//this field will be reupdated after g slot is selected
          dev_tx_dl_if_pre_data[13:11]    <= 'h0;//this field will be reupdated after g slot is selected
          dev_tx_dl_if_pre_data[16:14]    <= 'h0;//this field will be reupdated after g slot is selected
          dev_tx_dl_if_pre_data[19:17]    <= 'h0;//reserved must be 0
          dev_tx_dl_if_pre_data[23:20]    <= h2d_rsp_crdt_send;//TBD: rsp crdt logic for crdt to be added later
          dev_tx_dl_if_pre_data[27:24]    <= ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (lru))? ({1'h1, m2s_req_crdt_send[2:0]}): ((h2d_req_crdt_send > 0) && (m2s_req_crdt_send > 0) && (!lru))? ({1'h0, h2d_req_crdt_send[2:0]}): (m2s_req_crdt_send > 0)? ({1'h1, m2s_req_crdt_send[2:0]}): (h2d_req_crdt_send > 0)? ({1'h0, h2d_req_crdt_send[2:0]}): 'h0;//TBD: req crdt logic for crdt to be added later
          dev_tx_dl_if_pre_data[31:28]    <= ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (lru))? ({1'h1, m2s_rwd_crdt_send[2:0]}): ((h2d_data_crdt_send > 0) && (m2s_rwd_crdt_send > 0) && (!lru))? ({1'h0, h2d_data_crdt_send[2:0]}): (m2s_rwd_crdt_send > 0)? ({1'h1, m2s_rwd_crdt_send[2:0]}): (h2d_data_crdt_send > 0)? ({1'h0, h2d_data_crdt_send[2:0]}): 'h0;//TBD: data crdt logic for crdt to be added later
          dev_tx_dl_if_pre_data[35:32]    <= 4'b0000;
          dev_tx_dl_if_pre_data[39:36]    <= 4'b0001;
          dev_tx_dl_if_pre_data[63:40]    <= 'h0;
          dev_tx_dl_if_pre_data[71:64]    <= ({ack_cnt_tbs[7:4], 1'b0, ack_cnt_tbs[2:0]});
          ack_cnt_snt                     <= ack_cnt_tbs;
        end else begin
          dev_tx_dl_if_pre_valid          <= 'h0;
        end
      end
    end
  end

  crc_gen crc_gen_inst(
    .data(dev_tx_dl_if_pre_data),
    .crc(dev_tx_dl_if_pre_crc)
  );
/*
  buffer #(
    .DEPTH(256),
    .ADDR_WIDTH(8),
    .FIFO_DATA_TYPE(holding_q_t)
  ) llrb (
	  .clk(dev_tx_dl_if.clk),
  	.rstn(dev_tx_dl_if.rstn),
  	.rval(ack_ret_val),
  	.ack_cnt(ack_ret),
    .wval(dev_tx_dl_if.valid),
    .datain(dev_tx_dl_if.data),
  	.eseq,
  	.wptr()
  );
*/
  rra #(
    .NO_OF_REQ(6)
  ) h_slot_rra_inst(
    .clk(clk),
    .rstn(rstn),
    .req(h_req),
    .gnt(h_gnt)
  );

  rra #(
    .NO_OF_REQ(7)
  ) g_slot_rra_inst(
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
              local_num_phy_reinit <= 'h0;
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
          r_states <= RETRY_REMOTE_NORMAL;
        end
      end
      endcase
    end
  end
  
  //retry req/ack snt logic tbd
  
endmodule

module crc_gen#(

)(
  input logic [511:0] data,
  output logic [15:0] crc
);

  localparam [511:0] DM[16] = {
    512'hEF9C_D9F9_C4BB_B83A_3E84_A97C_D7AE_DA13_FAEB_01B8_5B20_4A4C_AE1E_79D9_7753_5D21_DC7F_DD6A_38F0_3E77_F5F5_2A2C_636D_B05C_3978_EA30_CD50_E0D9_9B06_93D4_746B_2431,
    512'h9852_B505_26E6_6427_21C6_FDC2_BC79_B71A_079E_8164_76B0_6F6A_F911_4535_CCFA_F3B1_3240_33DF_2488_214C_0F0F_BF3A_52DB_6872_25C4_9F28_ABF8_90B5_5685_DA3E_4E5E_B629,
    512'h23B5_837B_57C8_8A29_AE67_D79D_8992_019E_F924_410A_6078_7DF9_D296_DB43_912E_24F9_455F_C485_AAB4_2ED1_F272_F5B1_4A00_0465_2B9A_A5A4_98AC_A883_3044_7ECB_5344_7F25,
    512'h7E46_1844_6F5F_FD2E_E9B7_42B2_1367_DADC_8679_213D_6B1C_74B0_4755_1478_BFC4_4F5D_7ED0_3F28_EDAA_291F_0CCC_50F4_C66D_B26E_ACB5_B8E2_8106_B498_0324_ACB1_DDC9_1BA3,
    512'h50BF_D5DB_F314_46AD_4A5F_0825_DE1D_377D_B9D7_9126_EEAE_7014_8DB4_F3E5_28B1_7A8F_6317_C2FE_4E25_2AF8_7393_0256_005B_696B_6F22_3641_8DD3_BA95_9A94_C58C_9A8F_A9E0,
    512'hA85F_EAED_F98A_2356_A52F_8412_EF0E_9BBE_DCEB_C893_7757_380A_46DA_79F2_9458_BD47_B18B_E17F_2712_957C_39C9_812B_002D_B4B5_B791_1B20_C6E9_DD4A_CD4A_62C6_4D47_D4F0,
    512'h542F_F576_FCC5_11AB_5297_C209_7787_4DDF_6E75_E449_BBAB_9C05_236D_3CF9_4A2C_5EA3_D8C5_F0BF_9389_4ABE_1CE4_C095_8016_DA5A_DBC8_8D90_6374_EEA5_66A5_3163_26A3_EA78,
    512'h2A17_FABB_7E62_88D5_A94B_E104_BBC3_A6EF_B73A_F224_DDD5_CE02_91B6_9E7C_A516_2F51_EC62_F85F_C9C4_A55F_0E72_604A_C00B_6D2D_6DE4_46C8_31BA_7752_B352_98B1_9351_F53C,
    512'h150B_FD5D_BF31_446A_D4A5_F082_5DE1_D377_DB9D_7912_6EEA_E701_48DB_4F3E_528B_17A8_F631_7C2F_E4E2_52AF_8739_3025_6005_B696_B6F2_2364_18DD_3BA9_59A9_4C58_C9A8_FA9E,
    512'h8A85_FEAE_DF98_A235_6A52_F841_2EF0_E9BB_EDCE_BC89_3775_7380_A46D_A79F_2945_8BD4_7B18_BE17_F271_2957_C39C_9812_B002_DB4B_5B79_11B2_0C6E_9DD4_ACD4_A62C_64D4_7D4F,
    512'hAADE_26AE_AB77_E920_8BAD_D55C_40D6_AECE_0C0C_5FFC_C09A_F38C_FC28_AA16_E3F1_98CB_E1F3_8261_C1C8_AADC_143B_6625_3B6C_DDF9_94C4_62E9_CB67_AE33_CD6C_C0C2_4601_1A96,
    512'hD56F_1357_55BB_F490_45D6_EAAE_206B_5767_0606_2FFE_604D_79C6_7E14_550B_71F8_CC65_F0F9_C130_E0E4_556E_0A1D_B312_9DB6_6EFC_CA62_3174_E5B3_D719_E6B6_6061_2300_8D4B,
    512'h852B_5052_6E66_4272_1C6F_DC2B_C79B_71A0_79E8_1647_6B06_F6AF_9114_535C_CFAF_3B13_2403_3DF2_4882_14C0_F0FB_F3A5_2DB6_8722_5C49_F28A_BF89_0B55_685D_A3E4_E5EB_6294,
    512'hC295_A829_3733_2139_0E37_EE15_E3CD_B8D0_3CF4_0B23_B583_7B57_C88A_29AE_67D7_9D89_9201_9EF9_2441_0A60_787D_F9D2_96DB_4391_2E24_F945_5FC4_85AA_B42E_D1F2_72F5_B14A,
    512'h614A_D414_9B99_909C_871B_F70A_F1E6_DC68_1E7A_0591_DAC1_BDAB_E445_14D7_33EB_CEC4_C900_CF7C_9220_8530_3C3E_FCE9_4B6D_A1C8_9712_7CA2_AFE2_42D5_5A17_68F9_397A_D8A5,
    512'hDF39_B3F3_8977_7074_7D09_52F9_AF5D_B427_F5D6_0370_B640_9499_5C3C_F3B2_EEA6_BA43_B8FF_BAD4_71E0_7CEF_EBEA_5458_C6DB_60B8_72F1_D461_9AA1_C1B3_360D_27A8_E8D6_4863
  };

  assign crc[15] = ^(DM[15] & data[511:0]);
  assign crc[14] = ^(DM[14] & data[511:0]);
  assign crc[13] = ^(DM[13] & data[511:0]);
  assign crc[12] = ^(DM[12] & data[511:0]);
  assign crc[11] = ^(DM[11] & data[511:0]);
  assign crc[10] = ^(DM[10] & data[511:0]);
  assign crc[9] = ^(DM[9] & data[511:0]);
  assign crc[8] = ^(DM[8] & data[511:0]);
  assign crc[7] = ^(DM[7] & data[511:0]);
  assign crc[6] = ^(DM[6] & data[511:0]);
  assign crc[5] = ^(DM[5] & data[511:0]);
  assign crc[4] = ^(DM[4] & data[511:0]);
  assign crc[3] = ^(DM[3] & data[511:0]);
  assign crc[2] = ^(DM[2] & data[511:0]);
  assign crc[1] = ^(DM[1] & data[511:0]);
  assign crc[0] = ^(DM[0] & data[511:0]);

endmodule

module crc_check#(

)(
  output logic crc_pass,
  output logic c2c_fail,
  input logic [527:0] data
);

  logic [15:0] crc;
  localparam [511:0] DM[16] = {
    512'hEF9C_D9F9_C4BB_B83A_3E84_A97C_D7AE_DA13_FAEB_01B8_5B20_4A4C_AE1E_79D9_7753_5D21_DC7F_DD6A_38F0_3E77_F5F5_2A2C_636D_B05C_3978_EA30_CD50_E0D9_9B06_93D4_746B_2431,
    512'h9852_B505_26E6_6427_21C6_FDC2_BC79_B71A_079E_8164_76B0_6F6A_F911_4535_CCFA_F3B1_3240_33DF_2488_214C_0F0F_BF3A_52DB_6872_25C4_9F28_ABF8_90B5_5685_DA3E_4E5E_B629,
    512'h23B5_837B_57C8_8A29_AE67_D79D_8992_019E_F924_410A_6078_7DF9_D296_DB43_912E_24F9_455F_C485_AAB4_2ED1_F272_F5B1_4A00_0465_2B9A_A5A4_98AC_A883_3044_7ECB_5344_7F25,
    512'h7E46_1844_6F5F_FD2E_E9B7_42B2_1367_DADC_8679_213D_6B1C_74B0_4755_1478_BFC4_4F5D_7ED0_3F28_EDAA_291F_0CCC_50F4_C66D_B26E_ACB5_B8E2_8106_B498_0324_ACB1_DDC9_1BA3,
    512'h50BF_D5DB_F314_46AD_4A5F_0825_DE1D_377D_B9D7_9126_EEAE_7014_8DB4_F3E5_28B1_7A8F_6317_C2FE_4E25_2AF8_7393_0256_005B_696B_6F22_3641_8DD3_BA95_9A94_C58C_9A8F_A9E0,
    512'hA85F_EAED_F98A_2356_A52F_8412_EF0E_9BBE_DCEB_C893_7757_380A_46DA_79F2_9458_BD47_B18B_E17F_2712_957C_39C9_812B_002D_B4B5_B791_1B20_C6E9_DD4A_CD4A_62C6_4D47_D4F0,
    512'h542F_F576_FCC5_11AB_5297_C209_7787_4DDF_6E75_E449_BBAB_9C05_236D_3CF9_4A2C_5EA3_D8C5_F0BF_9389_4ABE_1CE4_C095_8016_DA5A_DBC8_8D90_6374_EEA5_66A5_3163_26A3_EA78,
    512'h2A17_FABB_7E62_88D5_A94B_E104_BBC3_A6EF_B73A_F224_DDD5_CE02_91B6_9E7C_A516_2F51_EC62_F85F_C9C4_A55F_0E72_604A_C00B_6D2D_6DE4_46C8_31BA_7752_B352_98B1_9351_F53C,
    512'h150B_FD5D_BF31_446A_D4A5_F082_5DE1_D377_DB9D_7912_6EEA_E701_48DB_4F3E_528B_17A8_F631_7C2F_E4E2_52AF_8739_3025_6005_B696_B6F2_2364_18DD_3BA9_59A9_4C58_C9A8_FA9E,
    512'h8A85_FEAE_DF98_A235_6A52_F841_2EF0_E9BB_EDCE_BC89_3775_7380_A46D_A79F_2945_8BD4_7B18_BE17_F271_2957_C39C_9812_B002_DB4B_5B79_11B2_0C6E_9DD4_ACD4_A62C_64D4_7D4F,
    512'hAADE_26AE_AB77_E920_8BAD_D55C_40D6_AECE_0C0C_5FFC_C09A_F38C_FC28_AA16_E3F1_98CB_E1F3_8261_C1C8_AADC_143B_6625_3B6C_DDF9_94C4_62E9_CB67_AE33_CD6C_C0C2_4601_1A96,
    512'hD56F_1357_55BB_F490_45D6_EAAE_206B_5767_0606_2FFE_604D_79C6_7E14_550B_71F8_CC65_F0F9_C130_E0E4_556E_0A1D_B312_9DB6_6EFC_CA62_3174_E5B3_D719_E6B6_6061_2300_8D4B,
    512'h852B_5052_6E66_4272_1C6F_DC2B_C79B_71A0_79E8_1647_6B06_F6AF_9114_535C_CFAF_3B13_2403_3DF2_4882_14C0_F0FB_F3A5_2DB6_8722_5C49_F28A_BF89_0B55_685D_A3E4_E5EB_6294,
    512'hC295_A829_3733_2139_0E37_EE15_E3CD_B8D0_3CF4_0B23_B583_7B57_C88A_29AE_67D7_9D89_9201_9EF9_2441_0A60_787D_F9D2_96DB_4391_2E24_F945_5FC4_85AA_B42E_D1F2_72F5_B14A,
    512'h614A_D414_9B99_909C_871B_F70A_F1E6_DC68_1E7A_0591_DAC1_BDAB_E445_14D7_33EB_CEC4_C900_CF7C_9220_8530_3C3E_FCE9_4B6D_A1C8_9712_7CA2_AFE2_42D5_5A17_68F9_397A_D8A5,
    512'hDF39_B3F3_8977_7074_7D09_52F9_AF5D_B427_F5D6_0370_B640_9499_5C3C_F3B2_EEA6_BA43_B8FF_BAD4_71E0_7CEF_EBEA_5458_C6DB_60B8_72F1_D461_9AA1_C1B3_360D_27A8_E8D6_4863
  };

  assign crc[15] = ^(DM[15] & data[511:0]);
  assign crc[14] = ^(DM[14] & data[511:0]);
  assign crc[13] = ^(DM[13] & data[511:0]);
  assign crc[12] = ^(DM[12] & data[511:0]);
  assign crc[11] = ^(DM[11] & data[511:0]);
  assign crc[10] = ^(DM[10] & data[511:0]);
  assign crc[9] = ^(DM[9] & data[511:0]);
  assign crc[8] = ^(DM[8] & data[511:0]);
  assign crc[7] = ^(DM[7] & data[511:0]);
  assign crc[6] = ^(DM[6] & data[511:0]);
  assign crc[5] = ^(DM[5] & data[511:0]);
  assign crc[4] = ^(DM[4] & data[511:0]);
  assign crc[3] = ^(DM[3] & data[511:0]);
  assign crc[2] = ^(DM[2] & data[511:0]);
  assign crc[1] = ^(DM[1] & data[511:0]);
  assign crc[0] = ^(DM[0] & data[511:0]);

  assign crc_pass = (crc == data[15:0])? 'h1: 'h0;
  assign crc_fail = (crc != data[15:0])? 'h1: 'h0;

endmodule

module host_rx_path #(

)(
  cxl_host_rx_dl_if.rx_mp host_rx_dl_if,
  output logic retry_ack_snt,
  output logic retry_req_snt,
  output logic phy_link_rst,
  input logic phy_rst,
  input logic phy_reinit,
  input logic phy_link_up,
  output d2h_req_txn_t d2h_req_txn[4],
  output d2h_rsp_txn_t d2h_rsp_txn[2],
  output d2h_data_pkt_t d2h_data_pkt[4],
  output s2m_ndr_txn_t s2m_ndr_txn[3],
  output s2m_drs_pkt_t s2m_drs_pkt[3],
  output logic ack,
  output logic ack_ret_val,
  output logic [7:0] ack_ret,
  output logic init_done,
  output logic crdt_val,
  output logic crdt_rsp_cm,
  output logic crdt_req_cm,
  output logic crdt_data_cm,
  output logic [2:0] crdt_rsp,
  output logic [2:0] crdt_req,
  output logic [2:0] crdt_data
);

  localparam SLOT1_OFFSET = 128;
  localparam SLOT2_OFFSET = 256;
  localparam SLOT3_OFFSET = 384;
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
  logic crc_pass_d;
  logic crc_fail_d;
  logic retryable_flit;
  logic non_retryable_flit;
  logic retry_req_rcvd;
  logic [7:0] retry_ack_num_retry;
  logic retry_ack_empty_bit;
  logic retry_ack_rcvd;
  logic host_rx_dl_if_d_valid;//assuming crc checker takes 1 cycle to tell crc pass or fail
  logic [511:0] host_rx_dl_if_d_data;//assuming crc checker takes 1 cycle to tell crc pass or fail
  logic retry_frame_detect;
  logic retry_req_detect;
  logic retry_ack_detect;
  logic retry_idle_detect;
  logic [3:0] data_slot[5];
  logic [3:0] data_slot_d[5];
  d2h_data_pkt_t d2h_data_pkt_d[4];
  s2m_drs_pkt_t s2m_drs_pkt_d[3];
  logic [2:0] ack_count;
  logic [2:0] ack_count_d;
  logic llcrd_flit;

  assign init_done          = (host_rx_dl_if_d_data[39:36] == 'h8) && (host_rx_dl_if_d_data[35:32] == 'hc) && (host_rx_dl_if_d_data[0] == 'h1) && (host_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign retry_frame_detect = (host_rx_dl_if_d_data[39:36] == 'h3) && (host_rx_dl_if_d_data[35:32] == 'h1) && (host_rx_dl_if_d_data[0] == 'h1) && (host_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign retry_idle_detect  = (host_rx_dl_if_d_data[39:36] == 'h0) && (host_rx_dl_if_d_data[35:32] == 'h1) && (host_rx_dl_if_d_data[0] == 'h1) && (host_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign retry_req_detect   = (host_rx_dl_if_d_data[39:36] == 'h1) && (host_rx_dl_if_d_data[35:32] == 'h1) && (host_rx_dl_if_d_data[0] == 'h1) && (host_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign retry_ack_detect   = (host_rx_dl_if_d_data[39:36] == 'h2) && (host_rx_dl_if_d_data[35:32] == 'h1) && (host_rx_dl_if_d_data[0] == 'h1) && (host_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign llcrd_flit         = (host_rx_dl_if_d_data[39:36] == 'h1) && (host_rx_dl_if_d_data[35:32] == 'h0) && (host_rx_dl_if_d_data[0] == 'h1) && (host_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign non_retryable_flit = (retry_idle_detect) || (retry_frame_detect) || (retry_req_detect) || (retry_ack_detect);
  assign retryable_flit     = (!retry_idle_detect) && (!retry_frame_detect) && (!retry_req_detect) && (!retry_ack_detect);
  assign crdt_val           = (llcrd_flit || (host_rx_dl_if_d_data[0] == 'h0)) && (host_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign crdt_data_cm       = crdt_val && host_rx_dl_if_d_data[31];
  assign crdt_data          = crdt_val && host_rx_dl_if_d_data[30:28];
  assign crdt_req_cm        = crdt_val && host_rx_dl_if_d_data[27];
  assign crdt_req           = crdt_val && host_rx_dl_if_d_data[26:24];
  assign crdt_rsp_cm        = crdt_val && host_rx_dl_if_d_data[23];
  assign crdt_rsp           = crdt_val && host_rx_dl_if_d_data[22:20];
  
  function automatic void header0(
    input logic [511:0] data, 
    ref d2h_data_pkt_t d2h_data_pkt[4], 
    ref d2h_rsp_txn_t d2h_rsp_txn[2], 
    ref s2m_ndr_txn_t s2m_ndr_txn[3]
  );

    d2h_data_pkt[0].pending_data_slot          = 'hf;
    d2h_data_pkt[0].d2h_data_txn.valid         = data[32];
    d2h_data_pkt[0].d2h_data_txn.uqid          = data[44:33];
    d2h_data_pkt[0].d2h_data_txn.chunkvalid    = data[45];
    d2h_data_pkt[0].d2h_data_txn.bogus         = data[46];
    d2h_data_pkt[0].d2h_data_txn.poison        = data[47];
    d2h_rsp_txn[0].valid                       = data[49];
    d2h_rsp_txn[0].opcode                      = d2h_rsp_opcode_t'(data[54:50]);//get elab error if you directly assign
    d2h_rsp_txn[0].uqid                        = data[66:55];
    d2h_rsp_txn[1].valid                       = data[69];
    d2h_rsp_txn[1].opcode                      = d2h_rsp_opcode_t'(data[74:70]);
    d2h_rsp_txn[1].uqid                        = data[86:75];
    s2m_ndr_txn[0].valid                       = data[89];
    s2m_ndr_txn[0].opcode                   = s2m_ndr_opcode_t'(data[92:90]);
    s2m_ndr_txn[0].metafield                   = metafield_t'(data[94:93]);
    s2m_ndr_txn[0].metavalue                   = metavalue_t'(data[96:95]);
    s2m_ndr_txn[0].tag                         = data[112:97];

  endfunction

  function automatic void header1(
    input logic [511:0] data, 
    ref d2h_req_txn_t d2h_req_txn[4], 
    ref d2h_data_pkt_t d2h_data_pkt[4]
  );

    d2h_req_txn[0].valid                     = data[32];
    d2h_req_txn[0].opcode                    = d2h_req_opcode_t'(data[37:33]);
    d2h_req_txn[0].cqid                      = data[49:38];
    d2h_req_txn[0].nt                        = data[50];
    d2h_req_txn[0].address                   = data[103:58];
    d2h_data_pkt[0].pending_data_slot        = 'hf;
    d2h_data_pkt[0].d2h_data_txn.valid       = data[111];
    d2h_data_pkt[0].d2h_data_txn.uqid        = data[123:112];
    d2h_data_pkt[0].d2h_data_txn.chunkvalid  = data[124];
    d2h_data_pkt[0].d2h_data_txn.bogus       = data[125];
    d2h_data_pkt[0].d2h_data_txn.poison      = data[126];

  endfunction

  function automatic void header2(
    input logic [511:0] data, 
    ref d2h_data_pkt_t d2h_data_pkt[4], 
    ref d2h_rsp_txn_t d2h_rsp_txn[2]
  );

    d2h_data_pkt[0].pending_data_slot        = 'hf;
    d2h_data_pkt[0].d2h_data_txn.valid       = data[32];
    d2h_data_pkt[0].d2h_data_txn.uqid        = data[44:33];
    d2h_data_pkt[0].d2h_data_txn.chunkvalid  = data[45];
    d2h_data_pkt[0].d2h_data_txn.bogus       = data[46];
    d2h_data_pkt[0].d2h_data_txn.poison      = data[47];
    d2h_data_pkt[1].pending_data_slot        = 'hf;
    d2h_data_pkt[1].d2h_data_txn.valid       = data[49];
    d2h_data_pkt[1].d2h_data_txn.uqid        = data[61:50];
    d2h_data_pkt[1].d2h_data_txn.chunkvalid  = data[62];
    d2h_data_pkt[1].d2h_data_txn.bogus       = data[63];
    d2h_data_pkt[1].d2h_data_txn.poison      = data[64];
    d2h_data_pkt[2].pending_data_slot        = 'hf;
    d2h_data_pkt[2].d2h_data_txn.valid       = data[66];
    d2h_data_pkt[2].d2h_data_txn.uqid        = data[78:67];
    d2h_data_pkt[2].d2h_data_txn.chunkvalid  = data[79];
    d2h_data_pkt[2].d2h_data_txn.bogus       = data[80];
    d2h_data_pkt[2].d2h_data_txn.poison      = data[81];
    d2h_data_pkt[3].pending_data_slot        = 'hf;
    d2h_data_pkt[3].d2h_data_txn.valid       = data[83];
    d2h_data_pkt[3].d2h_data_txn.uqid        = data[95:84];
    d2h_data_pkt[3].d2h_data_txn.chunkvalid  = data[96];
    d2h_data_pkt[3].d2h_data_txn.bogus       = data[97];
    d2h_data_pkt[3].d2h_data_txn.poison      = data[98];
    d2h_rsp_txn[0].valid                     = data[100];
    d2h_rsp_txn[0].opcode                    = d2h_rsp_opcode_t'(data[105:101]);
    d2h_rsp_txn[0].uqid                      = data[117:106];

  endfunction

  function automatic void header3(
    input logic [511:0] data, 
    ref s2m_drs_pkt_t s2m_drs_pkt[3], 
    ref s2m_ndr_txn_t s2m_ndr_txn[3]
  );

    s2m_drs_pkt[0].pending_data_slot        = 'hf;
    s2m_drs_pkt[0].s2m_drs_txn.valid        = data[32];
    s2m_drs_pkt[0].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[35:33]);
    s2m_drs_pkt[0].s2m_drs_txn.metafield    = metafield_t'(data[37:36]);
    s2m_drs_pkt[0].s2m_drs_txn.metavalue    = metavalue_t'(data[39:38]);
    s2m_drs_pkt[0].s2m_drs_txn.tag          = data[55:40];
    s2m_drs_pkt[0].s2m_drs_txn.poison       = data[56];
    s2m_ndr_txn[0].valid                    = data[72];
    s2m_ndr_txn[0].opcode                = s2m_ndr_opcode_t'(data[75:73]);
    s2m_ndr_txn[0].metafield                = metafield_t'(data[77:76]);
    s2m_ndr_txn[0].metavalue                = metavalue_t'(data[79:78]);
    s2m_ndr_txn[0].tag                      = data[95:80];

  endfunction

  function automatic void header4(
    input logic [511:0] data, 
    ref s2m_ndr_txn_t s2m_ndr_txn[3]
  );

    s2m_ndr_txn[0].valid        = data[32];
    s2m_ndr_txn[0].opcode    = s2m_ndr_opcode_t'(data[35:33]);
    s2m_ndr_txn[0].metafield    = metafield_t'(data[37:36]);
    s2m_ndr_txn[0].metavalue    = metavalue_t'(data[39:38]);
    s2m_ndr_txn[0].tag          = data[55:40];
    s2m_ndr_txn[1].valid        = data[60];
    s2m_ndr_txn[1].opcode    = s2m_ndr_opcode_t'(data[63:61]);
    s2m_ndr_txn[1].metafield    = metafield_t'(data[65:64]);
    s2m_ndr_txn[1].metavalue    = metavalue_t'(data[67:66]);
    s2m_ndr_txn[1].tag          = data[83:68];

  endfunction

  function automatic void header5(
    input logic [511:0] data, 
    ref s2m_drs_pkt_t s2m_drs_pkt[3]
  );

    s2m_drs_pkt[0].pending_data_slot        = 'hf;
    s2m_drs_pkt[0].s2m_drs_txn.valid        = data[32];
    s2m_drs_pkt[0].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[35:33]);
    s2m_drs_pkt[0].s2m_drs_txn.metafield    = metafield_t'(data[37:36]);
    s2m_drs_pkt[0].s2m_drs_txn.metavalue    = metavalue_t'(data[39:38]);
    s2m_drs_pkt[0].s2m_drs_txn.tag          = data[55:40];
    s2m_drs_pkt[0].s2m_drs_txn.poison       = data[56];
    s2m_drs_pkt[1].pending_data_slot        = 'hf;
    s2m_drs_pkt[1].s2m_drs_txn.valid        = data[72];
    s2m_drs_pkt[1].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[75:73]);
    s2m_drs_pkt[1].s2m_drs_txn.metafield    = metafield_t'(data[77:76]);
    s2m_drs_pkt[1].s2m_drs_txn.metavalue    = metavalue_t'(data[79:78]);
    s2m_drs_pkt[1].s2m_drs_txn.tag          = data[95:80];
    s2m_drs_pkt[1].s2m_drs_txn.poison       = data[96];

  endfunction

  function automatic void generic0(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref d2h_data_pkt_t d2h_data_pkt[4],
    ref s2m_drs_pkt_t s2m_drs_pkt[3]
    //inout d2h_req_txn_t d2h_data_pkt[4],
    //inout s2m_drs_pkt_t s2m_drs_pkt[3]
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
          s2m_drs_pkt[2].s2m_drs_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
          s2m_drs_pkt[2].pending_data_slot = 'h0;
          /*if(s2m_drs_pkt[3].pending_data_slot != 'h0) begin
            s2m_drs_pkt[3].s2m_drs_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
            s2m_drs_pkt[3].pending_data_slot = 'he;
          end*/
        end else if(s2m_drs_pkt[2].pending_data_slot == 'hc) begin
          s2m_drs_pkt[2].s2m_drs_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
          s2m_drs_pkt[2].pending_data_slot = 'h0;
          /*if(s2m_drs_pkt[3].pending_data_slot != 'h0) begin
            s2m_drs_pkt[3].s2m_drs_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
            s2m_drs_pkt[3].pending_data_slot = 'hc;
          end*/
        end else if(s2m_drs_pkt[2].pending_data_slot == 'h8) begin
          s2m_drs_pkt[2].s2m_drs_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
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
          d2h_data_pkt[2].d2h_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
          d2h_data_pkt[2].pending_data_slot = 'h0;
          if(d2h_data_pkt[3].pending_data_slot != 'h0) begin
            d2h_data_pkt[3].d2h_data_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
            d2h_data_pkt[3].pending_data_slot = 'he;
          end
        end else if(d2h_data_pkt[2].pending_data_slot == 'hc) begin
          d2h_data_pkt[2].d2h_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
          d2h_data_pkt[2].pending_data_slot = 'h0;
          if(d2h_data_pkt[3].pending_data_slot != 'h0) begin
            d2h_data_pkt[3].d2h_data_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
            d2h_data_pkt[3].pending_data_slot = 'hc;
          end
        end else if(d2h_data_pkt[2].pending_data_slot == 'h8) begin
          d2h_data_pkt[2].d2h_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
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
  
  function automatic void generic1(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref d2h_req_txn_t d2h_req_txn[4],
    ref d2h_rsp_txn_t d2h_rsp_txn[2]
  );

    if(slot_sel == 'h1) begin
      d2h_req_txn[0].valid        = data[(SLOT1_OFFSET+0)];
      d2h_req_txn[0].opcode       = d2h_req_opcode_t'(data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+1)]);
      d2h_req_txn[0].cqid         = data[(SLOT1_OFFSET+17):(SLOT1_OFFSET+6)];
      d2h_req_txn[0].nt           = data[(SLOT1_OFFSET+18)];
      d2h_req_txn[0].address      = data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+26)];
      d2h_rsp_txn[0].valid        = data[(SLOT1_OFFSET+79)];
      d2h_rsp_txn[0].opcode       = d2h_rsp_opcode_t'(data[(SLOT1_OFFSET+84):(SLOT1_OFFSET+80)]);
      d2h_rsp_txn[0].uqid         = data[(SLOT1_OFFSET+96):(SLOT1_OFFSET+85)];
      d2h_rsp_txn[1].valid        = data[(SLOT1_OFFSET+99)];
      d2h_rsp_txn[1].opcode       = d2h_rsp_opcode_t'(data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+100)]);
      d2h_rsp_txn[1].uqid         = data[(SLOT1_OFFSET+116):(SLOT1_OFFSET+105)];
    end else if(slot_sel == 'h2) begin
      d2h_req_txn[0].valid        = data[(SLOT2_OFFSET+0)];
      d2h_req_txn[0].opcode       = d2h_req_opcode_t'(data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+1)]);
      d2h_req_txn[0].cqid         = data[(SLOT2_OFFSET+17):(SLOT2_OFFSET+6)];
      d2h_req_txn[0].nt           = data[(SLOT2_OFFSET+18)];
      d2h_req_txn[0].address      = data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+26)];
      d2h_rsp_txn[0].valid        = data[(SLOT2_OFFSET+79)];
      d2h_rsp_txn[0].opcode       = d2h_rsp_opcode_t'(data[(SLOT2_OFFSET+84):(SLOT2_OFFSET+80)]);
      d2h_rsp_txn[0].uqid         = data[(SLOT2_OFFSET+96):(SLOT2_OFFSET+85)];
      d2h_rsp_txn[1].valid        = data[(SLOT2_OFFSET+99)];
      d2h_rsp_txn[1].opcode       = d2h_rsp_opcode_t'(data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+100)]);
      d2h_rsp_txn[1].uqid         = data[(SLOT2_OFFSET+116):(SLOT2_OFFSET+105)];
    end else if(slot_sel == 'h3) begin
      d2h_req_txn[0].valid        = data[(SLOT3_OFFSET+0)];
      d2h_req_txn[0].opcode       = d2h_req_opcode_t'(data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+1)]);
      d2h_req_txn[0].cqid         = data[(SLOT3_OFFSET+17):(SLOT3_OFFSET+6)];
      d2h_req_txn[0].nt           = data[(SLOT3_OFFSET+18)];
      d2h_req_txn[0].address      = data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+26)];
      d2h_rsp_txn[0].valid        = data[(SLOT3_OFFSET+79)];
      d2h_rsp_txn[0].opcode       = d2h_rsp_opcode_t'(data[(SLOT3_OFFSET+84):(SLOT3_OFFSET+80)]);
      d2h_rsp_txn[0].uqid         = data[(SLOT3_OFFSET+96):(SLOT3_OFFSET+85)];
      d2h_rsp_txn[1].valid        = data[(SLOT3_OFFSET+99)];
      d2h_rsp_txn[1].opcode       = d2h_rsp_opcode_t'(data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+100)]);
      d2h_rsp_txn[1].uqid         = data[(SLOT3_OFFSET+116):(SLOT3_OFFSET+105)];
    end else begin
      d2h_req_txn[0].valid = 'hX;
      d2h_rsp_txn[0].valid = 'hX;
      d2h_rsp_txn[1].valid = 'hX;
    end

  endfunction

  function automatic void generic2(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref d2h_req_txn_t d2h_req_txn[4],
    ref d2h_data_pkt_t d2h_data_pkt[4],
    ref d2h_rsp_txn_t d2h_rsp_txn[2]
  );

    if(slot_sel == 'h1) begin
      d2h_req_txn[0].valid                    = data[(SLOT1_OFFSET+0)];
      d2h_req_txn[0].opcode                   = d2h_req_opcode_t'(data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+1)]);
      d2h_req_txn[0].cqid                     = data[(SLOT1_OFFSET+17):(SLOT1_OFFSET+6)];
      d2h_req_txn[0].nt                       = data[(SLOT1_OFFSET+18)];
      d2h_req_txn[0].address                  = data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+26)];
      d2h_data_pkt[0].pending_data_slot       = 'hf;
      d2h_data_pkt[0].d2h_data_txn.valid      = data[(SLOT1_OFFSET+79)];
      d2h_data_pkt[0].d2h_data_txn.uqid       = data[(SLOT1_OFFSET+91):(SLOT1_OFFSET+80)];
      d2h_data_pkt[0].d2h_data_txn.chunkvalid = data[(SLOT1_OFFSET+92)];
      d2h_data_pkt[0].d2h_data_txn.bogus      = data[(SLOT1_OFFSET+93)];
      d2h_data_pkt[0].d2h_data_txn.poison     = data[(SLOT1_OFFSET+94)];
      d2h_rsp_txn[0].valid                    = data[(SLOT1_OFFSET+96)];
      d2h_rsp_txn[0].opcode                   = d2h_rsp_opcode_t'(data[(SLOT1_OFFSET+101):(SLOT1_OFFSET+97)]);
      d2h_rsp_txn[0].uqid                     = data[(SLOT1_OFFSET+113):(SLOT1_OFFSET+102)];
    end else if(slot_sel == 'h2) begin
      d2h_req_txn[0].valid                    = data[(SLOT2_OFFSET+0)];
      d2h_req_txn[0].opcode                   = d2h_req_opcode_t'(data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+1)]);
      d2h_req_txn[0].cqid                     = data[(SLOT2_OFFSET+17):(SLOT2_OFFSET+6)];
      d2h_req_txn[0].nt                       = data[(SLOT2_OFFSET+18)];
      d2h_req_txn[0].address                  = data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+26)];
      d2h_data_pkt[0].pending_data_slot       = 'hf;
      d2h_data_pkt[0].d2h_data_txn.valid      = data[(SLOT2_OFFSET+79)];
      d2h_data_pkt[0].d2h_data_txn.uqid       = data[(SLOT2_OFFSET+91):(SLOT2_OFFSET+80)];
      d2h_data_pkt[0].d2h_data_txn.chunkvalid = data[(SLOT2_OFFSET+92)];
      d2h_data_pkt[0].d2h_data_txn.bogus      = data[(SLOT2_OFFSET+93)];
      d2h_data_pkt[0].d2h_data_txn.poison     = data[(SLOT2_OFFSET+94)];
      d2h_rsp_txn[0].valid                    = data[(SLOT2_OFFSET+96)];
      d2h_rsp_txn[0].opcode                   = d2h_rsp_opcode_t'(data[(SLOT2_OFFSET+101):(SLOT2_OFFSET+97)]);
      d2h_rsp_txn[0].uqid                     = data[(SLOT2_OFFSET+113):(SLOT2_OFFSET+102)];
    end else if(slot_sel == 'h3) begin
      d2h_req_txn[0].valid                    = data[(SLOT3_OFFSET+0)];
      d2h_req_txn[0].opcode                   = d2h_req_opcode_t'(data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+1)]);
      d2h_req_txn[0].cqid                     = data[(SLOT3_OFFSET+17):(SLOT3_OFFSET+6)];
      d2h_req_txn[0].nt                       = data[(SLOT3_OFFSET+18)];
      d2h_req_txn[0].address                  = data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+26)];
      d2h_data_pkt[0].pending_data_slot       = 'hf;
      d2h_data_pkt[0].d2h_data_txn.valid      = data[(SLOT3_OFFSET+79)];
      d2h_data_pkt[0].d2h_data_txn.uqid       = data[(SLOT3_OFFSET+91):(SLOT3_OFFSET+80)];
      d2h_data_pkt[0].d2h_data_txn.chunkvalid = data[(SLOT3_OFFSET+92)];
      d2h_data_pkt[0].d2h_data_txn.bogus      = data[(SLOT3_OFFSET+93)];
      d2h_data_pkt[0].d2h_data_txn.poison     = data[(SLOT3_OFFSET+94)];
      d2h_rsp_txn[0].valid                    = data[(SLOT3_OFFSET+96)];
      d2h_rsp_txn[0].opcode                   = d2h_rsp_opcode_t'(data[(SLOT3_OFFSET+101):(SLOT3_OFFSET+97)]);
      d2h_rsp_txn[0].uqid                     = data[(SLOT3_OFFSET+113):(SLOT3_OFFSET+102)];
    end else begin
      d2h_req_txn[0].valid = 'hX;
      d2h_data_pkt[0].d2h_data_txn.valid = 'hX;
      d2h_rsp_txn[0].valid = 'hX;
    end

  endfunction

  function automatic void generic3(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref d2h_data_pkt_t d2h_data_pkt[4]
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
      d2h_data_pkt[0].d2h_data_txn.valid        = 'hX;
      d2h_data_pkt[1].d2h_data_txn.valid        = 'hX;
      d2h_data_pkt[2].d2h_data_txn.valid        = 'hX;
      d2h_data_pkt[3].d2h_data_txn.valid        = 'hX;
    end

  endfunction

  function automatic void generic4(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref s2m_drs_pkt_t s2m_drs_pkt[3],
    ref s2m_ndr_txn_t s2m_ndr_txn[3]
  );

    if(slot_sel == 'h1) begin
      s2m_drs_pkt[0].pending_data_slot     = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid     = data[(SLOT1_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.opcode = s2m_drs_opcode_t'(data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]);
      s2m_drs_pkt[0].s2m_drs_txn.metafield = metafield_t'(data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]);
      s2m_drs_pkt[0].s2m_drs_txn.metavalue = metavalue_t'(data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]);
      s2m_drs_pkt[0].s2m_drs_txn.tag       = data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison    = data[(SLOT1_OFFSET+24)];
      s2m_ndr_txn[0].valid                 = data[(SLOT1_OFFSET+40)];
      s2m_ndr_txn[0].opcode             = s2m_ndr_opcode_t'(data[(SLOT1_OFFSET+43):(SLOT1_OFFSET+41)]);
      s2m_ndr_txn[0].metafield             = metafield_t'(data[(SLOT1_OFFSET+45):(SLOT1_OFFSET+44)]);
      s2m_ndr_txn[0].metavalue             = metavalue_t'(data[(SLOT1_OFFSET+47):(SLOT1_OFFSET+46)]);
      s2m_ndr_txn[0].tag                   = data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+48)];
      s2m_ndr_txn[1].valid                 = data[(SLOT1_OFFSET+68)];
      s2m_ndr_txn[1].opcode             = s2m_ndr_opcode_t'(data[(SLOT1_OFFSET+71):(SLOT1_OFFSET+69)]);
      s2m_ndr_txn[1].metafield             = metafield_t'(data[(SLOT1_OFFSET+73):(SLOT1_OFFSET+72)]);
      s2m_ndr_txn[1].metavalue             = metavalue_t'(data[(SLOT1_OFFSET+75):(SLOT1_OFFSET+74)]);
      s2m_ndr_txn[1].tag                   = data[(SLOT1_OFFSET+91):(SLOT1_OFFSET+76)];
    end else if(slot_sel == 'h2) begin
      s2m_drs_pkt[0].pending_data_slot     = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid     = data[(SLOT2_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.opcode = s2m_drs_opcode_t'(data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]);
      s2m_drs_pkt[0].s2m_drs_txn.metafield = metafield_t'(data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]);
      s2m_drs_pkt[0].s2m_drs_txn.metavalue = metavalue_t'(data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]);
      s2m_drs_pkt[0].s2m_drs_txn.tag       = data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison    = data[(SLOT2_OFFSET+24)];
      s2m_ndr_txn[0].valid                 = data[(SLOT2_OFFSET+40)];
      s2m_ndr_txn[0].opcode             = s2m_ndr_opcode_t'(data[(SLOT2_OFFSET+43):(SLOT2_OFFSET+41)]);
      s2m_ndr_txn[0].metafield             = metafield_t'(data[(SLOT2_OFFSET+45):(SLOT2_OFFSET+44)]);
      s2m_ndr_txn[0].metavalue             = metavalue_t'(data[(SLOT2_OFFSET+47):(SLOT2_OFFSET+46)]);
      s2m_ndr_txn[0].tag                   = data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+48)];
      s2m_ndr_txn[1].valid                 = data[(SLOT2_OFFSET+68)];
      s2m_ndr_txn[1].opcode             = s2m_ndr_opcode_t'(data[(SLOT2_OFFSET+71):(SLOT2_OFFSET+69)]);
      s2m_ndr_txn[1].metafield             = metafield_t'(data[(SLOT2_OFFSET+73):(SLOT2_OFFSET+72)]);
      s2m_ndr_txn[1].metavalue             = metavalue_t'(data[(SLOT2_OFFSET+75):(SLOT2_OFFSET+74)]);
      s2m_ndr_txn[1].tag                   = data[(SLOT2_OFFSET+91):(SLOT2_OFFSET+76)];
    end else if(slot_sel == 'h3) begin
      s2m_drs_pkt[0].pending_data_slot     = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid     = data[(SLOT3_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.opcode = s2m_drs_opcode_t'(data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]);
      s2m_drs_pkt[0].s2m_drs_txn.metafield = metafield_t'(data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]);
      s2m_drs_pkt[0].s2m_drs_txn.metavalue = metavalue_t'(data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]);
      s2m_drs_pkt[0].s2m_drs_txn.tag       = data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison    = data[(SLOT3_OFFSET+24)];
      s2m_ndr_txn[0].valid                 = data[(SLOT3_OFFSET+40)];
      s2m_ndr_txn[0].opcode             = s2m_ndr_opcode_t'(data[(SLOT3_OFFSET+43):(SLOT3_OFFSET+41)]);
      s2m_ndr_txn[0].metafield             = metafield_t'(data[(SLOT3_OFFSET+45):(SLOT3_OFFSET+44)]);
      s2m_ndr_txn[0].metavalue             = metavalue_t'(data[(SLOT3_OFFSET+47):(SLOT3_OFFSET+46)]);
      s2m_ndr_txn[0].tag                   = data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+48)];
      s2m_ndr_txn[1].valid                 = data[(SLOT3_OFFSET+68)];
      s2m_ndr_txn[1].opcode             = s2m_ndr_opcode_t'(data[(SLOT3_OFFSET+71):(SLOT3_OFFSET+69)]);
      s2m_ndr_txn[1].metafield             = metafield_t'(data[(SLOT3_OFFSET+73):(SLOT3_OFFSET+72)]);
      s2m_ndr_txn[1].metavalue             = metavalue_t'(data[(SLOT3_OFFSET+75):(SLOT3_OFFSET+74)]);
      s2m_ndr_txn[1].tag                   = data[(SLOT3_OFFSET+91):(SLOT3_OFFSET+76)];
    end else begin
      s2m_drs_pkt[0].s2m_drs_txn.valid = 'hX;
      s2m_ndr_txn[0].valid = 'hX;
      s2m_ndr_txn[1].valid = 'hX;
    end

  endfunction

  function automatic void generic5(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref s2m_ndr_txn_t s2m_ndr_txn[3]
  );

    if(slot_sel == 'h1) begin
      s2m_ndr_txn[0].valid        = data[(SLOT1_OFFSET+0)];
      s2m_ndr_txn[0].opcode    = s2m_ndr_opcode_t'(data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]);
      s2m_ndr_txn[0].metafield    = metafield_t'(data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]);
      s2m_ndr_txn[0].metavalue    = metavalue_t'(data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]);
      s2m_ndr_txn[0].tag          = data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)];
      s2m_ndr_txn[1].valid        = data[(SLOT1_OFFSET+28)];
      s2m_ndr_txn[1].opcode    = s2m_ndr_opcode_t'(data[(SLOT1_OFFSET+31):(SLOT1_OFFSET+29)]);
      s2m_ndr_txn[1].metafield    = metafield_t'(data[(SLOT1_OFFSET+33):(SLOT1_OFFSET+32)]);
      s2m_ndr_txn[1].metavalue    = metavalue_t'(data[(SLOT1_OFFSET+35):(SLOT1_OFFSET+34)]);
      s2m_ndr_txn[1].tag          = data[(SLOT1_OFFSET+51):(SLOT1_OFFSET+36)];
      s2m_ndr_txn[2].valid        = data[(SLOT1_OFFSET+56)];
      s2m_ndr_txn[2].opcode    = s2m_ndr_opcode_t'(data[(SLOT1_OFFSET+59):(SLOT1_OFFSET+57)]);
      s2m_ndr_txn[2].metafield    = metafield_t'(data[(SLOT1_OFFSET+61):(SLOT1_OFFSET+60)]);
      s2m_ndr_txn[2].metavalue    = metavalue_t'(data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+62)]);
      s2m_ndr_txn[2].tag          = data[(SLOT1_OFFSET+79):(SLOT1_OFFSET+64)];
    end else if(slot_sel == 'h2) begin
      s2m_ndr_txn[0].valid        = data[(SLOT2_OFFSET+0)];
      s2m_ndr_txn[0].opcode    = s2m_ndr_opcode_t'(data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]);
      s2m_ndr_txn[0].metafield    = metafield_t'(data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]);
      s2m_ndr_txn[0].metavalue    = metavalue_t'(data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]);
      s2m_ndr_txn[0].tag          = data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)];
      s2m_ndr_txn[1].valid        = data[(SLOT2_OFFSET+28)];
      s2m_ndr_txn[1].opcode    = s2m_ndr_opcode_t'(data[(SLOT2_OFFSET+31):(SLOT2_OFFSET+29)]);
      s2m_ndr_txn[1].metafield    = metafield_t'(data[(SLOT2_OFFSET+33):(SLOT2_OFFSET+32)]);
      s2m_ndr_txn[1].metavalue    = metavalue_t'(data[(SLOT2_OFFSET+35):(SLOT2_OFFSET+34)]);
      s2m_ndr_txn[1].tag          = data[(SLOT2_OFFSET+51):(SLOT2_OFFSET+36)];
      s2m_ndr_txn[2].valid        = data[(SLOT2_OFFSET+56)];
      s2m_ndr_txn[2].opcode    = s2m_ndr_opcode_t'(data[(SLOT2_OFFSET+59):(SLOT2_OFFSET+57)]);
      s2m_ndr_txn[2].metafield    = metafield_t'(data[(SLOT2_OFFSET+61):(SLOT2_OFFSET+60)]);
      s2m_ndr_txn[2].metavalue    = metavalue_t'(data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+62)]);
      s2m_ndr_txn[2].tag          = data[(SLOT2_OFFSET+79):(SLOT2_OFFSET+64)];
    end else if(slot_sel == 'h3) begin
      s2m_ndr_txn[0].valid        = data[(SLOT3_OFFSET+0)];
      s2m_ndr_txn[0].opcode    = s2m_ndr_opcode_t'(data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]);
      s2m_ndr_txn[0].metafield    = metafield_t'(data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]);
      s2m_ndr_txn[0].metavalue    = metavalue_t'(data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]);
      s2m_ndr_txn[0].tag          = data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)];
      s2m_ndr_txn[1].valid        = data[(SLOT3_OFFSET+28)];
      s2m_ndr_txn[1].opcode    = s2m_ndr_opcode_t'(data[(SLOT3_OFFSET+31):(SLOT3_OFFSET+29)]);
      s2m_ndr_txn[1].metafield    = metafield_t'(data[(SLOT3_OFFSET+33):(SLOT3_OFFSET+32)]);
      s2m_ndr_txn[1].metavalue    = metavalue_t'(data[(SLOT3_OFFSET+35):(SLOT3_OFFSET+34)]);
      s2m_ndr_txn[1].tag          = data[(SLOT3_OFFSET+51):(SLOT3_OFFSET+36)];
      s2m_ndr_txn[2].valid        = data[(SLOT3_OFFSET+56)];
      s2m_ndr_txn[2].opcode    = s2m_ndr_opcode_t'(data[(SLOT3_OFFSET+59):(SLOT3_OFFSET+57)]);
      s2m_ndr_txn[2].metafield    = metafield_t'(data[(SLOT3_OFFSET+61):(SLOT3_OFFSET+60)]);
      s2m_ndr_txn[2].metavalue    = metavalue_t'(data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+62)]);
      s2m_ndr_txn[2].tag          = data[(SLOT3_OFFSET+79):(SLOT3_OFFSET+64)];
    end else begin
      s2m_ndr_txn[0].valid        = 'hX;
      s2m_ndr_txn[1].valid        = 'hX;
      s2m_ndr_txn[2].valid        = 'hX;
    end

  endfunction

  function automatic void generic6(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref s2m_drs_pkt_t s2m_drs_pkt[3]
  );

    if(slot_sel == 'h1) begin
      s2m_drs_pkt[0].pending_data_slot        = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid        = data[(SLOT1_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]);
      s2m_drs_pkt[0].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT1_OFFSET+5):(SLOT1_OFFSET+4)]);
      s2m_drs_pkt[0].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+6)]);
      s2m_drs_pkt[0].s2m_drs_txn.tag          = data[(SLOT1_OFFSET+23):(SLOT1_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison       = data[(SLOT1_OFFSET+24)];
      s2m_drs_pkt[1].pending_data_slot        = 'hf;
      s2m_drs_pkt[1].s2m_drs_txn.valid        = data[(SLOT1_OFFSET+40)];
      s2m_drs_pkt[1].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT1_OFFSET+43):(SLOT1_OFFSET+41)]);
      s2m_drs_pkt[1].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT1_OFFSET+45):(SLOT1_OFFSET+44)]);
      s2m_drs_pkt[1].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT1_OFFSET+47):(SLOT1_OFFSET+46)]);
      s2m_drs_pkt[1].s2m_drs_txn.tag          = data[(SLOT1_OFFSET+63):(SLOT1_OFFSET+48)];
      s2m_drs_pkt[1].s2m_drs_txn.poison       = data[(SLOT1_OFFSET+64)];
      s2m_drs_pkt[2].pending_data_slot        = 'hf;
      s2m_drs_pkt[2].s2m_drs_txn.valid        = data[(SLOT1_OFFSET+80)];
      s2m_drs_pkt[2].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT1_OFFSET+83):(SLOT1_OFFSET+81)]);
      s2m_drs_pkt[2].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT1_OFFSET+85):(SLOT1_OFFSET+84)]);
      s2m_drs_pkt[2].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT1_OFFSET+87):(SLOT1_OFFSET+86)]);
      s2m_drs_pkt[2].s2m_drs_txn.tag          = data[(SLOT1_OFFSET+103):(SLOT1_OFFSET+88)];
      s2m_drs_pkt[2].s2m_drs_txn.poison       = data[(SLOT1_OFFSET+104)];
    end else if(slot_sel == 'h2) begin
      s2m_drs_pkt[0].pending_data_slot        = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid        = data[(SLOT2_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]);
      s2m_drs_pkt[0].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT2_OFFSET+5):(SLOT2_OFFSET+4)]);
      s2m_drs_pkt[0].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+6)]);
      s2m_drs_pkt[0].s2m_drs_txn.tag          = data[(SLOT2_OFFSET+23):(SLOT2_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison       = data[(SLOT2_OFFSET+24)];
      s2m_drs_pkt[1].pending_data_slot        = 'hf;
      s2m_drs_pkt[1].s2m_drs_txn.valid        = data[(SLOT2_OFFSET+40)];
      s2m_drs_pkt[1].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT2_OFFSET+43):(SLOT2_OFFSET+41)]);
      s2m_drs_pkt[1].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT2_OFFSET+45):(SLOT2_OFFSET+44)]);
      s2m_drs_pkt[1].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT2_OFFSET+47):(SLOT2_OFFSET+46)]);
      s2m_drs_pkt[1].s2m_drs_txn.tag          = data[(SLOT2_OFFSET+63):(SLOT2_OFFSET+48)];
      s2m_drs_pkt[1].s2m_drs_txn.poison       = data[(SLOT2_OFFSET+64)];
      s2m_drs_pkt[2].pending_data_slot        = 'hf;
      s2m_drs_pkt[2].s2m_drs_txn.valid        = data[(SLOT2_OFFSET+80)];
      s2m_drs_pkt[2].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT2_OFFSET+83):(SLOT2_OFFSET+81)]);
      s2m_drs_pkt[2].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT2_OFFSET+85):(SLOT2_OFFSET+84)]);
      s2m_drs_pkt[2].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT2_OFFSET+87):(SLOT2_OFFSET+86)]);
      s2m_drs_pkt[2].s2m_drs_txn.tag          = data[(SLOT2_OFFSET+103):(SLOT2_OFFSET+88)];
      s2m_drs_pkt[2].s2m_drs_txn.poison       = data[(SLOT2_OFFSET+104)];
    end else if(slot_sel == 'h3) begin
      s2m_drs_pkt[0].pending_data_slot        = 'hf;
      s2m_drs_pkt[0].s2m_drs_txn.valid        = data[(SLOT3_OFFSET+0)];
      s2m_drs_pkt[0].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]);
      s2m_drs_pkt[0].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT3_OFFSET+5):(SLOT3_OFFSET+4)]);
      s2m_drs_pkt[0].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+6)]);
      s2m_drs_pkt[0].s2m_drs_txn.tag          = data[(SLOT3_OFFSET+23):(SLOT3_OFFSET+8)];
      s2m_drs_pkt[0].s2m_drs_txn.poison       = data[(SLOT3_OFFSET+24)];
      s2m_drs_pkt[1].pending_data_slot        = 'hf;
      s2m_drs_pkt[1].s2m_drs_txn.valid        = data[(SLOT3_OFFSET+40)];
      s2m_drs_pkt[1].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT3_OFFSET+43):(SLOT3_OFFSET+41)]);
      s2m_drs_pkt[1].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT3_OFFSET+45):(SLOT3_OFFSET+44)]);
      s2m_drs_pkt[1].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT3_OFFSET+47):(SLOT3_OFFSET+46)]);
      s2m_drs_pkt[1].s2m_drs_txn.tag          = data[(SLOT3_OFFSET+63):(SLOT3_OFFSET+48)];
      s2m_drs_pkt[1].s2m_drs_txn.poison       = data[(SLOT3_OFFSET+64)];
      s2m_drs_pkt[2].pending_data_slot        = 'hf;
      s2m_drs_pkt[2].s2m_drs_txn.valid        = data[(SLOT3_OFFSET+80)];
      s2m_drs_pkt[2].s2m_drs_txn.opcode    = s2m_drs_opcode_t'(data[(SLOT3_OFFSET+83):(SLOT3_OFFSET+81)]);
      s2m_drs_pkt[2].s2m_drs_txn.metafield    = metafield_t'(data[(SLOT3_OFFSET+85):(SLOT3_OFFSET+84)]);
      s2m_drs_pkt[2].s2m_drs_txn.metavalue    = metavalue_t'(data[(SLOT3_OFFSET+87):(SLOT3_OFFSET+86)]);
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
      //foreach(data_slot[i]) data_slot[i] <= 'h0;
      //foreach(data_slot_d[i]) data_slot_d[i] <= 'h0;
      data_slot[0] <= 'h0;
      data_slot[1] <= 'h0;
      data_slot[2] <= 'h0;
      data_slot[3] <= 'h0;
      data_slot[4] <= 'h0;
      data_slot_d[0] <= 'h0;
      data_slot_d[1] <= 'h0;
      data_slot_d[2] <= 'h0;
      data_slot_d[3] <= 'h0;
      data_slot_d[4] <= 'h0;
      ack <= 'h0;
      ack_count_d <= 'h0;
      ack_ret_val <= 'h0;
    end else begin
      ack_count_d <= ack_count;
      if((ack_count_d == 'h7) && (ack_count == 'h0)) begin
        ack <= 'h1;
      end else begin
        ack <= 'h0;
      end
      if(host_rx_dl_if_d_valid && retryable_flit && llcrd_flit) begin
        ack_ret_val <= 'h1;
      end else begin
        ack_ret_val <= 'h0;
      end
      if(host_rx_dl_if_d_valid && retryable_flit && (!llcrd_flit)) begin
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
    if(host_rx_dl_if_d_valid && retryable_flit && (!llcrd_flit) &&
        (!data_slot_d[0][3] || 
          ((data_slot_d[0] == 'hf) && 
            ((d2h_data_pkt_d[0].pending_data_slot == 0) && (s2m_drs_pkt_d[0].pending_data_slot == 0)) &&
            ((d2h_data_pkt_d[1].pending_data_slot == 0) && (s2m_drs_pkt_d[1].pending_data_slot == 0)) &&
            ((d2h_data_pkt_d[2].pending_data_slot == 0) && (s2m_drs_pkt_d[2].pending_data_slot == 0)) &&
            ((d2h_data_pkt_d[3].pending_data_slot == 0))
          )
        )
      ) begin 
      if(host_rx_dl_if_d_data[7:5] == 'h4) begin
        data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;//need to add what happens when slot 1 is g slot
        if((host_rx_dl_if_d_data[10:8] == 'h1) || (host_rx_dl_if_d_data[10:8] == 'h5)) begin
          data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
          if((host_rx_dl_if_d_data[13:11] == 'h1) || (host_rx_dl_if_d_data[13:11] == 'h5)) begin
            data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            if((host_rx_dl_if_d_data[16:14] == 'h1) || (host_rx_dl_if_d_data[16:14] == 'h5)) begin
              data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            end else if((host_rx_dl_if_d_data[16:14] == 'h2) || (host_rx_dl_if_d_data[16:14] == 'h4)) begin  
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            end else if(host_rx_dl_if_d_data[16:14] == 'h6) begin  
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h0;
            end else begin
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'hf;
            end
          end else if((host_rx_dl_if_d_data[10:8] == 'h2) || (host_rx_dl_if_d_data[10:8] == 'h4)) begin  
            data_slot[0] = 'h8; data_slot[1] = 'h7; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
          end else if(host_rx_dl_if_d_data[10:8] == 'h6) begin  
            data_slot[0] = 'h8; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'h7; data_slot[4] = 'h0;
          end else begin
            data_slot[0] = 'h8; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h7;
          end
        end else if((host_rx_dl_if_d_data[10:8] == 'h2) || (host_rx_dl_if_d_data[10:8] == 'h4)) begin  
          data_slot[0] = 'hc; data_slot[1] = 'h3; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
        end else if(host_rx_dl_if_d_data[10:8] == 'h6) begin  
          data_slot[0] = 'hc; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'h3; data_slot[4] = 'h0;
        end else begin
          data_slot[0] = 'hc; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h3;
        end
      end else if((host_rx_dl_if_d_data[7:5] == 'h0) || (host_rx_dl_if_d_data[7:5] == 'h1) || (host_rx_dl_if_d_data[7:5] == 'h3)) begin
        data_slot[0] = 'he; data_slot[1] = 'h1; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
      end else if(host_rx_dl_if_d_data[7:5] == 'h5) begin
        data_slot[0] = 'he; data_slot[1] = 'hf; data_slot[2] = 'h1; data_slot[3] = 'h0; data_slot[4] = 'h0;
      end else begin
        data_slot[0] = 'he; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h1;
      end
    //end else if(host_rx_dl_if_d_valid && data_slot_d[0][0] /*&& data_slot_d[0][1] && data_slot_d[0][2] && data_slot_d[0][3]*/) begin
      //data_slot[0] = data_slot[1]; data_slot[1] = data_slot[2]; data_slot[3] = data_slot[4]; data_slot[4] = 'h0;
    end
  
    if(host_rx_dl_if_d_valid && retryable_flit && (!llcrd_flit)) begin
      ack_count = ack_count + 1;
      if(!data_slot[0][0]) begin
        case(host_rx_dl_if_d_data[7:5])
          'h0: begin
            header0(host_rx_dl_if_d_data, d2h_data_pkt, d2h_rsp_txn, s2m_ndr_txn);
          end
          'h1: begin
            header1(host_rx_dl_if_d_data, d2h_req_txn, d2h_data_pkt);
          end
          'h2: begin
            header2(host_rx_dl_if_d_data, d2h_data_pkt, d2h_rsp_txn);
          end
          'h3: begin
            header3(host_rx_dl_if_d_data, s2m_drs_pkt, s2m_ndr_txn);
          end
          'h4: begin
            header4(host_rx_dl_if_d_data, s2m_ndr_txn);
          end
          'h5: begin
            header5(host_rx_dl_if_d_data, s2m_drs_pkt);
          end
          default: begin

          end
        endcase
        case(host_rx_dl_if_d_data[10:8])
          'h0: begin
            generic0('h1, host_rx_dl_if_d_data, d2h_data_pkt, s2m_drs_pkt);
          end
          'h1: begin
            generic1('h1, host_rx_dl_if_d_data, d2h_req_txn, d2h_rsp_txn);
          end
          'h2: begin
            generic2('h1, host_rx_dl_if_d_data, d2h_req_txn, d2h_data_pkt, d2h_rsp_txn);
          end
          'h3: begin
            generic3('h1, host_rx_dl_if_d_data, d2h_data_pkt);
          end
          'h4: begin
            generic4('h1, host_rx_dl_if_d_data, s2m_drs_pkt, s2m_ndr_txn);
          end
          'h5: begin
            generic5('h1, host_rx_dl_if_d_data, s2m_ndr_txn);
          end
          'h6: begin
            generic6('h1, host_rx_dl_if_d_data, s2m_drs_pkt);
          end
          default: begin
          
          end
        endcase
        case(host_rx_dl_if_d_data[13:11])
          'h0: begin
            generic0('h2, host_rx_dl_if_d_data, d2h_data_pkt, s2m_drs_pkt);
          end
          'h1: begin
            generic1('h2, host_rx_dl_if_d_data, d2h_req_txn, d2h_rsp_txn);
          end
          'h2: begin
            generic2('h2, host_rx_dl_if_d_data, d2h_req_txn, d2h_data_pkt, d2h_rsp_txn);
          end
          'h3: begin
            generic3('h2, host_rx_dl_if_d_data, d2h_data_pkt);
          end
          'h4: begin
            generic4('h2, host_rx_dl_if_d_data, s2m_drs_pkt, s2m_ndr_txn);
          end
          'h5: begin
            generic5('h2, host_rx_dl_if_d_data, s2m_ndr_txn);
          end
          'h6: begin
            generic6('h2, host_rx_dl_if_d_data, s2m_drs_pkt);
          end
          default: begin
          
          end
        endcase
        case(host_rx_dl_if_d_data[16:14])
          'h0: begin
            generic0('h3, host_rx_dl_if_d_data, d2h_data_pkt, s2m_drs_pkt);
          end
          'h1: begin
            generic1('h3, host_rx_dl_if_d_data, d2h_req_txn, d2h_rsp_txn);
          end
          'h2: begin
            generic2('h3, host_rx_dl_if_d_data, d2h_req_txn, d2h_data_pkt, d2h_rsp_txn);
          end
          'h3: begin
            generic3('h3, host_rx_dl_if_d_data, d2h_data_pkt);
          end
          'h4: begin
            generic4('h3, host_rx_dl_if_d_data, s2m_drs_pkt, s2m_ndr_txn);
          end
          'h5: begin
            generic5('h3, host_rx_dl_if_d_data, s2m_ndr_txn);
          end
          'h6: begin
            generic6('h3, host_rx_dl_if_d_data, s2m_drs_pkt);
          end
          default: begin
          
          end
        endcase
      end else if(data_slot[0][0]) begin
        generic0('h0, host_rx_dl_if_d_data, d2h_data_pkt, s2m_drs_pkt);
      end
    end
    
    if(host_rx_dl_if_d_valid && llcrd_flit) begin
      ack_count = ack_count + 1;
      ack_ret = {host_rx_dl_if_d_data[71:68], host_rx_dl_if_d_data[2], host_rx_dl_if_d_data[66:64]};
    end
  end

  cxl_lrsm_rrsm #(
  ) cxl_lrsm_rrsm_inst (
    .clk(host_rx_dl_if.clk),
    .rstn(host_rx_dl_if.rstn),
    .*
  );

  crc_check #(
  ) c2c_check_inst (
    .data(host_rx_dl_if.data),
    .*
  );

  //TODO: serious mistake I am assuming only one side of the link can have error at a time

  always@(posedge host_rx_dl_if.clk) begin
    if(!host_rx_dl_if.rstn) begin
      crc_pass_d <= 'h0;
      crc_fail_d <= 'h0;
      host_rx_dl_if_d_valid <= 'h0;
      host_rx_dl_if_d_data <= 'h0;
    end else begin
      crc_pass_d <= crc_pass;
      crc_fail_d <= crc_fail;
      host_rx_dl_if_d_valid <= host_rx_dl_if.valid;
      host_rx_dl_if_d_data <= host_rx_dl_if.data[527:16];
      if(host_rx_dl_if_d_valid) begin
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
            retry_ack_empty_bit <= host_rx_dl_if_d_data[64];
            retry_ack_num_retry <= host_rx_dl_if_d_data[71:67];
            retry_frame_states <= RETRY_NOFRAME;
          end else begin
            retry_req_rcvd <= 'h0;
            retry_ack_rcvd <= 'h0;
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        default: begin
            retry_frame_states <= RETRY_NOFRAME;
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
  output h2d_req_txn_t h2d_req_txn[2],
  output h2d_rsp_txn_t h2d_rsp_txn[4],
  output h2d_data_pkt_t h2d_data_pkt[4],
  output m2s_req_txn_t m2s_req_txn[2],
  output m2s_rwd_pkt_t m2s_rwd_pkt,
  output logic ack,
  output logic ack_ret_val,
  output logic [7:0] ack_ret,
  output logic init_done,
  output logic crdt_val,
  output logic crdt_rsp_cm,
  output logic crdt_req_cm,
  output logic crdt_data_cm,
  output logic [2:0] crdt_rsp,
  output logic [2:0] crdt_req,
  output logic [2:0] crdt_data
);

  localparam SLOT1_OFFSET = 128;
  localparam SLOT2_OFFSET = 256;
  localparam SLOT3_OFFSET = 384;
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
  logic crc_pass_d;
  logic crc_fail_d;
  logic retryable_flit;
  logic non_retryable_flit;
  logic retry_req_rcvd;
  logic [7:0] retry_ack_num_retry;
  logic retry_ack_empty_bit;
  logic retry_ack_rcvd;
  logic dev_rx_dl_if_d_valid;//assuming crc checker takes 1 cycle to tell crc pass or fail
  logic [511:0] dev_rx_dl_if_d_data;//assuming crc checker takes 1 cycle to tell crc pass or fail
  logic retry_frame_detect;
  logic retry_req_detect;
  logic retry_ack_detect;
  logic retry_idle_detect;
  logic [3:0] data_slot[5];
  logic [3:0] data_slot_d[5];
  h2d_data_pkt_t h2d_data_pkt_d[4];
  m2s_rwd_pkt_t m2s_rwd_pkt_d;
  logic [1:0] h2d_req_ptr;
  logic [1:0] h2d_rsp_ptr;
  logic [1:0] h2d_data_ptr;
  logic [1:0] m2s_req_ptr;
  logic [1:0] m2s_rwd_ptr;
  logic [2:0] ack_count;
  logic [2:0] ack_count_d;
  logic llcrd_flit;

  assign init_done          = (dev_rx_dl_if_d_data[39:36] == 'h8) && (dev_rx_dl_if_d_data[35:32] == 'hc) && (dev_rx_dl_if_d_data[0] == 'h1) && (dev_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign retry_frame_detect = (dev_rx_dl_if_d_data[39:36] == 'h3) && (dev_rx_dl_if_d_data[35:32] == 'h1) && (dev_rx_dl_if_d_data[0] == 'h1) && (dev_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign retry_idle_detect  = (dev_rx_dl_if_d_data[39:36] == 'h0) && (dev_rx_dl_if_d_data[35:32] == 'h1) && (dev_rx_dl_if_d_data[0] == 'h1) && (dev_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign retry_req_detect   = (dev_rx_dl_if_d_data[39:36] == 'h1) && (dev_rx_dl_if_d_data[35:32] == 'h1) && (dev_rx_dl_if_d_data[0] == 'h1) && (dev_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign retry_ack_detect   = (dev_rx_dl_if_d_data[39:36] == 'h2) && (dev_rx_dl_if_d_data[35:32] == 'h1) && (dev_rx_dl_if_d_data[0] == 'h1) && (dev_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign llcrd_flit         = (dev_rx_dl_if_d_data[39:36] == 'h1) && (dev_rx_dl_if_d_data[35:32] == 'h0) && (dev_rx_dl_if_d_data[0] == 'h1) && (dev_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign non_retryable_flit = (retry_idle_detect) || (retry_frame_detect) || (retry_req_detect) || (retry_ack_detect);
  assign retryable_flit     = (!retry_idle_detect) && (!retry_frame_detect) && (!retry_req_detect) && (!retry_ack_detect);
  assign crdt_val           = (llcrd_flit || (dev_rx_dl_if_d_data[0] == 'h0)) && (dev_rx_dl_if_d_valid) && (crc_pass_d) && (!crc_fail_d);
  assign crdt_data_cm       = crdt_val && dev_rx_dl_if_d_data[31];
  assign crdt_data          = crdt_val && dev_rx_dl_if_d_data[30:28];
  assign crdt_req_cm        = crdt_val && dev_rx_dl_if_d_data[27];
  assign crdt_req           = crdt_val && dev_rx_dl_if_d_data[26:24];
  assign crdt_rsp_cm        = crdt_val && dev_rx_dl_if_d_data[23];
  assign crdt_rsp           = crdt_val && dev_rx_dl_if_d_data[22:20];
  
  function automatic void header0(
    input logic [511:0] data,
    ref h2d_req_txn_t h2d_req_txn[2],
    ref h2d_rsp_txn_t h2d_rsp_txn[4]
  );
    h2d_req_txn[0].valid        = data[32];
    h2d_req_txn[0].opcode       = h2d_req_opcode_t'(data[35:33]);
    h2d_req_txn[0].address      = data[81:36];
    h2d_req_txn[0].uqid         = data[93:82];
    h2d_rsp_txn[0].valid        = data[96];
    h2d_rsp_txn[0].opcode       = h2d_rsp_opcode_t'(data[100:97]);
    h2d_rsp_txn[0].rspdata      = h2d_rsp_data_opcode_t'(data[112:101]);
    h2d_rsp_txn[0].rsppre       = data[114:113];
    h2d_rsp_txn[0].cqid         = data[126:115];
  endfunction

  function automatic void header1(
    input logic [511:0] data,
    ref h2d_data_pkt_t h2d_data_pkt[4],
    ref h2d_rsp_txn_t h2d_rsp_txn[4]
  );
    h2d_data_pkt[0].pending_data_slot         = 'hf;
    h2d_data_pkt[0].h2d_data_txn.valid        = data[32];
    h2d_data_pkt[0].h2d_data_txn.cqid         = data[44:33];
    h2d_data_pkt[0].h2d_data_txn.chunkvalid   = data[45];
    h2d_data_pkt[0].h2d_data_txn.poison       = data[46];
    h2d_data_pkt[0].h2d_data_txn.goerr        = data[47];
    h2d_rsp_txn[0].valid                      = data[56];
    h2d_rsp_txn[0].opcode                     = h2d_rsp_opcode_t'(data[60:57]);
    h2d_rsp_txn[0].rspdata                    = h2d_rsp_data_opcode_t'(data[72:61]);
    h2d_rsp_txn[0].rsppre                     = data[74:73];
    h2d_rsp_txn[0].cqid                       = data[86:75];
    h2d_rsp_txn[1].valid                      = data[88];
    h2d_rsp_txn[1].opcode                     = h2d_rsp_opcode_t'(data[92:89]);
    h2d_rsp_txn[1].rspdata                    = h2d_rsp_data_opcode_t'(data[104:93]);
    h2d_rsp_txn[1].rsppre                     = data[106:105];
    h2d_rsp_txn[1].cqid                       = data[118:107];

  endfunction

  function automatic void header2(
    input logic [511:0] data,
    ref h2d_req_txn_t h2d_req_txn[2],
    ref h2d_data_pkt_t h2d_data_pkt[4]
  );
    h2d_req_txn[0].valid                     = data[32];
    h2d_req_txn[0].opcode                    = h2d_req_opcode_t'(data[35:33]);
    h2d_req_txn[0].address                   = data[81:36];
    h2d_req_txn[0].uqid                      = data[93:82];
    h2d_data_pkt[0].h2d_data_txn.valid       = data[96];
    h2d_data_pkt[0].h2d_data_txn.cqid        = data[108:97];
    h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[109];
    h2d_data_pkt[0].h2d_data_txn.poison      = data[110];
    h2d_data_pkt[0].h2d_data_txn.goerr       = data[111];
  endfunction

  function automatic void header3(
    input logic [511:0] data,
    ref h2d_data_pkt_t h2d_data_pkt[4]
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

  function automatic void header4(
    input logic [511:0] data,
    ref m2s_rwd_pkt_t m2s_rwd_pkt
  );
    m2s_rwd_pkt.pending_data_slot        = 'hf;
    m2s_rwd_pkt.m2s_rwd_txn.valid        = data[32];
    m2s_rwd_pkt.m2s_rwd_txn.memopcode    = m2s_rwd_opcode_t'(data[36:33]);
    m2s_rwd_pkt.m2s_rwd_txn.snptype      = snptype_t'(data[39:37]);
    m2s_rwd_pkt.m2s_rwd_txn.metafield    = metafield_t'(data[41:40]);
    m2s_rwd_pkt.m2s_rwd_txn.metavalue    = metavalue_t'(data[43:42]);
    m2s_rwd_pkt.m2s_rwd_txn.tag          = data[58:44];
    m2s_rwd_pkt.m2s_rwd_txn.address      = data[105:59];
    m2s_rwd_pkt.m2s_rwd_txn.poison       = data[106];
    m2s_rwd_pkt.m2s_rwd_txn.tc           = data[108:107];

  endfunction

  function automatic void header5(
    input logic [511:0] data,
    ref m2s_req_txn_t m2s_req_txn[2]
  );
    m2s_req_txn[0].valid        = data[32];
    m2s_req_txn[0].memopcode    = m2s_req_opcode_t'(data[36:33]);
    m2s_req_txn[0].snptype      = snptype_t'(data[39:37]);
    m2s_req_txn[0].metafield    = metafield_t'(data[41:40]);
    m2s_req_txn[0].metavalue    = metavalue_t'(data[43:42]);
    m2s_req_txn[0].tag          = data[58:44];
    m2s_req_txn[0].address      = data[106:59];
    m2s_req_txn[0].tc           = data[108:107];
  endfunction

  function automatic void generic0(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref h2d_data_pkt_t h2d_data_pkt[4],
    ref m2s_rwd_pkt_t m2s_rwd_pkt
    //inout h2d_data_pkt_t h2d_data_pkt[4],
    //inout m2s_rwd_pkt_t m2s_rwd_pkt
  );
    if(m2s_rwd_pkt.pending_data_slot == 'hf) begin
      if(slot_sel == 1) begin
        m2s_rwd_pkt.m2s_rwd_txn.data[SLOT3_OFFSET-1:0] = data[SLOT3_OFFSET-1:0]; 
        m2s_rwd_pkt.pending_data_slot = 'h8;
      end else if(slot_sel == 2) begin
        m2s_rwd_pkt.m2s_rwd_txn.data[SLOT2_OFFSET-1:0] = data[SLOT2_OFFSET-1:0]; 
        m2s_rwd_pkt.pending_data_slot = 'hc;
      end else if(slot_sel == 3) begin
        m2s_rwd_pkt.m2s_rwd_txn.data[SLOT1_OFFSET-1:0] = data[SLOT1_OFFSET-1:0]; 
        m2s_rwd_pkt.pending_data_slot = 'he;
      end else if(slot_sel == 0) begin
        m2s_rwd_pkt.m2s_rwd_txn.data = data; 
        m2s_rwd_pkt.pending_data_slot = 'h0;
      end 
    end else if(m2s_rwd_pkt.pending_data_slot == 'he) begin
      m2s_rwd_pkt.m2s_rwd_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0]; 
      m2s_rwd_pkt.pending_data_slot = 'h0;
      /*TODO: next gen upgrade logic
      if(m2s_rwd_pkt[1].pending_data_slot != 0) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
        m2s_rwd_pkt[1].pending_data_slot = 'he;
      end*/
    end else if(m2s_rwd_pkt.pending_data_slot == 'hc) begin
      m2s_rwd_pkt.m2s_rwd_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0]; 
      m2s_rwd_pkt.pending_data_slot = 'h0;
      //TODO:maybe for future gen where size of rwd is > 1
      /*if(m2s_rwd_pkt[1].pending_data_slot != 0) begin
        m2s_rwd_pkt[1].m2s_rwd_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
        m2s_rwd_pkt[1].pending_data_slot = 'hc;
      end*/
    end else if(m2s_rwd_pkt.pending_data_slot == 'h8) begin
      m2s_rwd_pkt.m2s_rwd_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0]; 
      m2s_rwd_pkt.pending_data_slot = 'h0;
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
          h2d_data_pkt[2].h2d_data_txn.data[511:SLOT1_OFFSET] = data[SLOT3_OFFSET-1:0];
          h2d_data_pkt[2].pending_data_slot = 'h0;
          if(h2d_data_pkt[3].pending_data_slot != 'h0) begin
            h2d_data_pkt[3].h2d_data_txn.data[SLOT1_OFFSET-1:0] = data[511:SLOT3_OFFSET];
            h2d_data_pkt[3].pending_data_slot = 'he;
          end
        end else if(h2d_data_pkt[2].pending_data_slot == 'hc) begin
          h2d_data_pkt[2].h2d_data_txn.data[511:SLOT2_OFFSET] = data[SLOT2_OFFSET-1:0];
          h2d_data_pkt[2].pending_data_slot = 'h0;
          if(h2d_data_pkt[3].pending_data_slot != 'h0) begin
            h2d_data_pkt[3].h2d_data_txn.data[SLOT2_OFFSET-1:0] = data[511:SLOT2_OFFSET];
            h2d_data_pkt[3].pending_data_slot = 'hc;
          end
        end else if(h2d_data_pkt[2].pending_data_slot == 'h8) begin
          h2d_data_pkt[2].h2d_data_txn.data[511:SLOT3_OFFSET] = data[SLOT1_OFFSET-1:0];
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

  function automatic void generic1(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref h2d_rsp_txn_t h2d_rsp_txn[4]
  );

    if(slot_sel == 'h1) begin
      h2d_rsp_txn[0].valid        = data[(SLOT1_OFFSET+0)];
      h2d_rsp_txn[0].opcode       = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)]);
      h2d_rsp_txn[0].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+16):(SLOT1_OFFSET+5)]);
      h2d_rsp_txn[0].rsppre       = data[(SLOT1_OFFSET+18):(SLOT1_OFFSET+17)];
      h2d_rsp_txn[0].cqid         = data[(SLOT1_OFFSET+30):(SLOT1_OFFSET+19)];
      h2d_rsp_txn[1].valid        = data[(SLOT1_OFFSET+32)];
      h2d_rsp_txn[1].opcode       = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+36):(SLOT1_OFFSET+33)]);
      h2d_rsp_txn[1].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+48):(SLOT1_OFFSET+37)]);
      h2d_rsp_txn[1].rsppre       = data[(SLOT1_OFFSET+50):(SLOT1_OFFSET+49)];
      h2d_rsp_txn[1].cqid         = data[(SLOT1_OFFSET+62):(SLOT1_OFFSET+51)];
      h2d_rsp_txn[2].valid        = data[(SLOT1_OFFSET+64)];
      h2d_rsp_txn[2].opcode       = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+68):(SLOT1_OFFSET+65)]);
      h2d_rsp_txn[2].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+80):(SLOT1_OFFSET+69)]);
      h2d_rsp_txn[2].rsppre       = data[(SLOT1_OFFSET+82):(SLOT1_OFFSET+81)];
      h2d_rsp_txn[2].cqid         = data[(SLOT1_OFFSET+94):(SLOT1_OFFSET+83)];
      h2d_rsp_txn[3].valid        = data[(SLOT1_OFFSET+96)];
      h2d_rsp_txn[3].opcode       = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+97)]);
      h2d_rsp_txn[3].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+112):(SLOT1_OFFSET+101)]);
      h2d_rsp_txn[3].rsppre       = data[(SLOT1_OFFSET+114):(SLOT1_OFFSET+113)];
      h2d_rsp_txn[3].cqid         = data[(SLOT1_OFFSET+126):(SLOT1_OFFSET+115)];
    end else if(slot_sel == 'h2) begin
      h2d_rsp_txn[0].valid        = data[(SLOT2_OFFSET+0)];
      h2d_rsp_txn[0].opcode       = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)]);
      h2d_rsp_txn[0].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+16):(SLOT2_OFFSET+5)]);
      h2d_rsp_txn[0].rsppre       = data[(SLOT2_OFFSET+18):(SLOT2_OFFSET+17)];
      h2d_rsp_txn[0].cqid         = data[(SLOT2_OFFSET+30):(SLOT2_OFFSET+19)];
      h2d_rsp_txn[1].valid        = data[(SLOT2_OFFSET+32)];
      h2d_rsp_txn[1].opcode       = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+36):(SLOT2_OFFSET+33)]);
      h2d_rsp_txn[1].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+48):(SLOT2_OFFSET+37)]);
      h2d_rsp_txn[1].rsppre       = data[(SLOT2_OFFSET+50):(SLOT2_OFFSET+49)];
      h2d_rsp_txn[1].cqid         = data[(SLOT2_OFFSET+62):(SLOT2_OFFSET+51)];
      h2d_rsp_txn[2].valid        = data[(SLOT2_OFFSET+64)];
      h2d_rsp_txn[2].opcode       = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+68):(SLOT2_OFFSET+65)]);
      h2d_rsp_txn[2].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+80):(SLOT2_OFFSET+69)]);
      h2d_rsp_txn[2].rsppre       = data[(SLOT2_OFFSET+82):(SLOT2_OFFSET+81)];
      h2d_rsp_txn[2].cqid         = data[(SLOT2_OFFSET+94):(SLOT2_OFFSET+83)];
      h2d_rsp_txn[3].valid        = data[(SLOT2_OFFSET+96)];
      h2d_rsp_txn[3].opcode       = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)]);
      h2d_rsp_txn[3].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)]);
      h2d_rsp_txn[3].rsppre       = data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)];
      h2d_rsp_txn[3].cqid         = data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)];
    end else if(slot_sel == 'h3) begin
      h2d_rsp_txn[0].valid        = data[(SLOT3_OFFSET+0)];
      h2d_rsp_txn[0].opcode       = h2d_rsp_opcode_t'(data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)]);
      h2d_rsp_txn[0].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT3_OFFSET+16):(SLOT3_OFFSET+5)]);
      h2d_rsp_txn[0].rsppre       = data[(SLOT3_OFFSET+18):(SLOT3_OFFSET+17)];
      h2d_rsp_txn[0].cqid         = data[(SLOT3_OFFSET+30):(SLOT3_OFFSET+19)];
      h2d_rsp_txn[1].valid        = data[(SLOT3_OFFSET+32)];
      h2d_rsp_txn[1].opcode       = h2d_rsp_opcode_t'(data[(SLOT3_OFFSET+36):(SLOT3_OFFSET+33)]);
      h2d_rsp_txn[1].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT3_OFFSET+48):(SLOT3_OFFSET+37)]);
      h2d_rsp_txn[1].rsppre       = data[(SLOT3_OFFSET+50):(SLOT3_OFFSET+49)];
      h2d_rsp_txn[1].cqid         = data[(SLOT3_OFFSET+62):(SLOT3_OFFSET+51)];
      h2d_rsp_txn[2].valid        = data[(SLOT3_OFFSET+64)];
      h2d_rsp_txn[2].opcode       = h2d_rsp_opcode_t'(data[(SLOT3_OFFSET+68):(SLOT3_OFFSET+65)]);
      h2d_rsp_txn[2].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT3_OFFSET+80):(SLOT3_OFFSET+69)]);
      h2d_rsp_txn[2].rsppre       = data[(SLOT3_OFFSET+82):(SLOT3_OFFSET+81)];
      h2d_rsp_txn[2].cqid         = data[(SLOT3_OFFSET+94):(SLOT3_OFFSET+83)];
      h2d_rsp_txn[3].valid        = data[(SLOT3_OFFSET+96)];
      h2d_rsp_txn[3].opcode       = h2d_rsp_opcode_t'(data[(SLOT3_OFFSET+100):(SLOT3_OFFSET+97)]);
      h2d_rsp_txn[3].rspdata      = h2d_rsp_data_opcode_t'(data[(SLOT3_OFFSET+112):(SLOT3_OFFSET+101)]);
      h2d_rsp_txn[3].rsppre       = data[(SLOT3_OFFSET+114):(SLOT3_OFFSET+113)];
      h2d_rsp_txn[3].cqid         = data[(SLOT3_OFFSET+126):(SLOT3_OFFSET+115)];    
    end else begin
      h2d_rsp_txn[0].valid = 'hX;
      h2d_rsp_txn[1].valid = 'hX;
      h2d_rsp_txn[2].valid = 'hX;
      h2d_rsp_txn[3].valid = 'hX;
    end

  endfunction

  function automatic void generic2(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref h2d_req_txn_t h2d_req_txn[2],
    input int h2d_req_ptr,
    ref h2d_data_pkt_t h2d_data_pkt[4],
    ref h2d_rsp_txn_t h2d_rsp_txn[4],
    input int h2d_rsp_ptr
  );

    if(slot_sel == 'h1) begin
      if(h2d_req_ptr > 0) begin
        h2d_req_txn[1].valid                     = data[(SLOT1_OFFSET+0)];
        h2d_req_txn[1].opcode                    = h2d_req_opcode_t'(data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]);
        h2d_req_txn[1].address                   = data[(SLOT1_OFFSET+49):(SLOT1_OFFSET+4)];
        h2d_req_txn[1].uqid                      = data[(SLOT1_OFFSET+61)+(SLOT1_OFFSET+50)];
      end else begin
        h2d_req_txn[0].valid                     = data[(SLOT1_OFFSET+0)];
        h2d_req_txn[0].opcode                    = h2d_req_opcode_t'(data[(SLOT1_OFFSET+3):(SLOT1_OFFSET+1)]);
        h2d_req_txn[0].address                   = data[(SLOT1_OFFSET+49):(SLOT1_OFFSET+4)];
        h2d_req_txn[0].uqid                      = data[(SLOT1_OFFSET+61)+(SLOT1_OFFSET+50)];
      end
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT1_OFFSET+64)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+65)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT1_OFFSET+77)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT1_OFFSET+78)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT1_OFFSET+79)];
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid                     = data[(SLOT1_OFFSET+88)];
        h2d_rsp_txn[1].opcode                    = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+92):(SLOT1_OFFSET+89)]);
        h2d_rsp_txn[1].rspdata                   = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+93)]);
        h2d_rsp_txn[1].rsppre                    = data[(SLOT1_OFFSET+106):(SLOT1_OFFSET+105)];
        h2d_rsp_txn[1].cqid                      = data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+107)];
      end else begin
        h2d_rsp_txn[0].valid                     = data[(SLOT1_OFFSET+88)];
        h2d_rsp_txn[0].opcode                    = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+92):(SLOT1_OFFSET+89)]);
        h2d_rsp_txn[0].rspdata                   = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+93)]);
        h2d_rsp_txn[0].rsppre                    = data[(SLOT1_OFFSET+106):(SLOT1_OFFSET+105)];
        h2d_rsp_txn[0].cqid                      = data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+107)];
      end
    end else if(slot_sel == 'h2) begin
      if(h2d_req_ptr > 0) begin
        h2d_req_txn[1].valid                = data[(SLOT2_OFFSET+0)];
        h2d_req_txn[1].opcode               = h2d_req_opcode_t'(data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]);
        h2d_req_txn[1].address              = data[(SLOT2_OFFSET+49):(SLOT2_OFFSET+4)];
        h2d_req_txn[1].uqid                 = data[(SLOT2_OFFSET+61):(SLOT2_OFFSET+50)];
      end else begin
        h2d_req_txn[0].valid                = data[(SLOT2_OFFSET+0)];
        h2d_req_txn[0].opcode               = h2d_req_opcode_t'(data[(SLOT2_OFFSET+3):(SLOT2_OFFSET+1)]);
        h2d_req_txn[0].address              = data[(SLOT2_OFFSET+49):(SLOT2_OFFSET+4)];
        h2d_req_txn[0].uqid                 = data[(SLOT2_OFFSET+61):(SLOT2_OFFSET+50)];
      end
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT2_OFFSET+64)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+65)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+77)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT2_OFFSET+78)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+79)];
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid                = data[(SLOT2_OFFSET+88)];
        h2d_rsp_txn[1].opcode               = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+92):(SLOT2_OFFSET+89)]);
        h2d_rsp_txn[1].rspdata              = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+93)]);
        h2d_rsp_txn[1].rsppre               = data[(SLOT2_OFFSET+106):(SLOT2_OFFSET+105)];
        h2d_rsp_txn[1].cqid                 = data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+107)];
      end else begin
        h2d_rsp_txn[0].valid                = data[(SLOT2_OFFSET+88)];
        h2d_rsp_txn[0].opcode               = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+92):(SLOT2_OFFSET+89)]);
        h2d_rsp_txn[0].rspdata              = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+93)]);
        h2d_rsp_txn[0].rsppre               = data[(SLOT2_OFFSET+106):(SLOT2_OFFSET+105)];
        h2d_rsp_txn[0].cqid                 = data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+107)];
      end
    end else if(slot_sel == 'h3) begin
      if(h2d_req_ptr > 0) begin
        h2d_req_txn[1].valid                = data[(SLOT3_OFFSET+0)];
        h2d_req_txn[1].opcode               = h2d_req_opcode_t'(data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]);
        h2d_req_txn[1].address              = data[(SLOT3_OFFSET+49):(SLOT3_OFFSET+4)];
        h2d_req_txn[1].uqid                 = data[(SLOT3_OFFSET+61):(SLOT3_OFFSET+50)];
      end else begin
        h2d_req_txn[0].valid                = data[(SLOT3_OFFSET+0)];
        h2d_req_txn[0].opcode               = h2d_req_opcode_t'(data[(SLOT3_OFFSET+3):(SLOT3_OFFSET+1)]);
        h2d_req_txn[0].address              = data[(SLOT3_OFFSET+49):(SLOT3_OFFSET+4)];
        h2d_req_txn[0].uqid                 = data[(SLOT3_OFFSET+61):(SLOT3_OFFSET+50)];
      end
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT3_OFFSET+64)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+65)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT3_OFFSET+77)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT3_OFFSET+78)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT3_OFFSET+79)];
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid                = data[(SLOT3_OFFSET+88)];
        h2d_rsp_txn[1].opcode               = h2d_rsp_opcode_t'(data[(SLOT3_OFFSET+92):(SLOT3_OFFSET+89)]);
        h2d_rsp_txn[1].rspdata              = h2d_rsp_data_opcode_t'(data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+93)]);
        h2d_rsp_txn[1].rsppre               = data[(SLOT3_OFFSET+106):(SLOT3_OFFSET+105)];
        h2d_rsp_txn[1].cqid                 = data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+107)]; 
      end else begin
        h2d_rsp_txn[0].valid                = data[(SLOT3_OFFSET+88)];
        h2d_rsp_txn[0].opcode               = h2d_rsp_opcode_t'(data[(SLOT3_OFFSET+92):(SLOT3_OFFSET+89)]);
        h2d_rsp_txn[0].rspdata              = h2d_rsp_data_opcode_t'(data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+93)]);
        h2d_rsp_txn[0].rsppre               = data[(SLOT3_OFFSET+106):(SLOT3_OFFSET+105)];
        h2d_rsp_txn[0].cqid                 = data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+107)]; 
      end
    end else begin
      h2d_req_txn[0].valid = 'hX;
      h2d_req_txn[1].valid = 'hX;
      h2d_data_pkt[0].h2d_data_txn.valid = 'hX;
      h2d_rsp_txn[0].valid = 'hX;
      h2d_rsp_txn[1].valid = 'hX;
    end

  endfunction

  function automatic void generic3(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref h2d_data_pkt_t h2d_data_pkt[4],
    ref h2d_rsp_txn_t h2d_rsp_txn[4],
    input int h2d_rsp_ptr
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
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid                   = data[(SLOT1_OFFSET+96)];
        h2d_rsp_txn[1].opcode                  = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+97)]);
        h2d_rsp_txn[1].rspdata                 = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+112):(SLOT1_OFFSET+101)]);
        h2d_rsp_txn[1].rsppre                  = data[(SLOT1_OFFSET+114):(SLOT1_OFFSET+113)];
        h2d_rsp_txn[1].cqid                    = data[(SLOT1_OFFSET+126):(SLOT1_OFFSET+115)];
      end else begin
        h2d_rsp_txn[0].valid                   = data[(SLOT1_OFFSET+96)];
        h2d_rsp_txn[0].opcode                  = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+97)]);
        h2d_rsp_txn[0].rspdata                 = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+112):(SLOT1_OFFSET+101)]);
        h2d_rsp_txn[0].rsppre                  = data[(SLOT1_OFFSET+114):(SLOT1_OFFSET+113)];
        h2d_rsp_txn[0].cqid                    = data[(SLOT1_OFFSET+126):(SLOT1_OFFSET+115)];
      end
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
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid                   = data[(SLOT2_OFFSET+96)];
        h2d_rsp_txn[1].opcode                  = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)]);
        h2d_rsp_txn[1].rspdata                 = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)]);
        h2d_rsp_txn[1].rsppre                  = data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)];
        h2d_rsp_txn[1].cqid                    = data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)];    
      end else begin
        h2d_rsp_txn[0].valid                   = data[(SLOT2_OFFSET+96)];
        h2d_rsp_txn[0].opcode                  = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)]);
        h2d_rsp_txn[0].rspdata                 = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)]);
        h2d_rsp_txn[0].rsppre                  = data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)];
        h2d_rsp_txn[0].cqid                    = data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)];    
      end
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
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid                   = data[(SLOT2_OFFSET+96)];
        h2d_rsp_txn[1].opcode                  = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)]);
        h2d_rsp_txn[1].rspdata                 = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)]);
        h2d_rsp_txn[1].rsppre                  = data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)];
        h2d_rsp_txn[1].cqid                    = data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)];   
      end else begin
        h2d_rsp_txn[0].valid                   = data[(SLOT2_OFFSET+96)];
        h2d_rsp_txn[0].opcode                  = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+97)]);
        h2d_rsp_txn[0].rspdata                 = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+112):(SLOT2_OFFSET+101)]);
        h2d_rsp_txn[0].rsppre                  = data[(SLOT2_OFFSET+114):(SLOT2_OFFSET+113)];
        h2d_rsp_txn[0].cqid                    = data[(SLOT2_OFFSET+126):(SLOT2_OFFSET+115)];   
      end
    end else begin
      h2d_data_pkt[0].h2d_data_txn.valid = 'hX;
      h2d_data_pkt[1].h2d_data_txn.valid = 'hX;
      h2d_data_pkt[2].h2d_data_txn.valid = 'hX;
      h2d_data_pkt[3].h2d_data_txn.valid = 'hX;
      h2d_rsp_txn[0].valid               = 'hX;
      h2d_rsp_txn[1].valid               = 'hX;
    end

  endfunction
  
  function automatic void generic4(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref m2s_req_txn_t m2s_req_txn[2],
    input int m2s_req_ptr,
    ref h2d_data_pkt_t h2d_data_pkt[4]
  );

    if(slot_sel == 'h1) begin
      if(m2s_req_ptr > 0) begin
        m2s_req_txn[1].valid                   = data[(SLOT1_OFFSET+0)];
        m2s_req_txn[1].memopcode               = m2s_req_opcode_t'(data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)]);
        m2s_req_txn[1].snptype                 = snptype_t'(data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+5)]);
        m2s_req_txn[1].metafield               = metafield_t'(data[(SLOT1_OFFSET+9):(SLOT1_OFFSET+8)]);
        m2s_req_txn[1].metavalue               = metavalue_t'(data[(SLOT1_OFFSET+11):(SLOT1_OFFSET+10)]);
        m2s_req_txn[1].tag                     = data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+12)];
        m2s_req_txn[1].address                 = data[(SLOT1_OFFSET+74):(SLOT1_OFFSET+28)];
        m2s_req_txn[1].tc                      = data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+75)];
      end else begin
        m2s_req_txn[0].valid                   = data[(SLOT1_OFFSET+0)];
        m2s_req_txn[0].memopcode               = m2s_req_opcode_t'(data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)]);
        m2s_req_txn[0].snptype                 = snptype_t'(data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+5)]);
        m2s_req_txn[0].metafield               = metafield_t'(data[(SLOT1_OFFSET+9):(SLOT1_OFFSET+8)]);
        m2s_req_txn[0].metavalue               = metavalue_t'(data[(SLOT1_OFFSET+11):(SLOT1_OFFSET+10)]);
        m2s_req_txn[0].tag                     = data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+12)];
        m2s_req_txn[0].address                 = data[(SLOT1_OFFSET+74):(SLOT1_OFFSET+28)];
        m2s_req_txn[0].tc                      = data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+75)];
      end
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT1_OFFSET+88)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT1_OFFSET+100):(SLOT1_OFFSET+89)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT1_OFFSET+101)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT1_OFFSET+102)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT1_OFFSET+103)];
    end else if(slot_sel == 'h2) begin
      if(m2s_req_ptr > 0) begin
        m2s_req_txn[1].valid                   = data[(SLOT2_OFFSET+0)];
        m2s_req_txn[1].memopcode               = m2s_req_opcode_t'(data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)]);
        m2s_req_txn[1].snptype                 = snptype_t'(data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+5)]);
        m2s_req_txn[1].metafield               = metafield_t'(data[(SLOT2_OFFSET+9):(SLOT2_OFFSET+8)]);
        m2s_req_txn[1].metavalue               = metavalue_t'(data[(SLOT2_OFFSET+11):(SLOT2_OFFSET+10)]);
        m2s_req_txn[1].tag                     = data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+12)];
        m2s_req_txn[1].address                 = data[(SLOT2_OFFSET+74):(SLOT2_OFFSET+28)];
        m2s_req_txn[1].tc                      = data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+75)];
      end else begin
        m2s_req_txn[0].valid                   = data[(SLOT2_OFFSET+0)];
        m2s_req_txn[0].memopcode               = m2s_req_opcode_t'(data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)]);
        m2s_req_txn[0].snptype                 = snptype_t'(data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+5)]);
        m2s_req_txn[0].metafield               = metafield_t'(data[(SLOT2_OFFSET+9):(SLOT2_OFFSET+8)]);
        m2s_req_txn[0].metavalue               = metavalue_t'(data[(SLOT2_OFFSET+11):(SLOT2_OFFSET+10)]);
        m2s_req_txn[0].tag                     = data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+12)];
        m2s_req_txn[0].address                 = data[(SLOT2_OFFSET+74):(SLOT2_OFFSET+28)];
        m2s_req_txn[0].tc                      = data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+75)];
      end
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT2_OFFSET+88)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT2_OFFSET+100):(SLOT2_OFFSET+89)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT2_OFFSET+101)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT2_OFFSET+102)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT2_OFFSET+103)];
    end else if(slot_sel == 'h3) begin
      if(m2s_req_ptr > 0) begin
        m2s_req_txn[1].valid                   = data[(SLOT3_OFFSET+0)];
        m2s_req_txn[1].memopcode               = m2s_req_opcode_t'(data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)]);
        m2s_req_txn[1].snptype                 = snptype_t'(data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+5)]);
        m2s_req_txn[1].metafield               = metafield_t'(data[(SLOT3_OFFSET+9):(SLOT3_OFFSET+8)]);
        m2s_req_txn[1].metavalue               = metavalue_t'(data[(SLOT3_OFFSET+11):(SLOT3_OFFSET+10)]);
        m2s_req_txn[1].tag                     = data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+12)];
        m2s_req_txn[1].address                 = data[(SLOT3_OFFSET+74):(SLOT3_OFFSET+28)];
        m2s_req_txn[1].tc                      = data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+75)];
      end else begin
        m2s_req_txn[0].valid                   = data[(SLOT3_OFFSET+0)];
        m2s_req_txn[0].memopcode               = m2s_req_opcode_t'(data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)]);
        m2s_req_txn[0].snptype                 = snptype_t'(data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+5)]);
        m2s_req_txn[0].metafield               = metafield_t'(data[(SLOT3_OFFSET+9):(SLOT3_OFFSET+8)]);
        m2s_req_txn[0].metavalue               = metavalue_t'(data[(SLOT3_OFFSET+11):(SLOT3_OFFSET+10)]);
        m2s_req_txn[0].tag                     = data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+12)];
        m2s_req_txn[0].address                 = data[(SLOT3_OFFSET+74):(SLOT3_OFFSET+28)];
        m2s_req_txn[0].tc                      = data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+75)];
      end
      h2d_data_pkt[0].pending_data_slot        = 'hf;
      h2d_data_pkt[0].h2d_data_txn.valid       = data[(SLOT3_OFFSET+88)];
      h2d_data_pkt[0].h2d_data_txn.cqid        = data[(SLOT3_OFFSET+100):(SLOT3_OFFSET+89)];
      h2d_data_pkt[0].h2d_data_txn.chunkvalid  = data[(SLOT3_OFFSET+101)];
      h2d_data_pkt[0].h2d_data_txn.poison      = data[(SLOT3_OFFSET+102)];
      h2d_data_pkt[0].h2d_data_txn.goerr       = data[(SLOT3_OFFSET+103)];
    end else begin
      m2s_req_txn[0].valid = 'hX;
      m2s_req_txn[1].valid = 'hX;
      h2d_data_pkt[0].h2d_data_txn.valid = 'hX;
    end

  endfunction
  
  function automatic void generic5(
    input logic [1:0] slot_sel,
    input logic [511:0] data,
    ref m2s_rwd_pkt_t m2s_rwd_pkt,
    ref h2d_rsp_txn_t h2d_rsp_txn[4],
    input int h2d_rsp_ptr
  );

    if(slot_sel == 'h1) begin
      m2s_rwd_pkt.pending_data_slot        = 'hf;
      m2s_rwd_pkt.m2s_rwd_txn.valid        = data[(SLOT1_OFFSET+0)];
      m2s_rwd_pkt.m2s_rwd_txn.memopcode    = m2s_rwd_opcode_t'(data[(SLOT1_OFFSET+4):(SLOT1_OFFSET+1)]);
      m2s_rwd_pkt.m2s_rwd_txn.snptype      = snptype_t'(data[(SLOT1_OFFSET+7):(SLOT1_OFFSET+5)]);
      m2s_rwd_pkt.m2s_rwd_txn.metafield    = metafield_t'(data[(SLOT1_OFFSET+9):(SLOT1_OFFSET+8)]);
      m2s_rwd_pkt.m2s_rwd_txn.metavalue    = metavalue_t'(data[(SLOT1_OFFSET+11):(SLOT1_OFFSET+10)]);
      m2s_rwd_pkt.m2s_rwd_txn.tag          = data[(SLOT1_OFFSET+27):(SLOT1_OFFSET+12)];
      m2s_rwd_pkt.m2s_rwd_txn.address      = data[(SLOT1_OFFSET+73):(SLOT1_OFFSET+28)];
      m2s_rwd_pkt.m2s_rwd_txn.poison       = data[(SLOT1_OFFSET+74)];
      m2s_rwd_pkt.m2s_rwd_txn.tc           = data[(SLOT1_OFFSET+76):(SLOT1_OFFSET+75)];
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid               = data[(SLOT1_OFFSET+88)];
        h2d_rsp_txn[1].opcode              = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+92):(SLOT1_OFFSET+89)]);
        h2d_rsp_txn[1].rspdata             = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+93)]);
        h2d_rsp_txn[1].rsppre              = data[(SLOT1_OFFSET+106):(SLOT1_OFFSET+105)];
        h2d_rsp_txn[1].cqid                = data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+107)];
      end else begin
        h2d_rsp_txn[0].valid               = data[(SLOT1_OFFSET+88)];
        h2d_rsp_txn[0].opcode              = h2d_rsp_opcode_t'(data[(SLOT1_OFFSET+92):(SLOT1_OFFSET+89)]);
        h2d_rsp_txn[0].rspdata             = h2d_rsp_data_opcode_t'(data[(SLOT1_OFFSET+104):(SLOT1_OFFSET+93)]);
        h2d_rsp_txn[0].rsppre              = data[(SLOT1_OFFSET+106):(SLOT1_OFFSET+105)];
        h2d_rsp_txn[0].cqid                = data[(SLOT1_OFFSET+118):(SLOT1_OFFSET+107)];
      end
    end else if(slot_sel == 'h2) begin
      m2s_rwd_pkt.pending_data_slot        = 'hf;
      m2s_rwd_pkt.m2s_rwd_txn.valid        = data[(SLOT2_OFFSET+0)];
      m2s_rwd_pkt.m2s_rwd_txn.memopcode    = m2s_rwd_opcode_t'(data[(SLOT2_OFFSET+4):(SLOT2_OFFSET+1)]);
      m2s_rwd_pkt.m2s_rwd_txn.snptype      = snptype_t'(data[(SLOT2_OFFSET+7):(SLOT2_OFFSET+5)]);
      m2s_rwd_pkt.m2s_rwd_txn.metafield    = metafield_t'(data[(SLOT2_OFFSET+9):(SLOT2_OFFSET+8)]);
      m2s_rwd_pkt.m2s_rwd_txn.metavalue    = metavalue_t'(data[(SLOT2_OFFSET+11):(SLOT2_OFFSET+10)]);
      m2s_rwd_pkt.m2s_rwd_txn.tag          = data[(SLOT2_OFFSET+27):(SLOT2_OFFSET+12)];
      m2s_rwd_pkt.m2s_rwd_txn.address      = data[(SLOT2_OFFSET+73):(SLOT2_OFFSET+28)];
      m2s_rwd_pkt.m2s_rwd_txn.poison       = data[(SLOT2_OFFSET+74)];
      m2s_rwd_pkt.m2s_rwd_txn.tc           = data[(SLOT2_OFFSET+76):(SLOT2_OFFSET+75)];
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid               = data[(SLOT2_OFFSET+88)];
        h2d_rsp_txn[1].opcode              = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+92):(SLOT2_OFFSET+89)]);
        h2d_rsp_txn[1].rspdata             = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+93)]);
        h2d_rsp_txn[1].rsppre              = data[(SLOT2_OFFSET+106):(SLOT2_OFFSET+105)];
        h2d_rsp_txn[1].cqid                = data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+107)];
      end else begin
        h2d_rsp_txn[0].valid               = data[(SLOT2_OFFSET+88)];
        h2d_rsp_txn[0].opcode              = h2d_rsp_opcode_t'(data[(SLOT2_OFFSET+92):(SLOT2_OFFSET+89)]);
        h2d_rsp_txn[0].rspdata             = h2d_rsp_data_opcode_t'(data[(SLOT2_OFFSET+104):(SLOT2_OFFSET+93)]);
        h2d_rsp_txn[0].rsppre              = data[(SLOT2_OFFSET+106):(SLOT2_OFFSET+105)];
        h2d_rsp_txn[0].cqid                = data[(SLOT2_OFFSET+118):(SLOT2_OFFSET+107)];
      end
    end else if(slot_sel == 'h3) begin
      m2s_rwd_pkt.pending_data_slot        = 'hf;
      m2s_rwd_pkt.m2s_rwd_txn.valid        = data[(SLOT3_OFFSET+0)];
      m2s_rwd_pkt.m2s_rwd_txn.memopcode    = m2s_rwd_opcode_t'(data[(SLOT3_OFFSET+4):(SLOT3_OFFSET+1)]);
      m2s_rwd_pkt.m2s_rwd_txn.snptype      = snptype_t'(data[(SLOT3_OFFSET+7):(SLOT3_OFFSET+5)]);
      m2s_rwd_pkt.m2s_rwd_txn.metafield    = metafield_t'(data[(SLOT3_OFFSET+9):(SLOT3_OFFSET+8)]);
      m2s_rwd_pkt.m2s_rwd_txn.metavalue    = metavalue_t'(data[(SLOT3_OFFSET+11):(SLOT3_OFFSET+10)]);
      m2s_rwd_pkt.m2s_rwd_txn.tag          = data[(SLOT3_OFFSET+27):(SLOT3_OFFSET+12)];
      m2s_rwd_pkt.m2s_rwd_txn.address      = data[(SLOT3_OFFSET+73):(SLOT3_OFFSET+28)];
      m2s_rwd_pkt.m2s_rwd_txn.poison       = data[(SLOT3_OFFSET+74)];
      m2s_rwd_pkt.m2s_rwd_txn.tc           = data[(SLOT3_OFFSET+76):(SLOT3_OFFSET+75)];
      if(h2d_rsp_ptr > 0) begin
        h2d_rsp_txn[1].valid               = data[(SLOT3_OFFSET+88)];
        h2d_rsp_txn[1].opcode              = h2d_rsp_opcode_t'(data[(SLOT3_OFFSET+92):(SLOT3_OFFSET+89)]);
        h2d_rsp_txn[1].rspdata             = h2d_rsp_data_opcode_t'(data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+93)]);
        h2d_rsp_txn[1].rsppre              = data[(SLOT3_OFFSET+106):(SLOT3_OFFSET+105)];
        h2d_rsp_txn[1].cqid                = data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+107)]; 
      end else begin
        h2d_rsp_txn[0].valid               = data[(SLOT3_OFFSET+88)];
        h2d_rsp_txn[0].opcode              = h2d_rsp_opcode_t'(data[(SLOT3_OFFSET+92):(SLOT3_OFFSET+89)]);
        h2d_rsp_txn[0].rspdata             = h2d_rsp_data_opcode_t'(data[(SLOT3_OFFSET+104):(SLOT3_OFFSET+93)]);
        h2d_rsp_txn[0].rsppre              = data[(SLOT3_OFFSET+106):(SLOT3_OFFSET+105)];
        h2d_rsp_txn[0].cqid                = data[(SLOT3_OFFSET+118):(SLOT3_OFFSET+107)]; 
      end
    end else begin
      m2s_rwd_pkt.m2s_rwd_txn.valid = 'hX;
      h2d_rsp_txn[0].valid = 'hX;
      h2d_rsp_txn[1].valid = 'hX;
    end

  endfunction

  always@(posedge dev_rx_dl_if.clk) begin
    if(!dev_rx_dl_if.rstn) begin
      //TODO: not sure if this foreach will initialize for all indeces
      //foreach(data_slot[i]) data_slot[i] <= 'h0;
      //foreach(data_slot_d[i]) data_slot_d[i] <= 'h0;
      data_slot_d[0] <= 'h0;
      data_slot_d[1] <= 'h0;
      data_slot_d[2] <= 'h0;
      data_slot_d[3] <= 'h0;
      data_slot_d[4] <= 'h0;
      ack <= 'h0;
      ack_count_d <= 'h0;
      ack_ret_val <= 'h0;
    end else begin
      ack_count_d <= ack_count;
      if((ack_count_d == 'h7) && (ack_count == 'h0)) begin
        ack <= 'h1;
      end else begin
        ack <= 'h0;
      end
      if(dev_rx_dl_if_d_valid && retryable_flit && llcrd_flit) begin
        ack_ret_val <= 'h1;
      end else begin
        ack_ret_val <= 'h0;
      end
      if(dev_rx_dl_if_d_valid && retryable_flit && (!llcrd_flit)) begin
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
    if(dev_rx_dl_if_d_valid && retryable_flit && (!llcrd_flit) && 
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
      if(dev_rx_dl_if_d_data[7:5] == 'h4) begin
        data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;//need to add what happens when slot 1 is g slot
        if((dev_rx_dl_if_d_data[10:8] == 'h1) || (dev_rx_dl_if_d_data[10:8] == 'h5)) begin
          data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
          if((dev_rx_dl_if_d_data[13:11] == 'h1) || (dev_rx_dl_if_d_data[13:11] == 'h5)) begin
            data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            if((dev_rx_dl_if_d_data[16:14] == 'h1) || (dev_rx_dl_if_d_data[16:14] == 'h5)) begin
              data_slot[0] = 'h0; data_slot[1] = 'h0; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            end else if((dev_rx_dl_if_d_data[16:14] == 'h2) || (dev_rx_dl_if_d_data[16:14] == 'h4)) begin  
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
            end else if(dev_rx_dl_if_d_data[16:14] == 'h6) begin  
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h0;
            end else begin
              data_slot[0] = 'h0; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'hf;
            end
          end else if((dev_rx_dl_if_d_data[10:8] == 'h2) || (dev_rx_dl_if_d_data[10:8] == 'h4)) begin  
            data_slot[0] = 'h8; data_slot[1] = 'h7; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
          end else if(dev_rx_dl_if_d_data[10:8] == 'h6) begin  
            data_slot[0] = 'h8; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'h7; data_slot[4] = 'h0;
          end else begin
            data_slot[0] = 'h8; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h7;
          end
        end else if((dev_rx_dl_if_d_data[10:8] == 'h2) || (dev_rx_dl_if_d_data[10:8] == 'h4)) begin  
          data_slot[0] = 'hc; data_slot[1] = 'h3; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
        end else if(dev_rx_dl_if_d_data[10:8] == 'h6) begin  
          data_slot[0] = 'hc; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'h3; data_slot[4] = 'h0;
        end else begin
          data_slot[0] = 'hc; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h3;
        end
      end else if((dev_rx_dl_if_d_data[7:5] == 'h0) || (dev_rx_dl_if_d_data[7:5] == 'h1) || (dev_rx_dl_if_d_data[7:5] == 'h3)) begin
        data_slot[0] = 'he; data_slot[1] = 'h1; data_slot[2] = 'h0; data_slot[3] = 'h0; data_slot[4] = 'h0;
      end else if(dev_rx_dl_if_d_data[7:5] == 'h5) begin
        data_slot[0] = 'he; data_slot[1] = 'hf; data_slot[2] = 'h1; data_slot[3] = 'h0; data_slot[4] = 'h0;
      end else begin
        data_slot[0] = 'he; data_slot[1] = 'hf; data_slot[2] = 'hf; data_slot[3] = 'hf; data_slot[4] = 'h1;
      end
    //end else if(dev_rx_dl_if_d_valid && data_slot_d[0][0] /*&& data_slot_d[0][1] && data_slot_d[0][2] && data_slot_d[0][3]*/) begin
      //data_slot[0] = data_slot[1]; data_slot[1] = data_slot[2]; data_slot[3] = data_slot[4]; data_slot[4] = 'h0;
    end
    
    if(dev_rx_dl_if_d_valid && retryable_flit && (!llcrd_flit)) begin
      ack_count = ack_count + 1;
      if(!data_slot[0][0]) begin
        h2d_req_ptr = 'h0;
        h2d_rsp_ptr = 'h0;
        h2d_data_ptr = 'h0;
        m2s_req_ptr = 'h0;
        m2s_rwd_ptr = 'h0;
        case(dev_rx_dl_if_d_data[7:5])
          'h0: begin
            header0(dev_rx_dl_if_d_data, h2d_req_txn, h2d_rsp_txn);
            h2d_req_ptr = h2d_req_ptr + 1;
            h2d_rsp_ptr = h2d_rsp_ptr + 1;
          end
          'h1: begin
            header1(dev_rx_dl_if_d_data, h2d_data_pkt, h2d_rsp_txn);
          end
          'h2: begin
            header2(dev_rx_dl_if_d_data, h2d_req_txn, h2d_data_pkt);
          end
          'h3: begin
            header3(dev_rx_dl_if_d_data, h2d_data_pkt);
          end
          'h4: begin
            header4(dev_rx_dl_if_d_data, m2s_rwd_pkt);
          end
          'h5: begin
            header5(dev_rx_dl_if_d_data, m2s_req_txn);
            m2s_req_ptr = m2s_req_ptr + 1;
          end
          default: begin

          end
        endcase
        case(dev_rx_dl_if_d_data[10:8])
          'h0: begin
            generic0('h1, dev_rx_dl_if_d_data, h2d_data_pkt, m2s_rwd_pkt);
          end
          'h1: begin
            generic1('h1, dev_rx_dl_if_d_data, h2d_rsp_txn);
          end
          'h2: begin
            generic2('h1, dev_rx_dl_if_d_data, h2d_req_txn, h2d_req_ptr, h2d_data_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          'h3: begin
            generic3('h1, dev_rx_dl_if_d_data, h2d_data_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          'h4: begin
            generic4('h1, dev_rx_dl_if_d_data, m2s_req_txn, m2s_req_ptr, h2d_data_pkt);
          end
          'h5: begin
            generic5('h1, dev_rx_dl_if_d_data, m2s_rwd_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          default: begin
          
          end
        endcase
        case(dev_rx_dl_if_d_data[13:11])
          'h0: begin
            generic0('h2, dev_rx_dl_if_d_data, h2d_data_pkt, m2s_rwd_pkt);
          end
          'h1: begin
            generic1('h2, dev_rx_dl_if_d_data, h2d_rsp_txn);
          end
          'h2: begin
            generic2('h2, dev_rx_dl_if_d_data, h2d_req_txn, h2d_req_ptr, h2d_data_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          'h3: begin
            generic3('h2, dev_rx_dl_if_d_data, h2d_data_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          'h4: begin
            generic4('h2, dev_rx_dl_if_d_data, m2s_req_txn, m2s_req_ptr, h2d_data_pkt);
          end
          'h5: begin
            generic5('h2, dev_rx_dl_if_d_data, m2s_rwd_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          default: begin
          
          end
        endcase
        case(dev_rx_dl_if_d_data[16:14])
          'h0: begin
            generic0('h3, dev_rx_dl_if_d_data, h2d_data_pkt, m2s_rwd_pkt);
          end
          'h1: begin
            generic1('h3, dev_rx_dl_if_d_data, h2d_rsp_txn);
          end
          'h2: begin
            generic2('h3, dev_rx_dl_if_d_data, h2d_req_txn, h2d_req_ptr, h2d_data_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          'h3: begin
            generic3('h3, dev_rx_dl_if_d_data, h2d_data_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          'h4: begin
            generic4('h3, dev_rx_dl_if_d_data, m2s_req_txn, m2s_req_ptr, h2d_data_pkt);
          end
          'h5: begin
            generic5('h3, dev_rx_dl_if_d_data, m2s_rwd_pkt, h2d_rsp_txn, h2d_rsp_ptr);
          end
          default: begin
          
          end
        endcase
      end else if(data_slot[0][0]) begin
          generic0('h0, dev_rx_dl_if_d_data, h2d_data_pkt, m2s_rwd_pkt);
      end
    end

    if(dev_rx_dl_if_d_valid && retryable_flit && llcrd_flit) begin
      ack_count = ack_count + 1;
      ack_ret = {dev_rx_dl_if_d_data[71:68], dev_rx_dl_if_d_data[2], dev_rx_dl_if_d_data[66:64]};
    end
  end 

  cxl_lrsm_rrsm #(
  ) cxl_lrsm_rrsm_inst (
    .clk(dev_rx_dl_if.clk),
    .rstn(dev_rx_dl_if.rstn),
    .*
  );

  crc_check #( 
  ) c2c_check_inst (
    .data(dev_rx_dl_if.data),
    .*
  );

  //TODO: serious mistake I am assuming only one side of the link can have error at a time
  
  always@(posedge dev_rx_dl_if.clk) begin
    if(!dev_rx_dl_if.rstn) begin
      crc_pass_d <= 'h0;
      crc_fail_d <= 'h0;
      dev_rx_dl_if_d_valid <= 'h0;
      dev_rx_dl_if_d_data <= 'h0;
    end else begin
      crc_pass_d <= crc_pass;
      crc_fail_d <= crc_fail;
      dev_rx_dl_if_d_valid <= dev_rx_dl_if.valid;
      dev_rx_dl_if_d_data <= dev_rx_dl_if.data[527:16];
      if(dev_rx_dl_if_d_valid) begin
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
        RETRY_FRAME5: begin//TODO:some flaw in this check later
          if(retry_frame_detect) begin  
            retry_frame_states <= RETRY_FRAME5;
          end else if(retry_req_detect) begin
            retry_frame_states <= RETRY_NOFRAME;
            retry_req_rcvd <= 'h1;
            retry_frame_states <= RETRY_NOFRAME;
          end else if(retry_ack_detect) begin
            retry_ack_rcvd <= 'h1;
            retry_ack_empty_bit <= dev_rx_dl_if_d_data[64];
            retry_ack_num_retry <= dev_rx_dl_if_d_data[71:67];
            retry_frame_states <= RETRY_NOFRAME;
          end else begin
            retry_req_rcvd <= 'h0;
            retry_ack_rcvd <= 'h0;
            retry_frame_states <= RETRY_NOFRAME;
          end
        end
        default: begin
            retry_frame_states <= RETRY_NOFRAME;
        end
        endcase
      end
    end
  end

endmodule
//TODO: this replay logic is still under development and needs to be tested and verified
module replay_buffer#(
  parameter REPLAY_BUFFER_SIZE = 256,
  parameter REPLAY_BUFFER_IDX_WIDTH = $clog2(REPLAY_BUFFER_SIZE),
  parameter REPLAY_BUFFER_WIDTH = 512
)(
  cxl_host_tx_dl_if.mon replay_inbuff_if,
  cxl_host_tx_dl_if.tx_mp replay_outbuff_if,
  input logic ack,
  input logic nack,
  input logic fullack,
  output logic replay_buff_full,
  output logic replay_buff_empty,
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
  	input logic dwval,
  	input logic twval,
  	input logic qwval,
    input logic [ADDR_WIDTH-1:0] ack_cnt,
    input FIFO_DATA_TYPE datain,
    input FIFO_DATA_TYPE ddatain,
    input FIFO_DATA_TYPE tdatain,
    input FIFO_DATA_TYPE qdatain,
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
  
  FIFO_DATA_TYPE fifo_h[DEPTH];
  logic [ADDR_WIDTH:0] rdptr;
  logic [ADDR_WIDTH:0] wrptr;
 
  assign wptr = wrptr;
  
 	always@(posedge clk) begin
    if(!rstn) begin
     	rdptr <= 0;
     	wrptr <= 0;
     	empty <= 0;
     	full <= 0;
     	ovrflw <= 'h0;
     	undrflw <= 'h0;
     	eseq <= 'h0;
    end else begin
     	if(rval || wval) begin
        if((wval && !full) || (dwval && (occupancy < (DEPTH-3))) || (twval && (occupancy < (DEPTH-4))) || (qwval && (occupancy < (DEPTH-5)))) begin
         	casez({qwval,twval,dwval,wval})
            4'b0001: begin
              fifo_h[wrptr] <= datain;
         	    wrptr <= wrptr + 1;
         	    eseq <= eseq + 1;
            end
            //TODO: potential bug: look at how you are filling in the parallel writes because for 4 writes there could be 3 ready and this could trigger 3 writes and 4th will be ignored which will be a bug
            4'b001?: begin
              fifo_h[wrptr] <= datain;
              fifo_h[wrptr+1] <= ddatain;
         	    wrptr <= wrptr + 2;
         	    eseq <= eseq + 2;
            end
            4'b01??: begin
              fifo_h[wrptr] <= datain;
              fifo_h[wrptr+1] <= ddatain;
              fifo_h[wrptr+2] <= tdatain;
         	    wrptr <= wrptr + 3;
         	    eseq <= eseq + 3;
            end
            4'b1???: begin
              fifo_h[wrptr] <= datain;
              fifo_h[wrptr+1] <= ddatain;
              fifo_h[wrptr+2] <= tdatain;
              fifo_h[wrptr+3] <= qdatain;
         	    wrptr <= wrptr + 4;
         	    eseq <= eseq + 4;
            end
            default: begin
            end
          endcase
        end else if(((rval && (!empty)) || (drval && (occupancy>1)) || (trval && (occupancy>2)) || (qrval && (occupancy>3)))) begin
          casez({qrval,trval,drval,rval})
            4'b0001: begin
              if(ack_cnt == 0) begin
                rdptr <= rdptr + 1;
         	      dataout <= fifo_h[rdptr];
              end else begin
                rdptr <= rdptr + ack_cnt;
              end
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
       	occupancy <= (DEPTH - (wrptr - rdptr));
        if(rdptr == wrptr) begin
         	empty <= 'h1;
        end else begin 
         	empty <= 'h0;
        end
        if((rdptr[ADDR_WIDTH] != wrptr[ADDR_WIDTH]) && (rdptr[(ADDR_WIDTH-1):0] == wrptr[(ADDR_WIDTH-1):0])) begin
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

  localparam BUFFER_DEPTH = 32;
  localparam BUFFER_ADDR_WIDTH = $clog2(BUFFER_DEPTH);
  logic crdt_val;
  logic crdt_rsp_cm;
  logic crdt_req_cm;
  logic crdt_data_cm;
  logic [2:0] crdt_rsp;
  logic [2:0] crdt_req;
  logic [2:0] crdt_data;
  logic [BUFFER_ADDR_WIDTH-1:0] d2h_req_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] d2h_rsp_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] d2h_data_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] s2m_ndr_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] s2m_drs_occ;
  logic [BUFFER_ADDR_WIDTH:0]   d2h_req_wptr;
  logic [BUFFER_ADDR_WIDTH:0]   d2h_rsp_wptr;
  logic [BUFFER_ADDR_WIDTH:0]   d2h_data_wptr;
  logic [BUFFER_ADDR_WIDTH:0]   s2m_ndr_wptr;
  logic [BUFFER_ADDR_WIDTH:0]   s2m_drs_wptr;
  logic [BUFFER_ADDR_WIDTH-1:0] h2d_req_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] h2d_rsp_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] h2d_data_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] m2s_req_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] m2s_rwd_occ;
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
  logic d2h_req_valid;
  logic d2h_rsp_valid;
  logic d2h_data_valid;
  logic s2m_ndr_valid;
  logic s2m_drs_valid;
  d2h_req_txn_t d2h_req_dataout;
  d2h_rsp_txn_t d2h_rsp_dataout;
  d2h_data_txn_t d2h_data_dataout;
  s2m_ndr_txn_t s2m_ndr_dataout;
  s2m_drs_txn_t s2m_drs_dataout;
  h2d_req_txn_t h2d_req_dataout;
  h2d_req_txn_t h2d_req_ddataout;
  h2d_req_txn_t h2d_req_tdataout;
  h2d_req_txn_t h2d_req_qdataout;
  h2d_rsp_txn_t h2d_rsp_dataout;
  h2d_rsp_txn_t h2d_rsp_ddataout;
  h2d_rsp_txn_t h2d_rsp_tdataout;
  h2d_rsp_txn_t h2d_rsp_qdataout;
  h2d_data_txn_t h2d_data_dataout;
  h2d_data_txn_t h2d_data_ddataout;
  h2d_data_txn_t h2d_data_tdataout;
  h2d_data_txn_t h2d_data_qdataout;
  m2s_req_txn_t m2s_req_dataout;
  m2s_req_txn_t m2s_req_ddataout;
  m2s_req_txn_t m2s_req_tdataout;
  m2s_req_txn_t m2s_req_qdataout;
  m2s_rwd_txn_t m2s_rwd_dataout;
  m2s_rwd_txn_t m2s_rwd_ddataout;
  m2s_rwd_txn_t m2s_rwd_tdataout;
  m2s_rwd_txn_t m2s_rwd_qdataout;
  d2h_req_txn_t d2h_req_txn[4];
  d2h_rsp_txn_t d2h_rsp_txn[2];
  d2h_data_pkt_t d2h_data_pkt[4];
  s2m_ndr_txn_t s2m_ndr_txn[3];
  s2m_drs_pkt_t s2m_drs_pkt[3];
  logic ack;
  logic ack_ret_val;
  logic [7:0] ack_ret;
  logic init_done;
  logic m2s_req_full;
  logic m2s_rwd_full;
  logic h2d_req_full;
  logic h2d_rsp_full;
  logic h2d_data_full;
  int curr_c_crdt_rsp_cnt;
  int curr_m_crdt_rsp_cnt;
  int curr_c_crdt_req_cnt;
  int curr_m_crdt_req_cnt;
  int curr_c_crdt_data_cnt;
  int curr_m_crdt_data_cnt;

  always@(posedge host_m2s_req_if.clk) begin
    if(!host_m2s_req_if.rstn) begin
      curr_c_crdt_req_cnt <= 'h0;
    end else begin
      if(host_m2s_req_if.m2s_req_txn.valid && ((!crdt_val) || (crdt_val && crdt_req_cm) || (crdt_val && crdt_req_cm && (crdt_req == 0)))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt - host_m2s_req_if.m2s_req_txn.valid;
      end else if(!host_m2s_req_if.m2s_req_txn.valid && (crdt_val && !crdt_req_cm && (crdt_req != 0))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt + ((crdt_req == 'd1)? 'd1: (crdt_req == 'd2)? 'd2: (crdt_req == 'd3)? 'd4: (crdt_req == 'd4)? 'd8: (crdt_req == 'd5)? 'd16: (crdt_req == 'd6)? 'd32: (crdt_req == 'd7)? 'd64: 'hX);
      end else if(host_m2s_req_if.m2s_req_txn.valid && (crdt_val && !crdt_req_cm && (crdt_req != 0))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt - host_m2s_req_if.m2s_req_txn.valid + ((crdt_req == 'd1)? 'd1: (crdt_req == 'd2)? 'd2: (crdt_req == 'd3)? 'd4: (crdt_req == 'd4)? 'd8: (crdt_req == 'd5)? 'd16: (crdt_req == 'd6)? 'd32: (crdt_req == 'd7)? 'd64: 'hX);
      end
    end
  end
  
  always@(posedge host_m2s_rwd_if.clk) begin
    if(!host_m2s_rwd_if.rstn) begin
      curr_c_crdt_data_cnt <= 'h0;
    end else begin
      if(host_m2s_rwd_if.m2s_rwd_txn.valid && ((!crdt_val) || (crdt_val && crdt_data_cm) || (crdt_val && crdt_data_cm && (crdt_data == 0)))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt - host_m2s_rwd_if.m2s_rwd_txn.valid;
      end else if(!host_m2s_rwd_if.m2s_rwd_txn.valid && (crdt_val && !crdt_data_cm && (crdt_data != 0))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt + ((crdt_data == 'd1)? 'd1: (crdt_data == 'd2)? 'd2: (crdt_data == 'd3)? 'd4: (crdt_data == 'd4)? 'd8: (crdt_data == 'd5)? 'd16: (crdt_data == 'd6)? 'd32: (crdt_data == 'd7)? 'd64: 'hX);
      end else if(host_m2s_rwd_if.m2s_rwd_txn.valid && (crdt_val && !crdt_data_cm && (crdt_data != 0))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt - host_m2s_rwd_if.m2s_rwd_txn.valid + ((crdt_data == 'd1)? 'd1: (crdt_data == 'd2)? 'd2: (crdt_data == 'd3)? 'd4: (crdt_data == 'd4)? 'd8: (crdt_data == 'd5)? 'd16: (crdt_data == 'd6)? 'd32: (crdt_data == 'd7)? 'd64: 'hX);
      end
    end
  end

  always@(posedge host_h2d_rsp_if.clk) begin
    if(!host_h2d_rsp_if.rstn) begin
      curr_c_crdt_rsp_cnt <= 'h0;
    end else begin
      if(host_h2d_rsp_if.h2d_rsp_txn.valid && ((!crdt_val) || (crdt_val && crdt_rsp_cm) || (crdt_val && crdt_rsp_cm && (crdt_rsp == 0)))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt - host_h2d_rsp_if.h2d_rsp_txn.valid;
      end else if(!host_h2d_rsp_if.h2d_rsp_txn.valid && (crdt_val && !crdt_rsp_cm && (crdt_rsp != 0))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt + ((crdt_rsp == 'd1)? 'd1: (crdt_rsp == 'd2)? 'd2: (crdt_rsp == 'd3)? 'd4: (crdt_rsp == 'd4)? 'd8: (crdt_rsp == 'd5)? 'd16: (crdt_rsp == 'd6)? 'd32: (crdt_rsp == 'd7)? 'd64: 'hX);
      end else if(host_h2d_rsp_if.h2d_rsp_txn.valid && (crdt_val && !crdt_rsp_cm && (crdt_rsp != 0))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt - host_h2d_rsp_if.h2d_rsp_txn.valid + ((crdt_rsp == 'd1)? 'd1: (crdt_rsp == 'd2)? 'd2: (crdt_rsp == 'd3)? 'd4: (crdt_rsp == 'd4)? 'd8: (crdt_rsp == 'd5)? 'd16: (crdt_rsp == 'd6)? 'd32: (crdt_rsp == 'd7)? 'd64: 'hX);
      end
    end
  end

  always@(posedge host_h2d_req_if.clk) begin
    if(!host_h2d_req_if.rstn) begin
      curr_c_crdt_req_cnt <= 'h0;
    end else begin
      if(host_h2d_req_if.h2d_req_txn.valid && ((!crdt_val) || (crdt_val && crdt_req_cm) || (crdt_val && crdt_req_cm && (crdt_req == 0)))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt - host_h2d_req_if.h2d_req_txn.valid;
      end else if(!host_h2d_req_if.h2d_req_txn.valid && (crdt_val && !crdt_req_cm && (crdt_req != 0))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt + ((crdt_req == 'd1)? 'd1: (crdt_req == 'd2)? 'd2: (crdt_req == 'd3)? 'd4: (crdt_req == 'd4)? 'd8: (crdt_req == 'd5)? 'd16: (crdt_req == 'd6)? 'd32: (crdt_req == 'd7)? 'd64: 'hX);
      end else if(host_h2d_req_if.h2d_req_txn.valid && (crdt_val && !crdt_req_cm && (crdt_req != 0))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt - host_h2d_req_if.h2d_req_txn.valid + ((crdt_req == 'd1)? 'd1: (crdt_req == 'd2)? 'd2: (crdt_req == 'd3)? 'd4: (crdt_req == 'd4)? 'd8: (crdt_req == 'd5)? 'd16: (crdt_req == 'd6)? 'd32: (crdt_req == 'd7)? 'd64: 'hX);
      end
    end
  end

  always@(posedge host_h2d_data_if.clk) begin
    if(!host_h2d_data_if.rstn) begin
      curr_c_crdt_data_cnt <= 'h0;
    end else begin
      if(host_h2d_data_if.h2d_data_txn.valid && ((!crdt_val) || (crdt_val && crdt_data_cm) || (crdt_val && crdt_data_cm && (crdt_data == 0)))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt - host_h2d_data_if.h2d_data_txn.valid;
      end else if(!host_h2d_data_if.h2d_data_txn.valid && (crdt_val && !crdt_data_cm && (crdt_data != 0))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt + ((crdt_data == 'd1)? 'd1: (crdt_data == 'd2)? 'd2: (crdt_data == 'd3)? 'd4: (crdt_data == 'd4)? 'd8: (crdt_data == 'd5)? 'd16: (crdt_data == 'd6)? 'd32: (crdt_data == 'd7)? 'd64: 'hX);
      end else if(host_h2d_data_if.h2d_data_txn.valid && (crdt_val && !crdt_data_cm && (crdt_data != 0))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt - host_h2d_data_if.h2d_data_txn.valid + ((crdt_data == 'd1)? 'd1: (crdt_data == 'd2)? 'd2: (crdt_data == 'd3)? 'd4: (crdt_data == 'd4)? 'd8: (crdt_data == 'd5)? 'd16: (crdt_data == 'd6)? 'd32: (crdt_data == 'd7)? 'd64: 'hX);
      end
    end
  end

  assign host_m2s_req_if.ready = (!m2s_req_full) && (curr_m_crdt_req_cnt != 0);
  assign host_m2s_rwd_if.ready = (!m2s_rwd_full) && (curr_m_crdt_data_cnt != 0);
  assign host_h2d_req_if.ready = (!h2d_req_full) && (curr_c_crdt_req_cnt != 0);
  assign host_h2d_rsp_if.ready = (!h2d_rsp_full) && (curr_c_crdt_rsp_cnt != 0);
  assign host_h2d_data_if.ready = (!h2d_data_full) && (curr_c_crdt_data_cnt != 0);
  assign host_d2h_req_if.d2h_req_txn.valid = !d2h_req_valid;
  assign host_d2h_req_if.d2h_req_txn = d2h_req_dataout;
  assign host_d2h_rsp_if.d2h_rsp_txn.valid = !d2h_rsp_valid;
  assign host_d2h_rsp_if.d2h_rsp_txn = d2h_rsp_dataout;
  assign host_d2h_data_if.d2h_data_txn.valid = !d2h_data_valid;
  assign host_d2h_data_if.d2h_data_txn = d2h_data_dataout;
  assign host_s2m_ndr_if.s2m_ndr_txn.valid = !s2m_ndr_valid;
  assign host_s2m_ndr_if.s2m_ndr_txn = s2m_ndr_dataout;
  assign host_s2m_drs_if.s2m_drs_txn.valid = !s2m_drs_valid;
  assign host_s2m_drs_if.s2m_drs_txn = s2m_drs_dataout;

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(d2h_req_txn_t)
  ) d2h_req_fifo_inst (
	  .clk(host_d2h_req_if.clk),
  	.rstn(host_d2h_req_if.rstn),
  	.rval(host_d2h_req_if.ready),
  	.wval(d2h_req_txn[0].valid),
  	.dwval(d2h_req_txn[1].valid),
  	.twval(d2h_req_txn[2].valid),
  	.qwval(d2h_req_txn[3].valid),
    .datain(d2h_req_txn[0]),
    .ddatain(d2h_req_txn[1]),
    .tdatain(d2h_req_txn[2]),
    .qdatain(d2h_req_txn[3]),
    .dataout(d2h_req_dataout),
  	.eseq,
  	.wptr(d2h_req_wptr),
  	.empty(d2h_req_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(d2h_req_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(d2h_rsp_txn_t)
  ) d2h_rsp_fifo_inst (
	  .clk(host_d2h_rsp_if.clk),
  	.rstn(host_d2h_rsp_if.rstn),
  	.rval(host_d2h_rsp_if.ready),
  	.wval(d2h_rsp_txn[0].valid),
  	.dwval(d2h_rsp_txn[1].valid),
    .datain(d2h_rsp_txn[0]),
    .ddatain(d2h_rsp_txn[1]),
    .dataout(d2h_rsp_dataout),
  	.eseq,
  	.wptr(d2h_rsp_wptr),
  	.empty(d2h_rsp_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(d2h_rsp_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(d2h_data_txn_t)
  ) d2h_data_fifo_inst (
	  .clk(host_d2h_data_if.clk),
  	.rstn(host_d2h_data_if.rstn),
  	.rval(host_d2h_data_if.ready),
  	.wval(((d2h_data_pkt[0].d2h_data_txn.valid) && (!(|d2h_data_pkt[0].pending_data_slot)))),
  	.qwval(((d2h_data_pkt[3].d2h_data_txn.valid) && (!(|d2h_data_pkt[3].pending_data_slot)))),
    .datain(d2h_data_pkt[0].d2h_data_txn),
    .ddatain(d2h_data_pkt[1].d2h_data_txn),
    .tdatain(d2h_data_pkt[2].d2h_data_txn),
    .qdatain(d2h_data_pkt[3].d2h_data_txn),
    .dataout(d2h_data_dataout),
  	.eseq,
  	.wptr(d2h_data_wptr),
  	.empty(d2h_data_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(d2h_data_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(s2m_ndr_txn_t)
  ) s2m_ndr_fifo_inst (
	  .clk(host_s2m_ndr_if.clk),
  	.rstn(host_s2m_ndr_if.rstn),
  	.rval(host_s2m_ndr_if.ready),
  	.wval(s2m_ndr_txn[0].valid),
  	.dwval(s2m_ndr_txn[1].valid),
  	.twval(s2m_ndr_txn[2].valid),
    .datain(s2m_ndr_txn[0]),
    .ddatain(s2m_ndr_txn[1]),
    .tdatain(s2m_ndr_txn[2]),
    .dataout(s2m_ndr_dataout),
  	.eseq,
  	.wptr(s2m_ndr_wptr),
  	.empty(s2m_ndr_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(s2m_ndr_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(s2m_drs_txn_t)
  ) s2m_drs_fifo_inst (
	  .clk(host_s2m_drs_if.clk),
  	.rstn(host_s2m_drs_if.rstn),
  	.rval(host_s2m_drs_if.ready),
  	.wval(((s2m_drs_pkt[0].s2m_drs_txn.valid) && (!(|s2m_drs_pkt[0].pending_data_slot)))),
  	.dwval(((s2m_drs_pkt[1].s2m_drs_txn.valid) && (!(|s2m_drs_pkt[1].pending_data_slot)))),
  	.twval(((s2m_drs_pkt[2].s2m_drs_txn.valid) && (!(|s2m_drs_pkt[2].pending_data_slot)))),
    .datain(s2m_drs_pkt[0].s2m_drs_txn),
    .ddatain(s2m_drs_pkt[1].s2m_drs_txn),
    .tdatain(s2m_drs_pkt[2].s2m_drs_txn),
    .dataout(s2m_drs_dataout),
  	.eseq,
  	.wptr(s2m_drs_wptr),
  	.empty(s2m_drs_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(s2m_drs_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(m2s_req_txn_t)
  ) m2s_req_fifo_inst (
	  .clk(host_m2s_req_if.clk),
  	.rstn(host_m2s_req_if.rstn),
  	.rval(m2s_req_rval),
  	.drval(m2s_req_drval),
  	.qrval(m2s_req_qrval),
  	.wval(host_m2s_req_if.m2s_req_txn.valid),
    .datain(host_m2s_req_if.m2s_req_txn),
    .dataout(m2s_req_dataout),
    .ddataout(m2s_req_ddataout),
    .tdataout(m2s_req_tdataout),
    .qdataout(m2s_req_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(m2s_req_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(m2s_req_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(m2s_rwd_txn_t)
  ) m2s_rwd_fifo_inst (
	  .clk(host_m2s_rwd_if.clk),
  	.rstn(host_m2s_rwd_if.rstn),
  	.rval(m2s_rwd_rval),
  	.drval(m2s_rwd_drval),
  	.qrval(m2s_rwd_qrval),
  	.wval(host_m2s_rwd_if.m2s_rwd_txn.valid),
    .datain(host_m2s_rwd_if.m2s_rwd_txn),
    .dataout(m2s_rwd_dataout),
    .ddataout(m2s_rwd_ddataout),
    .tdataout(m2s_rwd_tdataout),
    .qdataout(m2s_rwd_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(m2s_rwd_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(m2s_rwd_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(h2d_req_txn_t)
  ) h2d_req_fifo_inst (
	  .clk(host_h2d_req_if.clk),
  	.rstn(host_h2d_req_if.rstn),
  	.rval(h2d_req_rval),
  	.drval(h2d_req_drval),
  	.qrval(h2d_req_qrval),
  	.wval(host_h2d_req_if.h2d_req_txn.valid),
    .datain(host_h2d_req_if.h2d_req_txn),
    .dataout(h2d_req_dataout),
    .ddataout(h2d_req_ddataout),
    .tdataout(h2d_req_tdataout),
    .qdataout(h2d_req_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(h2d_req_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_req_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(h2d_rsp_txn_t)
  ) h2d_rsp_fifo_inst (
	  .clk(host_h2d_rsp_if.clk),
  	.rstn(host_h2d_rsp_if.rstn),
  	.rval(h2d_rsp_rval),
  	.drval(h2d_rsp_drval),
  	.qrval(h2d_rsp_qrval),
  	.wval(host_h2d_rsp_if.h2d_rsp_txn.valid),
    .datain(host_h2d_rsp_if.h2d_rsp_txn),
    .dataout(h2d_rsp_dataout),
    .ddataout(h2d_rsp_ddataout),
    .tdataout(h2d_rsp_tdataout),
    .qdataout(h2d_rsp_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(h2d_rsp_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_rsp_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(h2d_data_txn_t)
  ) h2d_data_fifo_inst (
	  .clk(host_h2d_data_if.clk),
  	.rstn(host_h2d_data_if.rstn),
  	.rval(h2d_data_rval),
  	.drval(h2d_data_drval),
  	.qrval(h2d_data_qrval),
  	.wval(host_h2d_data_if.h2d_data_txn.valid),
    .datain(host_h2d_data_if.h2d_data_txn),
    .dataout(h2d_data_dataout),
    .ddataout(h2d_data_ddataout),
    .tdataout(h2d_data_tdataout),
    .qdataout(h2d_data_qdataout),
  	.eseq,
  	.wptr,
  	.empty,
    .full(h2d_data_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_data_occ)
  );

  host_tx_path #(
    .BUFFER_DEPTH(BUFFER_DEPTH),
    .BUFFER_ADDR_WIDTH(BUFFER_ADDR_WIDTH)
  ) host_tx_path_inst (
    .*
  );

  host_rx_path #(

  ) host_rx_path_inst (
    .*
  );
/*
  replay_buffer #(

  ) replay_buffer_inst (
    .*
  );
*/
endmodule

module cxl_device
   #(
  
   ) (
    cxl_cache_d2h_req_if.dev_if_mp  dev_d2h_req_if,
    cxl_cache_d2h_rsp_if.dev_if_mp  dev_d2h_rsp_if,
    cxl_cache_d2h_data_if.dev_if_mp dev_d2h_data_if,
    cxl_cache_h2d_req_if.dev_if_mp  dev_h2d_req_if,
    cxl_cache_h2d_rsp_if.dev_if_mp  dev_h2d_rsp_if,
    cxl_cache_h2d_data_if.dev_if_mp dev_h2d_data_if,
    cxl_mem_m2s_req_if.dev_if_mp    dev_m2s_req_if,
    cxl_mem_m2s_rwd_if.dev_if_mp    dev_m2s_rwd_if,
    cxl_mem_s2m_ndr_if.dev_if_mp    dev_s2m_ndr_if,
    cxl_mem_s2m_drs_if.dev_if_mp    dev_s2m_drs_if,
    cxl_dev_tx_dl_if.tx_mp          dev_tx_dl_if,
    cxl_dev_rx_dl_if.rx_mp          dev_rx_dl_if
);

  localparam BUFFER_DEPTH = 32;
  localparam BUFFER_ADDR_WIDTH = $clog2(BUFFER_DEPTH);
  logic crdt_val;
  logic crdt_rsp_cm;
  logic crdt_req_cm;
  logic crdt_data_cm;
  logic [2:0] crdt_rsp;
  logic [2:0] crdt_req;
  logic [2:0] crdt_data;
  logic [BUFFER_ADDR_WIDTH-1:0] h2d_req_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] h2d_rsp_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] h2d_data_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] m2s_req_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] m2s_rwd_occ;
  logic [BUFFER_ADDR_WIDTH:0]   h2d_req_wptr;
  logic [BUFFER_ADDR_WIDTH:0]   h2d_rsp_wptr;
  logic [BUFFER_ADDR_WIDTH:0]   h2d_data_wptr;
  logic [BUFFER_ADDR_WIDTH:0]   m2s_req_wptr;
  logic [BUFFER_ADDR_WIDTH:0]   m2s_rwd_wptr;
  logic [BUFFER_ADDR_WIDTH-1:0] d2h_req_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] d2h_rsp_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] d2h_data_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] s2m_ndr_occ;
  logic [BUFFER_ADDR_WIDTH-1:0] s2m_drs_occ;
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
  logic h2d_req_valid;
  logic h2d_rsp_valid;
  logic h2d_data_valid;
  logic m2s_req_valid;
  logic m2s_rwd_valid;
  h2d_req_txn_t h2d_req_dataout;
  h2d_rsp_txn_t h2d_rsp_dataout;
  h2d_data_txn_t h2d_data_dataout;
  m2s_req_txn_t m2s_req_dataout;
  m2s_rwd_txn_t m2s_rwd_dataout;
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
  h2d_req_txn_t h2d_req_txn[2];
  h2d_rsp_txn_t h2d_rsp_txn[4];
  h2d_data_pkt_t h2d_data_pkt[4];
  m2s_req_txn_t m2s_req_txn[2];
  m2s_rwd_pkt_t m2s_rwd_pkt;
  logic ack;
  logic ack_ret_val;
  logic [7:0] ack_ret;
  logic init_done;
  logic s2m_ndr_full;
  logic s2m_drs_full;
  logic d2h_req_full;
  logic d2h_rsp_full;
  logic d2h_data_full;
  int curr_c_crdt_rsp_cnt;
  int curr_m_crdt_rsp_cnt;
  int curr_c_crdt_req_cnt;
  int curr_m_crdt_req_cnt;
  int curr_c_crdt_data_cnt;
  int curr_m_crdt_data_cnt;

  always@(posedge dev_s2m_ndr_if.clk) begin
    if(!dev_s2m_ndr_if.rstn) begin
      curr_c_crdt_rsp_cnt <= 'h0;
    end else begin
      if(dev_s2m_ndr_if.s2m_ndr_txn.valid && ((!crdt_val) || (crdt_val && crdt_rsp_cm) || (crdt_val && crdt_rsp_cm && (crdt_rsp == 0)))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt - dev_s2m_ndr_if.s2m_ndr_txn.valid;
      end else if(!dev_s2m_ndr_if.s2m_ndr_txn.valid && (crdt_val && !crdt_rsp_cm && (crdt_rsp != 0))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt + ((crdt_rsp == 'd1)? 'd1: (crdt_rsp == 'd2)? 'd2: (crdt_rsp == 'd3)? 'd4: (crdt_rsp == 'd4)? 'd8: (crdt_rsp == 'd5)? 'd16: (crdt_rsp == 'd6)? 'd32: (crdt_rsp == 'd7)? 'd64: 'hX);
      end else if(dev_s2m_ndr_if.s2m_ndr_txn.valid && (crdt_val && !crdt_rsp_cm && (crdt_rsp != 0))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt - dev_s2m_ndr_if.s2m_ndr_txn.valid + ((crdt_rsp == 'd1)? 'd1: (crdt_rsp == 'd2)? 'd2: (crdt_rsp == 'd3)? 'd4: (crdt_rsp == 'd4)? 'd8: (crdt_rsp == 'd5)? 'd16: (crdt_rsp == 'd6)? 'd32: (crdt_rsp == 'd7)? 'd64: 'hX);
      end
    end
  end
  
  always@(posedge dev_s2m_drs_if.clk) begin
    if(!dev_s2m_drs_if.rstn) begin
      curr_c_crdt_data_cnt <= 'h0;
    end else begin
      if(dev_s2m_drs_if.s2m_drs_txn.valid && ((!crdt_val) || (crdt_val && crdt_data_cm) || (crdt_val && crdt_data_cm && (crdt_data == 0)))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt - dev_s2m_drs_if.s2m_drs_txn.valid;
      end else if(!dev_s2m_drs_if.s2m_drs_txn.valid && (crdt_val && !crdt_data_cm && (crdt_data != 0))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt + ((crdt_data == 'd1)? 'd1: (crdt_data == 'd2)? 'd2: (crdt_data == 'd3)? 'd4: (crdt_data == 'd4)? 'd8: (crdt_data == 'd5)? 'd16: (crdt_data == 'd6)? 'd32: (crdt_data == 'd7)? 'd64: 'hX);
      end else if(dev_s2m_drs_if.s2m_drs_txn.valid && (crdt_val && !crdt_data_cm && (crdt_data != 0))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt - dev_s2m_drs_if.s2m_drs_txn.valid + ((crdt_data == 'd1)? 'd1: (crdt_data == 'd2)? 'd2: (crdt_data == 'd3)? 'd4: (crdt_data == 'd4)? 'd8: (crdt_data == 'd5)? 'd16: (crdt_data == 'd6)? 'd32: (crdt_data == 'd7)? 'd64: 'hX);
      end
    end
  end
  
  always@(posedge dev_d2h_rsp_if.clk) begin
    if(!dev_d2h_rsp_if.rstn) begin
      curr_c_crdt_rsp_cnt <= 'h0;
    end else begin
      if(dev_d2h_rsp_if.d2h_rsp_txn.valid && ((!crdt_val) || (crdt_val && crdt_rsp_cm) || (crdt_val && crdt_rsp_cm && (crdt_rsp == 0)))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt - dev_d2h_rsp_if.d2h_rsp_txn.valid;
      end else if(!dev_d2h_rsp_if.d2h_rsp_txn.valid && (crdt_val && !crdt_rsp_cm && (crdt_rsp != 0))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt + ((crdt_rsp == 'd1)? 'd1: (crdt_rsp == 'd2)? 'd2: (crdt_rsp == 'd3)? 'd4: (crdt_rsp == 'd4)? 'd8: (crdt_rsp == 'd5)? 'd16: (crdt_rsp == 'd6)? 'd32: (crdt_rsp == 'd7)? 'd64: 'hX);
      end else if(dev_d2h_rsp_if.d2h_rsp_txn.valid && (crdt_val && !crdt_rsp_cm && (crdt_rsp != 0))) begin
        curr_c_crdt_rsp_cnt <= curr_c_crdt_rsp_cnt - dev_d2h_rsp_if.d2h_rsp_txn.valid + ((crdt_rsp == 'd1)? 'd1: (crdt_rsp == 'd2)? 'd2: (crdt_rsp == 'd3)? 'd4: (crdt_rsp == 'd4)? 'd8: (crdt_rsp == 'd5)? 'd16: (crdt_rsp == 'd6)? 'd32: (crdt_rsp == 'd7)? 'd64: 'hX);
      end
    end
  end

  always@(posedge dev_d2h_req_if.clk) begin
    if(!dev_d2h_req_if.rstn) begin
      curr_c_crdt_req_cnt <= 'h0;
    end else begin
      if(dev_d2h_req_if.d2h_req_txn.valid && ((!crdt_val) || (crdt_val && crdt_req_cm) || (crdt_val && crdt_req_cm && (crdt_req == 0)))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt - dev_d2h_req_if.d2h_req_txn.valid;
      end else if(!dev_d2h_req_if.d2h_req_txn.valid && (crdt_val && !crdt_req_cm && (crdt_req != 0))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt + ((crdt_req == 'd1)? 'd1: (crdt_req == 'd2)? 'd2: (crdt_req == 'd3)? 'd4: (crdt_req == 'd4)? 'd8: (crdt_req == 'd5)? 'd16: (crdt_req == 'd6)? 'd32: (crdt_req == 'd7)? 'd64: 'hX);
      end else if(dev_d2h_req_if.d2h_req_txn.valid && (crdt_val && !crdt_req_cm && (crdt_req != 0))) begin
        curr_c_crdt_req_cnt <= curr_c_crdt_req_cnt - dev_d2h_req_if.d2h_req_txn.valid + ((crdt_req == 'd1)? 'd1: (crdt_req == 'd2)? 'd2: (crdt_req == 'd3)? 'd4: (crdt_req == 'd4)? 'd8: (crdt_req == 'd5)? 'd16: (crdt_req == 'd6)? 'd32: (crdt_req == 'd7)? 'd64: 'hX);
      end
    end
  end

  always@(posedge dev_d2h_data_if.clk) begin
    if(!dev_d2h_data_if.rstn) begin
      curr_c_crdt_data_cnt <= 'h0;
    end else begin
      if(dev_d2h_data_if.d2h_data_txn.valid && ((!crdt_val) || (crdt_val && crdt_data_cm) || (crdt_val && crdt_data_cm && (crdt_data == 0)))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt - dev_d2h_data_if.d2h_data_txn.valid;
      end else if(!dev_d2h_data_if.d2h_data_txn.valid && (crdt_val && !crdt_data_cm && (crdt_data != 0))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt + ((crdt_data == 'd1)? 'd1: (crdt_data == 'd2)? 'd2: (crdt_data == 'd3)? 'd4: (crdt_data == 'd4)? 'd8: (crdt_data == 'd5)? 'd16: (crdt_data == 'd6)? 'd32: (crdt_data == 'd7)? 'd64: 'hX);
      end else if(dev_d2h_data_if.d2h_data_txn.valid && (crdt_val && !crdt_data_cm && (crdt_data != 0))) begin
        curr_c_crdt_data_cnt <= curr_c_crdt_data_cnt - dev_d2h_data_if.d2h_data_txn.valid + ((crdt_data == 'd1)? 'd1: (crdt_data == 'd2)? 'd2: (crdt_data == 'd3)? 'd4: (crdt_data == 'd4)? 'd8: (crdt_data == 'd5)? 'd16: (crdt_data == 'd6)? 'd32: (crdt_data == 'd7)? 'd64: 'hX);
      end
    end
  end

  assign dev_s2m_ndr_if.ready = (!s2m_ndr_full) && (curr_m_crdt_rsp_cnt != 0);
  assign dev_s2m_drs_if.ready = (!s2m_drs_full) && (curr_m_crdt_data_cnt != 0);
  assign dev_d2h_req_if.ready = (!d2h_req_full) && (curr_c_crdt_req_cnt != 0);
  assign dev_d2h_rsp_if.ready = (!d2h_rsp_full) && (curr_c_crdt_rsp_cnt != 0);
  assign dev_d2h_data_if.ready = (!d2h_data_full) && (curr_c_crdt_data_cnt != 0);
  assign dev_m2s_req_if.m2s_req_txn.valid = m2s_req_valid; 
  assign dev_m2s_rwd_if.m2s_rwd_txn.valid = m2s_rwd_valid;
  assign dev_h2d_req_if.h2d_req_txn.valid = h2d_req_valid;
  assign dev_h2d_rsp_if.h2d_rsp_txn.valid = h2d_rsp_valid;
  assign dev_h2d_data_if.h2d_data_txn.valid = h2d_data_valid;
  assign dev_m2s_req_if.m2s_req_txn = m2s_req_dataout; 
  assign dev_m2s_rwd_if.m2s_rwd_txn = m2s_rwd_dataout;
  assign dev_h2d_req_if.h2d_req_txn = h2d_req_dataout;
  assign dev_h2d_rsp_if.h2d_rsp_txn = h2d_rsp_dataout;
  assign dev_h2d_data_if.h2d_data_txn = h2d_data_dataout;

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(d2h_req_txn_t)
  ) d2h_req_fifo_inst (
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
  	.full(d2h_req_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(d2h_req_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(d2h_rsp_txn_t)
  ) d2h_rsp_fifo_inst (
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
  	.full(d2h_rsp_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(d2h_rsp_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(d2h_data_txn_t)
  ) d2h_data_fifo_inst (
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
  	.full(d2h_data_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(d2h_data_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(s2m_ndr_txn_t)
  ) s2m_ndr_fifo_inst (
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
  	.full(s2m_ndr_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(s2m_ndr_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(s2m_drs_txn_t)
  ) s2m_drs_fifo_inst (
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
  	.full(s2m_drs_full),
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(s2m_drs_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(m2s_req_txn_t)
  ) m2s_req_fifo_inst (
	  .clk(dev_m2s_req_if.clk),
  	.rstn(dev_m2s_req_if.rstn),
  	.rval(dev_m2s_req_if.ready),
  	.wval(m2s_req_txn[0].valid),
  	.dwval(m2s_req_txn[1].valid),
    .datain(m2s_req_txn[0]),
    .ddatain(m2s_req_txn[1]),
    .dataout(m2s_req_dataout),
  	.eseq,
  	.wptr(m2s_req_wptr),
  	.empty(m2s_req_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(m2s_req_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(m2s_rwd_txn_t)
  ) m2s_rwd_fifo_inst (
	  .clk(dev_m2s_rwd_if.clk),
  	.rstn(dev_m2s_rwd_if.rstn),
  	.rval(dev_m2s_rwd_if.ready),
  	.wval(((m2s_rwd_pkt.m2s_rwd_txn.valid) && (!(|m2s_rwd_pkt.pending_data_slot)))),
    .datain(m2s_rwd_pkt.m2s_rwd_txn),
    .dataout(m2s_rwd_dataout),
  	.eseq,
  	.wptr(m2s_rwd_wptr),
  	.empty(m2s_rwd_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(m2s_rwd_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(h2d_req_txn_t)
  ) h2d_req_fifo_inst (
	  .clk(dev_h2d_req_if.clk),
  	.rstn(dev_h2d_req_if.rstn),
  	.rval(dev_h2d_req_if.ready),
  	.wval(h2d_req_txn[0].valid),
  	.dwval(h2d_req_txn[1].valid),
    .datain(h2d_req_txn[0]),
    .ddatain(h2d_req_txn[1]),
    .dataout(h2d_req_dataout),
  	.eseq,
  	.wptr(h2d_req_wptr),
  	.empty(h2d_req_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_req_occ)
  );

  buffer#(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(h2d_rsp_txn_t)
  ) h2d_rsp_fifo_inst (
	  .clk(dev_h2d_rsp_if.clk),
  	.rstn(dev_h2d_rsp_if.rstn),
  	.rval(dev_h2d_rsp_if.ready),
  	.wval(h2d_rsp_txn[0].valid),
  	.dwval(h2d_rsp_txn[1].valid),
  	.twval(h2d_rsp_txn[2].valid),
  	.qwval(h2d_rsp_txn[3].valid),
    .datain(h2d_rsp_txn[0]),
    .ddatain(h2d_rsp_txn[1]),
    .tdatain(h2d_rsp_txn[2]),
    .qdatain(h2d_rsp_txn[3]),
    .dataout(h2d_rsp_dataout),
  	.eseq,
  	.wptr(h2d_rsp_wptr),
  	.empty(h2d_rsp_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_rsp_occ)
  );

  buffer #(
    .DEPTH(BUFFER_DEPTH),
    .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
    .FIFO_DATA_TYPE(h2d_data_txn_t)
  ) h2d_data_fifo_inst (
	  .clk(dev_h2d_data_if.clk),
  	.rstn(dev_h2d_data_if.rstn),
  	.rval(dev_h2d_data_if.ready),
  	.wval(((h2d_data_pkt[0].h2d_data_txn.valid) && (!(|h2d_data_pkt[0].pending_data_slot)))),
  	.qwval(((h2d_data_pkt[3].h2d_data_txn.valid) && (!(|h2d_data_pkt[3].pending_data_slot)))),
  	.datain(h2d_data_pkt[0].h2d_data_txn),
  	.ddatain(h2d_data_pkt[1].h2d_data_txn),
  	.tdatain(h2d_data_pkt[2].h2d_data_txn),
  	.qdatain(h2d_data_pkt[3].h2d_data_txn),
    .dataout(h2d_data_dataout),
  	.eseq,
  	.wptr(h2d_data_wptr),
  	.empty(h2d_data_valid),
  	.full,
  	.undrflw,
  	.ovrflw,
  	.near_full,
  	.occupancy(h2d_data_occ)
  );

  device_tx_path #(
  ) device_tx_path_inst (
    .*
  );

  device_rx_path #(
  ) device_rx_path_inst (
    .*
  );
/*
  replay_buffer #(
  ) replay_buffer_inst (
    .replay_inbuff_if(dev_tx_dl_if),
    .*
  );
*/
endmodule

module tb_top;

  logic clk;
  logic valid_delays_d[10];
  logic [527:0] data_delays_d[10];
  logic valid_delays_dd[10];
  logic [527:0] data_delays_dd[10];

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

  cxl_host_tx_dl_if   host_tx_dl_if(clk);
  cxl_host_rx_dl_if   host_rx_dl_if(clk);
  cxl_dev_tx_dl_if    dev_tx_dl_if(clk);
  cxl_dev_rx_dl_if    dev_rx_dl_if(clk);

//  assign dev_rx_dl_if.valid   = host_tx_dl_if.valid;
//  assign dev_rx_dl_if.data    = host_tx_dl_if.data;
//  assign host_rx_dl_if.valid  = dev_tx_dl_if.valid;
//  assign host_rx_dl_if.data   = dev_tx_dl_if.data;

  always@(posedge clk) begin
    dev_rx_dl_if.valid<= valid_delays_d[0];
    valid_delays_d[0] <= valid_delays_d[1];
    valid_delays_d[1] <= valid_delays_d[2];
    valid_delays_d[2] <= valid_delays_d[3];
    valid_delays_d[3] <= valid_delays_d[4];
    valid_delays_d[4] <= valid_delays_d[5];
    valid_delays_d[5] <= valid_delays_d[6];
    valid_delays_d[6] <= valid_delays_d[7];
    valid_delays_d[7] <= valid_delays_d[8];
    valid_delays_d[8] <= valid_delays_d[9];
    valid_delays_d[9] <= host_tx_dl_if.valid;
    dev_rx_dl_if.data <= data_delays_d[0];
    data_delays_d[0] <= data_delays_d[1];
    data_delays_d[1] <= data_delays_d[2];
    data_delays_d[2] <= data_delays_d[3];
    data_delays_d[3] <= data_delays_d[4];
    data_delays_d[4] <= data_delays_d[5];
    data_delays_d[5] <= data_delays_d[6];
    data_delays_d[6] <= data_delays_d[7];
    data_delays_d[7] <= data_delays_d[8];
    data_delays_d[8] <= data_delays_d[9];
    data_delays_d[9] <= host_tx_dl_if.data;
    host_rx_dl_if.valid <= valid_delays_dd[0];
    valid_delays_dd[0] <= valid_delays_dd[1];
    valid_delays_dd[1] <= valid_delays_dd[2];
    valid_delays_dd[2] <= valid_delays_dd[3];
    valid_delays_dd[3] <= valid_delays_dd[4];
    valid_delays_dd[4] <= valid_delays_dd[5];
    valid_delays_dd[5] <= valid_delays_dd[6];
    valid_delays_dd[6] <= valid_delays_dd[7];
    valid_delays_dd[7] <= valid_delays_dd[8];
    valid_delays_dd[8] <= valid_delays_dd[9];
    valid_delays_dd[9] <= dev_tx_dl_if.valid;
    host_rx_dl_if.data <= data_delays_dd[0];
    data_delays_dd[0] <= data_delays_dd[1];
    data_delays_dd[1] <= data_delays_dd[2];
    data_delays_dd[2] <= data_delays_dd[3];
    data_delays_dd[3] <= data_delays_dd[4];
    data_delays_dd[4] <= data_delays_dd[5];
    data_delays_dd[5] <= data_delays_dd[6];
    data_delays_dd[6] <= data_delays_dd[7];
    data_delays_dd[7] <= data_delays_dd[8];
    data_delays_dd[8] <= data_delays_dd[9];
    data_delays_dd[9] <= dev_tx_dl_if.data;
  end 

  cxl_host #(
  ) cxl_host_inst (
    .*
  );

  cxl_device #(
  ) cxl_device_inst (
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
    uvm_config_db#(virtual cxl_mem_s2m_ndr_if)::set(null, "*", "host_s2m_ndr_if", host_s2m_ndr_if);
    uvm_config_db#(virtual cxl_mem_s2m_drs_if)::set(null, "*", "host_s2m_drs_if", host_s2m_drs_if);

    uvm_config_db#(virtual cxl_cache_d2h_req_if)::set(null, "*", "dev_d2h_req_if", dev_d2h_req_if);
    uvm_config_db#(virtual cxl_cache_d2h_rsp_if)::set(null, "*", "dev_d2h_rsp_if", dev_d2h_rsp_if);
    uvm_config_db#(virtual cxl_cache_d2h_data_if)::set(null, "*", "dev_d2h_data_if", dev_d2h_data_if);
    uvm_config_db#(virtual cxl_cache_h2d_req_if)::set(null, "*", "dev_h2d_req_if", dev_h2d_req_if);
    uvm_config_db#(virtual cxl_cache_h2d_rsp_if)::set(null, "*", "dev_h2d_rsp_if", dev_h2d_rsp_if);
    uvm_config_db#(virtual cxl_cache_h2d_data_if)::set(null, "*", "dev_h2d_data_if", dev_h2d_data_if);
    uvm_config_db#(virtual cxl_mem_m2s_req_if)::set(null, "*", "dev_m2s_req_if", dev_m2s_req_if);
    uvm_config_db#(virtual cxl_mem_m2s_rwd_if)::set(null, "*", "dev_m2s_rwd_if", dev_m2s_rwd_if);
    uvm_config_db#(virtual cxl_mem_s2m_ndr_if)::set(null, "*", "dev_s2m_ndr_if", dev_s2m_ndr_if);
    uvm_config_db#(virtual cxl_mem_s2m_drs_if)::set(null, "*", "dev_s2m_drs_if", dev_s2m_drs_if);
    run_test("cxl_base_test");
  end

  class cxl_cfg_obj extends uvm_object;
    `uvm_object_utils(cxl_cfg_obj)
    rand cxl_hdm_t hdm;
    rand cxl_type_t cxl_type;

    constraint hdm_c {
      (cxl_type == GEET_CXL_TYPE_1) -> (hdm == GEET_CXL_HDM_H);
      (cxl_type == GEET_CXL_TYPE_3) -> (hdm == GEET_CXL_HDM_H);
    }

    function new(string name = "cxl_cfg_obj");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm config obj : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class cxl_base_txn_seq_item extends uvm_sequence_item;
    rand int delay_value;
    rand logic delay_set;
    rand delay_type_t delay_type;
    rand int reset_cycles;

    `uvm_object_utils_begin(cxl_base_txn_seq_item)
      `uvm_field_int(delay_value, UVM_NOCOMPARE)
      `uvm_field_int(delay_set, UVM_NOCOMPARE)
      `uvm_field_enum(delay_type_t,delay_type, UVM_NOCOMPARE)
      `uvm_field_int(reset_cycles, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint delay_c{
      soft delay_set inside {'h0};
      if(delay_set){
        (delay_type == GEET_CXL_SHORT_DLY) -> delay_value inside {[1:10]};
        (delay_type == GEET_CXL_MED_DLY)   -> delay_value inside {[10:100]};
        (delay_type == GEET_CXL_LONG_DLY)  -> delay_value inside {[100:1000]};
      } else {
        delay_value inside {'h0};
      }
      solve delay_set before delay_type;
      solve delay_type before delay_value;
    }

    constraint reset_cycles_c {
      reset_cycles == 10;
    }

    function new(string name = "cxl_base_txn_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass 
  
  //can justify not using struct for fields as a txn because in future if you want 
  //different uvm_field types you cannot assign it using struct alone 
  class d2h_req_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand d2h_req_opcode_t opcode;
    rand logic [51:0] address;
    rand logic [11:0] cqid;
    rand logic nt;
    int d2h_req_crdt;

    `uvm_object_utils_begin(d2h_req_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(d2h_req_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_int(cqid, UVM_DEFAULT)
      `uvm_field_int(nt, UVM_DEFAULT)
      `uvm_field_int(d2h_req_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint always_valid_c{
      soft valid == 1;
    }

    constraint byte_align_64B_c{
      address[5:0] == 'h0;
    }    

    function new(string name = "d2h_req_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class d2h_rsp_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand d2h_rsp_opcode_t opcode;
    rand logic [11:0] uqid;
    int d2h_rsp_crdt;

    `uvm_object_utils_begin(d2h_rsp_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(d2h_rsp_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_int(uqid, UVM_DEFAULT)
      `uvm_field_int(d2h_rsp_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint always_valid_c{
      soft valid == 1;
    }

    function new(string name = "d2h_rsp_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class d2h_data_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand logic [11:0] uqid;
    rand logic chunkvalid;
    rand logic bogus;
    rand logic poison;
    rand logic [511:0] data;

    `uvm_object_utils_begin(d2h_data_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(uqid, UVM_DEFAULT)
      `uvm_field_int(chunkvalid, UVM_DEFAULT)
      `uvm_field_int(bogus, UVM_DEFAULT)
      `uvm_field_int(poison, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
    `uvm_object_utils_end

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
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class h2d_req_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand h2d_req_opcode_t opcode;
    rand logic [51:0] address;
    rand logic [11:0] uqid;
    int h2d_req_crdt;

    `uvm_object_utils_begin(h2d_req_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(h2d_req_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_int(uqid, UVM_DEFAULT)
      `uvm_field_int(h2d_req_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint always_valid_c{
      soft valid == 1;
    }

    constraint byte_align_64B_c{
      address[5:0] == 'h0;
    }    

    function new(string name = "h2d_req_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class h2d_rsp_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand h2d_rsp_opcode_t opcode;
    rand h2d_rsp_data_opcode_t rspdata;
    rand logic [1:0] rsppre;
    rand logic [11:0] cqid;
    int h2d_rsp_crdt;

    `uvm_object_utils_begin(h2d_rsp_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(h2d_rsp_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_enum(h2d_rsp_data_opcode_t, rspdata, UVM_DEFAULT)
      `uvm_field_int(rsppre, UVM_DEFAULT)
      `uvm_field_int(cqid, UVM_DEFAULT)
      `uvm_field_int(h2d_rsp_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    constraint always_valid_c{
      soft valid == 1;
    }

    constraint go_rspdata_c{
      (opcode == GEET_CXL_CACHE_OPCODE_GO) -> (rspdata inside {GEET_CXL_CACHE_MESI_I, GEET_CXL_CACHE_MESI_S, GEET_CXL_CACHE_MESI_E, GEET_CXL_CACHE_MESI_M, GEET_CXL_CACHE_MESI_ERR});
      solve opcode before rspdata;
    }

    constraint ignore_do_later_c{
      soft rspdata == 'h0;
      soft rsppre == 'h0;
    }

    function new(string name = "h2d_rsp_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class h2d_data_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand logic [11:0] cqid;
    rand logic chunkvalid;
    rand logic poison;
    rand logic goerr;
    rand logic [511:0] data;
    int h2d_data_crdt;

    `uvm_object_utils_begin(h2d_data_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(cqid, UVM_DEFAULT)
      `uvm_field_int(chunkvalid, UVM_DEFAULT)
      `uvm_field_int(poison, UVM_DEFAULT)
      `uvm_field_int(goerr, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
      `uvm_field_int(h2d_data_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint always_valid_c{
      soft valid == 'h1;
    }

    constraint skip_err_c{
      soft poison == 'h0;
      soft goerr == 'h0;
    }

    constraint skip_32B_chunks_c{
      soft chunkvalid == 'h0;
    };

    function new(string name = "h2d_data_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction
  
  endclass

  class m2s_req_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand logic [51:0] address;
    rand m2s_req_opcode_t memopcode;
    rand metafield_t metafield;
    rand metavalue_t metavalue;
    rand snptype_t snptype;
    rand logic [15:0] tag;
    rand logic [1:0] tc;
    int m2s_req_crdt;

    `uvm_object_utils_begin(m2s_req_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_enum(m2s_req_opcode_t, memopcode, UVM_DEFAULT)
      `uvm_field_enum(metafield_t, metafield, UVM_DEFAULT)
      `uvm_field_enum(metavalue_t, metavalue, UVM_DEFAULT)
      `uvm_field_enum(snptype_t, snptype, UVM_DEFAULT)
      `uvm_field_int(tag, UVM_DEFAULT)
      `uvm_field_int(tc, UVM_DEFAULT)
      `uvm_field_int(m2s_req_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint always_valid_c{
      soft valid == 'h1;
    }

    constraint byte_align_64B_c{
      address[5:0] == 'h0;
    }

    constraint metafield_rsvd_illegal_c{
      !metafield inside {GEET_CXL_MEM_MF_METAFIELD_RSVD1,GEET_CXL_MEM_MF_METAFIELD_RSVD2};
    }

    constraint metavalue_rsvd_illegal_c{
      !metavalue inside {GEET_CXL_MEM_MV_METAVALUE_RSVD};
    }

    constraint tc_0_c{
      soft tc == 'h0;
    }    

    function new(string name = "m2s_req_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class m2s_rwd_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand logic [51:0] address;
    rand m2s_rwd_opcode_t memopcode;
    rand metafield_t metafield;
    rand metavalue_t metavalue;
    rand snptype_t snptype;
    rand logic [15:0] tag;
    rand logic [1:0] tc;
    rand logic poison;
    rand logic [511:0] data;
    int m2s_rwd_crdt;

    `uvm_object_utils_begin(m2s_rwd_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_enum(m2s_rwd_opcode_t, memopcode, UVM_DEFAULT)
      `uvm_field_enum(metafield_t, metafield, UVM_DEFAULT)
      `uvm_field_enum(metavalue_t, metavalue, UVM_DEFAULT)
      `uvm_field_enum(snptype_t, snptype, UVM_DEFAULT)
      `uvm_field_int(tag, UVM_DEFAULT)
      `uvm_field_int(tc, UVM_DEFAULT)
      `uvm_field_int(poison, UVM_DEFAULT)
      `uvm_field_int(data, UVM_DEFAULT)
      `uvm_field_int(m2s_rwd_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint always_valid_c{
      soft valid == 'h1;
    }

    constraint byte_align_64B_c{
      address[5:0] == 'h0;
    }

    constraint metafield_rsvd_illegal_c{
      !metafield inside {GEET_CXL_MEM_MF_METAFIELD_RSVD1,GEET_CXL_MEM_MF_METAFIELD_RSVD2};
    }

    constraint metavalue_rsvd_illegal_c{
      !metavalue inside {GEET_CXL_MEM_MV_METAVALUE_RSVD};
    }

    constraint tc_0_c{
      soft tc == 'h0;
    }    

    constraint skp_err_c{
      soft poison == 'h0;
    }

    function new(string name = "m2s_req_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class s2m_ndr_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand s2m_ndr_opcode_t opcode;
    rand metafield_t metafield;
    rand metavalue_t metavalue;
    rand logic [15:0] tag;
    int s2m_ndr_crdt;

    `uvm_object_utils_begin(s2m_ndr_seq_item)
      `uvm_field_int(valid, UVM_DEFAULT)
      `uvm_field_enum(s2m_ndr_opcode_t, opcode, UVM_DEFAULT)
      `uvm_field_enum(metafield_t, metafield, UVM_DEFAULT)
      `uvm_field_enum(metavalue_t, metavalue, UVM_DEFAULT)
      `uvm_field_int(tag, UVM_DEFAULT)
      `uvm_field_int(s2m_ndr_crdt, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint always_valid_c{
      soft valid == 'h1;
    }

    constraint illegal_ndr_opcode_c{
      opcode == 'h3;
    }

    constraint metafield_rsvd_illegal_c{
      !metafield inside {GEET_CXL_MEM_MF_METAFIELD_RSVD1,GEET_CXL_MEM_MF_METAFIELD_RSVD2};
    }

    constraint metavalue_rsvd_illegal_c{
      !metavalue inside {GEET_CXL_MEM_MV_METAVALUE_RSVD};
    }

    constraint solve_ordrer_c{
      solve opcode before metafield;
      solve opcode before metavalue;
      solve metafield before metavalue;
    }

    function new(string name = "s2m_ndr_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class s2m_drs_seq_item extends cxl_base_txn_seq_item;
    rand logic valid;
    rand s2m_drs_opcode_t opcode;
    rand metafield_t metafield;
    rand metavalue_t metavalue;
    rand logic [15:0] tag;
    rand logic poison;
    rand logic [511:0] data;
    int s2m_drs_crdt;

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

    constraint always_valid_c{
      soft valid == 'h1;
    }

    constraint legal_drs_opcode_c{
      opcode == 'h0;
    }

    constraint metafield_rsvd_illegal_c{
      !metafield inside {GEET_CXL_MEM_MF_METAFIELD_RSVD1,GEET_CXL_MEM_MF_METAFIELD_RSVD2};
    }

    constraint metavalue_rsvd_illegal_c{
      !metavalue inside {GEET_CXL_MEM_MV_METAVALUE_RSVD};
    }

    constraint skip_err_c{
      soft poison == 'h0;
    }

    function new(string name = "s2m_drs_seq_item");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructed uvm seq item : %s", name), UVM_DEBUG)
    endfunction

  endclass


  class host_d2h_req_sequencer extends uvm_sequencer#(d2h_req_seq_item);
    `uvm_component_utils(host_d2h_req_sequencer);
    uvm_tlm_analysis_fifo#(d2h_req_seq_item) host_d2h_req_fifo;

    function new(string name = "host_d2h_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_d2h_req_fifo = new("host_d2h_req_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class host_d2h_rsp_sequencer extends uvm_sequencer#(d2h_rsp_seq_item);
    `uvm_component_utils(host_d2h_rsp_sequencer);
    uvm_tlm_analysis_fifo#(d2h_rsp_seq_item) host_d2h_rsp_fifo;

    function new(string name = "host_d2h_rsp_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_d2h_rsp_fifo = new("host_d2h_rsp_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class host_d2h_data_sequencer extends uvm_sequencer#(d2h_data_seq_item);
    `uvm_component_utils(host_d2h_data_sequencer);
    uvm_tlm_analysis_fifo#(d2h_data_seq_item) host_d2h_data_fifo;

    function new(string name = "host_d2h_data_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_d2h_data_fifo = new("host_d2h_data_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class dev_h2d_req_sequencer extends uvm_sequencer#(h2d_req_seq_item);
    `uvm_component_utils(dev_h2d_req_sequencer);
    uvm_tlm_analysis_fifo#(h2d_req_seq_item) dev_h2d_req_fifo;

    function new(string name = "dev_h2d_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_h2d_req_fifo = new("dev_h2d_req_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class dev_h2d_rsp_sequencer extends uvm_sequencer#(h2d_rsp_seq_item);
    `uvm_component_utils(dev_h2d_rsp_sequencer);
    uvm_tlm_analysis_fifo#(h2d_rsp_seq_item) dev_h2d_rsp_fifo;

    function new(string name = "dev_h2d_rsp_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_h2d_rsp_fifo = new("dev_h2d_rsp_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class dev_h2d_data_sequencer extends uvm_sequencer#(h2d_data_seq_item);
    `uvm_component_utils(dev_h2d_data_sequencer);
    uvm_tlm_analysis_fifo#(h2d_data_seq_item) dev_h2d_data_fifo;

    function new(string name = "dev_h2d_data_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_h2d_data_fifo = new("dev_h2d_data_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class dev_m2s_req_sequencer extends uvm_sequencer#(m2s_req_seq_item);
    `uvm_component_utils(dev_m2s_req_sequencer);
    uvm_tlm_analysis_fifo#(m2s_req_seq_item) dev_m2s_req_fifo;

    function new(string name = "dev_m2s_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_m2s_req_fifo = new("dev_m2s_req_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class dev_m2s_rwd_sequencer extends uvm_sequencer#(m2s_rwd_seq_item);
    `uvm_component_utils(dev_m2s_rwd_sequencer);
    uvm_tlm_analysis_fifo#(m2s_rwd_seq_item) dev_m2s_rwd_fifo;

    function new(string name = "dev_m2s_rwd_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_m2s_rwd_fifo = new("dev_m2s_rwd_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class host_s2m_ndr_sequencer extends uvm_sequencer#(s2m_ndr_seq_item);
    `uvm_component_utils(host_s2m_ndr_sequencer);
    uvm_tlm_analysis_fifo#(s2m_ndr_seq_item) host_s2m_ndr_fifo;

    function new(string name = "host_s2m_ndr_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_s2m_ndr_fifo = new("host_s2m_ndr_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class host_s2m_drs_sequencer extends uvm_sequencer#(s2m_drs_seq_item);
    `uvm_component_utils(host_s2m_drs_sequencer);
    uvm_tlm_analysis_fifo#(s2m_drs_seq_item) host_s2m_drs_fifo;

    function new(string name = "host_s2m_drs_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_s2m_drs_fifo = new("host_s2m_drs_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

  endclass

  class dev_d2h_req_sequencer extends uvm_sequencer#(d2h_req_seq_item);
    `uvm_component_utils(dev_d2h_req_sequencer)
    
    int d2h_req_crdt;
    d2h_req_seq_item d2h_req_seq_item_h;
    d2h_req_seq_item d2h_req_seq_item_exp_h;
    d2h_req_seq_item d2h_req_seq_item_act_h;
    d2h_req_seq_item drv_mon_txn[$];
    //d2h_req_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(d2h_req_seq_item) dev_d2h_req_fifo;

    function new(string name = "dev_d2h_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_d2h_req_fifo    = new("dev_d2h_req_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
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
            dev_d2h_req_fifo.get_ap(d2h_req_seq_item_act_h);
            d2h_req_seq_item_exp_h = drv_mon_txn.pop_front();
            if(d2h_req_seq_item_act_h.compare(d2h_req_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none*/
    endtask 

  endclass

  class dev_d2h_rsp_sequencer extends uvm_sequencer#(d2h_rsp_seq_item);
    `uvm_component_utils(dev_d2h_rsp_sequencer)
    
    int d2h_rsp_crdt;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;
    d2h_rsp_seq_item d2h_rsp_seq_item_exp_h;
    d2h_rsp_seq_item d2h_rsp_seq_item_act_h;
    d2h_rsp_seq_item drv_mon_txn[$];
    d2h_rsp_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(d2h_rsp_seq_item) dev_d2h_rsp_fifo;

    function new(string name = "dev_d2h_rsp_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_d2h_rsp_fifo    = new("dev_d2h_rsp_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            d2h_rsp_seq_item_h = last_req();
            inflight_txn.push_back(d2h_rsp_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!dev_d2h_rsp_fifo.is_empty);
            dev_d2h_rsp_fifo.get_ap(d2h_rsp_seq_item_act_h);
            d2h_rsp_seq_item_exp_h = drv_mon_txn.pop_front();
            if(d2h_rsp_seq_item_act_h.compare(d2h_rsp_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none*/
    endtask 

  endclass

  class dev_d2h_data_sequencer extends uvm_sequencer#(d2h_data_seq_item);
    `uvm_component_utils(dev_d2h_data_sequencer)
    
    int d2h_data_crdt;
    d2h_data_seq_item d2h_data_seq_item_h;
    d2h_data_seq_item d2h_data_seq_item_exp_h;
    d2h_data_seq_item d2h_data_seq_item_act_h;
    d2h_data_seq_item drv_mon_txn[$];
    d2h_data_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(d2h_data_seq_item) dev_d2h_data_fifo;

    function new(string name = "dev_d2h_data_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_d2h_data_fifo    = new("dev_d2h_data_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            d2h_data_seq_item_h = last_req();
            inflight_txn.push_back(d2h_data_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!dev_d2h_data_fifo.is_empty);
            dev_d2h_data_fifo.get_ap(d2h_data_seq_item_act_h);
            d2h_data_seq_item_exp_h = drv_mon_txn.pop_front();
            if(d2h_data_seq_item_act_h.compare(d2h_data_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none*/
    endtask 

  endclass

  class host_h2d_req_sequencer extends uvm_sequencer#(h2d_req_seq_item);
    `uvm_component_utils(host_h2d_req_sequencer)
    
    int h2d_req_crdt;
    h2d_req_seq_item h2d_req_seq_item_h;
    h2d_req_seq_item h2d_req_seq_item_exp_h;
    h2d_req_seq_item h2d_req_seq_item_act_h;
    h2d_req_seq_item drv_mon_txn[$];
    h2d_req_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(h2d_req_seq_item) host_h2d_req_fifo;

    function new(string name = "host_h2d_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_h2d_req_fifo    = new("host_h2d_req_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            h2d_req_seq_item_h = last_req();
            inflight_txn.push_back(h2d_req_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!host_h2d_req_fifo.is_empty);
            host_h2d_req_fifo.get_ap(h2d_req_seq_item_act_h);
            h2d_req_seq_item_exp_h = drv_mon_txn.pop_front();
            if(h2d_req_seq_item_act_h.compare(h2d_req_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none*/
    endtask 

  endclass

  class host_h2d_rsp_sequencer extends uvm_sequencer#(h2d_rsp_seq_item);
    `uvm_component_utils(host_h2d_rsp_sequencer)
    
    int h2d_rsp_crdt;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;
    h2d_rsp_seq_item h2d_rsp_seq_item_exp_h;
    h2d_rsp_seq_item h2d_rsp_seq_item_act_h;
    h2d_rsp_seq_item drv_mon_txn[$];
    h2d_rsp_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(h2d_rsp_seq_item) host_h2d_rsp_fifo;

    function new(string name = "host_h2d_rsp_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_h2d_rsp_fifo    = new("host_h2d_rsp_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            h2d_rsp_seq_item_h = last_req();
            inflight_txn.push_back(h2d_rsp_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!host_h2d_rsp_fifo.is_empty);
            host_h2d_rsp_fifo.get_ap(h2d_rsp_seq_item_act_h);
            h2d_rsp_seq_item_exp_h = drv_mon_txn.pop_front();
            if(h2d_rsp_seq_item_act_h.compare(h2d_rsp_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end  
        end
      join_none*/
    endtask 

  endclass

  class host_h2d_data_sequencer extends uvm_sequencer#(h2d_data_seq_item);
    `uvm_component_utils(host_h2d_data_sequencer)
    
    int h2d_data_crdt;
    h2d_data_seq_item h2d_data_seq_item_h;
    h2d_data_seq_item h2d_data_seq_item_exp_h;
    h2d_data_seq_item h2d_data_seq_item_act_h;
    h2d_data_seq_item drv_mon_txn[$];
    h2d_data_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(h2d_data_seq_item) host_h2d_data_fifo;

    function new(string name = "host_h2d_data_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_h2d_data_fifo    = new("host_h2d_data_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            h2d_data_seq_item_h = last_req();
            inflight_txn.push_back(h2d_data_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!host_h2d_data_fifo.is_empty);
            host_h2d_data_fifo.get_ap(h2d_data_seq_item_act_h);
            h2d_data_seq_item_exp_h = drv_mon_txn.pop_front();
            if(h2d_data_seq_item_act_h.compare(h2d_data_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none*/
    endtask 

  endclass

  class host_m2s_req_sequencer extends uvm_sequencer#(m2s_req_seq_item);
    `uvm_component_utils(host_m2s_req_sequencer)
    
    int m2s_req_crdt;
    m2s_req_seq_item m2s_req_seq_item_h;
    m2s_req_seq_item m2s_req_seq_item_exp_h;
    m2s_req_seq_item m2s_req_seq_item_act_h;
    m2s_req_seq_item drv_mon_txn[$];
    m2s_req_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(m2s_req_seq_item) host_m2s_req_fifo;

    function new(string name = "host_m2s_req_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_m2s_req_fifo    = new("host_m2s_req_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            m2s_req_seq_item_h = last_req();
            inflight_txn.push_back(m2s_req_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!host_m2s_req_fifo.is_empty);
            host_m2s_req_fifo.get_ap(m2s_req_seq_item_act_h);
            m2s_req_seq_item_exp_h = drv_mon_txn.pop_front();
            if(m2s_req_seq_item_act_h.compare(m2s_req_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          
          end
        end
      join_none*/
    endtask 

  endclass

  class host_m2s_rwd_sequencer extends uvm_sequencer#(m2s_rwd_seq_item);
    `uvm_component_utils(host_m2s_rwd_sequencer)
    
    int m2s_rwd_crdt;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;
    m2s_rwd_seq_item m2s_rwd_seq_item_exp_h;
    m2s_rwd_seq_item m2s_rwd_seq_item_act_h;
    m2s_rwd_seq_item drv_mon_txn[$];
    m2s_rwd_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(m2s_rwd_seq_item) host_m2s_rwd_fifo;

    function new(string name = "host_m2s_rwd_sequencer", uvm_component parent = null );
      super.new(name, parent);
      host_m2s_rwd_fifo    = new("host_m2s_rwd_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            m2s_rwd_seq_item_h = last_req();
            inflight_txn.push_back(m2s_rwd_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!host_m2s_rwd_fifo.is_empty);
            host_m2s_rwd_fifo.get_ap(m2s_rwd_seq_item_act_h);
            m2s_rwd_seq_item_exp_h = drv_mon_txn.pop_front();
            if(m2s_rwd_seq_item_act_h.compare(m2s_rwd_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none*/
    endtask 

  endclass

  class dev_s2m_ndr_sequencer extends uvm_sequencer#(s2m_ndr_seq_item);
    `uvm_component_utils(dev_s2m_ndr_sequencer)
    
    int s2m_ndr_crdt;
    s2m_ndr_seq_item s2m_ndr_seq_item_h;
    s2m_ndr_seq_item s2m_ndr_seq_item_exp_h;
    s2m_ndr_seq_item s2m_ndr_seq_item_act_h;
    s2m_ndr_seq_item drv_mon_txn[$];
    s2m_ndr_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(s2m_ndr_seq_item) dev_s2m_ndr_fifo;

    function new(string name = "dev_s2m_ndr_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_s2m_ndr_fifo    = new("dev_s2m_ndr_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            s2m_ndr_seq_item_h = last_req();
            inflight_txn.push_back(s2m_ndr_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!dev_s2m_ndr_fifo.is_empty);
            dev_s2m_ndr_fifo.get_ap(s2m_ndr_seq_item_act_h);
            s2m_ndr_seq_item_exp_h = drv_mon_txn.pop_front();
            if(s2m_ndr_seq_item_act_h.compare(s2m_ndr_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end
        end
      join_none*/
    endtask 

  endclass

  class dev_s2m_drs_sequencer extends uvm_sequencer#(s2m_drs_seq_item);
    `uvm_component_utils(dev_s2m_drs_sequencer)
    
    int s2m_drs_crdt;
    s2m_drs_seq_item s2m_drs_seq_item_h;
    s2m_drs_seq_item s2m_drs_seq_item_exp_h;
    s2m_drs_seq_item s2m_drs_seq_item_act_h;
    s2m_drs_seq_item drv_mon_txn[$];
    s2m_drs_seq_item inflight_txn[$];
    uvm_tlm_analysis_fifo#(s2m_drs_seq_item) dev_s2m_drs_fifo;

    function new(string name = "dev_s2m_drs_sequencer", uvm_component parent = null );
      super.new(name, parent);
      dev_s2m_drs_fifo    = new("dev_s2m_drs_fifo",   this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      /*fork 
        begin
          forever begin
            wait_for_item_done();
            s2m_drs_seq_item_h = last_req();
            inflight_txn.push_back(s2m_drs_seq_item_h);
          end
        end
        begin
          forever begin
            wait(!dev_s2m_drs_fifo.is_empty);
            dev_s2m_drs_fifo.get_ap(s2m_drs_seq_item_act_h);
            s2m_drs_seq_item_exp_h = drv_mon_txn.pop_front();
            if(s2m_drs_seq_item_act_h.compare(s2m_drs_seq_item_exp_h)) begin
              `uvm_fatal(get_type_name(), $sformatf("exp driven txn and actual monitored txn mismatch") );
            end
          end   
        end
        join_none*/
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_req_if.mon)::get(this, "", "dev_d2h_req_if", dev_d2h_req_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", d2h_req_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_rsp_if.mon)::get(this, "", "dev_d2h_rsp_if", dev_d2h_rsp_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", d2h_rsp_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_data_if.mon)::get(this, "", "dev_d2h_data_if", dev_d2h_data_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", d2h_data_seq_item_h.sprint()), UVM_HIGH)
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
    h2d_req_seq_item h2d_req_seq_item_h;

    function new(string name = "host_h2d_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_req_port = new("h2d_req_port", this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_req_if.mon)::get(this, "", "host_h2d_req_if", host_h2d_req_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", h2d_req_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_rsp_if.mon)::get(this, "", "host_h2d_rsp_if", host_h2d_rsp_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", h2d_rsp_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_data_if.mon)::get(this, "", "host_h2d_data_if", host_h2d_data_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", h2d_data_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_m2s_req_if.mon)::get(this, "", "host_m2s_req_if", host_m2s_req_if))) begin
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
              m2s_req_seq_item_h.memopcode     = host_m2s_req_if.m2s_req_txn.memopcode;
              m2s_req_seq_item_h.metafield     = host_m2s_req_if.m2s_req_txn.metafield;
              m2s_req_seq_item_h.metavalue     = host_m2s_req_if.m2s_req_txn.metavalue;
              m2s_req_seq_item_h.snptype       = host_m2s_req_if.m2s_req_txn.snptype;
              m2s_req_seq_item_h.tag           = host_m2s_req_if.m2s_req_txn.tag;
              m2s_req_seq_item_h.tc            = host_m2s_req_if.m2s_req_txn.tc;
              m2s_req_port.write(m2s_req_seq_item_h);
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", m2s_req_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_m2s_rwd_if.mon)::get(this, "", "host_m2s_rwd_if", host_m2s_rwd_if))) begin
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
              m2s_rwd_seq_item_h.memopcode     = host_m2s_rwd_if.m2s_rwd_txn.memopcode;
              m2s_rwd_seq_item_h.metafield     = host_m2s_rwd_if.m2s_rwd_txn.metafield;
              m2s_rwd_seq_item_h.metavalue     = host_m2s_rwd_if.m2s_rwd_txn.metavalue;
              m2s_rwd_seq_item_h.snptype       = host_m2s_rwd_if.m2s_rwd_txn.snptype;
              m2s_rwd_seq_item_h.tag           = host_m2s_rwd_if.m2s_rwd_txn.tag;
              m2s_rwd_seq_item_h.tc            = host_m2s_rwd_if.m2s_rwd_txn.tc;
              m2s_rwd_seq_item_h.poison        = host_m2s_rwd_if.m2s_rwd_txn.poison;
              m2s_rwd_seq_item_h.data          = host_m2s_rwd_if.m2s_rwd_txn.data;
              m2s_rwd_port.write(m2s_rwd_seq_item_h);
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", m2s_rwd_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_s2m_ndr_if.mon)::get(this, "", "dev_s2m_ndr_if", dev_s2m_ndr_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", s2m_ndr_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_s2m_drs_if.mon)::get(this, "", "dev_s2m_drs_if", dev_s2m_drs_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", s2m_drs_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_req_if.mon)::get(this, "", "host_d2h_req_if", host_d2h_req_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", d2h_req_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_rsp_if.mon)::get(this, "", "host_d2h_rsp_if", host_d2h_rsp_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", d2h_rsp_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_data_if.mon)::get(this, "", "host_d2h_data_if", host_d2h_data_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", d2h_data_seq_item_h.sprint()), UVM_HIGH)
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
    h2d_req_seq_item h2d_req_seq_item_h;

    function new(string name = "dev_h2d_req_monitor", uvm_component parent = null);
      super.new(name, parent);
      h2d_req_port = new("h2d_req_port", this);
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_req_if.mon)::get(this, "", "dev_h2d_req_if", dev_h2d_req_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", h2d_req_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_rsp_if.mon)::get(this, "", "dev_h2d_rsp_if", dev_h2d_rsp_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", h2d_rsp_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_data_if.mon)::get(this, "", "dev_h2d_data_if", dev_h2d_data_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", h2d_data_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_m2s_req_if.mon)::get(this, "", "dev_m2s_req_if", dev_m2s_req_if))) begin
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
              m2s_req_seq_item_h.memopcode     = dev_m2s_req_if.m2s_req_txn.memopcode;
              m2s_req_seq_item_h.metafield     = dev_m2s_req_if.m2s_req_txn.metafield;
              m2s_req_seq_item_h.metavalue     = dev_m2s_req_if.m2s_req_txn.metavalue;
              m2s_req_seq_item_h.snptype       = dev_m2s_req_if.m2s_req_txn.snptype;
              m2s_req_seq_item_h.tag           = dev_m2s_req_if.m2s_req_txn.tag;
              m2s_req_seq_item_h.tc            = dev_m2s_req_if.m2s_req_txn.tc;
              m2s_req_port.write(m2s_req_seq_item_h);
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", m2s_req_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_m2s_rwd_if.mon)::get(this, "", "dev_m2s_rwd_if", dev_m2s_rwd_if))) begin
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
              m2s_rwd_seq_item_h.memopcode     = dev_m2s_rwd_if.m2s_rwd_txn.memopcode;
              m2s_rwd_seq_item_h.metafield     = dev_m2s_rwd_if.m2s_rwd_txn.metafield;
              m2s_rwd_seq_item_h.metavalue     = dev_m2s_rwd_if.m2s_rwd_txn.metavalue;
              m2s_rwd_seq_item_h.snptype       = dev_m2s_rwd_if.m2s_rwd_txn.snptype;
              m2s_rwd_seq_item_h.tag           = dev_m2s_rwd_if.m2s_rwd_txn.tag;
              m2s_rwd_seq_item_h.tc            = dev_m2s_rwd_if.m2s_rwd_txn.tc;
              m2s_rwd_seq_item_h.poison        = dev_m2s_rwd_if.m2s_rwd_txn.poison;
              m2s_rwd_seq_item_h.data          = dev_m2s_rwd_if.m2s_rwd_txn.data;
              m2s_rwd_port.write(m2s_rwd_seq_item_h);
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", m2s_rwd_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_s2m_ndr_if.mon)::get(this, "", "host_s2m_ndr_if", host_s2m_ndr_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", s2m_ndr_seq_item_h.sprint()), UVM_HIGH)
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
      `uvm_info(get_type_name(), $sformatf("constructed uvm monitor : %s", name), UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm monitor : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_s2m_drs_if.mon)::get(this, "", "host_s2m_drs_if", host_s2m_drs_if))) begin
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
              `uvm_info(get_type_name(), $sformatf("wrote item in uvm monitor : %s", s2m_drs_seq_item_h.sprint()), UVM_HIGH)
            end  
          end
        end
      join_none
    endtask

  endclass

  class host_d2h_req_driver extends uvm_driver#(d2h_req_seq_item);
    `uvm_component_utils(host_d2h_req_driver)
    
    virtual cxl_cache_d2h_req_if.host_pasv_drvr_mp host_d2h_req_if;
    d2h_req_seq_item d2h_req_seq_item_h;

    function new(string name = "host_d2h_req_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_req_if.host_pasv_drvr_mp)::get(this, "", "host_d2h_req_if", host_d2h_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_req_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_d2h_req_if.rstn <= 'h0;
        repeat(d2h_req_seq_item_h.reset_cycles) @(negedge host_d2h_req_if.clk) host_d2h_req_if.rstn <= 'h0;
        host_d2h_req_if.rstn <= 'h1;
        seq_item_port.item_done(d2h_req_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_req_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class host_d2h_rsp_driver extends uvm_driver#(d2h_rsp_seq_item);
    `uvm_component_utils(host_d2h_rsp_driver)
    
    virtual cxl_cache_d2h_rsp_if.host_pasv_drvr_mp host_d2h_rsp_if;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;

    function new(string name = "host_d2h_rsp_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_rsp_if.host_pasv_drvr_mp)::get(this, "", "host_d2h_rsp_if", host_d2h_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_rsp_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_rsp_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_rsp_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_d2h_rsp_if.rstn <= 'h0;
        repeat(d2h_rsp_seq_item_h.reset_cycles) @(negedge host_d2h_rsp_if.clk) host_d2h_rsp_if.rstn <= 'h0;
        host_d2h_rsp_if.rstn <= 'h1;
        seq_item_port.item_done(d2h_rsp_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_rsp_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_rsp_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class host_d2h_data_driver extends uvm_driver#(d2h_data_seq_item);
    `uvm_component_utils(host_d2h_data_driver)
    
    virtual cxl_cache_d2h_data_if.host_pasv_drvr_mp host_d2h_data_if;
    d2h_data_seq_item d2h_data_seq_item_h;

    function new(string name = "host_d2h_data_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_data_if.host_pasv_drvr_mp)::get(this, "", "host_d2h_data_if", host_d2h_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_d2h_data_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_data_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_data_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_d2h_data_if.rstn <= 'h0;
        repeat(d2h_data_seq_item_h.reset_cycles) @(negedge host_d2h_data_if.clk) host_d2h_data_if.rstn <= 'h0;
        host_d2h_data_if.rstn <= 'h1;
        seq_item_port.item_done(d2h_data_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_data_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_data_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class host_s2m_ndr_driver extends uvm_driver#(s2m_ndr_seq_item);
    `uvm_component_utils(host_s2m_ndr_driver)
    
    virtual cxl_mem_s2m_ndr_if.host_pasv_drvr_mp host_s2m_ndr_if;
    s2m_ndr_seq_item s2m_ndr_seq_item_h;

    function new(string name = "host_s2m_ndr_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_s2m_ndr_if.host_pasv_drvr_mp)::get(this, "", "host_s2m_ndr_if", host_s2m_ndr_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_s2m_ndr_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(s2m_ndr_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_ndr_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_s2m_ndr_if.rstn <= 'h0;
        repeat(s2m_ndr_seq_item_h.reset_cycles) @(negedge host_s2m_ndr_if.clk) host_s2m_ndr_if.rstn <= 'h0;
        host_s2m_ndr_if.rstn <= 'h1;
        seq_item_port.item_done(s2m_ndr_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(s2m_ndr_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_ndr_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class host_s2m_drs_driver extends uvm_driver#(s2m_drs_seq_item);
    `uvm_component_utils(host_s2m_drs_driver)
    
    virtual cxl_mem_s2m_drs_if.host_pasv_drvr_mp host_s2m_drs_if;
    s2m_drs_seq_item s2m_drs_seq_item_h;

    function new(string name = "host_s2m_drs_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_s2m_drs_if.host_pasv_drvr_mp)::get(this, "", "host_s2m_drs_if", host_s2m_drs_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_s2m_drs_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(s2m_drs_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_drs_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_s2m_drs_if.rstn <= 'h0;
        repeat(s2m_drs_seq_item_h.reset_cycles) @(negedge host_s2m_drs_if.clk) host_s2m_drs_if.rstn <= 'h0;
        host_s2m_drs_if.rstn <= 'h1;
        seq_item_port.item_done(s2m_drs_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(s2m_drs_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_drs_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_h2d_req_driver extends uvm_driver#(h2d_req_seq_item);
    `uvm_component_utils(dev_h2d_req_driver)
    
    virtual cxl_cache_h2d_req_if.dev_pasv_drvr_mp dev_h2d_req_if;
    h2d_req_seq_item h2d_req_seq_item_h;

    function new(string name = "dev_h2d_req_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_req_if.dev_pasv_drvr_mp)::get(this, "", "dev_h2d_req_if", dev_h2d_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_req_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_h2d_req_if.rstn <= 'h0;
        repeat(h2d_req_seq_item_h.reset_cycles) @(negedge dev_h2d_req_if.clk) dev_h2d_req_if.rstn <= 'h0;
        dev_h2d_req_if.rstn <= 'h1;
        seq_item_port.item_done(h2d_req_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_req_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_h2d_rsp_driver extends uvm_driver#(h2d_rsp_seq_item);
    `uvm_component_utils(dev_h2d_rsp_driver)
    
    virtual cxl_cache_h2d_rsp_if.dev_pasv_drvr_mp dev_h2d_rsp_if;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;

    function new(string name = "dev_h2d_rsp_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_rsp_if.dev_pasv_drvr_mp)::get(this, "", "dev_h2d_rsp_if", dev_h2d_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_rsp_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_rsp_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_rsp_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_h2d_rsp_if.rstn <= 'h0;
        repeat(h2d_rsp_seq_item_h.reset_cycles) @(negedge dev_h2d_rsp_if.clk) dev_h2d_rsp_if.rstn <= 'h0;
        dev_h2d_rsp_if.rstn <= 'h1;
        seq_item_port.item_done(h2d_rsp_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_rsp_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_rsp_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_h2d_data_driver extends uvm_driver#(h2d_data_seq_item);
    `uvm_component_utils(dev_h2d_data_driver)
    
    virtual cxl_cache_h2d_data_if.dev_pasv_drvr_mp dev_h2d_data_if;
    h2d_data_seq_item h2d_data_seq_item_h;

    function new(string name = "dev_h2d_data_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_data_if.dev_pasv_drvr_mp)::get(this, "", "dev_h2d_data_if", dev_h2d_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_h2d_data_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_data_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_data_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_h2d_data_if.rstn <= 'h0;
        repeat(h2d_data_seq_item_h.reset_cycles) @(negedge dev_h2d_data_if.clk) dev_h2d_data_if.rstn <= 'h0;
        dev_h2d_data_if.rstn <= 'h1;
        seq_item_port.item_done(h2d_data_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_data_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_data_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_m2s_req_driver extends uvm_driver#(m2s_req_seq_item);
    `uvm_component_utils(dev_m2s_req_driver)
    
    virtual cxl_mem_m2s_req_if.dev_pasv_drvr_mp dev_m2s_req_if;
    m2s_req_seq_item m2s_req_seq_item_h;

    function new(string name = "dev_m2s_req_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_m2s_req_if.dev_pasv_drvr_mp)::get(this, "", "dev_m2s_req_if", dev_m2s_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_m2s_req_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(m2s_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_m2s_req_if.rstn <= 'h0;
        repeat(m2s_req_seq_item_h.reset_cycles) @(negedge dev_m2s_req_if.clk) dev_m2s_req_if.rstn <= 'h0;
        dev_m2s_req_if.rstn <= 'h1;
        seq_item_port.item_done(m2s_req_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(m2s_req_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_m2s_rwd_driver extends uvm_driver#(m2s_rwd_seq_item);
    `uvm_component_utils(dev_m2s_rwd_driver)
    
    virtual cxl_mem_m2s_rwd_if.dev_pasv_drvr_mp dev_m2s_rwd_if;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;

    function new(string name = "dev_m2s_rwd_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_m2s_rwd_if.dev_pasv_drvr_mp)::get(this, "", "dev_m2s_rwd_if", dev_m2s_rwd_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_m2s_rwd_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(m2s_rwd_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_rwd_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_m2s_rwd_if.rstn <= 'h0;
        repeat(m2s_rwd_seq_item_h.reset_cycles) @(negedge dev_m2s_rwd_if.clk) dev_m2s_rwd_if.rstn <= 'h0;
        dev_m2s_rwd_if.rstn <= 'h1;
        seq_item_port.item_done(m2s_rwd_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(m2s_rwd_seq_item_h);  
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_rwd_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_d2h_req_driver extends uvm_driver#(d2h_req_seq_item);
    `uvm_component_utils(dev_d2h_req_driver)
    
    virtual cxl_cache_d2h_req_if.dev_actv_drvr_mp dev_d2h_req_if;
    d2h_req_seq_item d2h_req_seq_item_h;

    function new(string name = "dev_d2h_req_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_req_if.dev_actv_drvr_mp)::get(this, "", "dev_d2h_req_if", dev_d2h_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_req_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_d2h_req_if.rstn <= 'h0;
        repeat(d2h_req_seq_item_h.reset_cycles) @(negedge dev_d2h_req_if.clk) dev_d2h_req_if.rstn <= 'h0;
        dev_d2h_req_if.rstn <= 'h1;
        seq_item_port.item_done(d2h_req_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(d2h_req_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_req_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(dev_d2h_req_if.ready);
      seq_item_port.item_done(d2h_req_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask
  endclass

  class dev_d2h_rsp_driver extends uvm_driver#(d2h_rsp_seq_item);
    `uvm_component_utils(dev_d2h_rsp_driver)
    
    virtual cxl_cache_d2h_rsp_if.dev_actv_drvr_mp dev_d2h_rsp_if;
    d2h_rsp_seq_item d2h_rsp_seq_item_h;

    function new(string name = "dev_d2h_rsp_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_rsp_if.dev_actv_drvr_mp)::get(this, "", "dev_d2h_rsp_if", dev_d2h_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_rsp_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_rsp_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_rsp_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_d2h_rsp_if.rstn <= 'h0;
        repeat(d2h_rsp_seq_item_h.reset_cycles) @(negedge dev_d2h_rsp_if.clk) dev_d2h_rsp_if.rstn <= 'h0;
        dev_d2h_rsp_if.rstn <= 'h1;
        seq_item_port.item_done(d2h_rsp_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(d2h_rsp_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_rsp_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(dev_d2h_rsp_if.ready);
      seq_item_port.item_done(d2h_rsp_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_rsp_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_rsp_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_d2h_data_driver extends uvm_driver#(d2h_data_seq_item);
    `uvm_component_utils(dev_d2h_data_driver)
    virtual cxl_cache_d2h_data_if.dev_actv_drvr_mp dev_d2h_data_if;
    d2h_data_seq_item d2h_data_seq_item_h;

    function new(string name = "dev_d2h_data_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_d2h_data_if.dev_actv_drvr_mp)::get(this, "", "dev_d2h_data_if", dev_d2h_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_d2h_data_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_data_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_data_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_d2h_data_if.rstn <= 'h0;
        repeat(d2h_data_seq_item_h.reset_cycles) @(negedge dev_d2h_data_if.clk) dev_d2h_data_if.rstn <= 'h0;
        dev_d2h_data_if.rstn <= 'h1;
        seq_item_port.item_done(d2h_data_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(d2h_data_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_data_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(dev_d2h_data_if.ready);
      seq_item_port.item_done(d2h_data_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(d2h_data_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", d2h_data_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
        seq_item_port.item_done(d2h_data_seq_item_h);
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class host_h2d_req_driver extends uvm_driver#(h2d_req_seq_item);
    `uvm_component_utils(host_h2d_req_driver)
    virtual cxl_cache_h2d_req_if.host_actv_drvr_mp host_h2d_req_if;
    h2d_req_seq_item h2d_req_seq_item_h;

    function new(string name = "host_h2d_req_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_req_if.host_actv_drvr_mp)::get(this, "", "host_h2d_req_if", host_h2d_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_req_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_h2d_req_if.rstn <= 'h0;
        repeat(h2d_req_seq_item_h.reset_cycles) @(negedge host_h2d_req_if.clk) host_h2d_req_if.rstn <= 'h0;
        host_h2d_req_if.rstn <= 'h1;
        seq_item_port.item_done(h2d_req_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(h2d_req_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_req_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(host_h2d_req_if.ready);
      seq_item_port.item_done(h2d_req_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass
  
  class host_h2d_rsp_driver extends uvm_driver#(h2d_rsp_seq_item);
    `uvm_component_utils(host_h2d_rsp_driver)
    virtual cxl_cache_h2d_rsp_if.host_actv_drvr_mp host_h2d_rsp_if;
    h2d_rsp_seq_item h2d_rsp_seq_item_h;

    function new(string name = "host_h2d_rsp_monitor", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_rsp_if.host_actv_drvr_mp)::get(this, "", "host_h2d_rsp_if", host_h2d_rsp_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_rsp_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_rsp_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_rsp_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_h2d_rsp_if.rstn <= 'h0;
        repeat(h2d_rsp_seq_item_h.reset_cycles) @(negedge host_h2d_rsp_if.clk) host_h2d_rsp_if.rstn <= 'h0;
        host_h2d_rsp_if.rstn <= 'h1;
        seq_item_port.item_done(h2d_rsp_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(h2d_rsp_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_rsp_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(host_h2d_rsp_if.ready);
      seq_item_port.item_done(h2d_rsp_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_rsp_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_rsp_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class host_h2d_data_driver extends uvm_driver#(h2d_data_seq_item);
    `uvm_component_utils(host_h2d_data_driver)
    virtual cxl_cache_h2d_data_if.host_actv_drvr_mp host_h2d_data_if;
    h2d_data_seq_item h2d_data_seq_item_h;

    function new(string name = "host_h2d_data_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_cache_h2d_data_if.host_actv_drvr_mp)::get(this, "", "host_h2d_data_if", host_h2d_data_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_h2d_data_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_data_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_data_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_h2d_data_if.rstn <= 'h0;
        repeat(h2d_data_seq_item_h.reset_cycles) @(negedge host_h2d_data_if.clk) host_h2d_data_if.rstn <= 'h0;
        host_h2d_data_if.rstn <= 'h1;
        seq_item_port.item_done(h2d_data_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(h2d_data_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_data_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(host_h2d_data_if.ready);
      seq_item_port.item_done(h2d_data_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(h2d_data_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", h2d_data_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class host_m2s_req_driver extends uvm_driver#(m2s_req_seq_item);
    `uvm_component_utils(host_m2s_req_driver)
    virtual cxl_mem_m2s_req_if.host_actv_drvr_mp host_m2s_req_if;
    m2s_req_seq_item m2s_req_seq_item_h;

    function new(string name = "host_m2s_req_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_m2s_req_if.host_actv_drvr_mp)::get(this, "", "host_m2s_req_if", host_m2s_req_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_m2s_req_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction 

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(m2s_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_m2s_req_if.rstn <= 'h0;
        repeat(m2s_req_seq_item_h.reset_cycles) @(negedge host_m2s_req_if.clk) host_m2s_req_if.rstn <= 'h0;
        host_m2s_req_if.rstn <= 'h1;
        seq_item_port.item_done(m2s_req_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(m2s_req_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_req_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(host_m2s_req_if.ready);
      seq_item_port.item_done(m2s_req_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin  
        seq_item_port.get_next_item(m2s_req_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_req_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
        if(m2s_req_seq_item_h.delay_set) begin
          repeat(m2s_req_seq_item_h.delay_value) @(negedge host_m2s_req_if.clk);
        end
        host_m2s_req_if.m2s_req_txn.valid    <=  m2s_req_seq_item_h.valid;
        host_m2s_req_if.m2s_req_txn.address  <=  m2s_req_seq_item_h.address;
        host_m2s_req_if.m2s_req_txn.memopcode<=  m2s_req_seq_item_h.memopcode;
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask

  endclass

  class host_m2s_rwd_driver extends uvm_driver#(m2s_rwd_seq_item);
    `uvm_component_utils(host_m2s_rwd_driver)
    virtual cxl_mem_m2s_rwd_if.host_actv_drvr_mp host_m2s_rwd_if;
    m2s_rwd_seq_item m2s_rwd_seq_item_h;

    function new(string name = "host_m2s_rwd_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_m2s_rwd_if.host_actv_drvr_mp)::get(this, "", "host_m2s_rwd_if", host_m2s_rwd_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface host_m2s_rwd_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(m2s_rwd_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_rwd_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        host_m2s_rwd_if.rstn <= 'h0;
        repeat(m2s_rwd_seq_item_h.reset_cycles) @(negedge host_m2s_rwd_if.clk) host_m2s_rwd_if.rstn <= 'h0;
        host_m2s_rwd_if.rstn <= 'h1;
        seq_item_port.item_done(m2s_rwd_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(m2s_rwd_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_rwd_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(host_m2s_rwd_if.ready);
      seq_item_port.item_done(m2s_rwd_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin  
        seq_item_port.get_next_item(m2s_rwd_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", m2s_rwd_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
        if(m2s_rwd_seq_item_h.delay_set) begin
          repeat(m2s_rwd_seq_item_h.delay_value) @(negedge host_m2s_rwd_if.clk);
        end
        host_m2s_rwd_if.m2s_rwd_txn.valid    <=  m2s_rwd_seq_item_h.valid;
        host_m2s_rwd_if.m2s_rwd_txn.address  <=  m2s_rwd_seq_item_h.address;
        host_m2s_rwd_if.m2s_rwd_txn.memopcode<=  m2s_rwd_seq_item_h.memopcode;
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_s2m_ndr_driver extends uvm_driver#(s2m_ndr_seq_item);
    `uvm_component_utils(dev_s2m_ndr_driver)
    virtual cxl_mem_s2m_ndr_if.dev_actv_drvr_mp dev_s2m_ndr_if;
    s2m_ndr_seq_item s2m_ndr_seq_item_h;

    function new(string name = "dev_s2m_ndr_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_s2m_ndr_if.dev_actv_drvr_mp)::get(this, "", "dev_s2m_ndr_if", dev_s2m_ndr_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_s2m_ndr_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(s2m_ndr_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_ndr_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_s2m_ndr_if.rstn <= 'h0;
        repeat(s2m_ndr_seq_item_h.reset_cycles) @(negedge dev_s2m_ndr_if.clk) dev_s2m_ndr_if.rstn <= 'h0;
        dev_s2m_ndr_if.rstn <= 'h1;
        seq_item_port.item_done(s2m_ndr_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(s2m_ndr_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_ndr_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(dev_s2m_ndr_if.ready);
      seq_item_port.item_done(s2m_ndr_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin  
        seq_item_port.get_next_item(s2m_ndr_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_ndr_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)  
    endtask

  endclass

  class dev_s2m_drs_driver extends uvm_driver#(s2m_drs_seq_item);
    `uvm_component_utils(dev_s2m_drs_driver)
    virtual cxl_mem_s2m_drs_if.dev_actv_drvr_mp dev_s2m_drs_if;
    s2m_drs_seq_item s2m_drs_seq_item_h;

    function new(string name = "dev_s2m_drs_driver", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm driver : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      if(!(uvm_config_db#(virtual cxl_mem_s2m_drs_if.dev_actv_drvr_mp)::get(this, "", "dev_s2m_drs_if", dev_s2m_drs_if))) begin
        `uvm_fatal(get_type_name(), $sformatf("failed to get virtual interface dev_s2m_drs_if"));
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter reset_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin
        seq_item_port.get_next_item(s2m_drs_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_drs_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);  
        dev_s2m_drs_if.rstn <= 'h0;
        repeat(s2m_drs_seq_item_h.reset_cycles) @(negedge dev_s2m_drs_if.clk) dev_s2m_drs_if.rstn <= 'h0;
        dev_s2m_drs_if.rstn <= 'h1;
        seq_item_port.item_done(s2m_drs_seq_item_h);  
        phase.drop_objection(phase);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      seq_item_port.get_next_item(s2m_drs_seq_item_h);
      `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_drs_seq_item_h.sprint()), UVM_DEBUG)
      phase.raise_objection(this);  
      wait(dev_s2m_drs_if.ready);
      seq_item_port.item_done(s2m_drs_seq_item_h);  
      phase.drop_objection(phase);
      `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("exit configure_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
      forever begin  
        seq_item_port.get_next_item(s2m_drs_seq_item_h);
        `uvm_info(get_type_name(), $sformatf("fetching new seq item in driver : %s", get_full_name()), UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("got item in uvm driver : %s", s2m_drs_seq_item_h.sprint()), UVM_DEBUG)
        phase.raise_objection(this);
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
        phase.drop_objection(this);
        `uvm_info(get_type_name(), $sformatf("seq item done in driver : %s", get_full_name()), UVM_HIGH)
      end
      `uvm_info(get_type_name(), $sformatf("exit run_phase in uvm driver : %s", get_full_name()), UVM_HIGH)
    endtask

  endclass

  class dev_d2h_req_agent extends uvm_agent;
    `uvm_component_utils(dev_d2h_req_agent)
    dev_d2h_req_driver dev_d2h_req_driver_h;
    dev_d2h_req_monitor dev_d2h_req_monitor_h;
    dev_d2h_req_sequencer dev_d2h_req_sequencer_h;

    function new(string name = "dev_d2h_req_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_req_sequencer_h = dev_d2h_req_sequencer::type_id::create("dev_d2h_req_sequencer_h", this);
        dev_d2h_req_driver_h = dev_d2h_req_driver::type_id::create("dev_d2h_req_driver_h", this);
      end
      dev_d2h_req_monitor_h = dev_d2h_req_monitor::type_id::create("dev_d2h_req_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_req_driver_h.seq_item_port.connect(dev_d2h_req_sequencer_h.seq_item_export);
        dev_d2h_req_monitor_h.d2h_req_port.connect(dev_d2h_req_sequencer_h.dev_d2h_req_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class dev_d2h_rsp_agent extends uvm_agent;
    `uvm_component_utils(dev_d2h_rsp_agent)
    dev_d2h_rsp_driver dev_d2h_rsp_driver_h;
    dev_d2h_rsp_monitor dev_d2h_rsp_monitor_h;
    dev_d2h_rsp_sequencer dev_d2h_rsp_sequencer_h;

    function new(string name = "dev_d2h_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_rsp_sequencer_h = dev_d2h_rsp_sequencer::type_id::create("dev_d2h_rsp_sequencer_h", this);
        dev_d2h_rsp_driver_h = dev_d2h_rsp_driver::type_id::create("dev_d2h_rsp_driver_h", this);
      end
      dev_d2h_rsp_monitor_h = dev_d2h_rsp_monitor::type_id::create("dev_d2h_rsp_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_rsp_driver_h.seq_item_port.connect(dev_d2h_rsp_sequencer_h.seq_item_export);
        dev_d2h_rsp_monitor_h.d2h_rsp_port.connect(dev_d2h_rsp_sequencer_h.dev_d2h_rsp_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass

  class dev_d2h_data_agent extends uvm_agent;
    `uvm_component_utils(dev_d2h_data_agent)
    dev_d2h_data_driver dev_d2h_data_driver_h;
    dev_d2h_data_monitor dev_d2h_data_monitor_h;
    dev_d2h_data_sequencer dev_d2h_data_sequencer_h;

    function new(string name = "dev_d2h_data_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_data_sequencer_h = dev_d2h_data_sequencer::type_id::create("dev_d2h_data_sequencer_h", this);
        dev_d2h_data_driver_h = dev_d2h_data_driver::type_id::create("dev_d2h_data_driver_h", this);
      end
      dev_d2h_data_monitor_h = dev_d2h_data_monitor::type_id::create("dev_d2h_data_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_d2h_data_driver_h.seq_item_port.connect(dev_d2h_data_sequencer_h.seq_item_export);
        dev_d2h_data_monitor_h.d2h_data_port.connect(dev_d2h_data_sequencer_h.dev_d2h_data_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass

  class host_h2d_req_agent extends uvm_agent;
    `uvm_component_utils(host_h2d_req_agent)
    host_h2d_req_driver host_h2d_req_driver_h;
    host_h2d_req_monitor host_h2d_req_monitor_h;
    host_h2d_req_sequencer host_h2d_req_sequencer_h;

    function new(string name = "host_h2d_req_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_h2d_req_sequencer_h = host_h2d_req_sequencer::type_id::create("host_h2d_req_sequencer_h", this);
        host_h2d_req_driver_h = host_h2d_req_driver::type_id::create("host_h2d_req_driver_h", this);
      end
      host_h2d_req_monitor_h = host_h2d_req_monitor::type_id::create("host_h2d_req_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)  
      if(is_active == UVM_ACTIVE) begin
        host_h2d_req_driver_h.seq_item_port.connect(host_h2d_req_sequencer_h.seq_item_export);
        host_h2d_req_monitor_h.h2d_req_port.connect(host_h2d_req_sequencer_h.host_h2d_req_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class host_h2d_rsp_agent extends uvm_agent;
    `uvm_component_utils(host_h2d_rsp_agent)
    host_h2d_rsp_driver host_h2d_rsp_driver_h;
    host_h2d_rsp_monitor host_h2d_rsp_monitor_h;
    host_h2d_rsp_sequencer host_h2d_rsp_sequencer_h;

    function new(string name = "host_h2d_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)  
      if(is_active == UVM_ACTIVE) begin
        host_h2d_rsp_sequencer_h = host_h2d_rsp_sequencer::type_id::create("host_h2d_rsp_sequencer_h", this);
        host_h2d_rsp_driver_h = host_h2d_rsp_driver::type_id::create("host_h2d_rsp_driver_h", this);
      end
      host_h2d_rsp_monitor_h = host_h2d_rsp_monitor::type_id::create("host_h2d_rsp_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_h2d_rsp_driver_h.seq_item_port.connect(host_h2d_rsp_sequencer_h.seq_item_export);
        host_h2d_rsp_monitor_h.h2d_rsp_port.connect(host_h2d_rsp_sequencer_h.host_h2d_rsp_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class host_h2d_data_agent extends uvm_agent;
    `uvm_component_utils(host_h2d_data_agent)
    host_h2d_data_driver host_h2d_data_driver_h;
    host_h2d_data_monitor host_h2d_data_monitor_h;
    host_h2d_data_sequencer host_h2d_data_sequencer_h;

    function new(string name = "host_h2d_data_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_h2d_data_sequencer_h = host_h2d_data_sequencer::type_id::create("host_h2d_data_sequencer_h", this);
        host_h2d_data_driver_h = host_h2d_data_driver::type_id::create("host_h2d_data_driver_h", this);
      end
      host_h2d_data_monitor_h = host_h2d_data_monitor::type_id::create("host_h2d_data_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_h2d_data_driver_h.seq_item_port.connect(host_h2d_data_sequencer_h.seq_item_export);
        host_h2d_data_monitor_h.h2d_data_port.connect(host_h2d_data_sequencer_h.host_h2d_data_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
 
  class host_m2s_req_agent extends uvm_agent;
    `uvm_component_utils(host_m2s_req_agent)
    host_m2s_req_driver host_m2s_req_driver_h;
    host_m2s_req_monitor host_m2s_req_monitor_h;
    host_m2s_req_sequencer host_m2s_req_sequencer_h;

    function new(string name = "host_m2s_req_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_m2s_req_sequencer_h = host_m2s_req_sequencer::type_id::create("host_m2s_req_sequencer_h", this);
        host_m2s_req_driver_h = host_m2s_req_driver::type_id::create("host_m2s_req_driver_h", this);
      end
      host_m2s_req_monitor_h = host_m2s_req_monitor::type_id::create("host_m2s_req_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_m2s_req_driver_h.seq_item_port.connect(host_m2s_req_sequencer_h.seq_item_export);
        host_m2s_req_monitor_h.m2s_req_port.connect(host_m2s_req_sequencer_h.host_m2s_req_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class host_m2s_rwd_agent extends uvm_agent;
    `uvm_component_utils(host_m2s_rwd_agent)
    host_m2s_rwd_driver host_m2s_rwd_driver_h;
    host_m2s_rwd_monitor host_m2s_rwd_monitor_h;
    host_m2s_rwd_sequencer host_m2s_rwd_sequencer_h;

    function new(string name = "host_m2s_rwd_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_m2s_rwd_sequencer_h = host_m2s_rwd_sequencer::type_id::create("host_m2s_rwd_sequencer_h", this);
        host_m2s_rwd_driver_h = host_m2s_rwd_driver::type_id::create("host_m2s_rwd_driver_h", this);
      end
      host_m2s_rwd_monitor_h = host_m2s_rwd_monitor::type_id::create("host_m2s_rwd_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_m2s_rwd_driver_h.seq_item_port.connect(host_m2s_rwd_sequencer_h.seq_item_export);
        host_m2s_rwd_monitor_h.m2s_rwd_port.connect(host_m2s_rwd_sequencer_h.host_m2s_rwd_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass

  class dev_s2m_ndr_agent extends uvm_agent;
    `uvm_component_utils(dev_s2m_ndr_agent)
    dev_s2m_ndr_driver dev_s2m_ndr_driver_h;
    dev_s2m_ndr_monitor dev_s2m_ndr_monitor_h;
    dev_s2m_ndr_sequencer dev_s2m_ndr_sequencer_h;

    function new(string name = "dev_s2m_ndr_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_s2m_ndr_sequencer_h = dev_s2m_ndr_sequencer::type_id::create("dev_s2m_ndr_sequencer_h", this);
        dev_s2m_ndr_driver_h = dev_s2m_ndr_driver::type_id::create("dev_s2m_ndr_driver_h", this);
      end
      dev_s2m_ndr_monitor_h = dev_s2m_ndr_monitor::type_id::create("dev_s2m_ndr_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_s2m_ndr_driver_h.seq_item_port.connect(dev_s2m_ndr_sequencer_h.seq_item_export);
        dev_s2m_ndr_monitor_h.s2m_ndr_port.connect(dev_s2m_ndr_sequencer_h.dev_s2m_ndr_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class dev_s2m_drs_agent extends uvm_agent;
    `uvm_component_utils(dev_s2m_drs_agent)
    dev_s2m_drs_driver dev_s2m_drs_driver_h;
    dev_s2m_drs_monitor dev_s2m_drs_monitor_h;
    dev_s2m_drs_sequencer dev_s2m_drs_sequencer_h;

    function new(string name = "dev_s2m_drs_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_s2m_drs_sequencer_h = dev_s2m_drs_sequencer::type_id::create("dev_s2m_drs_sequencer_h", this);
        dev_s2m_drs_driver_h = dev_s2m_drs_driver::type_id::create("dev_s2m_drs_driver_h", this);
      end
      dev_s2m_drs_monitor_h = dev_s2m_drs_monitor::type_id::create("dev_s2m_drs_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_s2m_drs_driver_h.seq_item_port.connect(dev_s2m_drs_sequencer_h.seq_item_export);
        dev_s2m_drs_monitor_h.s2m_drs_port.connect(dev_s2m_drs_sequencer_h.dev_s2m_drs_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass

  class host_d2h_req_agent extends uvm_agent;
    `uvm_component_utils(host_d2h_req_agent)
    host_d2h_req_driver host_d2h_req_driver_h;
    host_d2h_req_monitor host_d2h_req_monitor_h;
    host_d2h_req_sequencer host_d2h_req_sequencer_h;

    function new(string name = "host_d2h_req_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_d2h_req_sequencer_h = host_d2h_req_sequencer::type_id::create("host_d2h_req_sequencer_h", this);
        host_d2h_req_driver_h = host_d2h_req_driver::type_id::create("host_d2h_req_driver_h", this);
      end
      host_d2h_req_monitor_h = host_d2h_req_monitor::type_id::create("host_d2h_req_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)  
      if(is_active == UVM_ACTIVE) begin
        host_d2h_req_driver_h.seq_item_port.connect(host_d2h_req_sequencer_h.seq_item_export);
        host_d2h_req_monitor_h.d2h_req_port.connect(host_d2h_req_sequencer_h.host_d2h_req_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class host_d2h_rsp_agent extends uvm_agent;
    `uvm_component_utils(host_d2h_rsp_agent)
    host_d2h_rsp_driver host_d2h_rsp_driver_h;
    host_d2h_rsp_monitor host_d2h_rsp_monitor_h;
    host_d2h_rsp_sequencer host_d2h_rsp_sequencer_h;

    function new(string name = "host_d2h_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_d2h_rsp_sequencer_h = host_d2h_rsp_sequencer::type_id::create("host_d2h_rsp_sequencer_h", this);
        host_d2h_rsp_driver_h = host_d2h_rsp_driver::type_id::create("host_d2h_rsp_driver_h", this);
      end
      host_d2h_rsp_monitor_h = host_d2h_rsp_monitor::type_id::create("host_d2h_rsp_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)  
      if(is_active == UVM_ACTIVE) begin
        host_d2h_rsp_driver_h.seq_item_port.connect(host_d2h_rsp_sequencer_h.seq_item_export);
        host_d2h_rsp_monitor_h.d2h_rsp_port.connect(host_d2h_rsp_sequencer_h.host_d2h_rsp_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass

  class host_d2h_data_agent extends uvm_agent;
    `uvm_component_utils(host_d2h_data_agent)
    host_d2h_data_driver host_d2h_data_driver_h;
    host_d2h_data_monitor host_d2h_data_monitor_h;
    host_d2h_data_sequencer host_d2h_data_sequencer_h;

    function new(string name = "host_d2h_data_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_d2h_data_sequencer_h = host_d2h_data_sequencer::type_id::create("host_d2h_data_sequencer_h", this);
        host_d2h_data_driver_h = host_d2h_data_driver::type_id::create("host_d2h_data_driver_h", this);
      end
      host_d2h_data_monitor_h = host_d2h_data_monitor::type_id::create("host_d2h_data_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_d2h_data_driver_h.seq_item_port.connect(host_d2h_data_sequencer_h.seq_item_export);
        host_d2h_data_monitor_h.d2h_data_port.connect(host_d2h_data_sequencer_h.host_d2h_data_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass

  class dev_h2d_req_agent extends uvm_agent;
    `uvm_component_utils(dev_h2d_req_agent)
    dev_h2d_req_driver dev_h2d_req_driver_h;
    dev_h2d_req_monitor dev_h2d_req_monitor_h;
    dev_h2d_req_sequencer dev_h2d_req_sequencer_h;

    function new(string name = "dev_h2d_req_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_req_sequencer_h = dev_h2d_req_sequencer::type_id::create("dev_h2d_req_sequencer_h", this);
        dev_h2d_req_driver_h = dev_h2d_req_driver::type_id::create("dev_h2d_req_driver_h", this);
      end
      dev_h2d_req_monitor_h = dev_h2d_req_monitor::type_id::create("dev_h2d_req_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_req_driver_h.seq_item_port.connect(dev_h2d_req_sequencer_h.seq_item_export);
        dev_h2d_req_monitor_h.h2d_req_port.connect(dev_h2d_req_sequencer_h.dev_h2d_req_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class dev_h2d_rsp_agent extends uvm_agent;
    `uvm_component_utils(dev_h2d_rsp_agent)
    dev_h2d_rsp_driver dev_h2d_rsp_driver_h;
    dev_h2d_rsp_monitor dev_h2d_rsp_monitor_h;
    dev_h2d_rsp_sequencer dev_h2d_rsp_sequencer_h;

    function new(string name = "dev_h2d_rsp_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_rsp_sequencer_h = dev_h2d_rsp_sequencer::type_id::create("dev_h2d_rsp_sequencer_h", this);
        dev_h2d_rsp_driver_h = dev_h2d_rsp_driver::type_id::create("dev_h2d_rsp_driver_h", this);
      end
      dev_h2d_rsp_monitor_h = dev_h2d_rsp_monitor::type_id::create("dev_h2d_rsp_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_rsp_driver_h.seq_item_port.connect(dev_h2d_rsp_sequencer_h.seq_item_export);
        dev_h2d_rsp_monitor_h.h2d_rsp_port.connect(dev_h2d_rsp_sequencer_h.dev_h2d_rsp_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class dev_h2d_data_agent extends uvm_agent;
    `uvm_component_utils(dev_h2d_data_agent)
    dev_h2d_data_driver dev_h2d_data_driver_h;
    dev_h2d_data_monitor dev_h2d_data_monitor_h;
    dev_h2d_data_sequencer dev_h2d_data_sequencer_h;

    function new(string name = "dev_h2d_data_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_data_sequencer_h = dev_h2d_data_sequencer::type_id::create("dev_h2d_data_sequencer_h", this);
        dev_h2d_data_driver_h = dev_h2d_data_driver::type_id::create("dev_h2d_data_driver_h", this);
      end
      dev_h2d_data_monitor_h = dev_h2d_data_monitor::type_id::create("dev_h2d_data_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_h2d_data_driver_h.seq_item_port.connect(dev_h2d_data_sequencer_h.seq_item_export);
        dev_h2d_data_monitor_h.h2d_data_port.connect(dev_h2d_data_sequencer_h.dev_h2d_data_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
 
  class dev_m2s_req_agent extends uvm_agent;
    `uvm_component_utils(dev_m2s_req_agent)
    dev_m2s_req_driver dev_m2s_req_driver_h;
    dev_m2s_req_monitor dev_m2s_req_monitor_h;
    dev_m2s_req_sequencer dev_m2s_req_sequencer_h;

    function new(string name = "dev_m2s_req_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_m2s_req_sequencer_h = dev_m2s_req_sequencer::type_id::create("dev_m2s_req_sequencer_h", this);
        dev_m2s_req_driver_h = dev_m2s_req_driver::type_id::create("dev_m2s_req_driver_h", this);
      end
      dev_m2s_req_monitor_h = dev_m2s_req_monitor::type_id::create("dev_m2s_req_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_m2s_req_driver_h.seq_item_port.connect(dev_m2s_req_sequencer_h.seq_item_export);
        dev_m2s_req_monitor_h.m2s_req_port.connect(dev_m2s_req_sequencer_h.dev_m2s_req_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class dev_m2s_rwd_agent extends uvm_agent;
    `uvm_component_utils(dev_m2s_rwd_agent)
    dev_m2s_rwd_driver dev_m2s_rwd_driver_h;
    dev_m2s_rwd_monitor dev_m2s_rwd_monitor_h;
    dev_m2s_rwd_sequencer dev_m2s_rwd_sequencer_h;

    function new(string name = "dev_m2s_rwd_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_m2s_rwd_sequencer_h = dev_m2s_rwd_sequencer::type_id::create("dev_m2s_rwd_sequencer_h", this);
        dev_m2s_rwd_driver_h = dev_m2s_rwd_driver::type_id::create("dev_m2s_rwd_driver_h", this);
      end
      dev_m2s_rwd_monitor_h = dev_m2s_rwd_monitor::type_id::create("dev_m2s_rwd_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        dev_m2s_rwd_driver_h.seq_item_port.connect(dev_m2s_rwd_sequencer_h.seq_item_export);
        dev_m2s_rwd_monitor_h.m2s_rwd_port.connect(dev_m2s_rwd_sequencer_h.dev_m2s_rwd_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass

  class host_s2m_ndr_agent extends uvm_agent;
    `uvm_component_utils(host_s2m_ndr_agent)
    host_s2m_ndr_driver host_s2m_ndr_driver_h;
    host_s2m_ndr_monitor host_s2m_ndr_monitor_h;
    host_s2m_ndr_sequencer host_s2m_ndr_sequencer_h;

    function new(string name = "host_s2m_ndr_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_s2m_ndr_sequencer_h = host_s2m_ndr_sequencer::type_id::create("host_s2m_ndr_sequencer_h", this);
        host_s2m_ndr_driver_h = host_s2m_ndr_driver::type_id::create("host_s2m_ndr_driver_h", this);
      end
      host_s2m_ndr_monitor_h = host_s2m_ndr_monitor::type_id::create("host_s2m_ndr_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_s2m_ndr_driver_h.seq_item_port.connect(host_s2m_ndr_sequencer_h.seq_item_export);
        host_s2m_ndr_monitor_h.s2m_ndr_port.connect(host_s2m_ndr_sequencer_h.host_s2m_ndr_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
  
  class host_s2m_drs_agent extends uvm_agent;
    `uvm_component_utils(host_s2m_drs_agent)
    host_s2m_drs_driver host_s2m_drs_driver_h;
    host_s2m_drs_monitor host_s2m_drs_monitor_h;
    host_s2m_drs_sequencer host_s2m_drs_sequencer_h;

    function new(string name = "host_s2m_drs_agent", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm agent : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_s2m_drs_sequencer_h = host_s2m_drs_sequencer::type_id::create("host_s2m_drs_sequencer_h", this);
        host_s2m_drs_driver_h = host_s2m_drs_driver::type_id::create("host_s2m_drs_driver_h", this);
      end
      host_s2m_drs_monitor_h = host_s2m_drs_monitor::type_id::create("host_s2m_drs_monitor_h", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("is_active = %0s", is_active.name()), UVM_HIGH)
      if(is_active == UVM_ACTIVE) begin
        host_s2m_drs_driver_h.seq_item_port.connect(host_s2m_drs_sequencer_h.seq_item_export);
        host_s2m_drs_monitor_h.s2m_drs_port.connect(host_s2m_drs_sequencer_h.host_s2m_drs_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm agent : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass
//TODO:put checker of checking all 1s data for err and GO-I condition in rsp in monitor not in scoreboard
  class cxl_cm_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(cxl_cm_scoreboard)
    d2h_req_seq_item  dev_d2h_req_host_d2h_req_integ_aa   [logic[11:0]];
    d2h_rsp_seq_item  dev_d2h_rsp_host_d2h_rsp_integ_aa   [logic[11:0]];
    d2h_data_seq_item dev_d2h_data_host_d2h_data_integ_aa [logic[11:0]];
    h2d_req_seq_item  host_h2d_req_dev_h2d_req_integ_aa   [logic[11:0]];
    h2d_rsp_seq_item  host_h2d_rsp_dev_h2d_rsp_integ_aa   [logic[11:0]];
    h2d_data_seq_item host_h2d_data_dev_h2d_data_integ_aa [logic[11:0]];
    m2s_req_seq_item  host_m2s_req_dev_m2s_req_integ_aa   [logic[11:0]];
    m2s_rwd_seq_item  host_m2s_rwd_dev_m2s_rwd_integ_aa   [logic[11:0]];
    s2m_ndr_seq_item  dev_s2m_ndr_host_s2m_ndr_integ_aa   [logic[11:0]];
    s2m_drs_seq_item  dev_s2m_drs_host_s2m_drs_integ_aa   [logic[11:0]];
    d2h_req_seq_item  memrdfwd_aa             [logic[11:0]];
    d2h_req_seq_item  memwrfwd_aa             [logic[11:0]];
    d2h_req_seq_item  d2h_req_h2d_rsp_aa      [logic[11:0]];
    d2h_req_seq_item  d2h_req_h2d_data_aa     [logic[11:0]];
    h2d_rsp_seq_item  h2d_rsp_h2d_rsp_aa      [logic[11:0]];
    h2d_rsp_seq_item  h2d_rsp_d2h_data_aa     [logic[11:0]];
    h2d_rsp_seq_item  h2d_rsp_d2h_errdata_aa  [logic[11:0]];
    h2d_rsp_seq_item  h2d_rsp_h2d_errdata_aa  [logic[11:0]];
    h2d_req_seq_item  h2d_req_d2h_rsp_aa      [logic[11:0]];
    h2d_req_seq_item  h2d_req_d2h_data_aa     [logic[11:0]];
    m2s_req_seq_item  m2s_req_s2m_ndr_aa      [logic[11:0]];
    m2s_req_seq_item  m2s_req_s2m_drs_aa      [logic[11:0]];
    m2s_rwd_seq_item  m2s_rwd_s2m_ndr_aa      [logic[11:0]];
    h2d_req_seq_item  host_h2d_req_seq_item_h;
    h2d_rsp_seq_item  host_h2d_rsp_seq_item_h;
    h2d_data_seq_item host_h2d_data_seq_item_h;
    h2d_req_seq_item  dev_h2d_req_seq_item_h;
    h2d_rsp_seq_item  dev_h2d_rsp_seq_item_h;
    h2d_data_seq_item dev_h2d_data_seq_item_h;
    d2h_req_seq_item  host_d2h_req_seq_item_h;
    d2h_rsp_seq_item  host_d2h_rsp_seq_item_h;
    d2h_data_seq_item host_d2h_data_seq_item_h;
    d2h_req_seq_item  dev_d2h_req_seq_item_h;
    d2h_rsp_seq_item  dev_d2h_rsp_seq_item_h;
    d2h_data_seq_item dev_d2h_data_seq_item_h;
    m2s_req_seq_item  dev_m2s_req_seq_item_h;
    m2s_rwd_seq_item  dev_m2s_rwd_seq_item_h;
    s2m_ndr_seq_item  dev_s2m_ndr_seq_item_h;
    s2m_drs_seq_item  dev_s2m_drs_seq_item_h;
    m2s_req_seq_item  host_m2s_req_seq_item_h;
    m2s_rwd_seq_item  host_m2s_rwd_seq_item_h;
    s2m_ndr_seq_item  host_s2m_ndr_seq_item_h;
    s2m_drs_seq_item  host_s2m_drs_seq_item_h;
    uvm_tlm_analysis_fifo#(h2d_req_seq_item)  dev_h2d_req_fifo;
    uvm_tlm_analysis_fifo#(h2d_rsp_seq_item)  dev_h2d_rsp_fifo;
    uvm_tlm_analysis_fifo#(h2d_data_seq_item) dev_h2d_data_fifo;
    uvm_tlm_analysis_fifo#(h2d_req_seq_item)  host_h2d_req_fifo;
    uvm_tlm_analysis_fifo#(h2d_rsp_seq_item)  host_h2d_rsp_fifo;
    uvm_tlm_analysis_fifo#(h2d_data_seq_item) host_h2d_data_fifo;
    uvm_tlm_analysis_fifo#(d2h_req_seq_item)  dev_d2h_req_fifo;
    uvm_tlm_analysis_fifo#(d2h_rsp_seq_item)  dev_d2h_rsp_fifo;
    uvm_tlm_analysis_fifo#(d2h_data_seq_item) dev_d2h_data_fifo;
    uvm_tlm_analysis_fifo#(d2h_req_seq_item)  host_d2h_req_fifo;
    uvm_tlm_analysis_fifo#(d2h_rsp_seq_item)  host_d2h_rsp_fifo;
    uvm_tlm_analysis_fifo#(d2h_data_seq_item) host_d2h_data_fifo;
    uvm_tlm_analysis_fifo#(m2s_req_seq_item)  host_m2s_req_fifo;
    uvm_tlm_analysis_fifo#(m2s_rwd_seq_item)  host_m2s_rwd_fifo;
    uvm_tlm_analysis_fifo#(m2s_req_seq_item)  dev_m2s_req_fifo;
    uvm_tlm_analysis_fifo#(m2s_rwd_seq_item)  dev_m2s_rwd_fifo;
    uvm_tlm_analysis_fifo#(s2m_ndr_seq_item)  host_s2m_ndr_fifo;
    uvm_tlm_analysis_fifo#(s2m_drs_seq_item)  host_s2m_drs_fifo;
    uvm_tlm_analysis_fifo#(s2m_ndr_seq_item)  dev_s2m_ndr_fifo;
    uvm_tlm_analysis_fifo#(s2m_drs_seq_item)  dev_s2m_drs_fifo;
    cxl_cfg_obj cxl_cfg_obj_h;

    function new(string name = "cxl_cm_scoreboard", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm scoreboard : %s", name), UVM_DEBUG)
      dev_h2d_req_fifo    = new("dev_h2d_req_fifo",   this);
      dev_h2d_rsp_fifo    = new("dev_h2d_rsp_fifo",   this);
      dev_h2d_data_fifo   = new("dev_h2d_data_fifo",  this);
      host_h2d_req_fifo   = new("host_h2d_req_fifo",  this);
      host_h2d_rsp_fifo   = new("host_h2d_rsp_fifo",  this);
      host_h2d_data_fifo  = new("host_h2d_data_fifo", this);
      dev_d2h_req_fifo    = new("dev_d2h_req_fifo",   this);
      dev_d2h_rsp_fifo    = new("dev_d2h_rsp_fifo",   this);
      dev_d2h_data_fifo   = new("dev_d2h_data_fifo",  this);
      host_d2h_req_fifo   = new("host_d2h_req_fifo",  this);
      host_d2h_rsp_fifo   = new("host_d2h_rsp_fifo",  this);
      host_d2h_data_fifo  = new("host_d2h_data_fifo", this);
      host_m2s_req_fifo   = new("host_m2s_req_fifo",  this);
      host_m2s_rwd_fifo   = new("host_m2s_rwd_fifo",  this);
      dev_m2s_req_fifo    = new("dev_m2s_req_fifo",   this);
      dev_m2s_rwd_fifo    = new("dev_m2s_rwd_fifo",   this);
      host_s2m_ndr_fifo   = new("host_s2m_ndr_fifo",  this);
      host_s2m_drs_fifo   = new("host_s2m_drs_fifo",  this);
      dev_s2m_ndr_fifo    = new("dev_s2m_ndr_fifo",   this);
      dev_s2m_drs_fifo    = new("dev_s2m_drs_fifo",   this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm scoreboard : %s", get_full_name()), UVM_HIGH)
    endfunction

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm scoreboard: %s", get_full_name()), UVM_HIGH)
      if(!uvm_resource_db#(cxl_cfg_obj)::read_by_name("", "cxl_cfg_obj_h", cxl_cfg_obj_h)) begin
        `uvm_fatal("CXL_CFG_OBJ", "cxl_cfg_obj not found")
      end
      fork
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) host_d2h_req();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) host_d2h_rsp();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) host_d2h_data();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) dev_d2h_req();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) dev_d2h_rsp();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) dev_d2h_data();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) host_h2d_req();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) host_h2d_rsp();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) host_h2d_data();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) dev_h2d_req();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) dev_h2d_rsp();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) dev_h2d_data();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) host_m2s_req();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) host_m2s_rwd();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) dev_m2s_req();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) dev_m2s_rwd();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) host_s2m_ndr();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) host_s2m_drs();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) dev_s2m_ndr();
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) dev_s2m_drs();
      join_none
      `uvm_info(get_type_name(), $sformatf("enter run_phase in uvm scoreboard: %s", get_full_name()), UVM_HIGH)
    endtask

    task dev_d2h_req();
      forever begin
        dev_d2h_req_fifo.get(dev_d2h_req_seq_item_h);
        dev_d2h_req_host_d2h_req_integ_aa[dev_d2h_req_seq_item_h.cqid] = dev_d2h_req_seq_item_h;
        if(dev_d2h_req_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_RDCURR}) begin
          d2h_req_h2d_data_aa[dev_d2h_req_seq_item_h.cqid] = dev_d2h_req_seq_item_h;
        end else begin
          d2h_req_h2d_rsp_aa[dev_d2h_req_seq_item_h.cqid] = dev_d2h_req_seq_item_h;
          if((cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1}) || (cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2} && cxl_cfg_obj_h.hdm inside {GEET_CXL_HDM_H})) begin
            if(dev_d2h_req_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_RDSHARED, GEET_CXL_CACHE_OPCODE_RDANY, GEET_CXL_CACHE_OPCODE_RDOWN}) begin
              d2h_req_h2d_data_aa[dev_d2h_req_seq_item_h.cqid] = dev_d2h_req_seq_item_h;
            end else if(dev_d2h_req_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_ITOMWR, GEET_CXL_CACHE_OPCODE_MEMWRI, GEET_CXL_CACHE_OPCODE_CLEANEVICT, GEET_CXL_CACHE_OPCODE_DIRTYEVICT, GEET_CXL_CACHE_OPCODE_WOWRINV, GEET_CXL_CACHE_OPCODE_WOWRINVF, GEET_CXL_CACHE_OPCODE_WRINV}) begin
            end else if(dev_d2h_req_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_CLFLUSH, GEET_CXL_CACHE_OPCODE_CACHEFLUSHED, GEET_CXL_CACHE_OPCODE_RDOWNNODATA, GEET_CXL_CACHE_OPCODE_CLEANEVICTNODATA}) begin
            end
          end else if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2} && cxl_cfg_obj_h.hdm inside {GEET_CXL_HDM_D}) begin
            if(dev_d2h_req_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_RDCURR, GEET_CXL_CACHE_OPCODE_RDSHARED, GEET_CXL_CACHE_OPCODE_RDANY, GEET_CXL_CACHE_OPCODE_RDOWN, GEET_CXL_CACHE_OPCODE_RDOWNNODATA, GEET_CXL_CACHE_OPCODE_CLFLUSH}) begin
              memrdfwd_aa[dev_d2h_req_seq_item_h.cqid] = dev_d2h_req_seq_item_h;
            end else if(dev_d2h_req_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_WOWRINV, GEET_CXL_CACHE_OPCODE_WOWRINVF}) begin
              memwrfwd_aa[dev_d2h_req_seq_item_h.cqid] = dev_d2h_req_seq_item_h;
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal opcode %0s for type 2 device bias mode %0s", dev_d2h_req_seq_item_h.opcode.name, cxl_cfg_obj_h.hdm.name()))
            end
          end
        end
      end
    endtask

    task dev_h2d_rsp();
      forever begin
        dev_h2d_rsp_fifo.get(dev_h2d_rsp_seq_item_h);
        if(host_h2d_rsp_dev_h2d_rsp_integ_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
          host_h2d_rsp_dev_h2d_rsp_integ_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
          `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
        end
        if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GOWRPULLDROP}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_CLEANEVICT}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              d2h_req_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GOWRITEPULL}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_ITOMWR, GEET_CXL_CACHE_OPCODE_MEMWRI, GEET_CXL_CACHE_OPCODE_CLEANEVICT, GEET_CXL_CACHE_OPCODE_DIRTYEVICT}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              h2d_rsp_d2h_data_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
              d2h_req_h2d_rsp_aa.delete(dev_d2h_req_seq_item_h.cqid);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_d2h_req_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_WRITEPULL}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_WRINV}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
              h2d_rsp_d2h_data_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
              d2h_req_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_FASTGOWRPULL}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_WOWRINV, GEET_CXL_CACHE_OPCODE_WOWRINVF}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
              h2d_rsp_d2h_data_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
              d2h_req_h2d_rsp_aa.delete(dev_d2h_req_seq_item_h.cqid);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_EXTCMP}) begin
          if(h2d_rsp_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_FASTGOWRPULL}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              h2d_rsp_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GO} && dev_h2d_rsp_seq_item_h.rspdata inside {GEET_CXL_CACHE_MESI_M}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_RDANY, GEET_CXL_CACHE_OPCODE_RDOWN}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              d2h_req_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          /*end else if(h2d_rsp_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_WRITEPULL}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
            h2d_rsp_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
        */end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GO} && dev_h2d_rsp_seq_item_h.rspdata inside {GEET_CXL_CACHE_MESI_E}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_RDANY, GEET_CXL_CACHE_OPCODE_RDOWN, GEET_CXL_CACHE_OPCODE_RDOWNNODATA}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              d2h_req_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          /*end else if(h2d_rsp_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_WRITEPULL}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
            h2d_rsp_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
        */end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GO} && dev_h2d_rsp_seq_item_h.rspdata inside {GEET_CXL_CACHE_MESI_S}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_RDANY, GEET_CXL_CACHE_OPCODE_RDSHARED}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              d2h_req_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          /*end else if(h2d_rsp_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_WRITEPULL}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
            h2d_rsp_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
        */end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GO} && dev_h2d_rsp_seq_item_h.rspdata inside {GEET_CXL_CACHE_MESI_I}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_RDANY, GEET_CXL_CACHE_OPCODE_RDSHARED, GEET_CXL_CACHE_OPCODE_CLFLUSH, GEET_CXL_CACHE_OPCODE_CACHEFLUSHED, GEET_CXL_CACHE_OPCODE_RDOWN, GEET_CXL_CACHE_OPCODE_CLEANEVICTNODATA}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              d2h_req_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
              h2d_rsp_h2d_errdata_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else if(h2d_rsp_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_WRITEPULL}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              h2d_rsp_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
              h2d_rsp_d2h_errdata_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GO} && dev_h2d_rsp_seq_item_h.rspdata inside {GEET_CXL_CACHE_MESI_ERR}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_RDANY, GEET_CXL_CACHE_OPCODE_RDSHARED, GEET_CXL_CACHE_OPCODE_CLFLUSH, GEET_CXL_CACHE_OPCODE_RDOWNNODATA, GEET_CXL_CACHE_OPCODE_RDOWN}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              d2h_req_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
              h2d_rsp_h2d_errdata_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else if(h2d_rsp_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_WRITEPULL}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              h2d_rsp_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
              h2d_rsp_d2h_errdata_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn h2d_rsp_opcode %0s and h2d_rsp_opcode %0s", h2d_rsp_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end else if(dev_h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GOERRWRPULL}) begin
          if(d2h_req_h2d_rsp_aa.exists(dev_h2d_rsp_seq_item_h.cqid)) begin
            `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_rsp_seq_item_h.cqid), UVM_NONE);
            if(d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_ITOMWR, GEET_CXL_CACHE_OPCODE_MEMWRI, GEET_CXL_CACHE_OPCODE_DIRTYEVICT, GEET_CXL_CACHE_OPCODE_WOWRINV, GEET_CXL_CACHE_OPCODE_WOWRINVF}) begin
              `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()), UVM_NONE);
              d2h_req_h2d_rsp_aa.delete(dev_h2d_rsp_seq_item_h.cqid);
              h2d_rsp_d2h_errdata_aa[dev_h2d_rsp_seq_item_h.cqid] = dev_h2d_rsp_seq_item_h;
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s and h2d_rsp_opcode %0s", d2h_req_h2d_rsp_aa[dev_h2d_rsp_seq_item_h.cqid].opcode.name(), dev_h2d_rsp_seq_item_h.opcode.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_rsp_seq_item_h.cqid));
          end
        end
      end
    endtask
    
    task dev_h2d_data();
      forever begin
        dev_h2d_data_fifo.get(dev_h2d_data_seq_item_h);
        if(host_h2d_data_dev_h2d_data_integ_aa.exists(dev_h2d_data_seq_item_h.cqid)) begin
          host_h2d_data_dev_h2d_data_integ_aa.delete(dev_h2d_data_seq_item_h.cqid);
          `uvm_info(get_type_name(), $sformatf("cqid = %0h match sent from the other side", dev_h2d_data_seq_item_h.cqid), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with cqid = %0h not sent from the other side", dev_h2d_data_seq_item_h.cqid));
        end
        if(d2h_req_h2d_data_aa.exists(dev_h2d_data_seq_item_h.cqid)) begin
          if(d2h_req_h2d_data_aa[dev_h2d_data_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_RDCURR, GEET_CXL_CACHE_OPCODE_RDSHARED, GEET_CXL_CACHE_OPCODE_RDANY, GEET_CXL_CACHE_OPCODE_RDOWN}) begin
            `uvm_info(get_type_name(), $sformatf("legal txn d2h_req_opcode %0s", d2h_req_h2d_data_aa[dev_h2d_data_seq_item_h.cqid].opcode.name()), UVM_NONE);
            d2h_req_h2d_data_aa.delete(dev_h2d_data_seq_item_h.cqid);
          end else begin
            `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s", d2h_req_h2d_data_aa[dev_h2d_data_seq_item_h.cqid].opcode.name()));
          end 
        end else if(h2d_rsp_h2d_errdata_aa.exists(dev_h2d_data_seq_item_h.cqid)) begin
          if((h2d_rsp_h2d_errdata_aa[dev_h2d_data_seq_item_h.cqid].opcode inside {GEET_CXL_CACHE_OPCODE_GO}) && (h2d_rsp_h2d_errdata_aa[dev_h2d_data_seq_item_h.cqid].rspdata inside {GEET_CXL_CACHE_MESI_I, GEET_CXL_CACHE_MESI_ERR}) && (dev_h2d_data_seq_item_h.data == 512'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff)) begin
            `uvm_info(get_type_name(), $sformatf("legal txn h2d_rsp_opcode %0s with all 1s data", h2d_rsp_h2d_errdata_aa[dev_h2d_data_seq_item_h.cqid].opcode.name()), UVM_NONE);
            h2d_rsp_h2d_errdata_aa.delete(dev_h2d_data_seq_item_h.cqid);
          end else begin
            `uvm_error(get_type_name(), $sformatf("illegal txn d2h_req_opcode %0s", h2d_rsp_h2d_errdata_aa[dev_h2d_data_seq_item_h.cqid].opcode.name()));
          end 
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", dev_h2d_data_seq_item_h.cqid));
        end
      end
    endtask

    task host_d2h_data();
      forever begin
        host_d2h_data_fifo.get(host_d2h_data_seq_item_h);
        if(dev_d2h_data_host_d2h_data_integ_aa.exists(host_d2h_data_seq_item_h.uqid)) begin
          dev_d2h_data_host_d2h_data_integ_aa.delete(host_d2h_data_seq_item_h.uqid);
          `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", host_d2h_data_seq_item_h.uqid), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not ent from the other side", host_d2h_data_seq_item_h.uqid));
        end
        if(h2d_rsp_d2h_data_aa.exists(host_d2h_data_seq_item_h.uqid)) begin
          if(h2d_rsp_d2h_data_aa[host_d2h_data_seq_item_h.uqid].opcode inside{GEET_CXL_CACHE_OPCODE_WRITEPULL, GEET_CXL_CACHE_OPCODE_GOWRITEPULL, GEET_CXL_CACHE_OPCODE_FASTGOWRPULL}) begin
            `uvm_info(get_type_name(), $sformatf("match txn h2d_rsp_opcode %0s", h2d_rsp_d2h_data_aa[host_d2h_data_seq_item_h.uqid].opcode.name()), UVM_NONE);
            h2d_rsp_d2h_data_aa.delete(host_d2h_data_seq_item_h.uqid);
          end else begin
            `uvm_error(get_type_name(), $sformatf("illegal txn h2d_rsp_opcode %0s", h2d_rsp_d2h_data_aa[host_d2h_data_seq_item_h.uqid].opcode.name()));
          end
        end else if(h2d_rsp_d2h_errdata_aa.exists(host_d2h_data_seq_item_h.uqid)) begin
          if(h2d_rsp_d2h_errdata_aa[host_d2h_data_seq_item_h.uqid].opcode inside{GEET_CXL_CACHE_OPCODE_GOERRWRPULL}) begin
            `uvm_info(get_type_name(), $sformatf("match txn h2d_rsp_opcode %0s", h2d_rsp_d2h_errdata_aa[host_d2h_data_seq_item_h.uqid].opcode.name()), UVM_NONE);
            h2d_rsp_d2h_errdata_aa.delete(host_d2h_data_seq_item_h.uqid);
          end else begin
            `uvm_error(get_type_name(), $sformatf("illegal txn h2d_rsp_opcode %0s", h2d_rsp_d2h_errdata_aa[host_d2h_data_seq_item_h.uqid].opcode.name()));
          end
        end else if(h2d_req_d2h_data_aa.exists(host_d2h_data_seq_item_h.uqid)) begin
          `uvm_info(get_type_name(), $sformatf("match txn h2d_req_opcode %0s", h2d_req_d2h_data_aa[host_d2h_data_seq_item_h.uqid].opcode.name()), UVM_NONE);
          h2d_req_d2h_data_aa.delete(host_d2h_data_seq_item_h.uqid);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not sent from the other side", host_d2h_data_seq_item_h.uqid));
        end
      end
    endtask

    task host_h2d_rsp();
      forever begin
        host_h2d_rsp_fifo.get(host_h2d_rsp_seq_item_h);
        host_h2d_rsp_dev_h2d_rsp_integ_aa[host_h2d_rsp_seq_item_h.cqid] = host_h2d_rsp_seq_item_h;
      end
    endtask

    task host_h2d_data();
      forever begin
        host_h2d_data_fifo.get(host_h2d_data_seq_item_h);
        host_h2d_data_dev_h2d_data_integ_aa[host_h2d_data_seq_item_h.cqid] = host_h2d_data_seq_item_h;
      end
    endtask

    task dev_d2h_rsp();
      forever begin
        dev_d2h_rsp_fifo.get(dev_d2h_rsp_seq_item_h);
        dev_d2h_rsp_host_d2h_rsp_integ_aa[dev_d2h_rsp_seq_item_h.uqid] = dev_d2h_rsp_seq_item_h;
      end
    endtask

    task dev_d2h_data();
      forever begin
        dev_d2h_data_fifo.get(dev_d2h_data_seq_item_h);
        dev_d2h_data_host_d2h_data_integ_aa[dev_d2h_data_seq_item_h.uqid] = dev_d2h_data_seq_item_h;
      end
    endtask

    task host_h2d_req();
      forever begin
        host_h2d_req_fifo.get(host_h2d_req_seq_item_h);
        host_h2d_req_dev_h2d_req_integ_aa[host_h2d_req_seq_item_h.uqid] = host_h2d_req_seq_item_h;
        h2d_req_d2h_rsp_aa[host_h2d_req_seq_item_h.uqid] = host_h2d_req_seq_item_h;
        h2d_req_d2h_data_aa[host_h2d_req_seq_item_h.uqid] = host_h2d_req_seq_item_h;
      end
    endtask

    task dev_h2d_req();
      forever begin
        dev_h2d_req_fifo.get(dev_h2d_req_seq_item_h);
        if(host_h2d_req_dev_h2d_req_integ_aa.exists(dev_h2d_req_seq_item_h.uqid)) begin
          host_h2d_req_dev_h2d_req_integ_aa.delete(dev_h2d_req_seq_item_h.uqid);
          `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", dev_h2d_req_seq_item_h.uqid), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not ent from the other side", dev_h2d_req_seq_item_h.uqid));
        end
      end
    endtask

    task host_d2h_req();
      forever begin
        host_d2h_req_fifo.get(host_d2h_req_seq_item_h);
        if(dev_d2h_req_host_d2h_req_integ_aa.exists(host_d2h_req_seq_item_h.cqid)) begin
          dev_d2h_req_host_d2h_req_integ_aa.delete(host_d2h_req_seq_item_h.cqid);
          `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", host_d2h_req_seq_item_h.cqid), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not ent from the other side", host_d2h_req_seq_item_h.cqid));
        end
      end
    endtask

    task host_d2h_rsp();
      forever begin
        host_d2h_rsp_fifo.get(host_d2h_rsp_seq_item_h);
        if(dev_d2h_rsp_host_d2h_rsp_integ_aa.exists(host_d2h_rsp_seq_item_h.uqid)) begin
          dev_d2h_rsp_host_d2h_rsp_integ_aa.delete(host_d2h_rsp_seq_item_h.uqid);
          `uvm_info(get_type_name(), $sformatf("uqid = %0h match sent from the other side", host_d2h_rsp_seq_item_h.uqid), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with uqid = %0h not ent from the other side", host_d2h_rsp_seq_item_h.uqid));
        end
        if(h2d_req_d2h_rsp_aa.exists(host_d2h_rsp_seq_item_h.uqid)) begin
          if(host_d2h_rsp_seq_item_h.opcode inside{GEET_CXL_CACHE_OPCODE_RSPIHITI} && h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode inside {GEET_CXL_CACHE_OPCODE_SNPDATA,GEET_CXL_CACHE_OPCODE_SNPCURR, GEET_CXL_CACHE_OPCODE_SNPINV}) begin
            `uvm_info(get_type_name(), $sformatf("legal combination match: d2h rsp opcode is %0s h2d req opcode is %0s", host_d2h_rsp_seq_item_h.opcode.name(), h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode.name()), UVM_NONE);  
          end else if(host_d2h_rsp_seq_item_h.opcode inside{GEET_CXL_CACHE_OPCODE_RSPVHITV} && h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode inside {GEET_CXL_CACHE_OPCODE_SNPCURR}) begin
            `uvm_info(get_type_name(), $sformatf("legal combination match: d2h rsp opcode is %0s h2d req opcode is %0s", host_d2h_rsp_seq_item_h.opcode.name(), h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode.name()), UVM_NONE);  
          end else if(host_d2h_rsp_seq_item_h.opcode inside{GEET_CXL_CACHE_OPCODE_RSPSHITSE} && h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode inside {GEET_CXL_CACHE_OPCODE_SNPDATA, GEET_CXL_CACHE_OPCODE_SNPCURR}) begin
            `uvm_info(get_type_name(), $sformatf("legal combination match: d2h rsp opcode is %0s h2d req opcode is %0s", host_d2h_rsp_seq_item_h.opcode.name(), h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode.name()), UVM_NONE);  
          end else if(host_d2h_rsp_seq_item_h.opcode inside{GEET_CXL_CACHE_OPCODE_RSPIHITSE} && h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode inside {GEET_CXL_CACHE_OPCODE_SNPINV}) begin
            `uvm_info(get_type_name(), $sformatf("legal combination match: d2h rsp opcode is %0s h2d req opcode is %0s", host_d2h_rsp_seq_item_h.opcode.name(), h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode.name()), UVM_NONE);  
          end else if(host_d2h_rsp_seq_item_h.opcode inside{GEET_CXL_CACHE_OPCODE_RSPSFWDM} && h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode inside {GEET_CXL_CACHE_OPCODE_SNPDATA, GEET_CXL_CACHE_OPCODE_SNPCURR}) begin
            `uvm_info(get_type_name(), $sformatf("legal combination match: d2h rsp opcode is %0s h2d req opcode is %0s", host_d2h_rsp_seq_item_h.opcode.name(), h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode.name()), UVM_NONE);  
          end else if(host_d2h_rsp_seq_item_h.opcode inside{GEET_CXL_CACHE_OPCODE_RSPIFWDM} && h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode inside {GEET_CXL_CACHE_OPCODE_SNPDATA, GEET_CXL_CACHE_OPCODE_SNPINV, GEET_CXL_CACHE_OPCODE_SNPCURR}) begin
            `uvm_info(get_type_name(), $sformatf("legal combination match: d2h rsp opcode is %0s h2d req opcode is %0s", host_d2h_rsp_seq_item_h.opcode.name(), h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode.name()), UVM_NONE);  
          end else if(host_d2h_rsp_seq_item_h.opcode inside{GEET_CXL_CACHE_OPCODE_RSPVFWDV} && h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode inside {GEET_CXL_CACHE_OPCODE_SNPCURR}) begin
            `uvm_info(get_type_name(), $sformatf("legal combination match: d2h rsp opcode is %0s h2d req opcode is %0s", host_d2h_rsp_seq_item_h.opcode.name(), h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode.name()), UVM_NONE);  
          end else begin
            `uvm_error(get_type_name(), $sformatf("mismatch illegal combination: d2h rsp opcode is %0s h2d req opcode is %0s", host_d2h_rsp_seq_item_h.opcode.name(), h2d_req_d2h_rsp_aa[host_d2h_rsp_seq_item_h.uqid].opcode.name()));  
          end
        end
      end
    endtask

    task host_m2s_req();
      forever begin
        host_m2s_req_fifo.get(host_m2s_req_seq_item_h);
        host_m2s_req_dev_m2s_req_integ_aa[host_m2s_req_seq_item_h.tag] = host_m2s_req_seq_item_h;
      end
    endtask

    task host_m2s_rwd();
      forever begin
        host_m2s_rwd_fifo.get(host_m2s_rwd_seq_item_h);
        host_m2s_rwd_dev_m2s_rwd_integ_aa[host_m2s_rwd_seq_item_h.tag] = host_m2s_rwd_seq_item_h;
      end
    endtask

    task dev_s2m_ndr();
      forever begin
        dev_s2m_ndr_fifo.get(dev_s2m_ndr_seq_item_h);
        dev_s2m_ndr_host_s2m_ndr_integ_aa[dev_s2m_ndr_seq_item_h.tag] = dev_s2m_ndr_seq_item_h;
      end
    endtask

    task dev_s2m_drs();
      forever begin
        dev_s2m_drs_fifo.get(dev_s2m_drs_seq_item_h);
        dev_s2m_drs_host_s2m_drs_integ_aa[dev_s2m_drs_seq_item_h.tag] = dev_s2m_drs_seq_item_h;
      end
    endtask

    task dev_m2s_req();
      forever begin
        dev_m2s_req_fifo.get(dev_m2s_req_seq_item_h);
        if(host_m2s_req_dev_m2s_req_integ_aa.exists(dev_m2s_req_seq_item_h.tag)) begin
          host_m2s_req_dev_m2s_req_integ_aa.delete(dev_m2s_req_seq_item_h.tag);
          `uvm_info(get_type_name(), $sformatf("tag = %0h match sent from the other side", dev_m2s_req_seq_item_h.tag), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with tag = %0h not sent from the other side", dev_m2s_rwd_seq_item_h.tag));
        end
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2} && cxl_cfg_obj_h.hdm inside {GEET_CXL_HDM_D}) begin
          if(memrdfwd_aa.exists(dev_m2s_req_seq_item_h.tag)) begin
            `uvm_info(get_type_name(), $sformatf("matching tag for rd forward flows with uqid tag match = %0h", dev_m2s_req_seq_item_h.tag), UVM_NONE);
            if((memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode inside {GEET_CXL_CACHE_OPCODE_RDCURR}) && (dev_m2s_req_seq_item_h.metavalue inside {GEET_CXL_MEM_MV_METAVALUE_ANY, GEET_CXL_MEM_MV_METAVALUE_SHARED, GEET_CXL_MEM_MV_METAVALUE_INVALID})) begin
              `uvm_info(get_type_name(), $sformatf("legal combination for opcode %0s and metavalue %0s", memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode.name(), dev_m2s_req_seq_item_h.metavalue.name()), UVM_NONE);
              memrdfwd_aa.delete(dev_m2s_req_seq_item_h.tag);
            end else if((memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode inside {GEET_CXL_CACHE_OPCODE_RDSHARED, GEET_CXL_CACHE_OPCODE_RDANY}) && (dev_m2s_req_seq_item_h.metavalue inside {GEET_CXL_MEM_MV_METAVALUE_SHARED, GEET_CXL_MEM_MV_METAVALUE_INVALID})) begin
              `uvm_info(get_type_name(), $sformatf("legal combination for opcode %0s and metavalue %0s", memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode.name(), dev_m2s_req_seq_item_h.metavalue.name()), UVM_NONE);
              memrdfwd_aa.delete(dev_m2s_req_seq_item_h.tag);
            end else if((memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode inside {GEET_CXL_CACHE_OPCODE_RDOWN, GEET_CXL_CACHE_OPCODE_RDOWNNODATA, GEET_CXL_CACHE_OPCODE_CLFLUSH}) && (dev_m2s_req_seq_item_h.metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID})) begin
              `uvm_info(get_type_name(), $sformatf("legal combination for opcode %0s and metavalue %0s", memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode.name(), dev_m2s_req_seq_item_h.metavalue.name()), UVM_NONE);
              memrdfwd_aa.delete(dev_m2s_req_seq_item_h.tag);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal combination for opcode %0s and metavalue %0s", memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode.name(), dev_m2s_req_seq_item_h.metavalue.name()));
            end
          end else if(memwrfwd_aa.exists(dev_m2s_req_seq_item_h.tag)) begin
            `uvm_info(get_type_name(), $sformatf("matching tag for wr forward flows with uqid tag match = %0h", dev_m2s_req_seq_item_h.tag), UVM_NONE);
            if((memwrfwd_aa[dev_m2s_req_seq_item_h.tag].opcode inside {GEET_CXL_CACHE_OPCODE_WOWRINV, GEET_CXL_CACHE_OPCODE_WOWRINVF}) && (dev_m2s_req_seq_item_h.metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID})) begin
              `uvm_info(get_type_name(), $sformatf("legal combination for opcode %0s and metavalue %0s", memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode.name(), dev_m2s_req_seq_item_h.metavalue.name()), UVM_NONE);
              memwrfwd_aa.delete(dev_m2s_req_seq_item_h.tag);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal combination for opcode %0s and metavalue %0s", memrdfwd_aa[dev_m2s_req_seq_item_h.tag].opcode.name(), dev_m2s_req_seq_item_h.metavalue.name()));
            end
          end else begin
            `uvm_error(get_type_name(), $sformatf("spurious txn with tag= %0h not sent from the other side", dev_m2s_req_seq_item_h.tag));
          end
        end
      end
      m2s_req_s2m_ndr_aa[dev_m2s_req_seq_item_h.tag] = dev_m2s_req_seq_item_h;
      m2s_req_s2m_drs_aa[dev_m2s_req_seq_item_h.tag] = dev_m2s_req_seq_item_h;
    endtask

    task dev_m2s_rwd();
      forever begin
        dev_m2s_rwd_fifo.get(dev_m2s_rwd_seq_item_h);
        if(host_m2s_rwd_dev_m2s_rwd_integ_aa.exists(dev_m2s_rwd_seq_item_h.tag)) begin
          host_m2s_rwd_dev_m2s_rwd_integ_aa.delete(dev_m2s_rwd_seq_item_h.tag);
          `uvm_info(get_type_name(), $sformatf("tag = %0h match sent from the other side", dev_m2s_rwd_seq_item_h.tag), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with tag = %0h not sent from the other side", dev_m2s_rwd_seq_item_h.tag));
        end
        m2s_rwd_s2m_ndr_aa[dev_m2s_rwd_seq_item_h.tag] = dev_m2s_rwd_seq_item_h;
      end
    endtask

    task host_s2m_ndr();
      forever begin
        host_s2m_ndr_fifo.get(host_s2m_ndr_seq_item_h);
        if(dev_s2m_ndr_host_s2m_ndr_integ_aa.exists(host_s2m_ndr_seq_item_h.tag)) begin
          dev_s2m_ndr_host_s2m_ndr_integ_aa.delete(host_s2m_ndr_seq_item_h.tag);
          `uvm_info(get_type_name(), $sformatf("tag = %0h match sent from the other side", host_s2m_ndr_seq_item_h.tag), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with tag = %0h not sent from the other side", host_s2m_ndr_seq_item_h.tag));
        end
        if(m2s_rwd_s2m_ndr_aa.exists(host_s2m_ndr_seq_item_h.tag)) begin
          `uvm_info(get_type_name(), $sformatf("tag match %0h m2s rwd opcode %0s s2m ndr opcode %0s", host_s2m_ndr_seq_item_h.tag, m2s_rwd_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode.name(), host_s2m_ndr_seq_item_h.opcode.name()),UVM_NONE)
          if(host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMP} && host_s2m_ndr_seq_item_h.metafield inside {GEET_CXL_MEM_MF_METAFIELD_NOOP}) begin
            `uvm_info(get_type_name(), $sformatf("legal combination of s2m ndr opcode %0s and metafield %0s", host_s2m_ndr_seq_item_h.opcode.name(), host_s2m_ndr_seq_item_h.metafield.name()), UVM_NONE);
            m2s_rwd_s2m_ndr_aa.delete(host_s2m_ndr_seq_item_h.tag);
          end else begin
            `uvm_error(get_type_name(), $sformatf("illegal combination of s2m ndr opcode %0s and metafield %0s", host_s2m_ndr_seq_item_h.opcode.name(), host_s2m_ndr_seq_item_h.metafield.name()));
          end
        end else if(m2s_req_s2m_ndr_aa.exists(host_s2m_ndr_seq_item_h.tag)) begin
          `uvm_info(get_type_name(), $sformatf("tag match %0h m2s rwd opcode %0s s2m ndr opcode %0s", host_s2m_ndr_seq_item_h.tag, m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode.name(), host_s2m_ndr_seq_item_h.opcode.name()),UVM_NONE);
          if((cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3})) begin
            if(
                (
                  (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMINV, GEET_CXL_MEM_OPCODE_MEMINVNT}) && 
                  (
                    (
                      (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metafield inside {GEET_CXL_MEM_MF_METAFIELD_META0STATE}) && 
                      (
                        ((m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_ANY}) && (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMPE})) ||
                        ((m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_SHARED}) && (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMPS})) ||
                        ((m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID}) && (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMP}))
                      )
                    ) || 
                    (
                      (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metafield inside {GEET_CXL_MEM_MF_METAFIELD_NOOP}) && (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMP})
                    )
                  )  
                ) || (
                  (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDDATA}) && 
                  (
                    (
                      (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metafield inside {GEET_CXL_MEM_MF_METAFIELD_META0STATE}) && 
                      (
                        (
                          (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_CMPE})  &&
                          (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_ANY}) && 
                          (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID})
                        ) || (
                          (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMPS})  &&
                          (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_SHARED}) 
                        )
                      )
                    ) || (
                      (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metafield inside {GEET_CXL_MEM_MF_METAFIELD_NOOP}) && 
                      ( 
                        (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_CMPS, GEET_CXL_MEM_OPCODE_CMPE})
                      )
                    )
                  )
                ) || (
                  (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD}) &&
                  (
                    ((m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metafield inside {GEET_CXL_MEM_MF_METAFIELD_NOOP}) && (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMP})) ||
                    (
                      (m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metafield inside {GEET_CXL_MEM_MF_METAFIELD_META0STATE}) && 
                      (
                        ((m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_ANY}) && (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMPE})) || 
                        ((m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_SHARED}) && (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMPS, GEET_CXL_MEM_OPCODE_CMPE})) || 
                        ((m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID}) && (host_s2m_ndr_seq_item_h.opcode inside {GEET_CXL_MEM_OPCODE_CMP}))
                      )
                    )
                  )
                )  
              ) begin
              `uvm_info(get_type_name(), $sformatf("legal combination for type 3 %0s opcode %0s", cxl_cfg_obj_h.cxl_type.name(), m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode.name()), UVM_NONE);
              m2s_req_s2m_ndr_aa.delete(host_s2m_ndr_seq_item_h.tag);
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal combination of s2m ndr opcode %0s and metafield %0s", host_s2m_ndr_seq_item_h.opcode.name(), host_s2m_ndr_seq_item_h.metafield.name()));
            end
          end else if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2}) begin
          end else begin
            `uvm_error(get_type_name(), $sformatf("invalid opcode %0s", m2s_req_s2m_ndr_aa[host_s2m_ndr_seq_item_h.tag].memopcode.name()));
          end
        end else begin
          `uvm_error(get_type_name(), $sformatf("no matching tag s2m ndr txn with tag %0h", host_s2m_ndr_seq_item_h.tag));
        end
      end
    endtask

    task host_s2m_drs();
      forever begin
        host_s2m_drs_fifo.get(host_s2m_drs_seq_item_h);
        if(dev_s2m_drs_host_s2m_drs_integ_aa.exists(host_s2m_drs_seq_item_h.tag)) begin
          dev_s2m_drs_host_s2m_drs_integ_aa.delete(host_s2m_drs_seq_item_h.tag);
          `uvm_info(get_type_name(), $sformatf("tag = %0h match sent from the other side", host_s2m_drs_seq_item_h.tag), UVM_NONE);
        end else begin
          `uvm_error(get_type_name(), $sformatf("spurious txn with tag = %0h not sent from the other side", host_s2m_drs_seq_item_h.tag));
        end
        if(m2s_req_s2m_drs_aa.exists(host_s2m_drs_seq_item_h.tag)) begin
          `uvm_info(get_type_name(), $sformatf("tag match %0h m2s req opcode %0s s2m drs opcode %0s", host_s2m_drs_seq_item_h.tag, m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode.name(), host_s2m_drs_seq_item_h.opcode.name()),UVM_NONE);
          if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3}) begin
            if(m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD, GEET_CXL_MEM_OPCODE_MEMRDDATA}) begin
              if(
                  (m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD}) || 
                  (
                    (m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDDATA}) && 
                    (
                      (
                        (host_s2m_drs_seq_item_h.metafield inside {GEET_CXL_MEM_MF_METAFIELD_META0STATE}) && (host_s2m_drs_seq_item_h.metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID, GEET_CXL_MEM_MV_METAVALUE_SHARED, GEET_CXL_MEM_MV_METAVALUE_ANY})
                      ) || 
                      ( 
                        host_s2m_drs_seq_item_h.metafield inside {GEET_CXL_MEM_MF_METAFIELD_NOOP}
                      )
                    )
                  )
                ) begin
                `uvm_info(get_type_name(), $sformatf("legal combination for type 3 %0s m2s req", cxl_cfg_obj_h.cxl_type.name()), UVM_NONE);
                m2s_req_s2m_drs_aa.delete(host_s2m_drs_seq_item_h.tag);
              end else begin
                `uvm_error(get_type_name(), $sformatf("illegal combination for type 3 %0s m2s req", cxl_cfg_obj_h.cxl_type.name()))
              end
            end else begin
              `uvm_error(get_type_name(), $sformatf("illegal opcode %0s for type 3 %0s m2s req", m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode.name(), cxl_cfg_obj_h.cxl_type.name()))
            end
          end else if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2}) begin
            if(m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD, GEET_CXL_MEM_OPCODE_MEMRDDATA}) begin
              if(
                  (m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD}) || 
                  (
                    (m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDDATA}) && 
                    (
                      (
                        ((host_s2m_drs_seq_item_h.metafield inside {GEET_CXL_MEM_MF_METAFIELD_META0STATE}) && (host_s2m_drs_seq_item_h.metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID, GEET_CXL_MEM_MV_METAVALUE_SHARED, GEET_CXL_MEM_MV_METAVALUE_ANY})) || 
                        ( host_s2m_drs_seq_item_h.metafield inside {GEET_CXL_MEM_MF_METAFIELD_NOOP})
                      )
                    )
                  )
                ) begin
                `uvm_info(get_type_name(), $sformatf("legal combination for type 2 %0s m2s req", cxl_cfg_obj_h.cxl_type.name()), UVM_NONE)
                m2s_req_s2m_drs_aa.delete(host_s2m_drs_seq_item_h.tag);
              end else begin
                `uvm_error(get_type_name(), $sformatf("illegal combination for type 2 %0s m2s req", cxl_cfg_obj_h.cxl_type.name()))
              end
            end else begin  
              `uvm_error(get_type_name(), $sformatf("illegal opcode %0s for type 2 %0s m2s req", m2s_req_s2m_drs_aa[host_s2m_drs_seq_item_h.tag].memopcode.name(), cxl_cfg_obj_h.cxl_type.name()))
            end
          end
        end else begin
          `uvm_error(get_type_name(), $sformatf("missing tag s2m drs opcode %0h", host_s2m_drs_seq_item_h.tag));
        end
      end
    endtask

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
    host_m2s_rwd_sequencer      host_m2s_rwd_seqr;
    host_s2m_ndr_sequencer      host_s2m_ndr_seqr;
    host_s2m_drs_sequencer      host_s2m_drs_seqr;
    dev_d2h_req_sequencer       dev_d2h_req_seqr;
    dev_d2h_rsp_sequencer       dev_d2h_rsp_seqr;
    dev_d2h_data_sequencer      dev_d2h_data_seqr;
    dev_h2d_req_sequencer       dev_h2d_req_seqr;
    dev_h2d_rsp_sequencer       dev_h2d_rsp_seqr;
    dev_h2d_data_sequencer      dev_h2d_data_seqr;
    dev_m2s_req_sequencer       dev_m2s_req_seqr;
    dev_m2s_rwd_sequencer       dev_m2s_rwd_seqr;
    dev_s2m_ndr_sequencer       dev_s2m_ndr_seqr;
    dev_s2m_drs_sequencer       dev_s2m_drs_seqr;
    cxl_cfg_obj                 cxl_cfg_obj_h;

    function new(string name = "cxl_cm_vsequencer", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm virtual sequencer : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm virtual sequencer : %s", get_full_name()), UVM_HIGH)
      if(!uvm_resource_db#(cxl_cfg_obj)::read_by_name("", "cxl_cfg_obj_h", cxl_cfg_obj_h)) begin
        `uvm_fatal("CXL_CFG_OBJ", "cxl_cfg_obj not found")
      end
      if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
        dev_d2h_req_seqr    = dev_d2h_req_sequencer::type_id::create("dev_d2h_req_seqr", this);
        dev_d2h_rsp_seqr    = dev_d2h_rsp_sequencer::type_id::create("dev_d2h_rsp_seqr", this);
        dev_d2h_data_seqr   = dev_d2h_data_sequencer::type_id::create("dev_d2h_data_seqr", this);
        dev_h2d_req_seqr    = dev_h2d_req_sequencer::type_id::create("dev_h2d_req_seqr", this);
        dev_h2d_rsp_seqr    = dev_h2d_rsp_sequencer::type_id::create("dev_h2d_rsp_seqr", this);
        dev_h2d_data_seqr   = dev_h2d_data_sequencer::type_id::create("dev_h2d_data_seqr", this);
        host_d2h_req_seqr   = host_d2h_req_sequencer::type_id::create("host_d2h_req_seqr", this);
        host_d2h_rsp_seqr   = host_d2h_rsp_sequencer::type_id::create("host_d2h_rsp_seqr", this);
        host_d2h_data_seqr  = host_d2h_data_sequencer::type_id::create("host_d2h_data_seqr", this);
        host_h2d_req_seqr   = host_h2d_req_sequencer::type_id::create("host_h2d_req_seqr", this);
        host_h2d_rsp_seqr   = host_h2d_rsp_sequencer::type_id::create("host_h2d_rsp_seqr", this);
        host_h2d_data_seqr  = host_h2d_data_sequencer::type_id::create("host_h2d_data_seqr", this);
      end  
      if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2, GEET_CXL_TYPE_3}) begin
        host_m2s_req_seqr   = host_m2s_req_sequencer::type_id::create("host_m2s_req_seqr", this);
        host_m2s_rwd_seqr   = host_m2s_rwd_sequencer::type_id::create("host_m2s_rwd_seqr", this);
        host_s2m_ndr_seqr   = host_s2m_ndr_sequencer::type_id::create("host_s2m_ndr_seqr", this);
        host_s2m_drs_seqr   = host_s2m_drs_sequencer::type_id::create("host_s2m_drs_seqr", this);
        dev_m2s_req_seqr    = dev_m2s_req_sequencer::type_id::create("dev_m2s_req_seqr", this);
        dev_m2s_rwd_seqr    = dev_m2s_rwd_sequencer::type_id::create("dev_m2s_rwd_seqr", this);
        dev_s2m_ndr_seqr    = dev_s2m_ndr_sequencer::type_id::create("dev_s2m_ndr_seqr", this);
        dev_s2m_drs_seqr    = dev_s2m_drs_sequencer::type_id::create("dev_s2m_drs_seqr", this);
      end
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm virtual sequencer : %s", get_full_name()), UVM_HIGH)
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
    cxl_cm_scoreboard       cxl_cm_scoreboard_h;
    cxl_cfg_obj             cxl_cfg_obj_h;

    function new(string name = "cxl_cm_env", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructed uvm environment : %s", name), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter build_phase in uvm environment : %s", get_full_name()), UVM_HIGH)
      cxl_cfg_obj_h         = cxl_cfg_obj::type_id::create("cxl_cfg_obj_h", this);
      if(cxl_cfg_obj_h.randomize() == 0) begin
        `uvm_fatal("CXL_CFG_OBJ", $sformatf("cxl_cfg_obj randomization failed"))
      end;
      `uvm_info(get_type_name(), $sformatf("cxl_cfg_obj_h addr = %0p", cxl_cfg_obj_h), UVM_NONE)
      uvm_resource_db#(cxl_cfg_obj)::set("*", "cxl_cfg_obj_h", cxl_cfg_obj_h);
      if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
        host_d2h_req_agent_h  = host_d2h_req_agent::type_id::create("host_d2h_req_agent_h", this);
        host_d2h_rsp_agent_h  = host_d2h_rsp_agent::type_id::create("host_d2h_rsp_agent_h", this);
        host_d2h_data_agent_h = host_d2h_data_agent::type_id::create("host_d2h_data_agent_h", this);
        dev_h2d_req_agent_h   = dev_h2d_req_agent::type_id::create("dev_h2d_req_agent_h", this);
        dev_h2d_rsp_agent_h   = dev_h2d_rsp_agent::type_id::create("dev_h2d_rsp_agent_h", this);
        dev_h2d_data_agent_h  = dev_h2d_data_agent::type_id::create("dev_h2d_data_agent_h", this);
        dev_d2h_req_agent_h   = dev_d2h_req_agent::type_id::create("dev_d2h_req_agent_h", this);
        dev_d2h_rsp_agent_h   = dev_d2h_rsp_agent::type_id::create("dev_d2h_rsp_agent_h", this);
        dev_d2h_data_agent_h  = dev_d2h_data_agent::type_id::create("dev_d2h_data_agent_h", this);
        host_h2d_req_agent_h  = host_h2d_req_agent::type_id::create("host_h2d_req_agent_h", this);
        host_h2d_rsp_agent_h  = host_h2d_rsp_agent::type_id::create("host_h2d_rsp_agent_h", this);
        host_h2d_data_agent_h = host_h2d_data_agent::type_id::create("host_h2d_data_agent_h", this);
      end
      if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2, GEET_CXL_TYPE_3}) begin
        host_m2s_req_agent_h  = host_m2s_req_agent::type_id::create("host_m2s_req_agent_h", this);
        host_m2s_rwd_agent_h  = host_m2s_rwd_agent::type_id::create("host_m2s_rwd_agent_h", this);
        dev_s2m_ndr_agent_h   = dev_s2m_ndr_agent::type_id::create("dev_s2m_ndr_agent_h", this);
        dev_s2m_drs_agent_h   = dev_s2m_drs_agent::type_id::create("dev_s2m_drs_agent_h", this);
        dev_m2s_req_agent_h   = dev_m2s_req_agent::type_id::create("dev_m2s_req_agent_h", this);
        dev_m2s_rwd_agent_h   = dev_m2s_rwd_agent::type_id::create("dev_m2s_rwd_agent_h", this);
        host_s2m_ndr_agent_h  = host_s2m_ndr_agent::type_id::create("host_s2m_ndr_agent_h", this);
        host_s2m_drs_agent_h  = host_s2m_drs_agent::type_id::create("host_s2m_drs_agent_h", this);
      end
      cxl_cm_scoreboard_h  = cxl_cm_scoreboard::type_id::create("cxl_cm_scoreboard_h", this);
      cxl_cm_vseqr          = cxl_cm_vsequencer::type_id::create("cxl_cm_vseqr", this);
      `uvm_info(get_type_name(), $sformatf("exit build_phase in uvm environment : %s", get_full_name()), UVM_HIGH)
    endfunction 

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("enter connect_phase in uvm environment : %s", get_full_name()), UVM_HIGH)
      `uvm_info(get_type_name(), $sformatf("dev_d2h_req_agent_h is_active = %0s", dev_d2h_req_agent_h.is_active.name()), UVM_FULL)
      if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
        if(dev_d2h_req_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_d2h_req_seqr   = dev_d2h_req_agent_h.dev_d2h_req_sequencer_h;
        end
        dev_d2h_req_agent_h.dev_d2h_req_monitor_h.d2h_req_port.connect(cxl_cm_scoreboard_h.dev_d2h_req_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_d2h_rsp_agent_h is_active = %0s", dev_d2h_rsp_agent_h.is_active.name()), UVM_FULL)
        if(dev_d2h_rsp_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_d2h_rsp_seqr   = dev_d2h_rsp_agent_h.dev_d2h_rsp_sequencer_h;
        end
        dev_d2h_rsp_agent_h.dev_d2h_rsp_monitor_h.d2h_rsp_port.connect(cxl_cm_scoreboard_h.dev_d2h_rsp_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_d2h_data_agent_h is_active = %0s", dev_d2h_data_agent_h.is_active.name()), UVM_FULL)
        if(dev_d2h_data_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_d2h_data_seqr  = dev_d2h_data_agent_h.dev_d2h_data_sequencer_h;
        end
        dev_d2h_data_agent_h.dev_d2h_data_monitor_h.d2h_data_port.connect(cxl_cm_scoreboard_h.dev_d2h_data_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_h2d_req_agent_h is_active = %0s", host_h2d_req_agent_h.is_active.name()), UVM_FULL)
        if(host_h2d_req_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_h2d_req_seqr   = host_h2d_req_agent_h.host_h2d_req_sequencer_h;
        end
        host_h2d_req_agent_h.host_h2d_req_monitor_h.h2d_req_port.connect(cxl_cm_scoreboard_h.host_h2d_req_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_h2d_rsp_agent_h is_active = %0s", host_h2d_rsp_agent_h.is_active.name()), UVM_FULL)
        if(host_h2d_rsp_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_h2d_rsp_seqr   = host_h2d_rsp_agent_h.host_h2d_rsp_sequencer_h;
        end
        host_h2d_rsp_agent_h.host_h2d_rsp_monitor_h.h2d_rsp_port.connect(cxl_cm_scoreboard_h.host_h2d_rsp_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_h2d_data_agent_h is_active = %0s", host_h2d_data_agent_h.is_active.name()), UVM_FULL)
        if(host_h2d_data_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_h2d_data_seqr  = host_h2d_data_agent_h.host_h2d_data_sequencer_h;
        end
        host_h2d_data_agent_h.host_h2d_data_monitor_h.h2d_data_port.connect(cxl_cm_scoreboard_h.host_h2d_data_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_m2s_req_agent_h is_active = %0s", host_m2s_req_agent_h.is_active.name()), UVM_FULL)
        if(host_m2s_req_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_m2s_req_seqr   = host_m2s_req_agent_h.host_m2s_req_sequencer_h;
        end
        host_d2h_req_agent_h.host_d2h_req_monitor_h.d2h_req_port.connect(cxl_cm_scoreboard_h.host_d2h_req_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_d2h_rsp_agent_h is_active = %0s", host_d2h_rsp_agent_h.is_active.name()), UVM_FULL)
        if(host_d2h_rsp_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_d2h_rsp_seqr   = host_d2h_rsp_agent_h.host_d2h_rsp_sequencer_h;
        end
        host_d2h_rsp_agent_h.host_d2h_rsp_monitor_h.d2h_rsp_port.connect(cxl_cm_scoreboard_h.host_d2h_rsp_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_d2h_data_agent_h is_active = %0s", host_d2h_data_agent_h.is_active.name()), UVM_FULL)
        if(host_d2h_data_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_d2h_data_seqr  = host_d2h_data_agent_h.host_d2h_data_sequencer_h;
        end
        host_d2h_data_agent_h.host_d2h_data_monitor_h.d2h_data_port.connect(cxl_cm_scoreboard_h.host_d2h_data_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_h2d_req_agent_h is_active = %0s", dev_h2d_req_agent_h.is_active.name()), UVM_FULL)
        if(dev_h2d_req_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_h2d_req_seqr   = dev_h2d_req_agent_h.dev_h2d_req_sequencer_h;
        end
        dev_h2d_req_agent_h.dev_h2d_req_monitor_h.h2d_req_port.connect(cxl_cm_scoreboard_h.dev_h2d_req_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_h2d_rsp_agent_h is_active = %0s", dev_h2d_rsp_agent_h.is_active.name()), UVM_FULL)
        if(dev_h2d_rsp_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_h2d_rsp_seqr   = dev_h2d_rsp_agent_h.dev_h2d_rsp_sequencer_h;
        end
        dev_h2d_rsp_agent_h.dev_h2d_rsp_monitor_h.h2d_rsp_port.connect(cxl_cm_scoreboard_h.dev_h2d_rsp_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_h2d_data_agent_h is_active = %0s", dev_h2d_data_agent_h.is_active.name()), UVM_FULL)
        if(dev_h2d_data_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_h2d_data_seqr  = dev_h2d_data_agent_h.dev_h2d_data_sequencer_h;
        end
        dev_h2d_data_agent_h.dev_h2d_data_monitor_h.h2d_data_port.connect(cxl_cm_scoreboard_h.dev_h2d_data_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_m2s_req_agent_h is_active = %0s", dev_m2s_req_agent_h.is_active.name()), UVM_FULL)
        if(dev_m2s_req_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_m2s_req_seqr   = dev_m2s_req_agent_h.dev_m2s_req_sequencer_h;
        end
      end
      if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2, GEET_CXL_TYPE_3}) begin
        host_m2s_req_agent_h.host_m2s_req_monitor_h.m2s_req_port.connect(cxl_cm_scoreboard_h.host_m2s_req_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_m2s_rwd_agent_h is_active = %0s", host_m2s_rwd_agent_h.is_active.name()), UVM_FULL)
        if(host_m2s_rwd_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_m2s_rwd_seqr   = host_m2s_rwd_agent_h.host_m2s_rwd_sequencer_h;
        end
        host_m2s_rwd_agent_h.host_m2s_rwd_monitor_h.m2s_rwd_port.connect(cxl_cm_scoreboard_h.host_m2s_rwd_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_s2m_ndr_agent_h is_active = %0s", dev_s2m_ndr_agent_h.is_active.name()), UVM_FULL)
        if(dev_s2m_ndr_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_s2m_ndr_seqr   = dev_s2m_ndr_agent_h.dev_s2m_ndr_sequencer_h;
        end
        dev_s2m_ndr_agent_h.dev_s2m_ndr_monitor_h.s2m_ndr_port.connect(cxl_cm_scoreboard_h.dev_s2m_ndr_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_s2m_drs_agent_h is_active = %0s", dev_s2m_drs_agent_h.is_active.name()), UVM_FULL)
        if(dev_s2m_drs_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_s2m_drs_seqr   = dev_s2m_drs_agent_h.dev_s2m_drs_sequencer_h;
        end
        dev_s2m_drs_agent_h.dev_s2m_drs_monitor_h.s2m_drs_port.connect(cxl_cm_scoreboard_h.dev_s2m_drs_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_d2h_req_agent_h is_active = %0s", host_d2h_req_agent_h.is_active.name()), UVM_FULL)
        if(host_d2h_req_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_d2h_req_seqr   = host_d2h_req_agent_h.host_d2h_req_sequencer_h;
        end
        dev_m2s_req_agent_h.dev_m2s_req_monitor_h.m2s_req_port.connect(cxl_cm_scoreboard_h.dev_m2s_req_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("dev_m2s_rwd_agent_h is_active = %0s", dev_m2s_rwd_agent_h.is_active.name()), UVM_FULL)
        if(dev_m2s_rwd_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.dev_m2s_rwd_seqr   = dev_m2s_rwd_agent_h.dev_m2s_rwd_sequencer_h;
        end
        dev_m2s_rwd_agent_h.dev_m2s_rwd_monitor_h.m2s_rwd_port.connect(cxl_cm_scoreboard_h.dev_m2s_rwd_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_s2m_ndr_agent_h is_active = %0s", host_s2m_ndr_agent_h.is_active.name()), UVM_FULL)
        if(host_s2m_ndr_agent_h.is_active == UVM_ACTIVE) begin
            cxl_cm_vseqr.host_s2m_ndr_seqr   = host_s2m_ndr_agent_h.host_s2m_ndr_sequencer_h;
        end
        host_s2m_ndr_agent_h.host_s2m_ndr_monitor_h.s2m_ndr_port.connect(cxl_cm_scoreboard_h.host_s2m_ndr_fifo.analysis_export);
        `uvm_info(get_type_name(), $sformatf("host_s2m_drs_agent_h is_active = %0s", host_s2m_drs_agent_h.is_active.name()), UVM_FULL)
        if(host_s2m_drs_agent_h.is_active == UVM_ACTIVE) begin
          cxl_cm_vseqr.host_s2m_drs_seqr   = host_s2m_drs_agent_h.host_s2m_drs_sequencer_h;
        end
        host_s2m_drs_agent_h.host_s2m_drs_monitor_h.s2m_drs_port.connect(cxl_cm_scoreboard_h.host_s2m_drs_fifo.analysis_export);
      end
      `uvm_info(get_type_name(), $sformatf("exit connect_phase in uvm environment : %s", get_full_name()), UVM_HIGH)
    endfunction

  endclass

  class cxl_base_txn_seq extends uvm_sequence;
    `uvm_object_utils(cxl_base_txn_seq)
    `uvm_declare_p_sequencer(cxl_cm_vsequencer)
    
    rand int num_trans;
    //rand cxl_base_txn_seq_item cxl_base_txn_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
    }

    function new(string name = "cxl_base_txn_seq");
      super.new(name);
    endfunction

  endclass

  class dev_d2h_req_seq extends cxl_base_txn_seq;
    `uvm_object_utils(dev_d2h_req_seq)
    rand d2h_req_seq_item d2h_req_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      d2h_req_seq_item_h.size == num_trans;
    }

    function new(string name = "dev_d2h_req_seq");
      super.new(name);
    endfunction

    task body();
      foreach(d2h_req_seq_item_h[i]) begin
        `uvm_do_on(d2h_req_seq_item_h[i], p_sequencer.dev_d2h_req_seqr);
      end
    endtask

  endclass

  class host_h2d_req_seq extends cxl_base_txn_seq;
    `uvm_object_utils(host_h2d_req_seq)
    rand h2d_req_seq_item h2d_req_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      h2d_req_seq_item_h.size == num_trans;
    }

    function new(string name = "host_h2d_req_seq");
      super.new(name);
    endfunction

    task body();
      foreach(h2d_req_seq_item_h[i]) begin
        `uvm_do_on(h2d_req_seq_item_h[i], p_sequencer.host_h2d_req_seqr);
      end
    endtask

  endclass

  class host_m2s_req_seq extends cxl_base_txn_seq;
    `uvm_object_utils(host_m2s_req_seq)
    rand m2s_req_seq_item m2s_req_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      m2s_req_seq_item_h.size == num_trans;
    }

    function new(string name = "host_m2s_req_seq");
      super.new(name);
    endfunction

    task body();
      foreach(m2s_req_seq_item_h[i]) begin
        `uvm_do_on(m2s_req_seq_item_h[i], p_sequencer.host_m2s_req_seqr);
      end
    endtask

  endclass

  class host_m2s_rwd_seq extends cxl_base_txn_seq;
    `uvm_object_utils(host_m2s_rwd_seq)
    rand m2s_rwd_seq_item m2s_rwd_seq_item_h[];

    constraint num_of_trans_c{
      soft num_trans inside {[10:100]};
      m2s_rwd_seq_item_h.size == num_trans;
    }

    function new(string name = "host_m2s_rwd_seq");
      super.new(name);
    endfunction

    task body();
      foreach(m2s_rwd_seq_item_h[i]) begin
        `uvm_do_on(m2s_rwd_seq_item_h[i], p_sequencer.host_m2s_rwd_seqr);
      end
    endtask

  endclass

  //cache/mem responder seq as per appendix C
  class cxl_cm_responder_seq extends uvm_sequence;
    `uvm_object_utils(cxl_cm_responder_seq)
    `uvm_declare_p_sequencer(cxl_cm_vsequencer)
    cxl_cfg_obj       cxl_cfg_obj_h;
    h2d_req_seq_item  h2d_req_seq_item_h;
    h2d_rsp_seq_item  h2d_rsp_seq_item_h;
    h2d_data_seq_item h2d_data_seq_item_h;
    d2h_rsp_seq_item  d2h_rsp_seq_item_h;
    d2h_data_seq_item d2h_data_seq_item_h;
    h2d_req_seq_item  h2d_req_seq_item_rcvd;
    h2d_rsp_seq_item  h2d_rsp_seq_item_rcvd;
    h2d_data_seq_item h2d_data_seq_item_rcvd;
    d2h_req_seq_item  d2h_req_seq_item_rcvd;
    d2h_rsp_seq_item  d2h_rsp_seq_item_rcvd;
    d2h_data_seq_item d2h_data_seq_item_rcvd;
    m2s_req_seq_item  m2s_req_seq_item_h;
    m2s_req_seq_item  m2s_req_seq_item_rcvd;
    m2s_rwd_seq_item  m2s_rwd_seq_item_rcvd;
    s2m_ndr_seq_item  s2m_req_ndr_seq_item_h;
    s2m_drs_seq_item  s2m_req_drs_seq_item_h;
    s2m_ndr_seq_item  s2m_rwd_ndr_seq_item_h;
    h2d_req_opcode_t  h2d_req_id_aa[int];// this will be useful in future gen
    bit unset_set;

    function new(string name = "cxl_cm_responder_seq");
      super.new(name);
    endfunction
    
    task body();
      if(!uvm_resource_db#(cxl_cfg_obj)::read_by_name("", "cxl_cfg_obj_h", cxl_cfg_obj_h)) begin
        `uvm_fatal("CXL_CFG_OBJ", "cxl_cfg_obj not found")
      end
      fork 
        begin
          forever begin
            //d2h_req_responder_h2d_req(); understand why this is not possible in CXLv1.1 we can rearchitect for multiple devices in next version but v1.1 is 1 to one connection
          end
        end
        begin
          forever begin
            if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
              d2h_req_responder_h2d_rsp_data();//understand this is only applicable to CXLv1.1
            end
          end
        end
        begin
          forever begin
            if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
              h2d_req_responder_d2h_rsp_data();//understand this is applicable to both v1.1 and future gen for multidevice
            end
          end
        end
        begin
          forever begin
            if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
              h2d_rsp_responder_d2h_data_data(); //such as wr pulls //understand this is going to be useful in multidevice not in CXL v1.1
            end
          end
        end
        begin
          forever begin
            if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
              h2d_rsp_responder_h2d_rsp_data(); //understand this is going to be useful in multidevice not in CXL v1.1
            end
          end
        end
        begin
          if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2}) begin
            forever begin
              type2_m2s_req_rwd_responder_s2m_ndr_drs();
            end
          end else if (cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3})begin
            forever begin
              type3_m2s_req_rwd_responder_s2m_ndr_drs();
            end
          end
        end
      join_none
    endtask    
    
    task  h2d_rsp_responder_d2h_data_data(); 
      p_sequencer.dev_h2d_rsp_seqr.dev_h2d_rsp_fifo.get(h2d_rsp_seq_item_rcvd);
      if(h2d_rsp_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_WRITEPULL, GEET_CXL_CACHE_OPCODE_GOWRITEPULL, GEET_CXL_CACHE_OPCODE_FASTGOWRPULL}) begin
        `uvm_do_on_with(
          d2h_data_seq_item_h,
          p_sequencer.dev_d2h_data_seqr,
          {
            uqid == h2d_rsp_seq_item_rcvd.cqid;
          }
        );
        //not an issue writepull can only trigger wr rsp not just GO-ERR/Ibest way to find out if the uqid is a wrinv then save it in psequencer and refer to it through uqid and send that response that support needs to be added,
      end else if(h2d_rsp_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_GOERRWRPULL}) begin
        `uvm_do_on_with(
          d2h_data_seq_item_h,
          p_sequencer.dev_d2h_data_seqr,
          {
            uqid == h2d_rsp_seq_item_rcvd.cqid;
            data == 512'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
          }
        );
      end
    endtask
    
    task  h2d_rsp_responder_h2d_rsp_data(); 
      automatic d2h_data_seq_item d2h_data_seq_item_rcvd_a;
      fork 
        begin
          p_sequencer.host_d2h_data_seqr.host_d2h_data_fifo.get(d2h_data_seq_item_rcvd_a);
        end
        begin
          p_sequencer.dev_h2d_rsp_seqr.dev_h2d_rsp_fifo.get(h2d_rsp_seq_item_rcvd);
          wait(d2h_data_seq_item_rcvd_a.uqid == h2d_rsp_seq_item_rcvd.cqid);
          if(h2d_rsp_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_FASTGOWRPULL}) begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                opcode inside {GEET_CXL_CACHE_OPCODE_EXTCMP};
                cqid == h2d_rsp_seq_item_rcvd.cqid;
              }
            );
          end else if(h2d_rsp_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_WRITEPULL}) begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                opcode inside {GEET_CXL_CACHE_OPCODE_GO};
                rspdata inside {GEET_CXL_CACHE_MESI_I, GEET_CXL_CACHE_MESI_ERR};
                cqid == h2d_rsp_seq_item_rcvd.cqid;
              }
            );
          end
        end
      join_none
    endtask
    
    //you must be careful here because req and rwd both send ndr so some might get overriden when both are tried to be called 
    task type2_m2s_req_rwd_responder_s2m_ndr_drs();
      m2s_req_seq_item_rcvd = null; 
      m2s_rwd_seq_item_rcvd = null;
      fork 
        begin
          p_sequencer.dev_m2s_req_seqr.dev_m2s_req_fifo.get(m2s_req_seq_item_rcvd); 
        end
        begin
          p_sequencer.dev_m2s_rwd_seqr.dev_m2s_rwd_fifo.get(m2s_rwd_seq_item_rcvd); 
        end
      join_any
      fork 
        begin
          if(m2s_req_seq_item_rcvd != null) begin
            `uvm_do_on_with(
              s2m_req_ndr_seq_item_h,
              p_sequencer.dev_s2m_ndr_seqr,
              {
                valid == 'h1;
                //TODO: just check if below covers all the possible conditions for opcode in the appendix in CXLv2
                ((m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD, GEET_CXL_MEM_OPCODE_MEMINV, GEET_CXL_MEM_OPCODE_MEMINVNT}) && (m2s_req_seq_item_rcvd.metafield == GEET_CXL_MEM_MF_METAFIELD_NOOP)) -> (opcode == GEET_CXL_MEM_OPCODE_CMP);
                ((m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDDATA}) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPDATA)) -> (opcode inside {GEET_CXL_MEM_OPCODE_CMPE, GEET_CXL_MEM_OPCODE_CMPS});
                ((m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD}) && (m2s_req_seq_item_rcvd.metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE) && (m2s_req_seq_item_rcvd.metavalue == GEET_CXL_MEM_MV_METAVALUE_ANY) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPINV)) -> (opcode == GEET_CXL_MEM_OPCODE_CMPE);
                ((m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD}) && (m2s_req_seq_item_rcvd.metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE) && (m2s_req_seq_item_rcvd.metavalue == GEET_CXL_MEM_MV_METAVALUE_SHARED) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPDATA)) -> (opcode inside {GEET_CXL_MEM_OPCODE_CMPE, GEET_CXL_MEM_OPCODE_CMPS});
                ((m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD}) && (m2s_req_seq_item_rcvd.metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE) && (m2s_req_seq_item_rcvd.metavalue == GEET_CXL_MEM_MV_METAVALUE_INVALID) && (m2s_req_seq_item_rcvd.snptype inside {GEET_CXL_MEM_SNPTYP_MEMSNPINV, GEET_CXL_MEM_SNPTYP_MEMSNPCUR})) -> (opcode == GEET_CXL_MEM_OPCODE_CMP);
                ((m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMINV, GEET_CXL_MEM_OPCODE_MEMINVNT}) && (m2s_req_seq_item_rcvd.metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE) && (m2s_req_seq_item_rcvd.metavalue == GEET_CXL_MEM_MV_METAVALUE_ANY) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPINV)) -> (opcode == GEET_CXL_MEM_OPCODE_CMPE);
                ((m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMINV, GEET_CXL_MEM_OPCODE_MEMINVNT}) && (m2s_req_seq_item_rcvd.metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE) && (m2s_req_seq_item_rcvd.metavalue == GEET_CXL_MEM_MV_METAVALUE_SHARED) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPDATA)) -> (opcode == GEET_CXL_MEM_OPCODE_CMPS);
                ((m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMINV, GEET_CXL_MEM_OPCODE_MEMINVNT}) && (m2s_req_seq_item_rcvd.metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE) && (m2s_req_seq_item_rcvd.metavalue == GEET_CXL_MEM_MV_METAVALUE_INVALID) && (m2s_req_seq_item_rcvd.snptype inside {GEET_CXL_MEM_SNPTYP_MEMSNPINV})) -> (opcode == GEET_CXL_MEM_OPCODE_CMP);
                tag == m2s_req_seq_item_rcvd.tag;
                metafield == m2s_req_seq_item_rcvd.metafield;
                ((m2s_req_seq_item_rcvd.memopcode == GEET_CXL_MEM_OPCODE_MEMRDDATA) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPDATA) && (s2m_req_ndr_seq_item_h.opcode == GEET_CXL_MEM_OPCODE_CMPE) && (s2m_req_ndr_seq_item_h.metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE)) -> (metavalue inside {GEET_CXL_MEM_MV_METAVALUE_ANY, GEET_CXL_MEM_MV_METAVALUE_INVALID});
                ((m2s_req_seq_item_rcvd.memopcode == GEET_CXL_MEM_OPCODE_MEMRDDATA) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPDATA) && (s2m_req_ndr_seq_item_h.opcode == GEET_CXL_MEM_OPCODE_CMPS) && (s2m_req_ndr_seq_item_h.metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE)) -> (metavalue inside {GEET_CXL_MEM_MV_METAVALUE_SHARED});
                ((m2s_req_seq_item_rcvd.memopcode == GEET_CXL_MEM_OPCODE_MEMRDDATA) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPDATA) && (s2m_req_ndr_seq_item_h.opcode != GEET_CXL_MEM_OPCODE_CMPE) && (s2m_req_ndr_seq_item_h.metafield == GEET_CXL_MEM_MF_METAFIELD_NOOP)) -> (metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID});
                ((m2s_req_seq_item_rcvd.memopcode == GEET_CXL_MEM_OPCODE_MEMRDDATA) && (m2s_req_seq_item_rcvd.snptype == GEET_CXL_MEM_SNPTYP_MEMSNPDATA) && (s2m_req_ndr_seq_item_h.opcode != GEET_CXL_MEM_OPCODE_CMPS) && (s2m_req_ndr_seq_item_h.metafield == GEET_CXL_MEM_MF_METAFIELD_NOOP)) -> (metavalue inside {GEET_CXL_MEM_MV_METAVALUE_ANY, GEET_CXL_MEM_MV_METAVALUE_INVALID});
              }
            );
          end
        end
        begin
          if((m2s_req_seq_item_rcvd != null) && (m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD, GEET_CXL_MEM_OPCODE_MEMRDDATA})) begin
            `uvm_do_on_with(
              s2m_req_drs_seq_item_h,
              p_sequencer.dev_s2m_ndr_seqr,
              {
                valid == 'h1;
                opcode == GEET_CXL_MEM_OPCODE_MEMDATA;
                tag == m2s_req_seq_item_rcvd.tag;
              }
            );
          end
        end
      join
      if(m2s_rwd_seq_item_rcvd != null) begin
        `uvm_do_on_with(
          s2m_rwd_ndr_seq_item_h,
          p_sequencer.dev_s2m_ndr_seqr,
          {
            valid == 'h1;
            opcode == GEET_CXL_MEM_OPCODE_CMP;
            tag == m2s_rwd_seq_item_rcvd.tag;
            metafield == GEET_CXL_MEM_MF_METAFIELD_NOOP;
          }
        );
      end
    endtask

    //you must be careful here because req and rwd both send ndr so some might get overriden when both are tried to be called 
    task type3_m2s_req_rwd_responder_s2m_ndr_drs();
      m2s_req_seq_item_rcvd = null; 
      m2s_rwd_seq_item_rcvd = null;
      fork 
        begin
          p_sequencer.dev_m2s_req_seqr.dev_m2s_req_fifo.get(m2s_req_seq_item_rcvd); 
        end
        begin
          p_sequencer.dev_m2s_rwd_seqr.dev_m2s_rwd_fifo.get(m2s_rwd_seq_item_rcvd); 
        end
      join_any
      fork 
        begin
          if((m2s_req_seq_item_rcvd != null) && (m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMINV, GEET_CXL_MEM_OPCODE_MEMINVNT})) begin
            `uvm_do_on_with(
              s2m_req_ndr_seq_item_h,
              p_sequencer.dev_s2m_ndr_seqr,
              {
                valid == 'h1;
                opcode == GEET_CXL_MEM_OPCODE_CMP;
                tag == m2s_req_seq_item_rcvd.tag;
              }
            );
          end
        end
        begin
          if((m2s_req_seq_item_rcvd != null) && (m2s_req_seq_item_rcvd.memopcode inside {GEET_CXL_MEM_OPCODE_MEMRD, GEET_CXL_MEM_OPCODE_MEMRDDATA})) begin
            `uvm_do_on_with(
              s2m_req_drs_seq_item_h,
              p_sequencer.dev_s2m_ndr_seqr,
              {
                valid == 'h1;
                opcode == GEET_CXL_MEM_OPCODE_MEMDATA;
                tag == m2s_req_seq_item_rcvd.tag;
              }
            );
          end
        end
      join
      if(m2s_rwd_seq_item_rcvd != null) begin;
        `uvm_do_on_with(
          s2m_rwd_ndr_seq_item_h,
          p_sequencer.dev_s2m_ndr_seqr,
          {
            valid == 'h1;
            opcode == GEET_CXL_MEM_OPCODE_CMP;
            tag == m2s_rwd_seq_item_rcvd.tag;
            metafield == GEET_CXL_MEM_MF_METAFIELD_NOOP;
          }
        );
      end
    endtask

    task d2h_req_responder_h2d_req();
/*      d2h_req_seq_item_rcvd = p_sequencer.host_d2h_req_seqr.host_d2h_req_fifo.get(); 
      if(d2h_req_seq_item_rcvd.opcode == GEET_CXL_CACHE_OPCODE_RDCURR) begin
        `uvm_do_on_with(
          h2d_req_seq_item_h,
          p_sequencer.h2d_req_seqr,
          {
            valid == 'h1;
            opcode == GEET_CXL_MEM_OPCODE_SNPCURR;
            address == d2h_req_seq_item_rcvd.address;
            uqid == d2h_req_seq_item_rcvd.cqid;
          }
        );
        h2d_req_id_aa[d2h_req_seq_item_rcvd.cqid] = h2d_req_seq_item_h.opcode;
      end
*/    endtask

    task h2d_req_responder_d2h_rsp_data();
    //TODO: spec says only return modified data using data channel but for other conditions it is not specified now you are returning data for any of the held state modified or otherwise you need to confirm this operation
      p_sequencer.dev_h2d_req_seqr.dev_h2d_req_fifo.get(h2d_req_seq_item_rcvd);
      if(h2d_req_seq_item_rcvd.opcode == GEET_CXL_CACHE_OPCODE_SNPCURR) begin
        fork 
          begin
            `uvm_do_on_with(
              d2h_rsp_seq_item_h,
              p_sequencer.dev_d2h_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {
                  GEET_CXL_CACHE_OPCODE_RSPIHITI, 
                  GEET_CXL_CACHE_OPCODE_RSPVHITV, 
                  GEET_CXL_CACHE_OPCODE_RSPSHITSE, 
                  GEET_CXL_CACHE_OPCODE_RSPSFWDM,
                  GEET_CXL_CACHE_OPCODE_RSPIFWDM,
                  GEET_CXL_CACHE_OPCODE_RSPVFWDV
                } ;
                uqid == h2d_req_seq_item_rcvd.uqid;
              }
            );
          end
          begin
            `uvm_do_on_with(
              d2h_data_seq_item_h,
              p_sequencer.dev_d2h_data_seqr,
              {
                valid == 'h1;
                uqid == h2d_req_seq_item_rcvd.uqid;
              }
            );
          end
        join
      end else if(h2d_req_seq_item_rcvd.opcode == GEET_CXL_CACHE_OPCODE_SNPINV) begin         
        fork
          begin
            `uvm_do_on_with(
              d2h_rsp_seq_item_h,
              p_sequencer.dev_d2h_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {
                  GEET_CXL_CACHE_OPCODE_RSPIHITI,
                  GEET_CXL_CACHE_OPCODE_RSPIHITSE,
                  GEET_CXL_CACHE_OPCODE_RSPIFWDM
                };
                uqid == h2d_req_seq_item_rcvd.uqid;
              }
            );
          end
          begin
            `uvm_do_on_with(
              d2h_data_seq_item_h,
              p_sequencer.dev_d2h_data_seqr,
              {
                valid == 'h1;
                uqid == h2d_req_seq_item_rcvd.uqid;
              }
            );
          end
        join
      end else if(h2d_req_seq_item_rcvd.opcode == GEET_CXL_CACHE_OPCODE_SNPDATA) begin
        fork 
          begin
            `uvm_do_on_with(
              d2h_rsp_seq_item_h,
              p_sequencer.dev_d2h_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {
                  GEET_CXL_CACHE_OPCODE_RSPIHITI,
                  GEET_CXL_CACHE_OPCODE_RSPSHITSE,
                  GEET_CXL_CACHE_OPCODE_RSPSFWDM,
                  GEET_CXL_CACHE_OPCODE_RSPIFWDM
                };
                uqid == h2d_req_seq_item_rcvd.uqid;
              }
            );
          end
          begin
            `uvm_do_on_with(
              d2h_data_seq_item_h,
              p_sequencer.dev_d2h_data_seqr,
              {
                valid == 'h1;
                uqid == h2d_req_seq_item_rcvd.uqid;
              }
            );
          end
        join
      end
    endtask

    task d2h_req_responder_h2d_rsp_data();
      //TODO: HDM-D needs to be defined in cfg like address map partitions
      //TODO: these FWD flows conflict with normal mem traffic and corrupt traffic look into how to get exclusive access to driver when it does uvm do
      p_sequencer.host_d2h_req_seqr.host_d2h_req_fifo.get(d2h_req_seq_item_rcvd);
      if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_RDCURR}) begin
//remember rdcurr doesnt give any response only data
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
/*        
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode == ;
                rspdata == d2h_rsp_seq_item_rcvd.uqid;
                cqid == d2h_rsp_seq_item_rcvd.uqid;
              }
            );
*/      
          end
//remember this maybe sent or may not be sent so it is good to randomize weather to give a data or not to give a data
          begin
            if(std::randomize(unset_set) == 0) begin
              `uvm_fatal("RANDOMIZE_FAIL", "Failed to randomize unset_set")
            end
            if(unset_set) begin
              `uvm_do_on_with(
                h2d_data_seq_item_h,
                p_sequencer.host_h2d_data_seqr,
                {
                  valid == 'h1;
                  cqid == d2h_req_seq_item_rcvd.cqid;
                }
              );
            end
          end
          join
        end else if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_D) begin
          `uvm_do_on_with(
            m2s_req_seq_item_h,
            p_sequencer.host_m2s_req_seqr,
            {
              valid == 'h1;
              address == d2h_req_seq_item_rcvd.address;
              memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDFWD};
              tag == d2h_req_seq_item_rcvd.cqid;
              snptype == GEET_CXL_MEM_SNPTYP_MEMSNPNOOP;
              metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE;
            }
          );
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_RDOWN}) begin
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GO} ;
                rspdata inside {GEET_CXL_CACHE_MESI_ERR, GEET_CXL_CACHE_MESI_I, GEET_CXL_CACHE_MESI_E, GEET_CXL_CACHE_MESI_M};
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            //both are not forked togather because there is a dependency of MESIERR making the data as all 1s
            `uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                ((h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GO) && (h2d_rsp_seq_item_h.rspdata == GEET_CXL_CACHE_MESI_ERR)) -> {data == 512'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff; goerr == 'h1;}
              }
            );
          end
          join
        end else if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_D) begin
          `uvm_do_on_with(
            m2s_req_seq_item_h,
            p_sequencer.host_m2s_req_seqr,
            {
              valid == 'h1;
              address == d2h_req_seq_item_rcvd.address;
              memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDFWD};
              tag == d2h_req_seq_item_rcvd.cqid;
              snptype == GEET_CXL_MEM_SNPTYP_MEMSNPNOOP;
              metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE;
              //metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID};//TODO:dont know if this is true
            }
          );
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_RDSHARED}) begin
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GO} ;
                rspdata inside {GEET_CXL_CACHE_MESI_ERR, GEET_CXL_CACHE_MESI_I, GEET_CXL_CACHE_MESI_S};
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            //both are not forked togather because there is a dependency of MESIERR making the data as all 1s
            `uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                ((h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GO) && (h2d_rsp_seq_item_h.rspdata == GEET_CXL_CACHE_MESI_ERR)) -> {data == 512'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff; goerr == 'h1;}
              }
            );
          end
          join
        end else if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_D) begin
          `uvm_do_on_with(
            m2s_req_seq_item_h,
            p_sequencer.host_m2s_req_seqr,
            {
              valid == 'h1;
              address == d2h_req_seq_item_rcvd.address;
              memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDFWD};
              tag == d2h_req_seq_item_rcvd.cqid;
              snptype == GEET_CXL_MEM_SNPTYP_MEMSNPNOOP;
              metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE;
              metavalue inside {GEET_CXL_MEM_MV_METAVALUE_SHARED};
            }
          );
        end
       end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_RDANY}) begin
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GO} ;
                rspdata inside {
                                  GEET_CXL_CACHE_MESI_ERR, 
                                  GEET_CXL_CACHE_MESI_I, 
                                  GEET_CXL_CACHE_MESI_S,
                                  GEET_CXL_CACHE_MESI_E,
                                  GEET_CXL_CACHE_MESI_M
                                };
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            //both are not forked togather because there is a dependency of MESIERR making the data as all 1s
            `uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                ((h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GO) && (h2d_rsp_seq_item_h.rspdata == GEET_CXL_CACHE_MESI_ERR)) -> {data == 512'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff; goerr == 'h1;}
              }
            );
          end
          join
        end else if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_D) begin
          `uvm_do_on_with(
            m2s_req_seq_item_h,
            p_sequencer.host_m2s_req_seqr,
            {
              valid == 'h1;
              address == d2h_req_seq_item_rcvd.address;
              memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDFWD};
              tag == d2h_req_seq_item_rcvd.cqid;
              snptype == GEET_CXL_MEM_SNPTYP_MEMSNPNOOP;
              metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE;
              metavalue inside {GEET_CXL_MEM_MV_METAVALUE_ANY};
            }
          );
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_RDOWNNODATA}) begin
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GO} ;
                rspdata inside {
                                  GEET_CXL_CACHE_MESI_ERR, 
                                  GEET_CXL_CACHE_MESI_E
                                };
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            //here it does not return any data even if it is goerr
            /*`uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                ((h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GO) && (h2d_rsp_seq_item_h.rspdata == GEET_CXL_CACHE_MESI_ERR)) -> (data == {512{1'b1}});
              }
            );*/
          end
          join
        end else if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_D) begin
          `uvm_do_on_with(
            m2s_req_seq_item_h,
            p_sequencer.host_m2s_req_seqr,
            {
              valid == 'h1;
              address == d2h_req_seq_item_rcvd.address;
              memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDFWD};
              tag == d2h_req_seq_item_rcvd.cqid;
              snptype == GEET_CXL_MEM_SNPTYP_MEMSNPNOOP;
              metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE;
              //metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID};//TODO:dont know if this is true
            }
          );
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_CLFLUSH}) begin
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GO} ;
                rspdata inside {
                                  GEET_CXL_CACHE_MESI_ERR, 
                                  GEET_CXL_CACHE_MESI_I
                                };
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            //here it does not return any data even if it is goerr
            /*`uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                ((h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GO) && (h2d_rsp_seq_item_h.rspdata == GEET_CXL_CACHE_MESI_ERR)) -> (data == {512{1'b1}});
              }
            );*/
          end
          join
        end else if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_D) begin
          `uvm_do_on_with(
            m2s_req_seq_item_h,
            p_sequencer.host_m2s_req_seqr,
            {
              valid == 'h1;
              address == d2h_req_seq_item_rcvd.address;
              memopcode inside {GEET_CXL_MEM_OPCODE_MEMRDFWD};
              tag == d2h_req_seq_item_rcvd.cqid;
              snptype == GEET_CXL_MEM_SNPTYP_MEMSNPNOOP;
              metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE;
              //metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID};//TODO:dont know if this is true
            }
          );
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_CACHEFLUSHED}) begin
        fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GO} ;
                rspdata inside {
                                  GEET_CXL_CACHE_MESI_I
                                };
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            //here it does not return any data even if it is goerr
            /*`uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                ((h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GO) && (h2d_rsp_seq_item_h.rspdata == GEET_CXL_CACHE_MESI_ERR)) -> (data == {512{1'b1}});
              }
            );*/
          end
        join
       end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_CLEANEVICTNODATA}) begin
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GO} ;
                rspdata inside {
                                  GEET_CXL_CACHE_MESI_I
                                };
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            //here it does not return any data even if it is goerr
            /*`uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                ((h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GO) && (h2d_rsp_seq_item_h.rspdata == GEET_CXL_CACHE_MESI_ERR)) -> (data == {512{1'b1}});
              }
            );*/
          end
          join
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_CLEANEVICT}) begin
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GOWRITEPULL, GEET_CXL_CACHE_OPCODE_GOWRPULLDROP} ;
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            //this thing below is wrong it was due to lack of undeerstanding initially
            //here it does not return any data even if it is pull drop
            /*if(h2d_rsp_seq_item_h.opcode inside {GEET_CXL_CACHE_OPCODE_GOWRITEPULL}) begin
              `uvm_do_on_with(
                h2d_data_seq_item_h,
                p_sequencer.host_h2d_data_seqr,
                {
                  valid == 'h1;
                  cqid == d2h_req_seq_item_rcvd.cqid;
                }
              );
            end*/
          end
          join
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_DIRTYEVICT, GEET_CXL_CACHE_OPCODE_ITOMWR, GEET_CXL_CACHE_OPCODE_MEMWRI}) begin
        if((cxl_cfg_obj_h.hdm == GEET_CXL_HDM_D) && d2h_req_seq_item_rcvd.opcode == GEET_CXL_CACHE_OPCODE_DIRTYEVICT) begin
        end else begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_GOWRITEPULL, GEET_CXL_CACHE_OPCODE_GOERRWRPULL} ;
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            /*//this is wrong below
            //here it does not return any data even if it is pull drop
            `uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                (h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GOERRWRPULL) -> {data == 512'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff; goerr == 'h1;}
              }
            );
            */
          end
          join
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_WOWRINV, GEET_CXL_CACHE_OPCODE_WOWRINVF}) begin
        if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_H) begin
          fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_FASTGOWRPULL, GEET_CXL_CACHE_OPCODE_GOERRWRPULL};
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            /*this is wrong due to lack of understanding: delete later 
            `uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                (h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GOERRWRPULL) -> {data == 512'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff; goerr == 'h1;}
              }
            );
            */
          end
          join
        end else if(cxl_cfg_obj_h.hdm == GEET_CXL_HDM_D) begin
          `uvm_do_on_with(
            m2s_req_seq_item_h,
            p_sequencer.host_m2s_req_seqr,
            {
              valid == 'h1;
              address == d2h_req_seq_item_rcvd.address;
              memopcode inside {GEET_CXL_MEM_OPCODE_MEMWRFWD};
              tag == d2h_req_seq_item_rcvd.cqid;
              snptype == GEET_CXL_MEM_SNPTYP_MEMSNPNOOP;
              metafield == GEET_CXL_MEM_MF_METAFIELD_META0STATE;
              //metavalue inside {GEET_CXL_MEM_MV_METAVALUE_INVALID};//TODO:dont know if this is true
            }
          );
        end
      end else if(d2h_req_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_WRINV}) begin
        fork 
          begin
            `uvm_do_on_with(
              h2d_rsp_seq_item_h,
              p_sequencer.host_h2d_rsp_seqr,
              {
                valid == 'h1;
                opcode inside {GEET_CXL_CACHE_OPCODE_FASTGOWRPULL, GEET_CXL_CACHE_OPCODE_GOERRWRPULL} ;
                cqid == d2h_req_seq_item_rcvd.cqid;
              }
            );
            /* this is wrong due to incorrect understanding:delete later
            `uvm_do_on_with(
              h2d_data_seq_item_h,
              p_sequencer.host_h2d_data_seqr,
              {
                valid == 'h1;
                cqid == d2h_req_seq_item_rcvd.cqid;
                (h2d_rsp_seq_item_h.opcode == GEET_CXL_CACHE_OPCODE_GOERRWRPULL) -> {
                  data == 512'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff; 
                  goerr == 'h1;
                  }
                }
              );*/
          end
        join
      end
    endtask

//understand this this too shall be useful in next gen but not in CXLv1.1
    task d2h_rsp_data_responder_h2d_rsp_data();
/*      d2h_rsp_seq_item_rcvd = p_sequencer.host_d2h_rsp_seqr.host_d2h_rsp_fifo.get();
      d2h_data_seq_item_rcvd = p_sequencer.host_d2h_data_seqr.host_d2h_data_fifo.get();
      if(d2h_rsp_seq_item_rcvd.opcode inside {GEET_CXL_CACHE_OPCODE_RSPVHITV, GEET_CXL_CACHE_OPCODE_RSPIHITI}) begin
        fork 
          begin
            if(h2d_req_id_aa.exists(d2h_rsp_seq_item_rcvd.uqid) && (h2d_req_id_aa[d2h_rsp_seq_item_rcvd.uqid] != GEET_CXL_CACHE_OPCODE_RDCURR)) begin
              `uvm_do_on_with(
                h2d_rsp_seq_item_h,
                p_sequencer.host_h2d_rsp_seqr,
                {
                  valid == 'h1;
                  opcode == ;
                  rspdata == d2h_rsp_seq_item_rcvd.uqid;
                  cqid == d2h_rsp_seq_item_rcvd.uqid;
                }
              );
            end
          end
          begin
            if(h2d_req_id_aa.exists(d2h_rsp_seq_item_rcvd.uqid) && (h2d_req_id_aa[d2h_rsp_seq_item_rcvd.uqid] != GEET_CXL_CACHE_OPCODE_RDCURR)) begin
              `uvm_do_on_with(
                h2d_data_seq_item_h,
                p_sequencer.host_h2d_data_seqr,
                {
                  valid == 'h1;
                  cqid == d2h_rsp_seq_item_rcvd.uqid;
                  data == d2h_data_seq_item_rcvd.data;
                }
              );
            end
          end
        join
      end
 */   endtask

  endclass

  class cxl_reset_seq extends uvm_sequence;
    `uvm_object_utils(cxl_reset_seq)
    `uvm_declare_p_sequencer(cxl_cm_vsequencer)
    rand int rst_cycles;
    d2h_req_seq_item   host_d2h_req_seq_item_h;
    d2h_req_seq_item   dev_d2h_req_seq_item_h;
    d2h_rsp_seq_item   host_d2h_rsp_seq_item_h;
    d2h_rsp_seq_item   dev_d2h_rsp_seq_item_h;
    d2h_data_seq_item  host_d2h_data_seq_item_h;
    d2h_data_seq_item  dev_d2h_data_seq_item_h;
    h2d_req_seq_item   host_h2d_req_seq_item_h;
    h2d_req_seq_item   dev_h2d_req_seq_item_h;
    h2d_rsp_seq_item   host_h2d_rsp_seq_item_h;
    h2d_rsp_seq_item   dev_h2d_rsp_seq_item_h;
    h2d_data_seq_item  host_h2d_data_seq_item_h;
    h2d_data_seq_item  dev_h2d_data_seq_item_h;
    m2s_req_seq_item   host_m2s_req_seq_item_h;
    m2s_req_seq_item   dev_m2s_req_seq_item_h;
    m2s_rwd_seq_item   host_m2s_rwd_seq_item_h;
    m2s_rwd_seq_item   dev_m2s_rwd_seq_item_h;
    s2m_ndr_seq_item   host_s2m_ndr_seq_item_h;
    s2m_ndr_seq_item   dev_s2m_ndr_seq_item_h;
    s2m_drs_seq_item   host_s2m_drs_seq_item_h;
    s2m_drs_seq_item   dev_s2m_drs_seq_item_h;
    cxl_cfg_obj        cxl_cfg_obj_h;

    constraint rst_cycles_c{
      soft rst_cycles == 10;
    }

    function new(string name = "cxl_reset_seq");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructing %s", get_full_name()), UVM_DEBUG)
    endfunction

    task body();
      `uvm_info(get_type_name(), $sformatf("starting reset_seq"), UVM_HIGH)
      if(!uvm_resource_db#(cxl_cfg_obj)::read_by_name("", "cxl_cfg_obj_h", cxl_cfg_obj_h)) begin
        `uvm_fatal("CXL_CFG_OBJ", "cxl_cfg_obj not found")
      end
      fork
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_d2h_req_seq_item_h,    p_sequencer.dev_d2h_req_seqr,   {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_d2h_rsp_seq_item_h,    p_sequencer.dev_d2h_rsp_seqr,   {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_d2h_data_seq_item_h,   p_sequencer.dev_d2h_data_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_h2d_req_seq_item_h,    p_sequencer.dev_h2d_req_seqr,   {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_h2d_rsp_seq_item_h,    p_sequencer.dev_h2d_rsp_seqr,   {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_h2d_data_seq_item_h,   p_sequencer.dev_h2d_data_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_d2h_req_seq_item_h,   p_sequencer.host_d2h_req_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_d2h_rsp_seq_item_h,   p_sequencer.host_d2h_rsp_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_d2h_data_seq_item_h,  p_sequencer.host_d2h_data_seqr, {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_h2d_req_seq_item_h,   p_sequencer.host_h2d_req_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_h2d_rsp_seq_item_h,   p_sequencer.host_h2d_rsp_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_h2d_data_seq_item_h,  p_sequencer.host_h2d_data_seqr, {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_m2s_req_seq_item_h,   p_sequencer.host_m2s_req_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_m2s_req_seq_item_h,    p_sequencer.dev_m2s_req_seqr,   {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_m2s_rwd_seq_item_h,   p_sequencer.host_m2s_rwd_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_m2s_rwd_seq_item_h,    p_sequencer.dev_m2s_rwd_seqr,   {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_s2m_ndr_seq_item_h,   p_sequencer.host_s2m_ndr_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on_with(host_s2m_drs_seq_item_h,   p_sequencer.host_s2m_drs_seqr,  {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_s2m_ndr_seq_item_h,    p_sequencer.dev_s2m_ndr_seqr,   {reset_cycles == rst_cycles;});
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on_with(dev_s2m_drs_seq_item_h,    p_sequencer.dev_s2m_drs_seqr,   {reset_cycles == rst_cycles;});
      join
      `uvm_info(get_type_name(), $sformatf("stopping reset_seq"), UVM_HIGH)
    endtask

  endclass

  class cxl_configure_seq extends uvm_sequence;
    `uvm_object_utils(cxl_configure_seq)
    `uvm_declare_p_sequencer(cxl_cm_vsequencer)    

    d2h_req_seq_item   dev_d2h_req_seq_item_h;
    d2h_rsp_seq_item   dev_d2h_rsp_seq_item_h;
    d2h_data_seq_item  dev_d2h_data_seq_item_h;
    h2d_req_seq_item   host_h2d_req_seq_item_h;
    h2d_rsp_seq_item   host_h2d_rsp_seq_item_h;
    h2d_data_seq_item  host_h2d_data_seq_item_h;
    m2s_req_seq_item   host_m2s_req_seq_item_h;
    m2s_rwd_seq_item   host_m2s_rwd_seq_item_h;
    s2m_ndr_seq_item   dev_s2m_ndr_seq_item_h;
    s2m_drs_seq_item   dev_s2m_drs_seq_item_h;
    cxl_cfg_obj        cxl_cfg_obj_h;

    function new(string name = "cxl_configure_seq");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructing %s", get_full_name()), UVM_DEBUG)
    endfunction

    task body();
      `uvm_info(get_type_name(), $sformatf("starting reset_seq"), UVM_HIGH)
      if(!uvm_resource_db#(cxl_cfg_obj)::read_by_name("", "cxl_cfg_obj_h", cxl_cfg_obj_h)) begin
        `uvm_fatal("CXL_CFG_OBJ", "cxl_cfg_obj not found")
      end
      fork
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on(dev_d2h_req_seq_item_h,    p_sequencer.dev_d2h_req_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on(dev_d2h_rsp_seq_item_h,    p_sequencer.dev_d2h_rsp_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on(dev_d2h_data_seq_item_h,   p_sequencer.dev_d2h_data_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on(host_h2d_req_seq_item_h,   p_sequencer.host_h2d_req_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on(host_h2d_rsp_seq_item_h,   p_sequencer.host_h2d_rsp_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) `uvm_do_on(host_h2d_data_seq_item_h,  p_sequencer.host_h2d_data_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on(host_m2s_req_seq_item_h,   p_sequencer.host_m2s_req_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on(host_m2s_rwd_seq_item_h,   p_sequencer.host_m2s_rwd_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on(dev_s2m_ndr_seq_item_h,    p_sequencer.dev_s2m_ndr_seqr);
        if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_3, GEET_CXL_TYPE_2}) `uvm_do_on(dev_s2m_drs_seq_item_h,    p_sequencer.dev_s2m_drs_seqr);
      join
      `uvm_info(get_type_name(), $sformatf("stopping reset_seq"), UVM_HIGH)

    endtask

  endclass

  class cxl_vseq extends uvm_sequence;
    `uvm_object_utils(cxl_vseq)
    `uvm_declare_p_sequencer(cxl_cm_vsequencer)
    cxl_cfg_obj           cxl_cfg_obj_h;
    dev_d2h_req_seq       dev_d2h_req_seq_h;
    host_h2d_req_seq      host_h2d_req_seq_h;
    host_m2s_req_seq      host_m2s_req_seq_h;
    host_m2s_rwd_seq      host_m2s_rwd_seq_h;
    cxl_cm_responder_seq  cxl_cm_responder_seq_h;

    function new(string name = "cxl_vseq");
      super.new(name);
      `uvm_info(get_type_name(), $sformatf("constructing %s", get_full_name()), UVM_DEBUG)
    endfunction

    task body();
      if(!uvm_resource_db#(cxl_cfg_obj)::read_by_name("", "cxl_cfg_obj_h", cxl_cfg_obj_h)) begin
        `uvm_fatal("CXL_CFG_OBJ", "cxl_cfg_obj not found")
      end
      fork 
        begin
          if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
            `uvm_info(get_type_name(), $sformatf("starting dev_d2h_req_seq"), UVM_HIGH)
            `uvm_do_on_with(dev_d2h_req_seq_h, p_sequencer, {num_trans == 1;});
            `uvm_info(get_type_name(), $sformatf("completed dev_d2h_req_seq"), UVM_HIGH)  
          end
        end
        begin
          if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_1, GEET_CXL_TYPE_2}) begin
            `uvm_info(get_type_name(), $sformatf("starting host_h2d_req_seq"), UVM_HIGH)
            `uvm_do_on_with(host_h2d_req_seq_h, p_sequencer, {num_trans == 1;});
            `uvm_info(get_type_name(), $sformatf("completed host_h2d_req_seq"), UVM_HIGH)
          end
        end
        begin
          if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2, GEET_CXL_TYPE_3}) begin
            `uvm_info(get_type_name(), $sformatf("starting host_m2s_req_seq"), UVM_HIGH)
            `uvm_do_on_with(host_m2s_req_seq_h, p_sequencer, {num_trans == 1;});
            `uvm_info(get_type_name(), $sformatf("completed host_m2s_req_seq"), UVM_HIGH)
          end
        end
        begin
          if(cxl_cfg_obj_h.cxl_type inside {GEET_CXL_TYPE_2, GEET_CXL_TYPE_3}) begin
            `uvm_info(get_type_name(), $sformatf("starting host_m2s_rwd_seq"), UVM_HIGH)
            `uvm_do_on_with(host_m2s_rwd_seq_h, p_sequencer, {num_trans == 1;});
            `uvm_info(get_type_name(), $sformatf("completed host_m2s_rwd_seq"), UVM_HIGH)
          end
        end
        begin
          `uvm_info(get_type_name(), $sformatf("starting cxl_cm_responder_seq"), UVM_HIGH)
          `uvm_do_on(cxl_cm_responder_seq_h, p_sequencer);
          `uvm_info(get_type_name(), $sformatf("completed cxl_cm_responder_seq"), UVM_HIGH)
        end
      join;
    endtask

  endclass

  class cxl_base_test extends uvm_test;
    `uvm_component_utils(cxl_base_test)
    cxl_cm_env cxl_cm_env_h;
    cxl_reset_seq cxl_reset_seq_h;
    cxl_configure_seq cxl_configure_seq_h;
    cxl_vseq cxl_vseq_h;

    function new(string name = "cxl_base_test", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("constructing %s", get_full_name()), UVM_DEBUG)
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("entering %s build_phase", get_full_name()), UVM_HIGH)
      cxl_cm_env_h = cxl_cm_env::type_id::create("cxl_cm_env_h", this);
      `uvm_info(get_type_name(), $sformatf("exiting %s build_phase", get_full_name()), UVM_HIGH)
    endfunction     

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      `uvm_info(get_type_name(), $sformatf("entering %s reset_phase", get_full_name()), UVM_HIGH)
      phase.raise_objection(this);
      cxl_reset_seq_h = cxl_reset_seq::type_id::create("cxl_reset_seq_h", this);
      if(cxl_reset_seq_h.randomize() == 0) begin
        `uvm_fatal(get_type_name(), $sformatf("randomization failure", get_full_name));
      end
      cxl_reset_seq_h.start(cxl_cm_env_h.cxl_cm_vseqr);
      phase.drop_objection(this);
      `uvm_info(get_type_name(), $sformatf("exiting %s reset_phase", get_full_name()), UVM_HIGH)
    endtask
    
    virtual task configure_phase(uvm_phase phase);
      super.configure_phase(phase);
      `uvm_info(get_type_name(), $sformatf("entering %s configure_phase", get_full_name()), UVM_HIGH)
      phase.raise_objection(this);
      cxl_configure_seq_h = cxl_configure_seq::type_id::create("cxl_configure_seq_h", this);
      cxl_configure_seq_h.start(cxl_cm_env_h.cxl_cm_vseqr);
      phase.drop_objection(this);
      `uvm_info(get_type_name(), $sformatf("exiting %s configure_phase", get_full_name()), UVM_HIGH)
    endtask

    virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("entering %s run_phase", get_full_name()), UVM_HIGH)
      phase.raise_objection(this);
      cxl_vseq_h = cxl_vseq::type_id::create("cxl_vseq_h", this);
      cxl_vseq_h.start(cxl_cm_env_h.cxl_cm_vseqr);
      phase.drop_objection(this);
      `uvm_info(get_type_name(), $sformatf("exiting %s run_phase", get_full_name()), UVM_HIGH)
    endtask

  endclass

endmodule