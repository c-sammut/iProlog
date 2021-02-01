person ako object with
	name:
		range		atom(new value)
		help		print("The name should be a string.")
		if_new		ask
		cache		yes;
	sex:
		range		new value in [male, female]
		help		print("Sex can only be male or female, not ", new value)
		if_needed	ask
		if_replaced	print("Are you sure you want a sex change?")
		if_removed	print("Are you sure you want the sex removed?")
		cache		yes;
	year_of_birth:
		range		year of current_date - 120 .. year of current_date
		help		print("Invalid year of birth.")
		if_needed	ask("Year of birth")
		cache		yes;
	age:
		cache		yes
		if_needed	year of current_date - year_of_birth of this person;
	parents:
		multivalued	yes
		range		new value must_be_a person
		help		print("The value in a parents slot must be a person.");
	height:
		range		10..220
		help		if new value < 10 then
					print(new value, "cm is too short."),
				if new value > 220 then
					print(new value, "cm is too tall."),
				print("The height should be between 10 and 220cm.")
		if_needed	ask("What is the height of ", name of this person);
	weight:
		range		1..150
		if_needed	ask("What is the weight of ", name of this person)
		cache		yes
		if_added	if new value > 100 then
					print("Your ", this slot, " is too high!");
	occupation:
		range		atom(new value)
		help		print("The occupation should be a string.")
		if_needed	ask("What is the occupation")
		cache		yes
		if_removed	print("I used to be a ", old value, ".")!


measure ako object with
	current_value:
		range		allowable_low of this measure .. allowable_high of this measure
		help		print("The patient is dead!")
		if_new		ask(prompt of this measure)
		cache		yes
		if_added	if	new value < expected_low of this measure then
					replace interpretation of this measure by low
				else if	new value > expected_high of this measure then
					replace interpretation of this measure by high
				else	replace interpretation of this measure by normal
		if_replaced	replace last_value of this measure by old value!


ph_frame ako measure with
	prompt:		default	"ph level";
	allowable_low:	default	6;
	allowable_high:	default	8;
	expected_high:	default	7.6;
	expected_low:	default	6.5!

'HCO3_frame' ako measure with
	prompt:		default	"HCO3 level";
	allowable_low:	default	6;
	allowable_high:	default	8;
	expected_high:	default	7.6;
	expected_low:	default	6.5!

paCO2_frame ako measure with
	prompt:		default	"paCO2 level";
	allowable_low:	default	6;
	allowable_high:	default	8;
	expected_high:	default	7.6;
	expected_low:	default	6.5!

patient ako person with
	ph:	
		cache		yes
		if_needed	make [ph_frame];
	'HCO3':	
		cache		yes
		if_needed	make ['HCO3_frame'];
	paCO2:
		cache		yes
		if_needed	make [paCO2_frame];
	diagnosis:
		multivalued	yes
		default		[];
	investigation:
		if_new		if	interpretation of ph of this patient = low
				then	add acidosis to diagnosis of this patient,

				if	interpretation of ph of this patient = high
				then	add alkalosis to diagnosis of this patient,

				if	interpretation of paCO2 of this patient = low
				then	add hypocarbic to diagnosis of this patient,

				if	interpretation of paCO2 of this patient = high
				then 	add hypercarbic to diagnosis of this patient,

				if 	acidosis in diagnosis of this patient
				and	interpretation of 'HCO3' of this patient = low
				then	add primary_metabolic_acidosis to diagnosis of this patient!

current_date isa object with
	year:	2001;
	month:	4;
	day:	1!
