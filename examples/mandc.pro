%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Missionaries and Canibals program.
%
%       The problem:
%               There are three missionaries and three cannibals on the
%               left bank of a river. They wish to cross over to the right
%               bank using a boat which can only carry two at a time. Plan
%               a sequence of crossings that will take everyone across.
%               The number of cannibals on either bank must never be greater
%               than the number of missionaries on the same bank, otherwise
%               the missionaries will be eaten!
%
%       A "state" is one snapshot in time. For this, problem the only
%       information we need to fully characterise a state is:
%               The number of missionaries on the left bank
%               The number of cannibals on the left bank
%               The side the boat is on.
%       All other information can be deduced from these three items.
%       To represent a state we use a 3-arity term, each argument being the
%       items listed:
%                       state(Missionaries, Cannibals, Side)
%       The solution will consist of a list of states, which will show how
%       things changes after each move.
%       The list will look like this:
%               [Most_Recent_States | List_of_Previous_States]
%       That is: the sequence will be in reverse order.
%
%       After the solution has been found, the list will be used to print
%       out the sequence of moves in the correct order.
%
%       Execute by typing "run!"
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run :-
        solve([state(3, 3, left)], X),
        print_soln(X),
	print('-------------------').
 
solve([state(0, 0, right) | Init], [state(0, 0, right) | Init]) :- !.
solve([S1 | Init], Final) :-
        newmove(S1, S2),
        not(member(S2, Init)),
        solve([S2, S1 | Init], Final).
 
newmove(state(M1, C1, left), state(M2, C2, right)) :-
        move(M, C),
        M <= M1,
        C <= C1,
        M2 is M1 - M,
        C2 is C1 - C,
        ok(M2, C2).
newmove(state(M1, C1, right), state(M2, C2, left)) :-
        move(M, C),
        M2 is M1 + M,
        C2 is C1 + C,
        M2 <= 3,
        C2 <= 3,
        ok(M2, C2).
 
move(2, 0).
move(1, 0).
move(1, 1).
move(0, 1).
move(0, 2).
 
ok(X, X) :- !.
ok(3, X) :- !.
ok(0, X).
 
% member(X, [X | _]) :- !.
% member(X, [_ | Y]) :- member(X, Y).
 
print_soln([state(M2, C2, left), state(M1, C1, right) | Y]) :-
        print_soln([state(M1, C1, right) | Y]),
        M is M2 - M1,
        C is C2 - C1,
        print('move ', M, ' missionaries and ', C, ' cannibals to the left').
print_soln([state(M2, C2, right), state(M1, C1, left) | Y]) :-
        print_soln([state(M1, C1, left) | Y]),
        M is M1 - M2,
        C is C1 - C2,
        print('move ', M, ' missionaries and ', C, ' cannibals to the right').
print_soln([_]).

%not(X) :- X, !, fail.
%not(_).
