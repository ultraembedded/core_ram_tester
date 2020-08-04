//-----------------------------------------------------------------
//                         RAM Tester
//                            V0.1
//                     Ultra-Embedded.com
//                       Copyright 2020
//
//                   admin@ultra-embedded.com
//
//                     License: Apache 2.0
//-----------------------------------------------------------------
// Copyright 2020 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------

`include "ram_tester_defs.v"

//-----------------------------------------------------------------
// Module:  RAM Tester Peripheral
//-----------------------------------------------------------------
module ram_tester
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter AXI_ID           = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input          clk_i
    ,input          rst_i
    ,input          cfg_awvalid_i
    ,input  [31:0]  cfg_awaddr_i
    ,input          cfg_wvalid_i
    ,input  [31:0]  cfg_wdata_i
    ,input  [3:0]   cfg_wstrb_i
    ,input          cfg_bready_i
    ,input          cfg_arvalid_i
    ,input  [31:0]  cfg_araddr_i
    ,input          cfg_rready_i
    ,input          outport_awready_i
    ,input          outport_wready_i
    ,input          outport_bvalid_i
    ,input  [1:0]   outport_bresp_i
    ,input  [3:0]   outport_bid_i
    ,input          outport_arready_i
    ,input          outport_rvalid_i
    ,input  [31:0]  outport_rdata_i
    ,input  [1:0]   outport_rresp_i
    ,input  [3:0]   outport_rid_i
    ,input          outport_rlast_i

    // Outputs
    ,output         cfg_awready_o
    ,output         cfg_wready_o
    ,output         cfg_bvalid_o
    ,output [1:0]   cfg_bresp_o
    ,output         cfg_arready_o
    ,output         cfg_rvalid_o
    ,output [31:0]  cfg_rdata_o
    ,output [1:0]   cfg_rresp_o
    ,output         outport_awvalid_o
    ,output [31:0]  outport_awaddr_o
    ,output [3:0]   outport_awid_o
    ,output [7:0]   outport_awlen_o
    ,output [1:0]   outport_awburst_o
    ,output         outport_wvalid_o
    ,output [31:0]  outport_wdata_o
    ,output [3:0]   outport_wstrb_o
    ,output         outport_wlast_o
    ,output         outport_bready_o
    ,output         outport_arvalid_o
    ,output [31:0]  outport_araddr_o
    ,output [3:0]   outport_arid_o
    ,output [7:0]   outport_arlen_o
    ,output [1:0]   outport_arburst_o
    ,output         outport_rready_o
);

//-----------------------------------------------------------------
// Write address / data split
//-----------------------------------------------------------------
// Address but no data ready
reg awvalid_q;

// Data but no data ready
reg wvalid_q;

wire wr_cmd_accepted_w  = (cfg_awvalid_i && cfg_awready_o) || awvalid_q;
wire wr_data_accepted_w = (cfg_wvalid_i  && cfg_wready_o)  || wvalid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    awvalid_q <= 1'b0;
else if (cfg_awvalid_i && cfg_awready_o && !wr_data_accepted_w)
    awvalid_q <= 1'b1;
else if (wr_data_accepted_w)
    awvalid_q <= 1'b0;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    wvalid_q <= 1'b0;
else if (cfg_wvalid_i && cfg_wready_o && !wr_cmd_accepted_w)
    wvalid_q <= 1'b1;
else if (wr_cmd_accepted_w)
    wvalid_q <= 1'b0;

//-----------------------------------------------------------------
// Capture address (for delayed data)
//-----------------------------------------------------------------
reg [7:0] wr_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    wr_addr_q <= 8'b0;
else if (cfg_awvalid_i && cfg_awready_o)
    wr_addr_q <= cfg_awaddr_i[7:0];

wire [7:0] wr_addr_w = awvalid_q ? wr_addr_q : cfg_awaddr_i[7:0];

//-----------------------------------------------------------------
// Retime write data
//-----------------------------------------------------------------
reg [31:0] wr_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    wr_data_q <= 32'b0;
else if (cfg_wvalid_i && cfg_wready_o)
    wr_data_q <= cfg_wdata_i;

//-----------------------------------------------------------------
// Request Logic
//-----------------------------------------------------------------
wire read_en_w  = cfg_arvalid_i & cfg_arready_o;
wire write_en_w = wr_cmd_accepted_w && wr_data_accepted_w;

//-----------------------------------------------------------------
// Accept Logic
//-----------------------------------------------------------------
assign cfg_arready_o = ~cfg_rvalid_o;
assign cfg_awready_o = ~cfg_bvalid_o && ~cfg_arvalid_i && ~awvalid_q;
assign cfg_wready_o  = ~cfg_bvalid_o && ~cfg_arvalid_i && ~wvalid_q;


//-----------------------------------------------------------------
// Register ram_test_cfg
//-----------------------------------------------------------------
reg ram_test_cfg_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_cfg_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_CFG))
    ram_test_cfg_wr_q <= 1'b1;
else
    ram_test_cfg_wr_q <= 1'b0;

// ram_test_cfg_burst_len [internal]
reg [3:0]  ram_test_cfg_burst_len_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_cfg_burst_len_q <= 4'd`RAM_TEST_CFG_BURST_LEN_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_CFG))
    ram_test_cfg_burst_len_q <= cfg_wdata_i[`RAM_TEST_CFG_BURST_LEN_R];

wire [3:0]  ram_test_cfg_burst_len_out_w = ram_test_cfg_burst_len_q;


// ram_test_cfg_read [internal]
reg        ram_test_cfg_read_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_cfg_read_q <= 1'd`RAM_TEST_CFG_READ_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_CFG))
    ram_test_cfg_read_q <= cfg_wdata_i[`RAM_TEST_CFG_READ_R];

wire        ram_test_cfg_read_out_w = ram_test_cfg_read_q;


// ram_test_cfg_rnd_delay [internal]
reg        ram_test_cfg_rnd_delay_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_cfg_rnd_delay_q <= 1'd`RAM_TEST_CFG_RND_DELAY_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_CFG))
    ram_test_cfg_rnd_delay_q <= cfg_wdata_i[`RAM_TEST_CFG_RND_DELAY_R];

wire        ram_test_cfg_rnd_delay_out_w = ram_test_cfg_rnd_delay_q;


// ram_test_cfg_incr [auto_clr]
reg        ram_test_cfg_incr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_cfg_incr_q <= 1'd`RAM_TEST_CFG_INCR_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_CFG))
    ram_test_cfg_incr_q <= cfg_wdata_i[`RAM_TEST_CFG_INCR_R];
else
    ram_test_cfg_incr_q <= 1'd`RAM_TEST_CFG_INCR_DEFAULT;

wire        ram_test_cfg_incr_out_w = ram_test_cfg_incr_q;


// ram_test_cfg_ones [auto_clr]
reg        ram_test_cfg_ones_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_cfg_ones_q <= 1'd`RAM_TEST_CFG_ONES_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_CFG))
    ram_test_cfg_ones_q <= cfg_wdata_i[`RAM_TEST_CFG_ONES_R];
else
    ram_test_cfg_ones_q <= 1'd`RAM_TEST_CFG_ONES_DEFAULT;

wire        ram_test_cfg_ones_out_w = ram_test_cfg_ones_q;


// ram_test_cfg_zero [auto_clr]
reg        ram_test_cfg_zero_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_cfg_zero_q <= 1'd`RAM_TEST_CFG_ZERO_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_CFG))
    ram_test_cfg_zero_q <= cfg_wdata_i[`RAM_TEST_CFG_ZERO_R];
else
    ram_test_cfg_zero_q <= 1'd`RAM_TEST_CFG_ZERO_DEFAULT;

wire        ram_test_cfg_zero_out_w = ram_test_cfg_zero_q;


//-----------------------------------------------------------------
// Register ram_test_base
//-----------------------------------------------------------------
reg ram_test_base_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_base_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_BASE))
    ram_test_base_wr_q <= 1'b1;
else
    ram_test_base_wr_q <= 1'b0;

// ram_test_base_addr [internal]
reg [31:0]  ram_test_base_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_base_addr_q <= 32'd`RAM_TEST_BASE_ADDR_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_BASE))
    ram_test_base_addr_q <= cfg_wdata_i[`RAM_TEST_BASE_ADDR_R];

wire [31:0]  ram_test_base_addr_out_w = ram_test_base_addr_q;


//-----------------------------------------------------------------
// Register ram_test_end
//-----------------------------------------------------------------
reg ram_test_end_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_end_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_END))
    ram_test_end_wr_q <= 1'b1;
else
    ram_test_end_wr_q <= 1'b0;

// ram_test_end_addr [internal]
reg [31:0]  ram_test_end_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_end_addr_q <= 32'd`RAM_TEST_END_ADDR_DEFAULT;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_END))
    ram_test_end_addr_q <= cfg_wdata_i[`RAM_TEST_END_ADDR_R];

wire [31:0]  ram_test_end_addr_out_w = ram_test_end_addr_q;


//-----------------------------------------------------------------
// Register ram_test_sts
//-----------------------------------------------------------------
reg ram_test_sts_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_sts_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_STS))
    ram_test_sts_wr_q <= 1'b1;
else
    ram_test_sts_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register ram_test_current
//-----------------------------------------------------------------
reg ram_test_current_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_current_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_CURRENT))
    ram_test_current_wr_q <= 1'b1;
else
    ram_test_current_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register ram_test_time
//-----------------------------------------------------------------
reg ram_test_time_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_time_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_TIME))
    ram_test_time_wr_q <= 1'b1;
else
    ram_test_time_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register ram_test_errors
//-----------------------------------------------------------------
reg ram_test_errors_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_errors_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_ERRORS))
    ram_test_errors_wr_q <= 1'b1;
else
    ram_test_errors_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register ram_test_last
//-----------------------------------------------------------------
reg ram_test_last_wr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    ram_test_last_wr_q <= 1'b0;
else if (write_en_w && (wr_addr_w[7:0] == `RAM_TEST_LAST))
    ram_test_last_wr_q <= 1'b1;
else
    ram_test_last_wr_q <= 1'b0;


wire        ram_test_sts_busy_in_w;
wire [31:0]  ram_test_current_addr_in_w;
wire [31:0]  ram_test_time_cycles_in_w;
wire [31:0]  ram_test_errors_count_in_w;
wire [31:0]  ram_test_last_rd_data_in_w;


//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (cfg_araddr_i[7:0])

    `RAM_TEST_CFG:
    begin
        data_r[`RAM_TEST_CFG_BURST_LEN_R] = ram_test_cfg_burst_len_q;
        data_r[`RAM_TEST_CFG_READ_R] = ram_test_cfg_read_q;
        data_r[`RAM_TEST_CFG_RND_DELAY_R] = ram_test_cfg_rnd_delay_q;
    end
    `RAM_TEST_BASE:
    begin
        data_r[`RAM_TEST_BASE_ADDR_R] = ram_test_base_addr_q;
    end
    `RAM_TEST_END:
    begin
        data_r[`RAM_TEST_END_ADDR_R] = ram_test_end_addr_q;
    end
    `RAM_TEST_STS:
    begin
        data_r[`RAM_TEST_STS_BUSY_R] = ram_test_sts_busy_in_w;
    end
    `RAM_TEST_CURRENT:
    begin
        data_r[`RAM_TEST_CURRENT_ADDR_R] = ram_test_current_addr_in_w;
    end
    `RAM_TEST_TIME:
    begin
        data_r[`RAM_TEST_TIME_CYCLES_R] = ram_test_time_cycles_in_w;
    end
    `RAM_TEST_ERRORS:
    begin
        data_r[`RAM_TEST_ERRORS_COUNT_R] = ram_test_errors_count_in_w;
    end
    `RAM_TEST_LAST:
    begin
        data_r[`RAM_TEST_LAST_RD_DATA_R] = ram_test_last_rd_data_in_w;
    end
    default :
        data_r = 32'b0;
    endcase
end

//-----------------------------------------------------------------
// RVALID
//-----------------------------------------------------------------
reg rvalid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rvalid_q <= 1'b0;
else if (read_en_w)
    rvalid_q <= 1'b1;
else if (cfg_rready_i)
    rvalid_q <= 1'b0;

assign cfg_rvalid_o = rvalid_q;

//-----------------------------------------------------------------
// Retime read response
//-----------------------------------------------------------------
reg [31:0] rd_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rd_data_q <= 32'b0;
else if (!cfg_rvalid_o || cfg_rready_i)
    rd_data_q <= data_r;

assign cfg_rdata_o = rd_data_q;
assign cfg_rresp_o = 2'b0;

//-----------------------------------------------------------------
// BVALID
//-----------------------------------------------------------------
reg bvalid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    bvalid_q <= 1'b0;
else if (write_en_w)
    bvalid_q <= 1'b1;
else if (cfg_bready_i)
    bvalid_q <= 1'b0;

assign cfg_bvalid_o = bvalid_q;
assign cfg_bresp_o  = 2'b0;




//-----------------------------------------------------------------
// Registers / Writes
//-----------------------------------------------------------------
wire [31:0] buffer_base_w     = {ram_test_base_addr_out_w[31:2], 2'b0};
wire [31:0] buffer_end_w      = {ram_test_end_addr_out_w[31:2],  2'b0};
wire        cfg_zero_w        = ram_test_cfg_zero_out_w;
wire        cfg_ones_w        = ram_test_cfg_ones_out_w;
wire        cfg_incr_w        = ram_test_cfg_incr_out_w;
wire        cfg_dly_w         = ram_test_cfg_rnd_delay_out_w;
wire        cfg_read_w        = ram_test_cfg_read_out_w;

wire        awvalid_w;
wire        arvalid_w;
wire [31:0] axaddr_w;
wire [7:0]  axlen_w;
wire        wvalid_w;
wire [31:0] wdata_w;
wire [3:0]  wstrb_w;
wire        wlast_w;
wire        accept_w;

reg [31:0]  current_addr_q;
reg [31:0]  outstanding_q;
reg         burst_q;
reg [7:0]   burst_cnt_q;

//-----------------------------------------------------------------
// State machine
//-----------------------------------------------------------------
`define STATE_W  4

// Current state
localparam STATE_IDLE       = 4'd0;
localparam STATE_ZERO       = 4'd1;
localparam STATE_ONES       = 4'd2;
localparam STATE_INCR       = 4'd3;
localparam STATE_WAIT       = 4'd4;

reg [`STATE_W-1:0] state_q;
reg [`STATE_W-1:0] next_state_r;

always @ *
begin
    next_state_r = state_q;

    case (state_q)
    //-----------------------------------------
    // IDLE
    //-----------------------------------------
    STATE_IDLE :
    begin
        if (cfg_zero_w)
            next_state_r  = STATE_ZERO;
        else if (cfg_ones_w)
            next_state_r  = STATE_ONES;
        else if (cfg_incr_w)
            next_state_r  = STATE_INCR;
    end
    //-----------------------------------------
    // WRITE
    //-----------------------------------------
    STATE_ZERO, STATE_ONES, STATE_INCR:
    begin
        if (current_addr_q == buffer_end_w && !burst_q)
            next_state_r = STATE_WAIT;
    end
    //-----------------------------------------
    // WAIT
    //-----------------------------------------
    STATE_WAIT:
    begin
        if (outstanding_q == 32'd0)
            next_state_r = STATE_IDLE;
    end
    default :
       ;

    endcase
end

// Update state
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    state_q <= STATE_IDLE;
else
    state_q <= next_state_r;

wire [3:0] rand_w;

ram_lfsr
#(
    .BITS(4),
    .N(16),
    .POLYNOMIAL(16'h8810)
)
u_rand
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .random_o(rand_w)
);

//-----------------------------------------------------------------
// Transaction tracking
//-----------------------------------------------------------------
reg [31:0]  outstanding_r;

always @ *
begin
    outstanding_r = outstanding_q;

    if ((arvalid_w || awvalid_w) && accept_w)
        outstanding_r = outstanding_r + 32'd1;

    if (outport_bvalid_i && outport_bready_o)
        outstanding_r = outstanding_r - 32'd1;
    else if (outport_rvalid_i && outport_rlast_i && outport_rready_o)
        outstanding_r = outstanding_r - 32'd1;
end

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    outstanding_q <= 32'b0;
else
    outstanding_q <= outstanding_r;

//-----------------------------------------------------------------
// Delays
//-----------------------------------------------------------------
reg [3:0] delay_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    delay_q <= 4'b0;
else if ((awvalid_w || arvalid_w || wvalid_w) && accept_w)
    delay_q <= rand_w;
else if (delay_q != 4'b0)
    delay_q <= delay_q - 4'd1;

wire valid_w = (!cfg_dly_w || delay_q == 4'b0) &&
               (current_addr_q != buffer_end_w || burst_q) &&
               (state_q != STATE_IDLE && state_q != STATE_WAIT);

//-----------------------------------------------------------------
// Length
//-----------------------------------------------------------------
reg [7:0]   burst_length_r;
wire [31:0] remaining_w    = buffer_end_w - current_addr_q - 32'd4;
wire [31:0] remain_words_w = {2'b0, remaining_w[31:2]};
wire [31:0] max_words_w    = {28'b0, ram_test_cfg_burst_len_out_w};

always @ *
begin
    burst_length_r = 8'b0;

    if (remain_words_w > max_words_w)
        burst_length_r = max_words_w[7:0];
    else if (remain_words_w[7:0] == 8'd1 || 
             remain_words_w[7:0] == 8'd3 ||
             remain_words_w[7:0] == 8'd7)
        burst_length_r = remain_words_w[7:0];
end

wire [31:0] length_bytes_w = {22'b0, burst_length_r + 8'd1, 2'b0};

assign axlen_w = burst_length_r;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    burst_q <= 1'b0;
else if (awvalid_w && accept_w && axlen_w != 8'b0)
    burst_q <= 1'b1;
else if (wvalid_w && accept_w && burst_cnt_q == 8'b0)
    burst_q <= 1'b0;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    burst_cnt_q <= 8'b0;
else if (awvalid_w && accept_w)
    burst_cnt_q <= axlen_w - 8'd1;
else if (wvalid_w && accept_w)
    burst_cnt_q <= burst_cnt_q - 8'd1;

//-----------------------------------------------------------------
// Current Address
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    current_addr_q <= 32'b0;
else if ((state_q == STATE_IDLE) && (next_state_r != STATE_IDLE))
    current_addr_q <= buffer_base_w;
else if (state_q != STATE_IDLE && (awvalid_w || arvalid_w) && accept_w)
    current_addr_q <= {current_addr_q[31:2], 2'b0} + length_bytes_w;

assign awvalid_w                  = valid_w & ~burst_q & ~cfg_read_w;
assign arvalid_w                  = valid_w & cfg_read_w;
assign axaddr_w                   = current_addr_q;
assign ram_test_current_addr_in_w = current_addr_q;

//-----------------------------------------------------------------
// Data
//-----------------------------------------------------------------
reg [31:0] write_data_q;
reg        cfg_inc_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    cfg_inc_q <= 1'b0;
else if (state_q == STATE_IDLE && next_state_r == STATE_INCR)
    cfg_inc_q <= 1'b1;
else if (state_q == STATE_IDLE)
    cfg_inc_q <= 1'b0;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    write_data_q <= 32'b0;
else if ((state_q == STATE_IDLE) && (next_state_r != STATE_IDLE))
begin
    if (next_state_r == STATE_ONES)
        write_data_q <= 32'hFFFFFFFF;
    else if (next_state_r == STATE_INCR)
        write_data_q <= 32'h33221100;
    else
        write_data_q <= 32'b0;
end
else if (cfg_inc_q && wvalid_w && accept_w)
    write_data_q <= write_data_q + 32'h44444444;
else if (cfg_inc_q && outport_rvalid_i && outport_rready_o)
    write_data_q <= write_data_q + 32'h44444444;

assign wvalid_w = (burst_q | awvalid_w) & valid_w;
assign wdata_w  = write_data_q;
assign wstrb_w  = 4'hF;
assign wlast_w  = burst_q ? (burst_cnt_q == 8'd0) : (axlen_w == 8'd0);

//-----------------------------------------------------------------
// Error Counter
//-----------------------------------------------------------------
reg [31:0] error_count_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    error_count_q <= 32'b0;
else if ((state_q == STATE_IDLE) && (next_state_r != STATE_IDLE))
    error_count_q <= 32'b0;
else if (outport_rvalid_i && outport_rready_o && outport_rdata_i != write_data_q)
    error_count_q <= error_count_q + 32'd1;

assign ram_test_errors_count_in_w = error_count_q;

//-----------------------------------------------------------------
// Last Read Data
//-----------------------------------------------------------------
reg [31:0] last_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    last_data_q <= 32'b0;
else if ((state_q == STATE_IDLE) && (next_state_r != STATE_IDLE))
    last_data_q <= 32'b0;
else if (outport_rvalid_i && outport_rready_o)
    last_data_q <= outport_rdata_i;

assign ram_test_last_rd_data_in_w = last_data_q;

//-----------------------------------------------------------------
// Perf Counter
//-----------------------------------------------------------------
reg [31:0] cycles_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    cycles_q <= 32'b0;
else if ((state_q == STATE_IDLE) && (next_state_r != STATE_IDLE))
    cycles_q <= 32'b0;
else if (state_q != STATE_IDLE)
    cycles_q <= cycles_q + 32'd1;

assign ram_test_time_cycles_in_w = cycles_q - 32'd2; // Compensation for internals

//-----------------------------------------------------------------
// AXI port
//-----------------------------------------------------------------
wire        axi_valid_w;
wire        axi_awvalid_w;
wire        axi_arvalid_w;
wire        axi_wvalid_w;
wire        axi_pop_w;

generic_fifo
#(
     .WIDTH(1+1+32+8+1+32+4+1)
    ,.DEPTH(8)
    ,.ADDR_W(3)
)
u_request
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)

    ,.push_i(awvalid_w | arvalid_w | wvalid_w)
    ,.data_in_i({awvalid_w, arvalid_w, axaddr_w, axlen_w, wvalid_w, wdata_w, wstrb_w, wlast_w})
    ,.accept_o(accept_w)

    ,.valid_o(axi_valid_w)
    ,.data_out_o({axi_awvalid_w, axi_arvalid_w, outport_awaddr_o, outport_awlen_o, 
                  axi_wvalid_w, outport_wdata_o, outport_wstrb_o, outport_wlast_o})
    ,.pop_i(axi_pop_w)
);

reg axi_awvalid_q;
reg axi_wvalid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    axi_awvalid_q <= 1'b0;
else if (outport_awvalid_o && outport_awready_i && (outport_wvalid_o && !outport_wready_i))
    axi_awvalid_q <= 1'b1;
else if (axi_pop_w)
    axi_awvalid_q <= 1'b0;

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    axi_wvalid_q <= 1'b0;
else if (outport_wvalid_o && outport_wready_i && (outport_awvalid_o && !outport_awready_i))
    axi_wvalid_q <= 1'b1;
else if (axi_pop_w)
    axi_wvalid_q <= 1'b0;

assign outport_awvalid_o = axi_valid_w & axi_awvalid_w & ~axi_awvalid_q;
assign outport_awid_o    = AXI_ID;
assign outport_awburst_o = 2'b01;
assign outport_wvalid_o  = axi_valid_w & axi_wvalid_w  & ~axi_wvalid_q;
assign outport_bready_o  = 1'b1;

assign outport_arvalid_o = axi_valid_w & axi_arvalid_w;
assign outport_arid_o    = AXI_ID;
assign outport_araddr_o  = outport_awaddr_o;
assign outport_arlen_o   = outport_awlen_o;
assign outport_arburst_o = outport_awburst_o;
assign outport_rready_o  = 1'b1;

assign axi_pop_w = (outport_arvalid_o   && outport_arready_i) ||
                   (((outport_awvalid_o && outport_awready_i) || axi_awvalid_q || !axi_awvalid_w) &&
                    ((outport_wvalid_o  && outport_wready_i)  || axi_wvalid_q || !axi_wvalid_w) && !axi_arvalid_w);

//-----------------------------------------------------------------
// Status to register interface
//-----------------------------------------------------------------
assign ram_test_sts_busy_in_w = (state_q != STATE_IDLE);

endmodule

//-----------------------------------------------------------------
// ram_lfsr: LFSR used for pseudo random generation
//-----------------------------------------------------------------
module ram_lfsr
#(
  parameter POLYNOMIAL = 4'h9,
  parameter N          = 4,
  parameter BITS       = 4
)
(
  input  clk_i,
  input  rst_i,

  output [BITS-1:0] random_o
);

reg [N-1:0] data_q;
reg [N-1:0] data_next_r;
reg         feedback_r;

integer i;

always @* 
begin
  data_next_r = data_q;
  
  for (i=0; i<BITS; i=i+1)
  begin
    feedback_r  = ^( POLYNOMIAL & data_next_r);
    data_next_r = {data_next_r[N-2:0], ~feedback_r};
  end
end

always @ (posedge clk_i or posedge rst_i)
if (rst_i) 
    data_q <= 'b0;
else
    data_q <= data_next_r;

assign random_o = data_q[N-1:N-BITS];

endmodule

module generic_fifo
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter WIDTH   = 8,
    parameter DEPTH   = 4,
    parameter ADDR_W  = 2
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input               clk_i
    ,input               rst_i
    ,input  [WIDTH-1:0]  data_in_i
    ,input               push_i
    ,input               pop_i

    // Outputs
    ,output [WIDTH-1:0]  data_out_o
    ,output              accept_o
    ,output              valid_o
);

//-----------------------------------------------------------------
// Local Params
//-----------------------------------------------------------------
localparam COUNT_W = ADDR_W + 1;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [WIDTH-1:0]   ram_q[DEPTH-1:0];
reg [ADDR_W-1:0]  rd_ptr_q;
reg [ADDR_W-1:0]  wr_ptr_q;
reg [COUNT_W-1:0] count_q;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    count_q   <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};
end
else
begin
    // Push
    if (push_i & accept_o)
    begin
        ram_q[wr_ptr_q] <= data_in_i;
        wr_ptr_q        <= wr_ptr_q + 1;
    end

    // Pop
    if (pop_i & valid_o)
        rd_ptr_q      <= rd_ptr_q + 1;

    // Count up
    if ((push_i & accept_o) & ~(pop_i & valid_o))
        count_q <= count_q + 1;
    // Count down
    else if (~(push_i & accept_o) & (pop_i & valid_o))
        count_q <= count_q - 1;
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
/* verilator lint_off WIDTH */
assign valid_o       = (count_q != 0);
assign accept_o      = (count_q != DEPTH);
/* verilator lint_on WIDTH */

assign data_out_o    = ram_q[rd_ptr_q];



endmodule
