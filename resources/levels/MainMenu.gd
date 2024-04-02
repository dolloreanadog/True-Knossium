extends Node2D

func _ready() -> void:
	$VBoxContainer/TutorialButton.disabled = true
	if !(SaveSystem.checkSaveFileExists()):
		$VBoxContainer/ContinueButton.disabled = true
	else:
		$VBoxContainer/ContinueButton.disabled = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.saveAllData()
		await Global.saved

func _on_button_pressed():
	get_tree().change_scene_to_file("res://resources/levels/ingame/dungeon/Dungeon.tscn")

func _on_new_game_button_pressed() -> void:
	$Control.show()

func _on_continue_button_pressed() -> void:
	Global.newGameCharacterInfo.clear()
	Global.newGameInventoryInfo.clear()
	print("Pressed Continue Button")
	if SaveSystem.checkSaveFileExists():
		print("Going to Dungeon")
		get_tree().change_scene_to_file("res://resources/levels/ingame/dungeon/Dungeon.tscn")
	else:
		push_error("There is no Save")

func _on_tutorial_button_pressed() -> void:
	pass

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://resources/levels/menu/Credits.tscn")

func _on_settings_button_pressed() -> void:
	$SettingsMenu.show()

func _on_exit_button_pressed() -> void:
	Global.saveAllData()
	await Global.saved
	get_tree().quit()

func _on_new_game_yes_pressed() -> void:
	SaveSystem.clearSaveThroughDeletion()
	get_tree().change_scene_to_file("res://resources/levels/menu/NewGameStartMenu/NewGameStartMenu.tscn")

func _on_new_game_no_pressed() -> void:
	$Control.hide()


func _on_clear_global_progression_pressed() -> void:
	$Control2.show()


func _on_clear_progression_yes_pressed() -> void:
	Global.clearProgressThroughDeletion()
	Global.clearProgressionDict()
	$Control2.hide()


func _on_clear_progression_no_pressed() -> void:
	$Control2.hide()
