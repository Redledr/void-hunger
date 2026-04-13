# ============================================================================
# GameState.gd - Persistent Game Data
# ============================================================================
# What this does:
#   This script holds all game data that persists across rounds.
#   When the game loads, it automatically starts with default values.
#   You can add your own data (like player names) in the _ready() method.
#
# Key concepts:
#   - "Persistent" = saved data that doesn't reset between rounds
#   - "Round" = one play session (30 seconds by default)
#
# How to use:
#   # Read data:
#   var my_currency = GameState.currency
#   var my_stage = GameState.black_hole_stage
#
#   # Write data (call via static method):
#   GameState.add_currency(10)
#
# Why this exists:
#   - Keeps all scenes from directly modifying each other's data
#   - Central place for save/load functionality later
# ============================================================================

extends NodeName

# The node name must be "GameState" to work as an Autoload
name = "GameState"

# =====---------------------------------------------------------------------
# Persistent Data (these survive rounds and game restarts)
# =====---------------------------------------------------------------------

# Currency: Total currency earned across all rounds
# You can spend this on upgrades between rounds
@export_group("Persistent Data - Survives Round End")
var currency: int = 0

# Black hole stage: Which growth stage the black hole is on (1-10)
# Higher stages mean larger black hole and more powerful effects
@export_range(1, 10):
var black_hole_stage: int = 1

# Mass earned this round: Used to determine black hole growth
# Resets to 0 at the start of each round
@export:
var mass: float = 0

# Mass thresholds for each stage: How much total mass needed to grow
# Stage 1 = threshold 0 (starting size)
# Stage 2 = threshold 100, etc.
# This is persistent - grows forever
@export:
var total_mass_threshold: float = 100.0

# =====---------------------------------------------------------------------
# Round Data (resets every round)
# =====---------------------------------------------------------------------

# Current round number
@export:
var round_number: int = 1

# Currency earned in the current round
# This resets to 0 each round and doesn't add to persistent currency
@export:
var round_currency: int = 0

# Mass per asteroid (tunable value)
@export:
var mass_per_object: float = 5.0

# =====---------------------------------------------------------------------
# Methods (functions you call from other scenes)
# =====---------------------------------------------------------------------

# Add currency to persistent total
# Also emits signal so HUD can update
func add_currency(amount: int) -> void:
	currency += amount
	EventBus.currency_changed.emit(currency)

# Add mass for black hole growth tracking
func add_mass(amount: float) -> void:
	mass += amount

# Check if we should grow the black hole
# Returns true if threshold was reached
func check_growth() -> bool:
	if total_mass_threshold < mass:
		# Grow to next stage
		black_hole_stage += 1
		total_mass_threshold *= 1.5  # Thresholds: 100, 150, 225, etc.
		return true
	return false

# Add currency to round currency (for tracking earnings this round)
func add_round_currency(amount: int) -> void:
	round_currency += amount
	return round_currency

# Reset round data (called at start of new round)
func reset_round() -> void:
	mass = 0
	round_currency = 0
	round_number += 1

# Getters for easy access from other scenes
func get_currency() -> int:
	return currency

func get_mass() -> float:
	return mass

func get_black_hole_stage() -> int:
	return black_hole_stage

func get_total_mass_threshold() -> float:
	return total_mass_threshold

func get_round_currency() -> int:
	return round_currency

func get_round_number() -> int:
	return round_number

# =====---------------------------------------------------------------------
# Override _ready() - runs once when scene loads
# =====---------------------------------------------------------------------
func _ready() -> void:
	# Add any default values or initialization here
	# Example: Load saved game if it exists
	print("GameState initialized. Currency:", currency, "Round:", round_number)
