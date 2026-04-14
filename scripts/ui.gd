extends CanvasLayer

var mass_label
var spawn_button
var pull_button
var multi_button

func _ready():
	var panel = VBoxContainer.new()
	panel.position = Vector2(10, 10)
	add_child(panel)

	mass_label = Label.new()
	mass_label.text = "Mass: 0"
	panel.add_child(mass_label)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	panel.add_child(spacer)

	spawn_button = Button.new()
	spawn_button.pressed.connect(_buy_spawn)
	panel.add_child(spawn_button)

	pull_button = Button.new()
	pull_button.pressed.connect(_buy_pull)
	panel.add_child(pull_button)

	multi_button = Button.new()
	multi_button.pressed.connect(_buy_multi)
	panel.add_child(multi_button)

	GameState.mass_changed.connect(_update_ui)
	_update_ui()

func _update_ui():
	mass_label.text = "Mass: " + str(snapped(GameState.mass, 0.1))

	spawn_button.text = "Spawn Rate Lv" + str(GameState.spawn_level) + "  [" + str(snapped(GameState.get_upgrade_cost("spawn"), 0.1)) + "]"
	pull_button.text = "Pull Speed Lv" + str(GameState.pull_level) + "  [" + str(snapped(GameState.get_upgrade_cost("pull"), 0.1)) + "]"
	multi_button.text = "Mass Multi Lv" + str(GameState.multi_level) + "  [" + str(snapped(GameState.get_upgrade_cost("multi"), 0.1)) + "]"

func _buy_spawn():
	GameState.buy_upgrade("spawn")

func _buy_pull():
	GameState.buy_upgrade("pull")

func _buy_multi():
	GameState.buy_upgrade("multi")
