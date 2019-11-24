module pwm_judge(
input clk,
input rst,
input [7:0]rx_data,
input [25:0] distance1, //前轮的
input [25:0] distance2, //后轮的
output m1_1,
output m1_2,
output m2_1,
output m2_2,
output m0,
output [2:0] led_mode //右拐1 左拐2 直行3 不动0
);
parameter  duo_initial = 60 ; //舵机正向前方的时的pwm占空比 此时8％
parameter  safe_distance = 0 ;//超声波测距制动的安全距离 30cm
reg  [10:0]	per_duo;   ///舵机占空比 单位千分之！！！！！！！名字是假的
reg  [10:0]	per_dian1; /////电机占空比
reg  [10:0]	per_dian2;
reg  [2:0]  led_mode_r ;
wire [10:0]	per_duo_w;
wire [10:0]	per_dian1_w;
wire [10:0]	per_dian2_w;
assign per_duo_w   = per_duo;
assign per_dian1_w = per_dian1;
assign per_dian2_w = per_dian2;
assign led_mode    = led_mode_r;

pwm u_pwm1_1 
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_dian1_w),
	.pwm_sgn	(m1_1)
);
pwm u_pwm1_2 
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_dian2_w),
	.pwm_sgn	(m1_2)
);
pwm u_pwm2_1 
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_dian1_w),
	.pwm_sgn	(m2_1)
);
pwm u_pwm2_2 
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_dian2_w),
	.pwm_sgn	(m2_2)
);
pwm  
#(
	.pwm_fre	(50)
) u_pwm0
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_duo_w),
	.pwm_sgn	(m0)
);

reg [2:0] mode;//-------------------------------------------------模式的判断
//--------------------------7：手势0 摆动1  手势态 6：启动1 制动0  5:直行1 拐弯0  4：前进1 后退0 /左拐1 右拐0 
// 										  摆手态 10000000 停止 前四位1111前进 
always @(posedge clk) begin 
	if (!rx_data[7]&&!rx_data[6]&&rx_data[5]&&rx_data[4]) begin 
		mode <= 0 ; ////制动
	end 
	else if (!rx_data[7]&&rx_data[6]&&rx_data[5]&&rx_data[4]) begin 
		mode <= 1 ;	 /////前进直行
	end 
	else if (!rx_data[7]&&rx_data[6]&&rx_data[5]&&!rx_data[4]) begin 
		mode <= 2 ;	 /////后退直行
	end 
	else if (!rx_data[7] && rx_data[6] && !rx_data[5] && rx_data[4]) begin 
		mode <= 3 ; //////前进左转（微调）
	end 
	else if (!rx_data[7] && rx_data[6] && !rx_data[5] && !rx_data[4]) begin 
		mode <= 4 ; //////前进右转（微调）
	end  
	else if	(rx_data[7]== 1 && rx_data[6:0] == 0) begin 
		mode <= 5 ; ///////摆手状态下的停止态
	end 
	else if (rx_data[7:4] == 4'b1111 ) begin 
		mode <= 6 ; ///////摆手时的直行前进状态
	end 
	else begin 
		mode <= mode ;
	end 
end 

//-----------------------------------0.125秒计数器，每半秒前轮角度改变一点
reg [25:0] cnt;
always @(posedge clk) begin 
	if(!rst) cnt <= 0 ;
	else if (cnt == 3_000_001)  //应该不需要多1的
		cnt <= 0 ;
	else  
		cnt <= cnt + 1;
end 

//-------------------------- 0.5秒计数器 移动时转轮子用的
reg [25:0] cntt;
always @(posedge clk) begin 
	if(!rst) cntt <= 0 ;
	else if (cntt == 12_000_001)  //应该不需要多1的
		cntt <= 0 ;
	else  
		cntt <= cntt + 1;
end 
//-----------------------------------
always @(posedge clk) begin 

	if(!rst) begin 
		per_dian1 <= 0 ;
		per_dian2 <= 0 ;
		per_duo   <= 60;
	end 	
//	else if (distance1 <safe_distance && mode != 0 && mode != 2) //如果前轮距障碍物小于安全距离，就只能进入模式0 2 （后退或原地转方向轮）
//		per_dian1 <= 0;
//	else if (distance2 <safe_distance && mode == 2 ) /////如果后轮小于安全距离，就不能进入模式2（后退模式）
//		per_dian2 <= 0;
	else if (mode == 0 ) begin //---------------------制动态
		if(rx_data[3:2] == 2'b00 ) begin //前轮不懂
			per_duo <= per_duo;
			per_dian1 <= 0 ;
			per_dian2 <= 0 ;
			led_mode_r<= 0 ;
		end 
		else if (rx_data[3:2] == 2'b10 ) begin //前轮左拐
			led_mode_r<= 2 ;
			if(per_duo <= 20) begin 
				per_duo   <= per_duo ; 
				per_dian1 <= 0 ;
				per_dian2 <= 0 ;
			end 
			else begin  
				if(cnt == 3_000_000) begin 
					per_duo   <= per_duo - rx_data[1:0];
					per_dian1 <= 0 ;
					per_dian2 <= 0 ;
				end 
			end 
		end  
		else if (rx_data[3:2] == 2'b01 )begin ///前轮右拐
			led_mode_r<= 1 ;
			if(per_duo >= 90) begin 
				per_duo <= per_duo ;
				per_dian1 <= 0 ;
				per_dian2 <= 0 ;
			end			
			else begin 
				if(cnt == 3_000_000) begin 
					per_duo   <= per_duo + rx_data[1:0];
					per_dian1 <= 0 ;
					per_dian2 <= 0 ;
				end 
			end 
		end 	
	end 
	else if (mode == 1 /*&& distance1 >= safe_distance*/) begin //前进直行
		per_dian1 <= 500 + 500*rx_data[3:2]/4;
		per_dian2 <= 0 ;
		led_mode_r<= 3 ;

	end  
	else if (mode == 2 /*&& distance2 >= safe_distance*/) begin //后退直行
		per_dian1 <= 0 ;
		per_dian2 <= 500 + 500*rx_data[3:2]/4;
		led_mode_r<= 3 ;
	end 
	else if (mode == 3 /*&& distance1 >= safe_distance*/) begin //前进左转（微调）
		led_mode_r<= 2 ;
		per_dian1 <= 500 + 500*rx_data[3:2]/4;
		per_dian2 <= 0 ;
		if(cntt == 12_000_000) begin 
			per_duo <= per_duo - rx_data[1:0];  
		end 
	end 
	else if (mode == 4/* && distance1 >= safe_distance*/) begin //前进右转（微调）
		led_mode_r<= 1 ;
		per_dian1 <= 500 + 500*rx_data[3:2]/4;
		per_dian2 <= 0 ;
		if(cntt == 12_000_000) 
			per_duo <= per_duo + rx_data[1:0];
	end
	else if (mode == 5) begin  //摆手时的停止态
		per_dian1 <= 0 ;
		per_dian2 <= 0 ;
		per_duo   <= duo_initial;
		led_mode_r<= 0 ;
	end 	  
	else if (mode == 6 /*&& distance1 >= safe_distance*/) begin  //摆手时的直行前态
		per_dian1 <= 500 + 500*rx_data[1:0]/4 ;
		per_dian2 <= 0 ;
		per_duo	  <= duo_initial ;
		led_mode_r<= 3 ;
	end 
	else begin 
		per_dian1  <= per_dian1 ; 
		per_dian2  <= per_dian2 ; 
	end 
end 
endmodule
