# ============================================================================
# HUD.gd - Heads-Up Display
# ============================================================================
# What this does:
#   Displays the currency counter in the top-left corner of the screen.
#   Updates automatically whenever currency changes (via EventBus signal).
#
# How to use:
#   1. Add this scene to your main game scene (Main.tscn or GameWorld.tscn)
#   2. The currency will automatically update when objects are destroyed
#   3. No need to manually connect signals - HUD listens to EventBus
#
# Why this exists:
#   - Keeps UI code separate from game logic
#   - Uses EventBus so any scene can update the HUD
#   - Simple, readable interface
# ============================================================================

class_name HUD
extends CanvasLayer

# =====---------------------------------------------------------------------
# Node References
# =====---------------------------------------------------------------------
# These nodes are referenced by name in the scene file
@onready var currency_label: Label = $CurrencyLabel
@onready var background: ColorRect = $Background

# =====---------------------------------------------------------------------
# Methods
# =====---------------------------------------------------------------------

# Called when the scene is added to the scene tree
func _ready() -> void:
	# Connect to EventBus signal - this updates the display automatically
	EventBus.currency_changed.connect(_on_currency_changed)

	# Initial update
	_update_currency_display()

# =====---------------------------------------------------------------------
# Private Methods
# =====---------------------------------------------------------------------

# Called whenever currency changes (via EventBus signal)
func _on_currency_changed(new_total: int) -> void:
	_update_currency_display()

# Format and display the currency amount
func _update_currency_display() -> void:
	# Replace %d with the actual currency value
	currency_label.text = "Currency: %d" % GameState.get_currency()
	# No animation needed for Phase 1, but you could add tween later

# =====---------------------------------------------------------------------
# Signal Connections (for future expansion)
# =====---------------------------------------------------------------------
# When you add mass progress bar, add this signal:
# EventBus.mass_gained.connect(_on_mass_gained)
#
# When you add round timer, add this signal:
# EventBus.round_started.connect(_on_round_started)
# =====---------------------------------------------------------------------
