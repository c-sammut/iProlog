%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A constraint satisfaction puzzle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

puzzle :-
	Houses = [house(_, norwegian, _, _, _), house(blue,_,_,_,_), house(_, _, _, milk, _), _,_],
	member(house(red, english, _, _, _), Houses),
	member(house(_, spanish, dog, _, _), Houses),
	member(house(green, _, _, coffee, _), Houses),
	member(house(_, ukranian, _, tea, _), Houses),
	right_of(house(green,_,_,_,_), house(ivory,_,_,_,_), Houses),
	member(house(_, _, snails, _, winstons), Houses),
	member(house(yellow, _, _, _, kools), Houses),
	next_to(house(_,_,_,_,chesterfields), house(_,_,fox,_,_), Houses),
	next_to(house(_,_,_,_,kools), house(_,_,horse,_,_), Houses),
	member(house(_, _, _, orange_juice, lucy_strikes), Houses),
	member(house(_, japanese, _, _, parliaments), Houses),
	member(house(_, _, zebra, _, _), Houses),
	member(house(_, _, _, water, _), Houses),
	print_houses(Houses).

right_of(A, B, [B, A | _]).
right_of(A, B, [_ | Y]) :- right_of(A, B, Y).

next_to(A, B, [A, B | _]).
next_to(A, B, [B, A | _]).
next_to(A, B, [_ | Y]) :- next_to(A, B, Y).

% member(X, [X|_]).
% member(X, [_|Y]) :- member(X, Y).

print_houses([A|B]) :- !,
	print(A),
	print_houses(B).
print_houses([]).

puzzle!
