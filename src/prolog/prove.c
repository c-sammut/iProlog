/************************************************************************/
/*		A small copying interpreter for Prolog			*/
/************************************************************************/


#include <unistd.h>
#include "prolog.h"

term trail = NULL;

env top_of_stack = NULL;

int trace_on = false;

query current_query = NULL;

term _list_proc, _demo;

static term _trace, _notrace, _eval_print;


/************************************************************************/
/*		Output routine for error backtrace			*/
/************************************************************************/

void backtrace(void)
{
	env p;
	char *msg = "In:      ";
	FILE *tmp = output;

	output = stderr;
	for (p = top_of_stack; p != NULL; p = p -> parent)
	{
		if (p -> goals == NULL)
			continue;
		fputs(msg, output);
		msg = "caller:  ";
		rprint(*(p -> goals), p -> parent -> frame);
	}
	putc('\n', output);
	output =  tmp;
}


/************************************************************************/
/*			Output routine for tracing calls		*/
/************************************************************************/

int trace_type = 0;

static void trace_help()
{
	fprintf(stderr, "\n");
	fprintf(stderr, "<cr>	next step\n");
	fprintf(stderr, "s	skip tracing this predicate\n");
	fprintf(stderr, "l	leap to end of execution (turn off tracing)\n");
	fprintf(stderr, "c	start full tracing\n");
	fprintf(stderr, "b	print the contents of the control stack\n");
	fprintf(stderr, "\n");
}


void trace_print(char *msg, env e, term rval)
{
	static int skip_to_depth = 1000;
	env bottom = current_query -> query_env;
	FILE *tmp = output;
	term goal;

//	if (e == NULL || e == bottom || ! isatty(fileno(input))) return;
	if (e == NULL || e == bottom) return;
	goal = *(e -> goals);

	if (trace_on || SPIED(TYPE(goal) == FN ? ARG(0, goal) : goal))
	{
		int depth = 0;
		query q;
		env p, e1 = e;

		if (goal == _trace || goal == _notrace)
			return;
		if (TYPE(goal) == FN && ARG(0, goal) == _eval_print)
			return;

		for (q = current_query; q != NULL && e1 != NULL; q = q -> previous_query)
		{
			for (p = e1; p != bottom && p != NULL; p = p -> parent)
				depth++;
			e1 = current_query -> old_top_of_stack;
		}

		if (depth > skip_to_depth)
			return;
		else
			skip_to_depth = 1000;

		repeat
		{
			output = stderr;
			fprintf(stderr, "(%d) %s: ", depth, msg);
			trace_type = (int)(*msg);
			rprin(goal, e -> parent -> frame);
			trace_type = 0;
			if (rval != NULL)
			{
				fputs(" = ", stderr);
				rprin(rval, e -> parent -> frame);
			}
#ifdef INTERACTIVE
			fputs(" ? ", stderr);
			output = tmp;

			getchar();			/* clear the last nl */
	
			switch (getchar())
			{
			case 's':	skip_to_depth = depth;
					return;
			case 'c':	trace_on = true;
					return;
			case 'l':	trace_on = false;
					return;
			case 'b':	backtrace();
					break;
			case '\n':	ungetc('\n', stdin);
					return;
			default:	trace_help();
					break;
			}
#else
			fputc('\n', output);
			return;
#endif
		}
	}
}


/************************************************************************/
/*  Untrailing requires that the bindings in each environment are reset	*/
/*  to the bindings prior to the last choice point.			*/
/************************************************************************/

void untrail(term old_trail)
{
	while (trail != NULL && trail != old_trail)
	{
		POINTER(trail) = NULL;
		trail = TRAIL(trail);
	}
}


/* External version for built-ins that have to backtrack */

void _untrail(void)
{
	untrail(top_of_stack -> trail);
}


/************************************************************************/
/*  Eliminate all backtrack points between environment and its parent	*/
/************************************************************************/

void cut(env p)
{
	env parent = p -> parent;
	int i = 0;

	while (p)
	{
		p -> cut = true;
		if (p == parent)
			return;
		p = p -> prev;
	}
}


/************************************************************************/
/*  Prove a tuple of goals stored in the calling environment.		*/
/*  This interpreter uses the continuation method of controlling the	*/
/*  proof, i.e. C's stack handles backtracking with the help of the	*/
/*  environment record stored in each call to prove.			*/
/************************************************************************/

bool prove(term *goals, env parent)
{
	env_struct current_env;
	term first_goal, first_clause;
	char *trace_msg = "CALL";

#ifdef THINK_C
	if (CheckForInterrupt())
		fail("interrupted");
#endif
	current_env.prev = parent;

	/****************************************************************/
	/* Unwind the stack looking for a clause that has goals		*/
	/* remaining to be satisfied					*/
	/****************************************************************/

L:	while (*goals == NULL)
	{
		if (parent == current_query -> query_env)
		{
			(* (current_query -> new_result))(
				&(current_query -> result),
				current_query -> query_vars,
				current_query -> query_env -> frame);
			if (current_query -> how_many > 0)
				--(current_query -> how_many);
			return true;
		}
		trace_print("EXIT", parent, NULL);
		goals = parent -> goals + 1;
		parent = parent -> parent;
	}

	/****************************************************************/
	/* Create a stack record to contain variable binding and	*/
	/* backtracking information					*/
	/****************************************************************/

	current_env.cut		= false;
//	current_env.frame	= local;
	current_env.frame	= NULL;
	current_env.global	= global;
	current_env.goals	= goals;
	current_env.trail	= trail;
	current_env.db		= parent -> db;
	current_env.parent	= parent;

	top_of_stack = &current_env;

	first_goal = unbind(*goals, parent -> frame);

	/****************************************************************/
	/* Find predicate symbol. Make "fn" local so that it doesn't	*/
	/* take up stack space on the recursive call to prove below	*/
	/****************************************************************/

TOP:	{
		term fn = first_goal;

		switch (TYPE(fn))
		{
		   case LIST:
				first_clause = PROC(_list_proc);
				break;
		   case FN:
				fn = unbind(ARG(0, fn), parent -> frame);
				if (fn == _demo)
				{
					fn = unbind(ARG(1, first_goal), parent -> frame);
					first_goal = unbind(ARG(2, first_goal), parent -> frame);
					current_env.db = fn;
				}
		   case ATOM:
				if (current_env.db != NULL) first_clause = current_env.db;
				if ((first_clause = PROC(fn)) != NULL) break;
				if (FLAGS(fn) & DYNAMIC) return false;
		   default:
				fprintf(stderr, "Undefined predicate, type %d\n", TYPE(fn));
				fail("Undefined predicate");
		}
	}

	/****************************************************************/
	/* Try to satisfy the goal by looping thrugh all clauses for	*/
	/* the predicate symbol						*/
	/****************************************************************/

UP1:	while (first_clause != NULL && ! current_env.cut)
	{
		/********************************************************/
		/* If it's a built-in predicate handle it seperately.	*/
		/* Since they don't backtrack in the normal way, jump	*/
		/* back to the top to get the next goal.		*/
		/********************************************************/

		switch (TYPE(first_clause))
		{
		case CLAUSE:
				if (ENABLED(first_clause))
				{
					term frame[NVARS(first_clause)];
					current_env.frame = frame;
					
					if (unify(first_goal, parent -> frame, HEAD(first_clause), current_env.frame))
					{
						trace_print(trace_msg, &current_env, NULL);
						trace_msg = "REDO";
						
						if (prove(BODY(first_clause), &current_env))
							if (current_query -> how_many == 0)
								return true;
					}
					untrail(current_env.trail);
					top_of_stack = &current_env;
					global = current_env.global;
				}
				first_clause = NEXT(first_clause);
				break;
		case PRED:
		case FPRED:
			{
				int rval;

				current_env.frame = parent -> frame;
				trace_print("CALL", &current_env, NULL);

				rval = (* C_CODE(first_clause))(first_goal, parent -> frame);

				if (current_env.cut)
					cut(&current_env);

				if (! rval)
				{
					trace_print("FAIL", &current_env, NULL);
					return false;
				}
				trace_print("EXIT", &current_env, NULL);
				goals++;
				goto L;
			}
		default:
				fail("Goal must be a call to a predicate");
		}
	}

	if (current_env.db != NULL)
	{
		current_env.db = INHERITS(current_env.db);
		if (current_env.db != NULL)
		{
			first_clause = PROC(current_env.db);
			goto UP1;
		}
		goto TOP;
	}

	trace_print("FAIL", &current_env, NULL);
	return false;
}


/************************************************************************/
/*	Utility to allow built-in predicates to backtrack		*/
/************************************************************************/

bool rest_of_clause(void)
{
	term q[1] = {NULL};
	env current_env = top_of_stack;

	prove(q, current_env);

	top_of_stack = current_env;
	return current_env -> cut;
}

/*
term *
new_local_frame(int n)
{
	term *rval = local;

	if ((local += n) >= local_end)
		fail("Out of memory. Too many procedures called.");

	return rval;
}
*/

/************************************************************************/
/*	This is the hook into the Prolog interpreter.			*/
/*	Lot's of things are saved to so that prove can be re-entrant.	*/
/************************************************************************/

term call_prove(term *q, term *frame, term vars, int how_many, void (*new_result)(), int cleanup)
{
	env_struct start_env;
	query_struct this_query;

	start_env.prev = NULL;
	start_env.parent = NULL;	/* start_env is a place holder for the	*/
	start_env.goals = NULL;		/* call to prove. It's only use is to	*/
	start_env.frame = frame;	/* to store the call frame.		*/
	start_env.global = global;
	start_env.trail = trail;
	start_env.db = top_of_stack == NULL ? NULL : top_of_stack -> db;
	start_env.cut = false;

	this_query.previous_query = current_query;
	this_query.old_top_of_stack = top_of_stack;
	this_query.query_env = &start_env;
	this_query.query_vars = vars;
	this_query.result = _nil;
	this_query.how_many = how_many;
	this_query.new_result = new_result;

	current_query = &this_query;
	top_of_stack = &start_env;

	prove(q, &start_env);

	if (cleanup)
	{
		untrail(start_env.trail);
		global = start_env.global;
	}
	top_of_stack = this_query.old_top_of_stack;
	current_query = this_query.previous_query;
	return this_query.result;
}

/************************************************************************/
/*		Use Prolog to check the conditions in a function	*/
/************************************************************************/

static void succeed(term *result, term varlist, term *frame)
{
	*result = _true;
}


bool cond(term *q, term *frame)
{
	if (q == NULL || *q == NULL)
		return true;

	return call_prove(q, frame, _nil, 1, succeed, false) != _nil;
}


/************************************************************************/
/*		Invoke the prolog interpreter from a command line	*/
/************************************************************************/

static void print_bindings(term *result, term varlist, term *frame)
{
	if (varlist != _nil)
	{
		int i;
		FILE *tmp = output;

		if (! isatty(fileno(output)))
			output = stderr;
		fputc('\n', output);
		for (i = 0; varlist != _nil; i++, varlist = CDR(varlist))
		{
			fprintf(output, "%s = ", NAME(CAR(CAR(varlist))));
			rprint(CDR(CAR(varlist)), frame);
		}
		output = tmp;
	}
	*result = _true;
}


void lush(term question, term vars, int how_many)
{
	term q[2] = {NULL, NULL};
	term frame[count_vars(vars)];

	*q = question;

	if (call_prove(q, frame, vars, how_many, print_bindings, true) == _nil)
		fprintf(stderr, "** no\n");
	else if (vars == _nil && how_many == -1 && isatty(fileno(input)))
		fprintf(isatty(fileno(output)) ? output : stderr, "** yes\n");
}


/************************************************************************/
/*	Decide whether to prove or evaluate from command line		*/
/************************************************************************/

static bool top_level(term goal, term *frame)
{
	extern term varlist, _is;
	term x = check_arg(1, goal, frame, ANY, IN);
	term defn, fn = x;

	switch (TYPE(fn))
	{
	  case FN:	fn = ARG(0, fn);
	  case ATOM:	if ((defn = PROC(fn)) == NULL)
			{
				if (FLAGS(fn) & DYNAMIC)
					return false;
				else
					fail("Undefined predicate");
			}
			break;
	  default:	defn = x;
	}

	switch (TYPE(defn))
	{
	  case PRED:
	  case FPRED:
			lush(x, varlist, -1);
			break;
	  case CLAUSE:
			if (TYPE(HEAD(defn)) != FN || ARG(0, HEAD(defn)) != _is)
			{
				lush(x, varlist, -1);
				break;
			}
	  default:
			if ((x = eval(x, frame)) == NULL)
				return false;
			if (! isatty(fileno(input)))
				return true;
			list_proc(x);
			fputc('\n', output);
	}
	return true;
}


/************************************************************************/
/*	Execute a directive - don't print variables and cut at end	*/
/************************************************************************/

void directive(term question, term vars)
{
	term q[2] = {NULL, NULL};
	term frame[count_vars(vars)];

	*q = question;

	if (call_prove(q, frame, vars, 1, succeed, true) == _nil)
		fprintf(stderr, "** no\n");
}


/************************************************************************/
/*			"Once" built-in predicate			*/
/************************************************************************/

static bool p_once(term goal, term *frame)
{
	term q[2] = {NULL, NULL};

	*q = check_arg(1, goal, frame, ANY, IN);

	return call_prove(q, frame, _nil, 1, succeed, true) != _nil;
}


/************************************************************************/
/*	"demo" built-in predicate, allows multiple world proofs		*/
/************************************************************************/

static bool demo(term goal, term *frame)
{
	term q[2];
	
	q[0] = goal;
	q[2] = NULL;
	
	prove(q, top_of_stack);
	return false;
}


static bool p_extends(term goal, term *frame)
{
	term theory = check_arg(1, goal, frame, ATOM, IN);
	term parent = check_arg(2, goal, frame, ATOM, IN);
	
	INHERITS(theory) = parent;
	
	return true;
}


/************************************************************************/
/*				init					*/
/************************************************************************/

void prove_init()
{
	_trace = intern("trace");
	_notrace = intern("notrace");
	_eval_print = intern("*eval*");

	new_pred(top_level, "?");
	new_pred(p_once, "once");
	
//	_demo = new_pred(demo, "demo");
//	new_pred(p_inherits, "inherits");
	
	defop(800, XFX, _demo = new_pred(demo, "::"));
	defop(300, XFX, new_pred(p_extends, "extends"));
}
