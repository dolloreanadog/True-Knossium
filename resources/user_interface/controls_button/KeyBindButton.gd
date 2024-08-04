extends Button
class_name KeybindButton

@export_enum("ToggleVisibilityAOEEnemy", "ToggleVisibilityAOEFriendly", "ToggleVisibilityAOESupport", "ToggleVisibilityAOEOffensive", "ToggleVisibilityAOENonDraggable", "ShowParty", "ShowInventory", "EndTurn", "ShowIngameMenu", "AutoPlaceAOE", "ViewStatsNormal", "ViewStatsHealth", "ViewStatsDefense", "ViewStatsAttack", "ViewStatsMorale", "ViewStatsLevel", "AttachMeleeAttackAOEToCursor", "AttachRangedAttackAOEToCursor", "AttachSupportAOEToCursor") var inputAction: String

func _init() -> void:
	toggle_mode = true

func _ready() -> void:
	set_process_unhandled_input(false)
	while SettingsSystem.inputsLoaded == false:
		await get_tree().create_timer(0.01).timeout
	UpdateText()

@warning_ignore("shadowed_variable_base_class")
func _toggled(button_pressed: bool) -> void:
	set_process_unhandled_input(button_pressed)
	if button_pressed:
		text = "Input Key"

func _unhandled_input(event: InputEvent) -> void:
	if event.pressed:
		InputMap.action_erase_events(inputAction)
		InputMap.action_add_event(inputAction, event)
		button_pressed = false
		release_focus()
		SettingsSystem.InputMapData[inputAction] = event
		SettingsSystem.saveInputMapData()
		UpdateText()
		

func UpdateText() -> void:
	if !(InputMap.action_get_events(inputAction).is_empty()):
		text = InputMap.action_get_events(inputAction)[0].as_text()
