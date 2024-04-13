`include "../rtl/lsrt.v"

`timescale 1ns/1ns

module lsrt_tb;

parameter BMSB = 3;
parameter DMSB = 9;
parameter CMSB = 12;

reg [CMSB:0] div;
reg fclk;
reg rstn, setn, clk;

wire x;

wire u_lstx_xst, u_lstx_empty;
wire u_lsrx_xst, u_lsrx_full;
reg u_lstx_push, u_lstx_clear;
reg u_lsrx_pop, u_lsrx_clear;
reg signed [DMSB:0] u_lstx_wdata;
wire signed [DMSB:0] u_lsrx_rdata;

initial clk = 1'b0;
always #5 clk = ~clk;

initial fclk = 1'b0;
always #24 fclk = ~fclk;

initial rstn = 1'b0;
initial setn = 1'b0;
always begin
	#17 rstn = 1'b1;
	#33 setn = 1'b1;
	repeat(50) @(negedge u_lsrx_full);
	#33 setn = 1'b0;
	#17 rstn = 1'b0;
end

reg [1:0] u_lstx_empty_d, u_lsrx_full_d;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		u_lstx_empty_d <= 2'b00;
		u_lsrx_full_d <= 2'b00;
	end
	else begin
		u_lstx_empty_d <= {u_lstx_empty_d[0:0], u_lstx_empty};
		u_lsrx_full_d <= {u_lsrx_full_d[0:0], u_lsrx_full};
	end
end

always@(negedge rstn or negedge clk) begin
	if(!rstn) begin
		u_lstx_push <= 1'b0;
		u_lstx_clear <= 1'b0;
		u_lsrx_pop <= 1'b0;
		u_lsrx_clear <= 1'b0;
		u_lstx_wdata <= $urandom_range(0,(1<<DMSB)-1);
		div <= $urandom_range(1,(1<<CMSB)-1);
	end
	else begin
		if(u_lstx_empty && u_lsrx_full) begin
			u_lstx_push <= ~u_lstx_push;
			div <= $urandom_range(1,(1<<CMSB)-1);
		end
		if(u_lstx_empty_d == 2'b10) begin
			u_lstx_wdata <= $urandom_range(0,(1<<DMSB)-1);
			u_lsrx_pop <= ~u_lsrx_pop;
		end
	end
end

lstx #(
	. BMSB ( BMSB ), 
	. DMSB ( DMSB ), 
	. CMSB ( CMSB ) 
) u_lstx (
	.empty(u_lstx_empty), 
	.push(u_lstx_push), .clear(u_lstx_clear), 
	.xst(u_lstx_xst), 
	.nst(), 
	.cst(), 
	.div(div), 
	.fclk(fclk),
	.wdata(u_lstx_wdata), 
	.tx(x), 
	.rstn(rstn), .setn(setn), .clk(clk) 
);

lsrx #(
	. BMSB ( BMSB ), 
	. DMSB ( DMSB ), 
	. CMSB ( CMSB ) 
) u_lsrx (
	.full(u_lsrx_full), 
	.pop(u_lsrx_pop), .clear(u_lsrx_clear), 
	.xst(u_lsrx_xst), 
	.nst(), 
	.cst(), 
	.div(div), 
	.fclk(fclk),
	.rdata(u_lsrx_rdata), 
	.rx(x), 
	.rstn(rstn), .setn(setn), .clk(clk) 
);

initial begin
	$fsdbDumpfile("./lsrt_tb.fsdb");
	$fsdbDumpvars(0, lsrt_tb);
	repeat(2) @(negedge rstn);
	$finish(2);
end

endmodule
