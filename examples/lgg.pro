library(ilp)!

lgg(
	(q(f(a), a) :- p(f(a), b), m(b, c), r(b, e)),
	(q(g(x), x) :- p(g(x), y), r(y, z), r(w, z)),
	X,
	Y
)?

lgg(
	f(g(a, b), [1, 2, [3, 4], 5], 1 + 2 * 3),
	f(g(a, h(a, b)), [1, 2, [3, 4, 5]], 1 + 6),
	X,
	Y
)?

lgg(
	(q(f(a)) :- p(a, b), r(b, c), r(b, e)),
	(q(f(x)) :- p(x, y), r(y, z), r(w, z)),
	X,
	Y
)?

% X = q(f(X)) :- p(X, Y) , r(Y, Z) , r(W, Z) , r(Y, E) , r(W, E)

% Y = [X/{a, x}, Y/{b, y}, Z/{c, z}, W/{b, w}, E/{e, z}]
