/************************************************************************/
/*     		Functions to manipulate an atom's property list		*/
/************************************************************************/

#include <stdarg.h>
#include "prolog.h"


/************************************************************************/
/*			Add a property/value pair			*/
/************************************************************************/

term putprop(term obj, term prop, term val)
{
	term *p;

	for (p = &PLIST(obj); *p != _nil; p = &CDR(*p))
		if (PROPERTY(CAR(*p)) == prop)
			return NULL;

	*p = hcons(h_fn1(prop, val), _nil);
	return CAR(*p);
}


static bool p_putprop(term goal, term *frame)
{
	term obj = check_arg(1, goal, frame, ATOM, IN);
	term prop = check_arg(2, goal, frame, ATOM, IN);
	term val = check_arg(3, goal, frame, ANY, IN);

	if (putprop(obj, prop, make(val, frame)) == NULL)
		fail("Property already exists");
	return true;
}


/************************************************************************/
/*			Get a property/value pair			*/
/************************************************************************/

term getprop(term obj, term prop)
{
	term p;

	for (p = PLIST(obj); p != _nil; p = CDR(p))
		if (PROPERTY(CAR(p)) == prop)
			return CAR(p);
	return NULL;
}

static term p_getprop(term goal, term *frame)
{
	term obj = check_arg(1, goal, frame, ATOM, IN);
	term prop = check_arg(2, goal, frame, ATOM, IN);
	term rval = getprop(obj, prop);

	if (rval == NULL)
		fail("Property does not exists");

	return VALUE(rval);
}


/************************************************************************/
/* 		     Get property value with inheritance		*/
/************************************************************************/

term getpropval(term obj, term prop)
{
	term p;
	
	for (p = PLIST(obj); p != _nil; p = CDR(p))
		if (PROPERTY(CAR(p)) == prop)
			return VALUE(CAR(p));
	
	for (p = INHERITS(obj); p != _nil; p = CDR(p))
	{
		term rval;
		
		if ((rval = getpropval(CAR(p), prop)) != NULL)
			return rval;
	}
	
	return NULL;
}


/************************************************************************/
/* 			Remove a property/value pair			*/
/************************************************************************/

bool remprop(term obj, term prop)
{
	term *p;

	for (p = &PLIST(obj); *p != _nil; p = &CDR(*p))
		if (PROPERTY(CAR(*p)) == prop)
		{
			term tmp = *p;

			*p = CDR(*p);
			CDR(tmp) = _nil; /*protect rest of list from being freed */
			free_term(tmp);
			return true;
		}

	return false;
}


static bool p_remprop(term goal, term *frame)
{
	term obj = check_arg(1, goal, frame, ATOM, IN);
	term prop = check_arg(2, goal, frame, ATOM, IN);

	return remprop(obj, prop);
}


/************************************************************************/
/*	Prolog predicate to get or set an atom's inheritance and	*/
/*	property lists							*/
/************************************************************************/

static bool p_object(term goal, term *frame)
{
	term obj = check_arg(1, goal, frame, ATOM, IN);
	
	switch (ARITY(goal))
	{
		case 1:
		{
			term p;
			
			fprintf(output, "\n\t%-10s", "inherits");
			print(INHERITS(obj));
			
			for (p = PLIST(obj); p != _nil; p = CDR(p))
			{
				term f = CAR(p);
				
				fprintf(output, "\t%-10s", NAME(CAR(f)));
				print(CDR(f));
			}
		}
			break;
		case 2:
		{
			term plist = check_arg(2, goal, frame, LIST, OUT);
			
			if (TYPE(plist) == LIST)
			{
				if (PLIST(obj) != NULL)
					free_term(PLIST(obj));
				PLIST(obj) = make(plist, frame);
			}
			else if (! unify(plist, frame, PLIST(obj), NULL))
				return false;
		}
			break;
		case 3:
		{
			term inherits = check_arg(2, goal, frame, LIST, OUT);
			term plist = check_arg(3, goal, frame, LIST, OUT);
			
			if (TYPE(inherits) == LIST)
			{
				if (INHERITS(obj) != NULL)
					free_term(INHERITS(obj));
				INHERITS(obj) = make(inherits, frame);
			}
			else if (! unify(inherits, frame, INHERITS(obj), NULL))
				return false;
			
			if (TYPE(plist) == LIST)
			{
				if (PLIST(obj) != NULL)
					free_term(PLIST(obj));
//				PLIST(obj) = make(plist, frame);
				
				PLIST(obj) = _nil;
				while (plist != _nil)
				{
					term pair = CAR(plist);

					if (TYPE(pair) != FN || ARITY(pair) != 2)
						fail("Badly formed attribute/value pair");

					term slot_name = ARG(1, pair);
					
					putprop(obj, slot_name, make(eval(ARG(2, pair), frame), frame));
					
					plist = CDR(plist);
					DEREF(plist);
				}
			}
			else if (! unify(plist, frame, PLIST(obj), NULL))
				return false;
		}
			break;
	}
	return true;
}


/************************************************************************/
/*	Prolog predicate to get or set a property/value pair		*/
/************************************************************************/

static bool p_property(term goal, term *frame)
{
	term obj = check_arg(1, goal, frame, ATOM, IN);
	term prop = check_arg(2, goal, frame, ATOM, IN);
	term val = check_arg(3, goal, frame, ANY, OUT);

	switch (TYPE(val))
	{
		case ANON:
		case FREE:
		case BOUND:
		case REF:
		{
			term rval = getpropval(obj, prop);
			
			if (rval == NULL)
				return false;
			else
				return unify(val, frame, rval, NULL);
			
		}
		default:
			if (putprop(obj, prop, make(eval(val, frame), frame)) == NULL)
				fail("Property already exists");
			return true;
	}
}

/************************************************************************/
/*	Public routines for adding a set of property/value pairs     	*/
/************************************************************************/

term build_plist(char *isa, ...)
{
	va_list ap;
	char *prop;
	term obj = gensym(isa);
	
	va_start(ap, isa);
	while ((prop = va_arg(ap, char *)))
	{
		term val = va_arg(ap, term);
		
		putprop(obj, intern(prop), val);
	}
	va_end(ap);
	
	return obj;
}


term build_plist_named(char *isa, ...)
{
	va_list ap;
	char *prop;
	term obj = intern(isa);
	
	va_start(ap, isa);
	while ((prop = va_arg(ap, char *)))
	{
		term val = va_arg(ap, term);
		
		putprop(obj, intern(prop), val);
	}
	va_end(ap);
	
	return obj;
}


/************************************************************************/
/*	Save all frames to a file					*/
/*	Uses forall_atoms to scan through hastable.			*/
/************************************************************************/

static void save_properties_helper(term p)
{
	if ((INHERITS(p) != _nil || PLIST(p) != _nil) &&  (INHERITS(p) != NULL && PLIST(p) != NULL))
	{
		fprintf(output, "properties(");
		prin(p);
		fprintf(output, ", ");
		prin(INHERITS(p));
		fprintf(output, ", ");
		prin(PLIST(p));
		fprintf(output, ")!\n");
	}

}
	
static bool save_properties(term goal, term *frame)
{
	extern int display;
	term fname = check_arg(1, goal, frame, ATOM, IN);
	FILE *old_output = output;
	term p;
	int i;

	output = fopen(NAME(fname), "w");
	display = true;
	
	forall_atoms(save_properties_helper);

	fclose(output);
	output = old_output;
	return true;
}


/************************************************************************/
/*				init					*/
/************************************************************************/

void plist_init(void)
{
	PLIST(_nil)		= _nil; /* fudge because initialisation of [] */
	
	new_pred(p_object,		"object");
	new_pred(p_property,		"property");
	new_pred(p_putprop,		"putprop");
	new_subr(p_getprop,		"getprop");
	new_pred(p_remprop,		"remprop");
	new_pred(save_properties,	"save_properties");
}
