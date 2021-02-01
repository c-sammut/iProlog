/* frame.c */

#define GENERIC		128

#define IS_GENERIC(x)	(TYPE(x) == ATOM && ((x) -> a.flags & GENERIC))

#define SLOT_NAME(x)	ARG(0, x)
#define VALUE(x)	ARG(1, x)

#define FACET(x)	ARG(0, x)
#define DAEMON(x)	ARG(1, x)

term get_facet(term object, term slot, term facet);
void put_facet(term obj, term prop, term facet, term daemon);
bool check_range(term val);
term fget(term obj, term prop);
bool fremove(term obj, term prop);
bool freplace(term obj, term prop, term val, term *frame);
void make_instance(term obj, term inherits, term slots, term *frame);
bool delete_frame(term obj);
bool delete_slot(term obj, term prop);
bool delete_facet(term obj, term prop, term facet);
bool list_frames(void);
void print_frame(term x);
void frame_init(void);
