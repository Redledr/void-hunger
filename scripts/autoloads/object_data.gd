# object_data.gd
# Autoload (singleton) — add to Project > Autoloads as "ObjectData"
#
# Centralises all spawnable-object definitions so every script
# that needs them reads from one place instead of carrying a
# personal copy of the full dictionary.
extends Node

const DATA: Dictionary = {
	# --- Subatomic ---
	"quark":      { "mass": 0.1,         "color": Color(0.55, 0.55, 0.95), "size": 1  },
	"electron":   { "mass": 0.12,        "color": Color(0.60, 0.60, 1.00), "size": 2  },
	"proton":     { "mass": 0.15,        "color": Color(0.70, 0.65, 1.00), "size": 3  },
	"neutron":    { "mass": 0.18,        "color": Color(0.75, 0.70, 1.00), "size": 4  },

	# --- Atomic / molecular ---
	"dust":       { "mass": 0.3,         "color": Color(0.65, 0.62, 0.55), "size": 5  },
	"atom":       { "mass": 0.5,         "color": Color(0.50, 0.80, 1.00), "size": 6  },
	"molecule":   { "mass": 0.9,         "color": Color(0.40, 0.75, 0.95), "size": 7  },
	"cells":      { "mass": 1.2,         "color": Color(0.30, 0.70, 0.85), "size": 8  },
	"bacterium":  { "mass": 1.5,         "color": Color(0.30, 0.65, 0.75), "size": 8  },
	"virus":      { "mass": 2.0,         "color": Color(0.35, 0.60, 0.80), "size": 9  },

	# --- Geological ---
	"sand":       { "mass": 3.0,         "color": Color(0.76, 0.70, 0.55), "size": 10  },
	"pebbles":    { "mass": 6.0,         "color": Color(0.62, 0.58, 0.50), "size": 11 },
	"rocks":      { "mass": 12.0,        "color": Color(0.48, 0.48, 0.52), "size": 12  },
	"boulders":   { "mass": 25.0,        "color": Color(0.38, 0.38, 0.42), "size": 13 },
	"mountains":  { "mass": 60.0,        "color": Color(0.30, 0.30, 0.35), "size": 14 },

	# --- Planetary ---
	"asteroid":   { "mass": 120.0,       "color": Color(0.65, 0.52, 0.42), "size": 15 },
	"planet":     { "mass": 500.0,       "color": Color(0.25, 0.55, 0.95), "size": 18 },

	# --- Stellar ---
	"dwarfstar":  { "mass": 2500.0,      "color": Color(1.0,  0.95, 0.6),  "size": 22 },
	"star":       { "mass": 5000.0,      "color": Color(1.0,  0.85, 0.3),  "size": 24 },
	"redgiant":   { "mass": 12000.0,     "color": Color(1.0,  0.45, 0.15), "size": 28 },
	"neutron_star":{ "mass": 30000.0,    "color": Color(0.9,  0.3,  1.0),  "size": 30 },

	# --- Galactic ---
	"starcluster":     { "mass": 80000.0,    "color": Color(1.0,  0.9,  0.5),  "size": 32 },
	"nebula":          { "mass": 150000.0,   "color": Color(0.7,  0.4,  1.0),  "size": 34 },
	"galaxy":          { "mass": 800000.0,   "color": Color(0.55, 0.25, 1.0),  "size": 40 },
	"galaxycluster":   { "mass": 5000000.0,  "color": Color(1.0,  0.45, 0.75), "size": 46 },
	"supercluster":    { "mass": 20000000.0, "color": Color(0.85, 0.6,  1.0),  "size": 52 },

	# --- Endgame ---
	"observableuniversefragment": { "mass": 100000000.0,  "color": Color(0.85, 0.85, 1.0), "size": 60 },
	"observableuniverse":         { "mass": 500000000.0,  "color": Color(1.0,  1.0,  1.0),  "size": 68 },
	"multiverse":                 { "mass": 5000000000.0, "color": Color(1.0,  0.98, 0.9),  "size": 80 },
}

# Returns the data dict for a type, or an empty dict if not found.
# Callers should always check the result before using it.
func get_data(type: String) -> Dictionary:
	return DATA.get(type, {})
