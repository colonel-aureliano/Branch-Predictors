######################################################################
#   ECE-4750 Makefile for branch traces
#   Copyright (c) 2023 Socrates Wong / Cornell University 
#   Redistribution prohibited without explicited permisison 
#   from copyright holder. 
#   Download and use of these materials are permitted by Cornell 
#   students enrolled in ECE-4750 for individual educational 
#   noncommercial purposes only. Redistribution either in part or in 
#   whole via both commercial (e.g., Course Hero) or non-commercial 
#   (e.g., public website) requires written permission from the 
#   copyright holder.
#   Usage:
#
#       %.sim: To execute the trace and determine your branch prediction accuracy
#
#   Enviroment Variables:
#
#       DESIGN: Used to set the design in case a testbench supports
#           more then one design.  Not used for unit testbench. Is
#           automatically set in run-all and can be manually set with
#           tb_%.v.sim , %.hex.sim and %.hex.diff
#
#       PHT: Used to set the PHT size
######################################################################
######################################################################
# !!!!You should not need to modify this file!!!!  If you believe
# otherwise, please ask in Ed before you do so.
######################################################################
CXX		=	g++-10
CXXFLAGS	=	-g -O3 -Wall

VERILATOR_FLAGS =
VERILATOR_FLAGS = --trace-fst
VERILATOR_FLAGS += -cc --exe
VERILATOR_FLAGS += -O3 
VERILATOR_FLAGS += -x-assign 0
VERILATOR_FLAGS += -Wall
VERILATOR_FLAGS += --assert
VERILATOR_FLAGS += --timing
VERILATOR_FLAGS +=  -y ..
VERILATOR_FLAGS +=  -y ../../..
VERILATOR_FLAGS +=  -y test
VERILATOR_FLAGS +=  -y ../lab1_imul
VERILATOR_FLAGS +=  -y ../lab2_proc
VERILATOR_FLAGS +=  -y .
VERILATOR_FLAGS +=  -Wno-DECLFILENAME
VERILATOR_FLAGS +=  -Wno-UNUSEDSIGNAL
VERILATOR_FLAGS +=  -Wno-VARHIDDEN
VERILATOR_FLAGS +=  -Wno-UNDRIVEN
VERILATOR_FLAGS +=  -Wno-GENUNNAMED
VERILATOR_FLAGS +=  -Wno-UNUSEDPARAM
VERILATOR_FLAGS +=  -Wno-PINCONNECTEMPTY
ifndef PHT
	PHT = 2048
endif
ifndef DESIGN
	DESIGN  = BranchBimodal
endif

ifeq ($(VERILATOR_ROOT),)
	VERILATOR = verilator
	VERILATOR_COVERAGE = verilator_coverage
else
export VERILATOR_ROOT
	VERILATOR = $(VERILATOR_ROOT)/bin/verilator
	VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

all:		predict

predict:	predict.cpp traces.cpp predictor.hpp branch.hpp traces.hpp my_predictor.hpp
		$(CXX) $(CXXFLAGS) -o predict predict.cpp traces.cpp

clean:
		rm -f predict
		rm obj_dir/ -rf
		rm waves/ -rf
		rm logs/ -rf

%.sim:
	@echo
	@echo "-- VERILATE ----------------"
	$(VERILATOR) $(VERILATOR_FLAGS)   --trace --top-module top tb_Branch.v predict.cpp traces.cpp   +define+DESIGN=$(DESIGN)  +define+PHT=$(PHT) 

	@echo
	@echo "-- COMPILE -----------------"
	cp *.?pp obj_dir 
	$(MAKE)  -C obj_dir  -f Vtop.mk 

	@echo
	@echo "-- RUN ---------------------"
	@mkdir -p logs
	@echo 
	obj_dir/Vtop  $(basename $@)  --outname temp +trace --all --design $(DESIGN) --PHT $(PHT)

	@echo
	@echo "-- DONE --------------------"
	@printf "To see waveforms, open waves/%s.waves.fst in a waveform viewer" temp
	@echo
