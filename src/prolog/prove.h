/* prove.c */

#define INTERACTIVE

#define DISABLED	128
#define DISABLE(x)	FLAGS(x) |= DISABLED
#define ENABLED(x)	!(FLAGS(x) & DISABLED)

typedef struct query_struct *query;
typedef struct env_struct *env;

typedef struct query_struct
{
	query previous_query;
	env old_top_of_stack;
	env query_env;
	term query_vars;
	term result;
	int how_many;
	void (*new_result)();
} query_struct;

typedef struct env_struct
{
	env parent;
	term *goals;
	term *frame;
	term *global;
	term db;
	term trail;
	env prev;
	int cut;
} env_struct;

extern term *global;
extern env top_of_stack;


/************************************************************************/
/*			    	Prototypes				*/
/************************************************************************/

bool cond(term *, term *);
bool rest_of_clause(void);
void untrail(term);
void _untrail(void);
void lush(term, term, int);
term call_prove(term *, term *, term, int, void (*)(), int);
void backtrace(void);
void directive(term, term);
void trace_print(char *, env, term);
void cut(env);
bool prove(term *, env);

