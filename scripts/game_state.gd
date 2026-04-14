extends Node

var mass = 0.0
var spawn_level = 0
var pull_level = 0
var multi_level = 0

signal mass_changed

func add_mass(amount):
	mass += amount
	emit_signal("mass_changed")

func get_spawn_interval():
	return max(0.3, 2.0 - spawn_level * 0.15)

func get_pull_speed():
	return 60.0 + pull_level * 20.0

func get_mass_multiplier():
	return 1.0 + multi_level * 0.25

func get_upgrade_cost(which):
	var base_costs = {"spawn": 10.0, "pull": 15.0, "multi": 25.0}
	var level = get(which + "_level")
	return base_costs[which] * pow(1.15, level)

func buy_upgrade(which):
	var cost = get_upgrade_cost(which)
	if mass >= cost:
		mass -= cost
		set(which + "_level", get(which + "_level") + 1)
		emit_signal("mass_changed")
		return true
	return false
