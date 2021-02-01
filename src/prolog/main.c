#include <unistd.h>
#include <setjmp.h>
#include <signal.h>
#include "prolog.h"


/************************************************************************/
/*	Initialise all modules. Must be called before anything else	*/
/************************************************************************/

static void pl_init(void)
{
	void	mem_init(), atom_init(), prove_init(), meta_init(),
		file_init(), lists_init(), eval_init(), math_init(),
		out_init(), compare_init(), db_init(), system_init(),
		lex_init(), read_init(), dcg_init(), unix_init(),
		socket_init(), plist_init(), worlds_init();

	mem_init();		/* must be called first */
	atom_init();
	prove_init();
	meta_init();
	file_init();
	lists_init();
	eval_init();
	math_init();
	out_init();
	compare_init();
	db_init();
	system_init();
	lex_init();
	read_init();
	dcg_init();
	unix_init();
	socket_init();
	plist_init();
}


/************************************************************************/
/*	Initialise; read command line arguments and start main loop	*/
/************************************************************************/

int main(int argc, char **argv)
{
	extern int optind;
	extern char *optarg;
	extern size_t global_size;
	int c;

	while ((c = getopt(argc, argv, "g:l:r:s:")) != EOF)
		switch (c)
		{
			case 'g':
				global_size = 1024 * atoi(optarg);
				break;
			case 's':
				tcp_socket_server(atoi(optarg));
				break;
			default:
				fprintf(stderr, "Incorrect argument\n");
				break;
		}

	pl_init();

	if (isatty(fileno(stdin)))
	{
		// Silliness to turn US date format into international format
		char day[3], month[4], year[5];
		sscanf(__DATE__, "%s %s %s", month, day, year);
		
		fprintf(stderr, "\niProlog (%s %s %s)\n", day, month, year);
	}

	while (optind < argc)
		read_file(intern(argv[optind++]));
	
	evloop();

	return 0;
}
