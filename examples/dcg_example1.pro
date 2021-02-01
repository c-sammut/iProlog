%	Parses simple sentences such as 'the giraffe eats the apple'

sent(V) --> np(N), vp(N, V).

np(X) --> det, noun(X).
np(X) --> proper_noun(X).

vp(N, V) --> iverb(N, V).
vp(Subj, V) --> tverb(Subj, Obj, V), np(Obj).

det --> [the].
det --> [a].

noun(giraffe) --> [giraffe].
noun(apple) --> [apple].

proper_noun(john) --> [john].
proper_noun(mary) --> [mary].

iverb(X, dreams(X)) --> [dreams].

tverb(X, Y, eats(X, Y)) --> [eats].

go(X) :- sent(X, [the, giraffe, eats, the, apple], _).
