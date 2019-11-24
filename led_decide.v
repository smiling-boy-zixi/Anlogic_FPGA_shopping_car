module led_decide(
input clk,
input rst,
input wire [7:0] 	rfid_rxd,
output wire [7:0] 	led,
output wire [2:0]	led_dec
 );
 
reg [7:0] 	led_r ;
reg [2:0]	led_dec_r;

always@(posedge clk)begin
	if(!rst)begin
		led_r <= 8'h00;
	end
	else if (rfid_rxd && rfid_rxd == 8'd17)begin
		led_r[7:0] <= rfid_rxd[7:0];
		led_dec_r <= 2'b01; 
	end
	else if(rfid_rxd && rfid_rxd == 8'd9)begin
		led_r[7:0] <= rfid_rxd[7:0];
		led_dec_r <= 2'b10; 
	end
//	else if(rfid_rxd != 8'd9 && rfid_rxd == 8'd17)begin
//		led_dec_r <= 3;
//	end
		
end

assign led = led_r ;
assign led_dec = led_dec_r;

endmodule