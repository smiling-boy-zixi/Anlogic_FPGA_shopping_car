module pwm#(
	parameter sys_clk = 24_000_000, ///主时钟
	parameter pwm_fre = 5000 
)
(
input clk_24M,
input rst,
input [10:0] perctg,	  /////别看名字，单位千分之
output pwm_sgn //signal 
); 

wire [25:0] pwm_num;	  ////目标值
reg [25:0] pwm_cnt;	 ////计数的
wire  [25:0] pwm_1;    ///高电平所占周期数

assign pwm_num = sys_clk/pwm_fre ;
assign pwm_1 = pwm_num*perctg/1000;
reg pwm_sgn_r;
always @(posedge clk_24M) begin 
	if(!rst) begin 
		pwm_cnt <= 0 ;
	end 
	else if(pwm_cnt <= pwm_1) begin 
		pwm_sgn_r <= 1 ;
		pwm_cnt <= pwm_cnt + 1 ;
	end 
	else if (pwm_cnt < pwm_num) begin 
		pwm_sgn_r <= 0 ;
		pwm_cnt <= pwm_cnt + 1 ;
	end 
	else if (pwm_cnt == pwm_num)
		pwm_cnt <= 0 ;
	else 
		pwm_cnt <= pwm_cnt ;
end 

assign pwm_sgn = pwm_sgn_r ;


endmodule
