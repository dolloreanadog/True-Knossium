extends Control
class_name IngameMenu
@onready var dungeon: BaseLevel = get_parent()

# Confirmation Window
enum confirmationType {QUITTODESKTOP, QUITTOMENU, ENDGAME}
var confirmType: confirmationType
@onready var confirmationBox: ConfirmationBox = get_node("ConfirmationControl")


func _on_back_to_game_button_pressed() -> void:
	if !(dungeon.isCharactersActive) && dungeon.specialWindowContainer.get_child_count() == 0 && dungeon.difficulty.isCharactersSpawningIn != true && dungeon.knossiumConsole.visible == false:
		dungeon.stopControlVisible(false, 1)
		dungeon.stopControlVisible(false, 2)
#	dungeon.stopControl.hide()
	self.hide()
#	dungeon.checkSpecialWindowContainer()


func _on_settings_button_pressed() -> void:
	Global.StartLoadingScreen(true)
	Global.previousScene = get_tree().get_current_scene().scene_file_path
	dungeon.saveToSaveSystem()
	var confirm: bool = await dungeon.saveConfirmation()
	if confirm:
		get_tree().change_scene_to_file("res://resources/user_interface/settings_menu/SettingsMenu.tscn")


func _on_save_button_pressed() -> void:
	dungeon.saveToSaveSystem()

# Sometimes friendly characters are not saved?
# on like the second time you go into menu characters are not saved!
func _on_go_to_menu_button_pressed() -> void:
	confirmType = confirmationType.QUITTOMENU
	confirmationBox.show()
	confirmationBox.setLabel("Are you sure you want to go to menu?")


# ^ issue as above
func _on_quit_game_button_pressed() -> void:
	confirmType = confirmationType.QUITTODESKTOP
	confirmationBox.show()
	confirmationBox.setLabel("Are you sure you want to go to desktop?")



func _on_end_game_button_pressed() -> void:
	confirmType = confirmationType.ENDGAME
	confirmationBox.show()
	confirmationBox.setLabel("Are you sure you want to end the game?")



func ConfirmationYesButtonPressed() -> void:
	Global.StartLoadingScreen(true)
	dungeon.saveToSaveSystem()
	var confirm: bool = await dungeon.saveConfirmation()
	if confirm:
		match confirmType:
			confirmationType.QUITTODESKTOP:
				get_tree().quit()
			confirmationType.QUITTOMENU:
				get_tree().change_scene_to_file("res://resources/levels/MainMenu.tscn")
			confirmationType.ENDGAME:
				dungeon.stopControlVisible(true, 1)
				dungeon.queue_free()
				get_tree().change_scene_to_file("res://resources/levels/menu/GameOverMenu/GameOverMenu.tscn")
	
	confirmationBox.hide()


func ConfirmationNoButtonPressed() -> void:
	confirmationBox.hide()
