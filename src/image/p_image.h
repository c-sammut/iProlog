/* p_image.c */

#define X_VIEWER "/opt/local/bin/xv - "

// #define X_VIEWER "xview stdin "

term push_image(term image);
bool pop_image(void);
term current_image(void);
