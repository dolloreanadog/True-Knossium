extends Node2D

func _ready() -> void:
	Global.StartLoadingScreen(false)
	if !(SaveSystem.checkSaveFileExists()):
		print("Save File Doesn't Exist!")
		$VBoxContainer/ContinueButton.disabled = true
	else:
		SaveSystem.loadAllData()
		print("checking the save version")
		if SaveSystem.checkSaveVersion():
			$VBoxContainer/ContinueButton.disabled = false
		else:
			$VBoxContainer/ContinueButton.disabled = true
	
	if SettingsSystem.GetIsTutorialNeeded():
		$TutorialBoxContainer.show()
	$AudioStreamPlayer.play()
	Global.EndLoadingScreen()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.call_deferred("saveAllData")
		await Global.Saved

func _on_button_pressed():
	get_tree().change_scene_to_file("res://resources/levels/ingame/dungeon/Dungeon.tscn")

func _on_new_game_button_pressed() -> void:
	$Control.show()

func _on_continue_button_pressed() -> void:
	Global.newGameCharacterInfo.clear()
	Global.newGameInventoryInfo.clear()
	print("Pressed Continue Button")
	if SaveSystem.checkSaveFileExists():
		Global.StartLoadingScreen(true)
		print("Going to Dungeon")
		await create_tween().tween_property($AudioStreamPlayer, "volume_db", -80, 1).finished
		get_tree().change_scene_to_file("res://resources/levels/ingame/dungeon/Dungeon.tscn")
	else:
		push_error("There is no Save")

func _on_tutorial_button_pressed() -> void:
	SettingsSystem.SetIsTutorialNeeded(false)
	SettingsSystem.clearSettingsThroughDeletion()
	SettingsSystem.saveSettings()
	Global.StartLoadingScreen(true)
	await create_tween().tween_property($AudioStreamPlayer, "volume_db", -80, 1).finished
	get_tree().change_scene_to_file("res://resources/levels/ingame/tutorial_levels/CombatTutorialDungeon.tscn")

func _on_credits_button_pressed() -> void:
	Global.StartLoadingScreen(true)
	get_tree().change_scene_to_file("res://resources/levels/menu/Credits.tscn")

func _on_settings_button_pressed() -> void:
	Global.StartLoadingScreen(true)
	Global.previousScene = get_tree().get_current_scene().scene_file_path
	get_tree().change_scene_to_file("res://resources/user_interface/settings_menu/SettingsMenu.tscn")

func _on_exit_button_pressed() -> void:
	Global.call_deferred("saveAllData")
	@warning_ignore("redundant_await")
	var confirm: bool = await Global.saveAllData()
#	await Global.Saved
	if confirm:
		print("Saved")
		get_tree().quit()

func _on_new_game_yes_pressed() -> void:
	Global.StartLoadingScreen(true)
	SaveSystem.clearSaveThroughDeletion()
	Global.clearNewProgressThroughDeletion()
	Global.clearNewProgressionDict()
	await create_tween().tween_property($AudioStreamPlayer, "volume_db", -80, 1).finished
	get_tree().change_scene_to_file("res://resources/levels/menu/NewGameStartMenu/NewGameStartMenu.tscn")

func _on_new_game_no_pressed() -> void:
	$Control.hide()


func _on_clear_global_progression_pressed() -> void:
	$Control2.show()


func _on_clear_progression_yes_pressed() -> void:
	SaveSystem.clearSaveThroughDeletion()
	$VBoxContainer/ContinueButton.disabled = true
	Global.clearProgressThroughDeletion()
	Global.clearProgressionDict()
	$Control2.hide()


func _on_clear_progression_no_pressed() -> void:
	$Control2.hide()


func TutorialBoxNoButtonPressed() -> void:
	$TutorialBoxContainer.hide()
	print(SettingsSystem.SettingsDict)
	SettingsSystem.SetIsTutorialNeeded(false)
	SettingsSystem.clearSettingsThroughDeletion()
	SettingsSystem.saveSettings()
	print(SettingsSystem.SettingsDict)
