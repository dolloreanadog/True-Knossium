extends Control
class_name IngameMenu
@onready var dungeon: levelDungeon = get_parent()
@onready var settingsMenu := dungeon.get_node("SettingsMenu")


func _on_back_to_game_button_pressed() -> void:
	dungeon.stopControl.hide()
	self.hide()


func _on_settings_button_pressed() -> void:
	settingsMenu.show()


func _on_save_button_pressed() -> void:
	dungeon.saveToSaveSystem()


func _on_go_to_menu_button_pressed() -> void:
	dungeon.saveToSaveSystem()
	await SaveSystem.Saved
#	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://resources/levels/MainMenu.tscn")


func _on_quit_game_button_pressed() -> void:
	dungeon.saveToSaveSystem()
	await SaveSystem.Saved
#	await get_tree().create_timer(3).timeout
	get_tree().quit()


func _on_end_game_button_pressed() -> void:
	dungeon.get_node("StopControl").show()
	dungeon.saveToSaveSystem()
	await SaveSystem.Saved
#	await get_tree().create_timer(3).timeout
	dungeon.queue_free()
	get_tree().change_scene_to_file("res://resources/levels/menu/GameOverMenu/GameOverMenu.tscn")
