extends Control
class_name SettingsMenu

#--[ General Buttons ]--

@onready var AOEMovementButton: CheckButton = get_node("ColorRect/GameplayPanel/HBoxContainer/AOEMovementButton")

#--[ Display Buttons ]--

@onready var resolutionOptions: OptionButton = get_node("ColorRect/DisplayPanel/Control/ResolutionOptions")
@onready var windowModeOptions: OptionButton = get_node("ColorRect/DisplayPanel/Control2/WindowModeOptions")
@onready var languageOptions: OptionButton = get_node("ColorRect/DisplayPanel/Control3/LanguageOptions")

#--[ Audio Buttons ]--

@onready var masterVolSlider: HSlider = get_node("ColorRect/AudioPanel/Control/MasterVolSlider")
@onready var masterVolSpinbox: SpinBox = get_node("ColorRect/AudioPanel/Control/MasterVolSpinbox")

@onready var MusicVolSlider: HSlider = get_node("ColorRect/AudioPanel/Control2/MusicVolSlider")
@onready var MusicVolSpinbox: SpinBox = get_node("ColorRect/AudioPanel/Control2/MusicVolSpinbox")

@onready var characterVolSlider: HSlider = get_node("ColorRect/AudioPanel/Control3/CharacterVolSlider")
@onready var characterVolSpinbox: SpinBox = get_node("ColorRect/AudioPanel/Control3/CharacterVolSpinbox")

@onready var SFXVolSlider: HSlider = get_node("ColorRect/AudioPanel/Control4/SFXVolSlider")
@onready var SFXVolSpinbox: SpinBox = get_node("ColorRect/AudioPanel/Control4/SFXSpinboxSpinbox")

#--[ Keybinds ]--


#-- Button Values
var AOEMovementValue: bool
var resolutionIndex: int
var windowModeIndex: int
var languageIndex: int
var masterVolValue: int
var MusicVolValue: int
var characterVolValue: int
var SFXVolValue: int

#--[ Base Functions ]--

func _ready() -> void:
	setSettings()

func setSettings() -> void:
	AOEMovementButton.button_pressed = SettingsSystem.getAOEMovement()
	resolutionOptions.selected = SettingsSystem.getScreenSize()
	windowModeOptions.selected = SettingsSystem.getWindowedMode()
	languageOptions.selected = SettingsSystem.getTranslation()
	
	masterVolSlider.value = SettingsSystem.getMasterVolume()
	masterVolSpinbox.value = SettingsSystem.getMasterVolume()
	
	MusicVolSlider.value = SettingsSystem.getMusicVolume()
	MusicVolSpinbox.value = SettingsSystem.getMusicVolume()
	
	characterVolSlider.value = SettingsSystem.getCharacterVolume()
	characterVolSpinbox.value = SettingsSystem.getCharacterVolume()
	
	SFXVolSlider.value = SettingsSystem.getSFXVolume()
	SFXVolSpinbox.value = SettingsSystem.getSFXVolume()

#--[ Button Functions]--

func AOEMovementButtonToggled(button_pressed: bool) -> void:
	SettingsSystem.setAOEMovement(button_pressed)

# 0 1280x720
# 1 1366x768
# 2 1920x1080
# 3 2560 x 1440
# 4 3840 x 2160
func ResolutionOptionItemSelected(index: int) -> void:
	SettingsSystem.setScreenSize(resolutionOptions.get_item_id(index))

# 0 Fullscreen
# 1 Windowed
# 2 Borderless Fullscreen
# 3 Borderless Windowed
func WindowModeOptionItemSelected(index: int) -> void:
	SettingsSystem.setWindowedMode(windowModeOptions.get_item_id(index))

# 0 English
# 1 Simple Chinese
# 2 Japanese
# 3 Spanish
# 4 French
func LanguageOptionItemSelected(index: int) -> void:
	SettingsSystem.setTranslation(languageOptions.get_item_id(index))

func MasterVolSliderChanged(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	SettingsSystem.setMasterVolume(value)
	masterVolSpinbox.value = SettingsSystem.getMasterVolume()
func MasterVolSpinboxChanged(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	SettingsSystem.setMasterVolume(value)
	masterVolSlider.value = SettingsSystem.getMasterVolume()

func MusicVolSliderChanged(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	SettingsSystem.setMusicVolume(value)

	MusicVolSpinbox.value = SettingsSystem.getMusicVolume()
func MusicVolSpinboxChanged(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	SettingsSystem.setMusicVolume(value)
	MusicVolSlider.value = SettingsSystem.getMusicVolume()

func CharacterVolSliderChanged(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	SettingsSystem.setCharacterVolume(value)
	characterVolSpinbox.value = SettingsSystem.getCharacterVolume()
func CharacterVolSpinboxChanged(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	SettingsSystem.setCharacterVolume(value)
	characterVolSlider.value = SettingsSystem.getCharacterVolume()

func SFXVolSliderChanged(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	SettingsSystem.setSFXVolume(value)
	SFXVolSpinbox.value = SettingsSystem.getSFXVolume()

func SFXVolSpinboxChanged(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	SettingsSystem.setSFXVolume(value)
	MusicVolSpinbox.value = SettingsSystem.getMusicVolume()
	SFXVolSlider.value = SettingsSystem.getSFXVolume()


func OnExitPressed() -> void:
	self.hide()

func onSavedPressed() -> void:
	SettingsSystem.clearSettingsThroughDeletion()
	SettingsSystem.saveSettings()
	SettingsSystem.applySettings()
	print(SettingsSystem.SettingsDict)
