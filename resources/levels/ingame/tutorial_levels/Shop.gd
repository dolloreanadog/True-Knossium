extends Control

@onready var dungeon: TutorialShop = get_tree().get_current_scene()
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
			get_tree().change_scene_to_file("res://resources/levels/MainMenu.tscn")
		2:
			pass
		3:
			pass


func _on_end_shopping_button_pressed() -> void:
	TutorialIndexSwitch()
