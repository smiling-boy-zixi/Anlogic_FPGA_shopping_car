module Trig#(
	parameter sys_clk = 24_000_000,
	parameter Trig_fre = 24//1s run 10000 times_

)
(
	input clk,
	input rst,
	output Trig_sign //signal
) ;

reg [25:0] Trig_num;   //1次周期对应时钟个数
reg [25:0] Trig_cnt;
reg [25:0] Trig_high;
reg [25:0] Trig_sign_r;

always@(posedge clk)
	if(!rst)begin
		Trig_cnt <= 0 ;
		Trig_high <= sys_clk/(Trig_fre*2778) ;
		Trig_sign_r <= 0 ;
		Trig_num <= sys_clk/Trig_fre ;
	end
	else if(Trig_cnt <= Trig_high)begin
		Trig_sign_r <= 1 ;
		Trig_cnt <= Trig_cnt + 1 ;
	end
	else if(Trig_cnt > Trig_high && Trig_cnt < Trig_num)begin
		Trig_sign_r <= 0 ;
		Trig_cnt <= Trig_cnt + 1 ;
		end
	else if(Trig_cnt == Trig_num)begin
		Trig_cnt <= 0 ;
	end
		
assign Trig_sign = Trig_sign_r ;



endmodule
