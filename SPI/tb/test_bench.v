`timescale 1ns/1ps
module test_bench;
	reg clk;
	reg rst_n;
	reg start;
	reg [7:0] data_in;
	reg sel;
	wire [7:0] data_out1;
	wire [7:0] data_out2;
	wire done;

	reg [7:0] expected;
	integer i;

	spi dut(
		.clk(clk),
		.rst_n(rst_n),
		.start(start),
		.data_in(data_in),
		.sel(sel),
		.data_out1(data_out1),
		.data_out2(data_out2),
		.done(done)
	);

	initial clk = 0;
		always #5 clk = ~clk;

	task verify;
		input [7:0] test_data;
		input sel;
		reg [7:0] exp_data;
		begin
			data_in = 8'h00;
			start = 1'b0;
			@(posedge clk);
			data_in = test_data;
			start = 1'b1;
			@(posedge clk);
			start = 1'b0;
			wait(done);

			exp_data = test_data;
			@(posedge clk);
			$display("At time: %t, rst_n = 1'b%b, start = 1'b%b, data_in = 8'b%b, sel = 1'b%b", $time, rst_n, start, data_in, sel);
			if((sel == 0 && data_out1 == exp_data && data_out2 == 8'h00) || (sel == 1 && data_out2 == exp_data && data_out1 == 8'h00)) begin
				$display("-----------------------------------------------------------------------------------------------------------------");
				$display("PASSED: Sel = 1'b%b, Sent = 0x%h, Received: 0x%h", sel, test_data, sel ? data_out2 : data_out1);
				$display("-----------------------------------------------------------------------------------------------------------------");
			end else begin
				$display("-----------------------------------------------------------------------------------------------------------------");
				$display("FAILED: Sel = 1'b%b, Sent = 0x%h, Received: 0x%h", sel, test_data, sel ? data_out2 : data_out1);
				$display("-----------------------------------------------------------------------------------------------------------------");
			end
		end
	endtask

	initial begin
		$dumpfile("test_bench.vcd");
		$dumpvars(0, test_bench);

		$display("-----------------------------------------------------------------------------------------------------------------------------");
		$display("--------------------------------------------TESTBENCH FOR SPI COMMUNICATION--------------------------------------------------");
		$display("-----------------------------------------------------------------------------------------------------------------------------");

		rst_n = 0;
		@(posedge clk);
		rst_n = 1;
		sel = 1'b1;
		@(posedge clk);
		verify(8'hf0,1);

		sel = 1'b0;
		@(posedge clk);
		verify(8'h55,sel);

		sel = 1'b0;
		@(posedge clk);
		verify(8'hff,sel);
		
		for (i = 0; i < 20; i = i + 1) begin
			sel = $random % 2;
			@(posedge clk);
			expected = $random % 256;
			verify(expected, sel);
		end

		$display("--------------------------------- COMPLETED TESTBENCH -----------------------------------------------------------------------");

		#100;
		$finish;

	end
endmodule

