/* files.c */

void reset_io(void);
term add_stream(term, term, FILE *);
term get_stream(term a, term mode);
bool close_stream(term strm);
bool set_input(term streamp);
bool set_output(term streamp);
void add_to_proc_list(term);
void read_file(term);
bool input_file(char *);
