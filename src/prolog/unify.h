/* unify.c */

void make_ref(term, term *);
term copy(term, term *);
bool unify(term, term *, term, term *);
term unbind(term, term *);
