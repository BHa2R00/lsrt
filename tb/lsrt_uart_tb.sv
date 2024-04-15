`include "../rtl/lsrt_uart.v"

`timescale 1ns/1ns

module lsrt_uart_tb;

integer fp;

parameter BMSB = 3;
parameter DMSB = 7;
parameter CMSB = 12;

reg [CMSB:0] div;
reg fclk;
reg rstn, setn, clk;

wire x;

wire u_uart_tx_xst, u_uart_tx_empty;
wire u_uart_rx_xst, u_uart_rx_full;
reg u_uart_tx_push, u_uart_tx_clear;
reg u_uart_rx_clear;
reg signed [DMSB:0] u_uart_tx_wdata;
wire signed [DMSB:0] u_uart_rx_rdata;

initial clk = 1'b0;
always #5 clk = ~clk;

initial fclk = 1'b0;
always #24 fclk = ~fclk;

initial rstn = 1'b0;
initial setn = 1'b0;
always begin
	fp = $fopen("../tb/rc4.fth","r");
	#17 rstn = 1'b1;
	#33 setn = 1'b1;
	while(!$feof(fp)) @(negedge u_uart_rx_full);
	#33 setn = 1'b0;
	#17 rstn = 1'b0;
	$fclose(fp);
end

reg [1:0] u_uart_tx_empty_d, u_uart_rx_full_d;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		u_uart_tx_empty_d <= 2'b00;
		u_uart_rx_full_d <= 2'b00;
	end
	else begin
		u_uart_tx_empty_d <= {u_uart_tx_empty_d[0:0], u_uart_tx_empty};
		u_uart_rx_full_d <= {u_uart_rx_full_d[0:0], u_uart_rx_full};
	end
end

always@(negedge rstn or negedge clk) begin
	if(!rstn) begin
		u_uart_tx_push <= 1'b0;
		u_uart_tx_clear <= 1'b0;
		u_uart_rx_clear <= 1'b0;
		u_uart_tx_wdata <= $urandom_range(0,(1<<DMSB)-1);
		div <= $urandom_range(1,(1<<CMSB)-1);
	end
	else begin
		if(u_uart_tx_empty && u_uart_rx_full) begin
			u_uart_tx_push <= ~u_uart_tx_push;
			div <= $urandom_range(1,(1<<CMSB)-1);
		end
		fork
		if(u_uart_tx_empty_d == 2'b10) begin
			u_uart_tx_wdata <= $fgetc(fp);
		end
		if(u_uart_rx_full_d == 2'b01) begin
			$write("%c", u_uart_rx_rdata);
		end
		join_any
	end
end

uart_tx #(
	. CMSB ( CMSB ) 
) u_uart_tx (
	.empty(u_uart_tx_empty), 
	.push(u_uart_tx_push), .clear(u_uart_tx_clear), 
	.xst(u_uart_tx_xst), 
	.nst(), 
	.cst(), 
	.div(div), 
	.fclk(fclk),
	.wdata(u_uart_tx_wdata), 
	.tx(x), 
	.rstn(rstn), .setn(setn), .clk(clk) 
);

uart_rx #(
	. CMSB ( CMSB ) 
) u_uart_rx (
	.full(u_uart_rx_full), 
	.clear(u_uart_rx_clear), 
	.xst(u_uart_rx_xst), 
	.nst(), 
	.cst(), 
	.div(div), 
	.fclk(fclk),
	.rdata(u_uart_rx_rdata), 
	.rx(x), 
	.rstn(rstn), .setn(setn), .clk(clk) 
);

initial begin
	$fsdbDumpfile("./lsrt_uart_tb.fsdb");
	$fsdbDumpvars(0, lsrt_uart_tb);
	repeat(2) @(negedge rstn);
	$finish(2);
end

endmodule
