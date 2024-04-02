extends Node

var filePathForSettingsData := "user://SettingsData.save"

# 1920x1080 is L
# 1280x720 is T
# 1366x768 is S
# 2560 x 1440 is X
# 3840 x 2160 is XX
enum screenSize {T, S, L, X, XX, AUTOMATIC }
enum windowMode {FULLSCREEN, WINDOWED, BORDERLESSFULLSCREEN, BORDERLESSWINDOW}
enum language {ENGLISH, SIMPLECHINESE, JAPANESE, SPANISH, FRENCH}

#SettingsAOEMovement
# False = Click & Click
# Click & Click = Click & Drag

var SettingsDict: Dictionary = {
	"SettingsAOEMovement": false,
	"SettingsTranslation": language.ENGLISH,
	"SettingsScreenSize": screenSize.L,
	"SettingsWindowedMode": windowMode.FULLSCREEN,
	"SettingsMasterVolume": 100,
	"SettingsMusicVolume": 100,
	"SettingsCharacterVolume": 100,
	"SettingsSFXVolume": 100,
}

signal Saved
signal Loaded

#--[ Getters & Setters ]--
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

func getMasterVolume() -> int:
	return SettingsDict.SettingsMasterVolume
func setMasterVolume(integer: int) -> void:
	SettingsDict.SettingsMasterVolume = clampi(integer, 0, 100)

func getMusicVolume() -> int:
	return SettingsDict.SettingsMusicVolume
func setMusicVolume(integer: int) -> void:
	SettingsDict.SettingsMusicVolume = clampi(integer, 0, 100)

func getCharacterVolume() -> int:
	return SettingsDict.SettingsCharacterVolume
func setCharacterVolume(integer: int) -> void:
	SettingsDict.SettingsCharacterVolume = clampi(integer, 0, 100)

func getSFXVolume() -> int:
	return SettingsDict.SettingsSFXVolume
func setSFXVolume(integer: int) -> void:
	SettingsDict.SettingsSFXVolume = clampi(integer, 0, 100)

#--[ Functions ]--
func _ready() -> void:
	loadSettings()
	applySettings()

func resetSettings() -> void:
	setAOEMovement(true)
	setTranslation(language.ENGLISH)
	setScreenSize(screenSize.T)
	setWindowedMode(windowMode.WINDOWED)
	setMasterVolume(100)
	setMusicVolume(100)
	setCharacterVolume(100)
	setSFXVolume(100)
	applySettings()

func clearSettingsThroughDeletion() -> void:
	if checkSettingsDataExists():
		DirAccess.remove_absolute("user://SettingsData.save")

func applySettings() -> void:
	
	match SettingsDict.SettingsWindowedMode:
		windowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			get_window().borderless = false
		windowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().borderless = false
		windowMode.BORDERLESSWINDOW:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().borderless = true
		windowMode.BORDERLESSFULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			get_window().borderless = true
	
	match SettingsDict.SettingsScreenSize:
		screenSize.S:
			get_viewport().size = Vector2(1366, 768)
		screenSize.T:
			get_viewport().size = Vector2(1280, 720)
			if getWindowedMode() == windowMode.WINDOWED:
				@warning_ignore("integer_division")
				get_window().position = Vector2i(DisplayServer.screen_get_size().x / 5, DisplayServer.screen_get_size().y / 5)
		screenSize.L:
			get_viewport().size = Vector2(1920, 1080)
		screenSize.X:
			get_viewport().size = Vector2(2560, 1440)
		screenSize.XX:
			get_viewport().size = Vector2(3840, 2160)
		screenSize.AUTOMATIC:
			get_viewport().size = DisplayServer.screen_get_size()
	
	AudioServer.set_bus_volume_db(0, SettingsDict.SettingsMasterVolume)
	AudioServer.set_bus_volume_db(1, SettingsDict.SettingsMusicVolume)
	AudioServer.set_bus_volume_db(2, SettingsDict.SettingsCharacterVolume)
	AudioServer.set_bus_volume_db(3, SettingsDict.SettingsSFXVolume)
	
	# Something to change localization

func saveSettings() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForSettingsData, FileAccess.WRITE, "Platy1ium")
	file.store_var(SettingsDict)
	file.close()
	emit_signal("Saved")

func loadSettings() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForSettingsData, FileAccess.READ, "Platy1ium") 
	if checkSettingsDataExists():
		print("Settings Data Exists!")
		SettingsDict = file.get_var()
		print(SettingsDict)
		emit_signal("Loaded")
	else:
		print("Settings Data Doesn't Exists!")


func checkSettingsDataExists() -> bool:
	if FileAccess.file_exists(filePathForSettingsData):
		return true
	else:
		return false
