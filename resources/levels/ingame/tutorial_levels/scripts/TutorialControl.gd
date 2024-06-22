extends Control
class_name TutorialControl

@onready var dungeon: TutorialLevel = get_tree().get_current_scene()
var tutorialIndex: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TutorialIndexSwitch()

func TutorialIndexSwitch() -> void:
	tutorialIndex += 1
	match tutorialIndex:
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
