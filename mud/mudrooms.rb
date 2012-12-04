[
	{ 
		name: "Glade",
		descriptions:
		{
			see: "An open field with a grove of thick aspen trees to the southwest. The ankle-deep grass sways in a gentle breeze." + " The sun shines warmly.".bold,
			hear: "Birdsong echoes across the glade, oblivious of a low rumble in the distance.",
			smell: "The scent of damp earth and blooming flowers rides on the wind.",
			feel: "You sense tremors in the distance, low and constant.",
		},
		exits:
		{
			"West" => "Hell",
		},
	},
	{ 
		name: "Hell",
		descriptions:
		{
			see: "A blazing inferno".bold,
			feel: "You are on fire!".bold,
		},
		exits:
		{
			"South" => "Glade",
		},
	},
]