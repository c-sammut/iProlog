/*
void version(char **version_id)
{
	void	frame_init(), rdr_init(), print_rule_init();
	void	probot_init(), script_init();
	void	xforms_init(), frame_browser_init(), rdr_GUI_init(),
		instance_init();


	frame_init();
	rdr_init();
	print_rule_init();

	probot_init();
	script_init();

	xforms_init();
	frame_browser_init();
	rdr_GUI_init();
	instance_init();
	
	*version_id = "iProlog GUI (15 November 2007)";
}
*/

#include <stdio.h>

void init()
{
	void xforms_init(), frame_browser_init(), rdr_GUI_init(), instance_init();
	void load_library(char *);
	
	load_library("probot");
	
	xforms_init();
	frame_browser_init();
	rdr_GUI_init();
	instance_init();

	fprintf(stderr, "Graphical user interface library loaded\n");
}
