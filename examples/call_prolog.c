#include <stdio.h>
#include <iProlog/prolog.h>

/*
** Example of calling prolog from regular C program *
** Compile: cc -g call_prolog.c -lprolog -L/usr/local/lib/iProlog
*/

int main()
{
	pl_init();

	print(CAR(CAR(ONE("[X]", "X is 1+1"))));
	print(CAR(ONE("[X]", "X is 2+2")));

	ONE("[]", "assert(f(a, b))");
	ONE("[]", "assert(f(b, c))");
	ONE("[]", "assert(g(1, 2))");

	ONE("[]", "listing");

	print(ALL("[X, Y]", "f(X, Y)"));
	print(ALL("[X, Y]", "g(X, Y)"));

	return 0;
}
