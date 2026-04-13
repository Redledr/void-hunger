# ============================================================================
# BlackHole.gd - The Growing Black Hole
# ============================================================================
# What this does:
#   Visual representation of the black hole in the center of the game.
#   Grows larger as you collect mass across rounds.
#   Shows current stage and mass collected.
#
# How to use:
#   1. Add this scene to your GameWorld scene
#   2. Connect the EventBus mass_gained signal to update the black hole
#   3. The black hole will grow smoothly between stages
#
# Why this exists:
#   - Visual feedback for player progress
#   - Teaches that the black hole is "growing" as it consumes matter
#   - Placeholder for later stages (1-10)
# ============================================================================

class_name BlackHole
extends ColorRect

# =====---------------------------------------------------------------------
# Node References
# =====---------------------------------------------------------------------
# Labels inside the black hole scene
@onready var stage_label: Label = $StageLabel
@onready var mass_label: Label = $MassLabel

# =====---------------------------------------------------------------------
# Exported Variables (set in Inspector)
# =====---------------------------------------------------------------------
# Current growth stage (1-10). Higher = bigger black hole.
@export var black_hole_stage: int = 1
# Mass collected this round (resets each round)
@export var mass: float = 0

# =====---------------------------------------------------------------------
# Methods
# =====---------------------------------------------------------------------

# Called when the scene is ready
func _ready() -> void:
	# Connect to EventBus signal
	EventBus.mass_gained.connect(_on_mass_gained)
	EventBus.black_hole_stage_changed.connect(_on_stage_changed)

	# Initial update
	_update_display()

# =====---------------------------------------------------------------------
# Private Methods
# =====---------------------------------------------------------------------

# Handle mass being added to the black hole
func _on_mass_gained(amount: float) -> void:
	mass += amount
	_update_display()
	# Check if we should grow
	if GameState.check_growth():
		_on_stage_changed(GameState.get_black_hole_stage())

# Called when the black hole grows to a new stage
func _on_stage_changed(new_stage: int) -> void:
	black_hole_stage = new_stage
	_update_display()
	# In Phase 2, you'd add a tween to smoothly grow between stages

# Update all display elements based on current state
func _update_display() -> void:
	# Update mass label
	mass_label.text = "Mass: %d" % mass

	# Calculate scale based on stage (Stage 1 = smallest, Stage 10 = largest)
	# Base size is 64, max size is 256
	# Use a smooth transition: size = 64 + (stage - 1) * 20
	var target_size: int = 64 + (black_hole_stage - 1) * 20

	# Tween the size (smooth growth)
	# For Phase 1, we'll just set it directly
	custom_minimum_size.x = target_size
	custom_minimum_size.y = target_size

	# Update stage label (in a way that's safe for beginner to read)
	var stage_name = "Stage " + str(black_hole_stage)
	if black_hole_stage >= 8:
		stage_name = "Stage " + str(black_hole_stage) + " (Boss!)"
	stage_label.text = stage_name

	# Make the black hole darker as it grows (more ominous!)
	var darkness: float = 0.05 + (black_hole_stage - 1) * 0.025
	# Clamp between 0.05 (Stage 1) and 0.3 (Stage 10)
	if darkness > 0.3:
		darkness = 0.3
	color = Color(darkness, darkness, darkness * 1.5, 1)  # Slightly purple-tinted

# =====---------------------------------------------------------------------
# Signal Connections (for future expansion)
# =====---------------------------------------------------------------------
# When you add visual effects for stage growth:
# add_effects_on_grow.connect(_on_grow_effects)
# =====---------------------------------------------------------------------
