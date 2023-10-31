library('ml')!

blackbird :- beak = t, colour = black, legs = 2, tail = t, wings = t.
bird :- beak = t, legs = 2, tail = t, wings = t.

go :-
	X is duce(blackbird, bird),
	pp X.
