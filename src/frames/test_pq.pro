% trace!

library("db")?
open_db?

fput(person, eyes, default, 2)!
fput(person, eyes, if_removed, print("I'm blind!"))!
fput(person, height, if_needed, 2+2)!
fput(person, age, range, integer(new_value))!
fput(person, age, help, print("ERROR: ", this_slot, " must be an integer\n"))!
freplace(person, age, if_replaced, print("Replace ", old_value, " with ", new_value))!
fput(person, child, multivalued, true)!
fput(person, child, if_added, print("New value: ", new_value))!

fput(fred, isa, person)!
fput(fred, age, 12)!

fput(jim, isa, person)!
fput(jim, age, 9)!

fput(mary, isa, person)!
fput(mary, age, 31)!
fput(mary, child, fred)!
fput(mary, child, jim)!


fget(jim, eyes, X)?
fget(jim, height, X)?
fget(mary, child, X)?

fput(jim, eyes, 2)!

fremove(jim, eyes)?

freplace(fred, age, 13)?

foo: {colour: {default:2}; size: big}!
bar: {isa: foo}!

fput(object, instances, multivalued, true)!


cylinder:
{
	ako: object;
	instances: [c, d];
	height:
	{
		range:		number(new_value) and new_value > 0;
		help:		print("Height must be a positive number");
		if_needed:	ask_user("Enter a height");
		if_removed:	fremove(self, volume);
		cache:		true
	};
	radius:
	{
		range:		number(new_value) and new_value > 0;
		help:		print("Radius must be a positive number");
		if_needed:	ask_user("Enter a radius value");
		if_removed:	fremove(self, cross_section);
		cache:		true
	};
	cross_section:
	{
		if_needed:	pi * radius ** 2;
		if_removed:	fremove(self, volume);
		cache:		true
	};
	volume:
	{
		if_needed:	cross_section * height;
		cache:		true
	};
	orientation:
	{
		range:		member(new_value, [standing, lying]);
		if_added:	print("Cylinder is ", new_value)
	}
}!

c: {isa: cylinder; height: 2; radius: 3}!
d: {isa: cylinder; colour: red}!

go :-
	V is volume(c),
	fremove(c, height).


%close_db!