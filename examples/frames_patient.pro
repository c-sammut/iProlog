%% A more complicated example of frames

library(kbs)!

person ako [] with
[
	name:
	[
		range		atom,
		help		message("The name should be a string."),
		if_new		ask_user,
		cache		true
	],
	sex:
	[
		range		[male, female],
		help		message("Sex can only be male or female, not ", new_value),
		if_needed	ask_user,
		if_replaced	message("Are you sure you want a sex change?"),
		if_removed	message("Are you sure you want the sex removed?"),
		cache		true
	],
	year_of_birth:
	[
		range		year(current_date) - 120 .. year(current_date),
		help		message("Invalid year of birth."),
		if_needed	ask_user("Year of birth"),
		cache		true
	],
	age:
	[
		cache		true,
		if_needed	year(current_date) - year_of_birth
	],
	parents:
	[
		multivalued	true,
		range		person,
		help		message("The value in a parents slot must be a person.")
	],
	height:
	[
		range		10..220,
		cache		true,
		help
		(		if new_value < 10 then
					message(new_value, "cm is too short."),
				if new_value > 220 then
					message(new_value, "cm is too tall."),
				message("The height should be between 10 and 220cm.")
		),
		if_needed	ask_user("What is the height of ", name)
	],
	weight:
	[
		range		1..150,
		help		message("Weight should be in the range 1 .. 150"),
		if_needed	ask_user("What is the weight of ", name),
		cache		true,
		if_added	if new_value > 100 then
					message("Your ", current_slot, " is too high!")
	],
	occupation:
	[
		range		atom,
		help		message("The occupation should be a string."),
		if_needed	ask_user("What is the occupation"),
		cache		true,
		if_removed	message("I used to be a ", old_value, ".")
	]
]!


measure ako [] with
[
	current_value:
	[
		range		allowable_low .. allowable_high,
		help		message("The patient is dead!"),
		if_new		ask_user(prompt),
		cache		true,
		if_added:	if	new_value < expected_low then
					interpretation is_replaced_by low
				else if	new_value > expected_high then
					interpretation is_replaced_by high
				else	interpretation is_replaced_by normal,
		if_replaced	last_value is_replaced_by old_value
	],
	interpretation:
	[
		range		[low, normal, high],
		help		message("Interpretation can only be 'low', 'normal' or 'high'")
	]
]!

%% Should this be a frame or generic???

ph_frame ako measure with
[
	prompt:		[if_needed	"ph level"],
	allowable_low:	[if_needed	6],
	allowable_high:	[if_needed	8],
	expected_high:	[if_needed	7.6],
	expected_low:	[if_needed	6.5]
]!

'HCO3_frame' ako measure with
[
	prompt:		[if_needed	"HCO3 level"],
	allowable_low:	[if_needed	6],
	allowable_high:	[if_needed	8],
	expected_high:	[if_needed	7.6],
	expected_low:	[if_needed	6.5]
]!

paCO2_frame ako measure with
[
	prompt:		[if_needed	"paCO2 level"],
	allowable_low:	[if_needed	6],
	allowable_high:	[if_needed	8],
	expected_high:	[if_needed	7.6],
	expected_low:	[if_needed	6.5]
]!

patient ako person with
[
	ph:
	[
		cache		true,
		if_needed	new [ph_frame]
	],
	'HCO3':
	[
		cache		true,
		if_needed	new ['HCO3_frame']
	],
	paCO2:
	[
		cache		true,
		if_needed	new [paCO2_frame]
	],
	diagnosis:
	[
		multivalued	true,
		if_needed	[]
	],
	investigation:
	[
		if_new
		(		if	interpretation(ph) = low
				then	diagnosis has_value acidosis,

				if	interpretation(ph) = high
				then	diagnosis has_value alkalosis,

				if	interpretation(paCO2) = low
				then	diagnosis has_value hypocarbic,

				if	interpretation(paCO2) = high
				then 	diagnosis has_value hypercarbic,

				if 	acidosis in diagnosis
				and	interpretation('HCO3') = low
				then	diagnosis has_value primary_metabolic_acidosis
		)
	]
]!

current_date isa [] with
[
	year:	2013,
	month:	3,
	day:	17
]!

fred isa patient with [name: fred, occupation: lecturer]!
jim isa person with [name: jim]!
