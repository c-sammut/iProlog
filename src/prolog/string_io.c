/************************************************************************/
/* Redirect input and output to strings rather than files		*/
/* There are some differences in system libraries between BSD and LUNUX	*/
/************************************************************************/

#include <string.h>
#include "prolog.h"

typedef struct
{
	char *str;
	size_t pos;
	size_t size;
} string_buffer;



/************************************************************************/
/*		Primitive read operation from a string			*/
/************************************************************************/

#ifdef _GNU_SOURCE
static ssize_t string_read(void *cookie, char *buf, size_t size)
#else
static int string_read(void *cookie, char *buf, int size)
#endif
{
	string_buffer *in_buf = (string_buffer *) cookie;
	int buf_size = in_buf -> size;

	if (in_buf -> pos >= buf_size)
		return EOF;
	if (in_buf -> pos + size >= buf_size)
		size = buf_size - in_buf -> pos;

	strncpy(buf, &((in_buf -> str)[in_buf -> pos]), size);
	in_buf -> pos += size;

	return size;
}


/************************************************************************/
/*		Primitive write operation to a string			*/
/************************************************************************/

#ifdef _GNU_SOURCE
static ssize_t string_write(void *cookie, const char *buf, size_t size)
#else
static int string_write(void *cookie, const char *buf, int size)
#endif
{
	string_buffer *out_buf = (string_buffer *) cookie;
	int buf_size = out_buf -> size;

	if (out_buf -> pos + size >= buf_size)
	{
		out_buf -> str = realloc(out_buf -> str, buf_size + 2 * strlen(buf));
		out_buf -> size += 2 * strlen(buf);
	}

	strncpy(&((out_buf -> str)[out_buf -> pos]), buf, size);
	out_buf -> pos += size;
	(out_buf -> str)[out_buf -> pos] = '\0';

	return strlen(buf);
}


/************************************************************************/
/*		Primitive close operation for a string			*/
/************************************************************************/

static int string_close(void *cookie)
{
	free(cookie);
	return 0;
}

#ifdef _GNU_SOURCE
static cookie_io_functions_t str_fns = {string_read, string_write, NULL, string_close};
#endif


/************************************************************************/
/*	Public function for opening a string as an input stream		*/
/************************************************************************/

FILE *str_ropen(void *buf)
{
	FILE *rval;
	string_buffer *cookie = malloc(sizeof (string_buffer));

	cookie -> str = (char *) buf;
	cookie -> pos = 0;
	cookie -> size = strlen(buf);
	
#ifdef _GNU_SOURCE
	rval = fopencookie(cookie, "r", str_fns);
#else
	rval = funopen(cookie, string_read, string_write, NULL, string_close);
#endif
	setlinebuf(rval);
	clear_input();

	return rval;
}


/************************************************************************/
/*	Public function for opening a string as an output stream	*/
/************************************************************************/

FILE *str_wopen(char **buf)
{
	FILE *rval;
	string_buffer *cookie = malloc(sizeof (string_buffer));

	cookie -> str = malloc(BUFSIZ);
	cookie -> pos = 0;
	cookie -> size = BUFSIZ;

#ifdef _GNU_SOURCE
	rval = fopencookie(cookie, "w", str_fns);
#else
	rval = funopen(cookie, string_read, string_write, NULL, string_close);
#endif
	setlinebuf(rval);

	*buf = cookie -> str;
	return rval;
}


/************************************************************************/
/*			Read atoms and terms from a string		*/
/************************************************************************/

term read_atom_from_string(char *str)
{
	term rval;
	FILE *old_input = input;

	input = str_ropen(str);
	rval = read_atom();
	fclose(input);
	input = old_input;

	return rval;
}


term read_term_from_string(char *str)
{
	term rval;
	FILE *old_input = input;
	
	input = str_ropen(str);
	rval = read_term();
	fclose(input);
	input = old_input;
	
	return rval;
}


term read_expr_from_string(char *str)
{
	term rval;
	FILE *old_input = input;
	
	input = str_ropen(str);
	rval = read_expr(999);
	fclose(input);
	input = old_input;
	
	return rval;
}


/************************************************************************/
/*			 Print terms to a string			*/
/************************************************************************/

char *prin_to_string(term t)
{
	FILE *old_output = output;
	char *buf;

	output = str_wopen(&buf);
	prin(t);
	fclose(output);
	output = old_output;

	return buf;
}


char *print_to_string(term t)
{
	FILE *old_output = output;
	char *buf;

	output = str_wopen(&buf);
	print(t);
	fclose(output);
	output = old_output;

	return buf;
}


/************************************************************************/
/*		Write a string term to a string output stream		*/
/************************************************************************/

char *message_to_string(term goal, term *frame)
{
	extern int display;
	int i;
	FILE *old_output = output;
	char *buf;

	output = str_wopen(&buf);
	
	display = false;
	if (ARITY(goal) > 0)
		for (i = 1; i <= ARITY(goal); i++)
			rprin(ARG(i, goal), frame);
	else
		rprin(goal, frame);
	fclose(output);
	output = old_output;

	return buf;
}
