/************************************************************************/
/*	Initialise all modules. Must be called before anything else	*/
/************************************************************************/

#include <stdio.h>

void init()
{
	void	set_init(), bayes_init(), atms_init(), aq_init(), id_init(),
	induct_init(), rt_init(), bp_init(), duce_init(), scw_init();
	
	void	discrim_init(), line_init(), mreg_init();
	
	
	set_init();
	bayes_init();
	atms_init();
	aq_init();
	id_init();
	induct_init();
	rt_init();
	bp_init();
	duce_init();
	scw_init();
	
	discrim_init();
	line_init();
	mreg_init();

	fprintf(stderr, "Machine Learning library loaded\n");
}
