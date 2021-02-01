/************************************************************************/
/*				Output routines				*/
/************************************************************************/

#include "prolog.h"

#define ADDRESS(x)	((unsigned long) x - (unsigned long) global_start)/sizeof(void *)

extern term *global_start;

void _prin(term x, short p_pred);
static bool portray(term, term *);

static term *frame = NULL;

int display = false;
void (*set_printing)(term);


/************************************************************************/
/*		find out if an atom should be quoted			*/
/************************************************************************/

static bool needs_quotes(char *s)
{
	extern chartype chtype[];
	chartype c;

	if (*s < 'a' || *s > 'z')
		return true;
	while (*++s)
	{
		c = chtype[*s];
		if (c != WORDCH && c != DIGIT)
			return true;
	}
	return false;
}


/************************************************************************/
/*			Print a string					*/
/************************************************************************/

static void prints(char *str)
{
	while (*str) putc(*str++, output);
}


/************************************************************************/
/*	Print a string, displaying non-printing characters		*/
/************************************************************************/

static void sprints(char *str)
{
	char c;

	while ((c = *str++))
		switch (c)
		{
		   case 07:     fprintf(output, "\\b");
				break;
	 	   case '\n':   fprintf(output, "\\n");
				break;
	 	   case '\t':   fprintf(output, "\\t");
				break;
	 	   case '\'':
	 	   case '"':    fprintf(output, "\\%c", c);
				break;
		   default:     if (c < 32)
		 	 	      fprintf(output, "\\%d", c);
	 			else putc(c, output);
				break;
		}
}


/************************************************************************/
/*				Print a list				*/
/************************************************************************/

static void print_list(term l)
{
	term x = l;

	putc('[', output);
	while(TYPE(x) == LIST)
	{
		_prin(CAR(x), 1200);
		x = CDR(x);

		DEREF(x);
		if (TYPE(x) == REF)
		{
			fprintf(output, " | _%ld", ADDRESS(x));
			break;
		}
		if (isvariable(x) && frame == NULL)
		{
			if (PNAME(x))
			{
				fprintf(output, " | %s", NAME(PNAME(x)));
				break;
			}
			else
			{
				fprintf(output, "_%d", OFFSET(x));
				break;
			}
		}
		if (x != _nil)
		{
			if (TYPE(x) != LIST)
			{
				fprintf(output, " | ");
				_prin(x, 250);
				break;
			}
			fprintf(output, ", ");
		}
	}
	putc(']', output);
}


/************************************************************************/
/*		Print a compound term in function notation		*/
/************************************************************************/

static void print_strip(term t)
{
	int i, n = ARITY(t);

	if (portray(t, frame))
		return;

	_prin(ARG(0, t), 1200);
	putc('(', output);
	for (i = 1; i < n; i++)
	{
		_prin(ARG(i, t), 1000);
		putc(',', output);
		putc(' ', output);
	}
	if (n != 0)
		_prin(ARG(i, t), 1000);
	putc(')', output);
}


/************************************************************************/
/*		Print compound term in operator notation		*/
/************************************************************************/

static void print_op(term x, short p_pred)
{
	short left_pred, right_pred;
	int precedence;
	term functor;

	functor = ARG(0, x);
	if (ARITY(x) == 1)
	{
		if (PREFIX(functor))
		{
			precedence = PRE_PREC(functor);
			if (p_pred < precedence)
				putc('(', output);
	    		prints(NAME(functor));
			putc(' ', output);
			_prin(ARG(1, x), precedence);
			if (p_pred < precedence)
				putc(')', output);
			return;
		}
		if (POSTFIX(functor))
		{
			precedence = POST_PREC(functor);
			if (p_pred < precedence)
				putc('(', output);
			_prin(ARG(1, x), precedence);
			putc(' ', output);
	    		prints(NAME(functor));
			if (p_pred < precedence)
				putc(')', output);
			return;
		}
	}
	if (ARITY(x) == 2)
	{
		precedence = IN_PREC(functor) - 1;
		if (INFIX(functor) & NONASS)
		    	left_pred = right_pred = precedence - 1;
		else if (INFIX(functor) & RIGHT)
		{
			right_pred = precedence;
			left_pred = right_pred - 1;
		}
		else
		{
			left_pred = precedence;
			right_pred = left_pred - 1;
		}
		if (p_pred < precedence)
			putc('(', output);
		_prin(ARG(1, x), left_pred);
		putc(' ', output);
		prints(NAME(functor));
		putc(' ', output);
		_prin(ARG(2, x), right_pred);
		if (p_pred < precedence)
			putc(')', output);
		return;
	}
	print_strip(x);
}


/************************************************************************/
/*  Print a clause. This cannot be read back in by the read routines	*/
/************************************************************************/

static void print_clause(term x)
{
	term *old_frame = frame;

// 	frame = NULL;

	if (HEAD(x) != _false)
	{
		_prin(HEAD(x), 1200);
		fputc(' ', output);
	}

	if (GOAL(1, x) != NULL)
	{
		int i = 1;

		fprintf(output, ":- ");
		repeat
		{
			_prin(GOAL(i++, x), 999);
			if (GOAL(i, x) != NULL)
				fputs(", ", output);
			else break;
		}
	}
	fputc('.', output);
	frame = old_frame;
}


/************************************************************************/
/*			Main routine for printing a term		*/
/************************************************************************/

void _prin(term x, short p_pred)
{
	extern int trace_type;
	term t;

#ifdef THINK_C
	if (CheckForInterrupt())
		fail("interrupted");
#endif
	if (x == NULL)
	{
		fputs("___", output);
		return;
	}
	DEREF(x);

	if (FLAGS(x) & MARK)
	{
		fputs("...", output);
		return;
	}
	FLAGS(x) |= MARK;		/* mark the node */

	switch (TYPE(x))
	{
	   case ATOM:
	   		if (display && x != _nil && needs_quotes(NAME(x)))
			{
				putc('"', output);
				sprints(NAME(x));
				putc('"', output);
			}
			else fprintf(output, "%s", NAME(x));
			break;
	   case REF:
			fprintf(output, "_R%ld", ADDRESS(x));
	   		break;
	   case ANON:
			putc('_', output);
	   		break;
	   case FREE:
			if (trace_type == 'E')
				_prin(frame[OFFSET(x)], p_pred);
			else
				fprintf(output, "%s", NAME(PNAME(x)));
			break;
	   case BOUND:
			if (frame != NULL && trace_type != 'C' && trace_type != 'F')
				_prin(frame[OFFSET(x)], p_pred);
	   		else if (PNAME(x) != NULL)
				fprintf(output, "%s", NAME(PNAME(x)));
			else
				fprintf(output, "_B%d", OFFSET(x));
			break;
	   case INT:
			fprintf(output, "%ld", IVAL(x));
			break;
	   case REAL:
	   		fprintf(output, "%g", RVAL(x));
			break;
	   case LIST:
	   		print_list(x);
			break;
	   case FN:
	   		t = ARG(0, x);
			DEREF(t);
			if (t == _lbrace)
			{
				putc('{', output);
				_prin(ARG(1, x), 1200);
				putc('}', output);
			}
			else if (IS_OP(t))
				print_op(x, p_pred);
			else
				print_strip(x);
			break;
	   case CLAUSE:
	   		print_clause(x);
			break;
	   case PRED:
	   case FPRED:
			fprintf(output, "|| Predefined predicate %s ||", NAME(ID(x)));
			break;
	   case SUBR:
	   case FSUBR:
			fprintf(output, "|| Predefined function %s ||", NAME(ID(x)));
			break;
	   case STREAM:
			fprintf(output, "|| Stream %s ||", NAME(FILE_NAME(x)));
			break;
	   case AVAIL:
			fprintf(output, "|| AVAIL (%d) ||", SIZE(x));
			break;
	   case SET:	if (set_printing == NULL)
	   			fprintf(output, "|| SET (%d) ||", SET_SIZE(x));
	   		else
	   			(*set_printing)(x);
			break;
	   case CHUNK:	PRINT_CHUNK(x);
			break;
	   default:
	   		fprintf(output, "|| %d ||", TYPE(x));
	}
	FLAGS(x) &= ~MARK;		/* unmark the node */
}


/************************************************************************/
/*		Print term using variable's print name			*/
/************************************************************************/

void prin(term x)
{
	frame = NULL;
	_prin(x, 1200);
}


void print(term x)
{
	prin(x);
	putc('\n', output);
	fflush(output);
}


/************************************************************************/
/*			Print term using variable's value		*/
/************************************************************************/

void rprin(term x, term *f)
{
	frame = f;
	_prin(x, 1200);
}


void rprint(term x, term *f)
{
	frame = f;
	_prin(x, 1200);
	putc('\n', output);
	fflush(output);
}


/************************************************************************/
/*			Prolog hooks to print routines			*/
/************************************************************************/

static bool p_write(term goal, term *frame)
{
	check_arity(goal, 1);

// 	display = true;
	rprin(ARG(1, goal), frame);
	return true;
}

static bool write_term(term goal, term *frame)
{
	term old_output = current_output;

	if (TYPE(goal) == FN && ARITY(goal) == 2)
	{
		current_output = check_arg(1, goal, frame, STREAM, IN);
		output = FPTR(current_output);
		display = true;
		rprin(ARG(2, goal), frame);
	}
	else
	{
		display = true;
		rprin(ARG(1, goal), frame);
	}

	current_output = old_output;
	output = FPTR(current_output);

	return true;
}


static bool p_nl(term goal, term *frame)
{
	FILE *fptr = output;

	if (TYPE(goal) == FN && ARITY(goal) == 1)
		fptr = FPTR(check_arg(1, goal, frame, STREAM, IN));

	fputc('\n', fptr);
	return true;
}


static bool p_tab(term goal, term *frame)
{
	term x = check_arg(1, goal, frame, INT, IN);
	int i = IVAL(x);

	if (i < 0)
		fail("Argument to tab is a negative integer");

	while (i--)
		fputc(' ',  output);
	return true;
}


static bool p_putc(term goal, term *frame)
{
	term x;

	if (ARITY(goal) == 2)
	{
		term old_output = current_output;

		x = check_arg(2, goal, frame, ATOM, IN);
		current_output = check_arg(1, goal, frame, STREAM, IN);
		output = FPTR(current_output);

		fputc(NAME(x)[0], output);

		current_output = old_output;
		output = FPTR(current_output);
	}
	else
	{
		x = check_arg(1, goal, frame, ATOM, IN);
		fputc(NAME(x)[0], output);
	}

	return true ;
}


bool p_prin(term goal, term *frame)
{
	int i, n = ARITY(goal);

	display = false;
	for (i = 1; i <= n; i++)
		rprin(ARG(i, goal), frame);
	return true ;
}


bool p_print(term goal, term *frame)
{
	p_prin(goal, frame);
	putc('\n', output);
	return true ;
}


/************************************************************************/
/*		Print each clause in a clause list			*/
/************************************************************************/

void list_proc(term p)
{
	term clist;
	int i;

	if (p == NULL)
		return;

	frame = NULL;
	display = true;

	if (TYPE(p) != CLAUSE)
	{
		_prin(p, 1200);
		return;
	}

	putc('\n', output);
	for (clist = p; clist != NULL && TYPE(clist) == CLAUSE; clist = NEXT(clist))
	{
		if (HEAD(clist) != _false)
		{
			_prin(HEAD(clist), 1200);
		}

		if (GOAL(1, clist) != NULL)
		{
			if (GOAL(2, clist))
				fprintf(output, " :-\n\t");
			else fprintf(output, " :- ");

			for (i = 1; GOAL(i + 1, clist) != NULL; i++)
			{
				_prin(GOAL(i, clist), 999);
				fprintf(output, ",\n\t");
			}
			_prin(GOAL(i, clist), 999);
		}
		fprintf(output, ".\n");
	}
}


/************************************************************************/
/*		Pretty print clauses attached to an atom		*/
/************************************************************************/

static bool pp(term goal, term *frame)
{
	term a = check_arg(1, goal, frame, ATOM, IN);
	term q = PROC(a);

	if (q != NULL && TYPE(q) == CLAUSE)
		list_proc(q);
	return true ;
}


/************************************************************************/
/*  Look through hash table for user defined predicates and print them	*/
/*  Uses forall_atoms to scan through hastable.			*/
/************************************************************************/

static void listing_helper(term p)
{
	term q = PROC(p);

	if (q != NULL && TYPE(q) == CLAUSE)
		list_proc(q);
}

bool listing(void)
{
	forall_atoms(listing_helper);
	return true ;
}


/************************************************************************/
/*		Pretty print clauses attached to an atom		*/
/************************************************************************/

static bool p_print_clause(term goal, term *frame)
{
	term x = check_arg(1, goal, frame, CLAUSE, IN);

	list_proc(x);
	return true;
}


/************************************************************************/
/*			Hooks for "portray"				*/
/************************************************************************/

static term temp;

static bool portray(term goal, term *frame)
{
	static term q[2] = {NULL, NULL};
	term a;

	if (TYPE(goal) != FN)
		fail("Can only portray compound terms");

	a = ARG(0, goal);
	DEREF(a);

	if (TYPE(a) == REF)
		return false;
	if (TYPE(a) != ATOM)
		fail("Can't portray this");
	if (PORTRAY(a) == NULL)
		return false;

	ARG(0, temp) = PORTRAY(a);
	ARG(1, temp) = goal;
	q[0] = temp;

	return cond(q, frame);
}

static bool p_portray(term goal, term *frame)
{
	term a = check_arg(1, goal, frame, ATOM, IN);
	term proc = check_arg(2, goal, frame, ATOM, IN);

	PORTRAY(a) = proc;
	return true;
}

/************************************************************************/
/*			Module initialisation				*/
/************************************************************************/

void out_init(void)
{
	set_printing = NULL;

	temp = new_h_fn(1);

	new_pred(p_write, "write");
	new_pred(write_term, "write_term");
	new_pred(p_nl, "nl");
	new_pred(p_tab, "tab");
	new_pred(p_putc, "putc");
	new_pred(p_prin, "prin");
	new_pred(p_print, "print");
	defop(700, FX, new_fpred(pp, "pp"));
	new_pred(listing, "listing");
	new_pred(p_print_clause, "print_clause");
	new_pred(p_portray, "portray");
}
