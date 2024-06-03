extends Node2D

func _ready() -> void:
	pass

func ConfirmButtonPressed() -> void:
	SettingsSystem.clearSettingsThroughDeletion()
	SettingsSystem.saveSettings()
	SettingsSystem.applySettings()
	get_tree().change_scene_to_file("res://resources/levels/MainMenu.tscn")
	print(SettingsSystem.SettingsDict)

func AOEMovementSliderValueChanged(value: float) -> void:
	if value == 0:
		# Click & Drag
		SettingsSystem.setAOEMovement(false)
	else:
		# Click & Click
		SettingsSystem.setAOEMovement(true)
