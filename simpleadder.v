module simpleadder(input wire clk,

		   input wire en_i,
		   input wire ina,
		   input wire inb,

		   output reg en_o,
		   output reg out);


	integer counter, state;
	reg[1:0] temp_a, temp_b;
	reg[2:0] temp_out;

	//Init
	initial begin
		counter = 0;
		temp_a = 2'b00;
		temp_b = 2'b00;
		temp_out = 3'b000;
		out = 0;

		en_o <= 0;
		state = 0;
	end
	
	always@(posedge clk)
	begin
		//State 0: Wait for en_i
		if(en_i==1'b1)
		begin
			state = 1;
		end

		case(state)
			//State 1: Start reading inputs
			1: begin
				temp_a = temp_a << 1;
				temp_a = temp_a | ina;
			
				temp_b = temp_b << 1;
				temp_b = temp_b | inb;

				counter = counter + 1;

				//After 2 bits, do the operation an move to the next state
				if(counter==2) begin
					temp_out = temp_a + temp_b;

					state = 2;
				end
			end

			//State 2: Enable en_o and sends result to the output
			2: begin
				out <= temp_out[2];
				temp_out = temp_out << 1;

				counter = counter + 1;

				if(counter==3) en_o <= 1'b1;

				if(counter==4) en_o <= 1'b0;

				if(counter==6) begin
					counter = 0;
					out <= 1'b0;
					state = 0;
				end
			end
		endcase
	end
endmodule
