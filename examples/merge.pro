%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Straight merge sort
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sort([], []).
sort([A|B], Y) :-
        split(A, B, X1, X2),
        sort(X1, Y1),
        sort(X2, Y2),
        merge(Y1, [A|Y2], Y).

split(_, [], [], []).
split(X, [A|B], [A|L1], L2) :-
        A < X,
        split(X, B, L1, L2).
split(X, [A|B], L1, [A|L2]):-
        A >= X,
        split(X, B, L1, L2).

merge([], X, X).
merge(X, [], X).
merge([A1|B1], [A2|B2], [A1|B]) :-
        A1 < A2,
        merge(B1, [A2|B2], B).
merge([A1|B1], [A2|B2], [A2|B]) :-
        A1 >= A2,
        merge([A1|B1], B2, B).

go(X) :- sort([5, 3, 8, 1, 0, 2], X).
