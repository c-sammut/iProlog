/************************************************************************/
/*			Unix system predicates				*/
/************************************************************************/

#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/time.h>
#include <sys/stat.h>

#include "prolog.h"

#define MAX_FDS	(sizeof(int) * 8)


/************************************************************************/
/*			getenv(+EnvironmentVariable, -Value)		*/
/************************************************************************/

static bool p_getenv(term goal, term *frame)
{
	term env_var = check_arg(1, goal, frame, ATOM, IN);
	term env_val = check_arg(2, goal, frame, ATOM, OUT);
	char *p = getenv(NAME(env_var));

	if (p == NULL)
		fail("Environment variable does not exist");
	return unify(env_val, frame, intern(p), frame);
}


/************************************************************************/
/*			   system(+CommandString)			*/
/************************************************************************/

static bool p_system(term goal, term *frame)
{
	term cmd = check_arg(1, goal, frame, ATOM, IN);

	return (system(NAME(cmd)) == 0);
}


/************************************************************************/
/*				ed +ProcName				*/
/************************************************************************/

static bool ed(term goal, term *frame)
{
	FILE *old_output = output;
	char buf[128], *editor, temp_file[32];
	term name = check_arg(1, goal, frame, ATOM, IN);
	term old_defn = PROC(name);

	strcpy(temp_file, "/tmp/iprolog.XXXXXX");

	if (old_defn)
	{
		int fd = mkstemp(temp_file);

		if ((output = fdopen(fd, "w")) == NULL)
		{
			output = old_output;
			fail("Couldn't open tmp file for editor");
		}
		list_proc(old_defn);
		fclose(output);
		output = old_output;
	}

	if (!(editor = getenv("EDITOR")))
		editor = "vi";

	sprintf(buf, "%s %s", editor, temp_file);

	repeat
	{
		term ans;

		PROC(name) = NULL;
		system(buf);
		if (input_file(temp_file))
		{
			if (old_defn) free_proc(old_defn);
			break;
		}

		fprintf(stderr,"Re-edit?(y/n) ");
		set_prompt(NULL);
		ans = get_atom();
		if (NAME(ans)[0] == 'n')
		{
			if (PROC(name)) free_proc(PROC(name));
			PROC(name) = old_defn;
			fprintf(stderr, "Old definition restored\n");
			break;
		}
	}
	unlink(temp_file);
	return true;
}


/************************************************************************/
/*	Set up pipes and fork new process to communicate with parent	*/
/************************************************************************/

#define	READ 0
#define	WRITE 1

static int pipe_process(char *name, int *readp, int *writep, int child_i, int child_o)
{
	int pid, send_pipe[2], receive_pipe[2];

	pipe(send_pipe);
	pipe(receive_pipe);

	switch (pid = fork())
	{
	    case -1:	/* fork failed */

			close(send_pipe[READ]);
			close(send_pipe[WRITE]);
			close(receive_pipe[READ]);
			close(receive_pipe[WRITE]);
			fail("fork failed");

	    case 0:	/* child */

			signal(SIGINT, SIG_IGN);

			dup2(send_pipe[READ], child_i == -1 ? 0 : child_i);
			dup2(receive_pipe[WRITE], child_o == -1 ? 1 : child_o);

			close(send_pipe[WRITE]);
			close(receive_pipe[READ]);

			execlp("/bin/sh", "sh", "-c", name, NULL);
			fprintf(stderr, "\nexec fail\n");
			exit(1);

	    default:	/* parent */

			close(send_pipe[READ]);
			close(receive_pipe[WRITE]);

			*writep = send_pipe[WRITE];
			*readp = receive_pipe[READ];

			return pid;
	}
}


void send_to(char *cmd, FILE **send, FILE **recieve)
{
	int parent_i, parent_o;
	
	pipe_process(cmd, &parent_i, &parent_o, -1, -1);

	*recieve = fdopen(parent_i, "r");
	*send = fdopen(parent_o, "w");
}


/************************************************************************/
/*		process(+ProgramName, -SendStream, -ReceiveSteam)	*/
/************************************************************************/

static bool p_process(term goal, term *frame)
{
	term cmd = check_arg(1, goal, frame, ATOM, IN);
	term send = check_arg(2, goal, frame, STREAM, OUT);
	term receive = check_arg(3, goal, frame, STREAM, OUT);
	int parent_i, parent_o, child_i = -1, child_o = -1;

	if (send == receive)
		fail("I/O streams must be different");

	if (TYPE(send) == STREAM)
	{
		if (NAME(MODE(send))[0] != 'w')
			fail("Can't send on an input stream");

		child_i = fileno(FPTR(send));		/*child's input is parent's output */
	}

	if (TYPE(receive) == STREAM)
	{
		if (NAME(MODE(receive))[0] != 'r')
			fail("can't receive from an output stream");

		child_o = fileno(FPTR(receive));	/* child's output is parent's input */
	}

	pipe_process(NAME(cmd), &parent_i, &parent_o, child_i, child_o);

	if (TYPE(send) != STREAM)
	{
		char buf[256];

		sprintf(buf, "%s - send", NAME(cmd));
		unify(send, frame, add_stream(intern(buf), intern("w"), fdopen(parent_o, "w")), frame);
	}

	if (TYPE(receive) != STREAM)
	{
		char buf[256];

		sprintf(buf, "%s - receive", NAME(cmd));
		unify(receive, frame, add_stream(intern(buf), intern("r"), fdopen(parent_i, "r")), frame);
	}

	return true;
}

/************************************************************************/
/*		     Check if input stream has incoming data		*/
/************************************************************************/

static bool p_input_ready(term goal, term *frame)
{
	struct stat buf;
	FILE *fptr;

	if (TYPE(goal) == FN && ARITY(goal) == 1)
		fptr = FPTR(check_arg(1, goal, frame, STREAM, IN));
	else
		fptr = input;

	fstat(fileno(fptr), &buf);
	return (buf.st_size != 0);
}


/************************************************************************/
/*			select a stream if it is ready			*/
/************************************************************************/

static bool p_select(term goal, term *frame)
{
	term stream_list = check_arg(1, goal, frame, LIST, IN);
	int interval = IVAL(check_arg(2, goal, frame, INT, IN));
	term ready_stream = check_arg(3, goal, frame, STREAM, OUT);

	fd_set readfds, writefds, exceptfds;
	struct timeval timeout, *tp = NULL;
	term stream_buf[MAX_FDS];
	int i = 0, n = 0;

	if (interval >= 0)
	{
		timeout.tv_sec  =  interval / 1000;
		timeout.tv_usec = (interval % 1000) * 1000;
		tp = &timeout;
	}
	else
		fail("select - bad timeout");

	FD_ZERO(&readfds);
	FD_ZERO(&writefds);
	FD_ZERO(&exceptfds);

	while (TYPE(stream_list) == LIST)
	{
		int fd;

		stream_buf[i] = CAR(stream_list);
		DEREF(stream_buf[i]);

		fd = fileno(FPTR(stream_buf[i]));
		if (fd > n)
			n = fd;

		if (NAME(MODE(stream_buf[i]))[0] == 'r')
			FD_SET(fd, &readfds);

		if (NAME(MODE(stream_buf[i]))[0] == 'w')
			FD_SET(fd, &writefds);

		stream_list = CDR(stream_list);
		DEREF(stream_list);
		i++;
	}

	if (select(n+1, &readfds, &writefds, &exceptfds, tp) == 0)
		return false;

	for (i = 0; i < n; i++)
	{
		int fd = fileno(FPTR(stream_buf[i]));

		if (FD_ISSET(fd, &readfds) ||  FD_ISSET(fd, &writefds))
			return(unify(ready_stream, frame, stream_buf[i], frame));
	}

	fail("something wrong in select - see sys admin");
}


/************************************************************************/
/*		   Dynamically load shared libraries			*/
/************************************************************************/

#ifdef _GNU_SOURCE
#define LIB_SUFFIX "so"
#else
#define LIB_SUFFIX "dylib"
#endif

void load_library(char *lib_name)
{
	typedef void (*init_f)();
	init_f init;
	char lib_file[128];
	
	sprintf(lib_file, "lib%s.%s", lib_name, LIB_SUFFIX);
	void *library = dlopen(lib_file, RTLD_NOW);

	if (! library)
	{
		fprintf(stderr, "Cannot load %s: %s", lib_file, dlerror());
		fail("Cannot load library");
	}

	init = dlsym(library, "init");
	char *result = dlerror();

	if (result)
	{
		fprintf(stderr, "Cannot find init in %s: %s", lib_file, result);
		fail("Cannot initialise library");
	}

	init();
//	fprintf(stderr, "%s library loaded\n", lib_name);
}


static bool p_library(term goal, term *frame)
{
	term lib = check_arg(1, goal, frame, ATOM, IN);
	load_library(NAME(lib));
	return true;
}


/************************************************************************/
/*			    Module Initialisation			*/
/************************************************************************/

void unix_init(void)
{
	defop(700, FX, new_pred(ed, "ed"));

	new_pred(p_getenv,	"getenv");
	new_pred(p_system,	"system");
	new_pred(p_input_ready,	"input_ready");
	new_pred(p_select,	"select");
	new_pred(p_process,	"process");
	new_pred(p_library,	"library");
};
