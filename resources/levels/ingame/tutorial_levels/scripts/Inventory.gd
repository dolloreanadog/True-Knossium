extends Control

@onready var inventoryMenu: InventoryMenu = $"../../InventoryMenu"
@onready var dungeon: TutorialLevel = get_tree().get_current_scene()
var tutorialIndex: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var inventoryMenuButton1 = inventoryMenu.get_node("ColorRect/SpawnAOEButton")
	var inventoryMenuButton2 = inventoryMenu.get_node("ColorRect/SpawnAllAOEButton")
	inventoryMenuButton1.connect("pressed", TutorialIndexSwitch)
	inventoryMenuButton2.connect("pressed", TutorialIndexSwitch)
	TutorialIndexSwitch()

func TutorialIndexSwitch() -> void:
	tutorialIndex += 1
	print("switched " + str(tutorialIndex))
	match tutorialIndex:
		0:
			$Part1.show()
		1: # Have them block the exit until they press another button
			$Part1.hide()
			$Part2.show()
		2:
			dungeon.inventoryUI.Exit()
			dungeon.SwitchTutorialStep(dungeon.tutorialSteps.PARTY)
			self.queue_free()



func _on_show_inventory_button_pressed() -> void:
	TutorialIndexSwitch()
