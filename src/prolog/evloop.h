/* evloop.c */

void warning(char *);
void fail(char *);
void evloop(void);
bool trap_cond(term *, term *);
void set_prompt(term);
term get_prompt();