%% Example of data file for propositional induction programs

table lens(
	age(young, pre_presbyopic, presbyopic),
	prescription(myope, hypermetrope),
	astigmatism(not_astigmatic, astigmatic),
	tear_production(reduced, normal),
	lens(hard, soft, none)
)!

lens(young, myope, not_astigmatic, reduced, none).			% 1
lens(young, myope, not_astigmatic, normal, soft).			% 2
lens(young, myope, astigmatic, reduced, none).				% 3
lens(young, myope, astigmatic, normal, hard).				% 4
lens(young, hypermetrope, not_astigmatic, reduced, none).		% 5
lens(young, hypermetrope, not_astigmatic, normal, soft).		% 6
lens(young, hypermetrope, astigmatic, reduced, none).			% 7
lens(young, hypermetrope, astigmatic, normal, hard).			% 8
lens(pre_presbyopic, myope, not_astigmatic, reduced, none).		% 9
lens(pre_presbyopic, myope, not_astigmatic, normal, soft).		% 10
lens(pre_presbyopic, myope, astigmatic, reduced, none).			% 11
lens(pre_presbyopic, myope, astigmatic, normal, hard).			% 12
lens(pre_presbyopic, hypermetrope, not_astigmatic, reduced, none).	% 13
lens(pre_presbyopic, hypermetrope, not_astigmatic, normal, soft).	% 14
lens(pre_presbyopic, hypermetrope, astigmatic, reduced, none).		% 15
lens(pre_presbyopic, hypermetrope, astigmatic, normal, none).		% 16
lens(presbyopic, myope, not_astigmatic, reduced, none).			% 17
lens(presbyopic, myope, not_astigmatic, normal, none).			% 18
lens(presbyopic, myope, astigmatic, reduced, none).			% 19
lens(presbyopic, myope, astigmatic, normal, hard).			% 20
lens(presbyopic, hypermetrope, not_astigmatic, reduced, none).		% 21
lens(presbyopic, hypermetrope, not_astigmatic, normal, soft).		% 22
lens(presbyopic, hypermetrope, astigmatic, reduced, none).		% 23
lens(presbyopic, hypermetrope, astigmatic, normal, none).		% 24

go1 :- 
	X is id(lens),
	pp X,
	test(X).

go2(X) :- bayes(lens(pre_presbyopic, myope, not_astigmatic, normal, X)).
go2(X) :- bayes(lens(pre_presbyopic, myope, not_astigmatic, reduced, X)).

go is induct(lens).

test(F) :-
	lens(Age, Prescription, Astigmatism, TearProduction, Lens),
	(F::lens(Age, Prescription, Astigmatism, TearProduction, Lens1) ->
		print('Lens = ', Lens, '; Actual = ', Lens1);
	 print("Can't classify ", lens(Age, Prescription, Astigmatism, TearProduction, Lens))).

