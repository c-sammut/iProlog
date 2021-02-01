/************************************************************************/
/*			Adds if-then-else macro to Prolog		*/
/************************************************************************/

#include "prolog.h"

#define MAX_COND 20

#define	COND(x)		ARG(1, x)
#define CONCL(x)	ARG(2, x)
#define ALT(x)		ARG(5, x)

#define NONVAR(x) (x != _anon && TYPE(x) != REF && TYPE(x) != ANON)

static term _if, _then, _else, _and, _or;
static term anon_struct;


/************************************************************************/
/*			Make a new if-statement				*/
/************************************************************************/

static term new_rule(term cond, term concl, term alt)
{
	term rval = new_h_fn(5);
	
	ARG(0, rval) = _if;
	COND(rval) = cond;
	CONCL(rval) = concl;
	ALT(rval) = alt;
	
	return rval;
}


/************************************************************************/
/*		Evaluate a conjunction of expressions			*/
/************************************************************************/

static term and(term expr, term *frame)
{
	term orig = expr;
	
	while (TYPE(expr) == FN && ARG(0, expr) == _and)
	{
		if (eval(ARG(1, expr), frame) != _true)
			return _false;
		expr = ARG(2, expr);
	}
	return (orig == expr ? orig : eval(expr, frame));
}


/************************************************************************/
/*		Evaluate a disjunction of expressions			*/
/************************************************************************/

static term or(term expr, term *frame)
{
	term orig = expr;
	
	while (TYPE(expr) == FN && ARG(0, expr) == _or)
	{
		if (eval(ARG(1, expr), frame) == _true)
			return _true;
		expr = ARG(2, expr);
	}
	return (orig == expr ? orig : eval(expr, frame));
}


/************************************************************************/
/*			Evaluate an RDR expression			*/
/************************************************************************/

static term if_expr(term expr, term *frame)
{
	if (eval(COND(expr), frame) == _true)
		return progn(CONCL(expr), frame);
	
	if (NONVAR(ALT(expr)))
		return progn(ALT(expr), frame);
	
	return NULL;
}


/************************************************************************/
/*				Read RDR				*/
/************************************************************************/

static term if_macro(term x)
{
	term a, cond, concl;
	term alt = anon_struct;
	
	ungetatom(a = get_atom());	// a could be a variable
	if (isatom(a) && INFIX(a))	// so check first
		return x;
	
	cond = read_expr(999);

	if ((a = get_atom()) != _then)
		syn_err("missing \"then\" in if statement");

	concl = read_expr(999);

	if ((a = get_atom()) == _else)
		alt = read_expr(999);
	else
		ungetatom(a);
	
	return new_rule(cond, concl, alt);
}


/************************************************************************/
/*				Print rule				*/
/************************************************************************/

static int tabs = 1;

static void tab(int n)
{
	while (n--)
		fputc('\t', output);
}

static bool print_rule(term goal, term *frame)
{
	term rdr = check_arg(1, goal, frame, FN, IN);
	term x;

	fprintf(output, "if ");
	rprin(COND(rdr), frame);

	x = CONCL(rdr);
	DEREF(x);
	if (NONVAR(x))
	{
		fprintf(output, " then ");
		rprin(x, frame);
	}

	x = ALT(rdr);
	DEREF(x);
	if (NONVAR(x))
	{
		fputc('\n', output);
		tab(tabs);
		fprintf(output, "else ");
		rprin(x, frame);
	}
	
	return true;
}


/************************************************************************/
/*				Initialisation				*/
/************************************************************************/

void control_init(void)
{
	defop(999,	XFX,	_else		= intern("else"));
	defop(999,	XFX,	_then		= intern("then"));
	
	defop(750,	XFY,	_and		= new_fsubr(and, "and"));
	defop(800,	XFY,	_or		= new_fsubr(or, "or"));
	
	_if		= new_fsubr(if_expr, "if");
	anon_struct	= new_var(ANON, 0, _anon);
	
	MACRO(_if)	= if_macro;
	PORTRAY(_if)	= new_pred(print_rule, "print_rule");
}
