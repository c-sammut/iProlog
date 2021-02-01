/************************************************************************/
/*	Initialise all modules. Must be called before anything else	*/
/************************************************************************/

#include <stdio.h>

void init()
{
	void	refine_init(), lgg_init(), golem_init(), progol_init(),
		clause_diff_init();

	refine_init();
	lgg_init();
	golem_init();
	progol_init();
	clause_diff_init();

	fprintf(stderr, "ILP library loaded\n");
}
