module master(
	input wire clk,
	input wire rst_n,
	input wire start,
	input wire miso,
	input wire [7:0] data_in,
	output reg mosi,
	output reg sck,
	output reg cs,
	output reg done
);

localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam TRANSFER = 2'b10;
localparam DONE = 2'b11;

reg [1:0] state, next_state;
reg [3:0] bit_cnt; // counting bits transmited.
reg [7:0] shift_reg; // Register for the bit translation.
reg shift_sck; // Used to create the signal SCK

// Defining the next state.
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state <= IDLE;
	end else begin
		state <= next_state;
	end
end

// FSM logic to control the SPI signals
always @(*) begin
	case(state)
		IDLE: begin
			if(start) begin
				next_state <= START; // transfer to the START state when the start signal is 1
			end else begin
				next_state <= IDLE;
			end
		end
		START: next_state <= TRANSFER; // after setuping before transfer to the TRANSFER state
		TRANSFER: begin
			if(bit_cnt == 4'b1000 && shift_sck) begin
				next_state <= DONE; // When the 8 bits are transmited , transfer to the DONE state
			end else begin
				next_state <= TRANSFER; // continue to transmit datas.
			end
		end
		DONE: next_state <= IDLE; // after communication, return to the IDLE state.
		default: next_state <= IDLE;
	endcase
end

// Logic to create the SPI signal
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mosi <= 1'b0;
		sck <= 1'b0;
		cs <= 1'b0;
		//data_out <= 8'h00;
		done <= 1'b0;
		bit_cnt <= 4'b0;
		shift_reg <= 8'h00;
		shift_sck <= 1'b0;
	end else begin
		case(state)
			IDLE: begin
				cs <= 1'b0; // cancel activate cs when the state is IDLE.
				done <= 1'b0;
				mosi <= 0;
				sck <= 1'b0;
				shift_sck <= 1'b0;
				//data_out <= 8'h00;
			end
			START: begin
				cs <= 1'b1;
				shift_reg <= data_in; // setup data need to send
				bit_cnt <= 4'b000;
				done <= 1'b0;
			end
			TRANSFER: begin
				shift_sck = ~shift_sck; // generate SCK clock pulse
				sck <= shift_sck;
				if(shift_sck) begin
					mosi <= shift_reg[7];
					shift_reg <= {shift_reg[6:0],1'b0};
					bit_cnt <= bit_cnt + 1'b1;
				end
			end
			DONE: begin
				cs <= 1'b0;
				done <= 1'b1;
			end
			default: begin
				cs <= 1'b0;
				done <= 1'b0;
			end
		endcase
	end
end
endmodule

