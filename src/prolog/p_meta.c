#include <setjmp.h>
#include "prolog.h"

static void succeed(term *result, term varlist, term *frame)
{
	*result = _true;
}

/************************************************************************/
/*			Collect results in a bag			*/
/************************************************************************/

static void collect(term *result, term vars, term *frame)
{
	extern term varlist;

 	varlist = _nil;
 	nconc(result, hcons(make(vars, frame), _nil));
}

/************************************************************************/
/*			Collect results in a set			*/
/************************************************************************/

static void collect_set(term *result, term vars, term *frame)
{
	extern term varlist;

	varlist = _nil;

	while (*result != _nil)
	{
		term x = CAR(*result);
		int comp = term_compare(vars, frame, x, NULL);
/*
		prin(vars);
		fprintf(output, " <==> ");
		prin(x);
		fprintf(output, " :: %d\n", comp);
		fflush(output);
*/		
		switch (comp)
		{
			case 0: /* terms are equal */
				return;
			case -1: /* new term comes before head of list */
				*result = hcons(make(vars, frame), *result);
				return;
			case 1:
				result = &(CDR(*result));
				break;
			default:
				fail("Internal error on comparison");
		}
	}

	*result = hcons(make(vars, frame), _nil);
}


/************************************************************************/
/*				Find all solutions			*/
/************************************************************************/

static bool findall(term goal, term *frame)
{
	int rval;
	term fn, tmp, q[2] = {NULL, NULL};

	check_arity(goal, 3);
	fn = copy(ARG(1, goal), frame);
	*q = copy(ARG(2, goal), frame);
	DEREF(*q);
//	tmp = call_prove(q, local, fn, -1, collect, true);
//	rval = unify(ARG(3, goal), frame, tmp, local);
	tmp = call_prove(q, frame, fn, -1, collect, true);
	rval = unify(ARG(3, goal), frame, tmp, frame);
	free_term(tmp);
	return rval;
}


term all(term goal, term *frame)
{
	term fn, tmp, rval, q[2] = {NULL, NULL};

	check_arity(goal, 2);
	fn = copy(ARG(1, goal), frame);
	*q = eval(ARG(2, goal), frame);
//	DEREF(*q);

//	tmp = call_prove(q, local, fn, -1, collect, true);
//	rval = copy(tmp, local);
	tmp = call_prove(q, frame, fn, -1, collect, true);
	rval = copy(tmp, frame);
	free_term(tmp);
	return rval;
}

static bool setof(term goal, term *frame)
{
	int rval;
	term fn, tmp, q[2] = {NULL, NULL};

	check_arity(goal, 3);
	fn = copy(ARG(1, goal), frame);
	*q = copy(ARG(2, goal), frame);
	DEREF(*q);
//	tmp = call_prove(q, local, fn, -1, collect_set, true);
//	rval = unify(ARG(3, goal), frame, tmp, local);
	tmp = call_prove(q, frame, fn, -1, collect_set, true);
	rval = unify(ARG(3, goal), frame, tmp, frame);
	free_term(tmp);
	return rval;
}


/************************************************************************/
/*			Apply a given clause to a term			*/
/************************************************************************/

static bool apply_clause(term goal, term *frame)
{
	term t = check_arg(1, goal, frame, FN, IN);
	term cl = check_arg(2, goal, frame, CLAUSE, IN);
	term current_frame[NVARS(cl)];

	if (! unify(t, frame, HEAD(cl), current_frame))
	{
		_untrail();
		return false;
	}
	return (call_prove(BODY(cl), current_frame, _nil, 1, succeed, false) != _nil);
}


/************************************************************************/
/*			User callable meta predicates			*/
/************************************************************************/

static bool p_cut(term goal, term *frame)
{
	cut(top_of_stack);
	return true;
}


static bool p_true(term t, term *frame)
{
	return true;
}


static bool _fail(term t, term *frame)
{
	return false;
}


static bool l_brace(term goal, term *frame)
{
	term q[2];

	q[0] = check_arg(1, goal, frame, ANY, IN);
	q[1] = NULL;

	prove(q, top_of_stack);
	if (top_of_stack -> cut)
		cut(top_of_stack);
	return false;
}


static bool not(term goal, term *frame)
{
	term q[2] = {NULL, NULL};

	q[0] = ARG(1, goal);
//	q[0] = check_arg(1, goal, frame, ANY, IN);
	make_ref(q[0], frame);

	return call_prove(q, frame, _nil, 1, succeed, true) == _nil;
}


static bool and(term goal, term *frame)
{
	term q[3];
	
	q[0] = ARG(1, goal);
	q[1] = ARG(2, goal);
	q[2] = NULL;

	prove(q, top_of_stack);
	return false;
}


static bool arrow(term goal, term *frame)
{
	env current_env = top_of_stack;
	term q[2] = {NULL, NULL};

	*q = check_arg(1, goal, frame, ANY, IN);
	if (cond(q, frame))
	{
		cut(current_env);
		*q = check_arg(2, goal, frame, ANY, IN);
		prove(q, current_env);
	}
	return false;
}


static bool or(term goal, term *frame)
{
	term q[2] = {NULL, NULL};
	env current_env = top_of_stack;

	make_ref(goal, frame);
	*q = ARG(1, goal);
	prove(q, current_env);
	if (current_env -> cut)
		return false;
	untrail(current_env -> trail);

	*q = ARG(2, goal);
	prove(q, current_env);
	return false;
}


static bool unless(term goal, term *frame)
{
	term x = ARG(1, goal);
	term y = ARG(2, goal);
	term q[2] = {NULL, NULL};

	if (TYPE(x) == FN && ARITY(x) == 2 && ARG(0, x) == _arrow)
	{
		*q = ARG(1, x);
//		make_ref(*q, frame);
		if (! cond(q, frame))
			return false;
	
		*q = y;
//		make_ref(*q, frame);
		if (cond(q, frame))
			return true;
	
		*q = ARG(2, x);
//		make_ref(*q, frame);
		return cond(q, frame);
	}
	else
	{
		*q = y;
//		make_ref(*q, frame);
		if (cond(q, frame))
			return true;
	
		*q = x;
//		make_ref(*q, frame);
		return cond(q, frame);
	}
}


static bool _repeat(term goal, term *frame)
{
	term *old_global = global;
	while (! rest_of_clause())
	{
		_untrail();
		global = old_global;
	}
	return false;
}


/************************************************************************/
/*				init					*/
/************************************************************************/

term _unless;

void meta_init()
{
	new_pred(findall, "findall");
	new_pred(setof, "setof");
	new_fsubr(all, "all");
	defop(800, XFX, new_pred(apply_clause, "wrt"));

	new_pred(p_cut, "!");
	new_pred(p_true, "true");
	new_pred(_fail, "fail");
  	new_pred(not, "not");
	defop(900, FY, new_pred(not, "\\+"));
	new_pred(and, ",");
//	new_pred(l_brace, "{");
	defop(950, XFX, new_pred(l_brace, "\\"));
	new_pred(arrow, "->");
	new_pred(or, "|");
	new_pred(or, ";");
	defop(1075, XFY, _unless = new_pred(unless, "unless"));
	new_pred(_repeat, "repeat");
	defop(1140, XFX, new_pred(and, "checking"));
}
