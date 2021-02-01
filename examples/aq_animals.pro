%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The "classic" animals learning example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

table animal(
	skin_covering(none, hair, feathers, scales),
	milk(yes, no),
	homeothermic(yes, no),
	habitat(land, sea, air),
	reproduction(oviporous, viviporous),
	breathing(lungs, gills),
	family(mammal, fish, reptile, bird, amphibian)
)!

animal(hair, yes, yes, land, viviporous, lungs, mammal).
animal(none, yes, yes, sea,  viviporous, lungs, mammal).
animal(hair, yes, yes, sea,  oviporous,  lungs, mammal).
animal(hair, yes, yes, air,  viviporous, lungs, mammal).

animal(scales, no,  no, sea,  oviporous,  gills, fish).

animal(scales, no, no, land, oviporous, lungs, reptile).
animal(scales, no, no, sea,  oviporous, lungs, reptile).

animal(feathers, no, yes, air,  oviporous, lungs, bird).
animal(feathers, no, yes, land, oviporous, lungs, bird).

animal(none, no, no, land, oviporous, lungs, amphibian).

go :-
	X is aq(animal),
	pp X.

% result

% animal(Skin_covering, Milk, Homeothermic, Habitat, Reproduction, Breathing, Family) :-
%	(Milk = yes -> Family = mammal
%	| Breathing = gills -> Family = fish
%	| Skin_covering = scales , Breathing = lungs -> Family = reptile
%	| Skin_covering = feathers -> Family = bird
%	| Skin_covering = none , Milk = no -> Family = amphibian
%	).

