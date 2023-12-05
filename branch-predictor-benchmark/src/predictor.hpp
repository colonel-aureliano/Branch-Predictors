// predictor.h
// This file declares branch_update and branch_predictor classes.

#include <verilated.h>

#include "verilated_fst_c.h"
#include "verilated_vcd_c.h"
#include "Vtop.h"
#include <iostream>
#include <fstream>
#include "svdpi.h"

Vtop* top;
vluint64_t main_time = 0;
VerilatedFstC* tfp;
 bool timming = false;
bool coverage = false;
bool waves = false;
bool all = false;
bool trace = false;

void tick(){
	main_time+=1;
	top->clk = !top->clk;
	top->reset = 0;
	if (main_time < 5) {
		top->reset = 1;
	}
	top->eval();
	if(waves){
		tfp->dump (main_time);
	}
}

class branch_update {
	bool _direction_prediction;
	unsigned int _target_prediction;

public:
	bool direction_prediction () { return _direction_prediction; }
	void direction_prediction (bool b) { _direction_prediction = b; }

	bool target_prediction () { return _target_prediction; }
	void target_prediction (unsigned int t) { _target_prediction = t; }

	branch_update (void) : 
		_direction_prediction(false), _target_prediction(0) {}
};

class branch_predictor {
public:
	virtual branch_update *predict (branch_info &) = 0;
	virtual void update (branch_update *, bool, unsigned int) {}
	virtual ~branch_predictor (void) {}
};
