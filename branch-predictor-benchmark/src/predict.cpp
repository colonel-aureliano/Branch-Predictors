// predict.cc
// This file contains the main function.  The program accepts a single 
// parameter: the name of a trace file.  It drives the branch predictor
// simulation by reading the trace file and feeding the traces one at a time
// to the branch predictor.

#include <stdio.h>
#include <stdlib.h>
#include <string.h> // in case you want to use e.g. memset
#include <assert.h>

#include "branch.hpp"
#include "traces.hpp"
#include "predictor.hpp"
#include "verilog_predictor.hpp"





double sc_time_stamp() {
    return main_time;  // Note does conversion to real, to match SystemC
}

int main (int argc, char *argv[]) {

	Verilated::commandArgs(argc, argv);
   
    std::string outname = "";
    for(int i =1; i<argc; i++){
        
            if (strcmp(argv[i], "--all") == 0) // This is your parameter name
            {                 
                all=true;    // Set flag
            }

            if (strcmp(argv[i], "--waves") == 0) // This is your parameter name
            {                 
                waves=true;    // Set flag
            }

            if (strcmp(argv[i], "--coverage") == 0) // This is your parameter name
            {                 
                coverage=true;    // Set flag
            }

            if (strcmp(argv[i], "--timming") == 0) // This is your parameter name
            {                 
                timming=true;    // Set flag
            }
            if (strcmp(argv[i], "--outname") == 0) // This is your parameter name
            {                 
                if(i+1<argc) outname = std::string(argv[i+1]) + ".";
            }

            if (strcmp(argv[i], "--trace") == 0) // This is your parameter name
            {                 
                trace=true;    // Set flag
            }
    }
    if(all){
        waves=true; 
        coverage=true;
        timming=true;
    }



	Verilated::debug(0);
    Verilated::randReset(2);
    Verilated::traceEverOn(true);
    Verilated::commandArgs(argc, argv);
    Verilated::mkdir("logs");
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    Verilated::commandArgs(argc, argv);
    contextp->traceEverOn(true);
    top = new Vtop{contextp.get(), "top"};

	tfp = new VerilatedFstC;
    Verilated::traceEverOn(true);
    Verilated::commandArgs(argc, argv);
    if(waves){
        top->trace(tfp, 99);  // Trace 99 levels of hierarchy
        Verilated::mkdir("waves");
        tfp->open((std::string("waves/")+outname +"waves.fst").c_str());
    }
	// make sure there is one parameter

	// if (argc != 2) {
	// 	fprintf (stderr, "Usage: %s <filename>.gz\n", argv[0]);
	// 	exit (1);
	// }

	// open the trace file for reading

	init_traces (argv[1]);

	// initialize competitor's branch prediction code

	branch_predictor *p = new verilog_predictor();

	// some statistics to keep, currently just for conditional branches

	long long int 
		tmiss = 0, 	// number of target mispredictions
		dmiss = 0, 	// number of direction mispredictions
		dtotal = 0; 	// number of direction mispredictions

	// keep looping until end of file

    //Start Verilog Simulator
    
    for(int x=0; x<10;x++) {
        tick();
    }

    //Go to main loop

	for (;;) {

		// get a trace

		traces *t = read_traces ();

		// NULL means end of file

		if (!t) break;

		// send this trace to the competitor's code for prediction

		

		// collect statistics for a conditional branch trace

		if (t->bi.br_flags & BR_CONDITIONAL) {
            branch_update *u = p->predict (t->bi);
			
            dtotal++;

			// count a direction misprediction

			dmiss += u->direction_prediction () != t->taken;

			// count a target misprediction

			tmiss += u->target_prediction () != t->target;

            p->update (u, t->taken, t->target);
		}

		// update competitor's state

		
	}

	// done reading traces

	end_traces ();
    top->final();
	// give final mispredictions per kilo-instruction and exit.
	// each trace represents exactly 100 million instructions.

	printf ("%0.3f MPKI\n", 1000.0 * (dmiss / 1e8));
	printf ("%0.3f Prediction accuarcy \n",  (float)(dtotal-dmiss) / dtotal);

    if(waves){
        tfp->close();
    }

	delete p;
	exit (0);
}
