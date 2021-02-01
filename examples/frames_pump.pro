block ako object with
[
	pump:
	[
		range		pump
	],
	motor:
	[
		range		motor
	],
	input_line:
	[
		range		line
	],
	output_line:
	[
		range		line
	],
	status:
	[
		range
				[good, bad],
		if_needed
		(
				if	status(input_line) = normal
				and	status(output_line) = low
				then	bad
		)
	],
	diagnosis:
	[
		if_needed
		(
				if	status(motor) = low
				then	motor is_replaced_by new [motor]
				and	'Motor replacement required',

				if	pressure(input_line) = pressure(output_line)
				then	pump is_replaced_by new [pump]
				and	'Pump replacement required',

				if	pressure(input_line) < pressure(output_line)
				then	output_line is_replaced_by new [line]
				and	'Line replacement required'
		)
	]
]!

line ako object with
[
	pressure:
	[
		range
				0 .. 200,
		cache
				true,
		if_needed
				ask_user
	],
	nominal_presure:
	[
		range
				0 .. 200,
		cache
				true,
		if_needed
				ask_user
	],
	status:
	[
		range
				[low, normal],
		if_needed
		(
				if pressure < nominal_pressure then low
				else normal
		)
	]
]!

motor ako object with
[
	current:
	[
		range
				0 .. 5,
		if_needed
				ask_user("Check the current through the motor.")
	],
	nominal_current:
	[
		range
				0 .. 5,
		if_needed
				ask_user("What is the nominal current for this motor?")
	],
	status:
	[
		range
				[low, normal],
		if_needed
		(
				if current < nominal_current then low
				else normal
		)
	]
]!


pump ako object with []!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

motor1 isa motor with
[
	nominal_current: 1,
	current: 1
]!

motor2 isa motor with
[
	nominal_current: 1,
	current: 1
]!

motor3 isa motor with []!

pump1 isa pump with []!
pump2 isa pump with []!
pump3 isa pump with []!

line1 isa line with
[
	nominal_pressure: 50,
	pressure: 50
]!

line2 isa line with
[
	nominal_pressure: 100,
	pressure: 80
]!

line3 isa line with
[
	nominal_pressure: 150,
	pressure: 120
]!

block1 isa block with
[
	pump: pump1,
	motor: motor1,
	input_line: line1,
	output_line: line2
]!

block2 isa block with
[
	pump: pump2,
	motor: motor2,
	input_line: line2,
	output_line: line3
]!
