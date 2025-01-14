module slave(
	input wire clk,
	input wire rst_n,
	input wire mosi,
	input wire sck,
	input wire cs,
	output reg miso,
	output reg [7:0] data_out
);

reg [7:0] shift_reg;
reg [2:0] bit_cnt;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		miso <= 1'b0;
		data_out <= 8'h00;
		shift_reg <= 8'h00;
		bit_cnt <= 3'b000;
	end else if (cs == 1) begin
		if(sck) begin
			shift_reg <= {shift_reg[6:0], mosi};
			if(bit_cnt == 3'b111) begin
				data_out <= {shift_reg[6:0], mosi};
			end
			bit_cnt <= bit_cnt + 1'b1;
		end
		miso <= shift_reg[7];
	end else begin
		miso <= 1'b0;
	end
end

endmodule

