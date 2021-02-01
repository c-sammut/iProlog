%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple example for invoking regression tree algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

table p(+indep, -dep)!

p(1.0, 1.0).
p(2.0, 2.0).
p(3.0, 4.0).
p(4.0, 6.0).

go:-
	X is rt(p),
	pp X.

table q(+a1, +a2, -d)!

q(A1, A2, D) :- p(A1, A2), D is A1 + A2.

go1 :-
	X is rt(q),
	pp X.
