# skill_data.gd
# Autoload singleton — Project > Autoloads as "SkillData"
extends Node

var SKILLS: Dictionary = {

	# ── PULL ─────────────────────────────────────────────────────────────────

	1: {
		"label":  "Passive Drag",
		"branch": "pull",
		"levels": [
			{ "effect": "spiral_rate", "value": 30.0,  "cost_energy": 10,   "unlock_mass": 0     },
			{ "effect": "spiral_rate", "value": 45.0,  "cost_energy": 25,   "unlock_mass": 50    },
			{ "effect": "spiral_rate", "value": 60.0,  "cost_energy": 60,   "unlock_mass": 200   },
			{ "effect": "spiral_rate", "value": 80.0,  "cost_energy": 120,  "unlock_mass": 500   },
		]
	},
	2: {
		"label":  "Hungry Void",
		"branch": "pull",
		"levels": [
			{ "effect": "pull_scale",  "value": 1.5,   "cost_energy": 20,   "unlock_mass": 30    },
			{ "effect": "pull_scale",  "value": 2.0,   "cost_energy": 50,   "unlock_mass": 150   },
			{ "effect": "pull_scale",  "value": 3.0,   "cost_energy": 100,  "unlock_mass": 400   },
			{ "effect": "pull_scale",  "value": 4.5,   "cost_energy": 200,  "unlock_mass": 1000  },
		]
	},
	3: {
		"label":  "Gravity Well",
		"branch": "pull",
		"levels": [
			{ "effect": "pull_radius", "value": 1.2,   "cost_energy": 30,   "unlock_mass": 80    },
			{ "effect": "pull_radius", "value": 1.5,   "cost_energy": 70,   "unlock_mass": 300   },
			{ "effect": "pull_radius", "value": 1.8,   "cost_energy": 140,  "unlock_mass": 700   },
			{ "effect": "pull_radius", "value": 2.2,   "cost_energy": 280,  "unlock_mass": 1500  },
		]
	},
	4: {
		"label":  "Event Horizon",
		"branch": "pull",
		"levels": [
			{ "effect": "lock_range",  "value": 1.0,   "cost_energy": 50,   "unlock_mass": 200   },
			{ "effect": "lock_range",  "value": 1.5,   "cost_energy": 100,  "unlock_mass": 600   },
			{ "effect": "lock_range",  "value": 2.0,   "cost_energy": 200,  "unlock_mass": 1200  },
			{ "effect": "lock_range",  "value": 2.5,   "cost_energy": 400,  "unlock_mass": 2500  },
		]
	},

	# ── FEAST ─────────────────────────────────────────────────────────────────

	5: {
		"label":  "Rapid Spawn",
		"branch": "feast",
		"levels": [
			{ "effect": "spawn_rate",  "value": 0.8,   "cost_energy": 15,   "unlock_mass": 100   },
			{ "effect": "spawn_rate",  "value": 0.65,  "cost_energy": 35,   "unlock_mass": 250   },
			{ "effect": "spawn_rate",  "value": 0.5,   "cost_energy": 80,   "unlock_mass": 600   },
			{ "effect": "spawn_rate",  "value": 0.35,  "cost_energy": 160,  "unlock_mass": 1500  },
		]
	},
	6: {
		"label":  "Dense Matter",
		"branch": "feast",
		"levels": [
			{ "effect": "mass_multi",  "value": 0.2,   "cost_energy": 20,   "unlock_mass": 120   },
			{ "effect": "mass_multi",  "value": 0.5,   "cost_energy": 45,   "unlock_mass": 350   },
			{ "effect": "mass_multi",  "value": 1.0,   "cost_energy": 90,   "unlock_mass": 800   },
			{ "effect": "mass_multi",  "value": 1.8,   "cost_energy": 180,  "unlock_mass": 2000  },
		]
	},
	7: {
		"label":  "Storm Surge",
		"branch": "feast",
		"levels": [
			{ "effect": "storm_interval", "value": 60.0,  "cost_energy": 40,  "unlock_mass": 300  },
			{ "effect": "storm_interval", "value": 45.0,  "cost_energy": 90,  "unlock_mass": 700  },
			{ "effect": "storm_interval", "value": 30.0,  "cost_energy": 180, "unlock_mass": 1500 },
			{ "effect": "storm_interval", "value": 15.0,  "cost_energy": 350, "unlock_mass": 3000 },
		]
	},
	8: {
		"label":  "Cascade",
		"branch": "feast",
		"levels": [
			{ "effect": "cascade_chance", "value": 0.15,  "cost_energy": 60,  "unlock_mass": 400  },
			{ "effect": "cascade_chance", "value": 0.30,  "cost_energy": 130, "unlock_mass": 900  },
			{ "effect": "cascade_chance", "value": 0.45,  "cost_energy": 260, "unlock_mass": 2000 },
			{ "effect": "cascade_chance", "value": 0.60,  "cost_energy": 500, "unlock_mass": 4500 },
		]
	},

	# ── SIGNAL ────────────────────────────────────────────────────────────────

	9: {
		"label":  "Impact Flash",
		"branch": "signal",
		"levels": [
			{ "effect": "flash_intensity", "value": 0.25,  "cost_energy": 30,  "unlock_mass": 500  },
			{ "effect": "flash_intensity", "value": 0.50,  "cost_energy": 70,  "unlock_mass": 1000 },
			{ "effect": "flash_intensity", "value": 0.75,  "cost_energy": 140, "unlock_mass": 2000 },
			{ "effect": "flash_intensity", "value": 1.0,   "cost_energy": 280, "unlock_mass": 4000 },
		]
	},
	10: {
		"label":  "Mass Numbers",
		"branch": "signal",
		"levels": [
			{ "effect": "float_numbers",  "value": 1.0,   "cost_energy": 25,  "unlock_mass": 500  },
			{ "effect": "float_numbers",  "value": 2.0,   "cost_energy": 55,  "unlock_mass": 1200 },
			{ "effect": "float_numbers",  "value": 3.0,   "cost_energy": 110, "unlock_mass": 2500 },
			{ "effect": "float_numbers",  "value": 4.0,   "cost_energy": 220, "unlock_mass": 5000 },
		]
	},
	11: {
		"label":  "Crit Absorption",
		"branch": "signal",
		"levels": [
			{ "effect": "crit_chance",    "value": 0.10,  "cost_energy": 50,  "unlock_mass": 600  },
			{ "effect": "crit_chance",    "value": 0.15,  "cost_energy": 110, "unlock_mass": 1500 },
			{ "effect": "crit_chance",    "value": 0.20,  "cost_energy": 220, "unlock_mass": 3000 },
			{ "effect": "crit_chance",    "value": 0.25,  "cost_energy": 440, "unlock_mass": 6000 },
		]
	},
	12: {
		"label":  "Combo Chain",
		"branch": "signal",
		"levels": [
			{ "effect": "combo_window",   "value": 2.0,   "cost_energy": 70,  "unlock_mass": 800  },
			{ "effect": "combo_window",   "value": 1.75,  "cost_energy": 150, "unlock_mass": 2000 },
			{ "effect": "combo_window",   "value": 1.5,   "cost_energy": 300, "unlock_mass": 4000 },
			{ "effect": "combo_window",   "value": 1.25,  "cost_energy": 600, "unlock_mass": 8000 },
		]
	},

	# ── ESCALATION ────────────────────────────────────────────────────────────

	13: {
		"label":  "Rare Objects",
		"branch": "escalation",
		"levels": [
			{ "effect": "rare_chance",    "value": 0.05,  "cost_energy": 100,  "unlock_mass": 2000  },
			{ "effect": "rare_chance",    "value": 0.10,  "cost_energy": 220,  "unlock_mass": 4000  },
			{ "effect": "rare_chance",    "value": 0.15,  "cost_energy": 440,  "unlock_mass": 8000  },
			{ "effect": "rare_chance",    "value": 0.20,  "cost_energy": 880,  "unlock_mass": 15000 },
		]
	},
	14: {
		"label":  "Gravity Storm",
		"branch": "escalation",
		"levels": [
			{ "effect": "gstorm_strength", "value": 1.5,  "cost_energy": 120,  "unlock_mass": 2500  },
			{ "effect": "gstorm_strength", "value": 2.5,  "cost_energy": 260,  "unlock_mass": 5000  },
			{ "effect": "gstorm_strength", "value": 4.0,  "cost_energy": 520,  "unlock_mass": 10000 },
			{ "effect": "gstorm_strength", "value": 6.0,  "cost_energy": 1000, "unlock_mass": 20000 },
		]
	},
	15: {
		"label":  "Singularity Pull",
		"branch": "escalation",
		"levels": [
			{ "effect": "sing_duration",  "value": 3.0,   "cost_energy": 150,  "unlock_mass": 3000  },
			{ "effect": "sing_duration",  "value": 5.0,   "cost_energy": 330,  "unlock_mass": 6000  },
			{ "effect": "sing_duration",  "value": 8.0,   "cost_energy": 660,  "unlock_mass": 12000 },
			{ "effect": "sing_duration",  "value": 12.0,  "cost_energy": 1300, "unlock_mass": 25000 },
		]
	},
	16: {
		"label":  "Collapse",
		"branch": "escalation",
		"levels": [
			{ "effect": "collapse_unlock", "value": 1.0,  "cost_energy": 0,    "unlock_mass": 50000 },
		]
	},
}

func get_level_data(id: int, level: int) -> Dictionary:
	var skill: Dictionary = SKILLS.get(id, {})
	var levels: Array = skill.get("levels", [])
	if level < 1 or level > levels.size():
		return {}
	return levels[level - 1]

func get_max_level(id: int) -> int:
	return SKILLS.get(id, {}).get("levels", []).size()

func get_all_ids() -> Array:
	return SKILLS.keys()

func get_skill(id: int) -> Dictionary:
	return SKILLS.get(id, {})
