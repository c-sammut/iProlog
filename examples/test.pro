animal(Skin_covering, Milk, Homeothermic, Habitat, Reproduction, Breathing, Family) :-
	(Milk = yes -> Family = mammal
	| Breathing = gills -> Family = fish 
	| Skin_covering = scales , Breathing = lungs -> Family = reptile 
	| Skin_covering = feathers -> Family = bird 
	| Skin_covering = none , Milk = no -> Family = amphibian
	).

/*
animal(hair, yes, yes, land, viviporous, lungs, F)?
animal(none, yes, yes, sea, viviporous, lungs, F)?
animal(hair, yes, yes, sea, oviporous, lungs, F)?
animal(hair, yes, yes, air, viviporous, lungs, F)?
animal(scales, no, no, sea, oviporous, gills, F)?
animal(scales, no, no, land, oviporous, lungs, F)?
animal(scales, no, no, sea, oviporous, lungs, F)?
animal(feathers, no, yes, air, oviporous, lungs, F)?
animal(feathers, no, yes, land, oviporous, lungs, F)?
animal(none, no, no, land, oviporous, lungs, F)?
*/

notrace?

f(a).
f(b).
f(c).

% (f(X) -> print(X) | F = 2 | F = 3), a == a?

dynamic(contact/1)!

% contact(_) :- fail.

touch(left).
touch(right).

tr :-
	contact(Side)	-> print(Side);
	touch(Side)	-> print(Side).

trace!
tr?

