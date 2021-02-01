library(db)?
open_db("test.tct")?

op(50, xfy, of)!
op(50, fx, this)!
op(800, fx, add)!
op(800, fx, replace)!
op(800, fx, remove)!
op(700, xfx, to)!
op(700, xfx, with)!

get_facet(Instance, Attribute, Facet, Daemon) :-
	get_frame(Instance, isa: Parents),
	member(Generic, Parents),
	get_facet_from_generic(Generic, Attribute, Facet, Daemon).

get_facet_from_generic(Generic, Attribute, Facet, Daemon) :-
	get_frame(Generic, Attribute: Facets),
	get_frame(Facets, Facet: Daemon),
	!.
get_facet_from_generic(Generic, Attribute, Facet, Daemon) :-
	get_frame(Generic, ako: Parents),
	member(Parent, Parents),
	get_facet_from_generic(Parent, Attribute: Daemon).

this Attribute is Value :-
	current_object(Object),
	fget(Object, Attribute, Daemon),
	Value is Daemon.

Attribute of Object is Value :-
	asserta(current_object(Object)),
	fget(Object, Attribute, Daemon),
	Value is Daemon,
	retract(current_object(Object)), !.
	
fget(Object, Attribute, Value) :-
	get_frame(Object, Attribute: Value), 
	!.
fget(Object, Attribute: Value) :-
	get_frame(Object, isa: Parents),
	member(Parent, Parents),
	get_frame(Parent, Attribute: Value), !.
fget(Object, Attribute, Value) :-
	get_facet(Object, Attribute, if_needed, Daemon),
	Value is Daemon,
	(get_facet(Object, Attribute, cache, Cond), holds(Cond) -> fadd(Object, Attribute: Value) | true).

add Value to Attribute of Object :-
	asserta(current_object(Object)),
	asserta(new_value is Value),
	range_check(Object, Attribute),
	multivalued(Object, Attribute), !,
	fadd(Object, Attribute: Value),
	if_added(Object, Attribute),
	retract(new_value is Value),
	retract(current_object(Object)).
add Value to Attribute of Object :-
	retract(new_value is Value),
	fail.
add Value to Attribute :-
	atomic(Attribute), !,
	current_object(Object),
	add Value to Attribute of Object.

range_check(Object, Attribute) :-
	get_facet(Object, Attribute, range, Cond), !,
	(holds(Cond) |get_facet(Object, Attribute, help, Help), _ is Help, fail).
range_check(_, _).

multivalued(Object, Attribute) :-
	get_frame(Object, Attribute: _),
	get_facet(Object, Attribute, multivalued, Cond), !,
	holds(Cond).
multivalued(_, _).

if_added(Object, Attribute) :-
	get_facet(Object, Attribute, if_added, Daemon), !,
	_ is Daemon.
if_added(_, _).

remove Slot of Object :-
	asserta(current_object(Object)),
	remprop(Object, Slot),
	get_facet(Object, Slot, if_removed, Daemon), !,
	print(Daemon),
	_ is Daemon,
	retract(current_object(Object)).
remove Slot :-
	atomic(Slot), !,
	print("Removing ", Slot),
	current_object(Object),
	remove Slot of Object.
remove.

holds(Condition) :- true is Condition.

ask_user(Prompt) is X :- print(Prompt, " (terminated by '.')"), read(X).

put_frame(person, eyes: 2)!
put_frame(student, class: cs1297)!

put_frame(fred, isa: [person, student], name: fred, age: 30, occupation: doctor)!
put_frame(jim, isa: [person], name: jim, age: 32+2, occupation: lawyer)!
put_frame(mary, isa: [person], name: mary, age: 28, occupation: lawyer)!

get_frame(Key, isa: [person], name: Name, age: Age, occupation: Occ), Age > 30?

cat_frame(jim, likes: mary)!
cat_frame(fred, likes: jim)!

freplace(fred, age:31)!

fadd(fred, likes: mary, hobby: ["stamp collecting", hiking])!

pf fred!

%likes of likes of fred?

%% Simple example of frames

cylinder:
{
	ako: [object],
	instances: [c, d],
	height:
	{
		range:		number(new_value) and new_value > 0,
		help:		print("Height must be a positive number"),
		if_needed:	ask_user("Enter a height"),
		if_removed:	remove volume,
		cache:		true
	},
	radius:
	{
		range:		number(new_value) and new_value > 0,
		help:		print("Radius must be a positive number"),
		if_needed:	ask_user("Enter a radius value"),
		if_removed:	remove cross_section,
		cache:		true
	},
	cross_section:
	{
		if_needed:	pi * this radius ** 2,
		if_removed:	remove volume,
		cache:		true
	},
	volume:
	{
		if_needed:	this cross_section * this height,
		cache:		true
	},
	orientation:
	{
		range:		member(new_value, [standing, lying]),
		if_added:	print("Cylinder is ", new_value),
		multivalued:	false
	}
}!

c: {isa: [cylinder], height: 2, radius: 3}!
d: {isa: [cylinder], colour: red}!

go :-
	V is volume of c,
	remove height of c.
