library(ml)!

table weather(
	outlook(sunny, overcast, rain),
	temprature(hot, mild, cool),
	humidity(high, normal),
	wind(weak, strong),
	play(yes, no)
)!

weather(sunny, hot, high, weak, no).
weather(sunny, hot, high, strong, no).
weather(overcast, hot, high, weak, yes).
weather(rain, mild, high, weak, yes).
weather(rain, cool, normal, weak, yes).
weather(rain, cool, normal, strong, no).
weather(overcast, cool, normal, strong, yes).
weather(sunny, mild, high, weak, no).
weather(sunny, cool, normal, weak, yes).
weather(rain, mild, normal, weak, yes).
weather(sunny, mild, normal, strong, yes).
weather(overcast, mild, high, strong, yes).
weather(overcast, hot, normal, weak, yes).
weather(rain, mild, high, strong, no).

go :-
	X is id(weather),
	pp X.

go!
