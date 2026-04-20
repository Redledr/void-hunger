extends Control

func _on_new_button_pressed() -> void:
	GameState.delete_save()
	print("Deleted Save")
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_continue_button_pressed() -> void:
	GameState.load_game()
	print("Game Loaded")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_load_button_pressed() -> void:
	GameState.load_game()
	print("Game Loaded")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/main.tscn")
	pass

func _on_exit_button_pressed() -> void:
	GameState.save_game()
	print("Saved Game")
	get_tree().quit()
	print("Exited")
