module baud_generator(
	input clk,
	output  baud_tick
);
parameter clk_frequency = 24_000_000 ;
parameter baud = 9600;
parameter baud_cnt_width = 17; /////这里至少16 不然灵敏度很低  再高到18也不行，直接炸了（估计超位宽了）
parameter baud_temp = (baud<<baud_cnt_width)/clk_frequency;//左移几位就是乘2的几次方


reg [baud_cnt_width:0] baud_cnt;//第一位是分频进位的
reg baud_tick_r;

always @(posedge clk) begin 
	baud_cnt <= baud_cnt[baud_cnt_width-1:0] + baud_temp;
	baud_tick_r <= baud_cnt[baud_cnt_width];
end 

assign baud_tick = baud_tick_r;
endmodule
