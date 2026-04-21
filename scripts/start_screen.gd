extends Control

@onready var continue_button: Button = $VBox/ContinueButton
@onready var save_info_label: Label  = $VBox/SaveInfoLabel

func _ready() -> void:
	_refresh_save_state()

func _refresh_save_state() -> void:
	var save_exists := FileAccess.file_exists(GameState.SAVE_PATH)
	continue_button.disabled = not save_exists

	if save_exists:
		# Load just enough to show info without fully loading into GameState.
		var cfg := ConfigFile.new()
		cfg.load(GameState.SAVE_PATH)
		var mass    := float(cfg.get_value("game", "mass",   0.0))
		var energy  := float(cfg.get_value("game", "energy", 0.0))
		var elapsed := float(cfg.get_value("game", "elapsed_time", 0.0))
		var mins    := int(elapsed / 60)
		var secs    := int(elapsed) % 60
		save_info_label.text = "Save found — Mass: %.0f  Energy: %.0f  Time: %02d:%02d" \
			% [mass, energy, mins, secs]
	else:
		save_info_label.text = "No save found."

func _on_new_button_pressed() -> void:
	GameState.delete_save()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_continue_button_pressed() -> void:
	GameState.load_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_settings_button_pressed() -> void:
	pass  # hook up later

func _on_exit_button_pressed() -> void:
	GameState.save_game()
	get_tree().quit()
