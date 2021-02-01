%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               WARPLAN robot problem solver
%               written by David Warren
%
%               % prolog warplan robot.plan
%               : run!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
op(650, yfx, =>)!
op(800, xfy, &)!
 
plans(Goal, Trace) :-
        not(consistent(Goal, true)),
        !,
        print(impossible).
plans(Goal, Start_Trace) :-
        plan(Goal, true, Start_Trace, Finish_Trace),
        !,
        print_plan(Finish_Trace),
        nl.
 
consistent(Goal, Protect) :-
        numbervars(Goal & Protect, 0, N),
        imposs(S),
        not(not(intersect(Goal, S))),
        implied(S, Goal & Protect),
        !,
        fail.
consistent(_, _).
 
plan(Goal1 & Other_Goals, Protect, Start_Trace, Final_Trace) :- !,
        solve(Goal1, Protect, Start_Trace, Next_Protect, Next_Trace),
	plan(Other_Goals, Next_Protect, Next_Trace, Final_Trace).
plan(Goal, Protect, Start_Trace, Final_Trace) :-
        solve(Goal, Protect, Start_Trace, _, Final_Trace).
 
solve(Goal, Protect, Trace, Protect, Trace) :-
        always(Goal).
solve(Goal, Protect, Trace, Protect1, Trace) :-
        holds(Goal, Trace),
        conjunction(Goal, Protect, Protect1).
solve(Goal, Protect, Trace, Goal & Protect, Trace1) :-
        add(Goal, Action),
        achieve(Goal, Action, Protect, Trace, Trace1).

achieve(Goal, Action, Protect, Trace, Trace1 => Action) :-
        preserves(Action, Protect),
        can(Action, Precondition),
        consistent(Precondition, Protect),
	plan(Precondition, Protect, Trace, Trace1),
        preserves(Action, Protect).
achieve(Goal, Action, Protect, Trace => Action1, Trace1 => Action1) :-
        preserved(Goal, Action1),
        retrace(Protect, Action1, Protect1),
        achieve(Goal, Action, Protect1, Trace, Trace1),
        preserved(Goal, Action1).
 
holds(Condition, Trace => Action) :-
        add(Condition, Action).
holds(Condition, Trace => Action) :- !,
        preserved(Condition, Action),
	holds(Condition, Trace),
        preserved(Condition, Action).
holds(Condition, Trace) :-
        given(Trace, Condition).
 
preserved(Condition, Action) :-
        numbervars(Condition & Action, 0, N),
        del(Condition, Action), !,
        fail.
preserved(_, _).
 
preserves(Action, Condition & C) :-
        preserved(Condition, Action),
        preserves(Action, C).
preserves(Action, true).
 
retrace(Protect, Action, Protect2) :-
        can(Action, Preconditions),
        retrace1(Protect, Action, Preconditions, Protect1),
        append1(Preconditions, Protect1, Protect2).
 
retrace1(Condition & Protect, Action, Preconditions, Protect1) :-
        add(Condition1, Action),
        equiv(Condition, Condition1),
        !,
        retrace1(Protect, Action, Preconditions, Protect1).
retrace1(Condition & Protect, Action, Preconditions, Protect1) :-
        elem(Condition1, Preconditions),
        equiv(Condition, Condition1),
        !,
        retrace1(Protect, Action, Preconditions, Protect1).
retrace1(Condition & Protect, Action2, C, Condition & P1) :-
        retrace1(Protect, Action2, C, P1).
retrace1(true, Action2, C, true).
 
conjunction(Condition, Protect, Protect) :-
        elem(Y, Protect),
        equiv(Condition, Y), !.
conjunction(Condition, Protect, Condition & Protect).
 
append1(Condition & C, Protect, Condition & P1) :- !,
        append1(C, Protect, P1).
append1(Condition, Protect, Condition & Protect).
 
elem(Condition, Y & C) :- elem(Condition, Y).
elem(Condition, Y & C) :- !, elem(Condition, C).
elem(Condition, Condition).
 
intersect(S1, S2) :- elem(Condition, S1), elem(Condition, S2).
 
implied(S1 & S2, C) :- !, implied(S1, C), implied(S2, C).
implied(Condition, C) :- elem(Condition, C).
implied(Condition, C) :- Condition.
 
equiv(Condition, Y) :- not(nonequiv(Condition, Y)).
 
nonequiv(Condition, Y) :-
        numbervars(Condition & Y, 0, N),
        Condition = Y,
        !,
        fail.
nonequiv(Condition, Y).
 
print_plan(Condition => Y) :- print_plan(Condition), print(Y).
print_plan(Condition) :- print(Condition).
