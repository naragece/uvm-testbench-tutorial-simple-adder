`timescale 1ns/10ps

module timeunit;
	initial $timeformat(-9,1," ns",9);
endmodule

module simpleadder_tb();
	reg clk;
	reg ina;
	reg inb;
	reg en_i;
	wire out;
	wire en_o;

	reg[1:0] tx_ina;
	reg[1:0] tx_inb;

	integer state_drv;

	integer counter_drv, counter_finish;

	//Connect the DUT to the TB
	simpleadder dut(.clk(clk),
			.ina(ina),
			.inb(inb),
			.en_i(en_i),
			.out(out),
			.en_o(en_o));

	initial begin
		clk = 1'b0;
		ina = 1'b0;
		inb = 1'b0;
		en_i = 1'b0;

		tx_ina = 2'b11;
		tx_inb = 2'b10;

		state_drv = 0;

		counter_drv = 0;
		counter_finish = 0;
	end
	
	//Generates clock
	initial begin
		#20;
		forever #20 clk = ! clk;
	end
	
	//Stops testbench after 30 clock cyles
	always@(posedge clk)
	begin
		counter_finish = counter_finish + 1;
		
		if(counter_finish == 30) $finish;
	end
	
	//Driver
	always@(posedge clk)
	begin

		//State 0: Drives the signal en_o
		if(counter_drv==0)
		begin
			en_i = 1'b1;
			state_drv = 1;
		end

		if(counter_drv==1)
		begin
			en_i = 1'b0;
		end

		case(state_drv)
			//State 1: Transmits the two inputs ina and inb
			1: begin
				ina = tx_ina[1];
				inb = tx_inb[1];

				tx_ina = tx_ina << 1;
				tx_inb = tx_inb << 1;

				counter_drv = counter_drv + 1;
				if(counter_drv==2) state_drv = 2;
			end

			//State 2: Waits for the DUT to respond
			2: begin
				ina = 1'b0;
				inb = 1'b0;
				counter_drv = counter_drv + 1;

				//After the supposed response, the TB starts over
				if(counter_drv==6)
				begin
					counter_drv = 0;
					state_drv = 0;
					
					//Restores the values of ina and inb to send again to the DUT
					tx_ina <= 2'b11;
					tx_inb = 2'b10;
				end
			end
		endcase
	end
	
	//Dump variables
	initial begin
		$dumpfile("simpleadder.dump");
		$dumpvars(0, simpleadder, simpleadder_tb);
	end
endmodule
