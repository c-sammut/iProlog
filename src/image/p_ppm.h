#ifdef _GNU_SOURCE
#define HAVE_BOOL 1	// Needed to stop netpbm's own bool clash with std
#include "ppm.h"
#else
#include "netpbm/ppm.h"
#endif

#define PPM_IMAGE(p) ((ppm *)(CHUNK_DATA(p)))

typedef struct
{
	int width;
	int height;
	pixval maxval;
	pixel **image;
} ppm;


ppm *new_ppm(int width, int height, pixval maxval);
void free_ppm(ppm *p);
ppm *read_ppm(char *fname);
void write_ppm(char *fname, ppm *p);
void display_ppm(ppm *p);
