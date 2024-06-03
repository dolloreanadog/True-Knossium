extends Control
class_name ShopConfirmationWindow

@export var dungeon: BaseLevel

func YesButtonPressed() -> void:
	Global.StartLoadingScreen(true)
	await dungeon.saveToSaveSystem()
	get_tree().change_scene_to_file("res://resources/levels/ingame/shop/ShopLevel.tscn")

func NoButtonPressed() -> void:
	if dungeon.specialWindowContainer.get_child_count() != 0:
		dungeon.stopControlVisible(false, 1)
		dungeon.stopControlVisible(false, 2)
#	remove_child(self)
	dungeon.checkSpecialWindowContainer()
	queue_free()
