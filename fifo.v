//howard add test 060400
//howard add for merge conflict
module afifo_ctrl_typ1 (/*autoarg*/

fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_af_w,
fifo_af_r, fifo_ae_w, fifo_ae_r, fifo_full_w, fifo_full_r,
fifo_empty_w, fifo_empty_r, fifo_filled_depth_w,
fifo_filled_depth_r, fifo_waddr_w, fifo_waddr_r, fifo_raddr_w,
fifo_raddr_r,

clk_fifo_w, rst_fifo_w_n, clk_fifo_r, rst_fifo_r_n,
fifo_af_lvl_w, fifo_af_lvl_r, fifo_ae_lvl_w, fifo_ae_lvl_r,
fifo_clr_w, fifo_clr_r, fifo_req_w, fifo_req_r
);


parameter FIFO_DEPTH = 3;


input clk_fifo_w;
input rst_fifo_w_n;
input clk_fifo_r;
input rst_fifo_r_n;
input [FIFO_DEPTH-1:0] fifo_af_lvl_w;
input [FIFO_DEPTH-1:0] fifo_af_lvl_r;
input [FIFO_DEPTH-1:0] fifo_ae_lvl_w;
input [FIFO_DEPTH-1:0] fifo_ae_lvl_r;
input fifo_clr_w;
input fifo_clr_r;
input fifo_req_w;
input fifo_req_r;
output fifo_wr_w;
output fifo_rd_r;
output [FIFO_DEPTH-1:0] fifo_addr_w;
output [FIFO_DEPTH-1:0] fifo_addr_r;
output fifo_af_w;
output fifo_af_r;
output fifo_ae_w;
output fifo_ae_r;
output fifo_full_w;
output fifo_full_r;
output fifo_empty_w;
output fifo_empty_r;
output [FIFO_DEPTH:0] fifo_filled_depth_w;
output [FIFO_DEPTH:0] fifo_filled_depth_r;
output [FIFO_DEPTH:0] fifo_waddr_w;
output [FIFO_DEPTH:0] fifo_waddr_r;
output [FIFO_DEPTH:0] fifo_raddr_w;
output [FIFO_DEPTH:0] fifo_raddr_r;


wire fifo_req_w_mask;
wire fifo_req_r_mask;
wire [FIFO_DEPTH:0] wr_addr_bin_w_inc;
wire [FIFO_DEPTH:0] wr_addr_gray_w_inc;
wire [FIFO_DEPTH:0] wr_addr_gray_w_next;
reg [FIFO_DEPTH:0] wr_addr_gray_w;
reg [FIFO_DEPTH:0] wr_addr_bin_w;
reg [FIFO_DEPTH:0] wr_addr_gray_r_sync1;
reg [FIFO_DEPTH:0] wr_addr_gray_r_sync2;
reg [FIFO_DEPTH:0] wr_addr_bin_r;
wire [FIFO_DEPTH:0] rd_addr_bin_r_inc;
wire [FIFO_DEPTH:0] rd_addr_gray_r_inc;
wire [FIFO_DEPTH:0] rd_addr_gray_r_next;
reg [FIFO_DEPTH:0] rd_addr_gray_r;
reg [FIFO_DEPTH:0] rd_addr_bin_r;
reg [FIFO_DEPTH:0] rd_addr_gray_w_sync1;
reg [FIFO_DEPTH:0] rd_addr_gray_w_sync2;
reg [FIFO_DEPTH:0] rd_addr_bin_w;
wire fifo_af_w;
wire fifo_af_r;
wire fifo_ae_w;
wire fifo_ae_r;
wire fifo_full_w;
wire fifo_full_r;
wire fifo_empty_w;
wire fifo_empty_r;
wire [FIFO_DEPTH:0] fifo_filled_depth_w;
wire [FIFO_DEPTH:0] fifo_filled_depth_r;
wire [FIFO_DEPTH:0] fifo_waddr_w;
wire [FIFO_DEPTH:0] fifo_waddr_r;
wire [FIFO_DEPTH:0] fifo_raddr_w;
wire [FIFO_DEPTH:0] fifo_raddr_r;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0] fifo_addr_w;
wire [FIFO_DEPTH-1:0] fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full_w);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty_r);





assign wr_addr_bin_w_inc = wr_addr_bin_w + 1;
assign wr_addr_gray_w_inc = (wr_addr_bin_w_inc >> 1) ^ wr_addr_bin_w_inc;
assign wr_addr_gray_w_next = fifo_clr_w ? {(FIFO_DEPTH+1){1'b0}} :
	                     fifo_req_w_mask ? wr_addr_gray_w_inc :
			     wr_addr_gray_w;
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    wr_addr_gray_w <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_w <= #`RD wr_addr_gray_w_next;
  end
end
always @ (/*autosense*/wr_addr_gray_w) begin: wr_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH; i>=0; i=i-1) begin
    wr_addr_bin_w[i] = ^(wr_addr_gray_w>>i);
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    wr_addr_gray_r_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    wr_addr_gray_r_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_r_sync1 <= #`RD wr_addr_gray_w;
    wr_addr_gray_r_sync2 <= #`RD wr_addr_gray_r_sync1;
  end
end  
always @ (/*autosense*/wr_addr_gray_r_sync2) begin: wr_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    wr_addr_bin_r[i] = ^(wr_addr_gray_r_sync2>>i);
  end
end



assign rd_addr_bin_r_inc = rd_addr_bin_r + 1;
assign rd_addr_gray_r_inc = (rd_addr_bin_r_inc>>1) ^ rd_addr_bin_r_inc;
assign rd_addr_gray_r_next = fifo_clr_r ? {(FIFO_DEPTH+1){1'b0}} :
	                     fifo_req_r_mask ? rd_addr_gray_r_inc : 
			     rd_addr_gray_r;
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    rd_addr_gray_r <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_r <= #`RD rd_addr_gray_r_next;
  end
end
always @ (/*autosense*/rd_addr_gray_r) begin: rd_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH; i>=0; i=i-1) begin
    rd_addr_bin_r[i] = ^(rd_addr_gray_r>>i);
  end
end
always @(posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    rd_addr_gray_w_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    rd_addr_gray_w_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_w_sync1 <= #`RD rd_addr_gray_r;
    rd_addr_gray_w_sync2 <= #`RD rd_addr_gray_w_sync1;
  end
end
always @ (/*autosense*/rd_addr_gray_w_sync2) begin: rd_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_w[i] = ^(rd_addr_gray_w_sync2>>i);
  end
end





assign fifo_af_w = ((wr_addr_bin_w - rd_addr_bin_w) >= ({1'b0, fifo_af_lvl_w}));
assign fifo_af_r = ((wr_addr_bin_r - rd_addr_bin_r) >= ({1'b0, fifo_af_lvl_r}));



assign fifo_ae_w = ((wr_addr_bin_w - rd_addr_bin_w) <= ({1'b0, fifo_ae_lvl_w}));
assign fifo_ae_r = ((wr_addr_bin_r - rd_addr_bin_r) <= ({1'b0, fifo_ae_lvl_r}));



assign fifo_full_w = (rd_addr_bin_w[FIFO_DEPTH] != wr_addr_bin_w[FIFO_DEPTH]) &
	             (rd_addr_bin_w[FIFO_DEPTH-1:0] == wr_addr_bin_w[FIFO_DEPTH-1:0]);
assign fifo_full_r = (rd_addr_bin_r[FIFO_DEPTH] != wr_addr_bin_r[FIFO_DEPTH]) & 
	             (rd_addr_bin_r[FIFO_DEPTH-1:0] == wr_addr_bin_r[FIFO_DEPTH-1:0]);



assign fifo_empty_w = (rd_addr_bin_w == wr_addr_bin_w);
assign fifo_empty_r = (rd_addr_bin_r == wr_addr_bin_r);



assign fifo_filled_depth_w = (wr_addr_bin_w - rd_addr_bin_w);
assign fifo_filled_depth_r = (wr_addr_bin_r - rd_addr_bin_r);



assign fifo_waddr_w = wr_addr_bin_w;
assign fifo_waddr_r = wr_addr_bin_r;
assign fifo_raddr_w = rd_addr_bin_w;
assign fifo_raddr_r = rd_addr_bin_r;


assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin_w[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin_r[FIFO_DEPTH-1:0];

endmodule











module afifo_ctrl_typ2 (/*autoarg*/

  fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_af_w,
  fifo_af_r, fifo_ae_w, fifo_ae_r, fifo_full_w, fifo_full_r,
  fifo_empty_w, fifo_empty_r, fifo_filled_depth_w,
  fifo_filled_depth_r, fifo_waddr_w, fifo_waddr_r, fifo_raddr_w,
  fifo_raddr_r,

  clk_fifo_w, rst_fifo_w_n, clk_fifo_r, rst_fifo_r_n,
  fifo_af_lvl_w, fifo_af_lvl_r, fifo_ae_lvl_w, fifo_ae_lvl_r,
  fifo_clr_w, fifo_clr_r, fifo_req_w, fifo_req_r
);


parameter FIFO_DEPTH = 3;


input clk_fifo_w;
input rst_fifo_w_n;
input clk_fifo_r;
input rst_fifo_r_n;
input [FIFO_DEPTH-1:0] fifo_af_lvl_w;
input [FIFO_DEPTH-1:0] fifo_af_lvl_r;
input [FIFO_DEPTH-1:0] fifo_ae_lvl_w;
input [FIFO_DEPTH-1:0] fifo_ae_lvl_r;
input fifo_clr_w;
input fifo_clr_r;
input fifo_req_w;
input fifo_req_r;
output fifo_wr_w;
output fifo_rd_r;
output [FIFO_DEPTH-1:0] fifo_addr_w;
output [FIFO_DEPTH-1:0] fifo_addr_r;
output fifo_af_w;
output fifo_af_r;
output fifo_ae_w;
output fifo_ae_r;
output fifo_full_w;
output fifo_full_r;
output fifo_empty_w;
output fifo_empty_r;
output [FIFO_DEPTH:0] fifo_filled_depth_w;
output [FIFO_DEPTH:0] fifo_filled_depth_r;
output [FIFO_DEPTH:0] fifo_waddr_r;
output [FIFO_DEPTH:0] fifo_waddr_w;
output [FIFO_DEPTH:0] fifo_raddr_r;
output [FIFO_DEPTH:0] fifo_raddr_w;


wire fifo_req_w_mask;
wire fifo_req_r_mask;
wire [FIFO_DEPTH:0] wr_addr_bin_w_inc;
wire [FIFO_DEPTH:0] wr_addr_gray_w_inc;
wire [FIFO_DEPTH:0] wr_addr_bin_w_next;
wire [FIFO_DEPTH:0] wr_addr_gray_w_next;
reg [FIFO_DEPTH:0] wr_addr_gray_w;
reg [FIFO_DEPTH:0] wr_addr_bin_w;
reg [FIFO_DEPTH:0] wr_addr_gray_r_sync1;
reg [FIFO_DEPTH:0] wr_addr_gray_r_sync2;
reg [FIFO_DEPTH:0] wr_addr_bin_r;
wire [FIFO_DEPTH:0] rd_addr_bin_r_inc;
wire [FIFO_DEPTH:0] rd_addr_gray_r_inc;
wire [FIFO_DEPTH:0] rd_addr_bin_r_next;
wire [FIFO_DEPTH:0] rd_addr_gray_r_next;
reg [FIFO_DEPTH:0] rd_addr_gray_r;
reg [FIFO_DEPTH:0] rd_addr_bin_r;
reg [FIFO_DEPTH:0] rd_addr_gray_w_sync1;
reg [FIFO_DEPTH:0] rd_addr_gray_w_sync2;
reg [FIFO_DEPTH:0] rd_addr_bin_w;
reg fifo_af_w;
reg fifo_af_r;
reg fifo_ae_w;
reg fifo_ae_r;
reg fifo_full_w;
reg fifo_full_r;
reg fifo_empty_w;
reg fifo_empty_r;
reg [FIFO_DEPTH:0] fifo_filled_depth_w;
reg [FIFO_DEPTH:0] fifo_filled_depth_r;
wire [FIFO_DEPTH:0] fifo_waddr_w;
wire [FIFO_DEPTH:0] fifo_waddr_r;
wire [FIFO_DEPTH:0] fifo_raddr_w;
wire [FIFO_DEPTH:0] fifo_raddr_r;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0] fifo_addr_w;
wire [FIFO_DEPTH-1:0] fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full_w);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty_r);





assign wr_addr_bin_w_inc = wr_addr_bin_w + 1;
assign wr_addr_gray_w_inc = (wr_addr_bin_w_inc >> 1) ^ wr_addr_bin_w_inc;
assign wr_addr_bin_w_next = fifo_clr_w ? {(FIFO_DEPTH+1){1'b0}} :
	                    fifo_req_w_mask ? wr_addr_bin_w_inc : 
			    wr_addr_bin_w;
assign wr_addr_gray_w_next = fifo_clr_w ? {(FIFO_DEPTH+1){1'b0}} :
	                     fifo_req_w_mask ? wr_addr_gray_w_inc :
			     wr_addr_gray_w;
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    wr_addr_gray_w <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_w <= #`RD wr_addr_gray_w_next;
  end
end
always @ (/*autosense*/wr_addr_gray_w)begin : wr_addr_bin_w_block
  integer i;
    for (i=FIFO_DEPTH;i>=0;i=i-1) begin
      wr_addr_bin_w[i] = ^(wr_addr_gray_w>>i);
    end
end
always @(posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    wr_addr_gray_r_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    wr_addr_gray_r_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_r_sync1 <= #`RD wr_addr_gray_w;
    wr_addr_gray_r_sync2 <= #`RD wr_addr_gray_r_sync1;
  end
end
always @ (/*autosense*/wr_addr_gray_r_sync2) begin: wr_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    wr_addr_bin_r[i] = ^(wr_addr_gray_r_sync2>>i);
  end
end



assign rd_addr_bin_r_inc = rd_addr_bin_r + 1;
assign rd_addr_gray_r_inc = (rd_addr_bin_r_inc>>1) ^ rd_addr_bin_r_inc;
assign rd_addr_bin_r_next = fifo_clr_r ? {(FIFO_DEPTH+1){1'b0}} :
	                    fifo_req_r_mask ? rd_addr_bin_r_inc :
			    rd_addr_bin_r;
assign rd_addr_gray_r_next = fifo_clr_r ? {(FIFO_DEPTH+1){1'b0}} :
	                     fifo_req_r_mask ? rd_addr_gray_r_inc :
			     rd_addr_gray_r;
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    rd_addr_gray_r <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_r <= #`RD rd_addr_gray_r_next;
  end
end
always @ (/*autosense*/rd_addr_gray_r) begin : rd_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_r[i] = ^ (rd_addr_gray_r>>i);
  end
end
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    rd_addr_gray_w_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    rd_addr_gray_w_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_w_sync1 <= #`RD rd_addr_gray_r;
    rd_addr_gray_w_sync2 <= #`RD rd_addr_gray_w_sync1;
  end
end
always @(/*autosense*/rd_addr_gray_w_sync2) begin: rd_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_w[i] = ^ (rd_addr_gray_w_sync2>>i);
  end
end





always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    fifo_af_w <= #`RD 1'b0;
  end
  else begin
    fifo_af_w <= #`RD ((wr_addr_bin_w_next - rd_addr_bin_w) >= ({1'b0, fifo_af_lvl_w}));
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n)begin
  if (!rst_fifo_r_n) begin
    fifo_af_r <= #`RD 1'b0;
  end
  else begin
    fifo_af_r <= #`RD ((wr_addr_bin_r - rd_addr_bin_r_next) >= ({1'b0, fifo_af_lvl_r}));
  end
end



always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    fifo_ae_w <= #`RD 1'b1;
  end
  else begin
    fifo_ae_w <= #`RD ((wr_addr_bin_w_next - rd_addr_bin_w) <= ({1'b0, fifo_ae_lvl_w}));
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    fifo_ae_r <= #`RD 1'b1;
  end
  else begin
    fifo_ae_r <= #`RD ((wr_addr_bin_r - rd_addr_bin_r_next) <= ({1'b0, fifo_ae_lvl_r}));
  end
end



always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    fifo_full_w <= #`RD 1'b0;
  end
  else begin
    fifo_full_w <= #`RD (rd_addr_bin_w[FIFO_DEPTH] != wr_addr_bin_w_next[FIFO_DEPTH]) & 
	                (rd_addr_bin_w[FIFO_DEPTH-1:0] == wr_addr_bin_w_next[FIFO_DEPTH-1:0]);
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    fifo_full_r <= #`RD 1'b0;
  end
  else begin
    fifo_full_r <= #`RD (rd_addr_bin_r_next[FIFO_DEPTH] != wr_addr_bin_r[FIFO_DEPTH]) &
	                (rd_addr_bin_r_next[FIFO_DEPTH-1:0] == wr_addr_bin_r[FIFO_DEPTH-1:0]);
  end
end



always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    fifo_empty_w <= #`RD 1'b1;
  end
  else begin
    fifo_empty_w <= #`RD (rd_addr_bin_w == wr_addr_bin_w_next);
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    fifo_empty_r <= #`RD 1'b1;
  end
  else begin
    fifo_empty_r <= #`RD (rd_addr_bin_r_next == wr_addr_bin_r);
  end
end



always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    fifo_filled_depth_w <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    fifo_filled_depth_w <= #`RD (wr_addr_bin_w_next - rd_addr_bin_w);
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    fifo_filled_depth_r <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    fifo_filled_depth_r <= #`RD (wr_addr_bin_r - rd_addr_bin_r_next);
  end
end



assign fifo_waddr_w = wr_addr_bin_w;
assign fifo_waddr_r = wr_addr_bin_r;
assign fifo_raddr_w = rd_addr_bin_w;
assign fifo_raddr_r = rd_addr_bin_r;

assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin_w[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin_r[FIFO_DEPTH-1:0];

endmodule












module afifo_ctrl_typ3 (/*autoarg*/

  fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_full_w,
  fifo_full_r, fifo_empty_w, fifo_empty_r,

  clk_fifo_w, rst_fifo_w_n, clk_fifo_r, rst_fifo_r_n, fifo_req_w,
  fifo_req_r
  );


parameter FIFO_DEPTH = 3;


input clk_fifo_w;
input rst_fifo_w_n;
input clk_fifo_r;
input rst_fifo_r_n;
input fifo_req_w;
input fifo_req_r;
output fifo_wr_w;
output fifo_rd_r;
output [FIFO_DEPTH-1:0] fifo_addr_w;
output [FIFO_DEPTH-1:0] fifo_addr_r;
output fifo_full_w;
output fifo_full_r;
output fifo_empty_w;
output fifo_empty_r;


wire fifo_req_w_mask;
wire fifo_req_r_mask;
wire [FIFO_DEPTH:0] wr_addr_bin_w_inc;
wire [FIFO_DEPTH:0] wr_addr_gray_w_inc;
wire [FIFO_DEPTH:0] wr_addr_gray_w_next;
reg [FIFO_DEPTH:0] wr_addr_gray_w;
reg [FIFO_DEPTH:0] wr_addr_bin_w;
reg [FIFO_DEPTH:0] wr_addr_gray_r_sync1;
reg [FIFO_DEPTH:0] wr_addr_gray_r_sync2;
reg [FIFO_DEPTH:0] wr_addr_bin_r;
wire [FIFO_DEPTH:0] rd_addr_bin_r_inc;
wire [FIFO_DEPTH:0] rd_addr_gray_r_inc;
wire [FIFO_DEPTH:0] rd_addr_gray_r_next;
reg [FIFO_DEPTH:0] rd_addr_gray_r;
reg [FIFO_DEPTH:0] rd_addr_bin_r;
reg [FIFO_DEPTH:0] rd_addr_gray_w_sync1;
reg [FIFO_DEPTH:0] rd_addr_gray_w_sync2;
reg [FIFO_DEPTH:0] rd_addr_bin_w;
wire fifo_full_w;
wire fifo_full_r;
wire fifo_empty_w;
wire fifo_empty_r;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0] fifo_addr_w;
wire [FIFO_DEPTH-1:0] fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full_w);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty_r);





assign wr_addr_bin_w_inc = wr_addr_bin_w + 1;
assign wr_addr_gray_w_inc = (wr_addr_bin_w_inc>>1) ^ wr_addr_bin_w_inc;
assign wr_addr_gray_w_next = fifo_req_w_mask ? wr_addr_gray_w_inc : wr_addr_gray_w;

always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    wr_addr_gray_w <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_w <= #`RD wr_addr_gray_w_next;
  end
end
always @ (/*autosense*/wr_addr_gray_w) begin: wr_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    wr_addr_bin_w[i] = ^(wr_addr_gray_w>>i);
  end
end
always @(posedge clk_fifo_r or negedge rst_fifo_r_n)begin
  if (!rst_fifo_r_n) begin
    wr_addr_gray_r_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    wr_addr_gray_r_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_r_sync1 <= #`RD wr_addr_gray_w;
    wr_addr_gray_r_sync2 <= #`RD wr_addr_gray_r_sync1;
  end
end
always @ (/*autosense*/wr_addr_gray_r_sync2) begin: wr_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    wr_addr_bin_r[i] = ^(wr_addr_gray_r_sync2>>i);
  end
end



assign rd_addr_bin_r_inc = rd_addr_bin_r + 1;
assign rd_addr_gray_r_inc = (rd_addr_bin_r_inc>>1) ^ rd_addr_bin_r_inc;
assign rd_addr_gray_r_next = fifo_req_r_mask ? rd_addr_gray_r_inc :
	                     rd_addr_gray_r;
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    rd_addr_gray_r <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_r <= #`RD rd_addr_gray_r_next;
  end
end
always @ (/*autosense*/rd_addr_gray_r) begin: rd_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_r[i] = ^(rd_addr_gray_r>>i);
  end
end
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    rd_addr_gray_w_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    rd_addr_gray_w_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_w_sync1 <= #`RD rd_addr_gray_r;
    rd_addr_gray_w_sync2 <= #`RD rd_addr_gray_w_sync1;
  end
end
always @ (/*autosense*/rd_addr_gray_w_sync2) begin: rd_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_w[i] = ^(rd_addr_gray_w_sync2>>i);
  end
end





assign fifo_full_w = (rd_addr_bin_w[FIFO_DEPTH] != wr_addr_bin_w[FIFO_DEPTH]) &
	             (rd_addr_bin_w[FIFO_DEPTH-1:0] == wr_addr_bin_w[FIFO_DEPTH-1:0]);
assign fifo_full_r = (rd_addr_bin_r[FIFO_DEPTH] != wr_addr_bin_r[FIFO_DEPTH]) &
	             (rd_addr_bin_r[FIFO_DEPTH-1:0] == wr_addr_bin_r[FIFO_DEPTH-1:0]);



assign fifo_empty_w = (rd_addr_bin_w == wr_addr_bin_w);
assign fifo_empty_r = (rd_addr_bin_r == wr_addr_bin_r);


assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin_w[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin_r[FIFO_DEPTH-1:0];

endmodule











module afifo_ctrl_typ4 (/*autoarg*/

  fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_full_w,
  fifo_full_r, fifo_empty_w, fifo_empty_r,

  clk_fifo_w, rst_fifo_w_n, clk_fifo_r, rst_fifo_r_n, fifo_req_w,
  fifo_req_r
  );


parameter FIFO_DEPTH = 3;


input clk_fifo_w;
input rst_fifo_w_n;
input clk_fifo_r;
input rst_fifo_r_n;
input fifo_req_w;
input fifo_req_r;
output fifo_wr_w;
output fifo_rd_r;
output [FIFO_DEPTH-1:0] fifo_addr_w;
output [FIFO_DEPTH-1:0] fifo_addr_r;
output fifo_full_w;
output fifo_full_r;
output fifo_empty_w;
output fifo_empty_r;


wire fifo_req_w_mask;
wire fifo_req_r_mask;
wire [FIFO_DEPTH:0] wr_addr_bin_w_inc;
wire [FIFO_DEPTH:0] wr_addr_gray_w_inc;
wire [FIFO_DEPTH:0] wr_addr_bin_w_next;
wire [FIFO_DEPTH:0] wr_addr_gray_w_next;
reg [FIFO_DEPTH:0] wr_addr_gray_w;
reg [FIFO_DEPTH:0] wr_addr_bin_w;
reg [FIFO_DEPTH:0] wr_addr_gray_r_sync1;
reg [FIFO_DEPTH:0] wr_addr_gray_r_sync2;
reg [FIFO_DEPTH:0] wr_addr_bin_r;
wire [FIFO_DEPTH:0] rd_addr_bin_r_inc;
wire [FIFO_DEPTH:0] rd_addr_gray_r_inc;
wire [FIFO_DEPTH:0] rd_addr_bin_r_next;
wire [FIFO_DEPTH:0] rd_addr_gray_r_next;
reg [FIFO_DEPTH:0] rd_addr_gray_r;
reg [FIFO_DEPTH:0] rd_addr_bin_r;
reg [FIFO_DEPTH:0] rd_addr_gray_w_sync1;
reg [FIFO_DEPTH:0] rd_addr_gray_w_sync2;
reg [FIFO_DEPTH:0] rd_addr_bin_w;
reg fifo_full_w;
reg fifo_full_r;
reg fifo_empty_w;
reg fifo_empty_r;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0] fifo_addr_w;
wire [FIFO_DEPTH-1:0] fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full_w);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty_r);





assign wr_addr_bin_w_inc = wr_addr_bin_w + 1;
assign wr_addr_gray_w_inc = (wr_addr_bin_w_inc>>1) ^ wr_addr_bin_w_inc;
assign wr_addr_bin_w_next = fifo_req_w_mask ? wr_addr_bin_w_inc : 
	                    wr_addr_bin_w;
assign wr_addr_gray_w_next = fifo_req_w_mask ? wr_addr_gray_w_inc :
	                     wr_addr_gray_w;
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    wr_addr_gray_w <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_w <= #`RD wr_addr_gray_w_next;
  end
end
always @ (/*autosense*/wr_addr_gray_w) begin: wr_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    wr_addr_bin_w[i] = ^(wr_addr_gray_w>>i);
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    wr_addr_gray_r_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    wr_addr_gray_r_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_r_sync1 <= #`RD wr_addr_gray_w;
    wr_addr_gray_r_sync2 <= #`RD wr_addr_gray_r_sync1;
  end
end
always @(/*autosense*/wr_addr_gray_r_sync2) begin:wr_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    wr_addr_bin_r[i] = ^(wr_addr_gray_r_sync2>>i);
  end
end
    


assign rd_addr_bin_r_inc = rd_addr_bin_r + 1;
assign rd_addr_gray_r_inc = (rd_addr_bin_r_inc>>1) ^ rd_addr_bin_r_inc;
assign rd_addr_bin_r_next = fifo_req_r_mask ? rd_addr_bin_r_inc :
	                    rd_addr_bin_r;
assign rd_addr_gray_r_next = fifo_req_r_mask ? rd_addr_gray_r_inc :
	                     rd_addr_gray_r;
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (~rst_fifo_r_n) begin
    rd_addr_gray_r <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_r <= #`RD rd_addr_gray_r_next;
  end
end
always @ (/*autosense*/rd_addr_gray_r) begin: rd_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_r[i] = ^(rd_addr_gray_r>>i);
  end
end
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    rd_addr_gray_w_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    rd_addr_gray_w_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_w_sync1 <= #`RD rd_addr_gray_r;
    rd_addr_gray_w_sync2 <= #`RD rd_addr_gray_w_sync1;
  end
end
always @ (/*autosense*/rd_addr_gray_w_sync2) begin: rd_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_w[i] = ^(rd_addr_gray_w_sync2>>i);
  end
end





always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (~rst_fifo_w_n) begin
    fifo_full_w <= #`RD 1'b0;
  end
  else begin
    fifo_full_w <= #`RD (rd_addr_bin_w[FIFO_DEPTH] != wr_addr_bin_w_next[FIFO_DEPTH]) &
	                (rd_addr_bin_w[FIFO_DEPTH-1:0] == wr_addr_bin_w_next[FIFO_DEPTH-1:0]); 
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (~rst_fifo_r_n) begin
    fifo_full_r <= #`RD 1'b0;
  end
  else begin
    fifo_full_r <= #`RD (rd_addr_bin_r_next[FIFO_DEPTH] != wr_addr_bin_r[FIFO_DEPTH]) &
	                (rd_addr_bin_r_next[FIFO_DEPTH-1:0] == wr_addr_bin_r[FIFO_DEPTH-1:0]); 
  end
end



always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (~rst_fifo_w_n) begin
    fifo_empty_w <= #`RD 1'b1;
  end
  else begin
    fifo_empty_w <= #`RD (rd_addr_bin_w == wr_addr_bin_w_next);
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    fifo_empty_r <= #`RD 1'b1;
  end
  else begin
    fifo_empty_r <= #`RD (rd_addr_bin_r_next == wr_addr_bin_r);
  end
end


assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin_w[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin_r[FIFO_DEPTH-1:0];

endmodule











module asfifo_ctrl_typ3 (/*autoarg*/

  fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_full_w,
  fifo_full_r, fifo_empty_w, fifo_empty_r,

  clk_fifo_w, rst_fifo_w_n, clk_fifo_r, rst_fifo_r_n, fifo_sync_en,
  fifo_clr_w, fifo_clr_r, fifo_req_w, fifo_req_r
  );
 
 
 parameter FIFO_DEPTH = 3;


 input clk_fifo_w;
 input rst_fifo_w_n;
 input clk_fifo_r;
 input rst_fifo_r_n;
 input fifo_sync_en;
 input fifo_clr_w;
 input fifo_clr_r;
 input fifo_req_w;
 input fifo_req_r;
 output fifo_wr_w;
 output fifo_rd_r;
 output [FIFO_DEPTH-1:0] fifo_addr_w;
 output [FIFO_DEPTH-1:0] fifo_addr_r;
 output fifo_full_w;
 output fifo_full_r;
 output fifo_empty_w;
 output fifo_empty_r;


 wire fifo_req_w_mask;
 wire fifo_req_r_mask;
 wire [FIFO_DEPTH:0] wr_addr_bin_w_inc;
 wire [FIFO_DEPTH:0] wr_addr_gray_w_inc;
 wire [FIFO_DEPTH:0] wr_addr_gray_w_next;
 reg [FIFO_DEPTH:0] wr_addr_gray_w;
 reg [FIFO_DEPTH:0] wr_addr_bin_w;
 reg [FIFO_DEPTH:0] wr_addr_gray_r_sync1;
 reg [FIFO_DEPTH:0] wr_addr_gray_r_sync2;
 reg [FIFO_DEPTH:0] wr_addr_gray_r_d;
 wire [FIFO_DEPTH:0] wr_addr_gray_r_mux;
 reg [FIFO_DEPTH:0] wr_addr_bin_r;
 wire [FIFO_DEPTH:0] rd_addr_bin_r_inc;
 wire [FIFO_DEPTH:0] rd_addr_gray_r_inc;
 wire [FIFO_DEPTH:0] rd_addr_gray_r_next;
 reg [FIFO_DEPTH:0] rd_addr_gray_r;
 reg [FIFO_DEPTH:0] rd_addr_bin_r;
 reg [FIFO_DEPTH:0] rd_addr_gray_w_sync1;
 reg [FIFO_DEPTH:0] rd_addr_gray_w_sync2;
 reg [FIFO_DEPTH:0] rd_addr_gray_w_d;
 wire [FIFO_DEPTH:0] rd_addr_gray_w_mux;
 reg [FIFO_DEPTH:0] rd_addr_bin_w;
 wire fifo_full_w;
wire  fifo_full_r;
wire fifo_empty_w;
wire fifo_empty_r;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0] fifo_addr_w;
wire [FIFO_DEPTH-1:0] fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full_w);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty_r);





assign wr_addr_bin_w_inc = wr_addr_bin_w + 1;
assign wr_addr_gray_w_inc = (wr_addr_bin_w_inc>>1) ^ wr_addr_bin_w_inc;
assign wr_addr_gray_w_next = fifo_clr_w ? {(FIFO_DEPTH+1){1'b0}} :
	                     fifo_req_w_mask ? wr_addr_gray_w_inc :
			     wr_addr_gray_w;
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (~rst_fifo_w_n) begin
    wr_addr_gray_w <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_w <= #`RD wr_addr_gray_w_next;
  end
end
always @ (/*autosense*/wr_addr_gray_w) begin: wr_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    wr_addr_bin_w[i] = ^(wr_addr_gray_w>>i);
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    wr_addr_gray_r_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    wr_addr_gray_r_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_r_sync1 <= #`RD wr_addr_gray_w;
    wr_addr_gray_r_sync2 <= #`RD wr_addr_gray_r_sync1;
  end
end
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    wr_addr_gray_r_d <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_gray_r_d <= #`RD wr_addr_gray_w;
  end
end
assign wr_addr_gray_r_mux = fifo_sync_en ? wr_addr_gray_r_d : wr_addr_gray_r_sync2;
always @ (/*autosense*/wr_addr_gray_r_mux) begin: wr_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    wr_addr_bin_r[i] = ^(wr_addr_gray_r_mux>>i);
  end
end



assign rd_addr_bin_r_inc = rd_addr_bin_r + 1;
assign rd_addr_gray_r_inc = (rd_addr_bin_r_inc>>1) ^ rd_addr_bin_r_inc;
assign rd_addr_gray_r_next = fifo_clr_r ? {(FIFO_DEPTH+1){1'b0}} :
	                     fifo_req_r_mask ? rd_addr_gray_r_inc :
			     rd_addr_gray_r;
always @ (posedge clk_fifo_r or negedge rst_fifo_r_n) begin
  if (!rst_fifo_r_n) begin
    rd_addr_gray_r <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_r <= #`RD rd_addr_gray_r_next;
  end
end
always @ (/*autosense*/rd_addr_gray_r) begin: rd_addr_bin_r_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_r[i] = ^(rd_addr_gray_r>>i);
  end
end
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    rd_addr_gray_w_sync1 <= #`RD {(FIFO_DEPTH+1){1'b0}};
    rd_addr_gray_w_sync2 <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_w_sync1 <= #`RD rd_addr_gray_r;
    rd_addr_gray_w_sync2 <= #`RD rd_addr_gray_w_sync1;
  end
end
always @ (posedge clk_fifo_w or negedge rst_fifo_w_n) begin
  if (!rst_fifo_w_n) begin
    rd_addr_gray_w_d <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_gray_w_d <= #`RD rd_addr_gray_r;
  end
end
assign rd_addr_gray_w_mux = fifo_sync_en ? rd_addr_gray_w_d : rd_addr_gray_w_sync2;
always @ (/*autosense*/rd_addr_gray_w_mux) begin: rd_addr_bin_w_block
  integer i;
  for (i=FIFO_DEPTH;i>=0;i=i-1) begin
    rd_addr_bin_w[i] = ^(rd_addr_gray_w_mux>>i);
  end
end





assign fifo_full_w = (rd_addr_bin_w[FIFO_DEPTH] != wr_addr_bin_w[FIFO_DEPTH]) &
	             (rd_addr_bin_w[FIFO_DEPTH-1:0] == wr_addr_bin_w[FIFO_DEPTH-1:0]);
assign fifo_full_r = (rd_addr_bin_r[FIFO_DEPTH] != wr_addr_bin_r[FIFO_DEPTH]) &
	             (rd_addr_bin_r[FIFO_DEPTH-1:0] == wr_addr_bin_r[FIFO_DEPTH-1:0]);



assign fifo_empty_w = (rd_addr_bin_w == wr_addr_bin_w);
assign fifo_empty_r = (rd_addr_bin_r == wr_addr_bin_r);


assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin_w[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin_r[FIFO_DEPTH-1:0];

endmodule











module sfifo_ctrl_typ1(/*autoarg*/

  fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_af, fifo_ae,
  fifo_full, fifo_empty, fifo_filled_depth, fifo_waddr, fifo_raddr,

  clk_fifo, rst_fifo_n, fifo_af_lvl, fifo_ae_lvl, fifo_clr,
  fifo_req_w, fifo_req_r
  );

 
parameter FIFO_DEPTH = 3;


input clk_fifo;
input rst_fifo_n;
input [FIFO_DEPTH-1:0] fifo_af_lvl;
input [FIFO_DEPTH-1:0] fifo_ae_lvl;
input fifo_clr;
input fifo_req_w;
input fifo_req_r;
output fifo_wr_w;
output fifo_rd_r;
output [FIFO_DEPTH-1:0] fifo_addr_w;
output [FIFO_DEPTH-1:0] fifo_addr_r;
output fifo_af;
output fifo_ae;
output fifo_full;
output fifo_empty;
output [FIFO_DEPTH:0] fifo_filled_depth;
output [FIFO_DPETH:0] fifo_waddr;
output [FIFO_DPETH:0] fifo_raddr;


wire fifo_req_w_mask;
wire fifo_req_r_mask;
wire [FIFO_DEPTH:0] wr_addr_bin_inc;
wire [FIFO_DEPTH:0] wr_addr_bin_next;
reg [FIFO_DEPTH:0] wr_addr_bin;
wire [FIFO_DEPTH:0] rd_addr_bin_inc;
wire [FIFO_DEPTH:0] rd_addr_bin_next;
reg [FIFO_DEPTH:0] rd_addr_bin;
wire fifo_af;
wire fifo_ae;
wire fifo_full;
wire fifo_empty;
wire [FIFO_DEPTH:0]fifo_filled_depth;
wire [FIFO_DEPTH:0]fifo_waddr;
wire [FIFO_DEPTH:0]fifo_raddr;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0]fifo_addr_w;
wire [FIFO_DEPTH-1:0]fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty);





assign wr_addr_bin_inc = wr_addr_bin + 1;
assign wr_addr_bin_next = fifo_clr ? {(FIFO_DEPTH+1){1'b0}} : 
	                  fifo_req_w_mask ? wr_addr_bin_inc :
			  wr_addr_bin;
always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    wr_addr_bin <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_bin <= #`RD wr_addr_bin_next;
  end
end



assign rd_addr_bin_inc = rd_addr_bin + 1;
assign rd_addr_bin_next = fifo_clr ? {(FIFO_DEPTH+1){1'b0}} :
	                  fifo_req_r_mask ? rd_addr_bin_inc :
			  rd_addr_bin;
always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    rd_addr_bin <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_bin <= #`RD rd_addr_bin_next;
  end
end





assign fifo_af = ((wr_addr_bin - rd_addr_bin) >= ({1'b0, fifo_af_lvl}));



assign fifo_ae = ((wr_addr_bin - rd_addr_bin) <= ({1'b0, fifo_ae_lvl}));



assign fifo_full = (rd_addr_bin[FIFO_DEPTH] != wr_addr_bin[FIFO_DEPTH]) &
	           (rd_addr_bin[FIFO_DEPTH-1:0] == wr_addr_bin[FIFO_DEPTH-1:0]);



assign fifo_empty = (rd_addr_bin == wr_addr_bin);



assign fifo_filled_depth = (wr_addr_bin - rd_addr_bin);



assign fifo_waddr = wr_addr_bin;
assign fifo_raddr = rd_addr_bin;


assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin[FIFO_DEPTH-1:0];

endmodule











module sfifo_ctrl_typ2(/*autoarg*/

  fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_af, fifo_ae,
  fifo_full, fifo_empty, fifo_filled_depth, fifo_waddr, fifo_raddr,

  clk_fifo, rst_fifo_n, fifo_af_lvl, fifo_ae_lvl, fifo_clr,
  fifo_req_w, fifo_req_r
  );

 
parameter FIFO_DEPTH = 3;


input clk_fifo;
input rst_fifo_n;
input [FIFO_DEPTH-1:0] fifo_af_lvl;
input [FIFO_DEPTH-1:0] fifo_ae_lvl;
input fifo_clr;
input fifo_req_w;
input fifo_req_r;
output fifo_wr_w;
output fifo_rd_r;
output [FIFO_DEPTH-1:0] fifo_addr_w;
output [FIFO_DEPTH-1:0] fifo_addr_r;
output fifo_af;
output fifo_ae;
output fifo_full;
output fifo_empty;
output [FIFO_DEPTH:0] fifo_filled_depth;
output [FIFO_DPETH:0] fifo_waddr;
output [FIFO_DPETH:0] fifo_raddr;


wire fifo_req_w_mask;
wire fifo_req_r_mask;
wire [FIFO_DEPTH:0] wr_addr_bin_inc;
wire [FIFO_DEPTH:0] wr_addr_bin_next;
reg [FIFO_DEPTH:0] wr_addr_bin;
wire [FIFO_DEPTH:0] rd_addr_bin_inc;
wire [FIFO_DEPTH:0] rd_addr_bin_next;
reg [FIFO_DEPTH:0] rd_addr_bin;
reg fifo_af;
reg fifo_ae;
reg fifo_full;
reg fifo_empty;
reg [FIFO_DEPTH:0]fifo_filled_depth;
wire [FIFO_DEPTH:0]fifo_waddr;
wire [FIFO_DEPTH:0]fifo_raddr;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0]fifo_addr_w;
wire [FIFO_DEPTH-1:0]fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty);





assign wr_addr_bin_inc = wr_addr_bin + 1;
assign wr_addr_bin_next = fifo_clr ? {(FIFO_DEPTH+1){1'b0}} : 
	                  fifo_req_w_mask ? wr_addr_bin_inc :
			  wr_addr_bin;
always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    wr_addr_bin <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_bin <= #`RD wr_addr_bin_next;
  end
end



assign rd_addr_bin_inc = rd_addr_bin + 1;
assign rd_addr_bin_next = fifo_clr ? {(FIFO_DEPTH+1){1'b0}} :
	                  fifo_req_r_mask ? rd_addr_bin_inc :
			  rd_addr_bin;
always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    rd_addr_bin <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_bin <= #`RD rd_addr_bin_next;
  end
end





always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    fifo_af <= #`RD 1'b0;
  end
  else begin
    fifo_af <= #`RD ((wr_addr_bin_next - rd_addr_bin_next) >= ({1'b0, fifo_af_lvl}));
  end
end



always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    fifo_ae <= #`RD 1'b1;
  end
  else begin
    fifo_ae <= #`RD ((wr_addr_bin_next - rd_addr_bin_next) <= ({1'b0, fifo_ae_lvl}));
  end
end



always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    fifo_full <= #`RD 1'b0;
  end
  else begin
    fifo_full <= #`RD (rd_addr_bin_next[FIFO_DEPTH] != wr_addr_bin_next[FIFO_DEPTH]) &
	              (rd_addr_bin_next[FIFO_DEPTH-1:0] == wr_addr_bin_next[FIFO_DEPTH-1:0]);
  end
end



always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    fifo_empty <= #`RD 1'b1;
  end
  else begin
    fifo_empty <= #`RD (rd_addr_bin_next == wr_addr_bin_next);
  end
end

 

always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    fifo_filled_depth <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    fifo_filled_depth <= #`RD (wr_addr_bin_next - rd_addr_bin_next);
  end
end



assign fifo_waddr = wr_addr_bin;
assign fifo_raddr = rd_addr_bin;


assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin[FIFO_DEPTH-1:0];

endmodule











module sfifo_ctrl_typ3(/*autoarg*/

  fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_full, 
  fifo_empty,

  clk_fifo, rst_fifo_n, fifo_clr, fifo_req_w, fifo_req_r
  );

 
parameter FIFO_DEPTH = 3;


input clk_fifo;
input rst_fifo_n;
input fifo_clr;
input fifo_req_w;
input fifo_req_r;
output fifo_wr_w;
output fifo_rd_r;
output [FIFO_DEPTH-1:0] fifo_addr_w;
output [FIFO_DEPTH-1:0] fifo_addr_r;
output fifo_full;
output fifo_empty;


wire fifo_req_w_mask;
wire fifo_req_r_mask;
wire [FIFO_DEPTH:0] wr_addr_bin_inc;
wire [FIFO_DEPTH:0] wr_addr_bin_next;
reg [FIFO_DEPTH:0] wr_addr_bin;
wire [FIFO_DEPTH:0] rd_addr_bin_inc;
wire [FIFO_DEPTH:0] rd_addr_bin_next;
reg [FIFO_DEPTH:0] rd_addr_bin;
wire fifo_full;
wire fifo_empty;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0]fifo_addr_w;
wire [FIFO_DEPTH-1:0]fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty);





assign wr_addr_bin_inc = wr_addr_bin + 1;
assign wr_addr_bin_next = fifo_clr ? {(FIFO_DEPTH+1){1'b0}} : 
	                  fifo_req_w_mask ? wr_addr_bin_inc :
			  wr_addr_bin;
always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    wr_addr_bin <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_bin <= #`RD wr_addr_bin_next;
  end
end



assign rd_addr_bin_inc = rd_addr_bin + 1;
assign rd_addr_bin_next = fifo_clr ? {(FIFO_DEPTH+1){1'b0}} :
	                  fifo_req_r_mask ? rd_addr_bin_inc :
			  rd_addr_bin;
always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    rd_addr_bin <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_bin <= #`RD rd_addr_bin_next;
  end
end





assign fifo_full = (rd_addr_bin[FIFO_DEPTH] != wr_addr_bin[FIFO_DEPTH]) &
	           (rd_addr_bin[FIFO_DEPTH-1:0] == wr_addr_bin[FIFO_DEPTH-1:0]);



assign fifo_empty = (rd_addr_bin == wr_addr_bin);


assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin[FIFO_DEPTH-1:0];

endmodule











module sfifo_ctrl_typ4(/*autoarg*/

  fifo_wr_w, fifo_rd_r, fifo_addr_w, fifo_addr_r, fifo_full, 
  fifo_empty,

  clk_fifo, rst_fifo_n, fifo_clr, fifo_req_w, fifo_req_r
  );

 
parameter FIFO_DEPTH = 3;


input clk_fifo;
input rst_fifo_n;
input fifo_clr;
input fifo_req_w;
input fifo_req_r;
output fifo_wr_w;
output fifo_rd_r;
output [FIFO_DEPTH-1:0] fifo_addr_w;
output [FIFO_DEPTH-1:0] fifo_addr_r;
output fifo_full;
output fifo_empty;


wire fifo_req_w_mask;
wire fifo_req_r_mask;
wire [FIFO_DEPTH:0] wr_addr_bin_inc;
wire [FIFO_DEPTH:0] wr_addr_bin_next;
reg [FIFO_DEPTH:0] wr_addr_bin;
wire [FIFO_DEPTH:0] rd_addr_bin_inc;
wire [FIFO_DEPTH:0] rd_addr_bin_next;
reg [FIFO_DEPTH:0] rd_addr_bin;
reg fifo_full;
reg fifo_empty;
wire fifo_wr_w;
wire fifo_rd_r;
wire [FIFO_DEPTH-1:0]fifo_addr_w;
wire [FIFO_DEPTH-1:0]fifo_addr_r;


assign fifo_req_w_mask = fifo_req_w & (~fifo_full);
assign fifo_req_r_mask = fifo_req_r & (~fifo_empty);





assign wr_addr_bin_inc = wr_addr_bin + 1;
assign wr_addr_bin_next = fifo_clr ? {(FIFO_DEPTH+1){1'b0}} : 
	                  fifo_req_w_mask ? wr_addr_bin_inc :
			  wr_addr_bin;
always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    wr_addr_bin <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    wr_addr_bin <= #`RD wr_addr_bin_next;
  end
end



assign rd_addr_bin_inc = rd_addr_bin + 1;
assign rd_addr_bin_next = fifo_clr ? {(FIFO_DEPTH+1){1'b0}} :
	                  fifo_req_r_mask ? rd_addr_bin_inc :
			  rd_addr_bin;
always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    rd_addr_bin <= #`RD {(FIFO_DEPTH+1){1'b0}};
  end
  else begin
    rd_addr_bin <= #`RD rd_addr_bin_next;
  end
end





always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    fifo_full <= #`RD 1'b0;
  end
  else begin
    fifo_full <= #`RD (rd_addr_bin_next[FIFO_DEPTH] != wr_addr_bin_next[FIFO_DEPTH]) &
	              (rd_addr_bin_next[FIFO_DEPTH-1:0] == wr_addr_bin_next[FIFO_DEPTH-1:0]);
  end
end



always @ (posedge clk_fifo or negedge rst_fifo_n) begin
  if (!rst_fifo_n) begin
    fifo_empty <= #`RD 1'b1;
  end
  else begin
    fifo_empty <= #`RD (rd_addr_bin_next == wr_addr_bin_next);
  end
end


assign fifo_wr_w = fifo_req_w_mask;
assign fifo_rd_r = fifo_req_r_mask;
assign fifo_addr_w = wr_addr_bin[FIFO_DEPTH-1:0];
assign fifo_addr_r = rd_addr_bin[FIFO_DEPTH-1:0];

endmodule
module rst_sync_typ1(
	rst_out_n,
	clk_sync,
	rst_in_n,
	rst_scan_n,
	ptest_scan_mode
);
output rst_out_n;
input clk_sync;
input rst_in_n;
input rst_scan_n;
input ptest_scan_mode;
wire rst_sync_reg_n;
reg rst_out_n_sync1;
reg rst_out_n_sync2;
wire rst_out_n;
assign rst_sync_reg_n = ptest_scan_mode ? rst_scan_n : rst_in_n;
always @ (posedge clk_sync or negedge rst_sync_reg_n) begin
  if (!rst_sync_reg_n) begin
    rst_out_n_sync1 <= #`RD 1'b0;
    rst_out_n_sync2 <= #`RD 1'b0;
  end
  else begin
    rst_out_n_sync1 <= #`RD 1'b1;
    rst_out_n_sync2 <= #`RD rst_out_n_sync1;
  end
end
assign rst_out_n = ptest_scan_mode ? rst_scan_n : rst_out_n_sync2;
endmodule 
module rst_sync_typ2(
	rst_out_n,
	clk_sync,
	soft_rst,
	rst_in_n,
	rst_scan_n,
	ptest_scan_mode
);
output rst_out_n;
input clk_sync;
input soft_rst;
input rst_in_n;
input rst_scan_n;
input ptest_scan_mode;
wire rst_sync_reg_n;
reg rst_out_n_sync1;
reg rst_out_n_sync2;
wire rst_out_n;
assign rst_sync_reg_n = ptest_scan_mode ? rst_scan_n : (rst_in_n & ~soft_rst);
always @ (posedge clk_sync or negedge rst_sync_reg_n) begin
  if (!rst_sync_reg_n) begin
    rst_out_n_sync1 <= #`RD 1'b0;
    rst_out_n_sync2 <= #`RD 1'b0;
  end
  else begin
    rst_out_n_sync1 <= #`RD 1'b1;
    rst_out_n_sync2 <= #`RD rst_out_n_sync1;
  end
end
assign rst_out_n = ptest_scan_mode ? rst_scan_n : rst_out_n_sync2;
endmodule 
module rst_sync_typ3(
	clk_a,
	rst_a_n,
	reg_a_clr,
	clk_b,
	rst_b_in_n,
	rsb_b_out_n,
	rst_scan_n,
	ptest_scan_mode
);
input clk_a;
input rst_a_n;
input reg_a_clr;
input clk_b;
input rst_b_in_n;
input rst_b_out_n;
input rst_scan_n;
input ptest_scan_mode;
reg reg_a_clr_reg;
wire rst_sync_reg_n;
reg rst_b_out_n_sync1;
reg rst_b_out_n_sync2;
wire rst_b_out_n;
always @ (posedge clk_a or negedge rst_a_n) begin
  if (~rst_a_n) begin
    reg_a_clr_reg <= #`RD 1'b0;
  end
  else begin
    reg_a_clr_reg <= #`RD reg_a_clr;
  end
end
assign rst_sync_reg_n = ptest_scan_mode ? rst_scan_n : (rst_b_in_n & ~reg_a_clr_reg);
always @ (posedge clk_b or negedge rst_sync_reg_n) begin
  if (!rst_sync_reg_n) begin
    rst_b_out_n_sync1 <= #`RD 1'b0;
    rst_b_out_n_sync2 <= #`RD 1'b0;
  end
  else begin
    rst_b_out_n_sync1 <= #`RD 1'b1;
    rst_b_out_n_sync2 <= #`RD rst_b_out_n_sync1;
  end
end
assign rst_b_out_n = ptest_scan_mode ? rst_scan_n : rst_b_out_n_sync2;
endmodule 
module lat_cs(/*autoarg*/

  lat_q,

  ptest_scan_mode, clk_scan, rst_scan_n, lat_clr, lat_set, lat_en,
  lat_d
  );
input ptest_scan_mode;
input clk_scan;
input rst_scan_n;
input lat_clr;
input lat_set;
input lat_en;
input lat_d;
output lat_q;
wire lat_cn;
wire lat_sn;
wire lat_q_i;
reg dff_q;
assign lat_cn = ~lat_clr;
assign lat_sn = ~lat_set | lat_clr;
cell_latcsn u_lat (
  .D (lat_d),
  .E (lat_en),
  .CDN (lat_cn),
  .SDN (lat_sn),
  .Q (lat_q_i),
  .QN ()
  );
always @ (posedge clk_scan or negedge rst_scan_n) begin
  if (!rst_scan_n) begin
    dff_q <= #`RD 1'b0;
  end
  else begin
    dff_q <= #`RD lat_clr ^ lat_set ^ lat_en ^ lat_d;
  end
end
assign lat_q = ptest_scan_mode ? dff_q : lat_q_i;
endmodule
module lat_e (/*autoarg*/

  lat_q,

  ptest_scan_mode, clk_scan, rst_scan_n, lat_en, lat_d
  );
parameter D_WIDTH = 8;
input ptest_scan_mode;
input clk_scan;
input rst_scan_n;
input lat_en;
input [(D_WIDTH-1):0] lat_d;
output [(D_WIDTH-1):0] lat_q;
reg [(D_WIDTH-1):0] lat_q_i;
reg [(D_WIDTH-1):0] dff_q;
always @ (lat_en or lat_d) begin
  if (lat_en) begin
    lat_q_i <= #`RD lat_d;
  end
  else begin
    lat_q_i <= #`RD lat_q_i;
  end
end
always @ (posedge clk_scan or negedge rst_scan_n) begin
  if (!rst_scan_n) begin
    dff_q <= #`RD 1'b0;
  end
  else begin
    dff_q <= #`RD {D_WIDTH{lat_en}} ^ lat_d;
  end
end
assign lat_q = ptest_scan_mode ? dff_q : lat_q_i;
endmodule
module lat_sc (/*autoarg*/

  lat_q,

  ptest_scan_mode, clk_scan, rst_scan_n, lat_clr, lat_set, lat_en,
  lat_d
  );
input ptest_scan_mode;
input clk_scan;
input rst_scan_n;
input lat_clr;
input lat_set;
input lat_en;
input lat_d;
output lat_q;
wire lat_cn;
wire lat_sn;
wire lat_q_i;
reg dff_q;
assign lat_cn = ~lat_clr | lat_set;
assign lat_sn = ~lat_set;
cell_latcsn u_lat (
  .D   (lat_d),
  .E   (lat_en),
  .CDN (lat_cn),
  .SDN (lat_sn),
  .Q   (lat_q_i),
  .QN  ()
  );
always @ (posedge clk_scan or negedge rst_scan_n) begin
  if (!rst_scan_n) begin
    dff_q <= #`RD 1'b0;
  end
  else begin
    dff_q <= #`RD lat_clr ^ lat_set ^ lat_en ^ lat_d;
  end
end
assign lat_q = ptest_scan_mode ? dff_q : lat_q_i;
endmodule
