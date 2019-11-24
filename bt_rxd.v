module bt_rxd(
input clk,
input rst,
input rxd,
input baud_tick,
output rx_int, ///////////////数据接收中断信号 ，告诉外部还在接收信息
output [7:0] rx_data,
output baud_en
);

reg rxd0,rxd1,rxd2,rxd3;
wire neg_rxd; ///////////捕捉rxd的下降沿，并拉高一个主时钟周期
always @(posedge clk) begin 
	if(!rst)
	begin 
		rxd0 <= 0 ;
		rxd1 <= 0 ;
		rxd2 <= 0 ; 
		rxd3 <= 0 ;	
	end 
	else 
	begin 
		rxd0 <= rxd;
		rxd1 <= rxd0;
		rxd2 <= rxd1;
		rxd3 <= rxd2;
	end 
end 

assign neg_rxd =   ~rxd0 & ~rxd1 & rxd2 & rxd3; 
//--------------------------------------------------------------------------------------------------------------------
reg rx_int_r; /////接收信息期间为高 否则低
reg rx_en;
reg [3:0] rx_num;
reg baud_en_r;
always @(posedge clk) begin 
	if(!rst) begin 
		rx_int_r <= 0;
		rx_en    <= 0;
		baud_en_r <= 0;
	end 	
	else if(neg_rxd) begin 
		rx_int_r <= 1;
		rx_en    <= 1;
		baud_en_r<= 1;
	end 
	else if(rx_num == 8) begin 
		rx_int_r <= 0;
		rx_en 	 <= 0;
		baud_en_r<= 0;
	
	end 
end 

assign rx_int = rx_int_r;
assign baud_en = baud_en_r;
//--------------------------------------------------------------------------------------------------------------------
reg [7:0] rx_buf;
reg [7:0] rx_data_r;
always @(posedge clk) begin 
	if(!rst) begin 
	rx_num <= 0;
	end 
	else if (rx_en)
	begin 
		if(baud_tick) begin 
			rx_num <= rx_num + 1;
			case (rx_num)
			0: rx_buf[0] <= rxd ;
			1: rx_buf[1] <= rxd ;
			2: rx_buf[2] <= rxd ;
			3: rx_buf[3] <= rxd ;
			4: rx_buf[4] <= rxd ;
			5: rx_buf[5] <= rxd ;
			6: rx_buf[6] <= rxd ;
			7: rx_buf[7] <= rxd ;
			default:rx_buf[7] <= 1 ;
			endcase		
		end 
		else if(rx_num == 8) begin 
		rx_num 		<= 0;
		rx_data_r 	<= rx_buf;
		end 		
	end 
end 

assign rx_data = rx_data_r ;



endmodule
