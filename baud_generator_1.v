module baud_generator_1(	
	input clk,
	input rst,
	input baud_en,
	output  baud_tick
);
parameter clk_frequency = 24_000_000 ;
parameter baud = 9600;
parameter baud_cnt_width = 15;
parameter baud_temp = (baud<<baud_cnt_width)/clk_frequency;//左移几位就是乘2的几次方


reg [baud_cnt_width:0] baud_cnt;//第一位是分频进位的
reg baud_tick_r;

always @(posedge clk) begin 
	if(!rst ) baud_cnt <= 500;
	if(baud_en==1) begin 
		baud_cnt <= baud_cnt[baud_cnt_width-1:0] + baud_temp;
		baud_tick_r <= baud_cnt[baud_cnt_width];
	end 
	else baud_cnt <= baud_cnt;
end 

assign baud_tick = baud_tick_r;
endmodule

