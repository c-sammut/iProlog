library('ml')!

blackbird :- beak = t, colour = black, legs = 2, tail = t, wings = t.
chimp :- colour = brown, hairy = t, legs = 2, tail = t, wings = f.
eagle :- beak = t, colour = golden, legs = 2, tail = t, wings = t.
elephant :- colour = grey, legs = 4, size = big, tail = t, trunk = t, wings = f.
elephant :- colour = grey, legs = 4, size = small, tail = t, trunk = t, wings = f.
falcon :- beak = t, colour = brown, legs = 2, size = big, tail = t, wings = t.
gorilla :- colour = black, hairy = t, legs = 2, tail = f, wings = f.
lemur :- colour = grey, legs = 2, tail = t, wings = f.
man :- colour = brown, hairy = f, legs = 2, size = big, tail = f, wings = f.
man :- colour = pink, hairy = f, legs = 2, size = small, tail = f, wings = f.
sparrow :- beak = t, colour = brown, legs = 2, size = small, tail = t, wings = t.

go :-
	X is duce(blackbird, chimp, eagle, elephant, falcon, gorilla, lemur, man, sparrow),
	pp X.
