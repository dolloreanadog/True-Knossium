extends Node2D

@export var character: Area2D

func _ready() -> void:
	$ConfirmButton.disabled = true
	$ConfirmButtonWarning.hide()

func ConfirmButtonPressed() -> void:
	SettingsSystem.clearSettingsThroughDeletion()
	SettingsSystem.saveSettings()
	SettingsSystem.applySettings()
	get_tree().change_scene_to_file("res://resources/levels/MainMenu.tscn")
	print(SettingsSystem.SettingsDict)

func AOEOnCharacter() -> void:
	var overlappingAOEs := character.get_overlapping_areas()
	print("(check) Array " + str(overlappingAOEs))
	print("(check) Array Size" + str(overlappingAOEs.size()))
	if overlappingAOEs.size() == 2:
		$ConfirmButton.disabled = true
		$ConfirmButtonWarning.text = "Can only have one AOE movement type, please put only one AOE on the dummy."
		$ConfirmButtonWarning.show()
	elif overlappingAOEs.size() == 0:
		$ConfirmButton.disabled = true
		$ConfirmButtonWarning.text = "Place An AOE on the character."
		$ConfirmButtonWarning.show()
	else:
		$ConfirmButton.disabled = false
		$ConfirmButtonWarning.hide()
		var overlappingAOE: SettingsAOE = overlappingAOEs.pop_back()
		SettingsSystem.setAOEMovement(overlappingAOE.AOEMovement)
		

func AOEMovementSliderValueChanged(value: float) -> void:
	if value == 0:
		# Click & Drag
		SettingsSystem.setAOEMovement(false)
	else:
		# Click & Click
		SettingsSystem.setAOEMovement(true)
