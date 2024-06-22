extends Control

@onready var dungeon: TutorialLevel = get_tree().get_current_scene()
var tutorialIndex: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorialIndex += 1

func IntroIndexSwitch() -> void:
	tutorialIndex += 1
	match tutorialIndex:
		0:
			$Part1.show()
		1:
			$Part1.hide()
			$Part2.show()
		2:
			dungeon.SwitchTutorialStep(dungeon.tutorialSteps.INVENTORY)
			self.queue_free()
	
	

func _on_button_pressed() -> void:
	IntroIndexSwitch()
