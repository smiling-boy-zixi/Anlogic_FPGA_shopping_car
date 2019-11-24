module rfid_rx( 
input clk,
input rst,
input rxd,
input baud_tick,
output rx_int, ///////////////数据接收中断信号 ，告诉外部还在接收信息
output [7:0] roll
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
always @(posedge clk) begin 
	if(!rst) begin 
		rx_int_r <= 0;
		rx_en    <= 0;
	end 	
	else if(neg_rxd) begin 
		rx_int_r <= 1;
		rx_en    <= 1;
	end 
	else if(rx_num == 9) begin 
		rx_int_r <= 0;
		rx_en 	 <= 0;	
	end 
end 

assign rx_int = rx_int_r;
//--------------------------------------------------------------------------------------------------------------------
reg [7:0] rx_buf;
reg [7:0] rx_data_r [23:0] ;
reg [4:0] cnt_cnt;
integer i ;
always @(posedge clk) begin 
	if(!rst) begin 
	rx_num <= 0;
	cnt_cnt <= 0 ;
	end 
	else if (rx_en)
	begin  ///
		for(i = 0 ;i <= 23 ; i = i + 1 ) begin 
			if(baud_tick && cnt_cnt == i) begin
				rx_num <= rx_num + 1 ;
				case (rx_num)
				1: rx_buf[0] <= rxd ;
				2: rx_buf[1] <= rxd ;
				3: rx_buf[2] <= rxd ;
				4: rx_buf[3] <= rxd ;
				5: rx_buf[4] <= rxd ;
				6: rx_buf[5] <= rxd ;
				7: rx_buf[6] <= rxd ;
				8: rx_buf[7] <= rxd ;
				default : rx_buf[7] <= rx_buf[7] ;
				endcase		
			end ///////下面的加了不知道有用没
////			else if(rx_num == 9 && cnt_cnt == i && i <= 0 && rx_buf != 8'hbb) begin
////				rx_num 		<= 0;
////				cnt_cnt		<= 0;
////				rx_buf		<= 0;
////			end 
////			else if(rx_num == 9 && cnt_cnt == i && i <= 7 && rx_buf == 8'h7e) begin 
////				rx_num		<= 0;
////				cnt_cnt 	<= 0;
////				rx_buf 		<= 0;
////			end /////////
//			else if(rx_num == 9 && cnt_cnt == i && i <= 22) begin 
//				rx_num     	<= 0 ;
//				cnt_cnt		<= cnt_cnt + 1;
//				rx_data_r[i]<= rx_buf ;
//				rx_buf 		<= 0 ; 
//			end 			
//			else if(rx_num == 9 && /*cnt_cnt == i &&*/ cnt_cnt == 23 ) begin 
//				rx_num 		<= 0 ;
//				cnt_cnt 	<= 0 ;
//				rx_data_r[23] <= rx_buf ;
//				rx_buf 		<= 0 ;
//			end 
//			else if (rx_num == 9 && rx_buf == 8'h7e && cnt_cnt != 23) begin 
//				rx_num 		<= 0 ;
//				cnt_cnt 	<= 0 ;
//			end 
//			else  
//				cnt_cnt 	<= cnt_cnt ;
			else if(rx_num == 9 && cnt_cnt == i && i <= 22) begin 
				rx_num     	<= 0 ;
				cnt_cnt		<= cnt_cnt + 1;
				rx_data_r[i]<= rx_buf ;
				rx_buf 		<= 0 ; 
			end 			
			else if(rx_num == 9 &&cnt_cnt == 23 ) begin 
				rx_num 		<= 0 ;
				cnt_cnt 	<= 0 ;
				rx_data_r[23] <= rx_buf ;
				rx_buf 		<= 0 ;
			end 
			else if (rx_num == 9 && rx_buf == 8'h7e && cnt_cnt != 23) begin 
				rx_num 		<= 0 ;
				cnt_cnt 	<= 0 ;
			end 
		end 			
	end  ///
end 

//-------------------------------------------------------------------------------------

wire [7:0]  check ;
reg  [7:0]	roll_r;



assign check = rx_data_r[1] + rx_data_r[2] + rx_data_r[3] + rx_data_r[4] + rx_data_r[5] + rx_data_r[6] + rx_data_r[7] +rx_data_r[8] + rx_data_r[9] + rx_data_r[10] + rx_data_r[11] + rx_data_r[12] + rx_data_r[13] + rx_data_r[14] + rx_data_r[15] + rx_data_r[16] + rx_data_r[17] + rx_data_r[18] + rx_data_r[19] + rx_data_r[20] + rx_data_r[21] ;

always @(posedge clk) begin 
	if(rx_data_r[0] == 8'hbb &&rx_data_r[23] == 8'h7e && rx_data_r[22] == check && cnt_cnt == 0) begin 
	roll_r  <=  rx_data_r[19] ;
	end 
	else roll_r <= roll_r ;
end

assign roll = roll_r ;


endmodule
