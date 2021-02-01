%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The modules below is an interpreter for a rule system called
% Generalized Variable-valued Logic invented by R.S. Michalski.
% The program was written by Claude Sammut.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

op(900, xfx, ::>)!
op(800, fx, @)!
op(750, xfx, =>)!
op(200, xfx, certainty)!
op(300, xfx, ..)!
op(200, xfy, or)!
op(100, fx, fn)!
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The top level procedure of the program is "diagnosis". When called by
% the query "diagnosis(D)?", the system will apply a set of rules describing
% disease conditions, to set of facts to produce a diagnosis. Each diagnosis
% is accompanied by a "Certainty". This is a percentage of confidence in
% the diagnosis e.g. "meningitis certainty 65" means a disease has been
% diagnosed as menangitis with 65% confidence.
% If a disease cannot be diagnosed with a confidence greater than a given
% threshold then it is not reported.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% The threshold certainty is defined to be 65%
 
certainty_threshold is 65.

diagnosis(Diagnosis certainty Certainty) :-
	conclude(Diagnosis certainty Certainty),
	Certainty >= certainty_threshold.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "conclude" is the top level of the rule interpretation program. The procedure
% states that a conclusion reached by a rule of the form Premise ::> Conclusion
% applies to the facts with a certainty obtained by evaluating the premise of
% the rule.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
conclude(Conclusion certainty Certainty) :-
	Premise ::> Conclusion,
	eval(Premise, Certainty).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To evaluate an expression of the form A + B, i.e. to determine the certainty
% of A and B applying to the facts, evaluate A and B separately, then add their
% certainties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
eval(A + B, Certainty) :- !,
	eval(A, Certainty1),
	eval(B, Certainty2),
	Certainty is Certainty1 + Certainty2.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An expression of the form Q * C consists of a percentage, Q, and a conjunction
% C. To evaluate this, we evaluate each conjunct and collect the resulting
% certainties in a list. We then take the average of the certainties and
% multiply the result by Q (since it is a percentage, we must divide by 100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
eval(Q * C, Certainty) :- !,
	conjunction(C, Certainties),
	Certainty is Q * sum(Certainties) div #Certainties div 100.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A conjunction without a percentage Q, is evaluated by averaging the
% certainties of each conjunct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
eval(C, Certainty) :- !,
	conjunction(C, Certainties),
	Certainty is sum(Certainties) div #Certainties.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A conjunction is represented as a list of selectors.
% The two parameters of "Conjunction" are the list of selectors and the
% list of certainties associated with each selector.
% The list of certainties is specified by evaluated the first selctor
% the calling "conjunction" recursively to evaluate the rest.
% One exception to this processing occurs when a conjunct has the form
% A => B. If A is true (ie. certainty = 100%) then we evaluate B.
% If A is not true then we ignore B completely.
% The first two clauses of conjunction deal with this case.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
conjunction([A => B | C], [B1 | C1]) :-
	selector(A, 100), !,
	selector(B, B1),
	conjunction(C, C1).
conjunction([A => B | C], C1) :- !,
	conjunction(C, C1).
conjunction([A | C], [A1 | C1]) :-
	selector(A, A1),
	conjunction(C, C1).
conjunction([], []).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The parameter to "sum" is a list of numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sum([]) is 0.
sum([A|B]) is A + sum(B).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If a selector has the form S certainty fn F then get the value of the
% attribute, S from the set of facts then apply function, F, to the value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
selector(S certainty fn F, Certainty) :- !,
	@ S = V,
	Certainty is F(V), !.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If a relation is of the form P(A, B) where P is a relation such as "<"
% and A is an attribute and B specifies the range of possible values of A
% then get the value of A from the facts and evaluate the conditional expression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

selector(P(A, B), 100) :-
	@ A = V,
	eval_cond(P(V, B), A), !.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If there is no match for the selector, return a certainty of 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

selector(_, 0).
 
% A selector may have from: V = A or B. If so then evaluating either A or B
% will return a result.
 
eval_cond(V = (A or B), T) :- !,
	eval_cond(V = A, T).
eval_cond(V = (A or B), T) :- !,
	eval_cond(V = B, T).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the selector is V = A..B, this means that the value, V,  may be in the
% range A to B. In this case we must find out the range of values that v can
% have by enumerating the elements between A and B and finding out if V is
% a member.
% As an example: the domain of attribute "time" is specified as the months
% of the year. "expand_range" will give the list of months which are allowed
% for time which would be passed as th parameter T.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
eval_cond(V = A..B, T)  :- !,
%	R is expand_range(A..B, domain(T)),
%	member(V, R).
	V in expand_range(A..B, domain(T)).
eval_cond(C, _) :- C.
 
expand_range(A..B, [A|T]) is [A | fill_range(B, T)].
expand_range(A..B, [X|T]) is expand_range(A..B, T).
expand_range(_, []) is [].
 
fill_range(X, [X|_]) is [X].
fill_range(X, [A|B]) is [A | fill_range(X, B)].
 
% member(X, [X|_]) :- !.
% member(X, [A|B]) :- member(X, B).
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This module contains rules which show how to diagnose diseases in soybean
% plant. The rules are expressed in a variant of Generalized Variable-valued
% Logic.
% 
% In GVL, event are described by a a set of attribute/value pairs. In this case
% an event is the observation of a diseased plant. An attribute of the the event
% is the time at which the observation was made. The domain of the attribute can
% be specified as below. Other attributes include the temperature, whether the
% leaves of the plant were normal or abnormal etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
domain(time) is [jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec].
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A GVL "selector" has the form "Predicate certainty Certainty". e.g.
% color = blue certainty 35 indicates that if the color attrbute is blue then a
% certainty of 35% is associated with the selector.
% In some cases, the certainty may be a function of the value of the attribute.
% For example, if the precipitation during the month of the observation was
% greater than 20mm then a 100% certainty is associted with precipitation,
% if 20mm fell, then 70% or 30% for anything else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p(Precipitation) is 100 :- Precipitation > 20.
p(20) is 70.
p(_)  is 30.
 
r1(N) is 100 :- N >= 3.
r1(2) is 80.
r1(1) is 70.
r1(0) is 20.
 
r2(N) is 100 :- N >= 2.
r2(2) is 60.
r2(0) is 20.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following rule shows how to diagnose the disease "diapthre stem canker".
% 90% of the evidence for the disease is based on the first conjunction
% 10% from the second.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
90 * [  time = aug..sep,
	precipitation certainty fn p,
	stem_cankers = above_second_node,
	fruiting_bodies = p,
	fruit_pods = n]
 
		+
 
10 * [  temperature >= 30,
	canker_lesion_colour = brown,
	years_crop_repeated certainty fn r1]
 
::> [diagnosis = diapothre_stem_canker].
 
 
90 * [  time = jul..aug,
	precipitation <= 2,
	temperature > 30,
	plant_growth = abn,
	leaves = abn,
	stem = abn,
	sclerotia = p,
	roots = rotted,
	internal_discolouration = black]
 
		+
10 * [  damaged_area = upland_areas,
	severity = severe,
	seed_size < 2,
	years_crop_repeated certainty fn r2]
 
::> [diagnosis = charcoal_rot].
 
 
90 * [  time = may..jun,
	plant_stand < 12,
	temperature < 25,
	precipitation < 2,
	leaves = abn,
	stem = abn,
	canker_lesion_colour = brown,
	roots = rotted,
	occurrence_of_hail = no =>
		stem_cankers = (below_soil_line or
			       at_soil_line or
			       slightly_above_soil_line),
	occurrence_of_hail = yes => stem_cankers = above_second_node]
 
		+
 
10 * [  fruiting_bodies = abs,
	external_decay = firm_dry,
	mycelium = abs]
 
::> [diagnosis = rhizoctonia_root_rot].
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following module contains a description of the event observed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
@ time = may.
@ plant_stand = 4.
@ precipitation = 1.
@ stem_cankers = above_second_node.
@ fruiting_bodies = abs.
@ fruit_pods = n.
@ external_decay = firm_dry.
@ temperature = 24.
@ stem = abn.
@ roots = rotted.
@ canker_lesion_colour = brown.
@ occurrence_of_hail = yes.
@ mycelium = p.
@ years_crop_repeated = 2.
