extends Area2D
class_name BaseAreaAOEDenial

var active: bool = true
@onready var visibility: ColorRect = self.get_node("ColorRect")

func _ready():
	pass

func setActive(boolean):
	print(str(self) + ": is active: " + str(boolean))
	active = boolean
	if active:
		visibility.visible = true
	else:
		visibility.visible = false
