extends Node2D

func _on_button_pressed():
	get_tree().change_scene_to_file("res://resources/levels/ingame/dungeon/Dungeon.tscn")

func _on_new_game_button_pressed() -> void:
	pass # Replace with function body.

func _on_continue_button_pressed() -> void:
	pass # Replace with function body.

func _on_tutorial_button_pressed() -> void:
	pass # Replace with function body.

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://resources/levels/menu/Credits.tscn")

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	get_tree().quit()
