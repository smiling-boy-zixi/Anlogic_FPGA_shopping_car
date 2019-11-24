module Echo(

input rst,
input clk,
input Echo_sign,
output [25:0] distance
);

reg [25:0] Echo_cnt;
reg [25:0] Echo_distance_t; ////cm

reg Echo_sign_delay_neg_1 ;
reg Echo_sign_delay_neg_2 ;

wire neg_Echo_sign ;

always@(posedge clk)begin
	if(!rst)begin
		Echo_sign_delay_neg_1 <= 1'b0 ;
		Echo_sign_delay_neg_2 <= 1'b0 ;
	end
	else begin
		Echo_sign_delay_neg_1 <= Echo_sign ;
		Echo_sign_delay_neg_2 <= Echo_sign_delay_neg_1 ;
	end
end

assign neg_Echo_sign = (Echo_sign_delay_neg_2 && ~Echo_sign_delay_neg_1) ;

always@(posedge clk)begin
	if(!rst)begin
	Echo_cnt <= 0 ;
	Echo_distance_t <= 0 ;
	end
	else if(Echo_sign == 1)begin
	Echo_cnt <= Echo_cnt + 1 ;
	end
	else if(neg_Echo_sign)begin
	Echo_distance_t <= Echo_cnt ;
	Echo_cnt <= 0 ;
	end
end

assign distance = Echo_distance_t*34000/48000000 ;//cm



endmodule
