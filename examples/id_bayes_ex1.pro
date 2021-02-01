table object(
		size(small, medium, large),
		colour(red, blue, green),
		shape(wedge, brick, pillar, sphere),
		class(yes, no)
)!

object(medium, blue, brick, yes).
object(small, red, sphere, yes).
object(large, green, pillar, yes).
object(large, green, sphere, yes).

object(small, red, wedge, no).
object(large, red, wedge, no).
object(large, red, pillar, no).

go is id(object).

go2(X) :-
	bayes(object(small, blue, wedge, X)).

% : go1?
% id0
%
% pp id0!
%
% object(Size, Colour, Shape, Class) :-
%	(Shape = wedge -> Class = no
%	|Shape = brick -> Class = yes
%	|Shape = pillar ->
%		(Colour = red -> Class = no
%		|Colour = green -> Class = yes
%		)
%	|Shape = sphere -> Class = yes
%	).
% ** yes
%
% : go2(X)?
%
% X = no

