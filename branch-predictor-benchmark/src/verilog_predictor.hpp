

class my_update : public branch_update {
public:
	unsigned int index;
};

class verilog_predictor : public branch_predictor {
public:
#define HISTORY_LENGTH	15
#define TABLE_BITS	15
	my_update u;
	branch_info bi;
	unsigned int history;
	unsigned char tab[1<<TABLE_BITS];

	verilog_predictor (void) {}

	branch_update *predict (branch_info & b) {
		u.index= b.address ;
		top->PC=b.address ;
		tick();
		tick();
		u.direction_prediction (top->prediction);
		// if (b.br_flags & BR_CONDITIONAL) {
		// 	u.direction_prediction (top->prediction);
		// } else {
		// 	u.direction_prediction (true);
		// }
		u.target_prediction (0);
		return &u;
	}

	void update (branch_update *u, bool taken, unsigned int target) {
		//printf("updating PC: %hd, value %d",((my_update *)u)->index, taken );
		top->PC=((my_update *)u)->index ;
		top-> update_val =taken;
		top-> update_en =1;
		tick();
		tick();
		top-> update_en =0;
	}
};
