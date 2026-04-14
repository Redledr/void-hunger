# ============================================================================
# UpgradeShop.gd - Between-Round Upgrade Screen
# ============================================================================
# What this does:
#   1. Shows currency and upgrades between rounds
#   2. "Next Round" button restarts the round
#
# How to use:
#   1. Main.gd calls game_world.queue_free() when round ends
#   2. Main.gd shows this scene using get_tree().change_scene_to_file()
#
# Why this exists:
#   - Separates round gameplay from upgrade UI
#   - Clean transition between phases of the game
# ============================================================================

class_name UpgradeShop
extends CanvasLayer

# =====---------------------------------------------------------------------
# Node References
# =====---------------------------------------------------------------------
@onready var next_round_button: Button = $NextRoundButton
@onready var currency_display: Label = $CurrencyDisplay

# =====---------------------------------------------------------------------
# Methods
# =====---------------------------------------------------------------------

# Called when the scene is ready
func _ready() -> void:
	# Connect button
	next_round_button.pressed.connect(_on_next_round_pressed)

	# Update currency display
	_update_currency_display()

# =====---------------------------------------------------------------------
# Signal Connections
# =====---------------------------------------------------------------------
# Update currency when it changes (from GameState signal)
EventBus.currency_changed.connect(_on_currency_changed)

# =====---------------------------------------------------------------------
# Called when "Next Round" button is pressed
# =====---------------------------------------------------------------------
func _on_next_round_pressed() -> void:
	# Hide this scene
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

	# The Main scene will load and start a new round
	print("Starting new round...")

# =====---------------------------------------------------------------------
# Update currency display
# =====---------------------------------------------------------------------
func _update_currency_display() -> void:
	currency_display.text = "Currency: %d" % GameState.get_currency()

func _on_currency_changed(_new_total: int) -> void:
	_update_currency_display()

# =====---------------------------------------------------------------------
# Exposed function for Main.gd to call before showing this scene
# =====---------------------------------------------------------------------
func update_currency_display() -> void:
	_update_currency_display()
