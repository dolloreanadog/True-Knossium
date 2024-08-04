extends Node

const filePathForSettingsData := "user://SettingsData.save"
const filePathForInputMapData := "user://InputMapData.save"
var gameSaveVersion: String = "0.87.2"

# 1920x1080 is L
# 1280x720 is T
# 1366x768 is S
# 2560 x 1440 is X
# 3840 x 2160 is XX
enum screenSize {T, S, L, X, XX, AUTOMATIC }
enum windowMode {FULLSCREEN, WINDOWED, BORDERLESSWINDOW}
enum language {ENGLISH, SIMPLECHINESE, JAPANESE, SPANISH, FRENCH}

var inputsLoaded: bool = false
#SettingsAOEMovement
# False = Click & Click
# Click & Click = Click & Drag

var SettingsDict: Dictionary = {
	"SettingsAOEMovement": false,
	"SettingsTranslation": language.ENGLISH,
	"SettingsScreenSize": screenSize.AUTOMATIC,
	"SettingsScreenDisplay": 0,
	"SettingsWindowedMode": windowMode.FULLSCREEN,
	"SettingsMasterVolume": 1.0,
	"SettingsMusicVolume": 0.25,
	"SettingsCharacterVolume": 1.0,
	"SettingsSFXVolume": 1.0,
	"SettingsVersion": gameSaveVersion,
	"ChosenAOEMovementYet": false,
	"IsTutorialNeeded": true,
}

var InputMapData: Dictionary

signal Saved
signal Loaded

#--[ Getters & Setters ]--
func getChosenAOEMovementYet() -> bool:
	return SettingsDict.ChosenAOEMovementYet
func setChosenAOEMovementYet(boolean: bool) -> void:
	SettingsDict.ChosenAOEMovementYet = boolean

func GetIsTutorialNeeded() -> bool:
	return SettingsDict.IsTutorialNeeded
func SetIsTutorialNeeded(boolean: bool) -> void:
	SettingsDict.IsTutorialNeeded = boolean


func getAOEMovement() -> bool:
	return SettingsDict.SettingsAOEMovement
func setAOEMovement(boolean: bool) -> void:
	SettingsDict.SettingsAOEMovement = boolean

func getTranslation() -> int:
	return SettingsDict.SettingsTranslation
func setTranslation(enumerator: language) -> void:
	SettingsDict.SettingsTranslation = enumerator

func getScreenSize() -> int:
	return SettingsDict.SettingsScreenSize
func setScreenSize(enumerator: screenSize) -> void:
	SettingsDict.SettingsScreenSize = enumerator

func getWindowedMode() -> int:
	return SettingsDict.SettingsWindowedMode
func setWindowedMode(enumerator: windowMode) -> void:
	SettingsDict.SettingsWindowedMode = enumerator

func getMasterVolume() -> float:
	return SettingsDict.SettingsMasterVolume
func setMasterVolume(Float: float) -> void:
	SettingsDict.SettingsMasterVolume = clampf(Float, 0, 1)

func getMusicVolume() -> float:
	return SettingsDict.SettingsMusicVolume
func setMusicVolume(Float: float) -> void:
	SettingsDict.SettingsMusicVolume = clampf(Float, 0, 1)

func getCharacterVolume() -> float:
	return SettingsDict.SettingsCharacterVolume
func setCharacterVolume(Float: float) -> void:
	SettingsDict.SettingsCharacterVolume = clampf(Float, 0, 1)

func getSFXVolume() -> float:
	return SettingsDict.SettingsSFXVolume
func setSFXVolume(Float: float) -> void:
	SettingsDict.SettingsSFXVolume = clampf(Float, 0, 1)

func SetScreenDisplay(value: int) -> void:
#	DisplayServer.window_get_current_screen(0)
	if !(value > DisplayServer.get_screen_count()):
		SettingsDict.SettingsScreenDisplay = value
	else:
		SettingsDict.SettingsScreenDisplay = 0
		push_error("Invalid Screen Display Input")

#--[ Functions ]--
func _ready() -> void:
	loadSettings()
	checkSettingsVersion()
	applySettings()
	
	for action in InputMap.get_actions():
		if InputMap.action_get_events(action).size() != 0:
			InputMapData[action] = InputMap.action_get_events(action)[0] 
	loadInputMapData()
	

func CenterWindow() -> void:
	var screen = DisplayServer.screen_get_size(0)
	get_window().position = (screen / 2) - get_window().size / 2

func resetSettings() -> void:
	setAOEMovement(true)
	setTranslation(language.ENGLISH)
	setScreenSize(screenSize.AUTOMATIC)
	setWindowedMode(windowMode.FULLSCREEN)
	setMasterVolume(1)
	setMusicVolume(0.25)
	setCharacterVolume(1)
	setSFXVolume(1)
	SettingsDict.SettingsVersion = gameSaveVersion
	SettingsDict.ChosenAOEMovementYet = true
	SetIsTutorialNeeded(true)
	SettingsDict.SettingsScreenDisplay = 0
	applySettings()

func clearSettingsThroughDeletion() -> void:
	if checkSettingsDataExists():
		DirAccess.remove_absolute("user://SettingsData.save")
#
func applySettings() -> void:
#	print("(check) " + str(InputMap.get_actions()))
	# For Testing
#	setKeybindThroughKey("ToggleVisibilityAOEEnemy", SettingsDict["ToggleVisibilityAOEEnemy"])
	
	await get_tree().create_timer(0.05).timeout
	match SettingsDict.SettingsWindowedMode:
		windowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		windowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		windowMode.BORDERLESSWINDOW:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
#			get_window().borderless = true
	
	await get_tree().create_timer(0.05).timeout
	match SettingsDict.SettingsScreenSize:
		screenSize.S:
			get_viewport().size = Vector2(1366, 768)
			if getWindowedMode() == windowMode.WINDOWED or getWindowedMode() == windowMode.BORDERLESSWINDOW:
				print("(check) Screen Size: "+ str(SettingsDict.SettingsWindowedMode))
				@warning_ignore("integer_division")
				CenterWindow()
		screenSize.T:
			get_viewport().size = Vector2(1280, 720)
			if getWindowedMode() == windowMode.WINDOWED or getWindowedMode() == windowMode.BORDERLESSWINDOW:
				print("(check) Screen Size: "+ str(SettingsDict.SettingsWindowedMode))
				@warning_ignore("integer_division")
				CenterWindow()
		screenSize.L:
			get_viewport().size = Vector2(1920, 1080)
			if getWindowedMode() == windowMode.WINDOWED or getWindowedMode() == windowMode.BORDERLESSWINDOW:
				print("(check) Screen Size: "+ str(SettingsDict.SettingsWindowedMode))
				@warning_ignore("integer_division")
				CenterWindow()
		screenSize.X:
			get_viewport().size = Vector2(2560, 1440)
			if getWindowedMode() == windowMode.WINDOWED or getWindowedMode() == windowMode.BORDERLESSWINDOW:
				print("(check) Screen Size: "+ str(SettingsDict.SettingsWindowedMode))
				@warning_ignore("integer_division")
				CenterWindow()
		screenSize.XX:
			get_viewport().size = Vector2(3840, 2160)
			if getWindowedMode() == windowMode.WINDOWED or getWindowedMode() == windowMode.BORDERLESSWINDOW:
				print("(check) Screen Size: "+ str(SettingsDict.SettingsWindowedMode))
				@warning_ignore("integer_division")
				CenterWindow()
		screenSize.AUTOMATIC:
			print("(check) Screen Size: "+ str(DisplayServer.screen_get_size()))
			get_viewport().size = DisplayServer.screen_get_size(0)
			get_window().position = Vector2i(0, 0)
	
	DisplayServer.window_set_current_screen(SettingsDict.SettingsScreenDisplay, 0)
	
	AudioServer.set_bus_volume_db(0, linear_to_db(SettingsDict.SettingsMasterVolume))
	AudioServer.set_bus_volume_db(1, linear_to_db(SettingsDict.SettingsMusicVolume))
	AudioServer.set_bus_volume_db(2, linear_to_db(SettingsDict.SettingsCharacterVolume))
	AudioServer.set_bus_volume_db(3, linear_to_db(SettingsDict.SettingsSFXVolume))
	print("Settings " + str(AudioServer.get_bus_volume_db(0)))
	print("Settings " + str(AudioServer.get_bus_volume_db(1)))
	# Something to change localization

func saveInputMapData() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForInputMapData, FileAccess.WRITE, "Platy1ium")
#	print("(check) Input Map Data" + str(InputMapData))
	file.store_var(InputMapData, true)
	file.close()
	
	for action in InputMapData.keys():
#		print("(check) Saved Input Map InputEventKey Object: " + str(InputMapData.find_key(InputMapData[action])))
#		print("(check) Saved Input Map InputEventKey Object: " + str(InputMapData[action]))
#		print("(check) Loaded Input Map InputEventKey ID: " + str(InputMapData[action].object_id))
		await get_tree().create_timer(0.01).timeout

func loadInputMapData() -> void:
	if !(FileAccess.file_exists(filePathForInputMapData)):
		saveInputMapData()
	else:
		var file := FileAccess.open_encrypted_with_pass(filePathForInputMapData, FileAccess.READ, "Platy1ium")  
		var tempMap = file.get_var(true) as Dictionary
		file.close()
		
#		print("(check) Loaded Input Map Data: " + str(tempMap))
		await get_tree().create_timer(0.25).timeout
		for action in InputMapData.keys():
			if tempMap.has(action):
				InputMapData[action] = tempMap[action]
				
#				print("(check) Loaded Input Map Action Object: " + str(InputMapData[action]))
#				print("(check) Loaded Input Map InputEventKey Object: " + str(InputMapData.find_key(InputMapData[action])))
#				print("(check) Loaded Input Map InputEventKey Object: " + str(InputMapData[action]))
#				print("(check) Loaded Input Map InputEventKey ID: " + str(InputMapData[action].object_id))
#				var event = instance_from_id(InputMapData[action].object_id)
				var event = InputMapData[action]
#				print("(check) Loaded Input Map InputEventKey Instanced: " + str(event))
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)
				await get_tree().create_timer(0.01).timeout
	

func saveSettings() -> bool:
	SettingsDict.SettingsVersion = gameSaveVersion
	var file := FileAccess.open_encrypted_with_pass(filePathForSettingsData, FileAccess.WRITE, "Platy1ium")
	file.store_var(SettingsDict)
	file.close()
	emit_signal("Saved")
	return true

func loadSettings() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForSettingsData, FileAccess.READ, "Platy1ium") 
	if checkSettingsDataExists():
		print("Settings Data Exists!")
		SettingsDict = file.get_var()
		print(SettingsDict)
		emit_signal("Loaded")
	else:
		get_tree().change_scene_to_file("res://resources/levels/menu/ChooseAOESettingsMenu/ChooseAOESettingsMenu.tscn")
		print("Settings Data Doesn't Exists!")
	inputsLoaded = true


func checkSettingsDataExists() -> bool:
	if FileAccess.file_exists(filePathForSettingsData):
		return true
	else:
		return false

func checkSettingsVersion() -> bool:
	if SettingsDict.find_key("SettingsVersion") != "":
		if SettingsDict.SettingsVersion != gameSaveVersion:
			push_error("Incompatible Settings Version, Current is " + str(gameSaveVersion) + ", Your Version is " + str(SettingsDict.SettingsVersion))
			resetSettings()
			return false
		else:
			print("Correct Settings Version")
			return true
	else:
		push_error("The Key SettingsVersion doesn't exist")
		SettingsDict.SettingsVersion = gameSaveVersion
		resetSettings()
		saveSettings()
		print("Settings Version: " + SettingsDict.SettingsVersion)
		return false
