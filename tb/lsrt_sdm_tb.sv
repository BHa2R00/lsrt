`include "../rtl/lsrt_sdm.v"

`timescale 1ns/1ns

module lsrt_sdm_tb;

parameter BMSB = 3;
parameter DMSB = 3;
parameter CMSB = 1;

reg fclk;
reg rstn, setn, clk;

wire x;

wire u_sdm_tx_xst, u_sdm_tx_empty;
wire u_sdm_rx_xst, u_sdm_rx_full;
reg u_sdm_tx_push, u_sdm_tx_clear;
reg u_sdm_rx_pop, u_sdm_rx_clear;
reg signed [DMSB:0] u_sdm_tx_wdata;
wire signed [DMSB:0] u_sdm_rx_rdata;

initial clk = 1'b0;
always #5 clk = ~clk;

initial fclk = 1'b0;
always #319 fclk = ~fclk;

initial rstn = 1'b0;
initial setn = 1'b0;
always begin
	#17 rstn = 1'b1;
	#33 setn = 1'b1;
	repeat(2000) @(negedge u_sdm_rx_full);
	#33 setn = 1'b0;
	#17 rstn = 1'b0;
end

reg [1:0] u_sdm_tx_empty_d, u_sdm_rx_full_d;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		u_sdm_tx_empty_d <= 2'b00;
		u_sdm_rx_full_d <= 2'b00;
	end
	else begin
		u_sdm_tx_empty_d <= {u_sdm_tx_empty_d[0:0], u_sdm_tx_empty};
		u_sdm_rx_full_d <= {u_sdm_rx_full_d[0:0], u_sdm_rx_full};
	end
end

always@(negedge rstn or negedge clk) begin
	if(!rstn) begin
		u_sdm_tx_push <= 1'b0;
		u_sdm_tx_clear <= 1'b0;
		u_sdm_rx_pop <= 1'b0;
		u_sdm_rx_clear <= 1'b0;
		u_sdm_tx_wdata <= $urandom_range(0,(1<<DMSB)-1);
	end
	else begin
		if(u_sdm_tx_empty && u_sdm_rx_full) begin
			u_sdm_tx_push <= ~u_sdm_tx_push;
		end
		if(u_sdm_tx_empty_d == 2'b10) begin
			u_sdm_tx_wdata <= ((1<<DMSB)-1) * $sin(110.0*$time*3.1415926);
			u_sdm_rx_pop <= ~u_sdm_rx_pop;
		end
		if(u_sdm_rx_full_d == 2'b01) begin
			//$write("%d", u_sdm_rx_rdata);
		end
	end
end

sdm_tx u_sdm_tx (
	.empty(u_sdm_tx_empty), 
	.push(u_sdm_tx_push), .clear(u_sdm_tx_clear), 
	.xst(u_sdm_tx_xst), 
	.nst(), 
	.cst(), 
	.fclk(fclk),
	.wdata(u_sdm_tx_wdata), 
	.tx(x), 
	.rstn(rstn), .setn(setn), .clk(clk) 
);

sdm_rx u_sdm_rx (
	.full(u_sdm_rx_full), 
	.pop(u_sdm_rx_pop), .clear(u_sdm_rx_clear), 
	.xst(u_sdm_rx_xst), 
	.nst(), 
	.cst(), 
	.fclk(fclk),
	.rdata(u_sdm_rx_rdata), 
	.rx(x), 
	.rstn(rstn), .setn(setn), .clk(clk) 
);

initial begin
	$fsdbDumpfile("./lsrt_sdm_tb.fsdb");
	$fsdbDumpvars(0, lsrt_sdm_tb);
	repeat(2) @(negedge rstn);
	$finish(2);
end

endmodule
