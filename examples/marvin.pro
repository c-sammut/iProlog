%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The beginnings of an implementation of the Marvin learning
% system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

op(900, xfx, <--)!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find elaborations of example and then use them to
% generlise it to reach the target description
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

learn(Concept <-- Example, Concept <-- Generalisation) :-
	all_elaborations(Example, Elaborations),
	print_all(Elaborations),
	target(Example, Elaborations, Generalisation).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect all clauses which elaborate the trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

all_elaborations(Trial, Elaborations) :-
	elaboration_one_pass(Trial, Elab1),
	Elab1 \= [], !,
	conc_heads(Trial, Elab1, NewTrial),
	all_elaborations(NewTrial, Elab2),
	conc(Elab1, Elab2, Elaborations).
all_elaborations(Trial, []).

elaboration_one_pass(Trial, Elaborations) :-
	findall(E, elaboration(Trial, E), Elaborations).

elaboration(Trial, Head <-- Body) :-
	Head <-- Body,
	subset(Body, Trial),
	not(member(Head, Trial)).

conc_heads([], [], []).
conc_heads([], [H <-- B | T], [H | X]) :-
	conc_heads([], T, X).
conc_heads([A|B], C, [A|D]) :-
	conc_heads(B, C, D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The target is a subset of the intial trial plus all
% elaborations. Ask the oracle of the target is correct.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

target(T, [], T).
target(Trial, [E | Rest], Target) :-
	try(Trial, E, NewTrial),
	target(NewTrial, Rest, Target).

try(Trial, Replacement, NewTrial) :-
	replace(Replacement, Trial, NewTrial),
	oracle(NewTrial), !.
try(Trial, _, Trial).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform replacement for all selected elaborations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

replace_all([], T, T).
replace_all([E | Rest], Trial, T) :-
	replace(E, Trial, T1),
	replace_all(Rest, T1, T).

% replace body of elaboration by the head

replace(Head <-- Body, Trial, [Head | T]) :-
	delete(Body, Trial, T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intra-construction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invent(Head <-- Body) :-
	H1 <-- B1,
	H2 <-- B2,
	B1 \= B2,
	numbervars(B1, 1, _),
	numbervars(B2, 1, _),
	intersection(B1, B2, Body),
	print(H1 <-- B1),
	print(H2 <-- B2),
	ask_teacher(Head, Body).

ask_teacher(Head, Body) :-
	print('Is'),
	print('	', Body),
	print('a useful concept concept'),
	ratom(y),
	print('Please enter the head of the new clause.'),
	read(Head).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			 Standard list processing utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conc([], X, X).
conc([A|B], C, [A|D]) :- conc(B, C, D).

subset([], _).
subset([A|B], X) :-
	member(A, X),
	subset(B, X).

delete(_, [], []).
delete(X, [A|B], Y) :-
	member(A, X), !,
	delete(X, B, Y).
delete(X, [A|B], [A|C]) :-
	delete(X, B, C).

intersection([], _, []).
intersection([A|B], C, [A|D]) :-
	member(A, C),
	intersection(B, C, D).

%member(X, [X|_]).
%member(X, [_|Y]) :- member(X, Y).

print_all([]).
print_all([A|B]) :- print(A), print_all(B).

oracle(T) :-
	nl,
	print('Is ', T),
	print('contained in the target concept?'),
	ratom(y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

chair(X) <-- [legs(X, 4), has_back(X)].

%any_shape(X) <-- [brick(X)].
%any_shape(X) <-- [wedge(X)].

%any_orientation(X) <-- [standing(X)].
%any_orientation(X) <-- [lying(X)].

column(X) <-- [brick(X), standing(X), on(X, ground)].
column(X) <-- [brick(X), standing(X), on(X, Y), column(Y)].

same_height(X, Y) <-- [on(X, ground), on(Y, ground)].
same_height(X, Y) <-- [on(X, X1), on (Y, Y1), same_height(X1, Y1)].

t1(X) :-
	learn(
		dining_room(my_room) <--
			[
			 part_of(my_room, chair1),
			 legs(chair1, 4),
			 has_back(chair1)
			],
		X).

t2(X) :-
	learn(
		arch(e) <--
			[
			 brick(a),
			 standing(a),
			 on(a, b),
			 brick(b),
			 standing(b),
			 on(b, ground),
			 brick(c),
			 standing(c),
			 on(c, d),
			 brick(d),
			 standing(d),
			 on(d, ground),
			 brick(e),
			 lying(e),
			 on(e, a),
			 on(e, c)
			],
		X).

t3(X) :-
	learn(
		column(a) <--
			[
			 brick(a),
			 standing(a),
			 on(a, b),
			 brick(b),
			 standing(b),
			 on(b, ground)
			],
		X).
