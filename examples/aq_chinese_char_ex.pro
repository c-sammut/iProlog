% Chinese character recognition from Ziino and Amin

table recg(
	stroke0type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke1type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke2type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke3type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke4type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke5type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke6type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke7type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke8type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	stroke9type(t0,t1,t2,t3,t4,t5,t6,t7,none),
	char(do700,do701)
)!

recg(t1,t4,t4,t4,t3,t3,none,none,none,none,do700).
recg(t4,t4,t1,t1,t3,t4,t3,t4,none,none,do700).
recg(t4,t4,t5,t1,t4,t3,t1,none,none,none,do700).
recg(t4,t5,t4,t1,t7,t3,t1,t4,none,none,do700).
recg(t1,t4,t1,t3,t3,t4,none,none,none,none,do700).
recg(t3,t4,t0,t1,t3,t1,none,none,none,none,do700).
recg(t1,t3,t0,t1,t4,t3,t4,none,none,none,do700).
recg(t4,t1,t4,t3,t3,t4,none,none,none,none,do700).
recg(t4,t1,t4,t3,t4,t1,none,none,none,none,do700).
recg(t1,t1,t4,t4,t2,none,none,none,none,none,do700).
recg(t0,t3,t4,t3,t4,t0,t4,t1,none,none,do701).
recg(t4,t4,t1,t1,t4,t3,t0,t3,none,none,do701).
recg(t7,t4,t1,t3,t1,t0,t3,t2,none,none,do701).
recg(t4,t0,t1,t3,t4,t1,t4,t3,t0,none,do701).
recg(t4,t3,t1,t3,t0,t4,t3,t0,none,none,do701).
recg(t0,t4,t4,t3,t0,t1,t4,t3,none,none,do701).
recg(t4,t1,t4,t1,t4,t4,t3,none,none,none,do701).
recg(t1,t4,t0,t3,t3,t3,t0,none,none,none,do701).
recg(t1,t4,t3,t4,t1,t4,t0,t3,none,none,do701).
recg(t0,t4,t1,t1,t4,t4,t3,t3,none,none,do701).

go :-
	X is aq(recg),
	pp X.


