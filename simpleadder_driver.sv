class simpleadder_driver extends uvm_driver#(simpleadder_transaction);
	`uvm_component_utils(simpleadder_driver)

	virtual simpleadder_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual simpleadder_if)::read_by_name
			(.scope("ifs"), .name("simpleadder_if"), .val(vif)));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		drive();
	endtask: run_phase

	virtual task drive();
		simpleadder_transaction sa_tx;
		integer counter = 0, state = 0;
		vif.sig_ina = 0'b0;
		vif.sig_inb = 0'b0;
		vif.sig_en_i = 1'b0;

		forever begin
			if(counter==0)
			begin
				seq_item_port.get_next_item(sa_tx);
				//`uvm_info("sa_driver", sa_tx.sprint(), UVM_LOW);
			end

			@(posedge vif.sig_clock)
			begin
				if(counter==0)
				begin
					vif.sig_en_i = 1'b1;
					state = 1;
				end

				if(counter==1)
				begin
					vif.sig_en_i = 1'b0;
				end

				case(state)
					1: begin
						vif.sig_ina = sa_tx.ina[1];
						vif.sig_inb = sa_tx.inb[1];

						sa_tx.ina = sa_tx.ina << 1;
						sa_tx.inb = sa_tx.inb << 1;
						
						counter = counter + 1;
						if(counter==2) state = 2;
					end

					2: begin
						vif.sig_ina = 1'b0;
						vif.sig_inb = 1'b0;
						counter = counter + 1;

						if(counter==6)
						begin
							counter = 0;
							state = 0;
							seq_item_port.item_done();
						end
					end
				endcase
			end
		end
	endtask: drive
endclass: simpleadder_driver
