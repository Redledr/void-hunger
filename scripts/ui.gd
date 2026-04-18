extends CanvasLayer

@onready var mass_label:        Label  = $Panel/VBox/MassLabel
@onready var energy_label:      Label  = $Panel/VBox/EnergyLabel
@onready var skill_tree_button: Button = $Panel/VBox/SkillTreeButton

@onready var skill_tree = $"../SkillTree"

func _ready() -> void:
	skill_tree_button.pressed.connect(_open_skill_tree)
	GameState.mass_changed.connect(_update_ui)
	GameState.energy_changed.connect(_update_ui)
	_update_ui()

func _update_ui() -> void:
	mass_label.text   = "Mass: %s"   % snapped(GameState.mass,   0.1)
	energy_label.text = "Energy: %s" % snapped(GameState.energy, 0.1)

func _open_skill_tree() -> void:
	skill_tree.show_tree()
