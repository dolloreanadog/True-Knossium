extends Area2D
class_name BaseAreaAOEDenial

enum blockType {ALL, MELEE, RANGED}
var active: bool = true
@export var visibility: ColorRect
@export var blocker: blockType

func setActive(boolean):
#	print(str(self) + ": is active: " + str(boolean))
	active = boolean
	if is_instance_valid(visibility):
		if active:
			visibility.visible = true
		else:
			visibility.visible = false
