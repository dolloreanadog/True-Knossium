extends Control
class_name ChooseNextLevelMenu

@onready var dungeon: BaseLevel = get_tree().get_current_scene()

const dungeonPaths: Dictionary = {
	"Dev Dungeon": "res://resources/levels/ingame/dungeon/Dungeon.tscn",
	"Dev Forest": "res://resources/levels/ingame/forest/Forest.tscn"
}

var availableDungeonPaths: Dictionary
var chosenDungeonPath: String

func _ready() -> void:
	for item in dungeonPaths:
		print("(check3)" + str(item))
		print("(check3)" + str(dungeonPaths[item]))
		print("(check3)" + str(get_tree().get_current_scene().get_scene_file_path()))
		if dungeonPaths[item] != get_tree().get_current_scene().get_scene_file_path():
			availableDungeonPaths[item] = dungeonPaths[item]
#			dungeonPaths.erase(item)
			print("(check3) Removed current scene path")
#			break;
	
	print("(check3) available paths: " + str(availableDungeonPaths))
	print("(check3) Got available paths")
# Need to check for available paths, do not have chosenDungeonPath be the same dungeon

# Use ShopConfirmationWindow as reference
# 2 button paths

func NextAreaButtonPressed() -> void:
	print("Yes pressed, going to shop.")
	dungeon.saveToSaveSystem()
	var confirm: bool = await dungeon.saveConfirmation()
	if confirm:
		Global.StartLoadingScreen(true)
		var chosenPath: String = availableDungeonPaths[availableDungeonPaths.keys().pick_random()]
		print("(check3) chosen paths: " + str(chosenPath))
		get_tree().change_scene_to_file(chosenPath)

func StayPressed() -> void:
	if dungeon.specialWindowContainer.get_child_count() != 0:
		dungeon.stopControlVisible(false, 1)
		dungeon.stopControlVisible(false, 2)
#	remove_child(self)
	dungeon.checkSpecialWindowContainer()
	queue_free()
