/* atom.c */

term intern(char *);
void forall_atoms(void (*fn)());
term gensym(char *);
void defop(int, int, term);

