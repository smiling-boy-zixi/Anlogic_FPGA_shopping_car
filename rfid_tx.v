module rfid_tx(
input clk_24M,
input rst,
input baud_tick,
input rx_int,	       //////收到的外部中断信号
output txd
);

reg rx_int0,rx_int1,rx_int2; ///寄存rx_int的值
wire neg_rx_int;       //////rx_int 下降沿标志位	

always @(posedge clk_24M or negedge rst) begin 
	if(!rst) begin 
		rx_int0 <= 0;
		rx_int1 <= 0;
		rx_int2 <= 0;		
	end 
	else	 begin 
		rx_int0 <= rx_int;
		rx_int1 <= rx_int0;
		rx_int2 <= rx_int1;
	end 
end 

assign reg_rx_int = ~rx_int1 & rx_int2; /////// 捕捉到下降沿后，neg_rx_int 拉高保持一个是主时钟周期
//--------------------------------------------------------------------------------------------------------

reg 		tx_enable;
reg [10:0] 	tx_num;
always @(posedge clk_24M) begin 
	if(!rst) begin 
		tx_enable <= 0 ;

	end 
	else if (reg_rx_int) begin 
		tx_enable <= 1;
	end 	
	else if (tx_num == 100) tx_enable <= 0;  //////////////////这里改了
	else tx_enable <= tx_enable ;
end 

//-------------------------------------------------------------------------------------------------------
reg txd_r;
always @(posedge clk_24M) begin 
	if(!rst) begin 
		txd_r  <= 1;
		tx_num <= 0;
	end 
	else if (tx_enable)	begin
		if(baud_tick ) begin 
			tx_num <= tx_num + 1 ;
			case (tx_num)
				0: txd_r <= 0;
				1: txd_r <= 1;
				2: txd_r <= 1;
				3: txd_r <= 0;
				4: txd_r <= 1;
				5: txd_r <= 1;
				6: txd_r <= 1;
				7: txd_r <= 0;
				8: txd_r <= 1;
				9: txd_r <= 1;
				10: txd_r <= 0;
				11: txd_r <= 0;
				12: txd_r <= 0;
				13: txd_r <= 0;
				14: txd_r <= 0;
				15: txd_r <= 0;
				16: txd_r <= 0;
				17: txd_r <= 0;
				18: txd_r <= 0;
				19: txd_r <= 1;
				20: txd_r <= 0;
				21: txd_r <= 1;
				22: txd_r <= 1;
				23: txd_r <= 1;
				24: txd_r <= 0;
				25: txd_r <= 0;
				26: txd_r <= 1;
				27: txd_r <= 0;
				28: txd_r <= 0;
				29: txd_r <= 1;
				30: txd_r <= 0;
				31: txd_r <= 0;
				32: txd_r <= 0;
				33: txd_r <= 0;
				34: txd_r <= 0;
				35: txd_r <= 0;
				36: txd_r <= 0;
				37: txd_r <= 0;
				38: txd_r <= 0;
				39: txd_r <= 1;
				40: txd_r <= 0;
				41: txd_r <= 1;
				42: txd_r <= 1;
				43: txd_r <= 0;
				44: txd_r <= 0;
				45: txd_r <= 0;
				46: txd_r <= 0;
				47: txd_r <= 0;
				48: txd_r <= 0;
				49: txd_r <= 1;
				50: txd_r <= 0;
				51: txd_r <= 0;
				52: txd_r <= 1;
				53: txd_r <= 0;
				54: txd_r <= 0;
				55: txd_r <= 0;
				56: txd_r <= 1;
				57: txd_r <= 0;
				58: txd_r <= 0;
				59: txd_r <= 1;
				60: txd_r <= 0;
				61: txd_r <= 0;
				62: txd_r <= 0;
				63: txd_r <= 0;
				64: txd_r <= 0;
				65: txd_r <= 0;
				66: txd_r <= 0; 
				67: txd_r <= 0;
				68: txd_r <= 0;
				69: txd_r <= 1;
				70: txd_r <= 0;
				71: txd_r <= 0;
				72: txd_r <= 0;
				73: txd_r <= 1;
				74: txd_r <= 0;
				75: txd_r <= 0;
				76: txd_r <= 1;
				77: txd_r <= 1;
				78: txd_r <= 0;
				79: txd_r <= 1;
				80: txd_r <= 0;
				81: txd_r <= 0;
				82: txd_r <= 0;
				83: txd_r <= 0;
				84: txd_r <= 0;
				85: txd_r <= 1;
				86: txd_r <= 1;
				87: txd_r <= 0;
				88: txd_r <= 1;
				89: txd_r <= 1;
				90: txd_r <= 0;
				91: txd_r <= 0;
				92: txd_r <= 1;
				93: txd_r <= 1;
				94: txd_r <= 1;
				95: txd_r <= 1;
				96: txd_r <= 1;
				97: txd_r <= 1;
				98: txd_r <= 0;
				99: txd_r <= 1;
				default : txd_r <= 1;	
			endcase 
		end 
		else if(tx_num == 100) tx_num <= 0 ;
		else tx_num <= tx_num ;
	end 
	else txd_r <= 1 ;
end 

assign txd = txd_r ;




endmodule
