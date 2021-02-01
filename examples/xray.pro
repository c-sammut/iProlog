%% Test program for skeletonisation and tracing

go :-
	Im is read_pgm('../../examples/test.pgm'),
	display_pgm,
	T is threshold(Im, 140),
	display_pbm,
	S is skeletonise(T) ,
	display_pbm,
	trace_skeleton.
