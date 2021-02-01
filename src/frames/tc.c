#include <tcutil.h>
#include <tctdb.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include "prolog.h"

static term _of;

static term _cat_frame, _at;

/************************************************************************/
/*	Open and close the Tokyocabinet database			*/
/*	Only one database can be open at one time.			*/
/************************************************************************/


static TCTDB *tdb = NULL;


static bool open_tcb(char *db_name)
{
	tdb = tctdbnew();	// create new database object

	if (! tctdbopen(tdb, db_name, TDBOWRITER | TDBOCREAT))
	{
		fprintf(stderr, "open error: %s\n", tctdberrmsg(tctdbecode(tdb)));
		return false;
	}
	return true;
}

static bool p_open_tcb(term goal, term *frame)
{
	term db_name = check_arg(1, goal, frame, ATOM, IN);
	return open_tcb(NAME(db_name));
}

static bool close_db()
{
	int rval = true;

	if (! tctdbclose(tdb))
	{
		fprintf(stderr, "close error: %s\n", tctdberrmsg(tctdbecode(tdb)));
		rval = false;
	}

	tctdbdel(tdb);
	return rval;
}

static bool p_close_tcb(term goal, term *frame)
{
	term db_name = check_arg(1, goal, frame, ATOM, IN);
	return open_tcb(NAME(db_name));
}

/************************************************************************/
/*			Convert a term to a string		*/
/************************************************************************/

static char *to_string(term t)
{
	extern int display;
	extern char *prin_to_string(term);

	display = true;
	char *rval = prin_to_string(t);
	display = false;
	return rval;
}

/************************************************************************/
/*	Store a frame in the data base					*/
/*	A frame is a set of attribute/value pairs			*/
/************************************************************************/

static bool put_frame(term goal, term *frame)
{
	if (tdb == NULL)
		fail("No open database");
	
	char pkbuf[256];
	int pksiz;
	
	term key_term = check_arg(1, goal, frame, ATOM, OUT);
	
	if (TYPE(key_term) == REF)
	{
		long key = (long) tctdbgenuid(tdb);
		pksiz = sprintf(pkbuf, "%ld", key);
		unify(key_term, frame, intern(pkbuf), frame);
	}
	else
	{
		pksiz = sprintf(pkbuf, "%s", NAME(key_term));
	}
	
	TCMAP *cols = tcmapnew();
	
	for (int i = 2; i <= ARITY(goal); i++)
	{
		term t = check_arg(i, goal, frame, FN, IN);
		
		if (ARITY(t) != 2)
			fail("each argument must be an attribute value pair");

		term attr = eval(ARG(1, t), frame);
		if (TYPE(attr) != ATOM)
			fail("attribute must be an atom");

		char *str = to_string(eval(ARG(2, t), frame));
		tcmapput2(cols, NAME(attr), str);
		free(str);
	}
	
	if (! (ARG(0, goal) == _cat_frame ? tctdbputcat(tdb, pkbuf, pksiz, cols) : tctdbput(tdb, pkbuf, pksiz, cols)))
	{
		fprintf(stderr, "put error: %s\n", tctdberrmsg(tctdbecode(tdb)));
	}
	
	tcmapdel(cols);
	return true;
}

/************************************************************************/
/*	Store a frame in the data base					*/
/*	A frame is a set of attribute/value pairs			*/
/************************************************************************/

static void add_pair(term t, term *frame, TCMAP *cols)
{
	if (TYPE(t) != FN || ARITY(t) != 2)
		fail("each element must be an attribute value pair");
	if (TYPE(ARG(1, t)) != ATOM)
		fail("attribute must be an atom");

//	char *str = to_string(eval(ARG(2, t), frame));
	term x = ARG(2, t);
	if (TYPE(x) == FN && ARG(0, x) == _lbrace)
		x = g_fn1(_at, eval(x, frame));
	char *str = to_string(x);
	tcmapput2(cols, NAME(ARG(1, t)), str);
	free(str);
}

static term expand_braces(term goal, term *frame, term key_atom)
{
	if (tdb == NULL)
		fail("No open database");
	
	if (key_atom == NULL)
	{
		char pkbuf[256];
		long key = (long) tctdbgenuid(tdb);
		int pksiz = sprintf(pkbuf, "%ld", key);
		key_atom = intern(pkbuf);
	}
	
	TCMAP *cols = tcmapnew();
	
	term x = check_arg(1, goal, frame, FN, IN);

	while (TYPE(x) == FN && ARG(0, x) == _comma)
	{
		add_pair(ARG(1, x), frame, cols);
		x = ARG(2, x);
	}
	add_pair(x, frame, cols);
	
	if (! tctdbput(tdb, NAME(key_atom), strlen(NAME(key_atom)), cols))
	{
		fprintf(stderr, "put error: %s\n", tctdberrmsg(tctdbecode(tdb)));
	}
	
	tcmapdel(cols);
	return key_atom;
}

static term p_expand_braces(term goal, term *frame)
{
	return expand_braces(goal, frame, NULL);
	
}

static bool set_frame(term goal, term *frame)
{
	term frame_name = check_arg(1, goal, frame, ATOM, IN);
	term plist	= check_arg(2, goal, frame, FN, IN);
	
	expand_braces(plist, frame, frame_name);
	return true;
}


/************************************************************************/
/*		Retrieve frames from the data base			*/
/************************************************************************/

extern term read_term_from_string(char *);
term read_expr_from_string(char *);

static term check_for_frame_reference(term x, term *frame)
{
	if (TYPE(x) == FN && ARG(0, x) == _at)
		return eval(x, frame);
	return x;
}

static bool get_object(term goal, term *frame, term key_term, char *rbuf, int rsiz)
{
	TCMAP *cols = tctdbget(tdb, rbuf, rsiz);

	if (cols && unify(key_term, frame, intern(rbuf), frame))
	{
		for (int i = 2; i <= ARITY(goal); i++)
		{
			term t = check_arg(i, goal, frame, FN, IN);
			term n = eval(ARG(1, t), frame);
			char *str = tcmapget2(cols, NAME(n));

			if (str == NULL || ! unify(ARG(2, t), frame, check_for_frame_reference(read_expr_from_string(str), frame), frame))
			{
				tcmapdel(cols);
				return false;
			}
		}
		tcmapdel(cols);
		return true;
	}
	return false;
}

static TCLIST *cons_query(term goal, term *frame)
{
	TDBQRY *qry = tctdbqrynew(tdb);
	
	for (int i = 2; i <= ARITY(goal); i++)
	{
		term t = check_arg(i, goal, frame, FN, IN);
		
		if (ARITY(t) != 2)
			fail("each argument must be an attribute value pair");
		if (TYPE(ARG(1, t)) != ATOM)
			fail("attribute must be an atom");
		
		term p = ARG(2, t);
		DEREF(p);
		
		if (TYPE(p) != REF)
		{
			char *str = to_string(ARG(2, t));
			tctdbqryaddcond(qry, NAME(ARG(1, t)), TDBQCSTREQ, str);
			free(str);
		}
	}
	
	return qry;
}

static bool get_all_frames(term goal, term *frame, term key_term)
{
	TDBQRY *qry = cons_query(goal, frame);
	TCLIST *res = tctdbqrysearch(qry);

	for (int i = 0; i < tclistnum(res); i++)
	{
		int rsiz;
		const char *rbuf = tclistval(res, i, &rsiz);
		if (get_object(goal, frame, key_term, rbuf, rsiz))
		{
			if (rest_of_clause())
				break;
			_untrail();
		}
	}

	tctdbqrydel(qry);
	tclistdel(res);
	return false;
}

static bool get_frame(term goal, term *frame)
{
	if (tdb == NULL)
		fail("No open database");

	char pkbuf[256];
	int pksiz;

	term key_term = check_arg(1, goal, frame, ATOM, OUT);

	if (TYPE(key_term) == ATOM)
		return get_object(goal, frame, key_term, NAME(key_term), strlen(NAME(key_term)));
	else
		return get_all_frames(goal, frame, key_term);
}


/************************************************************************/
/*			Remove frames from the data base		*/
/************************************************************************/

static bool remove_all_frames(term goal, term *frame, term key_term)
{
	TDBQRY *qry = cons_query(goal, frame);
	bool res = tctdbqrysearchout(qry);
	
	tctdbqrydel(qry);
	return res;
}

static bool rem_frame(term goal, term *frame)
{
	if (tdb == NULL)
		fail("No open database");
	
	char pkbuf[256];
	int pksiz;
	
	term key_term = check_arg(1, goal, frame, ATOM, OUT);

	if (TYPE(key_term) == ATOM)
	{
		return tctdbout(tdb, NAME(key_term), strlen(NAME(key_term)));
	}
	else
	{
		TDBQRY *qry = cons_query(goal, frame);
		bool res = tctdbqrysearchout(qry);
		tctdbqrydel(qry);
		return res;
	}
}


/************************************************************************/
/*			Replace values in a frame			*/
/************************************************************************/

static bool replace_values(term goal, term *frame)
{
	if (tdb == NULL)
		fail("No open database");
	
	term key_term = check_arg(1, goal, frame, ATOM, IN);
	TCMAP *cols = tctdbget(tdb, NAME(key_term), strlen(NAME(key_term)));
	
	if (cols)
	{
		for (int i = 2; i <= ARITY(goal); i++)
		{
			term t = check_arg(i, goal, frame, FN, IN);
			
			if (ARITY(t) != 2)
				fail("each argument must be an attribute value pair");
			
			term attr = eval(ARG(1, t), frame);
			if (TYPE(attr) != ATOM)
				fail("attribute must be an atom");
			
			char *str = to_string(eval(ARG(2, t), frame));
			tcmapput2(cols, NAME(attr), str);
			free(str);
		}
		
		if (! tctdbput(tdb, NAME(key_term), strlen(NAME(key_term)), cols))
		{
			fprintf(stderr, "put error: %s\n", tctdberrmsg(tctdbecode(tdb)));
		}
	}
	
	tcmapdel(cols);
	return true;
}


/************************************************************************/
/*			Remove values from a frame			*/
/************************************************************************/

static bool remove_values(term goal, term *frame)
{
	if (tdb == NULL)
		fail("No open database");
	
	term key_term = check_arg(1, goal, frame, ATOM, IN);
	TCMAP *cols = tctdbget(tdb, NAME(key_term), strlen(NAME(key_term)));
	
	if (cols)
	{
		for (int i = 2; i <= ARITY(goal); i++)
		{
			term attr = check_arg(i, goal, frame, ATOM, EVAL);
			tcmapout2(cols, NAME(attr));
		}
		
		if (! tctdbput(tdb, NAME(key_term), strlen(NAME(key_term)), cols))
		{
			fprintf(stderr, "put error: %s\n", tctdberrmsg(tctdbecode(tdb)));
		}
	}
	
	tcmapdel(cols);
	return true;
}


/************************************************************************/
/*		Destructively append value to list of value		*/
/************************************************************************/

static void nconc(term list, term val)
{
	print(list);
	term *next = &CDR(list);

	while (*next != _nil)
		next = &CDR(*next);

	if (TYPE(val) == LIST)
		*next = val;
	else
	 	*next = gcons(val, _nil);
}


/************************************************************************/
/*		       Return the expression unevaluated		*/
/************************************************************************/

static term frame_id(term goal, term *frame)
{
	term x = check_arg(1, goal, frame, ANY, IN);
	
	return x;
}


/************************************************************************/
/*			Add values to a frames attributes		*/
/************************************************************************/

static bool add_values(term goal, term *frame)
{
	if (tdb == NULL)
		fail("No open database");
	
	term key_term = check_arg(1, goal, frame, ATOM, IN);
	TCMAP *cols = tctdbget(tdb, NAME(key_term), strlen(NAME(key_term)));
	
	if (cols)
	{
		for (int i = 2; i <= ARITY(goal); i++)
		{
			term t = check_arg(i, goal, frame, FN, IN);
			
			if (ARITY(t) != 2)
				fail("each argument must be an attribute value pair");

			term attr = eval(ARG(1, t), frame);
			if (TYPE(attr) != ATOM)
				fail("attribute must be an atom");

			term new_value = eval(ARG(2, t), frame);

			char *old_str = tcmapget2(cols, NAME(attr));

			if (old_str != NULL)
			{
				term old_val = read_expr_from_string(old_str);

				if (TYPE(old_val) == LIST)
				{
					nconc(old_val, new_value);
					new_value = old_val;
				}
				else
					new_value = gcons(old_val, gcons(new_value, _nil));
			}

			char *new_str = to_string(new_value);
			tcmapput2(cols, NAME(attr), new_str);
			free(new_str);
		}
		
		if (! tctdbput(tdb, NAME(key_term), strlen(NAME(key_term)), cols))
		{
			fprintf(stderr, "put error: %s\n", tctdberrmsg(tctdbecode(tdb)));
		}
	}
	
	tcmapdel(cols);
	return true;
}


/************************************************************************/
/*			    Pretty print a frame			*/
/************************************************************************/

static bool print_frame(term goal, term *frame)
{
	if (tdb == NULL)
		fail("No open database");
	
	char pkbuf[256];
	int pksiz;
	
	term key_term = check_arg(1, goal, frame, ATOM, EVAL);
	TCMAP *cols = tctdbget(tdb, NAME(key_term), strlen(NAME(key_term)));
	
	if (cols)
	{
		char *name;
		
		fprintf(output, "frame(");
		prin(key_term);
		tcmapiterinit(cols);
		
		while ((name = tcmapiternext2(cols)) != NULL)
		{
			fprintf(output, ",\n\t%s: %s", name, tcmapget2(cols, name));
		}
		fprintf(output, "\n)\n");
		tcmapdel(cols);
	}
	return true;
}


/************************************************************************/
/*		    Pretty print a frame in JSON format			*/
/************************************************************************/

static void indent(int n)
{
	putc('\n', output);
	for (int i = 0; i < n; i++)
		putc('\t', output);
}

static void jp_help(term key_term, int n)
{
	char pkbuf[256];
	int pksiz;
	TCMAP *cols = tctdbget(tdb, NAME(key_term), strlen(NAME(key_term)));
	
	if (cols)
	{
		int comma = 0;
		char *name;

		indent(n);
		putc('{', output);

		tcmapiterinit(cols);

		while ((name = tcmapiternext2(cols)) != NULL)
		{
			char *val = tcmapget2(cols, name);

			if (comma++)
				putc(',', output);
			indent(n+1);

			if (val[0] == '@')
			{
				fprintf(output, "%s: ", name);
				term t = read_expr_from_string(++val);
				jp_help(t, n+1);
			}
			else
				fprintf(output, "%s: %s", name, val);
		}
		indent(n);
		putc('}', output);
		tcmapdel(cols);
	}
}

static bool jp(term goal, term *frame)
{
	if (tdb == NULL)
		fail("No open database");
	
	term key_term = check_arg(1, goal, frame, ATOM, IN);
	jp_help(key_term, 0);
	putc('\n', output);

	return true;
}

/************************************************************************/
/*			     Initialise module				*/
/************************************************************************/

void tc_init()
{
//	defop(50,  XFY, _of = intern("of"));
	_cat_frame = intern("cat_frame");

	new_pred(p_open_tcb, "open_db");
	new_pred(p_close_tcb, "close_db");
	new_pred(put_frame, "put_frame");
	new_pred(put_frame, "cat_frame");
	new_pred(get_frame, "get_frame");
	new_pred(rem_frame, "rem_frame");
	new_pred(replace_values, "freplace");
	new_pred(remove_values, "remprop");
	new_pred(add_values, "fadd");

	new_fsubr(p_expand_braces, "{");
	defop(998, XFX, new_pred(set_frame, ":"));
	defop(50, FX, _at = new_subr(frame_id, "@"));
	defop(100, FX, new_pred(print_frame, "pf"));
	defop(100, FX, new_pred(jp, "jp"));

	if (isatty(fileno(stdin)))
	{
		// Silliness to turn US date format into international format
		char day[3], month[4], year[5];
		sscanf(__DATE__, "%s %s %s", month, day, year);

		fprintf(stderr, "\TC frame database (%s %s %s)\n", day, month, year);
	}

}
