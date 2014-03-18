`include "simpleadder_pkg.sv"
`include "simpleadder.v"
`include "simpleadder_if.sv"

module simpleadder_tb_top;
	import uvm_pkg::*;

	//Interface declaration
	simpleadder_if vif();

	//Connects the Interface to the DUT
	simpleadder dut(vif.sig_clock,
			vif.sig_en_i,
			vif.sig_ina,
			vif.sig_inb,
			vif.sig_en_o,
			vif.sig_out);

	initial begin
		//Registers the Interface in the configuration block so that other
		//blocks can use it
		uvm_resource_db#(virtual simpleadder_if)::set
			(.scope("ifs"), .name("simpleadder_if"), .val(vif));

		//Executes the test
		run_test();
	end

	//Variable initialization
	initial begin
		vif.sig_clock <= 1'b1;
	end

	//Clock generation
	always
		#5 vif.sig_clock = ~vif.sig_clock;
endmodule
