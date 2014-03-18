class simpleadder_monitor_before extends uvm_monitor;
	`uvm_component_utils(simpleadder_monitor_before)

	uvm_analysis_port#(simpleadder_transaction) mon_ap_before;

	virtual simpleadder_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual simpleadder_if)::read_by_name
			(.scope("ifs"), .name("simpleadder_if"), .val(vif)));
		mon_ap_before = new(.name("mon_ap_before"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		integer counter_mon = 0, state = 0;

		simpleadder_transaction sa_tx;
		sa_tx = simpleadder_transaction::type_id::create
			(.name("sa_tx"), .contxt(get_full_name()));

		forever begin
			@(posedge vif.sig_clock)
			begin
				if(vif.sig_en_o==1'b1)
				begin
					state = 3;
				end

				if(state==3)
				begin
					sa_tx.out = sa_tx.out << 1;
					sa_tx.out[0] = vif.sig_out;

					counter_mon = counter_mon + 1;

					if(counter_mon==3)
					begin
						state = 0;
						counter_mon = 0;

						//Send the transaction to the analysis port
						mon_ap_before.write(sa_tx);
					end
				end
			end
		end
	endtask: run_phase
endclass: simpleadder_monitor_before

class simpleadder_monitor_after extends uvm_monitor;
	`uvm_component_utils(simpleadder_monitor_after)

	uvm_analysis_port#(simpleadder_transaction) mon_ap_after;

	virtual simpleadder_if vif;

	simpleadder_transaction sa_tx;
	
	//For coverage
	simpleadder_transaction sa_tx_cg;

	//Define coverpoints
	covergroup simpleadder_cg;
      		ina_cp:     coverpoint sa_tx_cg.ina;
      		inb_cp:     coverpoint sa_tx_cg.inb;
		cross ina_cp, inb_cp;
	endgroup: simpleadder_cg

	function new(string name, uvm_component parent);
		super.new(name, parent);
		simpleadder_cg = new;
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual simpleadder_if)::read_by_name
			(.scope("ifs"), .name("simpleadder_if"), .val(vif)));
		mon_ap_after= new(.name("mon_ap_after"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		integer counter_mon = 0, state = 0;
		sa_tx = simpleadder_transaction::type_id::create
			(.name("sa_tx"), .contxt(get_full_name()));

		forever begin
			@(posedge vif.sig_clock)
			begin
				if(vif.sig_en_i==1'b1)
				begin
					state = 1;
					sa_tx.ina = 2'b00;
					sa_tx.inb = 2'b00;
					sa_tx.out = 3'b000;
				end

				if(state==1)
				begin
					sa_tx.ina = sa_tx.ina << 1;
					sa_tx.inb = sa_tx.inb << 1;

					sa_tx.ina[0] = vif.sig_ina;
					sa_tx.inb[0] = vif.sig_inb;

					counter_mon = counter_mon + 1;

					if(counter_mon==2)
					begin
						state = 0;
						counter_mon = 0;

						//Predict the result
						predictor();
						sa_tx_cg = sa_tx;

						//Coverage
						simpleadder_cg.sample();

						//Send the transaction to the analysis port
						mon_ap_after.write(sa_tx);
					end
				end
			end
		end
	endtask: run_phase

	virtual function void predictor();
		sa_tx.out = sa_tx.ina + sa_tx.inb;
	endfunction: predictor
endclass: simpleadder_monitor_after
