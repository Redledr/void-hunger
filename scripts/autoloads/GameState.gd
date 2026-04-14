# GameState.gd - Autoload singleton
# Register in Project > Project Settings > Autoload as "GameState"

extends Node

# -------------------------------------------------------
# Persistent Data
# -------------------------------------------------------

var currency: int = 0
var black_hole_stage: int = 1
var mass: float = 0.0
var total_mass_threshold: float = 100.0

# -------------------------------------------------------
# Round Data
# -------------------------------------------------------

var round_number: int = 1
var round_currency: int = 0
var mass_per_object: float = 5.0

# -------------------------------------------------------
# Methods
# -------------------------------------------------------

func add_currency(amount: int) -> void:
	currency += amount
	EventBus.currency_changed.emit(currency)

func add_mass(amount: float) -> void:
	mass += amount

func check_growth() -> bool:
	if mass >= total_mass_threshold:
		black_hole_stage += 1
		total_mass_threshold *= 1.5
		return true
	return false

func add_round_currency(amount: int) -> int:
	round_currency += amount
	return round_currency

func reset_round() -> void:
	mass = 0.0
	round_currency = 0
	round_number += 1

# -------------------------------------------------------
# Getters
# -------------------------------------------------------

func get_currency() -> int: return currency
func get_mass() -> float: return mass
func get_black_hole_stage() -> int: return black_hole_stage
func get_total_mass_threshold() -> float: return total_mass_threshold
func get_round_currency() -> int: return round_currency
func get_round_number() -> int: return round_number

# -------------------------------------------------------
# Init
# -------------------------------------------------------

func _ready() -> void:
	print("GameState initialized. Currency: %d | Round: %d" % [currency, round_number])
