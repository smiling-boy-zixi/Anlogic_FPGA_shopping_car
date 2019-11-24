module led(
input clk,
input rst,
input [2:0]led_mode,//1:常亮  2：每0.2秒 亮灭一次 3；pwm 呼吸灯
output led_sgn
);
reg led_sgn_r ;
assign led_sgn = led_sgn_r ;
wire huxi_sgn;


huxideng u_huxideng
(
	.clk	(clk),
	.rst	(rst),
	.led	(huxi_sgn)
);
reg [25:0] cnt; //---------------------------0.2秒计时
always @(posedge clk) begin 	
	if(!rst) cnt <= 0 ;
	else if (cnt == 4_800_000)
		cnt <= 0 ;
	else 
		cnt <= cnt + 1;
end 

reg [25:0] cntt; // ------------------------0.1秒计时器
always @(posedge clk) begin 	
	if(!rst) cntt <= 0 ;
	else if (cntt == 2_400_000)
		cntt <= 0 ;
	else 
		cntt <= cntt + 1;
end 


always @(posedge clk ) begin //----------------不同模式输出不同的led_sgn_r
	if(led_mode == 1) 
		led_sgn_r <= 1;
	else if(led_mode == 0) begin 
		led_sgn_r <= 0;
	end 
	else if(led_mode == 2) begin 
		if(cntt == 2_400_000)
			led_sgn_r <= !led_sgn_r ;
		else 
			led_sgn_r <= led_sgn_r ;
	end 
	else if(led_mode == 3) begin 
		led_sgn_r <= huxi_sgn ;
	end 
end 


 


endmodule
