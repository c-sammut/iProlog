go :-
	X is duce(left, right),
	pp X.

left :- x = left, x_dot = left, theta = far_left, theta_dot = left.
left :- x = left, x_dot = left, theta = far_left, theta_dot = middle.
left :- x = left, x_dot = left, theta = far_left, theta_dot = right.
left :- x = left, x_dot = left, theta = far_right, theta_dot = left.
left :- x = left, x_dot = left, theta = mid_left, theta_dot = middle.
left :- x = left, x_dot = left, theta = mid_right, theta_dot = middle.
left :- x = left, x_dot = left, theta = near_left, theta_dot = left.
left :- x = left, x_dot = left, theta = near_left, theta_dot = middle.
left :- x = left, x_dot = left, theta = near_left, theta_dot = right.
left :- x = left, x_dot = left, theta = near_right, theta_dot = middle.
left :- x = left, x_dot = middle, theta = far_left, theta_dot = left.
left :- x = left, x_dot = middle, theta = far_left, theta_dot = middle.
left :- x = left, x_dot = middle, theta = far_right, theta_dot = left.
left :- x = left, x_dot = middle, theta = mid_left, theta_dot = left.
left :- x = left, x_dot = middle, theta = mid_left, theta_dot = middle.
left :- x = left, x_dot = middle, theta = mid_right, theta_dot = left.
left :- x = left, x_dot = middle, theta = near_left, theta_dot = left.
left :- x = left, x_dot = middle, theta = near_right, theta_dot = left.
left :- x = left, x_dot = right, theta = far_left, theta_dot = left.
left :- x = left, x_dot = right, theta = far_left, theta_dot = middle.
left :- x = left, x_dot = right, theta = far_left, theta_dot = right.
left :- x = left, x_dot = right, theta = mid_left, theta_dot = left.
left :- x = left, x_dot = right, theta = mid_left, theta_dot = middle.
left :- x = left, x_dot = right, theta = mid_left, theta_dot = right.
left :- x = left, x_dot = right, theta = mid_right, theta_dot = left.
left :- x = left, x_dot = right, theta = near_left, theta_dot = left.
left :- x = left, x_dot = right, theta = near_left, theta_dot = middle.
left :- x = left, x_dot = right, theta = near_right, theta_dot = right.
left :- x = middle, x_dot = left, theta = far_left, theta_dot = left.
left :- x = middle, x_dot = left, theta = far_left, theta_dot = middle.
left :- x = middle, x_dot = left, theta = far_left, theta_dot = right.
left :- x = middle, x_dot = left, theta = far_right, theta_dot = left.
left :- x = middle, x_dot = left, theta = mid_left, theta_dot = left.
left :- x = middle, x_dot = left, theta = mid_left, theta_dot = middle.
left :- x = middle, x_dot = left, theta = mid_right, theta_dot = left.
left :- x = middle, x_dot = left, theta = mid_right, theta_dot = middle.
left :- x = middle, x_dot = left, theta = near_left, theta_dot = left.
left :- x = middle, x_dot = left, theta = near_left, theta_dot = middle.
left :- x = middle, x_dot = left, theta = near_right, theta_dot = left.
left :- x = middle, x_dot = left, theta = near_right, theta_dot = middle.
left :- x = middle, x_dot = middle, theta = far_left, theta_dot = left.
left :- x = middle, x_dot = middle, theta = far_left, theta_dot = middle.
left :- x = middle, x_dot = middle, theta = mid_left, theta_dot = left.
left :- x = middle, x_dot = middle, theta = mid_left, theta_dot = middle.
left :- x = middle, x_dot = middle, theta = mid_right, theta_dot = left.
left :- x = middle, x_dot = middle, theta = near_left, theta_dot = left.
left :- x = middle, x_dot = middle, theta = near_right, theta_dot = left.
left :- x = middle, x_dot = right, theta = far_left, theta_dot = left.
left :- x = middle, x_dot = right, theta = far_left, theta_dot = middle.
left :- x = middle, x_dot = right, theta = far_right, theta_dot = left.
left :- x = middle, x_dot = right, theta = mid_left, theta_dot = left.
left :- x = middle, x_dot = right, theta = mid_left, theta_dot = middle.
left :- x = middle, x_dot = right, theta = mid_right, theta_dot = left.
left :- x = middle, x_dot = right, theta = near_left, theta_dot = left.
left :- x = middle, x_dot = right, theta = near_right, theta_dot = left.
left :- x = middle, x_dot = right, theta = near_right, theta_dot = right.
left :- x = right, x_dot = left, theta = far_left, theta_dot = left.
left :- x = right, x_dot = left, theta = far_left, theta_dot = middle.
left :- x = right, x_dot = left, theta = mid_left, theta_dot = middle.
left :- x = right, x_dot = left, theta = mid_right, theta_dot = left.
left :- x = right, x_dot = left, theta = near_left, theta_dot = right.
left :- x = right, x_dot = middle, theta = far_left, theta_dot = left.
left :- x = right, x_dot = middle, theta = far_left, theta_dot = middle.
left :- x = right, x_dot = middle, theta = far_right, theta_dot = left.
left :- x = right, x_dot = middle, theta = mid_left, theta_dot = left.
left :- x = right, x_dot = middle, theta = mid_left, theta_dot = middle.
left :- x = right, x_dot = middle, theta = mid_right, theta_dot = left.
left :- x = right, x_dot = middle, theta = near_left, theta_dot = left.
left :- x = right, x_dot = middle, theta = near_left, theta_dot = middle.
left :- x = right, x_dot = middle, theta = near_right, theta_dot = middle.
left :- x = right, x_dot = right, theta = far_left, theta_dot = left.
left :- x = right, x_dot = right, theta = far_left, theta_dot = middle.
left :- x = right, x_dot = right, theta = far_left, theta_dot = right.
left :- x = right, x_dot = right, theta = far_right, theta_dot = left.
left :- x = right, x_dot = right, theta = mid_left, theta_dot = left.
left :- x = right, x_dot = right, theta = mid_right, theta_dot = left.
left :- x = right, x_dot = right, theta = near_left, theta_dot = middle.
left :- x = right, x_dot = right, theta = near_left, theta_dot = right.
left :- x = right, x_dot = right, theta = near_right, theta_dot = left.
right :- x = left, x_dot = left, theta = far_right, theta_dot = middle.
right :- x = left, x_dot = left, theta = far_right, theta_dot = right.
right :- x = left, x_dot = left, theta = mid_left, theta_dot = left.
right :- x = left, x_dot = left, theta = mid_left, theta_dot = right.
right :- x = left, x_dot = left, theta = mid_right, theta_dot = left.
right :- x = left, x_dot = left, theta = mid_right, theta_dot = right.
right :- x = left, x_dot = left, theta = near_right, theta_dot = left.
right :- x = left, x_dot = left, theta = near_right, theta_dot = right.
right :- x = left, x_dot = middle, theta = far_left, theta_dot = right.
right :- x = left, x_dot = middle, theta = far_right, theta_dot = middle.
right :- x = left, x_dot = middle, theta = far_right, theta_dot = right.
right :- x = left, x_dot = middle, theta = mid_left, theta_dot = right.
right :- x = left, x_dot = middle, theta = mid_right, theta_dot = middle.
right :- x = left, x_dot = middle, theta = mid_right, theta_dot = right.
right :- x = left, x_dot = middle, theta = near_left, theta_dot = middle.
right :- x = left, x_dot = middle, theta = near_left, theta_dot = right.
right :- x = left, x_dot = middle, theta = near_right, theta_dot = middle.
right :- x = left, x_dot = middle, theta = near_right, theta_dot = right.
right :- x = left, x_dot = right, theta = far_right, theta_dot = left.
right :- x = left, x_dot = right, theta = far_right, theta_dot = middle.
right :- x = left, x_dot = right, theta = far_right, theta_dot = right.
right :- x = left, x_dot = right, theta = mid_right, theta_dot = middle.
right :- x = left, x_dot = right, theta = mid_right, theta_dot = right.
right :- x = left, x_dot = right, theta = near_left, theta_dot = right.
right :- x = left, x_dot = right, theta = near_right, theta_dot = left.
right :- x = left, x_dot = right, theta = near_right, theta_dot = middle.
right :- x = middle, x_dot = left, theta = far_right, theta_dot = middle.
right :- x = middle, x_dot = left, theta = far_right, theta_dot = right.
right :- x = middle, x_dot = left, theta = mid_left, theta_dot = right.
right :- x = middle, x_dot = left, theta = mid_right, theta_dot = right.
right :- x = middle, x_dot = left, theta = near_left, theta_dot = right.
right :- x = middle, x_dot = left, theta = near_right, theta_dot = right.
right :- x = middle, x_dot = middle, theta = far_left, theta_dot = right.
right :- x = middle, x_dot = middle, theta = far_right, theta_dot = left.
right :- x = middle, x_dot = middle, theta = far_right, theta_dot = middle.
right :- x = middle, x_dot = middle, theta = far_right, theta_dot = right.
right :- x = middle, x_dot = middle, theta = mid_left, theta_dot = right.
right :- x = middle, x_dot = middle, theta = mid_right, theta_dot = middle.
right :- x = middle, x_dot = middle, theta = mid_right, theta_dot = right.
right :- x = middle, x_dot = middle, theta = near_left, theta_dot = middle.
right :- x = middle, x_dot = middle, theta = near_left, theta_dot = right.
right :- x = middle, x_dot = middle, theta = near_right, theta_dot = middle.
right :- x = middle, x_dot = middle, theta = near_right, theta_dot = right.
right :- x = middle, x_dot = right, theta = far_left, theta_dot = right.
right :- x = middle, x_dot = right, theta = far_right, theta_dot = middle.
right :- x = middle, x_dot = right, theta = far_right, theta_dot = right.
right :- x = middle, x_dot = right, theta = mid_left, theta_dot = right.
right :- x = middle, x_dot = right, theta = mid_right, theta_dot = middle.
right :- x = middle, x_dot = right, theta = mid_right, theta_dot = right.
right :- x = middle, x_dot = right, theta = near_left, theta_dot = middle.
right :- x = middle, x_dot = right, theta = near_left, theta_dot = right.
right :- x = middle, x_dot = right, theta = near_right, theta_dot = middle.
right :- x = right, x_dot = left, theta = far_left, theta_dot = right.
right :- x = right, x_dot = left, theta = far_right, theta_dot = left.
right :- x = right, x_dot = left, theta = far_right, theta_dot = middle.
right :- x = right, x_dot = left, theta = far_right, theta_dot = right.
right :- x = right, x_dot = left, theta = mid_left, theta_dot = left.
right :- x = right, x_dot = left, theta = mid_left, theta_dot = right.
right :- x = right, x_dot = left, theta = mid_right, theta_dot = middle.
right :- x = right, x_dot = left, theta = mid_right, theta_dot = right.
right :- x = right, x_dot = left, theta = near_left, theta_dot = left.
right :- x = right, x_dot = left, theta = near_left, theta_dot = middle.
right :- x = right, x_dot = left, theta = near_right, theta_dot = left.
right :- x = right, x_dot = left, theta = near_right, theta_dot = middle.
right :- x = right, x_dot = left, theta = near_right, theta_dot = right.
right :- x = right, x_dot = middle, theta = far_left, theta_dot = right.
right :- x = right, x_dot = middle, theta = far_right, theta_dot = middle.
right :- x = right, x_dot = middle, theta = far_right, theta_dot = right.
right :- x = right, x_dot = middle, theta = mid_left, theta_dot = right.
right :- x = right, x_dot = middle, theta = mid_right, theta_dot = middle.
right :- x = right, x_dot = middle, theta = mid_right, theta_dot = right.
right :- x = right, x_dot = middle, theta = near_left, theta_dot = right.
right :- x = right, x_dot = middle, theta = near_right, theta_dot = left.
right :- x = right, x_dot = middle, theta = near_right, theta_dot = right.
right :- x = right, x_dot = right, theta = far_right, theta_dot = middle.
right :- x = right, x_dot = right, theta = far_right, theta_dot = right.
right :- x = right, x_dot = right, theta = mid_left, theta_dot = middle.
right :- x = right, x_dot = right, theta = mid_left, theta_dot = right.
right :- x = right, x_dot = right, theta = mid_right, theta_dot = middle.
right :- x = right, x_dot = right, theta = mid_right, theta_dot = right.
right :- x = right, x_dot = right, theta = near_left, theta_dot = left.
right :- x = right, x_dot = right, theta = near_right, theta_dot = middle.
right :- x = right, x_dot = right, theta = near_right, theta_dot = right.