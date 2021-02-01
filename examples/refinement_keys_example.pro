dynamic(bunch/1, red/0)!

opens(Bunch)
	where
		true
	asserting
		bunch(Bunch).

(:- key(Bunch, Make, NumProngs, key_length, Width))
	where
		bunch(Bunch),
		make(Make),
%		prongs(NumProngs),
		key_length(key_length),
		width(Width)
	asserting
		red.

go :-
	F is refine,
	pf F,
	flush_output,
	lgg_frame(F, [doesnt_open]).

make(abloy).
make(chubb).
make(rubo).
make(yale).

prongs(3).
prongs(4).
prongs(5).
prongs(6).

key_length(short).
key_length(medium).
key_length(long).

width(narrow).
width(normal).
width(broad).

opens(bunch1).
key(bunch1, abloy, 4, medium, broad).
key(bunch1, chubb, 3, long, narrow).
key(bunch1, abloy, 3, short, normal).

opens(bunch2).
key(bunch2, chubb, 4, medium, broad).
key(bunch2, chubb, 2, long, normal).
key(bunch2, abloy, 3, medium, broad).

opens(bunch3).
key(bunch3, abloy, 4, medium, broad).
key(bunch3, chubb, 3, long, narrow).
key(bunch3, abloy, 3, short, broad).

opens(bunch4).
key(bunch4, yale, 4, medium, broad).
key(bunch4, chubb, 3, long, broad).
key(bunch4, abloy, 3, medium, broad).
key(bunch4, abloy, 4, medium, narrow).

opens(bunch5).
key(bunch5, rubo, 5, short, narrow).
key(bunch5, yale, 4, long, broad).
key(bunch5, abloy, 3, medium, narrow).
key(bunch5, chubb, 6, medium, normal).

doesnt_open(bunch6).
key(bunch6, yale, 3, short, narrow).
key(bunch6, yale, 4, long, normal).
key(bunch6, chubb, 3, short, broad).
key(bunch6, chubb, 4, medium, broad).

doesnt_open(bunch7).
key(bunch7, yale, 4, long, broad).
key(bunch7, yale, 3, long, narrow).

doesnt_open(bunch8).
key(bunch8, rubo, 4, long, broad).
key(bunch8, yale, 4, long, broad).
key(bunch8, abloy, 3, short, broad).
key(bunch8, chubb, 3, short, broad).

doesnt_open(bunch9).
key(bunch9, chubb, 3, medium, broad).
key(bunch9, rubo, 5, long, narrow).
key(bunch9, abloy, 4, short, broad).
