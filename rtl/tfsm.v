module handshake_xor (
	output x, 
	input i, 
	input rstn, setn, clk 
);

reg d, q;

always@(*) begin
	if(~rstn) d = 1'b0;
	if(~setn) d = i;
	else if(~clk) d = i;
end

always@(*) begin
	if(~rstn) q = 1'b0;
	else if(~setn) q = i;
	else if(clk) q = d;
end

assign x = d ^ q;

endmodule


module state_xor #(
	parameter STMSB = 3, 
	parameter ST0   = {(STMSB+1){1'b0}} 
)(
	output xst, 
	output reg [STMSB:0] cst, 
	input [STMSB:0] nst, 
	input rstn, setn, clk 
);

reg [STMSB:0] lst;

always@(*) begin
	if(~rstn) lst = ST0;
	else if(setn && ~clk) lst = nst;
end

always@(*) begin
	if(~rstn) cst = ST0;
	else if(setn && clk) cst = lst;
end

assign xst = lst != cst;

endmodule
