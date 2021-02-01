%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Domain knowledge for WARPLAN - stacking blocks.
%       execute using 'run!' - solves Sussman's anomoly.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dynamic(on/2, clear/1)!

add(on(U,W),    move(U,V,W)).
add(clear(V),   move(U,V,W)).
 
del(on(U,V),    move(U,V,W)).
del(clear(W),   move(U,V,W)).
 
can(move(U,V,floor),    on(U,V) & V \= floor & clear(U)).
can(move(U,V,W),        clear(W) & on(U,V) & U \= W & clear(U)).
 
imposs(on(X,Y) & clear(Y)).
imposs(on(X,Y) & on(X,Z) & Y \= Z).
imposs(on(X,X)).
imposs(on(X, Z) & on(Y, Z) & X \= Y).
 
always(X) :- X.
 
given(start,on(a,floor)).
given(start,on(b,floor)).
given(start,on(c,a)).
given(start,on(d,floor)).
given(start,on(e,d)).
given(start,clear(b)).
given(start,clear(c)).
given(start,clear(e)).
 
run:-
	T0 is cputime,
	plans(on(a, b) & on(b, c), start),
	Time is cputime - T0,
	print('Time = ', Time).
