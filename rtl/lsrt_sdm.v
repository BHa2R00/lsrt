`include "../rtl/lsrt.v" 


module sdm_tx (
	output empty, 
	input push, clear, 
	output xst, 
	output [1:0] nst, 
	output [1:0] cst, 
	input fclk, 
	input signed [3:0] wdata, 
	output tx, 
	input rstn, setn, clk 
);

wire [15:0] weights[0:15];
assign weights[08] = 16'b0000000000000000;
assign weights[09] = 16'b0000000100000000;
assign weights[10] = 16'b0000100000100000;
assign weights[11] = 16'b0001000100010000;
assign weights[12] = 16'b0010010001001000;
assign weights[13] = 16'b0100100100100100;
assign weights[14] = 16'b1001001010010010;
assign weights[15] = 16'b1001010101010010;
assign weights[00] = 16'b1010101010101010;
assign weights[01] = ~weights[15];
assign weights[02] = ~weights[14];
assign weights[03] = ~weights[13];
assign weights[04] = ~weights[12];
assign weights[05] = ~weights[11];
assign weights[06] = ~weights[10];
assign weights[07] = ~weights[09];

wire [15:0] weight = weights[$unsigned(wdata)];

lstx #(
	. BMSB ( 3 ), 
	. DMSB ( 15 ), 
	. CMSB ( 2 ) 
) u_lstx (
	.empty(empty), 
	.push(push), .clear(clear), 
	.xst(xst), 
	.nst(nst), 
	.cst(cst), 
	.uclk(), 
	.div(3'd7), 
	.fclk(fclk), .sel_fclk(1'b0), 
	.wdata(weight), 
	.tx(tx), 
	.rstn(rstn), .setn(setn), .clk(clk) 
);

endmodule


module sdm_rx (
	output full, 
	input pop, clear, 
	output xst, 
	output [1:0] nst, 
	output [1:0] cst, 
	input fclk, 
	output reg signed [3:0] rdata, 
	input rx, 
	input rstn, setn, clk 
);

wire [15:0] rdata0;
reg [1:0] full_d;
wire full_01 = {full_d, full} == 3'b011;

lsrx #(
	. BMSB ( 3 ), 
	. DMSB ( 15 ), 
	. CMSB ( 2 ) 
) u_lsrx (
	.full(full), 
	.pop(pop), .clear(clear), 
	.xst(xst), 
	.nst(nst), 
	.cst(cst), 
	.uclk(), 
	.div(3'd7), 
	.fclk(fclk), .sel_fclk(1'b0),
	.rdata(rdata0), 
	.rx(rx), 
	.rstn(rstn), .setn(setn), .clk(clk) 
);

always@(negedge rstn or posedge fclk) begin
	if(!rstn) full_d <= 2'b00;
	else full_d <= {full_d[0], full};
end

always@(negedge rstn or posedge fclk) begin
	if(!rstn) rdata = 0;
	else if(full_01) begin
	rdata = -8;
	if(rdata0[00]) rdata = rdata + 1;
	if(rdata0[01]) rdata = rdata + 1;
	if(rdata0[02]) rdata = rdata + 1;
	if(rdata0[03]) rdata = rdata + 1;
	if(rdata0[04]) rdata = rdata + 1;
	if(rdata0[05]) rdata = rdata + 1;
	if(rdata0[06]) rdata = rdata + 1;
	if(rdata0[07]) rdata = rdata + 1;
	if(rdata0[08]) rdata = rdata + 1;
	if(rdata0[09]) rdata = rdata + 1;
	if(rdata0[10]) rdata = rdata + 1;
	if(rdata0[11]) rdata = rdata + 1;
	if(rdata0[12]) rdata = rdata + 1;
	if(rdata0[13]) rdata = rdata + 1;
	if(rdata0[14]) rdata = rdata + 1;
	if(rdata0[15]) rdata = rdata + 1;
	end
end

endmodule
