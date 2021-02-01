table recg(
	ptype0(n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20),
	ptype1(n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20),
	ptype2(n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20),
	ptype3(n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20),
	ptype4(n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20),
	ptype5(n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20),
	ptype6(n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20),
	ptype7(n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20),
	prob0(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i99999),
	prob1(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i99999),
	prob2(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i99999),
	prob3(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i99999),
	prob4(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i99999),
	prob5(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i99999),
	prob6(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i99999),
	prob7(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i99999), 
	char(do100,do101,do102,do103,do104,do105,do106,do107,do108,do109)
)!
        
test(Rule) :-
	recg(Ptype0,Ptype1,Ptype2,Ptype3,Ptype4,Ptype5,Ptype6,Ptype7,Prob0,Prob1,Prob2,Prob3,Prob4,Prob5,Prob6,Prob7,Char),
	check(recg(Ptype0,Ptype1,Ptype2,Ptype3,Ptype4,Ptype5,Ptype6,Ptype7,Prob0,Prob1,Prob2,Prob3,Prob4,Prob5,Prob6,Prob7,Char), Rule),
	fail.
test(_).

check(X, Rule) :-
	Rule::X, !.
check(X, F) :-
	print(X),
	errors(F) is_replaced_by errors(F) + 1.

go is errors(X) :-
	load 'examples/recg.tr',
	X is induct(recg),
	unload 'recg.tr',
	load 'examples/recg.test',
	test(X),
	pf X,
	unload 'recg.test'.
