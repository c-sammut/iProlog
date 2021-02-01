%	Convert English statement into predicate logic.
%	From Clocksin & Mellish
%
% example sentences:
%
% : go(X)?
% -> john loves mary.
% X = loves(john, mary)
%
% : go(X)?
% -> every man that lives loves a woman.
% X = all(_R36, (man(_R36) & lives(_R36) -> exists(_R69, woman(_R69) & loves(_R36, _R69))))

op(700, xfy, &)!

sentence(P) -->
	noun_phrase(X, P1, P),
	verb_phrase(X, P1).

noun_phrase(X, P1, P) -->
	determiner(X, P2, P1, P),
	noun(X, P3),
	rel_clause(X, P3, P2).

noun_phrase(X, P, P)  --> proper_noun(X).

verb_phrase(X, P) -->
	trans_verb(X, Y, P1),
	noun_phrase(Y, P1, P).

verb_phrase(X, P) --> intrans_verb(X, P).

rel_clause(X, P1, (P1 & P2)) --> [that], verb_phrase(X, P2).

rel_clause(_, P, P) --> [].


determiner(X, P1, P2, all(X, (P1 -> P2))) --> [every].

determiner(X, P1, P2, exists(X, (P1 & P2))) --> [a].


noun(X, man(X)) --> [man].

noun(X, woman(X)) --> [woman].

proper_noun(john) --> [john].

proper_noun(mary) --> [mary].

trans_verb(X, Y, loves(X, Y)) --> [loves].


intrans_verb(X, lives(X)) --> [lives].

go(X) :-
	read_sentence(S),
	sentence(X, S, []).
