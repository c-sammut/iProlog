/************************************************************************/
/*	Initialise all modules. Must be called before anything else	*/
/************************************************************************/

#include <stdio.h>

void init()
{
	void frame_init(), rdr_init(), print_rule_init();

	frame_init();
	rdr_init();
	print_rule_init();

	fprintf(stderr, "Frames and rule-based systems ready\n");
}
