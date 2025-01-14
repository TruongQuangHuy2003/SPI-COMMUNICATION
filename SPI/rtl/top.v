module spi (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [7:0] data_in,
    input wire sel, // Select signal to choose between slave 1 and slave 2
    output reg [7:0] data_out1,
    output reg [7:0] data_out2,
    output reg done
);

    // Internal signals
    wire mosi;
    wire sck;
    wire cs;
    wire miso1, miso2;
    reg miso;

    wire [7:0] master_data_out;
    wire master_done;
    wire [7:0] slave_data_out1;
    wire [7:0] slave_data_out2;

    // Instantiate the master module
    master ic1(
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start), 
        .miso(miso), 
        .data_in(data_in), 
        .mosi(mosi), 
        .sck(sck), 
        .cs(cs), 
        .done(master_done)
    );

    // Instantiate slave 1
    slave ic2(
        .clk(clk), 
        .rst_n(rst_n), 
        .mosi(mosi), 
        .sck(sck), 
        .cs(cs & ~sel), // Activate slave 1 when sel = 0
        .miso(miso1), 
        .data_out(slave_data_out1)
    );

    // Instantiate slave 2
    slave ic3(
        .clk(clk), 
        .rst_n(rst_n), 
        .mosi(mosi), 
        .sck(sck), 
        .cs(cs & sel), // Activate slave 2 when sel = 1
        .miso(miso2), 
        .data_out(slave_data_out2)
    );

    // Output logic for `miso`
    always @(*) begin
        // Select the appropriate slave's miso line based on `sel`
        //miso = sel ? miso2 : miso1; 
	if (!sel) begin
		miso <= miso1;
	end else begin
		miso <= miso2;
	end
    end
  
    // Handle data outputs and completion signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out1 <= 8'h00;
            data_out2 <= 8'h00;
            done <= 1'b0;
        end else if (!sel) begin
            data_out1 <= slave_data_out1; // Output from slave 1
	    data_out2 <= 8'h00;
	    done <= master_done;
    	end else begin
	    data_out1 <= 8'h00;
            data_out2 <= slave_data_out2; // Output from slave 2
            done <= master_done;         // Done signal from master
        end
    end
endmodule

