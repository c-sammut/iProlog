%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Forward chaining rule interpreter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

op(900, xfx, ==>)!
op(800, xfy, &)!
op(800, xfx, rule)!

dynamic(already_fired/1)!

print_rule((Label rule if A then B)) :-
	nl,
	print("\"", Label, "\"", " rule "),
	print_conj("if", A),
	print_conj("then", B).
	
print_conj(KeyWord, A and B) :- !,
	print(KeyWord, "\t", A),
	print_conj(and, B).
print_conj(KeyWord, A) :-
	print(KeyWord, "\t", A).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main interpreter loop is implemented by repeated backtracking.
% Each cycle consists of a matching phases in which we find out which
% rules can fire. If more then one rule is found, conflict resolution
% choses one. The statements in the consequent are executed by Prolog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run :-
	repeat,
	match_conditions(Rules),
	(Rules \= [] ->
		resolve(Rules, (Label rule if Antecedent then Consequent)),
		print_rule((Label rule if Antecedent then Consequent)),
		do(Consequent),
		assert(already_fired(Label, Antecedent));
	!).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Match will return a list of all instances of rules which can fire in
% a particular cycle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

match_conditions(Rules) :-
	findall(Rule, can_fire(Rule), Rules).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To find out if a rule can fire, make sure that each condition on
% the left hand side of a rule matches a fact in working memory.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

can_fire((Label rule if A then B)) :-
	(Label rule if A then B),
	satisfied(A),
	not(already_fired(Label, A)).

satisfied(A and B) :- !,
	A,
	satisfied(B).
satisfied(A) :- A.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Conflict resolution
% Just return the rule that has the longest antecedent.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resolve(Rules, Rule) :-
	resolve1(Rules, 0, _, Rule).

resolve1([], _, X, X).
resolve1([(Label rule if A then C) | Rest], Size, _, X) :-
	rule_size(A, S),
	S > Size, !,
	resolve1(Rest, S, (Label rule if A then C), X).
resolve1([_ | Rest], S, Rule, X) :-
	resolve1(Rest, S, Rule, X).

rule_size(_ and B, N) :- !,
	rule_size(B, Bsize),
	N is Bsize + 1.
rule_size(_, 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Scan through firing rules to perform actions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

do(A and B) :- !,
	execute(A),
	do(B).
do(A) :- execute(A).

execute(X) :- X, !.
execute(_).
