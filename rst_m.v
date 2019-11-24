module rst_m(
input clk,
output reg rst);

reg [2:0] rst_cnt;

always @(posedge clk) begin 
	if(rst_cnt == 4) rst_cnt <= rst_cnt;
	else rst_cnt <= rst_cnt + 1;
end 
always @(posedge clk) begin 
	if(rst_cnt == 4) rst <= 1;
	else rst <= 0;
end 

endmodule
