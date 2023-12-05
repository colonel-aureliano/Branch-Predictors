// trace.h
// This file declares functions and a struct for reading trace files.

// these #define the Unix commands for decompressing gzip, bzip2, and
// plain files.  If they are somewhere else on your system, change these
// definitions.

#define ZCAT            "/bin/gzip -dc"
#define BZCAT           "/usr/bin/bzip2 -dc"
#define CAT             "/bin/cat"

struct traces {
	bool	taken;
	unsigned int target;
	branch_info bi;
};

void init_traces (char *);
traces *read_traces (void);
void end_traces (void);
