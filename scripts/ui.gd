# ui.gd
# Attach to the root CanvasLayer of res://scenes/ui.tscn
#
# Responsibilities: display mass and upgrade buttons.
# NOTHING here mutates game state directly — it calls GameState and
# lets the signal update the display.  Keep it that way; it means
# you can reskin the UI entirely without touching game logic.
extends CanvasLayer

@onready var mass_label:   Label  = $Panel/MassLabel
@onready var spawn_button: Button = $Panel/SpawnButton
@onready var pull_button:  Button = $Panel/PullButton
@onready var multi_button: Button = $Panel/MultiButton

func _ready() -> void:
	spawn_button.pressed.connect(_buy_spawn)
	pull_button.pressed.connect(_buy_pull)
	multi_button.pressed.connect(_buy_multi)

	GameState.mass_changed.connect(_update_ui)
	_update_ui()

func _update_ui() -> void:
	mass_label.text = "Mass: %s" % snapped(GameState.mass, 0.1)

	_refresh_button(spawn_button, "Spawn Rate", "spawn")
	_refresh_button(pull_button,  "Pull Speed", "pull")
	_refresh_button(multi_button, "Mass Multi", "multi")

# Single helper so button text formatting lives in one place.
func _refresh_button(btn: Button, label: String, which: String) -> void:
	var level: int = GameState.levels[which]
	var cost: float = snapped(GameState.get_upgrade_cost(which), 0.1)
	btn.text   = "%s Lv%d  [%s]" % [label, level, cost]

func _buy_spawn() -> void: GameState.buy_upgrade("spawn")
func _buy_pull()  -> void: GameState.buy_upgrade("pull")
func _buy_multi() -> void: GameState.buy_upgrade("multi")
